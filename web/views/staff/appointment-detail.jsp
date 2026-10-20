<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chi tiết Lịch hẹn #APPT-${appointment.id} - VisionCare</title>
                <!-- Google Fonts -->
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <!-- Bootstrap 5 CSS -->
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <!-- Bootstrap Icons -->
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

                <!-- Employee / Staff Unified Layout CSS -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">
            </head>

            <body>

                <!-- Employee Unified Sidebar -->
                <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
                    <jsp:param name="activeNav" value="appointments" />
                </jsp:include>

                <!-- Main Wrapper -->
                <main class="main-wrapper">
                    <!-- Top Header -->
                    <jsp:include page="/views/employee/layout/employee-header.jsp" />

                    <!-- Page Content -->
                    <div class="page-content">

                        <!-- Flash Messages -->
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="flash-alert flash-alert-success alert-dismissible fade show" role="alert">
                                <div class="flash-alert-icon">
                                    <i class="bi bi-check-lg"></i>
                                </div>
                                <div class="flash-alert-content">
                                    <span class="alert-title">Thành công!</span>${sessionScope.successMessage}
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>
                        <c:if test="${not empty sessionScope.errorMessage}">
                            <div class="flash-alert flash-alert-danger alert-dismissible fade show" role="alert">
                                <div class="flash-alert-icon">
                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                </div>
                                <div class="flash-alert-content">
                                    <span class="alert-title">Thông báo:</span>${sessionScope.errorMessage}
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                            <c:remove var="errorMessage" scope="session" />
                        </c:if>

                        <!-- Navigation Breadcrumb -->
                        <div class="d-flex align-items-center mb-3">
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb mb-0">
                                    <li class="breadcrumb-item"><a
                                            href="${pageContext.request.contextPath}/staff/appointments"
                                            class="text-decoration-none text-muted">Lịch hẹn</a></li>
                                    <li class="breadcrumb-item active fw-semibold text-dark" aria-current="page">Chi
                                        tiết #APPT-${appointment.id}</li>
                                </ol>
                            </nav>
                        </div>

                        <!-- Header Card -->
                        <div class="content-card p-4 mb-4">
                            <div
                                class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="patient-avatar-box" style="width: 56px; height: 56px; font-size: 20px;">
                                        <c:choose>
                                            <c:when test="${not empty appointment.patientName}">
                                                ${appointment.patientName.substring(0, 1).toUpperCase()}
                                            </c:when>
                                            <c:otherwise>BN</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div>
                                        <div class="d-flex align-items-center gap-2 flex-wrap">
                                            <h3 class="mb-0 fw-bold text-dark">${appointment.patientName}</h3>
                                            <span class="badge bg-light text-dark border">#APPT-${appointment.id}</span>
                                            <c:choose>
                                                <c:when test="${appointment.status == 'Pending'}">
                                                    <span class="badge-status badge-pending" title="Chờ tiếp đón tại quầy lễ tân">Chờ tiếp đón</span>
                                                </c:when>
                                                <c:when test="${appointment.status == 'Confirmed' && empty appointment.checkinTime}">
                                                    <span class="badge-status badge-pending" title="Đã xác nhận lịch, chưa check-in tại quầy lễ tân">Chờ tiếp đón</span>
                                                </c:when>
                                                <c:when test="${appointment.status == 'Confirmed'}">
                                                    <span class="badge-status badge-confirmed" title="Đã tiếp đón, đang chờ vào khám">Chờ khám</span>
                                                </c:when>
                                                <c:when test="${appointment.status == 'In_Progress'}">
                                                    <span class="badge-status badge-in-progress" title="Bác sĩ đang thực hiện khám">Đang khám</span>
                                                </c:when>
                                                <c:when test="${appointment.status == 'Completed'}">
                                                    <span class="badge-status badge-completed" title="Ca khám đã hoàn thành">Đã khám xong</span>
                                                </c:when>
                                                <c:when test="${appointment.status == 'Canceled'}">
                                                    <span class="badge-status badge-canceled" title="Lịch hẹn đã hủy / vắng mặt">Đã hủy / Vắng mặt</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-pending">${appointment.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-muted small mt-1 d-flex align-items-center gap-3 flex-wrap">
                                            <span><i class="bi bi-telephone me-1"></i>${appointment.phone}</span>
                                            <span><i class="bi bi-calendar3 me-1"></i>Ngày hẹn:
                                                <strong>${appointment.appointmentDate}</strong></span>
                                            <span><i class="bi bi-clock me-1"></i>Khung giờ:
                                                <strong>${appointment.timeSlot}</strong></span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Quick Action -->
                                <c:set var="currentDateStr"><%= java.time.LocalDate.now().toString() %></c:set>
                                <c:set var="apptDateStr">${appointment.appointmentDate}</c:set>
                                <c:set var="isPastAppt" value="${not empty apptDateStr && apptDateStr < currentDateStr}" />
                                <div class="d-flex align-items-center gap-2">
                                    <c:choose>
                                        <c:when test="${appointment.status == 'Completed'}">
                                            <a href="${pageContext.request.contextPath}/profile/medical-record?id=${appointment.id}"
                                                class="btn btn-teal shadow-sm" target="_blank" title="Xem chi tiết phiếu kết quả khám bệnh">
                                                <i class="bi bi-file-earmark-medical me-1.5"></i> Xem phiếu khám
                                            </a>
                                        </c:when>
                                        <c:when test="${isPastAppt}">
                                            <span class="badge bg-secondary-subtle text-secondary border px-3 py-2 fw-medium" style="font-size: 13px;">
                                                <i class="bi bi-clock-history me-1"></i>Lịch hẹn đã qua ngày (${appointment.appointmentDate})
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <c:if test="${appointment.status == 'Pending'}">
                                                <button type="button" class="btn btn-teal" data-bs-toggle="modal"
                                                    data-bs-target="#checkinModal">
                                                    <i class="bi bi-box-arrow-in-right"></i> Check-in
                                                </button>
                                                <button type="button"
                                                    class="btn btn-outline-danger d-flex align-items-center gap-1"
                                                    data-bs-toggle="modal" data-bs-target="#cancelModal">
                                                    <i class="bi bi-x-circle"></i> Hủy lịch hẹn
                                                </button>
                                            </c:if>
                                            <c:if test="${appointment.status == 'Confirmed'}">
                                                <a href="${pageContext.request.contextPath}/staff/waiting-list"
                                                    class="btn btn-teal-outline">
                                                    <i class="bi bi-people-fill"></i> Xem trong Hàng đợi
                                                </a>
                                            </c:if>
                                            <c:if test="${appointment.status == 'In_Progress'}">
                                                <a href="${pageContext.request.contextPath}/staff/waiting-list"
                                                    class="btn btn-teal-outline">
                                                    <i class="bi bi-people-fill"></i> Xem trong Hàng đợi
                                                </a>
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Two-Column Layout -->
                        <div class="row g-4">
                            <!-- Left Column: Details -->
                            <div class="col-lg-7">
                                <!-- Patient Info Card -->
                                <div class="content-card p-4 mb-4">
                                    <div class="detail-section-title">
                                        <i class="bi bi-person-vcard text-teal"
                                            style="color: var(--primary-color);"></i>
                                        Thông tin Bệnh nhân
                                    </div>
                                    <div class="row g-3">
                                        <div class="col-sm-6">
                                            <div class="info-label">Họ và tên bệnh nhân</div>
                                            <div class="info-value text-dark fw-bold">${appointment.patientName}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Số điện thoại liên hệ</div>
                                            <div class="info-value">
                                                <a href="tel:${appointment.phone}"
                                                    class="text-decoration-none text-dark fw-semibold">
                                                    ${appointment.phone}
                                                </a>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Ngày sinh (DOB)</div>
                                            <div class="info-value">${not empty appointment.dob ? appointment.dob :
                                                'Chưa cập nhật'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Mã hồ sơ bệnh nhân</div>
                                            <div class="info-value">#PT-0${appointment.patientId}</div>
                                        </div>
                                        <div class="col-12">
                                            <div class="info-label">Địa chỉ cư trú</div>
                                            <div class="info-value">${not empty appointment.address ?
                                                appointment.address : 'Chưa có thông tin địa chỉ'}</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Appointment & Schedule Info Card -->
                                <div class="content-card p-4">
                                    <div class="detail-section-title">
                                        <i class="bi bi-calendar-event text-teal"
                                            style="color: var(--primary-color);"></i>
                                        Thông tin Ca khám & Bác sĩ Phụ trách
                                    </div>
                                    <div class="row g-3">
                                        <div class="col-sm-6">
                                            <div class="info-label">Bác sĩ khám</div>
                                            <div class="info-value text-dark fw-bold">${not empty appointment.doctorName
                                                ? appointment.doctorName : 'Chưa phân công'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Chuyên khoa</div>
                                            <div class="info-value">${not empty appointment.department ?
                                                appointment.department : 'Nhãn khoa'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Phòng khám</div>
                                            <div class="info-value">
                                                <c:choose>
                                                    <c:when test="${not empty appointment.roomName}">
                                                        <span
                                                            class="badge bg-light text-dark border px-3 py-2 fw-semibold">
                                                            <i
                                                                class="bi bi-door-open text-success me-1"></i>${appointment.roomName}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>Chưa xếp phòng</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Thời gian hẹn</div>
                                            <div class="info-value">
                                                <strong>${appointment.timeSlot}</strong>
                                                (${appointment.appointmentDate})
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Thời gian Check-in</div>
                                            <div class="info-value">
                                                <c:choose>
                                                    <c:when test="${not empty appointment.checkinTime}">
                                                        <span class="text-success fw-bold">
                                                            <i
                                                                class="bi bi-check2-circle me-1"></i>${appointment.checkinTime}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted">Chưa thực hiện tiếp đón</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Nhân viên tiếp đón (Staff)</div>
                                            <div class="info-value">${not empty appointment.staffName ?
                                                appointment.staffName : 'Chưa có'}</div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Dịch vụ đăng ký khám</div>
                                            <div class="info-value fw-semibold text-teal" style="color: #0d9488;">
                                                <i class="bi bi-tag-fill me-1"></i>${not empty appointment.serviceName ? appointment.serviceName : 'Khám mắt tổng quát & Soi đáy mắt'}
                                            </div>
                                        </div>
                                        <div class="col-sm-6">
                                            <div class="info-label">Phí dịch vụ ban đầu (Tiền cọc)</div>
                                            <div class="info-value d-flex align-items-center gap-2">
                                                <span class="fw-bold text-dark fs-6">
                                                    <fmt:formatNumber value="${appointment.fee > 0 ? appointment.fee : 200000}" type="number" groupingUsed="true" /> ₫
                                                </span>
                                                <c:choose>
                                                    <c:when test="${appointment.invoiceStatus == 'Paid'}">
                                                        <span class="badge bg-success-subtle text-success border border-success-subtle py-1 px-2" style="font-size: 11px;">
                                                            <i class="bi bi-check2-circle me-1"></i>Đã thanh toán (Paid)
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${appointment.invoiceStatus == 'Pending_Deposit'}">
                                                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle py-1 px-2" style="font-size: 11px;">
                                                            <i class="bi bi-clock me-1"></i>Chờ đặt cọc
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-secondary border py-1 px-2" style="font-size: 11px;">
                                                            ${not empty appointment.invoiceStatus ? appointment.invoiceStatus : 'Đã thu cọc'}
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column: Record Medical Notes (Feature for Iter 2) -->
                            <div class="col-lg-5">
                                <c:choose>
                                    <c:when test="${isPastAppt}">
                                        <!-- Khi đã qua ngày: Chỉ hiển thị Ghi chú Y tế dạng Xem (Read-only), không cho phép sửa hoặc thao tác khác -->
                                        <div class="content-card p-4">
                                            <div class="detail-section-title">
                                                <i class="bi bi-journal-medical text-teal" style="color: var(--primary-color);"></i>
                                                Ghi chú Y tế Ban đầu
                                            </div>
                                            <div class="p-2.5 px-3 rounded-3 border mb-3 d-flex align-items-start gap-2" style="background-color: #f8fafc; border-color: #e2e8f0 !important; color: #475569;">
                                                <i class="bi bi-info-circle-fill text-primary mt-0.5" style="font-size: 15px;"></i>
                                                <div style="font-size: 13px; line-height: 1.5;">
                                                    Lịch hẹn đã qua ngày khám (<strong>${appointment.appointmentDate}</strong>). Bạn chỉ có thể xem ghi chú y tế và thông tin hồ sơ, không thể thực hiện thay đổi hoặc tiếp đón.
                                                </div>
                                            </div>

                                            <div class="p-3 rounded-3 border mb-0" style="background-color: #f8fafc; border-color: #e2e8f0 !important;">
                                                <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
                                                    <label class="info-label fw-bold text-dark mb-0 d-flex align-items-center gap-2" style="font-size: 14px;">
                                                        <i class="bi bi-file-earmark-medical-fill" style="color: var(--primary-color, #0d9488); font-size: 17px;"></i>
                                                        <span>Nội dung Ghi chú Y tế</span>
                                                    </label>
                                                    <span class="badge bg-white border text-secondary fw-normal px-2.5 py-1" style="font-size: 11.5px;">
                                                        <i class="bi bi-clock-history text-muted me-1"></i>Hồ sơ lưu trữ
                                                    </span>
                                                </div>

                                                <c:set var="rawNotes" value="${fn:trim(appointment.medicalNotes)}" />
                                                <c:choose>
                                                    <c:when test="${empty rawNotes}">
                                                        <div class="text-center py-4 px-3 rounded-3 bg-white border" style="border-style: dashed !important; border-color: #cbd5e1 !important;">
                                                            <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-2"
                                                                style="width: 42px; height: 42px; background-color: #f1f5f9; color: #94a3b8;">
                                                                <i class="bi bi-journal-x" style="font-size: 20px;"></i>
                                                            </div>
                                                            <p class="mb-1 fw-semibold text-secondary" style="font-size: 13.5px;">Chưa có ghi chú y tế</p>
                                                            <p class="small text-muted mb-0">Ca khám này chưa được ghi nhận triệu chứng ban đầu hoặc dịch vụ chỉ định.</p>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${fn:contains(rawNotes, '|')}">
                                                        <c:forEach var="part" items="${fn:split(rawNotes, '|')}">
                                                            <c:set var="trimmedPart" value="${fn:trim(part)}" />
                                                            <c:if test="${not empty trimmedPart}">
                                                                <c:choose>
                                                                    <c:when test="${fn:contains(trimmedPart, ':')}">
                                                                        <c:set var="itemVal" value="${fn:trim(fn:substringAfter(trimmedPart, ':'))}" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:set var="itemVal" value="${trimmedPart}" />
                                                                    </c:otherwise>
                                                                </c:choose>

                                                                <c:choose>
                                                                    <c:when test="${fn:contains(trimmedPart, 'Dịch vụ') || fn:contains(trimmedPart, 'Bệnh lý')}">
                                                                        <!-- Dịch vụ / Yêu cầu khám -->
                                                                        <div class="p-3 rounded-3 mb-2.5 d-flex align-items-start gap-3 bg-white border shadow-sm"
                                                                            style="border-left: 4px solid #0d9488 !important; border-color: #ccfbf1 #ccfbf1 #ccfbf1 #0d9488;">
                                                                            <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                                                style="width: 36px; height: 36px; background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%); color: #ffffff;">
                                                                                <i class="bi bi-eye-fill" style="font-size: 16px;"></i>
                                                                            </div>
                                                                            <div class="flex-grow-1">
                                                                                <div class="d-flex align-items-center gap-2 mb-1">
                                                                                    <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold"
                                                                                        style="font-size: 11px; letter-spacing: 0.5px; background-color: #ccfbf1; color: #0f766e;">
                                                                                        <i class="bi bi-check2-circle me-1"></i>Dịch vụ chỉ định / Bệnh lý
                                                                                    </span>
                                                                                </div>
                                                                                <div class="fw-bold text-dark" style="font-size: 14.5px; line-height: 1.5; color: #0f172a !important;">
                                                                                    <c:out value="${itemVal}" />
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:when test="${fn:contains(trimmedPart, 'Lý do') || fn:contains(trimmedPart, 'Triệu chứng')}">
                                                                        <!-- Lý do khám & Triệu chứng -->
                                                                        <div class="p-3 rounded-3 mb-2.5 d-flex align-items-start gap-3 bg-white border shadow-sm"
                                                                            style="border-left: 4px solid #3b82f6 !important; border-color: #e2e8f0 #e2e8f0 #e2e8f0 #3b82f6;">
                                                                            <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                                                style="width: 36px; height: 36px; background: linear-gradient(135deg, #2563eb 0%, #3b82f6 100%); color: #ffffff;">
                                                                                <i class="bi bi-chat-square-text-fill" style="font-size: 15px;"></i>
                                                                            </div>
                                                                            <div class="flex-grow-1">
                                                                                <div class="d-flex align-items-center gap-2 mb-1">
                                                                                    <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold"
                                                                                        style="font-size: 11px; letter-spacing: 0.5px; background-color: #e0f2fe; color: #0369a1;">
                                                                                        <i class="bi bi-activity me-1"></i>Lý do đến khám & Triệu chứng ban đầu
                                                                                    </span>
                                                                                </div>
                                                                                <div class="fw-medium text-dark" style="font-size: 14px; line-height: 1.6; color: #1e293b !important;">
                                                                                    <c:out value="${itemVal}" />
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <!-- Ghi chú lâm sàng khác -->
                                                                        <div class="p-3 rounded-3 mb-2.5 d-flex align-items-start gap-3 bg-white border shadow-sm"
                                                                            style="border-left: 4px solid #64748b !important;">
                                                                            <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                                                style="width: 36px; height: 36px; background: #f1f5f9; color: #475569;">
                                                                                <i class="bi bi-journal-text" style="font-size: 16px;"></i>
                                                                            </div>
                                                                            <div class="flex-grow-1">
                                                                                <div class="d-flex align-items-center gap-2 mb-1">
                                                                                    <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold bg-light text-secondary border"
                                                                                        style="font-size: 11px; letter-spacing: 0.5px;">
                                                                                        <i class="bi bi-pencil-square me-1"></i>Ghi chú lâm sàng
                                                                                    </span>
                                                                                </div>
                                                                                <div class="text-dark" style="font-size: 14px; line-height: 1.6; white-space: pre-wrap;"><c:out value="${itemVal}" /></div>
                                                                            </div>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- Khi không có dấu phân cách | (dạng văn bản thông thường) -->
                                                        <c:choose>
                                                            <c:when test="${fn:contains(rawNotes, 'Dịch vụ:') || fn:startsWith(rawNotes, 'Dịch vụ')}">
                                                                <c:choose>
                                                                    <c:when test="${fn:contains(rawNotes, ':')}">
                                                                        <c:set var="itemVal" value="${fn:trim(fn:substringAfter(rawNotes, ':'))}" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:set var="itemVal" value="${rawNotes}" />
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <div class="p-3 rounded-3 mb-2.5 d-flex align-items-start gap-3 bg-white border shadow-sm"
                                                                    style="border-left: 4px solid #0d9488 !important; border-color: #ccfbf1 #ccfbf1 #ccfbf1 #0d9488;">
                                                                    <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                                        style="width: 36px; height: 36px; background: linear-gradient(135deg, #0d9488 0%, #14b8a6 100%); color: #ffffff;">
                                                                        <i class="bi bi-eye-fill" style="font-size: 16px;"></i>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <div class="d-flex align-items-center gap-2 mb-1">
                                                                            <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold"
                                                                                style="font-size: 11px; letter-spacing: 0.5px; background-color: #ccfbf1; color: #0f766e;">
                                                                                <i class="bi bi-check2-circle me-1"></i>Dịch vụ chỉ định / Bệnh lý
                                                                            </span>
                                                                        </div>
                                                                        <div class="fw-bold text-dark" style="font-size: 14.5px; line-height: 1.5; color: #0f172a !important;">
                                                                            <c:out value="${itemVal}" />
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:when test="${fn:contains(rawNotes, 'Lý do:') || fn:startsWith(rawNotes, 'Lý do')}">
                                                                <c:choose>
                                                                    <c:when test="${fn:contains(rawNotes, ':')}">
                                                                        <c:set var="itemVal" value="${fn:trim(fn:substringAfter(rawNotes, ':'))}" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:set var="itemVal" value="${rawNotes}" />
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <div class="p-3 rounded-3 mb-2.5 d-flex align-items-start gap-3 bg-white border shadow-sm"
                                                                    style="border-left: 4px solid #3b82f6 !important; border-color: #e2e8f0 #e2e8f0 #e2e8f0 #3b82f6;">
                                                                    <div class="rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                                                                        style="width: 36px; height: 36px; background: linear-gradient(135deg, #2563eb 0%, #3b82f6 100%); color: #ffffff;">
                                                                        <i class="bi bi-chat-square-text-fill" style="font-size: 15px;"></i>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <div class="d-flex align-items-center gap-2 mb-1">
                                                                            <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold"
                                                                                style="font-size: 11px; letter-spacing: 0.5px; background-color: #e0f2fe; color: #0369a1;">
                                                                                <i class="bi bi-activity me-1"></i>Lý do đến khám & Triệu chứng ban đầu
                                                                            </span>
                                                                        </div>
                                                                        <div class="fw-medium text-dark" style="font-size: 14px; line-height: 1.6; color: #1e293b !important;">
                                                                            <c:out value="${itemVal}" />
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <!-- Đoạn ghi chú chung -->
                                                                <div class="p-3 rounded-3 bg-white border shadow-sm"
                                                                    style="border-left: 4px solid #0d9488 !important;">
                                                                    <div class="d-flex align-items-center gap-2 mb-2">
                                                                        <span class="badge rounded-pill px-2.5 py-1 text-uppercase fw-semibold bg-light text-secondary border"
                                                                            style="font-size: 11px; letter-spacing: 0.5px;">
                                                                            <i class="bi bi-journal-medical me-1"></i>Triệu chứng / Ghi chú lâm sàng
                                                                        </span>
                                                                    </div>
                                                                    <div class="text-dark" style="font-size: 14px; line-height: 1.7; white-space: pre-wrap;"><c:out value="${rawNotes}" /></div>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <!-- Hướng dẫn lưu trữ -->
                                        <div class="p-3 rounded-3 bg-light border mt-3">
                                            <div class="d-flex align-items-center gap-2 mb-2 text-dark fw-semibold small">
                                                <i class="bi bi-shield-check text-success"></i> Thông tin lưu trữ hồ sơ
                                            </div>
                                            <p class="small text-muted mb-0" style="line-height: 1.6;">
                                                Hồ sơ lịch hẹn đã qua ngày được lưu trữ để phục vụ việc tra cứu lịch sử khám bệnh. Mọi thao tác tiếp đón hoặc hủy lịch chỉ áp dụng cho các ca khám trong ngày hôm nay hoặc sắp tới.
                                            </p>
                                        </div>
                                    </c:when>
                                    <c:when test="${appointment.status == 'Canceled'}">
                                        <!-- Khi đã hủy / vắng mặt: Hiển thị Thẻ thông tin Hủy & Ghi chú cũ dạng Read-only -->
                                        <div class="content-card p-4">
                                            <div class="detail-section-title text-danger">
                                                <i class="bi bi-clipboard2-x text-danger"></i>
                                                Thông tin Hủy lịch & Vắng mặt
                                            </div>
                                            <p class="text-muted small mb-3">
                                                Ca khám này đã được xác nhận kết thúc do bệnh nhân vắng mặt hoặc yêu cầu hủy lịch.
                                            </p>

                                            <div class="p-3 rounded-3 border mb-3" style="background-color: #fef2f2; border-color: #fecaca !important;">
                                                <label class="info-label text-danger fw-bold d-block mb-1">
                                                    <i class="bi bi-exclamation-triangle-fill me-1"></i>Lý do vắng mặt đã xác nhận:
                                                </label>
                                                <p class="fw-semibold text-dark mb-0 ps-2" style="font-size: 14px;">
                                                    <c:choose>
                                                        <c:when test="${not empty appointment.reason}">
                                                            ${appointment.reason}
                                                        </c:when>
                                                        <c:otherwise>
                                                            Gọi tên nhiều lần không có mặt / Bệnh nhân không đến phòng khám đúng giờ hẹn
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </div>

                                            <c:if test="${not empty appointment.medicalNotes}">
                                                <div class="mb-0">
                                                    <label class="info-label fw-bold text-dark mb-2 d-flex align-items-center gap-1.5" style="font-size: 13.5px;">
                                                        <i class="bi bi-file-earmark-medical-fill" style="color: var(--primary-color, #0d9488);"></i>
                                                        <span>Ghi chú Y tế ban đầu:</span>
                                                    </label>
                                                    <c:set var="rawNotesCancel" value="${fn:trim(appointment.medicalNotes)}" />
                                                    <c:choose>
                                                        <c:when test="${fn:contains(rawNotesCancel, '|')}">
                                                            <c:forEach var="part" items="${fn:split(rawNotesCancel, '|')}">
                                                                <c:set var="trimmedPart" value="${fn:trim(part)}" />
                                                                <c:if test="${not empty trimmedPart}">
                                                                    <c:choose>
                                                                        <c:when test="${fn:contains(trimmedPart, ':')}">
                                                                            <c:set var="itemVal" value="${fn:trim(fn:substringAfter(trimmedPart, ':'))}" />
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <c:set var="itemVal" value="${trimmedPart}" />
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    <div class="p-2.5 px-3 rounded-2 bg-white border mb-2 d-flex align-items-start gap-2.5 shadow-sm"
                                                                        style="border-left: 3.5px solid #0d9488 !important;">
                                                                        <i class="bi bi-tag-fill mt-1 text-teal" style="font-size: 13px; color: #0d9488;"></i>
                                                                        <div class="flex-grow-1">
                                                                            <div class="small fw-semibold text-secondary text-uppercase" style="font-size: 10.5px; letter-spacing: 0.3px;">
                                                                                <c:choose>
                                                                                    <c:when test="${fn:contains(trimmedPart, 'Dịch vụ') || fn:contains(trimmedPart, 'Bệnh lý')}">Dịch vụ yêu cầu</c:when>
                                                                                    <c:when test="${fn:contains(trimmedPart, 'Lý do') || fn:contains(trimmedPart, 'Triệu chứng')}">Lý do đến khám</c:when>
                                                                                    <c:otherwise>Ghi chú</c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                            <div class="fw-semibold text-dark mt-0.5" style="font-size: 13.5px; line-height: 1.5;">
                                                                                <c:out value="${itemVal}" />
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="p-2.5 px-3 rounded-2 bg-white border text-dark shadow-sm"
                                                                style="font-size: 13.5px; line-height: 1.6; border-left: 3.5px solid #0d9488 !important; white-space: pre-wrap;"><c:out value="${rawNotesCancel}" /></div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Hướng dẫn xử lý -->
                                        <div class="p-3 rounded-3 bg-light border mt-3">
                                            <div class="d-flex align-items-center gap-2 mb-2 text-dark fw-semibold small">
                                                <i class="bi bi-info-circle-fill text-primary"></i> Hướng dẫn nghiệp vụ tiếp đón
                                            </div>
                                            <p class="small text-muted mb-0" style="line-height: 1.6;">
                                                Nếu bệnh nhân đến trễ và muốn được khám lại, vui lòng hướng dẫn bệnh nhân đặt một lịch hẹn mới hoặc chuyển sang tiếp đón ca khám vãng lai trong ngày nếu bác sĩ còn slot trống.
                                            </p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Khi bình thường: Cho phép nhập/sửa Medical Notes -->
                                        <div class="content-card p-4">
                                            <div class="detail-section-title">
                                                <i class="bi bi-clipboard2-pulse text-teal"
                                                    style="color: var(--primary-color);"></i>
                                                Ghi nhận Ghi chú Y tế Ban đầu
                                            </div>
                                            <p class="text-muted small mb-3">
                                                Lễ tân ghi nhận triệu chứng sơ bộ, lý do đến khám hoặc các lưu ý đặc biệt để Bác
                                                sĩ nắm trước khi vào phòng khám.
                                            </p>

                                            <!-- Quick symptom suggestions -->
                                            <div class="mb-3">
                                                <label class="info-label d-block mb-2">Gợi ý triệu chứng nhanh:</label>
                                                <div class="d-flex flex-wrap gap-2">
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Khám mắt định kỳ, đo thị lực.')">+ Khám định
                                                        kỳ</span>
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Mắt đỏ, cộm xốn, chảy nước mắt 2 ngày nay.')">+ Đỏ
                                                        mắt, cộm xốn</span>
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Nhìn mờ đột ngột, chói mắt khi ra nắng.')">+ Nhìn
                                                        mờ</span>
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Tái khám theo hẹn của bác sĩ.')">+ Tái khám
                                                        hẹn</span>
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Có dị vật / bụi bay vào mắt.')">+ Dị vật mắt</span>
                                                    <span class="quick-tag-badge"
                                                        onclick="appendNote('Tiền sử cận thị, cần đo độ kính mới.')">+ Cắt kính
                                                        mới</span>
                                                </div>
                                            </div>

                                            <!-- Notes Form -->
                                            <form action="${pageContext.request.contextPath}/staff/appointment-detail"
                                                method="post">
                                                <input type="hidden" name="action" value="saveNotes">
                                                <input type="hidden" name="appointmentId" value="${appointment.id}">
                                                <input type="hidden" name="doctorId" value="${appointment.doctorId}">

                                                <div class="mb-3">
                                                    <label for="medicalNotesInput" class="info-label fw-semibold text-dark">
                                                        Nội dung Ghi chú Y tế (Medical Notes):
                                                    </label>
                                                    <textarea id="medicalNotesInput" name="medicalNotes" rows="5"
                                                        class="notes-textarea"
                                                        placeholder="Nhập triệu chứng của bệnh nhân, lý do khám, tiền sử dị ứng hoặc ghi chú cho bác sĩ...">${fn:trim(appointment.medicalNotes)}</textarea>
                                                </div>

                                                <div class="d-flex align-items-center justify-content-between pt-2">
                                                    <span class="text-muted small">
                                                        <c:choose>
                                                            <c:when test="${not empty appointment.medicalNotes}">
                                                                <i class="bi bi-check-circle text-success me-1"></i>Đã có ghi
                                                                chú lưu
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="bi bi-dash-circle text-muted me-1"></i>Chưa có ghi chú
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <button type="submit" class="btn btn-teal">
                                                        <i class="bi bi-floppy"></i> Lưu Ghi chú Y tế
                                                    </button>
                                                </div>
                                            </form>
                                        </div>

                                        <!-- Flow Information Box -->
                                        <div class="p-3 rounded-3 bg-light border mt-3">
                                            <div class="d-flex align-items-center gap-2 mb-2 text-dark fw-semibold small">
                                                <i class="bi bi-lightbulb-fill text-warning"></i> Quy trình Tiếp đón Khám mắt
                                            </div>
                                            <ol class="small text-muted ps-3 mb-0" style="line-height: 1.6;">
                                                <li>Kiểm tra thông tin cá nhân và số điện thoại của bệnh nhân.</li>
                                                <li>Bấm <strong>Check-in</strong> để xác nhận bệnh nhân đã có mặt.</li>
                                                <li>Ghi nhận triệu chứng ban đầu vào ô <strong>Medical Notes</strong>.</li>
                                                <li>Hướng dẫn bệnh nhân sang khu vực ghế chờ theo dõi trên màn hình hàng đợi.
                                                </li>
                                            </ol>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                    </div>
                </main>

                <!-- Modal Xác nhận Check-in (Thiết kế đồng bộ với hệ thống theo hình ảnh) -->
                <div class="modal fade" id="checkinModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-warning">
                                    <i class="bi bi-box-arrow-in-right"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận check-in?</h3>
                                <p class="modal-text">
                                    Bệnh nhân <strong class="text-dark">${appointment.patientName}</strong> sẽ được xác
                                    nhận tiếp đón và chuyển vào hàng đợi phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/appointment-detail" method="post"
                                    class="m-0">
                                    <input type="hidden" name="action" value="checkin">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">Check-in</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>



                <!-- Modal Xác nhận Hủy lịch hẹn -->
                <div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 430px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-danger">
                                    <i class="bi bi-calendar-x"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận hủy lịch hẹn?</h3>
                                <p class="modal-text mb-3">
                                    Lịch khám của bệnh nhân <strong
                                        class="text-dark">${appointment.patientName}</strong> (#APPT-${appointment.id})
                                    sẽ được hủy và giải phóng ca làm việc cho bác sĩ.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/appointment-detail" method="post"
                                    class="m-0 text-start">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">

                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold text-dark mb-1.5">
                                            Lý do hủy lịch <span class="text-danger">*</span>
                                        </label>
                                        <select name="cancelReasonSelect" id="cancelReasonSelect"
                                            class="form-select form-select-sm shadow-none mb-2"
                                            style="border-radius: 8px; font-size: 13.5px;"
                                            onchange="toggleCustomReason(this)">
                                            <option value="Liên hệ nhưng bệnh nhân báo bận không đến khám">Liên hệ nhưng bệnh nhân báo bận không đến khám</option>
                                            <option value="Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác">Bệnh nhân
                                                báo bận, yêu cầu đổi lịch sang ngày khác</option>
                                            <option value="Bệnh nhân không có nhu cầu khám nữa">Bệnh nhân không có nhu
                                                cầu khám nữa</option>
                                            <option value="Bệnh nhân đặt trùng / sai thông tin">Bệnh nhân đặt trùng /
                                                sai thông tin</option>
                                            <option value="other">Lý do khác (Nhập ghi chú)...</option>
                                        </select>
                                        <textarea name="cancelReasonCustom" id="cancelReasonCustom"
                                            class="form-control form-control-sm shadow-none d-none" rows="2"
                                            placeholder="Nhập lý do hủy chi tiết..."
                                            style="border-radius: 8px; font-size: 13px;"></textarea>
                                    </div>

                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Đóng</button>
                                        <button type="submit" class="btn btn-modal-danger">
                                            <i class="bi bi-x-circle me-1"></i> Hủy lịch
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Báo Vắng Mặt (Trường hợp 2: Bệnh nhân đã check-in nhưng gọi tên không có mặt) -->
                <div class="modal fade" id="absentModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-danger">
                                    <i class="bi bi-person-x"></i>
                                </div>
                                <h3 class="modal-title-custom">Xác nhận báo vắng mặt?</h3>
                                <p class="modal-text mb-3">
                                    Bệnh nhân <strong class="text-dark">${appointment.patientName}</strong> (#APPT-${appointment.id}) sẽ được ghi nhận vắng mặt trong ca khám và gỡ khỏi hàng đợi hôm nay.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/appointment-detail" method="post"
                                    class="m-0 text-start">
                                    <input type="hidden" name="action" value="absent">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">

                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold text-dark mb-1.5">
                                            Lý do vắng mặt <span class="text-danger">*</span>
                                        </label>
                                        <select name="cancelReasonSelect" id="absentDetailReasonSelect"
                                            class="form-select form-select-sm shadow-none mb-2"
                                            style="border-radius: 8px; font-size: 13.5px;"
                                            onchange="toggleAbsentDetailReason(this)">
                                            <option value="Gọi tên nhiều lần không có mặt / Không vào phòng khám">Gọi tên nhiều lần không có mặt / Không vào phòng khám</option>
                                            <option value="Bệnh nhân tự ý bỏ về trước khi đến lượt khám">Bệnh nhân tự ý bỏ về trước khi đến lượt khám</option>
                                            <option value="Bệnh nhân báo bận đột xuất, xin dời sang ngày khác">Bệnh nhân báo bận đột xuất, xin dời sang ngày khác</option>
                                            <option value="other">Lý do khác (Nhập ghi chú)...</option>
                                        </select>
                                        <textarea name="cancelReasonCustom" id="absentDetailReasonCustom"
                                            class="form-control form-control-sm shadow-none d-none" rows="2"
                                            placeholder="Nhập lý do chi tiết..."
                                            style="border-radius: 8px; font-size: 13px;"></textarea>
                                    </div>

                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Đóng</button>
                                        <button type="submit" class="btn btn-modal-danger">
                                            <i class="bi bi-person-x me-1"></i> Báo vắng mặt
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal Bỏ Qua Lượt / Đổi lượt với ca tiếp theo sau mình -->
                <div class="modal fade" id="skipModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <div class="modal-icon-warning">
                                    <i class="bi bi-arrow-down-circle"></i>
                                </div>
                                <h3 class="modal-title-custom">Bỏ qua lượt khám?</h3>
                                <p class="modal-text mb-3">
                                    Bệnh nhân <strong class="text-dark">${appointment.patientName}</strong> (#APPT-${appointment.id}) sẽ <strong>chuyển đổi ca khám với lượt tiếp theo sau mình</strong> để nhường lượt cho bệnh nhân kế tiếp vào phòng khám.
                                </p>
                                <form action="${pageContext.request.contextPath}/staff/appointment-detail" method="post"
                                    class="m-0">
                                    <input type="hidden" name="action" value="skip">
                                    <input type="hidden" name="appointmentId" value="${appointment.id}">
                                    <div class="modal-actions">
                                        <button type="button" class="btn btn-modal-cancel"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-modal-warning">
                                            <i class="bi bi-arrow-down-circle me-1"></i> Đổi lượt ca sau
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bootstrap 5 JS -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    function toggleCustomReason(select) {
                        var custom = document.getElementById('cancelReasonCustom');
                        if (custom) {
                            if (select.value === 'other') {
                                custom.classList.remove('d-none');
                                custom.focus();
                            } else {
                                custom.classList.add('d-none');
                                custom.value = '';
                            }
                        }
                    }

                    function toggleAbsentDetailReason(select) {
                        var custom = document.getElementById('absentDetailReasonCustom');
                        if (custom) {
                            if (select.value === 'other') {
                                custom.classList.remove('d-none');
                                custom.focus();
                            } else {
                                custom.classList.add('d-none');
                                custom.value = '';
                            }
                        }
                    }

                    function appendNote(text) {
                        var textarea = document.getElementById('medicalNotesInput');
                        if (textarea.value.trim() === '') {
                            textarea.value = text;
                        } else {
                            textarea.value = textarea.value + '\n' + text;
                        }
                        textarea.focus();
                    }
                </script>
            </body>

            </html>
