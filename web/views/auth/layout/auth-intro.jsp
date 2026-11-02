<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<aside class="auth-context" aria-label="Thông tin tài khoản VisionCare">
<div class="auth-context-mark"><i class="bi bi-eye" aria-hidden="true"></i></div><p class="auth-context-kicker">VisionCare · Tài khoản của bạn</p>
<h2><c:out value="${param.screenTitle}" /></h2><p><c:out value="${param.screenDescription}" /></p>
<ul><li><i class="bi bi-calendar2-check" aria-hidden="true"></i><div><strong>Quản lý lịch khám</strong><span>Theo dõi lịch hẹn và chọn ca phù hợp.</span></div></li><li><i class="bi bi-file-earmark-medical" aria-hidden="true"></i><div><strong>Hồ sơ và hóa đơn</strong><span>Tra cứu thông tin khám và thanh toán.</span></div></li><li><i class="bi bi-person-check" aria-hidden="true"></i><div><strong>Thông tin cá nhân</strong><span>Cập nhật thông tin liên hệ của bạn.</span></div></li></ul>
</aside>
