package com.visioncare.model;
public class Doctor {
    private int id;
    private String name;          
    private String title;         
    private String specialty;     
    private String departmentKey; 
    private String description;
    private String biography;     
    private String achievements;  
    private String image;         
    private double rating;        
    private int roomId;
    public Doctor() {
    }
    public Doctor(int id, String name, String title, String specialty,
                  String departmentKey, String description, String biography, String achievements, String image, double rating) {
        this.id = id;
        this.name = name;
        this.title = title;
        this.specialty = specialty;
        this.departmentKey = departmentKey;
        this.description = description;
        this.biography = biography;
        this.achievements = achievements;
        this.image = image;
        this.rating = rating;
    }
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public String getFullName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public String getSpecialty() {
        return specialty;
    }
    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }
    public String getDepartmentKey() {
        return departmentKey;
    }
    public void setDepartmentKey(String departmentKey) {
        this.departmentKey = departmentKey;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getBiography() {
        return biography;
    }
    public void setBiography(String biography) {
        this.biography = biography;
    }
    public String getAchievements() {
        return achievements;
    }
    public void setAchievements(String achievements) {
        this.achievements = achievements;
    }
    public String getImage() {
        return image;
    }
    public void setImage(String image) {
        this.image = image;
    }
    public double getRating() {
        return rating;
    }
    public void setRating(double rating) {
        this.rating = rating;
    }
    public int getRoomId() {
        return roomId;
    }
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
}
