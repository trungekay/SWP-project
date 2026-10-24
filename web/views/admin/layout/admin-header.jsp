<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    .header-right .dropdown:hover .dropdown-menu {
        display: block;
        margin-top: 0;
    }
    .header-right .dropdown-menu {
        border: none;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        border-radius: 10px;
        padding: 8px 0;
        min-width: 170px;
        width: fit-content;
        left: 28px;
        right: auto;
        margin-top: 5px;
    }
    .header-right .dropdown-item {
        padding: 8px 18px;
        color: #1e293b;
        font-size: 15px;
        font-weight: 500;
        transition: background-color 0.2s, color 0.2s;
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: 8px;
    }
    .header-right .dropdown-item:hover {
        background-color: #f8fafc;
        color: #008b74;
    }
    .header-right .dropdown-item.logout-item {
        color: #ef4444;
    }
    .header-right .dropdown-item.logout-item:hover {
        background-color: #fef2f2;
        color: #dc2626;
    }
</style>
<header class="top-header">
    <div class="header-right ms-auto">
        <div class="dropdown">
            <div class="user-profile" data-bs-toggle="dropdown" aria-expanded="false" style="cursor: pointer; display: flex; align-items: center; gap: 10px;">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName.substring(0, 1).toUpperCase()}
                        </c:when>
                        <c:otherwise>L</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-info">
                    <p class="name">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Lễ Tân Phạm Thị Lan'}</p>
                    <p class="role">
                        <c:choose>
                            <c:when test="${sessionScope.user.role == 'admin' || sessionScope.user.roleId == 1}">Quản trị viên (Admin)</c:when>
                            <c:when test="${sessionScope.user.role == 'director' || sessionScope.user.roleId == 2}">Giám đốc Điều hành (Director)</c:when>
                            <c:when test="${sessionScope.user.role == 'doctor' || sessionScope.user.roleId == 3}">Bác sĩ (Doctor)</c:when>
                            <c:when test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist' || sessionScope.user.roleId == 4}">Kỹ thuật viên / Chuyên viên (Specialist)</c:when>
                            <c:when test="${sessionScope.user.role == 'staff' || sessionScope.user.roleId == 5}">Nhân viên (Staff)</c:when>
                            <c:otherwise>Giám đốc Điều hành (Director)</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <i class="bi bi-chevron-down" style="font-size: 13px; color: #64748b; margin-left: 4px;"></i>
            </div>
            <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person"></i> Hồ sơ cá nhân</a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key"></i> Đổi mật khẩu</a></li>
                <li><a class="dropdown-item logout-item" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></li>
            </ul>
        </div>
    </div>
</header>
