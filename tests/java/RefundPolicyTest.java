import com.visioncare.dao.DBContext;
import com.visioncare.dao.RefundPolicy;
import com.visioncare.model.Appointment;
import java.sql.*;

/** Read-only SQL fixtures: no patient, invoice or request is written to the database. */
public class RefundPolicyTest {
    public static void main(String[] args) throws Exception {
        Appointment appt = new Appointment();
        appt.setStatus("Pending"); appt.setReason(RefundPolicy.REQUESTED + "Bận đột xuất");
        if (!appt.isCancellationRequested()) throw new AssertionError("Cancellation request must be distinguishable from unpaid booking");
        appt.setReason("Chưa thanh toán");
        if (appt.isCancellationRequested()) throw new AssertionError("Unpaid booking is not cancellation request");
        appt.setStatus("Confirmed"); appt.setInvoiceStatus("Paid"); appt.setCheckinTime(null);
        if (!appt.isReadyForCheckIn()) throw new AssertionError("Paid confirmed booking should await reception");
        appt.setCheckinTime("2026-10-23 08:00:00");
        if (appt.isReadyForCheckIn()) throw new AssertionError("Already checked-in booking cannot await reception");
        for (String code : new String[]{"#APT-19", "APT-19", "#APPT-19", "APPT-19"}) {
            if (!code.replaceFirst("(?i)^#?APP?T-", "").equals("19")) throw new AssertionError("Appointment code parsing: " + code);
        }
        DriverManager.setLoginTimeout(5);
        int count = 0;
        try (Connection conn = DBContext.getConnection()) {
            for (String status : new String[]{"Pending", "Confirmed", "In_Progress", "Completed", "Canceled"}) {
                for (boolean checkedIn : new boolean[]{false, true}) {
                    for (String invoice : new String[]{"Paid", "Partial_Paid", "Unpaid", "Pending_Deposit", "Refunded"}) {
                        for (boolean approved : new boolean[]{false, true}) {
                            for (String refund : new String[]{"", "Pending", "Approved", "Rejected"}) {
                                String sql = "WITH a AS (SELECT 1 AS Appointment_ID, CAST(? AS nvarchar(50)) AS Status, CAST(? AS datetime) AS checkin_time), "
                                    + "i AS (SELECT 1 AS Invoice_ID, CAST(? AS nvarchar(50)) AS Status), "
                                    + "Medical_Record AS (SELECT 1 AS Appointment_ID, CAST(? AS nvarchar(500)) AS conclusion), "
                                    + "Refund_Request AS (SELECT 1 AS Invoice_ID, CAST(? AS nvarchar(50)) AS Status) "
                                    + "SELECT CASE WHEN " + RefundPolicy.ELIGIBLE + " AND " + RefundPolicy.NO_ACTIVE_REQUEST + " THEN 1 ELSE 0 END FROM a CROSS JOIN i";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    ps.setString(1, status);
                                    ps.setTimestamp(2, checkedIn ? Timestamp.valueOf("2026-10-23 08:00:00") : null);
                                    ps.setString(3, invoice);
                                    ps.setString(4, approved ? RefundPolicy.APPROVED + "Bận đột xuất" : "Hệ thống: Hết hạn thanh toán");
                                    ps.setString(5, refund);
                                    try (ResultSet rs = ps.executeQuery()) {
                                        rs.next();
                                        boolean expected = status.equals("Canceled") && !checkedIn && approved
                                            && (invoice.equals("Paid") || invoice.equals("Partial_Paid"))
                                            && (refund.isEmpty() || refund.equals("Rejected"));
                                        if ((rs.getInt(1) == 1) != expected) throw new AssertionError(status + "/" + checkedIn + "/" + invoice + "/" + approved + "/" + refund);
                                        count++;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        System.out.println("PASS: " + count + " SQL refund eligibility scenarios and cancellation request state checks.");
    }
}
