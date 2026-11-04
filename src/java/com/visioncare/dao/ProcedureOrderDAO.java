package com.visioncare.dao;

import com.visioncare.model.MedicalRecord;
import com.visioncare.model.Patient;
import com.visioncare.model.ProcedureOrder;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProcedureOrderDAO {
    // Appointment alias is 'a' in clinical queues and authorization queries.
    public static final String NO_PROCEDURE_HANDOFF = "NOT EXISTS (SELECT 1 FROM Procedure_Order handoff "
            + "JOIN Medical_Record handoff_record ON handoff_record.Record_ID=handoff.Record_ID "
            + "WHERE handoff_record.Appointment_ID=a.Appointment_ID AND handoff.Status<>'Cancelled')";

    @FunctionalInterface public interface Connections { Connection open() throws Exception; }
    private final Connections connections;
    public ProcedureOrderDAO() { this(DBContext::getConnection); }
    public ProcedureOrderDAO(Connections connections) { this.connections = connections; }

    public boolean isStaffRequestSchemaReady() throws Exception {
        try (Connection c = connections.open(); PreparedStatement p = c.prepareStatement(
                "SELECT CASE WHEN COL_LENGTH('dbo.Procedure_Order','Requested_By_Employee_ID') IS NOT NULL "
                + "AND COL_LENGTH('dbo.Procedure_Order','Requested_At') IS NOT NULL "
                + "AND COLUMNPROPERTY(OBJECT_ID('dbo.Medical_Record'),'Doctor_Employee_ID','AllowsNull')=1 THEN 1 ELSE 0 END")) {
            try (ResultSet r = p.executeQuery()) { return r.next() && r.getInt(1) == 1; }
        }
    }

    public List<Map<String,Object>> getProcedureRequestPatients() throws Exception {
        List<Map<String,Object>> rows = new ArrayList<>();
        try (Connection c = connections.open(); PreparedStatement p = c.prepareStatement(
                "SELECT a.Appointment_ID,p.Patient_ID,p.Full_Name,p.Phone,ws.Work_Date,ws.Start_Time "
                + "FROM Appointment a JOIN Patient p ON p.Patient_ID=a.Patient_ID "
                + "JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
                + "WHERE a.checkin_time IS NOT NULL AND a.Status IN ('Confirmed','In_Progress') "
                + "AND ws.Work_Date=CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS date) "
                + "ORDER BY a.checkin_time,a.Appointment_ID")) {
            try (ResultSet r=p.executeQuery()) { while(r.next()) {
                Map<String,Object> row=new HashMap<>();
                row.put("appointmentId",r.getInt("Appointment_ID")); row.put("patientId",r.getInt("Patient_ID"));
                row.put("name",r.getString("Full_Name")); row.put("phone",r.getString("Phone"));
                rows.add(row);
            }}
        }
        return rows;
    }

    public List<Map<String,Object>> getProcedureRequestServices() throws Exception {
        List<Map<String,Object>> rows=new ArrayList<>();
        try(Connection c=connections.open(); PreparedStatement p=c.prepareStatement(
                "SELECT Service_ID,Service_Name,Price FROM Service_Catalog "
                + "WHERE Service_Code LIKE 'PT-%' ORDER BY Service_Name")) {
            try(ResultSet r=p.executeQuery()){while(r.next()){
                Map<String,Object> row=new HashMap<>();row.put("id",r.getInt(1));
                row.put("name",r.getString(2));row.put("price",r.getBigDecimal(3));rows.add(row);
            }}
        }
        return rows;
    }

    public Map<String,Object> getProcedureRequestContext(int appointmentId) throws Exception {
        Map<String,Object> row=new HashMap<>();
        try(Connection c=connections.open(); PreparedStatement p=c.prepareStatement(
                "SELECT a.Appointment_ID,p.Full_Name,p.Phone,mr.Record_ID,mr.Clinical_Diagnosis,mr.examination_result,mr.conclusion, "
                + "doc.Full_Name AS Doctor_Name FROM Appointment a JOIN Patient p ON p.Patient_ID=a.Patient_ID "
                + "LEFT JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID "
                + "LEFT JOIN Employee_Profile doc ON doc.Employee_ID=mr.Doctor_Employee_ID WHERE a.Appointment_ID=?")) {
            p.setInt(1,appointmentId);try(ResultSet r=p.executeQuery()){if(r.next()){
                row.put("name",r.getString("Full_Name"));row.put("phone",r.getString("Phone"));
                row.put("doctor",r.getString("Doctor_Name"));row.put("diagnosis",r.getString("Clinical_Diagnosis"));
                row.put("recordId",r.getInt("Record_ID"));
                row.put("findings",r.getString("examination_result"));row.put("conclusion",r.getString("conclusion"));
            }}
        }
        return row;
    }

    /** Lock the visit before creating an order, so duplicate submits and visit closure serialize. */
    public int createStaffRequest(int appointmentId,int serviceId,int staffId,String notes) throws Exception {
        if(appointmentId<=0||serviceId<=0||staffId<=0||notes==null||notes.length()>2000)
            throw new IllegalArgumentException("Thông tin chuyển ca không hợp lệ (ghi chú tối đa 2.000 ký tự).");
        try(Connection c=connections.open()) {
            c.setAutoCommit(false);
            try {
                try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM Employee_Profile e JOIN Account a ON a.Account_ID=e.Account_ID "
                        + "WHERE e.Employee_ID=? AND a.Role_ID=5 AND a.Account_Status='Active'")) {
                    p.setInt(1,staffId);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalStateException("Chỉ nhân viên tiếp nhận được gửi ca.");}
                }
                try(PreparedStatement p=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a WITH (UPDLOCK,HOLDLOCK) "
                        + "JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID WHERE a.Appointment_ID=? "
                        + "AND a.Status IN ('Confirmed','In_Progress') AND a.checkin_time IS NOT NULL "
                        + "AND ws.Work_Date=CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS date) "
                        + "AND NOT EXISTS(SELECT 1 FROM Master_Invoice mi JOIN Invoice_Checkout checkout ON checkout.Invoice_ID=mi.Invoice_ID "
                        + "WHERE mi.Appointment_ID=a.Appointment_ID AND checkout.Finalized_At IS NOT NULL)")) {
                    p.setInt(1,appointmentId);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalStateException("Lượt khám chưa check-in, đã kết thúc hoặc không thuộc hôm nay.");}
                }
                int recordId=0;
                try(PreparedStatement p=c.prepareStatement("SELECT Record_ID FROM Medical_Record WITH (UPDLOCK,HOLDLOCK) WHERE Appointment_ID=?")) {
                    p.setInt(1,appointmentId);try(ResultSet r=p.executeQuery()){if(r.next())recordId=r.getInt(1);}
                }
                if(recordId==0)try(PreparedStatement p=c.prepareStatement("INSERT INTO Medical_Record(Appointment_ID,Doctor_Employee_ID,Created_At) "
                        + "OUTPUT INSERTED.Record_ID VALUES(?,NULL,DATEADD(HOUR,7,SYSUTCDATETIME()))")) {
                    p.setInt(1,appointmentId);try(ResultSet r=p.executeQuery()){if(!r.next())throw new SQLException("Không tạo được hồ sơ tiếp nhận.");recordId=r.getInt(1);}
                }
                try(PreparedStatement p=c.prepareStatement("SELECT Order_ID FROM Procedure_Order WITH (UPDLOCK,HOLDLOCK) "
                        + "WHERE Record_ID=? AND Service_ID=? AND Status<>'Cancelled'")) {
                    p.setInt(1,recordId);p.setInt(2,serviceId);try(ResultSet r=p.executeQuery()){
                        if(r.next())throw new IllegalStateException("Dịch vụ này đã được gửi hoặc thực hiện trong lượt khám. Vui lòng kiểm tra ca đã có.");
                    }
                }
                int orderId;
                try(PreparedStatement p=c.prepareStatement("INSERT INTO Procedure_Order(Record_ID,Service_ID,Status,Actual_Price,Referral_Notes,Requested_By_Employee_ID,Requested_At) "
                        + "OUTPUT INSERTED.Order_ID SELECT ?,Service_ID,'Pending',Price,?,?,DATEADD(HOUR,7,SYSUTCDATETIME()) "
                        + "FROM Service_Catalog WITH (HOLDLOCK) WHERE Service_ID=? AND Service_Code LIKE 'PT-%'")) {
                    p.setInt(1,recordId);p.setNString(2,notes.trim());p.setInt(3,staffId);p.setInt(4,serviceId);
                    try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalStateException("Dịch vụ thủ thuật không hợp lệ.");orderId=r.getInt(1);}
                }
                // Sending to a Specialist starts this clinical visit without requiring a Doctor to call it.
                try(PreparedStatement p=c.prepareStatement("UPDATE Appointment SET Status='In_Progress' WHERE Appointment_ID=? AND Status='Confirmed'")) {
                    p.setInt(1,appointmentId);p.executeUpdate();
                }
                c.commit();return orderId;
            }catch(Exception e){c.rollback();throw e;}
        }
    }

    private static final String BASE_SELECT_ORDER = 
        "SELECT " +
        "    po.Order_ID, " +
        "    po.Specialist_Employee_ID, " +
        "    po.Record_ID, " +
        "    po.Service_ID, " +
        "    po.Status, " +
        "    po.Referral_Notes, " +
        "    CAST(NULL AS nvarchar(255)) AS Requester_Name, " +
        "    s.Service_Code, pr.Status AS Payment_Status, " +
        "    s.Service_Name, " +
        "    po.Actual_Price AS Service_Price, " +
        "    spec.Full_Name AS Specialist_Name, " +
        "    spec.Phone AS Specialist_Phone, " +
        "    r.Room_Name, " +
        "    mr.Appointment_ID, " +
        "    mr.Doctor_Employee_ID, " +
        "    mr.Clinical_Diagnosis, " +
        "    po.Result_Text AS examination_result, " +
        "    po.Result_Conclusion AS conclusion, " +
        "    mr.Created_At AS Record_Created_At, " +
        "    doc.Full_Name AS Doctor_Name, " +
        "    p.Patient_ID, " +
        "    p.Full_Name AS Patient_Name, " +
        "    p.Phone AS Patient_Phone, " +
        "    p.DOB AS Patient_DOB, " +
        "    p.Address AS Patient_Address " +
        "FROM Procedure_Order po " +
        "JOIN Service_Catalog s ON po.Service_ID = s.Service_ID " +
        "LEFT JOIN Procedure_Payment_Request pr ON pr.Order_ID = po.Order_ID " +
        "JOIN Medical_Record mr ON po.Record_ID = mr.Record_ID " +
        "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
        "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
        "LEFT JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
        "LEFT JOIN Employee_Profile spec ON po.Specialist_Employee_ID = spec.Employee_ID " +
        "LEFT JOIN Room r ON spec.Room_ID = r.Room_ID ";

    private String orderQuery() throws Exception {
        if(!isStaffRequestSchemaReady())return BASE_SELECT_ORDER;
        return BASE_SELECT_ORDER
                .replace("CAST(NULL AS nvarchar(255)) AS Requester_Name", "requester.Full_Name AS Requester_Name")
                .replace("mr.Created_At AS Record_Created_At", "COALESCE(po.Requested_At,mr.Created_At) AS Record_Created_At")
                + "LEFT JOIN Employee_Profile requester ON requester.Employee_ID=po.Requested_By_Employee_ID ";
    }

    // ==========================================
    // SCREEN 34: SPECIALIST WAITING LIST SCREEN
    // ==========================================

    /**
     * Lấy danh sách hàng đợi chỉ định cận lâm sàng cho Kỹ thuật viên (Specialist)
     * @param specialistId Nếu có, lọc theo KTV này hoặc các ca chưa có người nhận (null). Nếu null, lấy toàn bộ clinic.
     * @param status Trạng thái lọc ('Pending', 'Completed', 'Cancelled', hoặc 'all')
     * @param keyword Từ khóa tìm kiếm theo tên bệnh nhân, số điện thoại, tên dịch vụ
     * @param workDate Ngày chỉ định (lọc theo ngày, nếu null thì không lọc theo ngày)
     */
    public List<ProcedureOrder> getWaitingList(Integer specialistId, String status, String keyword, Date workDate) throws Exception {
        List<ProcedureOrder> list = new ArrayList<>();
        String base=orderQuery();
        StringBuilder sql = new StringBuilder(base);
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (specialistId != null && specialistId > 0) {
            sql.append("AND (po.Specialist_Employee_ID = ? OR po.Specialist_Employee_ID IS NULL) ");
            params.add(specialistId);
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            if ("Pending".equalsIgnoreCase(status.trim())) {
                sql.append("AND po.Status IN ('Pending', 'In_Progress') ");
            } else {
                sql.append("AND po.Status = ? ");
                params.add(status.trim());
            }
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR s.Service_Name LIKE ?) ");
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
            params.add(kwParam);
        }

        if (workDate != null) {
            sql.append(base.contains("COALESCE(po.Requested_At")
                    ? "AND CAST(COALESCE(po.Requested_At,mr.Created_At) AS DATE) = ? "
                    : "AND CAST(mr.Created_At AS DATE) = ? ");
            params.add(workDate);
        }

        sql.append("ORDER BY ");
        sql.append("  CASE WHEN po.Status = 'In_Progress' THEN 1 ");
        sql.append("       WHEN po.Status = 'Pending' THEN 2 ");
        sql.append("       WHEN po.Status = 'Completed' THEN 3 ");
        sql.append("       ELSE 4 END, ");
        sql.append("  po.Order_ID DESC ");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Đếm số lượng order theo các trạng thái để hiển thị badge số lượng
     */
    public Map<String, Integer> getOrderStatusCounts(Integer specialistId) throws Exception {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("all", 0);
        counts.put("pending", 0);
        counts.put("inProgress", 0);
        counts.put("completed", 0);
        counts.put("cancelled", 0);

        StringBuilder sql = new StringBuilder("SELECT po.Status, COUNT(*) AS Total FROM Procedure_Order po " +
                                              "JOIN Service_Catalog s ON po.Service_ID = s.Service_ID " +
                                              "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (specialistId != null && specialistId > 0) {
            sql.append("AND (po.Specialist_Employee_ID = ? OR po.Specialist_Employee_ID IS NULL) ");
            params.add(specialistId);
        }
        sql.append("GROUP BY po.Status ");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                int total = 0;
                while (rs.next()) {
                    String st = rs.getString("Status");
                    int cnt = rs.getInt("Total");
                    total += cnt;
                    if ("Pending".equalsIgnoreCase(st)) {
                        counts.put("pending", counts.get("pending") + cnt);
                    } else if ("In_Progress".equalsIgnoreCase(st)) {
                        counts.put("inProgress", cnt);
                        counts.put("pending", counts.get("pending") + cnt); // Also include in pending queue count
                    } else if ("Completed".equalsIgnoreCase(st)) {
                        counts.put("completed", cnt);
                    } else if ("Cancelled".equalsIgnoreCase(st)) {
                        counts.put("cancelled", cnt);
                    }
                }
                counts.put("all", total);
            }
        }
        return counts;
    }

    // ==========================================
    // SCREEN 35: SPECIALIST PATIENT DETAIL SCREEN
    // ==========================================

    /**
     * Lấy thông tin cơ bản của bệnh nhân theo Patient_ID
     */
    public Patient getPatientById(int patientId) throws Exception {
        String sql = "SELECT Patient_ID, Account_ID, Full_Name, Phone, DOB, Address FROM Patient WHERE Patient_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Patient(
                        rs.getInt("Patient_ID"),
                        rs.getObject("Account_ID") != null ? rs.getInt("Account_ID") : null,
                        rs.getString("Full_Name"),
                        rs.getString("Phone"),
                        rs.getDate("DOB"),
                        rs.getString("Address")
                    );
                }
            }
        }
        return null;
    }

    /**
     * Lấy thông tin bệnh nhân qua Record_ID
     */
    public Patient getPatientByRecordId(int recordId) throws Exception {
        String sql = "SELECT p.Patient_ID, p.Account_ID, p.Full_Name, p.Phone, p.DOB, p.Address " +
                     "FROM Medical_Record mr " +
                     "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "WHERE mr.Record_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Patient(
                        rs.getInt("Patient_ID"),
                        rs.getObject("Account_ID") != null ? rs.getInt("Account_ID") : null,
                        rs.getString("Full_Name"),
                        rs.getString("Phone"),
                        rs.getDate("DOB"),
                        rs.getString("Address")
                    );
                }
            }
        }
        return null;
    }

    /**
     * Lấy lịch sử khám bệnh (các lần khám trước) của bệnh nhân
     */
    public List<MedicalRecord> getPatientMedicalHistory(int patientId) throws Exception {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = "SELECT mr.Record_ID, mr.Appointment_ID, mr.Doctor_Employee_ID, mr.Clinical_Diagnosis, " +
                     "       mr.examination_result, mr.conclusion, mr.Created_At, " +
                     "       doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
                     "       a.Status AS Appointment_Status, a.checkin_time, " +
                     "       p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address " +
                     "FROM Medical_Record mr " +
                     "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "LEFT JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
                     "WHERE p.Patient_ID = ? " +
                     "ORDER BY mr.Created_At DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MedicalRecord r = new MedicalRecord();
                    r.setRecordId(rs.getInt("Record_ID"));
                    r.setAppointmentId(rs.getInt("Appointment_ID"));
                    r.setDoctorEmployeeId(rs.getInt("Doctor_Employee_ID"));
                    r.setClinicalDiagnosis(rs.getString("Clinical_Diagnosis"));
                    r.setExaminationResult(rs.getString("examination_result"));
                    r.setConclusion(rs.getString("conclusion"));
                    r.setCreatedAt(rs.getTimestamp("Created_At"));
                    r.setDoctorName(rs.getString("Doctor_Name"));
                    r.setDoctorSpecialty(rs.getString("Doctor_Specialty"));
                    r.setAppointmentStatus(rs.getString("Appointment_Status"));
                    r.setCheckinTime(rs.getTimestamp("checkin_time"));
                    r.setPatientId(rs.getInt("Patient_ID"));
                    r.setPatientName(rs.getString("Patient_Name"));
                    r.setPatientPhone(rs.getString("Patient_Phone"));
                    r.setPatientDob(rs.getDate("Patient_DOB"));
                    r.setPatientAddress(rs.getString("Patient_Address"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * Lấy toàn bộ các chỉ định cận lâm sàng của một bệnh nhân
     */
    public List<ProcedureOrder> getOrdersByPatientId(int patientId) throws Exception {
        List<ProcedureOrder> list = new ArrayList<>();
        String sql = orderQuery() + "WHERE p.Patient_ID = ? ORDER BY po.Order_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    // ==========================================
    // SCREEN 36: PROCEDURE EXECUTION DETAIL SCREEN
    // ==========================================

    /**
     * Lấy chi tiết 1 order cụ thể kèm thông tin bệnh nhân, bác sĩ, chẩn đoán
     */
    public ProcedureOrder getOrderById(int orderId) throws Exception {
        String sql = orderQuery() + "WHERE po.Order_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Lấy To-do list (danh sách tất cả chỉ định cần thực hiện) của cùng 1 phiên khám (Record_ID)
     */
    public List<ProcedureOrder> getTodoListByRecordId(int recordId) throws Exception {
        List<ProcedureOrder> list = new ArrayList<>();
        String sql = orderQuery() + "WHERE po.Record_ID = ? ORDER BY po.Order_ID ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Lấy thông tin phiếu khám / bệnh án ban đầu (Examination report)
     */
    public MedicalRecord getMedicalRecordById(int recordId) throws Exception {
        String sql = "SELECT mr.Record_ID, mr.Appointment_ID, mr.Doctor_Employee_ID, mr.Clinical_Diagnosis, " +
                     "       mr.examination_result, mr.conclusion, mr.Created_At, " +
                     "       doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
                     "       a.Status AS Appointment_Status, a.checkin_time, " +
                     "       p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address " +
                     "FROM Medical_Record mr " +
                     "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "LEFT JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
                     "WHERE mr.Record_ID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MedicalRecord r = new MedicalRecord();
                    r.setRecordId(rs.getInt("Record_ID"));
                    r.setAppointmentId(rs.getInt("Appointment_ID"));
                    r.setDoctorEmployeeId(rs.getInt("Doctor_Employee_ID"));
                    r.setClinicalDiagnosis(rs.getString("Clinical_Diagnosis"));
                    r.setExaminationResult(rs.getString("examination_result"));
                    r.setConclusion(rs.getString("conclusion"));
                    r.setCreatedAt(rs.getTimestamp("Created_At"));
                    r.setDoctorName(rs.getString("Doctor_Name"));
                    r.setDoctorSpecialty(rs.getString("Doctor_Specialty"));
                    r.setAppointmentStatus(rs.getString("Appointment_Status"));
                    r.setCheckinTime(rs.getTimestamp("checkin_time"));
                    r.setPatientId(rs.getInt("Patient_ID"));
                    r.setPatientName(rs.getString("Patient_Name"));
                    r.setPatientPhone(rs.getString("Patient_Phone"));
                    r.setPatientDob(rs.getDate("Patient_DOB"));
                    r.setPatientAddress(rs.getString("Patient_Address"));
                    return r;
                }
            }
        }
        return null;
    }

    /**
     * Cập nhật trạng thái của thủ thuật (Pending -> Completed hoặc Cancelled) và gán KTV thực hiện
     */
    public boolean updateOrderStatus(int orderId, Integer specialistEmployeeId, String newStatus) throws Exception {
        String sql = "UPDATE po SET po.Status = ?, po.Specialist_Employee_ID = ? "
                + "FROM Procedure_Order po WHERE po.Order_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            if (specialistEmployeeId != null && specialistEmployeeId > 0) {
                ps.setInt(2, specialistEmployeeId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Keep specialist findings on the order so the doctor's clinical record remains intact. */
    public boolean saveResults(int orderId, Integer specialistEmployeeId, String examinationResult,
                               String conclusion, String status) throws Exception {
        String sql = "UPDATE po SET Result_Text = ?, Result_Conclusion = ?, " +
                "Status = ?, Specialist_Employee_ID = ?, Completed_At = CASE WHEN ? = 'Completed' " +
                "THEN COALESCE(Completed_At, SYSDATETIME()) ELSE Completed_At END " +
                "FROM Procedure_Order po " +
                "WHERE po.Order_ID = ? AND po.Status <> 'Cancelled' " +
                "AND (po.Status <> 'Completed' OR ? = 'Completed')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, examinationResult);
            ps.setNString(2, conclusion);
            ps.setString(3, status);
            if (specialistEmployeeId != null && specialistEmployeeId > 0) ps.setInt(4, specialistEmployeeId);
            else ps.setNull(4, Types.INTEGER);
            ps.setString(5, status);
            ps.setInt(6, orderId);
            ps.setString(7, status);
            if (ps.executeUpdate() != 1) {
                throw new SQLException("Procedure order is unavailable for saving results");
            }
            return true;
        }
    }

    /**
     * Cập nhật biên bản thủ thuật vào Medical_Record.examination_result mà không ghi đè conclusion của Bác sĩ
     */
    public boolean updateMedicalRecordExaminationResult(int recordId, String examinationResult) throws Exception {
        String sql = "UPDATE Medical_Record SET examination_result = ? WHERE Record_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examinationResult);
            ps.setInt(2, recordId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Thêm chỉ định dịch vụ mới (hữu ích cho Bác sĩ khi khám hoặc để test dữ liệu)
     */
    public int createProcedureOrder(int recordId, int serviceId, Integer specialistEmployeeId, String status) throws Exception {
        String sql = "INSERT INTO Procedure_Order (Record_ID, Service_ID, Specialist_Employee_ID, Status, Actual_Price) " +
                     "SELECT ?, sc.Service_ID, ?, ?, sc.Price FROM Service_Catalog sc WHERE sc.Service_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, recordId);
            if (specialistEmployeeId != null && specialistEmployeeId > 0) {
                ps.setInt(2, specialistEmployeeId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, (status != null && !status.isEmpty()) ? status : "Pending");
            ps.setInt(4, serviceId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    // ==========================================
    // HELPER MAPPING
    // ==========================================

    private ProcedureOrder mapRow(ResultSet rs) throws SQLException {
        ProcedureOrder po = new ProcedureOrder();
        po.setOrderId(rs.getInt("Order_ID"));
        
        int specId = rs.getInt("Specialist_Employee_ID");
        if (!rs.wasNull()) {
            po.setSpecialistId(specId);
        } else {
            po.setSpecialistId(null);
        }

        po.setRecordId(rs.getInt("Record_ID"));
        po.setServiceId(rs.getInt("Service_ID"));
        po.setStatus(rs.getString("Status"));
        po.setReferralNotes(rs.getString("Referral_Notes"));
        po.setRequesterName(rs.getString("Requester_Name"));
        po.setServiceCode(rs.getString("Service_Code"));
        po.setPaymentStatus(rs.getString("Payment_Status"));

        po.setServiceName(rs.getString("Service_Name"));
        po.setServicePrice(rs.getDouble("Service_Price"));

        po.setSpecialistName(rs.getString("Specialist_Name"));
        po.setSpecialistPhone(rs.getString("Specialist_Phone"));
        po.setRoomName(rs.getString("Room_Name"));

        po.setAppointmentId(rs.getInt("Appointment_ID"));
        po.setDoctorId(rs.getInt("Doctor_Employee_ID"));
        po.setDoctorName(rs.getString("Doctor_Name"));
        po.setClinicalDiagnosis(rs.getString("Clinical_Diagnosis"));
        po.setExaminationResult(rs.getString("examination_result"));
        po.setConclusion(rs.getString("conclusion"));
        po.setRecordCreatedAt(rs.getTimestamp("Record_Created_At"));

        po.setPatientId(rs.getInt("Patient_ID"));
        po.setPatientName(rs.getString("Patient_Name"));
        po.setPatientPhone(rs.getString("Patient_Phone"));
        po.setPatientDob(rs.getDate("Patient_DOB"));
        po.setPatientAddress(rs.getString("Patient_Address"));

        return po;
    }
}
