package com.visioncare.dao;

import com.visioncare.model.LeaveCancelRequest;
import java.sql.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class LeaveCancelRequestDAO {

    @FunctionalInterface public interface Connections { Connection open() throws Exception; }
    private final Connections connections;

    public LeaveCancelRequestDAO() { this(DBContext::getConnection); }
    public LeaveCancelRequestDAO(Connections connections) { this.connections=connections; }

    // A request anchors one morning/afternoon, identified by the registered schedule.
    public static final String SAME_SHIFT = "COALESCE(ws.Doctor_Employee_ID,ws.Specialist_Employee_ID,ws.Staff_Employee_ID) = COALESCE(anchor.Doctor_Employee_ID,anchor.Specialist_Employee_ID,anchor.Staff_Employee_ID) "
            + "AND ws.Work_Date = anchor.Work_Date "
            + "AND CASE WHEN ws.Start_Time < '12:00' THEN 0 ELSE 1 END = "
            + "CASE WHEN anchor.Start_Time < '12:00' THEN 0 ELSE 1 END";
    public static final String NO_PENDING_LEAVE = "NOT EXISTS (SELECT 1 FROM Leave_Cancel_Request lr "
            + "JOIN Work_Schedule anchor ON anchor.Schedule_ID = lr.Schedule_ID "
            + "WHERE lr.request_status = 'Pending' AND " + SAME_SHIFT + ")";

    private final DateTimeFormatter dateTimeFmt = DateTimeFormatter.ofPattern("HH:mm • dd/MM/yyyy");
    private final DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public List<LeaveCancelRequest> getAllRequests(String statusFilter, String roleFilter) {
        List<LeaveCancelRequest> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT lcr.Request_ID, lcr.Schedule_ID, lcr.Requester_Employee_ID, lcr.Approved_By_Employee_ID, " +
            "       lcr.leave_Date, lcr.Reason, lcr.request_status, lcr.created_at, lcr.approved_at, " +
            "       req.Full_Name AS Requester_Name, req.Phone AS Requester_Phone, req.Specialty AS Requester_Specialty, " +
            "       rm.Room_Name, " +
            "       LOWER(r.Role_Name) AS Requester_Role, r.Role_Name AS Requester_Role_Raw, " +
            "       CASE WHEN ws.Start_Time < '12:00' THEN N'Buổi sáng' ELSE N'Buổi chiều' END AS Slot, CONVERT(VARCHAR(5), shift.Start_Time, 108) AS Start_Time_Str, CONVERT(VARCHAR(5), shift.End_Time, 108) AS End_Time_Str, ws.Status AS Schedule_Status, " +
            "       (SELECT COUNT(*) FROM Appointment aa JOIN Work_Schedule ww ON ww.Schedule_ID=aa.Schedule_ID WHERE ww.Doctor_Employee_ID=ws.Doctor_Employee_ID AND ww.Work_Date=ws.Work_Date AND CASE WHEN ww.Start_Time<'12:00' THEN 0 ELSE 1 END=CASE WHEN ws.Start_Time<'12:00' THEN 0 ELSE 1 END AND aa.Status IN ('Pending','Confirmed')) AS Affected_Count, " +
            "       app.Full_Name AS Approver_Name " +
            "FROM Leave_Cancel_Request lcr " +
            "JOIN Employee_Profile req ON lcr.Requester_Employee_ID = req.Employee_ID " +
            "JOIN Account a ON req.Account_ID = a.Account_ID " +
            "JOIN Role r ON a.Role_ID = r.Role_ID " +
            "LEFT JOIN Room rm ON req.Room_ID = rm.Room_ID " +
            "JOIN Work_Schedule ws ON lcr.Schedule_ID = ws.Schedule_ID " +
            "CROSS APPLY (SELECT MIN(w.Start_Time) AS Start_Time,MAX(w.End_Time) AS End_Time FROM Work_Schedule w WHERE COALESCE(w.Doctor_Employee_ID,w.Specialist_Employee_ID,w.Staff_Employee_ID)=COALESCE(ws.Doctor_Employee_ID,ws.Specialist_Employee_ID,ws.Staff_Employee_ID) AND w.Work_Date=ws.Work_Date AND CASE WHEN w.Start_Time<'12:00' THEN 0 ELSE 1 END=CASE WHEN ws.Start_Time<'12:00' THEN 0 ELSE 1 END) shift " +
            "LEFT JOIN Employee_Profile app ON lcr.Approved_By_Employee_ID = app.Employee_ID " +

            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND lcr.request_status = ? ");
            params.add(statusFilter);
        }
        if (roleFilter != null && !roleFilter.isEmpty() && !"all".equalsIgnoreCase(roleFilter)) {
            if ("doctor".equalsIgnoreCase(roleFilter)) {
                sql.append("AND r.Role_Name = 'Doctor' ");
            } else if ("specialist".equalsIgnoreCase(roleFilter) || "medical_specialist".equalsIgnoreCase(roleFilter)) {
                sql.append("AND r.Role_Name = 'Medical_Specialist' ");
            } else if ("staff".equalsIgnoreCase(roleFilter)) {
                sql.append("AND r.Role_Name = 'Staff' ");
            }
        }

        sql.append("ORDER BY CASE WHEN lcr.request_status = 'Pending' THEN 1 ELSE 2 END, lcr.Request_ID DESC");

        try (Connection conn = connections.open();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeaveCancelRequest req = new LeaveCancelRequest();
                    req.setRequestId(rs.getInt("Request_ID"));
                    req.setAffectedCount(rs.getInt("Affected_Count"));

                    req.setScheduleId(rs.getInt("Schedule_ID"));
                    req.setRequesterEmployeeId(rs.getInt("Requester_Employee_ID"));
                    req.setRequesterName(rs.getString("Requester_Name"));
                    String roleKey = rs.getString("Requester_Role");
                    req.setRequesterRole(roleKey);
                    
                    String roleNameVn = "Nhân viên";
                    if ("doctor".equals(roleKey)) roleNameVn = "Bác sĩ";
                    else if ("medical_specialist".equals(roleKey) || "specialist".equals(roleKey)) roleNameVn = "Bác sĩ phẫu thuật";
                    req.setRequesterRoleName(roleNameVn);

                    req.setRequesterPhone(rs.getString("Requester_Phone") != null ? rs.getString("Requester_Phone") : "Chưa cập nhật");
                    req.setRequesterSpecialty(rs.getString("Requester_Specialty") != null ? rs.getString("Requester_Specialty") : "Chung");
                    req.setRoomName(rs.getString("Room_Name") != null ? rs.getString("Room_Name") : "Chưa xếp phòng");

                    int appBy = rs.getInt("Approved_By_Employee_ID");
                    if (!rs.wasNull()) {
                        req.setApprovedByEmployeeId(appBy);
                    }
                    req.setApproverName(rs.getString("Approver_Name") != null ? rs.getString("Approver_Name") : "Chưa duyệt");

                    java.sql.Date ld = rs.getDate("leave_Date");
                    req.setLeaveDate(ld != null ? dateFmt.format(ld.toLocalDate()) : "");
                    req.setSlotName(rs.getString("Slot"));
                    req.setStartTime(rs.getString("Start_Time_Str"));
                    req.setEndTime(rs.getString("End_Time_Str"));
                    req.setScheduleStatus(rs.getString("Schedule_Status"));
                    req.setReason(rs.getString("Reason"));
                    req.setRequestStatus(rs.getString("request_status"));

                    Timestamp ca = rs.getTimestamp("created_at");
                    req.setCreatedAt(ca != null ? dateTimeFmt.format(ca.toLocalDateTime()) : "");
                    Timestamp aa = rs.getTimestamp("approved_at");
                    req.setApprovedAt(aa != null ? dateTimeFmt.format(aa.toLocalDateTime()) : "---");

                    list.add(req);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", 0);
        stats.put("pending", 0);
        stats.put("approved", 0);
        stats.put("rejected", 0);

        String sql = "SELECT request_status, COUNT(*) AS Cnt FROM Leave_Cancel_Request GROUP BY request_status";
        try (Connection conn = connections.open();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int total = 0;
            while (rs.next()) {
                String st = rs.getString("request_status");
                int cnt = rs.getInt("Cnt");
                total += cnt;
                if ("Pending".equalsIgnoreCase(st)) {
                    stats.put("pending", cnt);
                } else if ("Approved".equalsIgnoreCase(st)) {
                    stats.put("approved", cnt);
                } else if ("Rejected".equalsIgnoreCase(st)) {
                    stats.put("rejected", cnt);
                }
            }
            stats.put("total", total);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public LeaveCancelRequest getRequestById(int requestId) {
        String sql = "SELECT lcr.Request_ID, lcr.Schedule_ID, lcr.Requester_Employee_ID, lcr.Approved_By_Employee_ID, " +
                     "       lcr.leave_Date, lcr.Reason, lcr.request_status, lcr.created_at, lcr.approved_at, " +
                     "       req.Full_Name AS Requester_Name, req.Phone AS Requester_Phone, req.Specialty AS Requester_Specialty, " +
                     "       rm.Room_Name, " +
                     "       LOWER(r.Role_Name) AS Requester_Role, " +
                     "       ws.Slot, CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, ws.Status AS Schedule_Status, " +
                     "       app.Full_Name AS Approver_Name " +
                     "FROM Leave_Cancel_Request lcr " +
                     "JOIN Employee_Profile req ON lcr.Requester_Employee_ID = req.Employee_ID " +
                     "JOIN Account a ON req.Account_ID = a.Account_ID " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Room rm ON req.Room_ID = rm.Room_ID " +
                     "JOIN Work_Schedule ws ON lcr.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile app ON lcr.Approved_By_Employee_ID = app.Employee_ID " +
                     "WHERE lcr.Request_ID = ?";
        try (Connection conn = connections.open();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LeaveCancelRequest req = new LeaveCancelRequest();
                    req.setRequestId(rs.getInt("Request_ID"));
                    req.setScheduleId(rs.getInt("Schedule_ID"));
                    req.setRequesterEmployeeId(rs.getInt("Requester_Employee_ID"));
                    req.setRequesterName(rs.getString("Requester_Name"));
                    String roleKey = rs.getString("Requester_Role");
                    req.setRequesterRole(roleKey);
                    
                    String roleNameVn = "Nhân viên";
                    if ("doctor".equals(roleKey)) roleNameVn = "Bác sĩ";
                    else if ("medical_specialist".equals(roleKey) || "specialist".equals(roleKey)) roleNameVn = "Bác sĩ phẫu thuật";
                    req.setRequesterRoleName(roleNameVn);

                    req.setRequesterPhone(rs.getString("Requester_Phone") != null ? rs.getString("Requester_Phone") : "Chưa cập nhật");
                    req.setRequesterSpecialty(rs.getString("Requester_Specialty") != null ? rs.getString("Requester_Specialty") : "Chung");
                    req.setRoomName(rs.getString("Room_Name") != null ? rs.getString("Room_Name") : "Chưa xếp phòng");

                    int appBy = rs.getInt("Approved_By_Employee_ID");
                    if (!rs.wasNull()) {
                        req.setApprovedByEmployeeId(appBy);
                    }
                    req.setApproverName(rs.getString("Approver_Name") != null ? rs.getString("Approver_Name") : "Chưa duyệt");

                    java.sql.Date ld = rs.getDate("leave_Date");
                    req.setLeaveDate(ld != null ? dateFmt.format(ld.toLocalDate()) : "");
                    req.setSlotName(rs.getString("Slot"));
                    req.setStartTime(rs.getString("Start_Time_Str"));
                    req.setEndTime(rs.getString("End_Time_Str"));
                    req.setScheduleStatus(rs.getString("Schedule_Status"));
                    req.setReason(rs.getString("Reason"));
                    req.setRequestStatus(rs.getString("request_status"));

                    Timestamp ca = rs.getTimestamp("created_at");
                    req.setCreatedAt(ca != null ? dateTimeFmt.format(ca.toLocalDateTime()) : "");
                    Timestamp aa = rs.getTimestamp("approved_at");
                    req.setApprovedAt(aa != null ? dateTimeFmt.format(aa.toLocalDateTime()) : "---");
                    return req;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean approveRequest(int requestId, int directorEmployeeId) {
        try (Connection c = connections.open()) {
            c.setAutoCommit(false);
            try {
                int anchorId, doctorId;

                try (PreparedStatement p=c.prepareStatement("SELECT Schedule_ID,Requester_Employee_ID FROM Leave_Cancel_Request WITH (UPDLOCK,HOLDLOCK) WHERE Request_ID=? AND request_status='Pending'")) {
                    p.setInt(1,requestId);
                    try(ResultSet r=p.executeQuery()) { if(!r.next()){c.rollback();return false;} anchorId=r.getInt(1);doctorId=r.getInt(2); }
                }
                List<Integer> ids=lockFutureShift(c,anchorId,doctorId);
                if(ids.isEmpty()){c.rollback();return false;}
                int role=getEmployeeRole(c,doctorId);
                if(role!=3 && role!=4) {c.rollback();return false;}
                try(PreparedStatement p=c.prepareStatement("UPDATE Work_Schedule SET Status='On_Leave' WHERE Schedule_ID=?")) {
                    for(int id:ids){p.setInt(1,id);p.executeUpdate();}
                }
                try(PreparedStatement p=c.prepareStatement("UPDATE Leave_Cancel_Request SET request_status='Approved',Approved_By_Employee_ID=?,approved_at=SYSUTCDATETIME() WHERE Request_ID=? AND request_status='Pending'")) {
                    p.setInt(1,directorEmployeeId);p.setInt(2,requestId);if(p.executeUpdate()!=1){c.rollback();return false;}
                }
                c.commit();return true;
            } catch(Exception e){c.rollback();throw e;} finally{c.setAutoCommit(true);}
        } catch(Exception e){e.printStackTrace();return false;}
    }

    private List<Integer> lockFutureShift(Connection c,int scheduleId,int doctorId) throws SQLException {
        List<Integer> ids=new ArrayList<>();
        String sql="SELECT ws.Schedule_ID,ws.Status, "
            + "CASE WHEN DATEADD(MINUTE,DATEDIFF(MINUTE,CAST('00:00' AS time),ws.Start_Time),CAST(ws.Work_Date AS datetime2))<=DATEADD(HOUR,7,SYSUTCDATETIME()) THEN 1 ELSE 0 END AS Started, "
            + "CASE WHEN EXISTS(SELECT 1 FROM Appointment a WITH (UPDLOCK,HOLDLOCK) WHERE a.Schedule_ID=ws.Schedule_ID "
            + "AND (a.checkin_time IS NOT NULL OR a.Status IN ('In_Progress','Completed'))) THEN 1 ELSE 0 END AS HasClinicalWork "
            + "FROM Work_Schedule ws WITH (UPDLOCK,HOLDLOCK) JOIN Work_Schedule anchor ON anchor.Schedule_ID=? WHERE "
            + SAME_SHIFT + " AND COALESCE(ws.Doctor_Employee_ID,ws.Specialist_Employee_ID,ws.Staff_Employee_ID)=? ORDER BY ws.Schedule_ID";
        try(PreparedStatement p=c.prepareStatement(sql)) {
            p.setInt(1,scheduleId);p.setInt(2,doctorId);
            try(ResultSet r=p.executeQuery()) {while(r.next()) {
                if(r.getInt("Started")==1 || r.getInt("HasClinicalWork")==1
                    || !("Available".equals(r.getString("Status"))||"Booked".equals(r.getString("Status"))))
                    throw new SQLException("Buổi làm việc đã bắt đầu, đã tiếp đón bệnh nhân hoặc không còn khả dụng.");
                ids.add(r.getInt("Schedule_ID"));
            }}
        }
        return ids;
    }

    public boolean rejectRequest(int requestId,int directorEmployeeId,String reason) {
        if(reason==null||reason.trim().isEmpty()||reason.length()>2000)return false;
        try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(
            "UPDATE Leave_Cancel_Request SET request_status='Rejected',Approved_By_Employee_ID=?,approved_at=SYSUTCDATETIME(),Reason=Reason+N' [Lý do từ chối: '+?+N']' WHERE Request_ID=? AND request_status='Pending'")) {
            p.setInt(1,directorEmployeeId);p.setNString(2,reason.trim());p.setInt(3,requestId);return p.executeUpdate()==1;
        } catch(Exception e){e.printStackTrace();return false;}
    }

    public boolean createRequest(int scheduleId,int employeeId,String ignoredDate,String reason,int reviewedCount,boolean impactConfirmed) {
        if(reason==null||reason.trim().isEmpty()||reason.length()>2000)return false;
        try(Connection c=connections.open()) {
            c.setAutoCommit(false);
            try {
                List<Integer> ids=lockFutureShift(c,scheduleId,employeeId);
                if(ids.isEmpty()){c.rollback();return false;}
                int role=getEmployeeRole(c,employeeId);

                if(!Arrays.asList(3,4).contains(role)){c.rollback();return false;}
                if(role==3) {
                    String impactSql="SELECT COUNT(*) FROM Appointment a WITH (UPDLOCK,HOLDLOCK) "
                        + "JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID JOIN Work_Schedule anchor ON anchor.Schedule_ID=? "
                        + "WHERE " + SAME_SHIFT + " AND ws.Doctor_Employee_ID=? AND a.Status IN ('Pending','Confirmed')";
                    try(PreparedStatement p=c.prepareStatement(impactSql)) {
                        p.setInt(1,scheduleId);p.setInt(2,employeeId);
                        try(ResultSet r=p.executeQuery()) {
                            if(!r.next()){c.rollback();return false;}
                            int currentCount=r.getInt(1);
                            if(currentCount!=reviewedCount||(currentCount>0&&!impactConfirmed)){c.rollback();return false;}
                        }
                    }
                }
                try(PreparedStatement p=c.prepareStatement("SELECT lr.Request_ID FROM Leave_Cancel_Request lr JOIN Work_Schedule anchor ON anchor.Schedule_ID=lr.Schedule_ID JOIN Work_Schedule ws ON ws.Schedule_ID=? WHERE " + SAME_SHIFT + " AND lr.request_status IN ('Pending','Approved')")) {
                    p.setInt(1,scheduleId);try(ResultSet r=p.executeQuery()){if(r.next()){c.rollback();return false;}}
                }
                String insertSql="INSERT INTO Leave_Cancel_Request(Schedule_ID,Requester_Employee_ID,leave_Date,Reason,request_status,created_at) SELECT Schedule_ID,?,Work_Date,?,'Pending',SYSUTCDATETIME() FROM Work_Schedule WHERE Schedule_ID=?";
                try(PreparedStatement p=c.prepareStatement(insertSql)) {
                    p.setInt(1,employeeId);p.setNString(2,reason.trim());p.setInt(3,ids.get(0));
                    if(p.executeUpdate()!=1){c.rollback();return false;}
                }
                c.commit();return true;
            } catch(Exception e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
        } catch(Exception e){e.printStackTrace();return false;}
    }

    private int getEmployeeRole(Connection c,int employeeId) throws SQLException {
        try(PreparedStatement p=c.prepareStatement("SELECT a.Role_ID FROM Employee_Profile e JOIN Account a ON a.Account_ID=e.Account_ID WHERE e.Employee_ID=? AND a.Account_Status='Active'")) {
            p.setInt(1,employeeId);try(ResultSet r=p.executeQuery()){return r.next()?r.getInt(1):0;}
        }
    }

    public List<Map<String,Object>> getAvailableShifts(int employeeId) throws Exception {
        String sql="WITH shifts AS (SELECT MIN(ws.Schedule_ID) AS scheduleId,ws.Work_Date AS workDate, "
            + "CASE WHEN ws.Start_Time<'12:00' THEN N'Sáng' ELSE N'Chiều' END AS shiftName, MIN(ws.Start_Time) AS startTime,MAX(ws.End_Time) AS endTime, "
            + "COUNT(*) AS slotCount FROM Work_Schedule ws WHERE COALESCE(ws.Doctor_Employee_ID,ws.Specialist_Employee_ID,ws.Staff_Employee_ID)=? AND ws.Status IN ('Available','Booked') AND " + NO_PENDING_LEAVE
            + " GROUP BY ws.Work_Date,CASE WHEN ws.Start_Time<'12:00' THEN N'Sáng' ELSE N'Chiều' END "
            + "HAVING DATEADD(MINUTE,DATEDIFF(MINUTE,CAST('00:00' AS time),MIN(ws.Start_Time)),CAST(ws.Work_Date AS datetime2))>DATEADD(HOUR,7,SYSUTCDATETIME())) "
            + "SELECT shifts.*, (SELECT COUNT(*) FROM Appointment a JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
            + "JOIN Work_Schedule anchor ON anchor.Schedule_ID=shifts.scheduleId WHERE " + SAME_SHIFT
            + " AND a.Status IN ('Pending','Confirmed')) AS affectedCount FROM shifts ORDER BY workDate,startTime";
        try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,employeeId);return maps(p);}
    }

    public List<Map<String,Object>> getAffectedAppointments(int anchorId,int doctorId) throws Exception {
        String sql="SELECT a.Appointment_ID AS id,p.Full_Name AS patientName,p.Phone AS phone,ws.Start_Time AS startTime,a.Status AS status "
            + "FROM Appointment a JOIN Patient p ON p.Patient_ID=a.Patient_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
            + "JOIN Work_Schedule anchor ON anchor.Schedule_ID=? WHERE " + SAME_SHIFT
            + " AND ws.Doctor_Employee_ID=? AND a.Status IN ('Pending','Confirmed') ORDER BY ws.Start_Time,a.Appointment_ID";
        try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,anchorId);p.setInt(2,doctorId);return maps(p);}
    }

    private List<Map<String,Object>> maps(PreparedStatement p) throws SQLException {
        List<Map<String,Object>> rows=new ArrayList<>();
        try(ResultSet r=p.executeQuery()){ResultSetMetaData m=r.getMetaData();while(r.next()) {
            Map<String,Object> row=new LinkedHashMap<>();for(int i=1;i<=m.getColumnCount();i++)row.put(m.getColumnLabel(i),r.getObject(i));rows.add(row);
        }}return rows;
    }
}
