<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<header class="top-header">
    <div class="header-right ms-auto">
        <div class="user-profile">
            <c:set var="initial" value="A" />
            <c:if test="${not empty sessionScope.user and not empty sessionScope.user.fullName}">
                <c:set var="initial" value="${sessionScope.user.fullName.substring(0, 1).toUpperCase()}" />
            </c:if>
            <div class="avatar-circle">${initial}U</div>
            <div class="user-info">
                <p class="name">${not empty sessionScope.user ? sessionScope.user.fullName : 'Administrator'}</p>
                <p class="role">Super Admin</p>
            </div>
            <div class="dropdown ms-2">
                <i class="bi bi-chevron-down" style="font-size: 12px; color: #64748b; cursor: pointer;" data-bs-toggle="dropdown" aria-expanded="false"></i>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </div>
</header>
