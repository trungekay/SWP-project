import com.visioncare.dao.DBContext;
import com.visioncare.dao.RefundPolicy;
import com.visioncare.model.Appointment;
import java.sql.*;

/** Read-only regression fixtures for paid bookings and legacy cancellation requests. */
public class CancellationRequestTest {
    public static void main(String[] args) throws Exception {
        String[][] cases = {
            {"Pending", "Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "0", "1"},
            {"Pending", "Partial_Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "0", "1"},
            {"Pending", "Paid", "Pending", "Hoàn tiền khác", "", "0", "0"},
            {"Pending", "Unpaid", "Pending", "Hủy lịch hẹn #30: bận", "", "0", "0"},
            {"Pending", "Paid", "Rejected", "Hủy lịch hẹn #30: bận", "", "0", "0"},
            {"Pending", "Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "1", "0"},
            {"Confirmed", "Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "0", "0"},
            {"Canceled", "Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "0", "0"},
            {"Completed", "Paid", "Pending", "Hủy lịch hẹn #30: bận", "", "1", "0"},
            {"Pending", "Paid", "", "", RefundPolicy.REQUESTED + "bận", "0", "1"},
            {"Pending", "Paid", "", "", "", "0", "0"},
            {"Pending", "Pending_Deposit", "", "", "", "0", "0"}
        };
        DriverManager.setLoginTimeout(5);
        try (Connection conn = DBContext.getConnection()) {
            for (String[] row : cases) {
                String sql = "WITH a AS (SELECT 30 AS Appointment_ID, CAST(? AS nvarchar(50)) AS Status, CAST(? AS datetime) AS checkin_time), "
                    + "Master_Invoice AS (SELECT 29 AS Invoice_ID, 30 AS Appointment_ID, CAST(? AS nvarchar(50)) AS Status), "
                    + "Refund_Request AS (SELECT 29 AS Invoice_ID, CAST(? AS nvarchar(50)) AS Status, CAST(? AS nvarchar(500)) AS Reason), "
                    + "Medical_Record AS (SELECT 30 AS Appointment_ID, CAST(? AS nvarchar(500)) AS conclusion) "
                    + "SELECT CASE WHEN " + RefundPolicy.CANCELLATION_REQUESTED + " THEN 1 ELSE 0 END FROM a";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, row[0]); ps.setTimestamp(2, row[5].equals("1") ? Timestamp.valueOf("2026-10-19 08:00:00") : null);
                    ps.setString(3, row[1]); ps.setString(4, row[2]); ps.setString(5, row[3]); ps.setString(6, row[4]);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) != Integer.parseInt(row[6])) throw new AssertionError(java.util.Arrays.toString(row));
                    }
                }
            }
        }
        Appointment paidPending = new Appointment();
        paidPending.setStatus("Pending"); paidPending.setInvoiceStatus("Paid");
        if (paidPending.isAwaitingPayment()) throw new AssertionError("Never offer payment again for a paid booking");
        paidPending.setCancellationRequested(true);
        if (!paidPending.isCancellationRequested()) throw new AssertionError("Legacy cancellation must show waiting for cancellation approval");
        paidPending.setCheckinTime("2026-10-19 08:00:00");
        if (paidPending.isCancellationRequested()) throw new AssertionError("Cannot request cancellation after check-in");
        for (String invoice : new String[]{"Paid", "Partial_Paid", "Refunded", "Canceled"}) {
            Appointment booking = new Appointment(); booking.setStatus("Pending"); booking.setInvoiceStatus(invoice);
            if (booking.isAwaitingPayment()) throw new AssertionError("No payment button for invoice " + invoice);
        }
        for (String invoice : new String[]{"Pending_Deposit", "Unpaid"}) {
            Appointment booking = new Appointment(); booking.setStatus("Pending"); booking.setInvoiceStatus(invoice);
            if (!booking.isAwaitingPayment()) throw new AssertionError("Unpaid deposit should offer payment");
        }
        System.out.println("PASS: 12 cancellation SQL fixtures and paid-booking display states.");
    }
}
