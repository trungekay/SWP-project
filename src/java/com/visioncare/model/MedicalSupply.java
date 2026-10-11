package com.visioncare.model;

import java.math.BigDecimal;

public class MedicalSupply {
    private final int id;
    private final String name;
    private final String category;
    private final String batch;
    private final String unit;
    private final BigDecimal price;
    private final boolean uploadedImage;

    public MedicalSupply(int id, String name, String category, String batch,
            String unit, BigDecimal price, boolean uploadedImage) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.batch = batch;
        this.unit = unit;
        this.price = price;
        this.uploadedImage = uploadedImage;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public String getBatch() { return batch; }
    public String getUnit() { return unit; }
    public BigDecimal getPrice() { return price; }
    public boolean isUploadedImage() { return uploadedImage; }
}
