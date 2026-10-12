package com.visioncare.dao;

import com.visioncare.model.MedicalRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MedicalRecordDAO {

    private static final String BASE_SELECT_RECORD = 
        "SELECT mr.Record_ID, mr.Appointment_ID, mr.Doctor_Employee_ID, " +
        "       mr.Clinical_Diagnosis, mr.examination_result, mr.conclusion, mr.Created_At, " +
        "       doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, " +
        "       a.Status AS Appointment_Status, a.checkin_time, " +
        "       p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address " +
        "FROM Medical_Record mr " +
        "JOIN Appointment a ON mr.Appointment_ID = a.Appointment_ID " +
        "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
        "JOIN Employee_Profile doc ON mr.Doctor_Employee_ID = doc.Employee_ID ";

    public MedicalRecord getById(int recordId) throws Exception {
        String sql = BASE_SELECT_RECORD + "WHERE mr.Record_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public MedicalRecord getByAppointmentId(int appointmentId) throws Exception {
        String sql = BASE_SELECT_RECORD + "WHERE mr.Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<MedicalRecord> getByDoctorId(int doctorId) throws Exception {
        List<MedicalRecord> list = new ArrayList<>();
        String sql = BASE_SELECT_RECORD + "WHERE mr.Doctor_Employee_ID = ? ORDER BY mr.Created_At DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    public int createRecord(int appointmentId, int doctorEmployeeId, String clinicalDiagnosis) throws Exception {
        String sql = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorEmployeeId);
            ps.setString(3, clinicalDiagnosis);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public boolean updateExamination(int recordId, String clinicalDiagnosis, String examinationResult, String conclusion) throws Exception {
        String sql = "UPDATE Medical_Record SET Clinical_Diagnosis = ?, examination_result = ?, conclusion = ? WHERE Record_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clinicalDiagnosis);
            ps.setString(2, examinationResult);
            ps.setString(3, conclusion);
            ps.setInt(4, recordId);
            return ps.executeUpdate() > 0;
        }
    }

    private MedicalRecord mapRow(ResultSet rs) throws SQLException {
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
