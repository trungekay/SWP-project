package com.visioncare.model;

import java.math.BigDecimal;

public class Medicine {
    private final int id;
    private final String name;
    private final String category;
    private final BigDecimal price;
    private final boolean uploadedImage;

    public Medicine(int id, String name, String category, BigDecimal price, boolean uploadedImage) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.uploadedImage = uploadedImage;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public BigDecimal getPrice() { return price; }
    public boolean isUploadedImage() { return uploadedImage; }
}
