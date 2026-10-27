package com.visioncare.model;

public class ClinicBanner {
    private String key;
    private String title;
    private String defaultFilename;
    private boolean hasCustomImage;
    private String updatedAt;

    public ClinicBanner() {
    }

    public ClinicBanner(String key, String title, String defaultFilename, boolean hasCustomImage, String updatedAt) {
        this.key = key;
        this.title = title;
        this.defaultFilename = defaultFilename;
        this.hasCustomImage = hasCustomImage;
        this.updatedAt = updatedAt;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
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
