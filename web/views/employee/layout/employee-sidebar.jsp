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

        <c:if test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist'}">
            <li>
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                    <i class="bi bi-clipboard2-pulse"></i>
                    Hàng đợi cận lâm sàng
                </a>
            </li>
        </c:if>

        <c:if test="${sessionScope.user.role == 'doctor'}">
            <li>
                <a href="javascript:void(0);" class="${param.activeNav == 'examination' ? 'active' : ''}" title="Chức năng đang phát triển" style="opacity: 0.85;">
                    <i class="bi bi-file-earmark-medical"></i>
                    Khám bệnh & Bệnh án
                </a>
            </li>
        </c:if>
    </ul>
</aside>
