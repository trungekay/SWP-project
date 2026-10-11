package com.visioncare.model;

import java.math.BigDecimal;

public class CatalogService {
    private final int id;
    private final String code;
    private final String name;
    private final BigDecimal price;
    private final int categoryId;
    private final String categoryName;
    private final String summary;
    private final String description;
    private final String image;
    private final boolean uploadedImage;

    public CatalogService(int id, String code, String name, BigDecimal price,
            int categoryId, String categoryName, String summary, String description, String image,
            boolean uploadedImage) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.price = price;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.summary = summary;
        this.description = description;
        this.image = image;
        this.uploadedImage = uploadedImage;
    }

    public int getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public int getCategoryId() { return categoryId; }
    public String getCategoryName() { return categoryName; }
    public String getSummary() { return summary; }
    public String getDescription() { return description; }
    public String getImage() { return image; }
    public boolean isUploadedImage() { return uploadedImage; }
}
