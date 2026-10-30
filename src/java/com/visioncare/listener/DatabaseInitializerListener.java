package com.visioncare.listener;

import com.visioncare.dao.DBContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

@WebListener
public class DatabaseInitializerListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("==================================================================");
        System.out.println("[VisionCare] Initializing & Checking Database Sync on Startup...");
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) {
                System.err.println("[VisionCare] WARNING: Could not connect to database. Please check db.properties!");
                return;
            }

            // 1. Kiểm tra số lượng dịch vụ trong Service_Catalog
            int serviceCount = 0;
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM Service_Catalog")) {
                if (rs.next()) {
                    serviceCount = rs.getInt(1);
                }
            } catch (Exception e) {
                System.err.println("[VisionCare] Service_Catalog table might not exist yet: " + e.getMessage());
            }

            // Nếu chưa đủ 16 dịch vụ chuẩn, tự động nạp bổ sung đầy đủ
            if (serviceCount < 16) {
                System.out.println("[VisionCare] Detected only " + serviceCount + " services. Auto-synchronizing all 16 services...");
                syncFullServices(conn);
            } else {
                System.out.println("[VisionCare] Service_Catalog is up-to-date with " + serviceCount + " services.");
            }

            // 2. Tự động kiểm tra và bổ sung cột doctor_completed_at vào bảng Appointment nếu chưa có
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('Appointment', 'doctor_completed_at') IS NULL "
                           + "ALTER TABLE Appointment ADD doctor_completed_at datetime2(7) NULL");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on doctor_completed_at check: " + e.getMessage());
            }

            // 2b. Tự động kiểm tra và cấu hình Work_Schedule cho lịch Nhân viên
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('dbo.Work_Schedule', 'Staff_Employee_ID') IS NULL "
                           + "ALTER TABLE dbo.Work_Schedule ADD Staff_Employee_ID INT NULL");
                stmt.execute("IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_WS_Has_Employee') "
                           + "BEGIN "
                           + "  ALTER TABLE [dbo].[Work_Schedule] DROP CONSTRAINT [CHK_WS_Has_Employee]; "
                           + "  ALTER TABLE [dbo].[Work_Schedule] WITH CHECK ADD CONSTRAINT [CHK_WS_Has_Employee] "
                           + "  CHECK (([Doctor_Employee_ID] IS NOT NULL OR [Specialist_Employee_ID] IS NOT NULL OR [Staff_Employee_ID] IS NOT NULL)); "
                           + "END");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Work_Schedule staff check: " + e.getMessage());
            }

            // 3. Tự động kiểm tra và bổ sung các cột mới cho Procedure_Order (2026-10-19)
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('dbo.Procedure_Order', 'Result_Text') IS NULL "
                           + "ALTER TABLE dbo.Procedure_Order ADD Result_Text NVARCHAR(MAX) NULL");
                stmt.execute("IF COL_LENGTH('dbo.Procedure_Order', 'Result_Conclusion') IS NULL "
                           + "ALTER TABLE dbo.Procedure_Order ADD Result_Conclusion NVARCHAR(MAX) NULL");
                stmt.execute("IF COL_LENGTH('dbo.Procedure_Order', 'Completed_At') IS NULL "
                           + "ALTER TABLE dbo.Procedure_Order ADD Completed_At DATETIME2 NULL");
                stmt.execute("IF COL_LENGTH('dbo.Procedure_Order', 'Referral_Notes') IS NULL "
                           + "ALTER TABLE dbo.Procedure_Order ADD Referral_Notes NVARCHAR(2000) NULL");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Procedure_Order columns check: " + e.getMessage());
            }

            // 4. Tự động kiểm tra và bổ sung các cột mới cho Prescription_Detail (2026-10-19)
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('dbo.Prescription_Detail', 'Morning_Dose') IS NULL "
                           + "ALTER TABLE dbo.Prescription_Detail ADD Morning_Dose NVARCHAR(100) NULL");
                stmt.execute("IF COL_LENGTH('dbo.Prescription_Detail', 'Afternoon_Dose') IS NULL "
                           + "ALTER TABLE dbo.Prescription_Detail ADD Afternoon_Dose NVARCHAR(100) NULL");
                stmt.execute("IF COL_LENGTH('dbo.Prescription_Detail', 'Evening_Dose') IS NULL "
                           + "ALTER TABLE dbo.Prescription_Detail ADD Evening_Dose NVARCHAR(100) NULL");
                stmt.execute("IF COL_LENGTH('dbo.Prescription_Detail', 'Is_Custom_Medicine') IS NULL "
                           + "ALTER TABLE dbo.Prescription_Detail ADD Is_Custom_Medicine BIT NOT NULL DEFAULT(0)");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Prescription_Detail columns check: " + e.getMessage());
            }

            // Keep reception notes separate from the doctor's clinical diagnosis.
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('dbo.Medical_Record', 'Staff_Notes') IS NULL "
                           + "ALTER TABLE dbo.Medical_Record ADD Staff_Notes NVARCHAR(MAX) NULL");
                stmt.execute("UPDATE mr SET Staff_Notes = mr.Clinical_Diagnosis "
                           + "FROM dbo.Medical_Record mr JOIN dbo.Appointment a "
                           + "ON a.Appointment_ID = mr.Appointment_ID "
                           + "WHERE a.Status IN ('Pending', 'Confirmed', 'In_Progress') "
                           + "AND mr.Staff_Notes IS NULL AND mr.Clinical_Diagnosis IS NOT NULL "
                           + "AND mr.examination_result IS NULL AND mr.conclusion IS NULL");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Staff_Notes migration: " + e.getMessage());
            }

            // Align the existing supply category constraint with the retail form.
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET XACT_ABORT ON; BEGIN TRANSACTION; "
                           + "IF EXISTS (SELECT 1 FROM sys.check_constraints "
                           + "WHERE name = 'CHK_Medical_Supply_Category' "
                           + "AND parent_object_id = OBJECT_ID('dbo.Medical_Supply') "
                           + "AND definition NOT LIKE N'%Kính áp tròng%') "
                           + "ALTER TABLE dbo.Medical_Supply DROP CONSTRAINT CHK_Medical_Supply_Category; "
                           + "IF OBJECT_ID('dbo.Medical_Supply', 'U') IS NOT NULL "
                           + "AND NOT EXISTS (SELECT 1 FROM sys.check_constraints "
                           + "WHERE name = 'CHK_Medical_Supply_Category' "
                           + "AND parent_object_id = OBJECT_ID('dbo.Medical_Supply')) "
                           + "ALTER TABLE dbo.Medical_Supply WITH CHECK ADD CONSTRAINT CHK_Medical_Supply_Category "
                           + "CHECK (Category IN (N'Khác', N'Vật tư y tế tiêu hao', N'Kính & Phụ kiện', "
                           + "N'Kính gọng & tròng kính', N'Kính áp tròng', "
                           + "N'Phụ kiện & sản phẩm hỗ trợ', N'Thuốc & dung dịch')); "
                           + "COMMIT TRANSACTION");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Medical_Supply categories: " + e.getMessage());
            }

            // 6. Tự động kiểm tra và khởi tạo 3 bảng quản lý hóa đơn & thanh toán (Invoice_Checkout, Invoice_Checkout_Item, Invoice_Checkout_Payment) nếu chưa có
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF OBJECT_ID('dbo.Invoice_Checkout','U') IS NULL "
                           + "CREATE TABLE dbo.Invoice_Checkout ("
                           + "  Invoice_ID int NOT NULL PRIMARY KEY REFERENCES dbo.Master_Invoice(Invoice_ID),"
                           + "  Base_Amount decimal(18,0) NOT NULL CHECK (Base_Amount >= 0),"
                           + "  Opening_Paid decimal(18,0) NOT NULL DEFAULT 0 CHECK (Opening_Paid >= 0),"
                           + "  Finalized_At datetime2 NULL, Finalized_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID),"
                           + "  Payment_Method nvarchar(50) NULL CONSTRAINT CHK_Checkout_Payment_Method CHECK(Payment_Method IS NULL OR Payment_Method COLLATE Latin1_General_100_BIN2 IN ('Cash','QR_Banking'))"
                           + ")");
                stmt.execute("IF COL_LENGTH('dbo.Invoice_Checkout','Opening_Paid') IS NULL "
                           + "ALTER TABLE dbo.Invoice_Checkout ADD Opening_Paid decimal(18,0) NOT NULL DEFAULT 0");
                stmt.execute("IF OBJECT_ID('dbo.Invoice_Checkout_Item','U') IS NULL "
                           + "CREATE TABLE dbo.Invoice_Checkout_Item ("
                           + "  Invoice_ID int NOT NULL REFERENCES dbo.Invoice_Checkout(Invoice_ID), Item_Key nvarchar(64) NOT NULL,"
                           + "  Item_Name nvarchar(500) NOT NULL, Item_Type nvarchar(30) NOT NULL,"
                           + "  Quantity int NOT NULL CHECK(Quantity > 0), Unit_Price decimal(18,0) NOT NULL CHECK(Unit_Price >= 0),"
                           + "  Removable bit NOT NULL, Declined bit NOT NULL DEFAULT 0, Unpriced bit NOT NULL DEFAULT 0,"
                           + "  Changed_By int NULL REFERENCES dbo.Employee_Profile(Employee_ID), Changed_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),"
                           + "  PRIMARY KEY(Invoice_ID, Item_Key)"
                           + ")");
                stmt.execute("IF OBJECT_ID('dbo.Invoice_Checkout_Payment','U') IS NULL "
                           + "BEGIN "
                           + "  CREATE TABLE dbo.Invoice_Checkout_Payment ("
                           + "    Order_Code bigint NOT NULL PRIMARY KEY, Invoice_ID int NOT NULL REFERENCES dbo.Invoice_Checkout(Invoice_ID),"
                           + "    Amount decimal(18,0) NOT NULL CHECK(Amount > 0), Fingerprint varchar(64) NOT NULL,"
                           + "    Status varchar(20) NOT NULL CHECK(Status IN ('Creating','Pending','Paid','Failed','Cancelled')),"
                           + "    Checkout_Url nvarchar(1000) NULL, QR_Code nvarchar(max) NULL,"
                           + "    Created_By int NOT NULL REFERENCES dbo.Employee_Profile(Employee_ID), Created_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),"
                           + "    Updated_At datetime2 NOT NULL DEFAULT SYSUTCDATETIME(), Transaction_ID int NULL REFERENCES dbo.Payment_Transaction(Transaction_ID)"
                           + "  ); "
                           + "  CREATE UNIQUE INDEX UX_Checkout_ActivePayment ON dbo.Invoice_Checkout_Payment(Invoice_ID) WHERE Status IN ('Creating','Pending'); "
                           + "END");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Invoice_Checkout tables init: " + e.getMessage());
            }

            // 7. Cấu hình linh hoạt Quy trình khám (Workflow Steps) & Tiền phẫu (Prerequisite Services) cho Service_Catalog
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("IF COL_LENGTH('dbo.Service_Catalog', 'Requires_Pre_Op') IS NULL "
                           + "ALTER TABLE dbo.Service_Catalog ADD Requires_Pre_Op BIT NOT NULL DEFAULT 0");
                stmt.execute("IF COL_LENGTH('dbo.Service_Catalog', 'Prerequisite_Service_ID') IS NULL "
                           + "ALTER TABLE dbo.Service_Catalog ADD Prerequisite_Service_ID INT NULL REFERENCES dbo.Service_Catalog(Service_ID)");
                stmt.execute("IF COL_LENGTH('dbo.Service_Catalog', 'Allow_Direct_Booking') IS NULL "
                           + "ALTER TABLE dbo.Service_Catalog ADD Allow_Direct_Booking BIT NOT NULL DEFAULT 1");

                stmt.execute("IF OBJECT_ID('dbo.Service_Workflow_Step', 'U') IS NULL "
                           + "CREATE TABLE dbo.Service_Workflow_Step ("
                           + "  Step_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, "
                           + "  Service_ID INT NOT NULL REFERENCES dbo.Service_Catalog(Service_ID) ON DELETE CASCADE, "
                           + "  Step_Name NVARCHAR(255) NOT NULL, "
                           + "  Step_Stage VARCHAR(20) NOT NULL DEFAULT 'PRE_EXAM', "
                           + "  Step_Order INT NOT NULL DEFAULT 1, "
                           + "  Description NVARCHAR(500) NULL "
                           + ")");

                // ===================================================================
                // CHÍNH SÁCH ĐẶT LỊCH THEO TỪNG DỊCH VỤ (Áp dụng mỗi lần khởi động)
                // ===================================================================

                // TRƯỜNG HỢP 1: Cho phép đặt trực tiếp, không yêu cầu tiền phẫu
                // Gồm: dịch vụ khám, chẩn đoán, tầm soát không xâm lấn;
                // các gói tiền phẫu (LS-03, TT-05) — bản thân chúng cho đặt trực tiếp;
                // TP-LEO, TP-LEDAO — bệnh nhân tự nhận biết triệu chứng (cục u mí mắt,
                // chảy nước mắt sống), phòng có phòng tiểu phẫu đặt slot trực tiếp được.
                stmt.execute("UPDATE Service_Catalog "
                           + "SET Allow_Direct_Booking = 1, Requires_Pre_Op = 0, Prerequisite_Service_ID = NULL "
                           + "WHERE Service_Code IN ('NK-01','KX-02','KX-MAY','PE-04','GL-06','OCT-DM','KM-CVS','KM-DM','LS-03','TT-05','TP-LEO','TP-LEDAO')");

                // TRƯỜNG HỢP 2: Cho phép đặt trực tiếp + Bắt buộc qua tiền phẫu trước
                // PT-LASIK & PT-SMILE: phẫu thuật giác mạc xâm lấn, bắt buộc đo Pentacam & bản đồ giác mạc trước
                stmt.execute("UPDATE Service_Catalog "
                           + "SET Allow_Direct_Booking = 1, Requires_Pre_Op = 1, "
                           + "Prerequisite_Service_ID = (SELECT TOP 1 Service_ID FROM Service_Catalog WHERE Service_Code = 'LS-03') "
                           + "WHERE Service_Code IN ('PT-LASIK','PT-SMILE')");

                // PT-PHACO: phẫu thuật thay thủy tinh thể, bắt buộc đo công suất IOL & kiểm tra tim mạch/đường huyết trước
                stmt.execute("UPDATE Service_Catalog "
                           + "SET Allow_Direct_Booking = 1, Requires_Pre_Op = 1, "
                           + "Prerequisite_Service_ID = (SELECT TOP 1 Service_ID FROM Service_Catalog WHERE Service_Code = 'TT-05') "
                           + "WHERE Service_Code = 'PT-PHACO'");

                // TRƯỜNG HỢP 3: Ẩn hoàn toàn khỏi trang đặt lịch, chỉ qua chỉ định Bác sĩ
                // TP-YAG: Laser YAG bao sau đục — tiêu chí: bệnh nhân KHÔNG THỂ tự biết mình cần dịch vụ này.
                // Đây là biến chứng sau phẫu thuật Phaco (bao sau bị đục lại). Bệnh nhân chỉ
                // biết "mắt mờ trở lại", họ book tái khám. Bác sĩ mới phát hiện và ra chỉ định TP-YAG.
                // Không có bệnh nhân nào tự tìm "Laser YAG bao sau đục" trên web để đặt lịch.
                stmt.execute("UPDATE Service_Catalog "
                           + "SET Allow_Direct_Booking = 0, Requires_Pre_Op = 0, Prerequisite_Service_ID = NULL "
                           + "WHERE Service_Code = 'TP-YAG'");

                // Thêm các bước quy trình mẫu nếu bảng Service_Workflow_Step đang trống
                stmt.execute("IF NOT EXISTS (SELECT 1 FROM dbo.Service_Workflow_Step) "
                           + "BEGIN "
                           + "  DECLARE @lasikId INT = (SELECT TOP 1 Service_ID FROM dbo.Service_Catalog WHERE Service_Code = 'PT-LASIK'); "
                           + "  IF @lasikId IS NOT NULL BEGIN "
                           + "    INSERT INTO dbo.Service_Workflow_Step (Service_ID, Step_Name, Step_Stage, Step_Order, Description) VALUES "
                           + "    (@lasikId, N'Lấy máu xét nghiệm đông máu & kiểm tra sinh hiệu', 'PRE_EXAM', 1, N'Kiểm tra công thức máu và các chỉ số sinh hóa trước mổ'), "
                           + "    (@lasikId, N'Đo khúc xạ máy Pentacam & chụp bản đồ giác mạc', 'PRE_EXAM', 2, N'Khảo sát độ dày, cấu trúc và bản đồ giác mạc chuyên sâu'), "
                           + "    (@lasikId, N'Khám tiền phẫu & kết luận điều kiện mổ với Bác sĩ', 'IN_EXAM', 3, N'Bác sĩ phẫu thuật kết luận mắt đủ tiêu chuẩn mổ Femto-LASIK'), "
                           + "    (@lasikId, N'Thực hiện phẫu thuật tại phòng mổ vô khuẩn', 'POST_EXAM', 4, N'Ca mổ 15 phút với hệ thống Laser Femtosecond hiện đại'), "
                           + "    (@lasikId, N'Nghỉ ngơi hồi tỉnh & hẹn lịch tái khám định kỳ', 'POST_EXAM', 5, N'Theo dõi 30 phút sau mổ và phát kính bảo vệ mắt'); "
                           + "  END "
                           + "  DECLARE @smileId INT = (SELECT TOP 1 Service_ID FROM dbo.Service_Catalog WHERE Service_Code = 'PT-SMILE'); "
                           + "  IF @smileId IS NOT NULL BEGIN "
                           + "    INSERT INTO dbo.Service_Workflow_Step (Service_ID, Step_Name, Step_Stage, Step_Order, Description) VALUES "
                           + "    (@smileId, N'Lấy máu xét nghiệm & tầm soát bệnh lý toàn thân', 'PRE_EXAM', 1, N'Xét nghiệm máu an toàn trước can thiệp'), "
                           + "    (@smileId, N'Đo nhãn áp & phân tích cơ sinh học giác mạc Corvis', 'PRE_EXAM', 2, N'Đánh giá độ bền và độ giãn lồi của giác mạc'), "
                           + "    (@smileId, N'Bác sĩ chuyên khoa khúc xạ khám & duyệt phác đồ mổ', 'IN_EXAM', 3, N'Lập trình thông số phẫu thuật trên máy VisuMax'), "
                           + "    (@smileId, N'Phẫu thuật ReLEx SMILE rút lõi mô giác mạc 2mm', 'POST_EXAM', 4, N'Phẫu thuật không tạo vạt, hạn chế tối đa khô mắt'), "
                           + "    (@smileId, N'Kiểm tra mắt sau mổ, cấp kính bảo hộ và thuốc nhỏ', 'POST_EXAM', 5, N'Hướng dẫn chăm sóc mắt và tái khám sau 24 giờ'); "
                           + "  END "
                           + "  DECLARE @phacoId INT = (SELECT TOP 1 Service_ID FROM dbo.Service_Catalog WHERE Service_Code = 'PT-PHACO'); "
                           + "  IF @phacoId IS NOT NULL BEGIN "
                           + "    INSERT INTO dbo.Service_Workflow_Step (Service_ID, Step_Name, Step_Stage, Step_Order, Description) VALUES "
                           + "    (@phacoId, N'Xét nghiệm máu, đo điện tâm đồ & kiểm tra đường huyết', 'PRE_EXAM', 1, N'Tầm soát an toàn tim mạch và tiểu đường trước mổ'), "
                           + "    (@phacoId, N'Siêu âm mắt & đo công suất kính nội nhãn IOL', 'PRE_EXAM', 2, N'Đo chính xác độ khúc xạ của thủy tinh thể nhân tạo'), "
                           + "    (@phacoId, N'Bác sĩ khám lâm sàng & tư vấn chọn loại kính IOL', 'IN_EXAM', 3, N'Lựa chọn kính đơn tiêu, đa tiêu hoặc toric phù hợp'), "
                           + "    (@phacoId, N'Phẫu thuật Phaco tán nhuyễn và thay thủy tinh thể', 'POST_EXAM', 4, N'Ca mổ đường rạch siêu nhỏ 2.2mm, không đau'), "
                           + "    (@phacoId, N'Băng mắt bảo vệ, theo dõi hậu phẫu & hẹn tái khám', 'POST_EXAM', 5, N'Theo dõi 1-2 tiếng tại phòng hồi tỉnh trước khi xuất viện'); "
                           + "  END "
                           + "  DECLARE @generalId INT = (SELECT TOP 1 Service_ID FROM dbo.Service_Catalog WHERE Service_Code = 'NK-01'); "
                           + "  IF @generalId IS NOT NULL BEGIN "
                           + "    INSERT INTO dbo.Service_Workflow_Step (Service_ID, Step_Name, Step_Stage, Step_Order, Description) VALUES "
                           + "    (@generalId, N'Đo thị lực & đo khúc xạ máy tự động', 'PRE_EXAM', 1, N'Kiểm tra thị lực ban đầu và độ khúc xạ cơ bản'), "
                           + "    (@generalId, N'Đo nhãn áp không tiếp xúc', 'PRE_EXAM', 2, N'Tầm soát áp lực nhãn cầu phòng ngừa Glaucoma'), "
                           + "    (@generalId, N'Bác sĩ khám sinh hiển vi & soi đáy mắt trực tiếp', 'IN_EXAM', 3, N'Khám toàn diện kết giác mạc, tiền phòng và võng mạc'), "
                           + "    (@generalId, N'Tư vấn toa thuốc & hướng dẫn chăm sóc mắt', 'POST_EXAM', 4, N'Kê đơn thuốc hoặc tư vấn chuyển phòng chuyên khoa nếu cần'); "
                           + "  END "
                           + "END");
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on Service_Workflow_Step & PreOp migration: " + e.getMessage());
            }

            System.out.println("[VisionCare] Database check completed successfully!");
            System.out.println("==================================================================");

        } catch (Exception e) {
            System.err.println("[VisionCare] Note on DB Init: " + e.getMessage());
            System.err.println("[VisionCare] If database is not created yet, please run database/eye_clinic_db.sql or setup_database.bat.");
        }
    }

    private void syncFullServices(Connection conn) {
        String[][] services = {
            {"NK-01", "Khám mắt tổng quát & Soi đáy mắt", "200000", "Khám và tư vấn",
             "Khám và chẩn đoán toàn diện các bệnh lý về mắt, đo thị lực, kiểm tra áp lực nhãn cầu và soi đáy mắt.",
             "Bao gồm đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt, đánh giá tình trạng giác mạc và thủy tinh thể."},
            {"KX-02", "Đo khúc xạ và tư vấn kính", "150000", "Kiểm tra và chẩn đoán",
             "Khám sàng lọc và đo độ khúc xạ với hệ thống đo tự động chuẩn xác.",
             "Đo khúc xạ chính xác bằng máy tự động, thử thị lực và tư vấn tròng kính phù hợp."},
            {"LS-03", "Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE", "500000", "Khám và tư vấn",
             "Khám chuyên sâu 8 bước bản đồ giác mạc, đo độ dày giác mạc, soi đáy mắt và tư vấn phương pháp xóa cận. Hoàn trừ 100% phí khám nếu thực hiện mổ.",
             "Gói khám tiền phẫu bắt buộc để đánh giá mắt đủ điều kiện phẫu thuật khúc xạ (Femto-LASIK, ReLEx SMILE). Toàn bộ phí khám 500.000đ sẽ được trừ 100% vào chi phí ca mổ nếu quý khách tiến hành phẫu thuật."},
            {"PE-04", "Khám mắt trẻ em và tư vấn nhược thị", "300000", "Khám và tư vấn",
             "Sàng lọc sớm các tật khúc xạ tiến triển, tật lé và suy giảm thị lực ở trẻ nhỏ.",
             "Sàng lọc cận thị sớm, điều trị nhược thị và lác mắt trong không gian khám thân thiện."},
            {"TT-05", "Khám tầm soát & Tư vấn phẫu thuật Phaco (Đục thủy tinh thể)", "300000", "Khám và tư vấn",
             "Kiểm tra mức độ đục thể thủy tinh, đo công suất thể thủy tinh nhân tạo và tư vấn phẫu thuật Phaco. Hoàn trừ 100% phí khám nếu thực hiện mổ.",
             "Khám sàng lọc và tư vấn phẫu thuật Phaco đặt kính nội nhãn. Toàn bộ phí khám được khấu trừ 100% vào chi phí ca mổ khi thực hiện phẫu thuật."},
            {"GL-06", "Đo nhãn áp & Tầm soát Glaucoma", "250000", "Khám và tư vấn",
             "Kiểm tra áp lực nhãn cầu, soi góc tiền phòng và tầm soát phát hiện sớm bệnh lý thiên đầu thống (Glaucoma).",
             "Tầm soát và can thiệp bệnh Glaucoma, thoái hóa hoàng điểm và tổn thương võng mạc với hệ thống OCT."},
            {"KX-MAY", "Đo khúc xạ máy", "100000", "Kiểm tra và chẩn đoán",
             "Đo độ khúc xạ bằng máy đo tự động kỹ thuật số.", ""},
            {"OCT-DM", "Chụp OCT đáy mắt", "400000", "Kiểm tra và chẩn đoán",
             "Chụp cắt lớp quang học võng mạc, gai thị độ phân giải cao.", ""},
            {"KM-CVS", "Khám & Điều trị Khô mắt (Hội chứng màn hình)", "200000", "Khám và tư vấn",
             "Đo màng phim nước mắt, kiểm tra tuyến Meibomius và điều trị khô rát mỏi mắt do sử dụng máy tính, điện thoại kéo dài.",
             "Gói khám và phục hồi mắt chuyên sâu cho nhân viên văn phòng, học sinh sinh viên thường xuyên tiếp xúc màn hình điện tử."},
            {"KM-DM", "Khám & Tầm soát Đáy mắt - Võng mạc tiểu đường", "300000", "Khám và tư vấn",
             "Chụp màu đáy mắt, soi võng mạc tầm soát biến chứng xuất huyết võng mạc ở người tiểu đường và cao huyết áp.",
             "Quy trình chẩn đoán chuyên sâu giúp phát hiện sớm và can thiệp kịp thời các tổn thương võng mạc do đái tháo đường."},
            {"PT-LASIK", "Phẫu thuật Femto-LASIK hai mắt", "18000000", "Điều trị và thủ thuật",
             "Phẫu thuật khúc xạ không dao Femtosecond Laser chính xác, phục hồi thị lực nhanh 10/10.",
             "Phương pháp xóa cận viễn loạn hiện đại, an toàn, không đau, thời gian thực hiện chỉ 15 phút."},
            {"PT-SMILE", "Phẫu thuật ReLEx SMILE xóa cận", "42000000", "Điều trị và thủ thuật",
             "Công nghệ phẫu thuật khúc xạ không vạt tiên tiến nhất, đường rạch siêu nhỏ 2mm bảo tồn giác mạc tối đa.",
             "Kỹ thuật rút lõi mô giác mạc bằng công nghệ VisuMax từ Đức, giảm thiểu tối đa khô mắt sau mổ."},
            {"PT-PHACO", "Phẫu thuật Phaco đặt thủy tinh thể nhân tạo", "12000000", "Điều trị và thủ thuật",
             "Tán nhuyễn thể thủy tinh đục bằng sóng siêu âm Phaco và đặt thể thủy tinh nhân tạo cao cấp đường mổ 2.2mm.",
             "Ca phẫu thuật nhanh chóng 10-15 phút, xuất viện trong ngày, khôi phục thị lực sáng rõ cho người cao tuổi."},
            {"TP-LEO", "Chích rạch chắp lẹo mi mắt", "250000", "Điều trị và thủ thuật",
             "Tiểu phẫu dẫn lưu ổ viêm chắp lẹo mí mắt an toàn, vô trùng, hạn chế tái phát và đảm bảo thẩm mỹ.",
             "Thực hiện thủ thuật tại phòng tiểu phẫu vô khuẩn."},
            {"TP-LEDAO", "Bơm thông rửa lệ đạo", "300000", "Điều trị và thủ thuật",
             "Thông tắc đường dẫn lệ giải quyết triệt để triệu chứng chảy nước mắt sống và viêm túi lệ mạn tính.",
             "Quy trình thông rửa nhẹ nhàng với dụng cụ chuyên dụng."},
            {"TP-YAG", "Bắn Laser YAG bao sau đục", "1500000", "Điều trị và thủ thuật",
             "Thủ thuật laser ngoại trú làm trong suốt lại bao sau thể thủy tinh sau phẫu thuật Phaco.",
             "Không phẫu thuật, chỉ mất 5 phút, thị lực sáng rõ trở lại ngay sau khi bắn laser."}
        };

        String sqlCheck = "SELECT Service_ID FROM Service_Catalog WHERE Service_Code = ?";
        String sqlInsert = "INSERT INTO Service_Catalog (Service_Code, Service_Name, Price, Category, Summary, Description) VALUES (?, ?, ?, ?, ?, ?)";
        String sqlUpdate = "UPDATE Service_Catalog SET Service_Name = ?, Price = ?, Category = ?, Summary = ?, Description = ? WHERE Service_Code = ?";

        int addedCount = 0;
        for (String[] svc : services) {
            String code = svc[0];
            String name = svc[1];
            long price = Long.parseLong(svc[2]);
            String cat = svc[3];
            String sum = svc[4];
            String desc = svc[5];

            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setString(1, code);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        // Cập nhật thông tin dịch vụ nếu đã có code
                        try (PreparedStatement psUpd = conn.prepareStatement(sqlUpdate)) {
                            psUpd.setString(1, name);
                            psUpd.setLong(2, price);
                            psUpd.setString(3, cat);
                            psUpd.setString(4, sum);
                            psUpd.setString(5, desc);
                            psUpd.setString(6, code);
                            psUpd.executeUpdate();
                        }
                    } else {
                        // Thêm mới nếu chưa có
                        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert)) {
                            psIns.setString(1, code);
                            psIns.setString(2, name);
                            psIns.setLong(3, price);
                            psIns.setString(4, cat);
                            psIns.setString(5, sum);
                            psIns.setString(6, desc);
                            psIns.executeUpdate();
                            addedCount++;
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("[VisionCare] Error syncing service " + code + ": " + e.getMessage());
            }
        }
        System.out.println("[VisionCare] Synchronized full 16 services (added " + addedCount + " new services).");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
