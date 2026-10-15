<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <!-- Staff Sidebar -->
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/home" class="sidebar-brand">
            <span class="logo-mark"><i class="bi bi-eye"></i></span>
            <span class="brand-text">VisionCare</span>
        </a>
        <div style="padding: 10px 24px; font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.8px;">
            Bộ phận Tiếp đón & Lễ tân
        </div>
        <ul class="sidebar-menu">
            <li>
                <a href="${pageContext.request.contextPath}/staff/appointments" class="${param.activeNav == 'appointments' ? 'active' : ''}">
                    <i class="bi bi-calendar-check"></i>
                    <span>Danh sách Lịch hẹn</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/staff/waiting-list" class="${param.activeNav == 'waiting-list' ? 'active' : ''}">
                    <i class="bi bi-people"></i>
                    <span>Hàng đợi phòng khám</span>
                </a>
            </li>
            <li style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #f1f5f9;">
                <div style="padding: 4px 10px 10px 10px; font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.8px;">
                    Lịch cá nhân
                </div>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/employee/schedule" class="${param.activeNav == 'schedule' ? 'active' : ''}">
                    <i class="bi bi-clock-history"></i>
                    <span>Lịch làm việc của tôi</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/employee/register-schedule" class="${param.activeNav == 'register-schedule' ? 'active' : ''}">
                    <i class="bi bi-calendar-plus"></i>
                    <span>Đăng ký ca làm việc</span>
                </a>
            </li>
            <li style="margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/home">
                    <i class="bi bi-house-door"></i>
                    <span>Về trang chủ</span>
                </a>
            </li>
        </ul>
    </aside>
