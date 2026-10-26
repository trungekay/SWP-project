package com.visioncare.model;

public class LeaveCancelRequest {
    private int requestId;
    private int scheduleId;
    private int requesterEmployeeId;
    private String requesterName;
    private String requesterRole;
    private String requesterRoleName;
    private String requesterPhone;
    private String requesterSpecialty;
    private String roomName;
    private Integer approvedByEmployeeId;
    private String approverName;
    private String leaveDate;
    private String slotName;
    private String startTime;
    private String endTime;
    private String scheduleStatus;
    private String reason;
    private String requestStatus; // 'Pending', 'Approved', 'Rejected'
    private String createdAt;
    private String approvedAt;

    public LeaveCancelRequest() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getRequesterEmployeeId() {
        return requesterEmployeeId;
    }

    public void setRequesterEmployeeId(int requesterEmployeeId) {
        this.requesterEmployeeId = requesterEmployeeId;
    }

    public String getRequesterName() {
        return requesterName;
    }

    public void setRequesterName(String requesterName) {
        this.requesterName = requesterName;
    }

    public String getRequesterRole() {
        return requesterRole;
    }

    public void setRequesterRole(String requesterRole) {
        this.requesterRole = requesterRole;
    }

    public String getRequesterRoleName() {
        return requesterRoleName;
    }

    public void setRequesterRoleName(String requesterRoleName) {
        this.requesterRoleName = requesterRoleName;
    }

    public String getRequesterPhone() {
        return requesterPhone;
    }

    public void setRequesterPhone(String requesterPhone) {
        this.requesterPhone = requesterPhone;
    }

    public String getRequesterSpecialty() {
        return requesterSpecialty;
    }

    public void setRequesterSpecialty(String requesterSpecialty) {
        this.requesterSpecialty = requesterSpecialty;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public Integer getApprovedByEmployeeId() {
        return approvedByEmployeeId;
    }

    public void setApprovedByEmployeeId(Integer approvedByEmployeeId) {
        this.approvedByEmployeeId = approvedByEmployeeId;
    }

    public String getApproverName() {
        return approverName;
    }

    public void setApproverName(String approverName) {
        this.approverName = approverName;
    }

    public String getLeaveDate() {
        return leaveDate;
    }

    public void setLeaveDate(String leaveDate) {
        this.leaveDate = leaveDate;
    }

    public String getSlotName() {
        return slotName;
    }

    public void setSlotName(String slotName) {
        this.slotName = slotName;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getScheduleStatus() {
        return scheduleStatus;
    }

    public void setScheduleStatus(String scheduleStatus) {
        this.scheduleStatus = scheduleStatus;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getRequestStatus() {
        return requestStatus;
    }

    public void setRequestStatus(String requestStatus) {
        this.requestStatus = requestStatus;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(String approvedAt) {
        this.approvedAt = approvedAt;
    }

    public String getStatusBadgeClass() {
        if ("Approved".equalsIgnoreCase(requestStatus)) {
            return "bg-success text-white";
        } else if ("Rejected".equalsIgnoreCase(requestStatus)) {
            return "bg-danger text-white";
        }
        return "bg-warning text-dark";
    }

    public String getStatusVn() {
        if ("Approved".equalsIgnoreCase(requestStatus)) {
            return "Đã chấp nhận";
        } else if ("Rejected".equalsIgnoreCase(requestStatus)) {
            return "Đã từ chối";
        }
        return "Chờ giám đốc duyệt";
    }
}
