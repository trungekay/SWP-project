package com.visioncare.dao;

import com.visioncare.model.Appointment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý truy vấn liên quan đến Lịch hẹn khám.
 */
public class AppointmentDAO {

    /**
     * Tạo lịch hẹn mới — trả về ID vừa tạo.
     */
    public int create(Appointment a) throws Exception {
        String sql = "INSERT INTO appointments "
                + "(patient_name, phone, email, dob, doctor_id, appointment_date, "
                + " time_slot, department, payment, reason, status, user_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, a.getPatientName());
            ps.setString(2, a.getPhone());
            ps.setString(3, a.getEmail());
            ps.setDate(4, a.getDob());
            ps.setInt(5, a.getDoctorId());
            ps.setDate(6, a.getAppointmentDate());
            ps.setString(7, a.getTimeSlot());
            ps.setString(8, a.getDepartment());
            ps.setString(9, a.getPayment());
            ps.setString(10, a.getReason());
            ps.setString(11, a.getStatus() != null ? a.getStatus() : "pending");
            ps.setInt(12, a.getUserId());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Lấy danh sách lịch hẹn của một bác sĩ trong một ngày.
     */
    public List<Appointment> getByDoctorAndDate(int doctorId, Date date) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE doctor_id = ? AND appointment_date = ? "
                + "AND status != 'cancelled' ORDER BY time_slot";
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

    /**
     * Lấy danh sách lịch hẹn của một user.
     */
    public List<Appointment> getByUserId(int userId) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT * FROM appointments WHERE user_id = ? ORDER BY appointment_date DESC, time_slot";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Kiểm tra khung giờ đã được đặt chưa.
     */
    public boolean isSlotBooked(int doctorId, Date date, String timeSlot) throws Exception {
        String sql = "SELECT COUNT(*) FROM appointments "
                + "WHERE doctor_id = ? AND appointment_date = ? AND time_slot = ? AND status != 'cancelled'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            ps.setString(3, timeSlot);
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
        a.setId(rs.getInt("id"));
        a.setPatientName(rs.getString("patient_name"));
        a.setPhone(rs.getString("phone"));
        a.setEmail(rs.getString("email"));
        a.setDob(rs.getDate("dob"));
        a.setDoctorId(rs.getInt("doctor_id"));
        a.setAppointmentDate(rs.getDate("appointment_date"));
        a.setTimeSlot(rs.getString("time_slot"));
        a.setDepartment(rs.getString("department"));
        a.setPayment(rs.getString("payment"));
        a.setReason(rs.getString("reason"));
        a.setStatus(rs.getString("status"));
        a.setUserId(rs.getInt("user_id"));
        return a;
    }
}
