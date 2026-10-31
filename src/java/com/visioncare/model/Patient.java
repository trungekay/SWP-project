package com.visioncare.model;

import java.sql.Date;
import java.time.LocalDate;
import java.time.Period;

public class Patient {
    private int patientId;
    private Integer accountId;
    private String fullName;
    private String phone;
    private Date dob;
    private String address;

    public Patient() {
    }

    public Patient(int patientId, Integer accountId, String fullName, String phone, Date dob, String address) {
        this.patientId = patientId;
        this.accountId = accountId;
        this.fullName = fullName;
        this.phone = phone;
        this.dob = dob;
        this.address = address;
    }

    public int getPatientId() {
        return patientId;
    }

    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public void setAccountId(Integer accountId) {
        this.accountId = accountId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    private String email;
    private int totalAppointments;
    private String latestAppointmentDate;

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getTotalAppointments() {
        return totalAppointments;
    }

    public void setTotalAppointments(int totalAppointments) {
        this.totalAppointments = totalAppointments;
    }

    public String getLatestAppointmentDate() {
        return latestAppointmentDate;
    }

    public void setLatestAppointmentDate(String latestAppointmentDate) {
        this.latestAppointmentDate = latestAppointmentDate;
    }

    public boolean isHasAccount() {
        return accountId != null && accountId > 0;
    }

    public String getFormattedId() {
        return String.format("#PAT-%04d", patientId);
    }

    public int getAge() {
        if (dob == null) {
            return 0;
        }
        try {
            LocalDate birthDate = dob.toLocalDate();
            return Period.between(birthDate, LocalDate.now()).getYears();
        } catch (Exception e) {
            return 0;
        }
    }
}
