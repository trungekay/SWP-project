package com.visioncare.model;
public class ScheduleDayDTO {
    private String dayName;
    private String dateStr;
    private String fullDate;
    private boolean isToday;
    private boolean isPast;
    private int totalSlotsCount;
    public ScheduleDayDTO() {
    }
    public ScheduleDayDTO(String dayName, String dateStr, String fullDate, boolean isToday) {
        this.dayName = dayName;
        this.dateStr = dateStr;
        this.fullDate = fullDate;
        this.isToday = isToday;
        this.isPast = false;
        this.totalSlotsCount = 0;
    }
    public ScheduleDayDTO(String dayName, String dateStr, String fullDate, boolean isToday, boolean isPast) {
        this.dayName = dayName;
        this.dateStr = dateStr;
        this.fullDate = fullDate;
        this.isToday = isToday;
        this.isPast = isPast;
        this.totalSlotsCount = 0;
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
    public String getDayDate() {
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
    public boolean isPast() {
        return isPast;
    }
    public boolean getIsPast() {
        return isPast;
    }
    public boolean getPast() {
        return isPast;
    }
    public void setPast(boolean past) {
        isPast = past;
    }
    public void setIsPast(boolean past) {
        isPast = past;
    }
    public int getTotalSlotsCount() {
        return totalSlotsCount;
    }
    public void setTotalSlotsCount(int totalSlotsCount) {
        this.totalSlotsCount = totalSlotsCount;
    }
}
