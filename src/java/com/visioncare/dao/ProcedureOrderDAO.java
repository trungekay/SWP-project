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

    private static final String BASE_SELECT_ORDER = 
        "SELECT " +
        "    po.Order_ID, " +
        "    po.Specialist_Employee_ID, " +
        "    po.Record_ID, " +
        "    po.Service_ID, " +
        "    po.Status, " +
        "    s.Service_Name, " +
        "    po.Actual_Price AS Service_Price, " +
        "    spec.Full_Name AS Specialist_Name, " +
        "    spec.Phone AS Specialist_Phone, " +
        "    r.Room_Name, " +
        "    mr.Appointment_ID, " +
        "    mr.Doctor_Employee_ID, " +
        "    mr.Clinical_Diagnosis, " +
        "    mr.examination_result, " +
        "    mr.conclusion, " +
        "    mr.Created_At AS Record_Created_At, " +
        "    doc.Full_Name AS Doctor_Name, " +
        "    p.Patient_ID, " +
        "    p.Full_Name AS Patient_Name, " +
        "    p.Phone AS Patient_Phone, " +
        "    p.DOB AS Patient_DOB, " +
        "    p.Address AS Patient_Address " +
        "FROM Procedure_Order po " +
        "JOIN Service_Catalog s ON po.Service_ID = s.Service_ID " +
        "JOIN Medical_Record mr ON po.Record_ID = mr.Record_ID " +
        "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
        "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
        "JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
        "LEFT JOIN Employee_Profile spec ON po.Specialist_Employee_ID = spec.Employee_ID " +
        "LEFT JOIN Room r ON spec.Room_ID = r.Room_ID ";

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
        StringBuilder sql = new StringBuilder(BASE_SELECT_ORDER);
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
            sql.append("AND CAST(mr.Created_At AS DATE) = ? ");
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

        StringBuilder sql = new StringBuilder("SELECT po.Status, COUNT(*) AS Total FROM Procedure_Order po ");
        List<Object> params = new ArrayList<>();
        if (specialistId != null && specialistId > 0) {
            sql.append("WHERE (po.Specialist_Employee_ID = ? OR po.Specialist_Employee_ID IS NULL) ");
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
                     "JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
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
        String sql = BASE_SELECT_ORDER + "WHERE p.Patient_ID = ? ORDER BY po.Order_ID DESC";
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
        String sql = BASE_SELECT_ORDER + "WHERE po.Order_ID = ?";
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
        String sql = BASE_SELECT_ORDER + "WHERE po.Record_ID = ? ORDER BY po.Order_ID ASC";
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
                     "JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID " +
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
        String sql = "UPDATE Procedure_Order SET Status = ?, Specialist_Employee_ID = ? WHERE Order_ID = ?";
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

    /**
     * Cập nhật kết quả cận lâm sàng / ghi chú kết luận vào Medical_Record
     */
    public boolean updateMedicalRecordResults(int recordId, String examinationResult, String conclusion) throws Exception {
        String sql = "UPDATE Medical_Record SET examination_result = ?, conclusion = ? WHERE Record_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, examinationResult);
            ps.setString(2, conclusion);
            ps.setInt(3, recordId);
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
