<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Older deployed leave controllers still forward here. Keep their doctor view
// separate from the retired director rescheduling page during redeployment.
com.visioncare.model.User leaveUser = (com.visioncare.model.User) session.getAttribute("user");
if (Boolean.TRUE.equals(request.getAttribute("ownLeave")) && leaveUser != null
        && (leaveUser.getRoleId() == 3 || leaveUser.getRoleId() == 4)) {
    request.getRequestDispatcher("/views/employee/leave-requests.jsp").forward(request, response);
    return;
}
response.sendRedirect(request.getContextPath() + "/director/dashboard");
%>
