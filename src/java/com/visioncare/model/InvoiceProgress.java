package com.visioncare.model;

/** Checkout progress is separate from the stored financial balance and clinical status. */
public enum InvoiceProgress {
    Unpaid("Chưa thanh toán", "unpaid"),
    Partial_Paid("Thanh toán một phần", "partial"),
    Examined("Khám xong", "examined"),
    Completed("Hoàn thành", "completed"),
    Canceled("Đã hủy", "canceled"),
    Refunded("Đã hoàn tiền", "refunded"),
    NoInvoice("Chưa có hóa đơn", "missing");

    private final String label, color;
    InvoiceProgress(String label, String color) { this.label=label; this.color=color; }
    public String getLabel() { return label; }
    public String getColor() { return color; }

    public static InvoiceProgress resolve(boolean hasInvoice, String appointment, String financial,
                                          boolean finalized, boolean hasPayment) {
        if ("Refunded".equals(financial)) return Refunded;
        if (!hasInvoice) return NoInvoice;
        if ("Canceled".equals(appointment) || "Canceled".equals(financial))
            return hasPayment ? Canceled : Unpaid;
        if (finalized) return Completed;
        if ("Completed".equals(appointment)) return Examined;
        return hasPayment ? Partial_Paid : Unpaid;
    }
}
