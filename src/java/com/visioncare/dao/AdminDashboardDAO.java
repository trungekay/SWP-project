package com.visioncare.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminDashboardDAO {
    // Procedure payments are already transactions. The request only classifies them.
    private static final String EVENTS =
        "WITH Events AS (" +
        "SELECT CAST(t.Trans_Date AS date) Event_Day, t.Trans_Date Event_Time, CAST(t.Amount AS bigint) Amount, " +
        "CASE WHEN EXISTS(SELECT 1 FROM Procedure_Payment_Request pr WHERE pr.Transaction_ID=t.Transaction_ID) THEN 'Surgery' ELSE 'Exam' END Source " +
        "FROM Payment_Transaction t WHERE t.Gateway_Status='Success' " +
        "UNION ALL SELECT CAST(i.Create_At AS date),i.Create_At,CAST(co.Opening_Paid AS bigint),'Exam' " +
        "FROM Invoice_Checkout co JOIN Master_Invoice i ON i.Invoice_ID=co.Invoice_ID WHERE co.Opening_Paid>0 " +
        "UNION ALL SELECT CAST(DATEADD(HOUR,7,COALESCE(r.Completed_At,r.Update_At)) AS date),DATEADD(HOUR,7,COALESCE(r.Completed_At,r.Update_At)),-CAST(r.Refund_Amount AS bigint),'Refund' " +
        "FROM Refund_Request r WHERE r.Status='Completed') ";

    public Map<String,Long> getRevenue(LocalDate from, LocalDate to) throws Exception {
        String sql=EVENTS+"SELECT COALESCE(SUM(Amount),0) Total, " +
            "COALESCE(SUM(CASE WHEN Source='Exam' THEN Amount ELSE 0 END),0) Exam, " +
            "COALESCE(SUM(CASE WHEN Source='Surgery' THEN Amount ELSE 0 END),0) Surgery, " +
            "COALESCE(SUM(CASE WHEN Source='Refund' THEN -Amount ELSE 0 END),0) Refund " +
            "FROM Events WHERE Event_Day BETWEEN ? AND ?";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setDate(1,Date.valueOf(from));ps.setDate(2,Date.valueOf(to));
            try(ResultSet rs=ps.executeQuery()){rs.next();Map<String,Long> out=new HashMap<>();
                for(String key:new String[]{"Total","Exam","Surgery","Refund"})out.put(key,rs.getLong(key));
                return out;}
        }
    }

    public List<Map<String,Long>> getRevenueSeries(LocalDate from,LocalDate to,String bucket,int count) throws Exception {
        String expression;
        switch(bucket){
            case "slot":expression="DATEPART(hour,Event_Time)/2";break;
            case "day":expression="DATEDIFF(day,?,Event_Day)";break;
            case "month":expression="DATEDIFF(month,?,Event_Day)";break;
            default:expression="DATEDIFF(day,?,Event_Day)/7";
        }
        String sql=EVENTS+"SELECT Bucket_Index," +
            "SUM(CASE WHEN Source='Exam' THEN Amount ELSE 0 END) Exam," +
            "SUM(CASE WHEN Source='Surgery' THEN Amount ELSE 0 END) Surgery FROM (" +
            "SELECT "+expression+" Bucket_Index,Amount,Source " +
            "FROM Events WHERE Event_Day BETWEEN ? AND ? AND Source IN ('Exam','Surgery')) buckets GROUP BY Bucket_Index";
        List<Map<String,Long>> series=new ArrayList<>();
        for(int i=0;i<count;i++)series.add(new HashMap<>(Map.of("Exam",0L,"Surgery",0L)));
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            int index=1;
            if(!"slot".equals(bucket))ps.setDate(index++,Date.valueOf(from));
            ps.setDate(index++,Date.valueOf(from));
            ps.setDate(index,Date.valueOf(to));
            try(ResultSet rs=ps.executeQuery()){while(rs.next()){
                int i=rs.getInt("Bucket_Index");
                if(i>=0&&i<count){
                    series.get(i).put("Exam",rs.getLong("Exam"));
                    series.get(i).put("Surgery",rs.getLong("Surgery"));
                }
            }}
        }
        return series;
    }

    public AttendanceSummary getAttendanceSummary(LocalDate today) throws Exception {
        String sql="SELECT COUNT(*) Total_Appointments,COUNT(CASE WHEN a.checkin_time IS NOT NULL THEN 1 END) Checked_In " +
            "FROM Appointment a JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID " +
            "WHERE ws.Work_Date BETWEEN ? AND ? AND a.Status IN ('Confirmed','In_Progress','Completed')";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setDate(1,Date.valueOf(today.withDayOfMonth(1)));ps.setDate(2,Date.valueOf(today));
            try(ResultSet rs=ps.executeQuery()){rs.next();return new AttendanceSummary(rs.getInt(1),rs.getInt(2));}
        }
    }

    public List<Map<String,Object>> getJournal(LocalDate from,LocalDate to,String search,String status,int page,int size) throws Exception {
        String sql="SELECT t.Transaction_ID,t.Invoice_ID,t.Amount,t.Gateway_Status,t.Payment_Gateway," +
            "t.Trans_Date Event_Time,p.Full_Name Patient_Name,p.Phone,e.Full_Name Doctor_Name," +
            "(SELECT TOP 1 s.Service_Name FROM Procedure_Payment_Request pr JOIN Procedure_Order po ON po.Order_ID=pr.Order_ID " +
            "JOIN Service_Catalog s ON s.Service_ID=po.Service_ID WHERE pr.Transaction_ID=t.Transaction_ID) Service_Name " +
            "FROM Payment_Transaction t JOIN Master_Invoice i ON i.Invoice_ID=t.Invoice_ID " +
            "JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID JOIN Patient p ON p.Patient_ID=a.Patient_ID " +
            "JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID LEFT JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID " +
            "WHERE CAST(t.Trans_Date AS date) BETWEEN ? AND ? " +
            "AND (?='' OR p.Full_Name LIKE ? OR p.Phone LIKE ? OR CAST(t.Invoice_ID AS varchar(20)) LIKE ?) " +
            "AND (?='all' OR t.Gateway_Status=?) ORDER BY t.Trans_Date DESC,t.Transaction_ID DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        List<Map<String,Object>> rows=new ArrayList<>();
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            String term="%"+search+"%";ps.setDate(1,Date.valueOf(from));ps.setDate(2,Date.valueOf(to));
            ps.setString(3,search);ps.setString(4,term);ps.setString(5,term);ps.setString(6,term);
            ps.setString(7,status);ps.setString(8,status);ps.setInt(9,(page-1)*size);ps.setInt(10,size+1);
            try(ResultSet rs=ps.executeQuery()){while(rs.next()){
                Map<String,Object> row=new HashMap<>();
                for(String key:new String[]{"Transaction_ID","Invoice_ID","Amount","Gateway_Status","Payment_Gateway","Event_Time","Patient_Name","Phone","Doctor_Name","Service_Name"})
                    row.put(key,rs.getObject(key));
                rows.add(row);
            }}
        }
        return rows;
    }

    public static class AttendanceSummary {
        private final int totalAppointments,checkedIn;
        public AttendanceSummary(int totalAppointments,int checkedIn){this.totalAppointments=totalAppointments;this.checkedIn=checkedIn;}
        public int getTotalAppointments(){return totalAppointments;}
        public int getCheckedIn(){return checkedIn;}
        public Integer getRatePercent(){return totalAppointments==0?null:(int)Math.round(checkedIn*100.0/totalAppointments);}
    }
}
