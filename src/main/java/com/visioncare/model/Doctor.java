package com.visioncare.model;

/**
 * Entity đại diện cho Bác sĩ nhãn khoa.
 */
public class Doctor {

    private int id;
    private String name;          // ThS.BS. Nguyễn Văn An
    private String title;         // ThS.BS., TS.BS., BS.CKI., BS.
    private String specialty;     // Phẫu thuật LASIK & Khúc xạ
    private String departmentKey; // lasik, glaucoma, general, pediatric
    private String description;
    private String image;         // doctors/doctors-1.jpg
    private double rating;        // 4.5

    public Doctor() {
    }

    public Doctor(int id, String name, String title, String specialty,
                  String departmentKey, String description, String image, double rating) {
        this.id = id;
        this.name = name;
        this.title = title;
        this.specialty = specialty;
        this.departmentKey = departmentKey;
        this.description = description;
        this.image = image;
        this.rating = rating;
    }

    // ===== Getters & Setters =====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
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
}
