<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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

    /* User Profile Widget Styling Matching Screenshot */
    .header-right .user-profile {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
        padding: 4px 8px;
        border-radius: 8px;
        transition: background-color 0.2s;
    }
    .header-right .user-profile:hover {
        background-color: rgba(0, 139, 116, 0.05);
    }
    .header-right .avatar-circle {
        width: 40px;
        height: 40px;
        min-width: 40px;
        border-radius: 50%;
        background-color: #008b74;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 17px;
        box-shadow: 0 2px 6px rgba(0, 139, 116, 0.2);
    }
    .header-right .user-info {
        display: flex;
        flex-direction: column;
        justify-content: center;
        line-height: 1.25;
        text-align: left;
    }
    .header-right .user-info .name {
        font-weight: 700;
        font-size: 15px;
        color: #003366;
        margin: 0;
        letter-spacing: -0.2px;
    }
    .header-right .user-info .role {
        font-size: 12.5px;
        color: #64748b;
        margin: 0;
        font-weight: 400;
    }
</style>
<!-- Employee Top Header -->
<header class="top-header">
    <div class="header-right ms-auto">
        <div class="dropdown">
            <div class="user-profile" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.fullName}">
                            ${sessionScope.user.fullName.substring(0, 1).toUpperCase()}
                        </c:when>
                        <c:otherwise>L</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-info">
                    <p class="name">
                        <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Lễ Tân Phạm Thị Lan'}" />
                    </p>
                    <p class="role">
                        <c:choose>
                            <c:when test="${sessionScope.user.role == 'admin'}">Quản trị viên (Admin)</c:when>
                            <c:when test="${sessionScope.user.role == 'staff'}">Nhân viên (Staff)</c:when>
                            <c:when test="${sessionScope.user.role == 'doctor'}">Bác sĩ (Doctor)</c:when>
                            <c:when test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist'}">Kỹ thuật viên (Specialist)</c:when>
                            <c:otherwise>Nhân viên (Staff)</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <i class="bi bi-chevron-down" style="font-size: 13px; color: #64748b; margin-left: 4px;"></i>
            </div>
            <ul class="dropdown-menu dropdown-menu-end">
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/views/profile/manage.jsp">
                        <i class="bi bi-person"></i> Hồ sơ cá nhân
                    </a>
                </li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/views/profile/change-password.jsp">
                        <i class="bi bi-key"></i> Đổi mật khẩu
                    </a>
                </li>
                <li><hr class="dropdown-divider my-1"></li>
                <li>
                    <a class="dropdown-item logout-item" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right"></i> Đăng xuất
                    </a>
                </li>
            </ul>
        </div>
    </div>
</header>
