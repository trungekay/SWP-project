package com.visioncare.model;

/**
 * DTO bieu dien mot khung gio (Slot 30 phut) tren bang lich lam viec.
 */
public class ScheduleSlotDTO {
    private String id;
    private String timeRange;
    private String session;

    public ScheduleSlotDTO() {
    }

    public ScheduleSlotDTO(String id, String timeRange, String session) {
        this.id = id;
        this.timeRange = timeRange;
        this.session = session;
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
}
