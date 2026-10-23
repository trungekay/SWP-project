package com.visioncare.dao;

import com.visioncare.model.LeaveCancelRequest;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class LeaveCancelRequestDAO {

    private final SimpleDateFormat dateTimeFmt = new SimpleDateFormat("HH:mm • dd/MM/yyyy");
    private final SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");

    public List<LeaveCancelRequest> getAllRequests(String statusFilter, String roleFilter) {
        List<LeaveCancelRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT lcr.Request_ID, lcr.Schedule_ID, lcr.Requester_Employee_ID, lcr.Approved_By_Employee_ID, " +
            "       lcr.leave_Date, lcr.Reason, lcr.request_status, lcr.created_at, lcr.approved_at, " +
            "       req.Full_Name AS Requester_Name, req.Phone AS Requester_Phone, req.Specialty AS Requester_Specialty, " +
            "       rm.Room_Name, " +
            "       LOWER(r.Role_Name) AS Requester_Role, r.Role_Name AS Requester_Role_Raw, " +
            "       ws.Slot, CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, ws.Status AS Schedule_Status, " +
            "       app.Full_Name AS Approver_Name " +
            "FROM Leave_Cancel_Request lcr " +
            "JOIN Employee_Profile req ON lcr.Requester_Employee_ID = req.Employee_ID " +
            "JOIN Account a ON req.Account_ID = a.Account_ID " +
            "JOIN Role r ON a.Role_ID = r.Role_ID " +
            "LEFT JOIN Room rm ON req.Room_ID = rm.Room_ID " +
            "JOIN Work_Schedule ws ON lcr.Schedule_ID = ws.Schedule_ID " +
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

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeaveCancelRequest req = new LeaveCancelRequest();
                    req.setRequestId(rs.getInt("Request_ID"));
                    req.setScheduleId(rs.getInt("Schedule_ID"));
                    req.setRequesterEmployeeId(rs.getInt("Requester_Employee_ID"));
                    req.setRequesterName(rs.getString("Requester_Name"));
                    String roleKey = rs.getString("Requester_Role");
                    req.setRequesterRole(roleKey);
                    
                    String roleNameVn = "Nhân viên";
                    if ("doctor".equals(roleKey)) roleNameVn = "Bác sĩ";
                    else if ("medical_specialist".equals(roleKey) || "specialist".equals(roleKey)) roleNameVn = "Kỹ thuật viên / Chuyên viên";
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
                    req.setLeaveDate(ld != null ? dateFmt.format(ld) : "");
                    req.setSlotName(rs.getString("Slot"));
                    req.setStartTime(rs.getString("Start_Time_Str"));
                    req.setEndTime(rs.getString("End_Time_Str"));
                    req.setScheduleStatus(rs.getString("Schedule_Status"));
                    req.setReason(rs.getString("Reason"));
                    req.setRequestStatus(rs.getString("request_status"));

                    Timestamp ca = rs.getTimestamp("created_at");
                    req.setCreatedAt(ca != null ? dateTimeFmt.format(ca) : "");
                    Timestamp aa = rs.getTimestamp("approved_at");
                    req.setApprovedAt(aa != null ? dateTimeFmt.format(aa) : "---");

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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
                    else if ("medical_specialist".equals(roleKey) || "specialist".equals(roleKey)) roleNameVn = "Kỹ thuật viên / Chuyên viên";
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
                    req.setLeaveDate(ld != null ? dateFmt.format(ld) : "");
                    req.setSlotName(rs.getString("Slot"));
                    req.setStartTime(rs.getString("Start_Time_Str"));
                    req.setEndTime(rs.getString("End_Time_Str"));
                    req.setScheduleStatus(rs.getString("Schedule_Status"));
                    req.setReason(rs.getString("Reason"));
                    req.setRequestStatus(rs.getString("request_status"));

                    Timestamp ca = rs.getTimestamp("created_at");
                    req.setCreatedAt(ca != null ? dateTimeFmt.format(ca) : "");
                    Timestamp aa = rs.getTimestamp("approved_at");
                    req.setApprovedAt(aa != null ? dateTimeFmt.format(aa) : "---");
                    return req;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean approveRequest(int requestId, int directorEmployeeId) {
        String findScheduleSql = "SELECT Schedule_ID FROM Leave_Cancel_Request WHERE Request_ID = ? AND request_status = 'Pending'";
        String updateReqSql = "UPDATE Leave_Cancel_Request SET request_status = 'Approved', Approved_By_Employee_ID = ?, approved_at = SYSUTCDATETIME() WHERE Request_ID = ? AND request_status = 'Pending'";
        String updateScheduleSql = "UPDATE Work_Schedule SET Status = 'On_Leave' WHERE Schedule_ID = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int scheduleId = -1;
                try (PreparedStatement psFind = conn.prepareStatement(findScheduleSql)) {
                    psFind.setInt(1, requestId);
                    try (ResultSet rs = psFind.executeQuery()) {
                        if (rs.next()) {
                            scheduleId = rs.getInt("Schedule_ID");
                        }
                    }
                }

                if (scheduleId == -1) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement psReq = conn.prepareStatement(updateReqSql)) {
                    psReq.setInt(1, directorEmployeeId);
                    psReq.setInt(2, requestId);
                    int affected = psReq.executeUpdate();
                    if (affected != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement psWs = conn.prepareStatement(updateScheduleSql)) {
                    psWs.setInt(1, scheduleId);
                    psWs.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean rejectRequest(int requestId, int directorEmployeeId, String rejectReason) {
        String sql = "UPDATE Leave_Cancel_Request SET request_status = 'Rejected', Approved_By_Employee_ID = ?, approved_at = SYSUTCDATETIME(), " +
                     "Reason = CASE WHEN ? IS NOT NULL AND LEN(?) > 0 THEN Reason + N' [Giám đốc từ chối: ' + ? + N']' ELSE Reason END " +
                     "WHERE Request_ID = ? AND request_status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, directorEmployeeId);
            ps.setString(2, rejectReason);
            ps.setString(3, rejectReason);
            ps.setString(4, rejectReason);
            ps.setInt(5, requestId);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createRequest(int scheduleId, int requesterEmployeeId, String leaveDate, String reason) {
        String sql = "INSERT INTO Leave_Cancel_Request (Schedule_ID, Requester_Employee_ID, leave_Date, Reason, request_status, created_at) " +
                     "VALUES (?, ?, ?, ?, 'Pending', SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            ps.setInt(2, requesterEmployeeId);
            ps.setString(3, leaveDate);
            ps.setString(4, reason != null ? reason : "Bận việc đột xuất");
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
