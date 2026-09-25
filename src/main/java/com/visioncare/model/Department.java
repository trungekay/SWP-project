package com.visioncare.model;

/**
 * Entity đại diện cho chuyên khoa nhãn khoa.
 */
public class Department {

    private int id;
    private String key;         // general, lasik, pediatric, glaucoma, refraction
    private String name;        // Nhãn khoa tổng quát
    private String icon;        // fa-solid fa-eye
    private String description;

    public Department() {
    }

    public Department(int id, String key, String name, String icon, String description) {
        this.id = id;
        this.key = key;
        this.name = name;
        this.icon = icon;
        this.description = description;
    }

    // ===== Getters & Setters =====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
