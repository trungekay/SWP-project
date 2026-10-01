package com.visioncare.model;

/**
 * DTO bieu dien du lieu cua mot o Slot tren ma tran lich lam viec tu Database.
 */
public class ScheduleCellDTO {
    private int scheduleId;
    private String workDate;          // yyyy-MM-dd
    private String slot;              // Slot 1, Slot 2...
    private String startTime;         // 08:00:00
    private String endTime;           // 08:30:00
    private String session;           // Morning, Afternoon
    private String status;            // Available, Booked, On_Leave, Canceled, Off
    private String roomName;          // P.101

    // Thong tin benh nhan dat lich (neu co)
    private int appointmentId;
    private int patientId;
    private String patientName;
    private String patientPhone;
    private String appointmentStatus;

    public ScheduleCellDTO() {
        this.status = "Off";
    }

    public boolean isBooked() {
        return (appointmentId > 0 && !"Canceled".equalsIgnoreCase(appointmentStatus)) 
                || "Booked".equalsIgnoreCase(status);
    }

    public boolean isAvailable() {
        return "Available".equalsIgnoreCase(status) && !isBooked();
    }

    public boolean isOnLeave() {
        return "On_Leave".equalsIgnoreCase(status) || "Canceled".equalsIgnoreCase(status);
    }

    public boolean isOff() {
        return scheduleId <= 0 || "Off".equalsIgnoreCase(status);
    }

    // ===== Getters & Setters =====

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public String getWorkDate() {
        return workDate;
    }

    public void setWorkDate(String workDate) {
        this.workDate = workDate;
    }

    public String getSlot() {
        return slot;
    }

    public void setSlot(String slot) {
        this.slot = slot;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getSession() {
        return session;
    }

    public void setSession(String session) {
        this.session = session;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getAppointmentStatus() {
        return appointmentStatus;
    }

    public void setAppointmentStatus(String appointmentStatus) {
        this.appointmentStatus = appointmentStatus;
    }
}
