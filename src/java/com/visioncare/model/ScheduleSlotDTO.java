package com.visioncare.model;

/**
 * DTO bieu dien mot khung gio (Slot 30 phut) tren bang lich lam viec.
 */
public class ScheduleSlotDTO {
    private String id;
    private String timeRange;
    private String session;
    private String startTime;
    private String endTime;

    public ScheduleSlotDTO() {
    }

    public ScheduleSlotDTO(String id, String timeRange, String session) {
        this.id = id;
        this.timeRange = timeRange;
        this.session = session;
        if (timeRange != null && timeRange.contains("-")) {
            String[] parts = timeRange.split("-");
            this.startTime = parts[0].trim();
            this.endTime = parts[1].trim();
        }
    }

    public ScheduleSlotDTO(String id, String timeRange, String session, String startTime, String endTime) {
        this.id = id;
        this.timeRange = timeRange;
        this.session = session;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTimeRange() {
        return timeRange;
    }

    public void setTimeRange(String timeRange) {
        this.timeRange = timeRange;
    }

    public String getSession() {
        return session;
    }

    public void setSession(String session) {
        this.session = session;
    }

    public String getStartTime() {
        if (startTime == null && timeRange != null && timeRange.contains("-")) {
            return timeRange.split("-")[0].trim();
        }
        return startTime != null ? startTime : "";
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        if (endTime == null && timeRange != null && timeRange.contains("-")) {
            return timeRange.split("-")[1].trim();
        }
        return endTime != null ? endTime : "";
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
}

