package com.visioncare.dao;

import com.visioncare.model.Appointment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    public int createPendingAppointment(Appointment a, int serviceId, long fee) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            int patientId = getOrCreatePatient(conn, a);
            int scheduleId = a.getScheduleId();
            if (scheduleId <= 0) {
                scheduleId = getOrCreateSchedule(conn, a);
            }

            // Check if slot is already booked or taken
            String checkSlotSql = "SELECT ws.Status, " +
                                  "       (SELECT COUNT(*) FROM Appointment ap WHERE ap.Schedule_ID = ws.Schedule_ID AND ap.Status NOT IN ('Canceled', 'Rejected')) AS ActiveAppts " +
                                  "FROM Work_Schedule ws WHERE ws.Schedule_ID = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSlotSql)) {
                psCheck.setInt(1, scheduleId);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        String st = rsCheck.getString("Status");
                        int count = rsCheck.getInt("ActiveAppts");
                        if ("Booked".equalsIgnoreCase(st) || count > 0) {
                            conn.rollback();
                            return -1; // Slot already booked
                        }
                    }
                }
            }

            // Insert Appointment as Pending
            String sqlAppt = "INSERT INTO Appointment (Patient_ID, Schedule_ID, Status, created_at) VALUES (?, ?, 'Pending', SYSUTCDATETIME())";
            int appointmentId = -1;
            try (PreparedStatement psAppt = conn.prepareStatement(sqlAppt, Statement.RETURN_GENERATED_KEYS)) {
                psAppt.setInt(1, patientId);
                psAppt.setInt(2, scheduleId);
                psAppt.executeUpdate();
                try (ResultSet keys = psAppt.getGeneratedKeys()) {
                    if (keys.next()) {
                        appointmentId = keys.getInt(1);
                    }
                }
            }

            if (appointmentId > 0) {
                // Insert Master_Invoice as Pending_Deposit
                long totalFee = fee > 0 ? fee : 200000;
                String sqlInvoice = "INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At) " +
                                    "VALUES (?, ?, 0, ?, 'Pending_Deposit', SYSUTCDATETIME())";
                try (PreparedStatement psInv = conn.prepareStatement(sqlInvoice)) {
                    psInv.setInt(1, appointmentId);
                    psInv.setLong(2, totalFee);
                    psInv.setLong(3, totalFee);
                    psInv.executeUpdate();
                }

                // Insert Medical_Record with clinical diagnosis or selected service info
                String diag = "";
                if (a.getServiceName() != null && !a.getServiceName().isEmpty()) {
                    diag = "Dịch vụ/Bệnh lý: " + a.getServiceName();
                }
                if (a.getReason() != null && !a.getReason().trim().isEmpty()) {
                    diag += (diag.isEmpty() ? "" : " | ") + "Lý do khám: " + a.getReason().trim();
                }
                if (!diag.isEmpty()) {
                    String sqlRecord = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At) VALUES (?, ?, ?, SYSUTCDATETIME())";
                    try (PreparedStatement psRec = conn.prepareStatement(sqlRecord)) {
                        psRec.setInt(1, appointmentId);
                        psRec.setInt(2, a.getDoctorId());
                        psRec.setString(3, diag);
                        psRec.executeUpdate();
                    }
                }
            }

            conn.commit();
            return appointmentId;
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean confirmPayment(int appointmentId) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Get Master_Invoice
            int invoiceId = -1;
            long totalAmount = 200000;
            String sqlFindInv = "SELECT Invoice_ID, Total_Amount FROM Master_Invoice WHERE Appointment_ID = ?";
            try (PreparedStatement psInv = conn.prepareStatement(sqlFindInv)) {
                psInv.setInt(1, appointmentId);
                try (ResultSet rs = psInv.executeQuery()) {
                    if (rs.next()) {
                        invoiceId = rs.getInt("Invoice_ID");
                        totalAmount = rs.getLong("Total_Amount");
                    }
                }
            }

            if (invoiceId <= 0) {
                // If invoice didn't exist yet, create it
                String sqlInsInv = "INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Deposit_Amount, Balance_Due, Status, Create_At, Close_At) " +
                                   "VALUES (?, 200000, 200000, 0, 'Paid', SYSUTCDATETIME(), SYSUTCDATETIME())";
                try (PreparedStatement psIns = conn.prepareStatement(sqlInsInv, Statement.RETURN_GENERATED_KEYS)) {
                    psIns.setInt(1, appointmentId);
                    psIns.executeUpdate();
                    try (ResultSet keys = psIns.getGeneratedKeys()) {
                        if (keys.next()) invoiceId = keys.getInt(1);
                    }
                }
            } else {
                // Update Invoice to Paid
                String sqlUpdInv = "UPDATE Master_Invoice SET Deposit_Amount = Total_Amount, Balance_Due = 0, Status = 'Paid', Close_At = SYSUTCDATETIME() WHERE Invoice_ID = ?";
                try (PreparedStatement psUpd = conn.prepareStatement(sqlUpdInv)) {
                    psUpd.setInt(1, invoiceId);
                    psUpd.executeUpdate();
                }
            }

            // 2. Insert Payment_Transaction
            String sqlTrans = "INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Trans_Date, Payment_Gateway) " +
                              "VALUES (?, ?, 'Success', SYSUTCDATETIME(), 'VietQR_Banking')";
            try (PreparedStatement psTrans = conn.prepareStatement(sqlTrans)) {
                psTrans.setInt(1, invoiceId);
                psTrans.setLong(2, totalAmount);
                psTrans.executeUpdate();
            }

            // 3. Update Appointment status to Confirmed
            String sqlAppt = "UPDATE Appointment SET Status = 'Confirmed' WHERE Appointment_ID = ?";
            try (PreparedStatement psAppt = conn.prepareStatement(sqlAppt)) {
                psAppt.setInt(1, appointmentId);
                psAppt.executeUpdate();
            }

            // 4. Update Work_Schedule status to Booked
            String sqlSched = "UPDATE Work_Schedule SET Status = 'Booked' WHERE Schedule_ID = (SELECT Schedule_ID FROM Appointment WHERE Appointment_ID = ?)";
            try (PreparedStatement psSched = conn.prepareStatement(sqlSched)) {
                psSched.setInt(1, appointmentId);
                psSched.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public Appointment getAppointmentDetailById(int appointmentId) throws Exception {
        String sql = "SELECT a.Appointment_ID, a.Status AS Appt_Status, a.Patient_ID, a.Schedule_ID, a.created_at, " +
                     "       p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB, p.Account_ID, " +
                     "       ws.Work_Date, ws.Start_Time, ws.End_Time, ws.Slot, " +
                     "       e.Employee_ID, e.Full_Name AS Doctor_Name, e.Specialty, " +
                     "       mr.Clinical_Diagnosis, " +
                     "       mi.Invoice_ID, mi.Total_Amount, mi.Deposit_Amount, mi.Status AS Invoice_Status " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID " +
                     "LEFT JOIN Medical_Record mr ON a.Appointment_ID = mr.Appointment_ID " +
                     "LEFT JOIN Master_Invoice mi ON a.Appointment_ID = mi.Appointment_ID " +
                     "WHERE a.Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Appointment appt = new Appointment();
                    appt.setId(rs.getInt("Appointment_ID"));
                    appt.setStatus(rs.getString("Appt_Status"));
                    appt.setPatientName(rs.getString("Patient_Name"));
                    appt.setPhone(rs.getString("Patient_Phone"));
                    appt.setDob(rs.getDate("DOB"));
                    appt.setDoctorId(rs.getInt("Employee_ID"));
                    appt.setDoctorName(rs.getString("Doctor_Name"));
                    appt.setDepartment(rs.getString("Specialty"));
                    appt.setAppointmentDate(rs.getDate("Work_Date"));
                    Time st = rs.getTime("Start_Time");
                    appt.setTimeSlot(st != null ? st.toString().substring(0, 5) : "");
                    appt.setSlotName(rs.getString("Slot"));
                    appt.setScheduleId(rs.getInt("Schedule_ID"));
                    appt.setReason(rs.getString("Clinical_Diagnosis"));
                    appt.setInvoiceId(rs.getInt("Invoice_ID"));
                    appt.setFee(rs.getLong("Total_Amount"));
                    appt.setInvoiceStatus(rs.getString("Invoice_Status"));
                    try {
                        appt.setUserId(rs.getInt("Account_ID"));
                    } catch (Exception ignored) {}
                    return appt;
                }
            }
        }
        return null;
    }

    public int create(Appointment a) throws Exception {
        return createPendingAppointment(a, a.getServiceId(), a.getFee() > 0 ? a.getFee() : 200000);
    }

    private int getOrCreatePatient(Connection conn, Appointment a) throws SQLException {
        // Search by phone first
        String sqlFind = "SELECT Patient_ID, Account_ID FROM Patient WHERE Phone = ?";
        try (PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
            psFind.setString(1, a.getPhone());
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    int pId = rs.getInt("Patient_ID");
                    int accId = rs.getInt("Account_ID");
                    // If user is logged in but patient record didn't have Account_ID, link it
                    if (accId <= 0 && a.getUserId() > 0) {
                        String sqlLink = "UPDATE Patient SET Account_ID = ? WHERE Patient_ID = ?";
                        try (PreparedStatement psLink = conn.prepareStatement(sqlLink)) {
                            psLink.setInt(1, a.getUserId());
                            psLink.setInt(2, pId);
                            psLink.executeUpdate();
                        }
                    }
                    return pId;
                }
            }
        }

        // Also check if logged in user already has a Patient record by Account_ID
        if (a.getUserId() > 0) {
            String sqlFindAcc = "SELECT Patient_ID FROM Patient WHERE Account_ID = ?";
            try (PreparedStatement psAcc = conn.prepareStatement(sqlFindAcc)) {
                psAcc.setInt(1, a.getUserId());
                try (ResultSet rsAcc = psAcc.executeQuery()) {
                    if (rsAcc.next()) {
                        return rsAcc.getInt("Patient_ID");
                    }
                }
            }
        }

        String sqlInsert = "INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB) VALUES (?, ?, ?, ?)";
        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            if (a.getUserId() > 0) {
                psIns.setInt(1, a.getUserId());
            } else {
                psIns.setNull(1, Types.INTEGER);
            }
            psIns.setString(2, a.getPatientName());
            psIns.setString(3, a.getPhone());
            psIns.setDate(4, a.getDob());
            psIns.executeUpdate();
            try (ResultSet keys = psIns.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Cannot create patient");
    }

    private int getOrCreateSchedule(Connection conn, Appointment a) throws SQLException {
        String sqlFind = "SELECT Schedule_ID FROM Work_Schedule WHERE Doctor_Employee_ID = ? AND Work_Date = ? AND CAST(Start_Time AS VARCHAR(5)) = ?";
        try (PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
            psFind.setInt(1, a.getDoctorId());
            psFind.setDate(2, a.getAppointmentDate());
            psFind.setString(3, a.getTimeSlot());
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Schedule_ID");
                }
            }
        }
        String sqlInsert = "INSERT INTO Work_Schedule (Doctor_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Available')";
        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            psIns.setInt(1, a.getDoctorId());
            psIns.setDate(2, a.getAppointmentDate());
            String startTime = a.getTimeSlot().length() == 5 ? a.getTimeSlot() + ":00" : a.getTimeSlot();
            psIns.setString(3, startTime);
            String endTime = startTime.replace(":00:00", ":30:00").replace(":30:00", ":59:00");
            psIns.setString(4, endTime);
            psIns.setString(5, "Slot Khám");
            psIns.executeUpdate();
            try (ResultSet keys = psIns.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Cannot create schedule");
    }

    public List<Appointment> getByDoctorAndDate(int doctorId, Date date) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.Appointment_ID, a.Status, p.Full_Name, p.Phone, p.DOB, ws.Start_Time, ws.Doctor_Employee_ID, p.Account_ID " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? AND a.Status != 'Canceled' " +
                     "ORDER BY ws.Start_Time";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public List<Appointment> getByUserId(int userId) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.Appointment_ID, a.Status, p.Full_Name, p.Phone, p.DOB, ws.Start_Time, ws.Doctor_Employee_ID, p.Account_ID, ws.Work_Date, e.Full_Name AS Doctor_Name " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID " +
                     "WHERE p.Account_ID = ? ORDER BY ws.Work_Date DESC, ws.Start_Time";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appt = mapRow(rs);
                    appt.setAppointmentDate(rs.getDate("Work_Date"));
                    list.add(appt);
                }
            }
        }
        return list;
    }

    public boolean isSlotBooked(int doctorId, Date date, String timeSlot) throws Exception {
        String sql = "SELECT COUNT(*) FROM Appointment a " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? AND CAST(ws.Start_Time AS VARCHAR(5)) = ? AND a.Status NOT IN ('Canceled', 'Rejected')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            ps.setString(3, timeSlot != null && timeSlot.length() >= 5 ? timeSlot.substring(0, 5) : timeSlot);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getInt("Appointment_ID"));
        a.setPatientName(rs.getString("Full_Name"));
        a.setPhone(rs.getString("Phone"));
        a.setDob(rs.getDate("DOB"));
        a.setDoctorId(rs.getInt("Doctor_Employee_ID"));
        a.setTimeSlot(rs.getString("Start_Time"));
        a.setStatus(rs.getString("Status"));
        try {
            a.setUserId(rs.getInt("Account_ID"));
        } catch (SQLException e) {
            a.setUserId(0);
        }
        try {
            a.setDoctorName(rs.getString("Doctor_Name"));
        } catch (SQLException e) {
            // Field not present in this query
        }
        return a;
    }

    public List<Appointment> getStaffAppointments(Date date, String status, Integer doctorId, String keyword) throws Exception {
        List<Appointment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.Appointment_ID, a.Patient_ID, a.Schedule_ID, a.Staff_Employee_ID, a.Status, " +
            "CONVERT(VARCHAR(19), a.created_at, 120) AS Created_At_Str, " +
            "CONVERT(VARCHAR(19), a.checkin_time, 120) AS Checkin_Time_Str, " +
            "p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address, " +
            "ws.Work_Date, " +
            "CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
            "CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, " +
            "ws.Doctor_Employee_ID, " +
            "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
            "rm.Room_Name, " +
            "stf.Full_Name AS Staff_Name, " +
            "mr.Clinical_Diagnosis AS Medical_Notes " +
            "FROM Appointment a " +
            "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
            "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "LEFT JOIN Employee_Profile doc ON ws.Doctor_Employee_ID = doc.Employee_ID " +
            "LEFT JOIN Room rm ON doc.Room_ID = rm.Room_ID " +
            "LEFT JOIN Employee_Profile stf ON a.Staff_Employee_ID = stf.Employee_ID " +
            "LEFT JOIN Medical_Record mr ON a.Appointment_ID = mr.Appointment_ID " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (date != null) {
            sql.append(" AND ws.Work_Date = ?");
            params.add(date);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            if ("Pending".equalsIgnoreCase(status) || "not_checked_in".equalsIgnoreCase(status)) {
                sql.append(" AND a.checkin_time IS NULL AND a.Status NOT IN ('Canceled', 'Completed')");
            } else if ("CheckedIn".equalsIgnoreCase(status)) {
                sql.append(" AND a.checkin_time IS NOT NULL AND a.Status NOT IN ('Canceled')");
            } else {
                sql.append(" AND a.Status = ?");
                params.add(status.trim());
            }
        }
        if (doctorId != null && doctorId > 0) {
            sql.append(" AND ws.Doctor_Employee_ID = ?");
            params.add(doctorId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR CAST(a.Appointment_ID AS VARCHAR) LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        sql.append(" ORDER BY ws.Work_Date DESC, ws.Start_Time ASC, a.Appointment_ID DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Date) {
                    ps.setDate(i + 1, (Date) p);
                } else if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, p.toString());
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapStaffAppointment(rs));
                }
            }
        }
        return list;
    }

    public Appointment getAppointmentById(int appointmentId) throws Exception {
        String sql = "SELECT a.Appointment_ID, a.Patient_ID, a.Schedule_ID, a.Staff_Employee_ID, a.Status, " +
                     "CONVERT(VARCHAR(19), a.created_at, 120) AS Created_At_Str, " +
                     "CONVERT(VARCHAR(19), a.checkin_time, 120) AS Checkin_Time_Str, " +
                     "p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address, " +
                     "ws.Work_Date, " +
                     "CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
                     "CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, " +
                     "ws.Doctor_Employee_ID, " +
                     "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
                     "rm.Room_Name, " +
                     "stf.Full_Name AS Staff_Name, " +
                     "mr.Clinical_Diagnosis AS Medical_Notes " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile doc ON ws.Doctor_Employee_ID = doc.Employee_ID " +
                     "LEFT JOIN Room rm ON doc.Room_ID = rm.Room_ID " +
                     "LEFT JOIN Employee_Profile stf ON a.Staff_Employee_ID = stf.Employee_ID " +
                     "LEFT JOIN Medical_Record mr ON a.Appointment_ID = mr.Appointment_ID " +
                     "WHERE a.Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapStaffAppointment(rs);
                }
            }
        }
        return null;
    }

    public boolean checkInPatient(int appointmentId, int staffEmployeeId) throws Exception {
        Integer validStaffId = null;
        try (Connection conn = DBContext.getConnection()) {
            if (staffEmployeeId > 0) {
                String checkSql = "SELECT Employee_ID FROM Employee_Profile WHERE Employee_ID = ?";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, staffEmployeeId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            validStaffId = rs.getInt("Employee_ID");
                        }
                    }
                }
            }

            // Nếu staffEmployeeId không tồn tại trong Employee_Profile, tìm 1 Staff hợp lệ bất kỳ
            if (validStaffId == null) {
                String findStaffSql = "SELECT TOP 1 ep.Employee_ID FROM Employee_Profile ep " +
                                      "JOIN Account a ON ep.Account_ID = a.Account_ID " +
                                      "WHERE a.Role_ID = 5 ORDER BY ep.Employee_ID ASC";
                try (Statement st = conn.createStatement();
                     ResultSet rs = st.executeQuery(findStaffSql)) {
                    if (rs.next()) {
                        validStaffId = rs.getInt(1);
                    } else {
                        try (Statement stAny = conn.createStatement();
                             ResultSet rsAny = stAny.executeQuery("SELECT TOP 1 Employee_ID FROM Employee_Profile ORDER BY Employee_ID ASC")) {
                            if (rsAny.next()) {
                                validStaffId = rsAny.getInt(1);
                            }
                        }
                    }
                }
            }

            String sql = "UPDATE Appointment SET Status = 'Confirmed', checkin_time = SYSUTCDATETIME(), Staff_Employee_ID = ? WHERE Appointment_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                if (validStaffId != null && validStaffId > 0) {
                    ps.setInt(1, validStaffId);
                } else {
                    ps.setNull(1, Types.INTEGER);
                }
                ps.setInt(2, appointmentId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public boolean updateAppointmentStatus(int appointmentId, String newStatus) throws Exception {
        String sql = "UPDATE Appointment SET Status = ? WHERE Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, appointmentId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean cancelAppointment(int appointmentId, String reason) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật trạng thái Appointment thành 'Canceled'
            String sqlAppt = "UPDATE Appointment SET Status = 'Canceled' WHERE Appointment_ID = ?";
            try (PreparedStatement psAppt = conn.prepareStatement(sqlAppt)) {
                psAppt.setInt(1, appointmentId);
                int affected = psAppt.executeUpdate();
                if (affected <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Trả lại trạng thái Work_Schedule thành 'Available' để giải phóng slot
            String sqlSched = "UPDATE Work_Schedule SET Status = 'Available' " +
                              "WHERE Schedule_ID = (SELECT Schedule_ID FROM Appointment WHERE Appointment_ID = ?)";
            try (PreparedStatement psSched = conn.prepareStatement(sqlSched)) {
                psSched.setInt(1, appointmentId);
                psSched.executeUpdate();
            }

            // 3. Hủy hóa đơn liên quan nếu chưa thanh toán hoàn tất
            String sqlInv = "UPDATE Master_Invoice SET Status = 'Canceled' WHERE Appointment_ID = ? AND Status IN ('Pending_Deposit', 'Unpaid')";
            try (PreparedStatement psInv = conn.prepareStatement(sqlInv)) {
                psInv.setInt(1, appointmentId);
                psInv.executeUpdate();
            }

            // 4. Ghi nhận lý do hủy vào Medical_Record
            String noteReason = (reason != null && !reason.trim().isEmpty())
                    ? reason.trim()
                    : "Bệnh nhân báo bận, yêu cầu hủy/đổi lịch";

            String checkSql = "SELECT Record_ID FROM Medical_Record WHERE Appointment_ID = ?";
            boolean exists = false;
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, appointmentId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                String sqlUpdateMR = "UPDATE Medical_Record SET conclusion = ? WHERE Appointment_ID = ?";
                try (PreparedStatement psUpMR = conn.prepareStatement(sqlUpdateMR)) {
                    psUpMR.setString(1, "Lễ tân hủy lịch: " + noteReason);
                    psUpMR.setInt(2, appointmentId);
                    psUpMR.executeUpdate();
                }
            } else {
                int docId = 0;
                String sqlDoc = "SELECT ws.Doctor_Employee_ID FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE a.Appointment_ID = ?";
                try (PreparedStatement psDoc = conn.prepareStatement(sqlDoc)) {
                    psDoc.setInt(1, appointmentId);
                    try (ResultSet rsDoc = psDoc.executeQuery()) {
                        if (rsDoc.next()) {
                            docId = rsDoc.getInt(1);
                        }
                    }
                }
                if (docId > 0) {
                    String sqlInsMR = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, conclusion, Created_At) VALUES (?, ?, ?, SYSUTCDATETIME())";
                    try (PreparedStatement psInsMR = conn.prepareStatement(sqlInsMR)) {
                        psInsMR.setInt(1, appointmentId);
                        psInsMR.setInt(2, docId);
                        psInsMR.setString(3, "Lễ tân hủy lịch: " + noteReason);
                        psInsMR.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    /**
     * Tự động quét và cập nhật trạng thái các ca hẹn quá hạn thành 'Canceled':
     * - Các ca hẹn ở trạng thái Pending (chưa check-in)
     * - Ngày khám trong quá khứ (Work_Date < ngày hiện tại)
     * - Hoặc ngày khám là hôm nay nhưng đã quá giờ kết thúc ca (End_Time <= giờ hiện tại)
     */
    public int autoCancelExpiredAppointments() {
        int updatedCount = 0;
        String sql = "UPDATE Appointment " +
                     "SET Status = 'Canceled' " +
                     "WHERE Status = 'Pending' " +
                     "  AND checkin_time IS NULL " +
                     "  AND Schedule_ID IN (" +
                     "      SELECT ws.Schedule_ID FROM Work_Schedule ws " +
                     "      WHERE ws.Work_Date < CAST(GETDATE() AS DATE) " +
                     "         OR (ws.Work_Date = CAST(GETDATE() AS DATE) AND CAST(ws.End_Time AS TIME) <= CAST(GETDATE() AS TIME))" +
                     "  )";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            updatedCount = ps.executeUpdate();

            if (updatedCount > 0) {
                String noteSql = "UPDATE mr " +
                                 "SET mr.conclusion = N'Hệ thống tự động hủy: Quá giờ hẹn nhưng bệnh nhân không đến check-in' " +
                                 "FROM Medical_Record mr " +
                                 "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
                                 "WHERE a.Status = 'Canceled' AND a.checkin_time IS NULL " +
                                 "  AND (mr.conclusion IS NULL OR mr.conclusion = '')";
                try (PreparedStatement psNote = conn.prepareStatement(noteSql)) {
                    psNote.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return updatedCount;
    }

    public boolean saveMedicalNotes(int appointmentId, int doctorId, String notes) throws Exception {
        String checkSql = "SELECT Record_ID FROM Medical_Record WHERE Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection()) {
            boolean exists = false;
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, appointmentId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    exists = rs.next();
                }
            }
            if (exists) {
                String updateSql = "UPDATE Medical_Record SET Clinical_Diagnosis = ? WHERE Appointment_ID = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateSql)) {
                    psUp.setString(1, notes);
                    psUp.setInt(2, appointmentId);
                    return psUp.executeUpdate() > 0;
                }
            } else {
                String insertSql = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis, Created_At) VALUES (?, ?, ?, SYSUTCDATETIME())";
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    psIns.setInt(1, appointmentId);
                    psIns.setInt(2, doctorId);
                    psIns.setString(3, notes);
                    return psIns.executeUpdate() > 0;
                }
            }
        }
    }

    public List<Appointment> getWaitingList(Date date, Integer doctorId) throws Exception {
        return getWaitingList(date, doctorId, null);
    }

    public List<Appointment> getWaitingList(Date date, Integer doctorId, Integer roomId) throws Exception {
        return getWaitingList(date, doctorId, roomId, null);
    }

    public List<Appointment> getWaitingList(Date date, Integer doctorId, Integer roomId, String keyword) throws Exception {
        return getWaitingList(date, "all", doctorId, roomId, keyword);
    }

    public List<Appointment> getWaitingList(Date date, String status, Integer doctorId, Integer roomId, String keyword) throws Exception {
        List<Appointment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.Appointment_ID, a.Patient_ID, a.Schedule_ID, a.Staff_Employee_ID, a.Status, " +
            "CONVERT(VARCHAR(19), a.created_at, 120) AS Created_At_Str, " +
            "CONVERT(VARCHAR(19), a.checkin_time, 120) AS Checkin_Time_Str, " +
            "p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address, " +
            "ws.Work_Date, " +
            "CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
            "CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, " +
            "ws.Doctor_Employee_ID, " +
            "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
            "rm.Room_Name, " +
            "stf.Full_Name AS Staff_Name, " +
            "mr.Clinical_Diagnosis AS Medical_Notes " +
            "FROM Appointment a " +
            "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
            "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "LEFT JOIN Employee_Profile doc ON ws.Doctor_Employee_ID = doc.Employee_ID " +
            "LEFT JOIN Room rm ON doc.Room_ID = rm.Room_ID " +
            "LEFT JOIN Employee_Profile stf ON a.Staff_Employee_ID = stf.Employee_ID " +
            "LEFT JOIN Medical_Record mr ON a.Appointment_ID = mr.Appointment_ID " +
            "WHERE a.checkin_time IS NOT NULL "
        );

        List<Object> params = new ArrayList<>();
        if (date != null) {
            sql.append(" AND ws.Work_Date = ?");
            params.add(date);
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status) && !"all_queue".equalsIgnoreCase(status)) {
            if ("all_day".equalsIgnoreCase(status)) {
                sql.append(" AND a.Status IN ('Confirmed', 'In_Progress', 'Completed')");
            } else {
                sql.append(" AND a.Status = ?");
                params.add(status.trim());
            }
        } else {
            sql.append(" AND a.Status IN ('Confirmed', 'In_Progress')");
        }

        if (doctorId != null && doctorId > 0) {
            sql.append(" AND ws.Doctor_Employee_ID = ?");
            params.add(doctorId);
        }

        if (roomId != null && roomId > 0) {
            sql.append(" AND doc.Room_ID = ?");
            params.add(roomId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String cleanKw = keyword.trim();
            if (cleanKw.toUpperCase().startsWith("#APPT-")) {
                cleanKw = cleanKw.substring(6);
            } else if (cleanKw.toUpperCase().startsWith("APPT-")) {
                cleanKw = cleanKw.substring(5);
            } else if (cleanKw.startsWith("#")) {
                cleanKw = cleanKw.substring(1);
            }
            sql.append(" AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR CAST(a.Appointment_ID AS VARCHAR) LIKE ?)");
            params.add("%" + cleanKw + "%");
            params.add("%" + cleanKw + "%");
            params.add("%" + cleanKw + "%");
        }

        sql.append(" ORDER BY CASE WHEN a.Status = 'In_Progress' THEN 0 WHEN a.Status = 'Confirmed' THEN 1 ELSE 2 END, a.checkin_time ASC, ws.Start_Time ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Date) {
                    ps.setDate(i + 1, (Date) p);
                } else if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, p.toString());
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                int qNum = 1;
                while (rs.next()) {
                    Appointment appt = mapStaffAppointment(rs);
                    appt.setQueueNumber(qNum++);
                    list.add(appt);
                }
            }
        }
        return list;
    }

    private Appointment mapStaffAppointment(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getInt("Appointment_ID"));
        a.setPatientId(rs.getInt("Patient_ID"));
        a.setPatientName(rs.getString("Patient_Name"));
        a.setPhone(rs.getString("Patient_Phone"));
        a.setDob(rs.getDate("Patient_DOB"));
        a.setAddress(rs.getString("Patient_Address"));
        a.setAppointmentDate(rs.getDate("Work_Date"));
        a.setTimeSlot(rs.getString("Start_Time_Str"));
        a.setEndTime(rs.getString("End_Time_Str"));
        a.setDoctorId(rs.getInt("Doctor_Employee_ID"));
        a.setDoctorName(rs.getString("Doctor_Name"));
        a.setDepartment(rs.getString("Doctor_Specialty"));
        a.setRoomName(rs.getString("Room_Name"));
        a.setStatus(rs.getString("Status"));
        a.setStaffEmployeeId(rs.getInt("Staff_Employee_ID"));
        a.setStaffName(rs.getString("Staff_Name"));
        a.setCheckinTime(rs.getString("Checkin_Time_Str"));
        a.setCreatedAt(rs.getString("Created_At_Str"));
        a.setMedicalNotes(rs.getString("Medical_Notes"));
        return a;
    }

    public boolean skipQueue(int appointmentId) throws Exception {
        String sql = "UPDATE Appointment SET Status = 'Confirmed', checkin_time = SYSUTCDATETIME() WHERE Appointment_ID = ? AND Status = 'Confirmed'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            return ps.executeUpdate() > 0;
        }
    }
}

