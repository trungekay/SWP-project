package com.visioncare.dao;

/** Refunds require a staff-approved cancellation before check-in and a paid invoice. */
public final class RefundPolicy {
    private RefundPolicy() {}
    public static final String APPROVED = "Đã duyệt hủy trước tiếp đón: ";
    public static final String REQUESTED = "Yêu cầu hủy lịch: ";
    public static final String DOCTOR_UNAVAILABLE = "Bác sĩ đổi lịch, không thể sắp xếp lịch khám khác cho bệnh nhân";
    /** Recognize cancellation requests from both the current and the previous workflow. */
    public static final String CANCELLATION_REQUESTED = "a.Status = 'Pending' AND a.checkin_time IS NULL AND ("
        + "EXISTS (SELECT 1 FROM Medical_Record cm WHERE cm.Appointment_ID = a.Appointment_ID "
        + "AND cm.conclusion LIKE N'" + REQUESTED + "%') OR "
        + "EXISTS (SELECT 1 FROM Master_Invoice ci JOIN Refund_Request cr ON cr.Invoice_ID = ci.Invoice_ID "
        + "WHERE ci.Appointment_ID = a.Appointment_ID AND ci.Status IN ('Paid', 'Partial_Paid') "
        + "AND cr.Status = 'Pending' AND cr.Reason LIKE N'Hủy lịch hẹn #%'))";
    // Aliases a and i refer to Appointment and Master_Invoice respectively.
    public static final String ELIGIBLE = "a.Status = 'Canceled' AND a.checkin_time IS NULL "
        + "AND i.Status IN ('Paid', 'Partial_Paid') "
        + "AND EXISTS (SELECT 1 FROM Medical_Record mr WHERE mr.Appointment_ID = a.Appointment_ID "
        + "AND mr.conclusion LIKE N'" + APPROVED + "%') ";
    public static final String NO_ACTIVE_REQUEST = "NOT EXISTS (SELECT 1 FROM Refund_Request rr "
        + "WHERE rr.Invoice_ID = i.Invoice_ID AND rr.Status IN ('Pending', 'Approved', 'Success')) ";
}
