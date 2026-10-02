package com.visioncare.model;

public class TimeSlotConfig {
    private String slotName;
    private String startTime;
    private String endTime;
    private String session;
    private String status;

    public TimeSlotConfig(String slotName, String startTime, String endTime, String session, String status) {
        this.slotName = slotName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.session = session;
        this.status = status;
    }

    public String getSlotName() { return slotName; }
    public String getStartTime() { return startTime; }
    public String getEndTime() { return endTime; }
    public String getSession() { return session; }
    public String getStatus() { return status; }
}
