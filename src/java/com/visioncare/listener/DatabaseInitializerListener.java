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

            // 5. Tự động quét và hủy các ca hẹn trong quá khứ mà bệnh nhân không đến (chưa check-in)
            try {
                int canceledCount = new com.visioncare.dao.AppointmentDAO().autoCancelExpiredAppointments();
                if (canceledCount > 0) {
                    System.out.println("[VisionCare] Auto-canceled " + canceledCount + " past un-checked-in appointments.");
                }
            } catch (Exception e) {
                System.err.println("[VisionCare] Note on auto-cancel past appointments on startup: " + e.getMessage());
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
