package com.visioncare.model;

/**
 * DTO bieu dien mot tuy chon tuan trong dropdown filter (Tu ngay ... den ngay ...).
 */
public class WeekOptionDTO {
    private int offset;
    private String label;
    private String startDateStr;
    private String endDateStr;
    private boolean isCurrentWeek;

    public WeekOptionDTO() {
    }

    public WeekOptionDTO(int offset, String label, String startDateStr, String endDateStr, boolean isCurrentWeek) {
        this.offset = offset;
        this.label = label;
        this.startDateStr = startDateStr;
        this.endDateStr = endDateStr;
        this.isCurrentWeek = isCurrentWeek;
    }

    public int getOffset() {
        return offset;
    }

    public void setOffset(int offset) {
        this.offset = offset;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getStartDateStr() {
        return startDateStr;
    }

    public void setStartDateStr(String startDateStr) {
        this.startDateStr = startDateStr;
    }

    public String getEndDateStr() {
        return endDateStr;
    }

    public void setEndDateStr(String endDateStr) {
        this.endDateStr = endDateStr;
    }

    public boolean isCurrentWeek() {
        return isCurrentWeek;
    }

    public boolean getIsCurrentWeek() {
        return isCurrentWeek;
    }

    public void setCurrentWeek(boolean currentWeek) {
        isCurrentWeek = currentWeek;
    }
}
