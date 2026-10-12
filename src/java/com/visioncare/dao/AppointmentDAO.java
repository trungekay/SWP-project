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
}
