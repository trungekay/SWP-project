package com.visioncare.model;

public enum SupplyCategory {
    MEDICATIONS_AND_SOLUTIONS("Thuốc & Dung dịch"),
    EYEWEAR_AND_ACCESSORIES("Kính & Phụ kiện"),
    MEDICAL_CONSUMABLES("Vật tư y tế tiêu hao"),
    OTHER("Khác");

    private final String vietnameseName;

    SupplyCategory(String vietnameseName) {
        this.vietnameseName = vietnameseName;
    }

    public String getVietnameseName() { return vietnameseName; }

    public static SupplyCategory fromVietnameseName(String name) {
        for (SupplyCategory category : values()) {
            if (category.vietnameseName.equals(name)) return category;
        }
        return null;
    }
}
