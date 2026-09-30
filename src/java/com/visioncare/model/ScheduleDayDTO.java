package com.visioncare.model;

/**
 * DTO bieu dien mot ngay trong tuan tren bang lich lam viec.
 */
public class ScheduleDayDTO {
    private String dayName;
    private String dateStr;
    private String fullDate;
    private boolean isToday;

    public ScheduleDayDTO() {
    }

    public ScheduleDayDTO(String dayName, String dateStr, String fullDate, boolean isToday) {
        this.dayName = dayName;
        this.dateStr = dateStr;
        this.fullDate = fullDate;
        this.isToday = isToday;
    }

    public String getDayName() {
        return dayName;
    }

    public void setDayName(String dayName) {
        this.dayName = dayName;
    }

    public String getDateStr() {
        return dateStr;
    }

    public void setDateStr(String dateStr) {
        this.dateStr = dateStr;
    }

    public String getFullDate() {
        return fullDate;
    }

    public void setFullDate(String fullDate) {
        this.fullDate = fullDate;
    }

    public boolean isToday() {
        return isToday;
    }

    public boolean getIsToday() {
        return isToday;
    }

    public void setToday(boolean today) {
        isToday = today;
    }
}
