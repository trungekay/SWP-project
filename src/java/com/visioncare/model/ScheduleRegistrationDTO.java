package com.visioncare.model;
public class ScheduleRegistrationDTO {
    private String workDate;      
    private String slot;          
    private String startTime;     
    private String endTime;       
    private String session;       
    public ScheduleRegistrationDTO() {
    }
    public ScheduleRegistrationDTO(String workDate, String slot, String startTime, String endTime, String session) {
        this.workDate = workDate;
        this.slot = slot;
        this.startTime = startTime;
        this.endTime = endTime;
        this.session = session;
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
}
