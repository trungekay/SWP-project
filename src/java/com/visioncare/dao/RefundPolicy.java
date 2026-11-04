package com.visioncare.dao;

/** Refunds require a staff-approved cancellation before check-in and a paid invoice. */
public final class RefundPolicy {
    private RefundPolicy() {}
    public static final String APPROVED = "Đã duyệt hủy trước tiếp đón: ";
    public static final String REQUESTED = "Yêu cầu hủy lịch: ";
    public static final String DOCTOR_UNAVAILABLE = "Bác sĩ đổi lịch, không thể sắp xếp lịch khám khác cho bệnh nhân";
    public static final String PATIENT_AT_COUNTER = "Bệnh nhân yêu cầu hủy trực tiếp tại quầy trước check-in";
    public static boolean isRefundableCancellationReason(String reason) {
        if (reason == null) return false;
        String value = reason.trim();
        return value.startsWith("Đã duyệt yêu cầu hủy lịch") || value.equals(DOCTOR_UNAVAILABLE)
                || value.equals(PATIENT_AT_COUNTER)
                || value.equals("Liên hệ nhưng bệnh nhân báo bận không đến khám")
                || value.equals("Bệnh nhân không có nhu cầu khám nữa");
    }
    /** Recognize cancellation requests from both the current and the previous workflow. */
    public static final String CANCELLATION_REQUESTED = "a.Status = 'Pending' AND a.checkin_time IS NULL AND ("
        + "EXISTS (SELECT 1 FROM Medical_Record cm WHERE cm.Appointment_ID = a.Appointment_ID "
        + "AND cm.conclusion LIKE N'" + REQUESTED + "%') OR "
        + "EXISTS (SELECT 1 FROM Master_Invoice ci JOIN Refund_Request cr ON cr.Invoice_ID = ci.Invoice_ID "
        + "WHERE ci.Appointment_ID = a.Appointment_ID AND ci.Status IN ('Paid', 'Partial_Paid') "
        + "AND cr.Status = 'Pending' AND cr.Reason LIKE N'Hủy lịch hẹn #%'))";
    // Aliases a and i refer to Appointment and Master_Invoice respectively.
    public static final String ELIGIBLE = "a.Status = 'Canceled' "
        + "AND i.Status IN ('Paid', 'Partial_Paid') "
        + "AND EXISTS (SELECT 1 FROM Medical_Record mr WHERE mr.Appointment_ID = a.Appointment_ID "
        + "AND ((a.checkin_time IS NULL AND ("
        + "mr.conclusion LIKE N'" + APPROVED + "%' "
        + "OR mr.conclusion LIKE N'Lễ tân hủy lịch%')) "
        + "OR (a.checkin_time IS NOT NULL AND ("
        + "mr.conclusion LIKE N'Bác sĩ hủy ca quá giờ: %' "
        + "OR mr.conclusion LIKE N'%' + CHAR(10) + N'Bác sĩ hủy ca quá giờ: %')))) ";
    /** Only the latest Director-approved request is ready for payout. */
    public static final String APPROVED_FOR_PAYOUT = ELIGIBLE
        + " AND (SELECT TOP 1 rr.Status FROM Refund_Request rr WHERE rr.Invoice_ID = i.Invoice_ID ORDER BY rr.Refund_ID DESC) = 'Approved' ";
    public static final String NO_ACTIVE_REQUEST = "NOT EXISTS (SELECT 1 FROM Refund_Request rr "
        + "WHERE rr.Invoice_ID = i.Invoice_ID) ";
}
