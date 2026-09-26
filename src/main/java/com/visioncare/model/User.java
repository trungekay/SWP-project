package com.visioncare.model;

/**
 * Entity đại diện cho người dùng hệ thống (bệnh nhân, admin, bác sĩ).
 */
public class User {

    private int id;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String role;    // patient, doctor, admin

    public User() {
    }

    public User(int id, String fullName, String email, String password,
                String phone, String role) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
    }

    // ===== Getters & Setters =====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
