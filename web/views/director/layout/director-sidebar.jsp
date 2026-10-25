<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
.director-request-toggle { display:flex; align-items:center; gap:12px; width:100%; padding:14px 16px; border:0; border-radius:10px; background:transparent; color:#64748b; text-align:left; font:inherit; cursor:pointer; }
.director-request-toggle.active, .director-request-toggle:hover { color:#008b74; background:#f0f7f6; }
.director-request-menu { list-style:none; padding:4px 0 6px 14px; margin:0; }
.director-request-menu[hidden] { display:none !important; }
.director-request-menu a { font-size:13px; }
</style>
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
            <button type="button" class="director-request-toggle ${param.activeNav == 'refunds' || param.activeNav == 'reschedule-requests' ? 'active' : ''}"
                    aria-controls="director-request-menu" aria-expanded="${param.activeNav == 'refunds' || param.activeNav == 'reschedule-requests'}"
                    onclick="var menu=document.getElementById('director-request-menu'); menu.hidden=!menu.hidden; this.setAttribute('aria-expanded', String(!menu.hidden));">
                <i class="bi bi-inbox"></i><span>Quản lý yêu cầu</span><i class="bi bi-chevron-down ms-auto"></i>
            </button>
            <ul id="director-request-menu" class="director-request-menu" ${param.activeNav == 'refunds' || param.activeNav == 'reschedule-requests' ? '' : 'hidden'}>
                <li><a href="${pageContext.request.contextPath}/director/refunds" class="${param.activeNav == 'refunds' ? 'active' : ''}">
                    <i class="bi bi-cash-coin"></i><span>Quản lý yêu cầu hoàn tiền</span>
                    <c:if test="${not empty pendingRefundCount && pendingRefundCount > 0}"><span class="badge bg-warning text-dark rounded-pill ms-auto">${pendingRefundCount}</span></c:if>
                </a></li>
                <li><a href="${pageContext.request.contextPath}/director/reschedule-requests" class="${param.activeNav == 'reschedule-requests' ? 'active' : ''}">
                    <i class="bi bi-calendar2-week"></i><span>Quản lý yêu cầu đổi lịch</span>
                </a></li>
            </ul>
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
