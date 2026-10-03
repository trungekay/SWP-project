package com.visioncare.model;
import java.sql.Date;
public class TimeSlot {
    private int id;
    private int doctorId;
    private Date date;
    private String startTime;   
    private boolean booked;     
    public TimeSlot() {
    }
    public TimeSlot(int id, int doctorId, Date date, String startTime, boolean booked) {
        this.id = id;
        this.doctorId = doctorId;
        this.date = date;
        this.startTime = startTime;
        this.booked = booked;
    }
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getDoctorId() {
        return doctorId;
    }
    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }
    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }
    public String getStartTime() {
        return startTime;
    }
    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }
    public boolean isBooked() {
        return booked;
    }
    public void setBooked(boolean booked) {
        this.booked = booked;
    }
}
