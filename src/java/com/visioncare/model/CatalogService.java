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

    public String getSpecialty() {
        if (code != null) {
            String c = code.toUpperCase();
            if (c.contains("NK")) return "general";
            if (c.contains("KX")) return "refraction";
            if (c.contains("LS")) return "lasik";
            if (c.contains("PE")) return "children";
            if (c.contains("TT")) return "cataract";
            if (c.contains("GL")) return "retina";
        }
        if (name != null) {
            String n = name.toLowerCase();
            if (n.contains("khúc xạ") || n.contains("kính")) return "refraction";
            if (n.contains("lasik") || n.contains("phẫu thuật")) return "lasik";
            if (n.contains("trẻ em") || n.contains("nhược thị")) return "children";
            if (n.contains("thủy tinh thể") || n.contains("phaco")) return "cataract";
            if (n.contains("glaucoma") || n.contains("võng mạc") || n.contains("nhãn áp")) return "retina";
            if (n.contains("tổng quát")) return "general";
        }
        return categoryName != null ? categoryName : "";
    }

    public String getTag() {
        return categoryName != null ? categoryName : "";
    }
}
