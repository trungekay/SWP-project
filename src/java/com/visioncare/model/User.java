package com.visioncare.model;

/**
 * Entity Ä‘áº¡i diá»‡n cho ngÆ°á»i dÃ¹ng há»‡ thá»‘ng (bá»‡nh nhÃ¢n, admin, bÃ¡c sÄ©).
 */
public class User {

    private int id;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String role;    // patient, doctor, admin
    private String dob;
    private String address;
    private int roleId;
    private String status;

    public User() {
    }

    public User(int id, String fullName, String email, String password,
                String phone, String role, String dob, String address, int roleId, String status) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
        this.dob = dob;
        this.address = address;
        this.roleId = roleId;
        this.status = status;
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

    public String getDob() {
        return dob;
    }

    public void setDob(String dob) {
        this.dob = dob;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
