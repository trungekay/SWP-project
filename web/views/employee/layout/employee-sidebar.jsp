<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- Employee Work Sidebar -->
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/employee/schedule" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                <i class="bi bi-calendar-week"></i>
                Lịch làm việc của tôi
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/employee/register-schedule" class="${param.activeNav == 'register-schedule' ? 'active' : ''}">
                <i class="bi bi-calendar-plus"></i>
                Đăng ký ca làm việc
            </a>
        </li>

        <c:if test="${sessionScope.user.role == 'doctor'}">
            <li>
                <a href="${pageContext.request.contextPath}/doctor/waiting-list" class="${param.activeNav == 'doctor-waiting' || param.activeNav == 'examination' ? 'active' : ''}">
                    <i class="bi bi-people"></i>
                    Hàng đợi khám bệnh
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/views/profile/manage.jsp" class="${param.activeNav == 'profile' ? 'active' : ''}">
                    <i class="bi bi-person-circle"></i>
                    Hồ sơ cá nhân
                </a>
            </li>
        </c:if>

        <c:if test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist' || sessionScope.user.roleId == 4 || sessionScope.user.roleId == 1 || sessionScope.user.roleId == 2}">
            <li>
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                    <i class="bi bi-clipboard2-pulse"></i>
                    Hàng đợi cận lâm sàng
                </a>
            </li>
        </c:if>
    </ul>
</aside>
