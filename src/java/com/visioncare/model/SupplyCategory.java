package com.visioncare.model;

public enum SupplyCategory {
    MEDICATIONS_AND_SOLUTIONS("Thuốc & dung dịch"),
    FRAMES_AND_LENSES("Kính gọng & tròng kính"),
    CONTACT_LENSES("Kính áp tròng"),
    ACCESSORIES_AND_SUPPORT("Phụ kiện & sản phẩm hỗ trợ"),
    MEDICAL_CONSUMABLES("Vật tư y tế tiêu hao"),
    OTHER("Khác");

    private final String vietnameseName;

    SupplyCategory(String vietnameseName) {
        this.vietnameseName = vietnameseName;
    }

    public String getVietnameseName() { return vietnameseName; }

    public static SupplyCategory[] retailValues() {
        return new SupplyCategory[]{MEDICATIONS_AND_SOLUTIONS, FRAMES_AND_LENSES,
                CONTACT_LENSES, ACCESSORIES_AND_SUPPORT, OTHER};
    }

    public boolean isRetail() {
        for (SupplyCategory category : retailValues()) {
            if (this == category) return true;
        }
        return false;
    }

    public static SupplyCategory fromVietnameseName(String name) {
        for (SupplyCategory category : values()) {
            if (category.vietnameseName.equals(name)) return category;
        }
        return null;
    }
}
