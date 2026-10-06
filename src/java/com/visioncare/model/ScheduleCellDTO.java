package com.visioncare.model;
public class ScheduleCellDTO {
    private int scheduleId;
    private String workDate;          
    private String slot;              
    private String startTime;         
    private String endTime;           
    private String session;           
    private String status;            
    private String roomName;          
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
        return "On_Leave".equalsIgnoreCase(status);
    }
    public boolean isClosed() {
        return "Canceled".equalsIgnoreCase(status) || "Inactive".equalsIgnoreCase(status) || "Disabled".equalsIgnoreCase(status) || "Closed".equalsIgnoreCase(status);
    }
    public boolean isInactive() {
        return isClosed();
    }
    public boolean isOff() {
        return scheduleId <= 0 || "Off".equalsIgnoreCase(status);
    }
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
