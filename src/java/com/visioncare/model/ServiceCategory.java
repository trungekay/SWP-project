package com.visioncare.model;

public enum ServiceCategory {
    EXAMINATION("Khám và chẩn đoán"),
    TREATMENT("Điều trị và thủ thuật");

    private final String vietnameseName;

    ServiceCategory(String vietnameseName) {
        this.vietnameseName = vietnameseName;
    }

    public String getVietnameseName() { return vietnameseName; }

    public static ServiceCategory fromVietnameseName(String name) {
        for (ServiceCategory category : values()) {
            if (category.vietnameseName.equals(name)) return category;
        }
        return null;
    }
}
