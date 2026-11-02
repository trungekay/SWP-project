package com.visioncare.dao;

import com.visioncare.model.ConversionReportDay;
import java.sql.*;
import java.time.*;
import java.util.*;

public class ConversionReportDAO {
    public List<ConversionReportDay> list(LocalDate from, LocalDate to, LocalDateTime now) throws Exception {
        // Aggregate money before joining appointments: multiple payments/refunds must not multiply visits.
        String sql = "WITH Money AS ("
            + "SELECT Invoice_ID,CAST(Amount AS bigint) Amount FROM Payment_Transaction WHERE Gateway_Status='Success' "
            + "UNION ALL SELECT Invoice_ID,CAST(Opening_Paid AS bigint) FROM Invoice_Checkout WHERE Opening_Paid>0 "
            + "UNION ALL SELECT Invoice_ID,-CAST(Refund_Amount AS bigint) FROM Refund_Request WHERE Status='Completed'), "
            + "Receipts AS (SELECT i.Appointment_ID,SUM(m.Amount) Revenue FROM Money m "
            + "JOIN Master_Invoice i ON i.Invoice_ID=m.Invoice_ID GROUP BY i.Appointment_ID), "
            + "Visits AS (SELECT ws.Work_Date,COALESCE(r.Revenue,0) Revenue, CASE "
            + "WHEN a.Status IN ('Canceled','Cancelled') THEN 'Cancelled' "
            + "WHEN a.checkin_time IS NOT NULL OR a.Status IN ('In_Progress','Completed') THEN 'Arrived' "
            + "WHEN ws.Work_Date<CAST(? AS date) OR (ws.Work_Date=CAST(? AS date) AND ws.End_Time<CAST(? AS time)) THEN 'Absent' "
            + "ELSE 'Pending' END Visit_Status FROM Appointment a "
            + "JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
            + "LEFT JOIN Receipts r ON r.Appointment_ID=a.Appointment_ID WHERE ws.Work_Date BETWEEN ? AND ?) "
            + "SELECT Work_Date,COUNT_BIG(*) Total,"
            + "SUM(CAST(CASE WHEN Visit_Status='Arrived' THEN 1 ELSE 0 END AS bigint)) Arrived,"
            + "SUM(CAST(CASE WHEN Visit_Status='Cancelled' THEN 1 ELSE 0 END AS bigint)) Cancelled,"
            + "SUM(CAST(CASE WHEN Visit_Status='Absent' THEN 1 ELSE 0 END AS bigint)) Absent,"
            + "SUM(CAST(CASE WHEN Visit_Status='Pending' THEN 1 ELSE 0 END AS bigint)) Pending,"
            + "SUM(CASE WHEN Visit_Status='Arrived' THEN Revenue ELSE 0 END) Revenue "
            + "FROM Visits GROUP BY Work_Date ORDER BY Work_Date";
        List<ConversionReportDay> rows=new ArrayList<>();
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setTimestamp(1,Timestamp.valueOf(now));ps.setTimestamp(2,Timestamp.valueOf(now));
            ps.setTimestamp(3,Timestamp.valueOf(now));ps.setDate(4,java.sql.Date.valueOf(from));ps.setDate(5,java.sql.Date.valueOf(to));
            try(ResultSet rs=ps.executeQuery()) {while(rs.next()) rows.add(new ConversionReportDay(
                rs.getDate("Work_Date").toLocalDate(),rs.getLong("Total"),rs.getLong("Arrived"),
                rs.getLong("Cancelled"),rs.getLong("Absent"),rs.getLong("Pending"),rs.getLong("Revenue")));}
        }
        return rows;
    }
}
