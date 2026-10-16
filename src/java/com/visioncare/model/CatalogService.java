package com.visioncare.model;

import java.math.BigDecimal;

public class CatalogService {
    private final int id;
    private final String code;
    private final String name;
    private final BigDecimal price;
    private final String category;
    private final String summary;
    private final String description;
    private final boolean uploadedImage;

    public CatalogService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            boolean uploadedImage) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.price = price;
        this.category = category;
        this.summary = summary;
        this.description = description;
        this.uploadedImage = uploadedImage;
    }

    public int getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getCategory() { return category; }
    public String getCategoryName() { return category; }
    public String getSummary() { return summary; }
    public String getDescription() { return description; }
    public boolean isUploadedImage() { return uploadedImage; }

    public String getDefaultImagePath() {
        if (code != null) {
            String c = code.toUpperCase(java.util.Locale.ROOT);
            if (c.contains("NK") || c.contains("CVS")) return "departments-1.jpg";
            if (c.contains("KX")) return "departments-2.jpg";
            if (c.contains("LS") || c.contains("LASIK") || c.contains("SMILE")) return "departments-3.jpg";
            if (c.contains("PE")) return "departments-4.jpg";
            if (c.contains("TT") || c.contains("PHACO")) return "departments-5.jpg";
            if (c.contains("GL") || c.contains("DM") || c.contains("OCT")) return "gallery/gallery-1.jpg";
        }
        return "departments-1.jpg";
    }

    public String getSpecialty() {
        if (code != null) {
            String c = code.toUpperCase();
            if (c.contains("NK") || c.contains("CVS")) return "general";
            if (c.contains("KX")) return "refraction";
            if (c.contains("LS") || c.contains("LASIK") || c.contains("SMILE")) return "lasik";
            if (c.contains("PE")) return "children";
            if (c.contains("TT") || c.contains("PHACO")) return "cataract";
            if (c.contains("GL") || c.contains("DM") || c.contains("OCT")) return "retina";
        }
        if (name != null) {
            String n = name.toLowerCase();
            if (n.contains("khúc xạ") || n.contains("kính")) return "refraction";
            if (n.contains("lasik") || n.contains("smile") || n.contains("xóa cận")) return "lasik";
            if (n.contains("trẻ em") || n.contains("nhược thị")) return "children";
            if (n.contains("thủy tinh thể") || n.contains("phaco")) return "cataract";
            if (n.contains("glaucoma") || n.contains("võng mạc") || n.contains("đáy mắt") || n.contains("nhãn áp")) return "retina";
            if (n.contains("tổng quát") || n.contains("khô mắt")) return "general";
        }
        return category != null ? category : "";
    }

    public String getTag() {
        return category != null ? category : "";
    }
}
