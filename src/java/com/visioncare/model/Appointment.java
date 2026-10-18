package com.visioncare.model;
import java.sql.Date;
public class Appointment {
    private int id;
    private String patientName;
    private String phone;
    private String email;
    private Date dob;
    private int doctorId;
    private Date appointmentDate;
    private String timeSlot;     
    private String department;  
    private String payment;       
    private String reason;         
    private String doctorName;
    private String status;        
    private int userId;           
    private int serviceId;
    private String serviceName;
    private long fee = 200000;
    private long totalAmount;
    private long balanceDue;
    private int scheduleId;
    private String slotName;
    private String invoiceStatus;
    private int invoiceId;
    private boolean hasRefundRequest;
    private int patientId;
    private String address;
    private int staffEmployeeId;
    private String staffName;
    private String checkinTime;
    private String roomName;
    private String medicalNotes;
    private String createdAt;
    private String endTime;
    private int queueNumber;

    public Appointment() {
    }

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getPatientName() {
        return patientName;
    }
    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }
    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public Date getDob() {
        return dob;
    }
    public void setDob(Date dob) {
        this.dob = dob;
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

    public Date getAppointmentDate() {
        return appointmentDate;
    }
    public void setAppointmentDate(Date appointmentDate) {
        this.appointmentDate = appointmentDate;
    }
    public String getTimeSlot() {
        return timeSlot;
    }
    public void setTimeSlot(String timeSlot) {
        this.timeSlot = timeSlot;
    }
    public String getDepartment() {
        return department;
    }
    public void setDepartment(String department) {
        this.department = department;
    }
    public String getPayment() {
        return payment;
    }
    public void setPayment(String payment) {
        this.payment = payment;
    }
    public String getReason() {
        return reason;
    }
    public void setReason(String reason) {
        this.reason = reason;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
    public int getServiceId() {
        return serviceId;
    }
    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }
    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public long getFee() {
        return fee;
    }
    public void setFee(long fee) {
        this.fee = fee;
    }

    public int getScheduleId() {
        return scheduleId;
    }
    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getSlotName() {
        return slotName;
    }
    public void setSlotName(String slotName) {
        this.slotName = slotName;
    }

    public String getInvoiceStatus() {
        return invoiceStatus;
    }
    public void setInvoiceStatus(String invoiceStatus) {
        this.invoiceStatus = invoiceStatus;
    }

    public int getInvoiceId() {
        return invoiceId;
    }
    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

    public int getPatientId() {
        return patientId;
    }
    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }
    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }
    public int getStaffEmployeeId() {
        return staffEmployeeId;
    }
    public void setStaffEmployeeId(int staffEmployeeId) {
        this.staffEmployeeId = staffEmployeeId;
    }
    public String getStaffName() {
        return staffName;
    }
    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }
    public String getCheckinTime() {
        return checkinTime;
    }
    public void setCheckinTime(String checkinTime) {
        this.checkinTime = checkinTime;
    }
    public String getRoomName() {
        return roomName;
    }
    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }
    public String getMedicalNotes() {
        return medicalNotes;
    }
    public void setMedicalNotes(String medicalNotes) {
        this.medicalNotes = medicalNotes;
    }
    public String getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }
    public String getEndTime() {
        return endTime;
    }
    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
    public int getQueueNumber() {
        return queueNumber;
    }
    public void setQueueNumber(int queueNumber) {
        this.queueNumber = queueNumber;
    }

    public long getTotalAmount() {
        return totalAmount;
    }
    public void setTotalAmount(long totalAmount) {
        this.totalAmount = totalAmount;
    }

    public long getBalanceDue() {
        return balanceDue;
    }
    public void setBalanceDue(long balanceDue) {
        this.balanceDue = balanceDue;
    }

    public boolean isHasRefundRequest() {
        return hasRefundRequest;
    }
    public void setHasRefundRequest(boolean hasRefundRequest) {
        this.hasRefundRequest = hasRefundRequest;
    }

    public boolean isPast() {
        if (appointmentDate == null) return false;
        Date today = Date.valueOf(java.time.LocalDate.now());
        return appointmentDate.before(today);
    }

    public boolean getIsPast() {
        return isPast();
    }
}
