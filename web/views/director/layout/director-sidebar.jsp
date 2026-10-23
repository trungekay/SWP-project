<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- Director Sidebar -->
<aside class="sidebar">
    <a href="${pageContext.request.contextPath}/director/dashboard" class="sidebar-brand">
        <span class="logo-mark"><i class="bi bi-eye"></i></span>
        <span class="brand-text">VisionCare</span>
    </a>

    <ul class="sidebar-menu">
        <div class="sidebar-menu-header">BAN ĐIỀU HÀNH</div>
        <li>
            <a href="${pageContext.request.contextPath}/director/dashboard" class="${param.activeNav == 'dashboard' ? 'active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>Tổng quan Giám đốc</span>
            </a>
        </li>

        <div class="sidebar-menu-header mt-3">DANH SÁCH & LỊCH LÀM VIỆC</div>
        <li>
            <a href="${pageContext.request.contextPath}/director/doctors" class="${param.activeNav == 'doctors' ? 'active' : ''}">
                <i class="bi bi-person-badge"></i>
                <span>Bác sĩ & Lịch trực</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/director/specialists" class="${param.activeNav == 'specialists' ? 'active' : ''}">
                <i class="bi bi-clipboard2-pulse"></i>
                <span>KTV / Chuyên viên & Lịch</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/director/staffs" class="${param.activeNav == 'staffs' ? 'active' : ''}">
                <i class="bi bi-people"></i>
                <span>Nhân viên & Lịch làm việc</span>
            </a>
        </li>

        <div class="sidebar-menu-header mt-3">XÉT DUYỆT YÊU CẦU</div>
        <li>
            <a href="${pageContext.request.contextPath}/director/leave-requests" class="${param.activeNav == 'leave-requests' ? 'active' : ''}">
                <i class="bi bi-calendar-x"></i>
                <span>Duyệt hủy ca / Nghỉ phép</span>
                <c:if test="${not empty pendingLeaveCount && pendingLeaveCount > 0}">
                    <span class="badge bg-danger rounded-pill ms-auto px-2 py-1">${pendingLeaveCount}</span>
                </c:if>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/director/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                <i class="bi bi-cash-coin"></i>
                <span>Duyệt yêu cầu hoàn tiền</span>
                <c:if test="${not empty pendingRefundCount && pendingRefundCount > 0}">
                    <span class="badge bg-warning text-dark rounded-pill ms-auto px-2 py-1">${pendingRefundCount}</span>
                </c:if>
            </a>
        </li>

        <div class="sidebar-menu-header mt-3">HỆ THỐNG</div>
        <li>
            <a href="${pageContext.request.contextPath}/home">
                <i class="bi bi-house-door"></i>
                <span>Xem trang chủ</span>
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/logout" class="text-danger">
                <i class="bi bi-box-arrow-right text-danger"></i>
                <span class="text-danger">Đăng xuất</span>
            </a>
        </li>
    </ul>
</aside>
