<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>
    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="${param.activeNav == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-graph-up"></i>
                Dashboard Doanh thu
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/users" class="${param.activeNav == 'users' ? 'active' : ''}">
                <i class="bi bi-person"></i>
                Quản lý Người dùng
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/clinic-config" class="${param.activeNav == 'config' ? 'active' : ''}">
                <i class="bi bi-gear"></i>
                Cấu hình Phòng Khám
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/catalog" class="${param.activeNav == 'catalog' ? 'active' : ''}">
                <i class="bi bi-box"></i>
                Quản lý Danh mục (Dịch vụ/Vật tư)
            </a>
        </li>
    </ul>
</aside>
