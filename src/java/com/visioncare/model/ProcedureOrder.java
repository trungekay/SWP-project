package com.visioncare.model;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.Period;

public class ProcedureOrder {
    // Columns from Procedure_Order
    private int orderId;
    private Integer specialistId; // Specialist_Employee_ID
    private int recordId;
    private int serviceId;
    private String status; // 'Pending', 'Completed', 'Cancelled'
    private String referralNotes;
    private String serviceCode;
    private String paymentStatus;

    // Service info
    private String serviceName;
    private double servicePrice;

    // Specialist info
    private String specialistName;
    private String specialistPhone;
    private String roomName;

    // Medical Record & Doctor info
    private int appointmentId;
    private int doctorId;
    private String doctorName;
    private String clinicalDiagnosis;
    private String examinationResult;
    private String conclusion;
    private Timestamp recordCreatedAt;

    // Patient info
    private int patientId;
    private String patientName;
    private String patientPhone;
    private Date patientDob;
    private String patientAddress;

    public ProcedureOrder() {
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public Integer getSpecialistId() {
        return specialistId;
    }

    public void setSpecialistId(Integer specialistId) {
        this.specialistId = specialistId;
    }

    public int getRecordId() {
        return recordId;
    }

    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getReferralNotes() { return referralNotes; }
    public void setReferralNotes(String referralNotes) { this.referralNotes = referralNotes; }
    public String getServiceCode() { return serviceCode; }
    public void setServiceCode(String serviceCode) { this.serviceCode = serviceCode; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public boolean isPaymentBlocked() {
        return serviceCode != null && serviceCode.startsWith("PT-") && referralNotes != null
                && ("Pending".equals(status) || "In_Progress".equals(status))
                && !"Paid".equals(paymentStatus);
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public double getServicePrice() {
        return servicePrice;
    }

    public void setServicePrice(double servicePrice) {
        this.servicePrice = servicePrice;
    }

    public String getSpecialistName() {
        return specialistName;
    }

    public void setSpecialistName(String specialistName) {
        this.specialistName = specialistName;
    }

    public String getSpecialistPhone() {
        return specialistPhone;
    }

    public void setSpecialistPhone(String specialistPhone) {
        this.specialistPhone = specialistPhone;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getClinicalDiagnosis() {
        return clinicalDiagnosis;
    }

    public void setClinicalDiagnosis(String clinicalDiagnosis) {
        this.clinicalDiagnosis = clinicalDiagnosis;
    }

    public String getExaminationResult() {
        return examinationResult;
    }

    public void setExaminationResult(String examinationResult) {
        this.examinationResult = examinationResult;
    }

    public String getConclusion() {
        return conclusion;
    }

    public void setConclusion(String conclusion) {
        this.conclusion = conclusion;
    }

    public Timestamp getRecordCreatedAt() {
        return recordCreatedAt;
    }

    public void setRecordCreatedAt(Timestamp recordCreatedAt) {
        this.recordCreatedAt = recordCreatedAt;
    }

    public int getPatientId() {
        return patientId;
    }

    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getPatientPhone() {
        return patientPhone;
    }

    public void setPatientPhone(String patientPhone) {
        this.patientPhone = patientPhone;
    }

    public Date getPatientDob() {
        return patientDob;
    }

    public void setPatientDob(Date patientDob) {
        this.patientDob = patientDob;
    }

    public String getPatientAddress() {
        return patientAddress;
    }

    public void setPatientAddress(String patientAddress) {
        this.patientAddress = patientAddress;
    }

    public int getPatientAge() {
        if (patientDob == null) {
            return 0;
        }
        try {
            LocalDate birthDate = patientDob.toLocalDate();
            return Period.between(birthDate, LocalDate.now()).getYears();
        } catch (Exception e) {
            return 0;
        }
    }

    public String getStatusVn() {
        if ("Pending".equalsIgnoreCase(status)) return "Chờ thực hiện";
        if ("Completed".equalsIgnoreCase(status)) return "Đã hoàn thành";
        if ("Cancelled".equalsIgnoreCase(status)) return "Đã hủy";
        return status != null ? status : "Chưa xác định";
    }

    public String getStatusBadgeClass() {
        if ("Pending".equalsIgnoreCase(status)) return "bg-warning text-dark";
        if ("Completed".equalsIgnoreCase(status)) return "bg-success text-white";
        if ("Cancelled".equalsIgnoreCase(status)) return "bg-danger text-white";
        return "bg-secondary text-white";
    }
}
