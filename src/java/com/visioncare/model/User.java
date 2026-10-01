package com.visioncare.model;

/**
 * Entity dai dien cho nguoi dung he thong (benh nhan, bac si, chuyen vien, nhan vien, admin, giam doc).
 */
public class User {

    private int id;                 // Account_ID
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String role;            // patient, doctor, medical_specialist, staff, admin, director
    private String dob;
    private String address;

    // Cac truong thong tin bo sung theo tung Actor
    private int actorId;            // Doctor_ID / Specialist_ID / Staff_ID / Patient_ID
    private String specialty;       // Chuyen khoa cua Bac si / KTV
    private String roomName;        // Ten phong lam viec (vd: P.101)
    private String licenseNumber;   // So chung chi hanh nghe
    private String position;        // Vi tri cua Nhan vien

    public User() {
    }

    public User(int id, String fullName, String email, String password,
                String phone, String role, String dob, String address) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
        this.dob = dob;
        this.address = address;
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

    public int getActorId() {
        return actorId;
    }

    public void setActorId(int actorId) {
        this.actorId = actorId;
    }

    public String getSpecialty() {
        return specialty;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getLicenseNumber() {
        return licenseNumber;
    }

    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }
}
