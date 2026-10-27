package com.visioncare.util;

/** Exactly two persisted payment methods. Provider names do not define another method. */
public final class PaymentMethod {
    public static final String CASH = "Cash";
    public static final String QR_BANKING = "QR_Banking";
    private PaymentMethod() {}
    public static String canonical(String value) {
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Cần chọn phương thức thanh toán.");
        return switch (value.trim().toLowerCase(java.util.Locale.ROOT)) {
            case "cash", "cash_at_counter" -> CASH;
            case "qr_banking", "vietqr_banking", "bank_transfer", "payos_checkout", "vnpay" -> QR_BANKING;
            default -> throw new IllegalArgumentException("Phương thức thanh toán không hợp lệ.");
        };
    }
}
