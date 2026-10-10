package com.visioncare.model;

public class ClinicGalleryItem {
    private int id;
    private String title;
    private String description;
    private int displayOrder;
    private String defaultFilename;
    private boolean hasCustomImage;
    private String updatedAt;

    public ClinicGalleryItem() {
    }

    public ClinicGalleryItem(int id, String title, String description, int displayOrder, String defaultFilename, boolean hasCustomImage, String updatedAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.displayOrder = displayOrder;
        this.defaultFilename = defaultFilename;
        this.hasCustomImage = hasCustomImage;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public String getDefaultFilename() {
        return defaultFilename;
    }

    public void setDefaultFilename(String defaultFilename) {
        this.defaultFilename = defaultFilename;
    }

    public boolean isHasCustomImage() {
        return hasCustomImage;
    }

    public void setHasCustomImage(boolean hasCustomImage) {
        this.hasCustomImage = hasCustomImage;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
}
