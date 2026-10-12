<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!-- Employee Top Header -->
<header class="top-header">
    <div class="header-right ms-auto">
        <div class="dropdown">
            <div class="user-profile" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="avatar-circle">
                    <c:choose>
                        <c:when test="${sessionScope.user.role == 'doctor'}">BS</c:when>
                        <c:when test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist'}">KT</c:when>
                        <c:when test="${sessionScope.user.role == 'staff'}">LT</c:when>
                        <c:otherwise>NV</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-info">
                    <p class="name">
                        <c:out value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Nhân sự'}" />
                    </p>
                    <p class="role">
                        <c:choose>
                            <c:when test="${sessionScope.user.role == 'doctor'}">Bác sĩ</c:when>
                            <c:when test="${sessionScope.user.role == 'medical_specialist' || sessionScope.user.role == 'specialist'}">Kỹ thuật viên</c:when>
                            <c:when test="${sessionScope.user.role == 'staff'}">Lễ tân</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <i class="bi bi-chevron-down" style="font-size: 12px; color: #64748b; margin-left: 4px;"></i>
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
