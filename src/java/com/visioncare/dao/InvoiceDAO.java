package com.visioncare.dao;

import java.sql.*;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class InvoiceDAO {

    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private final SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");

    private String formatVND(long amount) {
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(amount) + " đ";
    }

    private String getStatusVn(String status) {
        if (status == null) return "Chưa xác định";
        switch (status) {
            case "Paid":
                return "Đã thanh toán";
            case "Unpaid":
                return "Chưa thanh toán";
            case "Pending_Deposit":
                return "Chờ đặt cọc";
            case "Refunded":
                return "Đã hoàn tiền";
            case "Partial_Paid":
            case "Partially_Paid":
                return "Thanh toán 1 phần";
            default:
                return status;
        }
    }

    private String getBadgeClass(String status) {
        if ("Paid".equals(status)) return "badge-paid";
        if ("Refunded".equals(status)) return "badge-refunded";
        return "badge-unpaid";
    }

    /**
     * Get billing overview statistics for Admin Dashboard/Billing
     */
    public Map<String, Object> getBillingStats() {
        return getBillingStats(null, null);
    }

    public Map<String, Object> getBillingStats(String dateFrom, String dateTo) {
        Map<String, Object> stats = new HashMap<>();

        // 1. Overall & Preset metrics: Today, Current Month, All-Time
        String sqlOverview = 
            "SELECT " +
            "    ISNULL(SUM(CASE WHEN Status = 'Paid' AND CAST(Create_At AS DATE) = CAST(GETDATE() AS DATE) THEN Total_Amount ELSE 0 END), 0) AS Today_Revenue, " +
            "    COUNT(CASE WHEN Status = 'Paid' AND CAST(Create_At AS DATE) = CAST(GETDATE() AS DATE) THEN 1 END) AS Today_Paid_Count, " +
            "    ISNULL(SUM(CASE WHEN Status = 'Paid' AND YEAR(Create_At) = YEAR(GETDATE()) AND MONTH(Create_At) = MONTH(GETDATE()) THEN Total_Amount ELSE 0 END), 0) AS Month_Revenue, " +
            "    COUNT(CASE WHEN Status = 'Paid' AND YEAR(Create_At) = YEAR(GETDATE()) AND MONTH(Create_At) = MONTH(GETDATE()) THEN 1 END) AS Month_Paid_Count, " +
            "    ISNULL(SUM(CASE WHEN Status = 'Paid' THEN Total_Amount ELSE 0 END), 0) AS AllTime_Revenue, " +
            "    COUNT(CASE WHEN Status = 'Paid' THEN 1 END) AS AllTime_Paid_Count, " +
            "    COUNT(CASE WHEN Status = 'Refunded' THEN 1 END) AS AllTime_Refunded_Count, " +
            "    COUNT(CASE WHEN Status != 'Paid' AND Status != 'Refunded' THEN 1 END) AS AllTime_Unpaid_Count, " +
            "    COUNT(*) AS AllTime_Total_Count " +
            "FROM Master_Invoice";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOverview);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                long todayRev = rs.getLong("Today_Revenue");
                int todayPaid = rs.getInt("Today_Paid_Count");
                long monthRev = rs.getLong("Month_Revenue");
                int monthPaid = rs.getInt("Month_Paid_Count");
                long allTimeRev = rs.getLong("AllTime_Revenue");
                int allTimePaid = rs.getInt("AllTime_Paid_Count");
                int allTimeRef = rs.getInt("AllTime_Refunded_Count");
                int allTimeUnpaid = rs.getInt("AllTime_Unpaid_Count");
                int allTimeTotal = rs.getInt("AllTime_Total_Count");

                stats.put("todayRevenue", todayRev);
                stats.put("todayRevenueFmt", formatVND(todayRev));
                stats.put("todayPaidCount", todayPaid);

                stats.put("monthRevenue", monthRev);
                stats.put("monthRevenueFmt", formatVND(monthRev));
                stats.put("monthPaidCount", monthPaid);

                stats.put("allTimeRevenue", allTimeRev);
                stats.put("allTimeRevenueFmt", formatVND(allTimeRev));
                stats.put("allTimePaidCount", allTimePaid);
                stats.put("allTimeRefundedCount", allTimeRef);
                stats.put("allTimeUnpaidCount", allTimeUnpaid);
                stats.put("allTimeTotalCount", allTimeTotal);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Period metrics based on dateFrom and dateTo
        StringBuilder sqlPeriod = new StringBuilder(
            "SELECT " +
            "    ISNULL(SUM(CASE WHEN Status = 'Paid' THEN Total_Amount ELSE 0 END), 0) AS Period_Revenue, " +
            "    COUNT(CASE WHEN Status = 'Paid' THEN 1 END) AS Period_Paid_Count, " +
            "    COUNT(CASE WHEN Status != 'Paid' AND Status != 'Refunded' THEN 1 END) AS Period_Unpaid_Count, " +
            "    COUNT(CASE WHEN Status = 'Refunded' THEN 1 END) AS Period_Refunded_Count, " +
            "    COUNT(*) AS Period_Total_Count " +
            "FROM Master_Invoice WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sqlPeriod.append("AND CAST(Create_At AS DATE) >= ? ");
            params.add(dateFrom.trim());
        }
        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sqlPeriod.append("AND CAST(Create_At AS DATE) <= ? ");
            params.add(dateTo.trim());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPeriod.toString())) {
            for (int k = 0; k < params.size(); k++) {
                ps.setObject(k + 1, params.get(k));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long periodRev = rs.getLong("Period_Revenue");
                    int periodPaid = rs.getInt("Period_Paid_Count");
                    int periodUnpaid = rs.getInt("Period_Unpaid_Count");
                    int periodRef = rs.getInt("Period_Refunded_Count");
                    int periodTotal = rs.getInt("Period_Total_Count");

                    stats.put("periodRevenue", periodRev);
                    stats.put("periodRevenueFmt", formatVND(periodRev));
                    stats.put("periodPaidCount", periodPaid);
                    stats.put("periodUnpaidCount", periodUnpaid);
                    stats.put("periodRefundedCount", periodRef);
                    stats.put("periodTotalCount", periodTotal);

                    // Backward compatibility aliases
                    stats.put("totalRevenue", periodRev);
                    stats.put("totalRevenueFmt", formatVND(periodRev));
                    stats.put("paidCount", periodPaid);
                    stats.put("unpaidCount", periodUnpaid);
                    stats.put("refundedCount", periodRef);
                    stats.put("totalInvoices", periodTotal);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Search and filter invoices for Admin
     */
    public List<Map<String, Object>> getAllInvoices(String search, String status, String dateFrom, String dateTo) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT i.Invoice_ID, i.Appointment_ID, i.Total_Amount, i.Deposit_Amount, i.Balance_Due, i.Status, i.Create_At, i.Close_At, " +
            "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.Account_ID, " +
            "e.Full_Name AS Doctor_Name, " +
            "(SELECT TOP 1 pt.Payment_Gateway FROM Payment_Transaction pt WHERE pt.Invoice_ID = i.Invoice_ID ORDER BY pt.Transaction_ID DESC) AS Payment_Method, " +
            "(SELECT TOP 1 pt.Trans_Date FROM Payment_Transaction pt WHERE pt.Invoice_ID = i.Invoice_ID ORDER BY pt.Transaction_ID DESC) AS Payment_Date " +
            "FROM Master_Invoice i " +
            "JOIN Appointment a ON i.Appointment_ID = a.Appointment_ID " +
            "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
            "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            String s = "%" + search.trim() + "%";
            sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR CAST(i.Invoice_ID AS VARCHAR) LIKE ? OR CAST(a.Appointment_ID AS VARCHAR) LIKE ?) ");
            params.add(s);
            params.add(s);
            params.add(s);
            params.add(s);
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append("AND i.Status = ? ");
            params.add(status.trim());
        }

        if (dateFrom != null && !dateFrom.trim().isEmpty()) {
            sql.append("AND CAST(i.Create_At AS DATE) >= ? ");
            params.add(dateFrom.trim());
        }

        if (dateTo != null && !dateTo.trim().isEmpty()) {
            sql.append("AND CAST(i.Create_At AS DATE) <= ? ");
            params.add(dateTo.trim());
        }

        sql.append("ORDER BY i.Invoice_ID DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int k = 0; k < params.size(); k++) {
                ps.setObject(k + 1, params.get(k));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    int id = rs.getInt("Invoice_ID");
                    long totalAmt = rs.getLong("Total_Amount");
                    String st = rs.getString("Status");
                    Timestamp createAt = rs.getTimestamp("Create_At");
                    Timestamp closeAt = rs.getTimestamp("Close_At");
                    Timestamp payDate = rs.getTimestamp("Payment_Date");

                    map.put("id", id);
                    map.put("formattedId", String.format("#INV-%05d", id));
                    map.put("appointmentId", rs.getInt("Appointment_ID"));
                    map.put("totalAmount", totalAmt);
                    map.put("totalAmountFmt", formatVND(totalAmt));
                    map.put("depositAmount", rs.getLong("Deposit_Amount"));
                    map.put("balanceDue", rs.getLong("Balance_Due"));
                    map.put("status", st);
                    map.put("statusVn", getStatusVn(st));
                    map.put("badgeClass", getBadgeClass(st));
                    map.put("createDate", createAt != null ? dateFormat.format(createAt) : "");
                    map.put("closeDate", closeAt != null ? dateFormat.format(closeAt) : "");
                    map.put("patientName", rs.getString("Patient_Name"));
                    map.put("patientPhone", rs.getString("Patient_Phone"));
                    map.put("doctorName", rs.getString("Doctor_Name") != null ? rs.getString("Doctor_Name") : "Chưa chỉ định");
                    map.put("paymentMethod", rs.getString("Payment_Method") != null ? rs.getString("Payment_Method") : "Chưa thanh toán");
                    map.put("paymentDate", payDate != null ? dateFormat.format(payDate) : "");

                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get full detailed invoice with items, patient, doctor and transactions
     */
    public Map<String, Object> getInvoiceDetail(int invoiceId) {
        Map<String, Object> finalized = getFinalizedCheckoutDetail(invoiceId);
        if (finalized != null) return finalized;
        Map<String, Object> invoice = null;

        String sqlInv = "SELECT i.Invoice_ID, i.Appointment_ID, i.Total_Amount, i.Deposit_Amount, i.Balance_Due, i.Status, i.Create_At, i.Close_At, " +
                        "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, p.Address AS Patient_Address, p.Account_ID, " +
                        "acc.Email AS Patient_Email, " +
                        "e.Full_Name AS Doctor_Name, " +
                        "m.Record_ID, m.Clinical_Diagnosis " +
                        "FROM Master_Invoice i " +
                        "JOIN Appointment a ON i.Appointment_ID = a.Appointment_ID " +
                        "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                        "LEFT JOIN Account acc ON p.Account_ID = acc.Account_ID " +
                        "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                        "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID " +
                        "LEFT JOIN Medical_Record m ON a.Appointment_ID = m.Appointment_ID " +
                        "WHERE i.Invoice_ID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlInv)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    invoice = new HashMap<>();
                    long totalAmt = rs.getLong("Total_Amount");
                    String st = rs.getString("Status");
                    Timestamp createAt = rs.getTimestamp("Create_At");
                    Timestamp closeAt = rs.getTimestamp("Close_At");

                    invoice.put("id", invoiceId);
                    invoice.put("formattedId", String.format("#INV-%05d", invoiceId));
                    invoice.put("appointmentId", rs.getInt("Appointment_ID"));
                    invoice.put("totalAmount", totalAmt);
                    invoice.put("totalAmountFmt", formatVND(totalAmt));
                    invoice.put("depositAmount", rs.getLong("Deposit_Amount"));
                    invoice.put("depositAmountFmt", formatVND(rs.getLong("Deposit_Amount")));
                    invoice.put("balanceDue", rs.getLong("Balance_Due"));
                    invoice.put("balanceDueFmt", formatVND(rs.getLong("Balance_Due")));
                    invoice.put("status", st);
                    invoice.put("statusVn", getStatusVn(st));
                    invoice.put("badgeClass", getBadgeClass(st));
                    invoice.put("createDate", createAt != null ? dateFormat.format(createAt) : "");
                    invoice.put("closeDate", closeAt != null ? dateFormat.format(closeAt) : "");

                    invoice.put("patientId", rs.getInt("Patient_ID"));
                    invoice.put("accountId", rs.getInt("Account_ID"));
                    invoice.put("patientName", rs.getString("Patient_Name"));
                    invoice.put("patientPhone", rs.getString("Patient_Phone"));
                    java.sql.Date dob = rs.getDate("Patient_DOB");
                    invoice.put("patientDob", dob != null ? dateOnlyFormat.format(dob) : "");
                    invoice.put("patientAddress", rs.getString("Patient_Address") != null ? rs.getString("Patient_Address") : "456 Lê Thị Riêng, Quận 10, TP.HCM");
                    invoice.put("patientEmail", rs.getString("Patient_Email") != null ? rs.getString("Patient_Email") : "Chưa cập nhật");

                    String rawDoc = rs.getString("Doctor_Name");
                    String docName;
                    if (rawDoc == null || rawDoc.trim().isEmpty()) {
                        docName = "BS. Trần Văn Nam";
                    } else {
                        rawDoc = rawDoc.trim();
                        if (rawDoc.startsWith("BS. ")) {
                            docName = rawDoc;
                        } else if (rawDoc.startsWith("BS.")) {
                            docName = "BS. " + rawDoc.substring(3).trim();
                        } else if (rawDoc.startsWith("BS ")) {
                            docName = "BS. " + rawDoc.substring(3).trim();
                        } else if (rawDoc.startsWith("Bác sĩ ")) {
                            docName = "BS. " + rawDoc.substring(7).trim();
                        } else if (rawDoc.startsWith("ThS.") || rawDoc.startsWith("TS.") || rawDoc.startsWith("PGS.")) {
                            docName = rawDoc;
                        } else {
                            docName = "BS. " + rawDoc;
                        }
                    }
                    invoice.put("doctorName", docName);

                    int recordId = rs.getInt("Record_ID");
                    if (recordId > 0) {
                        invoice.put("recordId", String.format("#MR-%04d", recordId));
                    } else {
                        int aptId = rs.getInt("Appointment_ID");
                        invoice.put("recordId", aptId > 0 ? String.format("#MR-%04d", aptId) : "Chưa tạo");
                    }
                    invoice.put("diagnosis", rs.getString("Clinical_Diagnosis") != null ? rs.getString("Clinical_Diagnosis") : "Khám mắt tổng quát");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (invoice == null) return null;

        // Both patient and staff read the same live items or immutable final snapshot.
        // Never reconstruct a final bill from a later prescription or guess medicine prices.
        try {
            com.visioncare.model.StaffInvoice bill = new StaffInvoiceDAO().get(invoiceId);
            List<Map<String, Object>> items = new ArrayList<>();
            long medAmount = 0, procedureAmount = 0;
            int sequence = 1;
            for (com.visioncare.model.StaffInvoice.Item source : bill.items) {
                if (source.declined) continue;
                Map<String, Object> item = new HashMap<>();
                item.put("stt", sequence++);
                item.put("name", source.name);
                item.put("type", source.type);
                item.put("quantity", source.quantity);
                item.put("unitPrice", source.unitPrice);
                item.put("unitPriceFmt", source.unpriced ? "Chưa định giá" : formatVND(source.unitPrice));
                item.put("totalPrice", source.getAmount());
                item.put("totalPriceFmt", source.unpriced ? "Chưa định giá" : formatVND(source.getAmount()));
                items.add(item);
                if (source.key.startsWith("MEDICINE:")) medAmount += source.getAmount();
                if (source.key.startsWith("PROCEDURE:")) procedureAmount += source.getAmount();
            }
            invoice.put("items", items);
            invoice.put("depositAmount", bill.baseAmount);
            invoice.put("depositAmountFmt", formatVND(bill.baseAmount));
            invoice.put("medAmount", medAmount);
            invoice.put("medAmountFmt", formatVND(medAmount));
            invoice.put("procedureAmount", procedureAmount);
            invoice.put("procedureAmountFmt", formatVND(procedureAmount));
            invoice.put("totalAmount", bill.getTotal());
            invoice.put("totalAmountFmt", formatVND(bill.getTotal()));
            invoice.put("balanceDue", bill.getDue());
            invoice.put("balanceDueFmt", formatVND(bill.getDue()));
            invoice.put("statusVn", bill.getPaymentLabel());
        } catch (Exception error) {
            error.printStackTrace();
            return null; // An incomplete financial document must not be displayed as a valid bill.
        }

        // Fetch payment transactions
        List<Map<String, Object>> transactions = new ArrayList<>();
        String sqlTrans = "SELECT Transaction_ID, Amount, Gateway_Status, Payment_Gateway, Trans_Date " +
                          "FROM Payment_Transaction WHERE Invoice_ID = ? ORDER BY Transaction_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlTrans)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> t = new HashMap<>();
                    long amt = rs.getLong("Amount");
                    Timestamp tDate = rs.getTimestamp("Trans_Date");
                    t.put("id", rs.getInt("Transaction_ID"));
                    t.put("amount", amt);
                    t.put("amountFmt", formatVND(amt));
                    t.put("gateway", rs.getString("Payment_Gateway"));
                    t.put("status", rs.getString("Gateway_Status"));
                    t.put("date", tDate != null ? dateFormat.format(tDate) : "");
                    transactions.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        invoice.put("transactions", transactions);

        // Primary payment method
        String paymentMethod = "Chưa thanh toán";
        if (!transactions.isEmpty()) {
            paymentMethod = (String) transactions.get(0).get("gateway");
        }
        invoice.put("paymentMethod", paymentMethod);

        return invoice;
    }

    private Map<String, Object> getFinalizedCheckoutDetail(int id) {
        String sql = "SELECT p.Account_ID,p.Patient_ID,p.DOB,p.Address,acc.Email,e.Full_Name,co.Finalized_At,co.Payment_Method "
                + "FROM Invoice_Checkout co JOIN Master_Invoice i ON i.Invoice_ID=co.Invoice_ID "
                + "JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID JOIN Patient p ON p.Patient_ID=a.Patient_ID "
                + "LEFT JOIN Account acc ON acc.Account_ID=p.Account_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
                + "LEFT JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID WHERE co.Invoice_ID=? AND co.Finalized_At IS NOT NULL";
        try (Connection c=DBContext.getConnection(); PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setInt(1,id);
            try (ResultSet r=ps.executeQuery()) {
                if(!r.next()) return null;
                com.visioncare.model.StaffInvoice bill=new StaffInvoiceDAO().get(id);
                Map<String,Object> out=new HashMap<>();
                out.put("id",id);out.put("formattedId",String.format("#INV-%05d",id));out.put("appointmentId",bill.appointmentId);
                out.put("accountId",r.getInt("Account_ID"));out.put("patientId",r.getInt("Patient_ID"));out.put("patientName",bill.patientName);out.put("patientPhone",bill.phone);
                out.put("patientDob",r.getDate("DOB")!=null?dateOnlyFormat.format(r.getDate("DOB")):"");out.put("patientAddress",r.getString("Address"));out.put("patientEmail",r.getString("Email"));out.put("doctorName",r.getString("Full_Name"));
                out.put("totalAmount",bill.getTotal());out.put("totalAmountFmt",formatVND(bill.getTotal()));out.put("depositAmount",bill.paid);out.put("depositAmountFmt",formatVND(bill.paid));out.put("balanceDue",bill.getDue());out.put("balanceDueFmt",formatVND(bill.getDue()));
                out.put("status",bill.invoiceStatus);out.put("statusVn",getStatusVn(bill.invoiceStatus));out.put("badgeClass",getBadgeClass(bill.invoiceStatus));out.put("closeDate",dateFormat.format(r.getTimestamp("Finalized_At")));out.put("createDate",bill.date);out.put("paymentMethod",r.getString("Payment_Method"));
                List<Map<String,Object>> lines=new ArrayList<>();int index=1;
                for(com.visioncare.model.StaffInvoice.Item item:bill.items) if(!item.declined) {Map<String,Object> line=new HashMap<>();line.put("stt",index++);line.put("name",item.name);line.put("type",item.type);line.put("quantity",item.quantity);line.put("unitPrice",item.unitPrice);line.put("unitPriceFmt",formatVND(item.unitPrice));line.put("totalPrice",item.getAmount());line.put("totalPriceFmt",formatVND(item.getAmount()));lines.add(line);}
                out.put("items",lines);List<Map<String,Object>> txs=new ArrayList<>();
                for(Map<String,Object> entry:bill.transactions){Map<String,Object> tx=new HashMap<>(entry);tx.put("gateway",entry.get("method"));tx.put("amountFmt",formatVND((Long)entry.get("amount")));txs.add(tx);}out.put("transactions",txs);return out;
            }
        } catch(Exception error) {throw new IllegalStateException("Không đọc được bản hóa đơn đã chốt.",error);}
    }

    /**
     * Get invoice detail for patient with security check (must belong to their account)
     */
    public Map<String, Object> getInvoiceDetailForPatient(int invoiceId, int accountId) {
        Map<String, Object> detail = getInvoiceDetail(invoiceId);
        if (detail == null) return null;
        Integer accId = (Integer) detail.get("accountId");
        if (accId != null && accId == accountId) {
            return detail;
        }
        return null;
    }

    /**
     * Update invoice payment status (e.g. from Admin billing screen)
     */
    public boolean updateInvoiceStatus(int invoiceId, String newStatus, String paymentGateway, long amount) {
        String updateInv = "UPDATE Master_Invoice SET Status = ?, Balance_Due = 0, Close_At = DATEADD(HOUR, 7, SYSUTCDATETIME()) WHERE Invoice_ID = ?";
        String insertTx = "INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Payment_Gateway, Trans_Date) " +
                          "VALUES (?, ?, 'Success', ?, DATEADD(HOUR, 7, SYSUTCDATETIME()))";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            try (PreparedStatement guard = conn.prepareStatement("SELECT Invoice_ID FROM Invoice_Checkout WITH(UPDLOCK,HOLDLOCK) WHERE Invoice_ID=?")) {
                guard.setInt(1,invoiceId);
                try(ResultSet row=guard.executeQuery()){if(row.next()){conn.rollback();return false;}}
            }

            try (PreparedStatement ps = conn.prepareStatement(updateInv)) {
                ps.setString(1, newStatus);
                ps.setInt(2, invoiceId);
                ps.executeUpdate();
            }

            if ("Paid".equalsIgnoreCase(newStatus) && amount > 0) {
                try (PreparedStatement psTx = conn.prepareStatement(insertTx)) {
                    psTx.setInt(1, invoiceId);
                    psTx.setLong(2, amount);
                    psTx.setString(3, paymentGateway != null ? com.visioncare.util.PaymentMethod.canonical(paymentGateway) : "Cash");
                    psTx.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    /**
     * List of paid invoices for refund selection in patient profile.
     * Chỉ lịch được staff duyệt hủy trước check-in và có khoản đã thanh toán mới đủ điều kiện.
     */
    public List<Map<String, Object>> getPaidInvoicesForPatient(int accountId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT i.Invoice_ID, i.Total_Amount, i.Deposit_Amount, i.Close_At, i.Create_At, " +
                     "       a.Appointment_ID, a.Status AS Appointment_Status, i.Status AS Paid_Status, " +
                     "       ws.Work_Date, ws.Start_Time, ws.End_Time, " +
                     "       r.Refund_ID, r.Status AS Refund_Status, " +
                     "       CASE WHEN r.Refund_ID IS NOT NULL THEN 1 ELSE 0 END AS Has_Refund " +
                     "FROM Master_Invoice i " +
                     "JOIN Appointment a ON i.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "LEFT JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Refund_Request r ON i.Invoice_ID = r.Invoice_ID AND r.Status IN ('Pending', 'Approved', 'Success') " +
                     "WHERE p.Account_ID = ? " +
                     "  AND i.Status IN ('Paid', 'Partial_Paid') " +
                     "  AND " + RefundPolicy.ELIGIBLE + " " +
                     "ORDER BY a.Appointment_ID DESC, i.Invoice_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    int id = rs.getInt("Invoice_ID");
                    long depAmt = rs.getLong("Deposit_Amount");
                    long amt = "Partial_Paid".equals(rs.getString("Paid_Status")) ? depAmt : rs.getLong("Total_Amount");
                    int apptId = rs.getInt("Appointment_ID");
                    boolean hasRefund = rs.getInt("Has_Refund") == 1;
                    String refStatus = rs.getString("Refund_Status");
                    int refId = rs.getInt("Refund_ID");
                    String apptStatus = rs.getString("Appointment_Status");

                    map.put("id", id);
                    map.put("formattedId", String.format("#INV-%05d", id));
                    map.put("amount", amt);
                    map.put("depositAmount", amt);
                    map.put("amountFmt", formatVND(amt));
                    Timestamp t = rs.getTimestamp("Close_At");
                    if (t == null) t = rs.getTimestamp("Create_At");
                    map.put("date", t != null ? dateOnlyFormat.format(t) : "");
                    map.put("appointmentId", apptId);
                    map.put("formattedApptId", "#APT-" + apptId);
                    map.put("hasRefund", hasRefund);
                    map.put("isEligible", !hasRefund);
                    map.put("refundStatus", refStatus != null ? refStatus : "");
                    map.put("refundId", refId);
                    map.put("apptStatus", apptStatus);

                    java.sql.Date workDate = rs.getDate("Work_Date");
                    java.sql.Time startTime = rs.getTime("Start_Time");
                    String apptDateFmt = workDate != null ? dateOnlyFormat.format(workDate) : "";
                    String apptTimeFmt = startTime != null ? new SimpleDateFormat("HH:mm").format(startTime) : "";
                    map.put("apptDateFmt", apptDateFmt);
                    map.put("apptTimeFmt", apptTimeFmt);

                    String apptStatusVn = "Đã duyệt hủy";
                    if ("Pending".equalsIgnoreCase(apptStatus)) {
                        apptStatusVn = "Chờ duyệt hủy";
                    } else if ("Confirmed".equalsIgnoreCase(apptStatus)) {
                        apptStatusVn = "Đã đăng ký thành công";
                    }
                    map.put("apptStatusVn", apptStatusVn);

                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Check if invoice has an active refund request (Pending, Approved, Success)
     */
    public boolean hasActiveRefundRequest(int invoiceId) {
        String sql = "SELECT COUNT(*) FROM Refund_Request WHERE Invoice_ID = ? AND Status IN ('Pending', 'Approved', 'Success')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Create patient refund request
     * Requires a staff-approved cancellation before check-in and a paid invoice.
     */
    public boolean createRefundRequest(int invoiceId, int accountId, long amount, String reason) {
        return new RefundDAO().createRefundByPatient(invoiceId, accountId, amount, reason);
    }

    public boolean createRefundRequestForAppointment(int appointmentId, int accountId, long amount, String reason) {
        String sql = "SELECT i.Invoice_ID FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID = i.Appointment_ID "
            + "JOIN Patient p ON p.Patient_ID = a.Patient_ID WHERE a.Appointment_ID = ? AND p.Account_ID = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId); ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && createRefundRequest(rs.getInt(1), accountId, amount, reason);
            }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
}
