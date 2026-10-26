<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- Controller contract: appointment (Appointment), history (List<MedicalRecord> of previous visits). --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết bệnh nhân - VisionCare</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-patient-detail.css?v=5">
</head>
<body>
    <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
        <jsp:param name="activeNav" value="examination" />
    </jsp:include>

    <main class="main-wrapper">
        <jsp:include page="/views/employee/layout/employee-header.jsp" />
        <div class="page-content doctor-detail-page">
            <nav class="doctor-detail-breadcrumb" aria-label="Điều hướng">
                <a href="${pageContext.request.contextPath}/doctor/waiting-list">
                    <i class="bi bi-arrow-left" aria-hidden="true"></i> Hàng đợi khám bệnh
                </a>
                <i class="bi bi-chevron-right" aria-hidden="true"></i>
                <span aria-current="page">Chi tiết bệnh nhân</span>
            </nav>

            <c:choose>
                <c:when test="${empty appointment}">
                    <div class="doctor-detail-empty-page" role="status">
                        <div class="doctor-detail-empty-icon"><i class="bi bi-person-x" aria-hidden="true"></i></div>
                        <h1>Không tìm thấy ca khám</h1>
                        <p>Ca khám này không tồn tại hoặc bạn chưa được phân công khám bệnh nhân.</p>
                        <a class="doctor-detail-button doctor-detail-button-primary" href="${pageContext.request.contextPath}/doctor/waiting-list">
                            <i class="bi bi-arrow-left" aria-hidden="true"></i> Về hàng đợi khám bệnh
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <header class="doctor-detail-heading">
                        <div>
                            <span class="doctor-detail-eyebrow">HỒ SƠ KHÁM BỆNH</span>
                            <h1>Chi tiết bệnh nhân</h1>
                            <p>Xem thông tin người bệnh, ca hẹn hôm nay và những lần khám trước.</p>
                        </div>
                        <c:if test="${appointment.status eq 'In_Progress' || appointment.status eq 'Completed'}">
                            <div class="doctor-detail-desktop-actions">
                            <c:choose>
                                <c:when test="${not empty examinationUrl}">
                                    <a class="doctor-detail-button doctor-detail-button-primary doctor-detail-desktop-action"
                                       href="<c:out value='${examinationUrl}' />">
                                        <i class="bi bi-clipboard2-pulse" aria-hidden="true"></i> ${appointment.status eq 'Completed' ? 'Xem phiếu khám' : 'Mở phiếu khám'}
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="doctor-detail-button doctor-detail-button-primary doctor-detail-desktop-action" type="button" disabled
                                            title="Phiếu khám chưa sẵn sàng">
                                        <i class="bi bi-clipboard2-pulse" aria-hidden="true"></i> Mở phiếu khám
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty prescriptionUrl}">
                                <a class="doctor-detail-button doctor-detail-button-secondary doctor-detail-desktop-action"
                                   href="<c:out value='${prescriptionUrl}' />">
                                    <i class="bi bi-prescription2" aria-hidden="true"></i> Kê đơn
                                </a>
                            </c:if>
                            <c:if test="${appointment.status eq 'In_Progress' && completionReady}">
                                <button type="button" class="doctor-detail-button doctor-detail-desktop-action"
                                        onclick="openDoctorCompleteModal()"
                                        style="background: #059669; color: #fff; border-color: #059669; font-weight: 600;">
                                    <i class="bi bi-check2-circle" aria-hidden="true"></i> Hoàn tất ca khám
                                </button>
                            </c:if>
                            <c:if test="${appointment.status eq 'In_Progress' && not completionReady}">
                                <span class="doctor-detail-desktop-action small text-muted">Lưu kết quả khám, chẩn đoán và kết luận để hoàn tất.</span>
                            </c:if>
                            </div>
                        </c:if>
                    </header>

                    <section class="doctor-detail-hero" aria-labelledby="patient-name">
                        <div class="doctor-detail-hero-main">
                            <div class="doctor-detail-avatar" aria-hidden="true">
                                <c:choose>
                                    <c:when test="${not empty appointment.patientName}"><c:out value="${fn:substring(appointment.patientName, 0, 1)}" /></c:when>
                                    <c:otherwise>BN</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="doctor-detail-hero-copy">
                                <div class="doctor-detail-hero-label">BỆNH NHÂN</div>
                                <h2 id="patient-name"><c:out value="${appointment.patientName}" default="Chưa có tên" /></h2>
                                <div class="doctor-detail-hero-identifiers">
                                    <span>Mã BN <strong>#PT-<c:out value="${appointment.patientId}" /></strong></span>
                                    <span>Mã lịch hẹn <strong>#APT-<c:out value="${appointment.id}" /></strong></span>
                                </div>
                            </div>
                        </div>
                        <div class="doctor-detail-status-wrap">
                            <c:choose>
                                <c:when test="${appointment.status eq 'Confirmed'}">
                                    <span class="doctor-detail-status waiting"><i class="bi bi-hourglass-split" aria-hidden="true"></i> Chờ khám</span>
                                </c:when>
                                <c:when test="${appointment.status eq 'In_Progress'}">
                                    <span class="doctor-detail-status examining"><i class="bi bi-activity" aria-hidden="true"></i> Đang khám</span>
                                </c:when>
                                <c:when test="${appointment.status eq 'Completed'}">
                                    <span class="doctor-detail-status completed"><i class="bi bi-check-circle" aria-hidden="true"></i> Hoàn tất</span>
                                </c:when>
                                <c:when test="${appointment.status eq 'Canceled'}">
                                    <span class="doctor-detail-status canceled"><i class="bi bi-x-circle" aria-hidden="true"></i> Đã hủy</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="doctor-detail-status neutral"><c:out value="${appointment.status}" default="Chưa rõ trạng thái" /></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="doctor-detail-hero-facts">
                            <span><i class="bi bi-calendar3" aria-hidden="true"></i>
                                <c:choose>
                                    <c:when test="${not empty appointment.appointmentDate}"><fmt:formatDate value="${appointment.appointmentDate}" pattern="dd/MM/yyyy" /></c:when>
                                    <c:otherwise>Chưa có ngày hẹn</c:otherwise>
                                </c:choose>
                            </span>
                            <span><i class="bi bi-clock" aria-hidden="true"></i> <c:out value="${appointment.timeSlot}" default="Chưa có giờ hẹn" /></span>
                            <span><i class="bi bi-geo-alt" aria-hidden="true"></i> <c:out value="${appointment.roomName}" default="Chưa phân phòng" /></span>
                        </div>
                    </section>

                    <div class="doctor-detail-grid">
                        <section class="doctor-detail-card" aria-labelledby="profile-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon teal"><i class="bi bi-person-vcard" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="profile-heading">Thông tin bệnh nhân</h2>
                                    <p>Thông tin liên hệ và nhận diện</p>
                                </div>
                            </div>
                            <dl class="doctor-detail-fields">
                                <div><dt>Họ và tên</dt><dd><c:out value="${appointment.patientName}" default="Chưa cập nhật" /></dd></div>
                                <div><dt>Ngày sinh</dt><dd>
                                    <c:choose>
                                        <c:when test="${not empty appointment.dob}"><fmt:formatDate value="${appointment.dob}" pattern="dd/MM/yyyy" /></c:when>
                                        <c:otherwise><span class="doctor-detail-muted">Chưa cập nhật</span></c:otherwise>
                                    </c:choose>
                                </dd></div>
                                <div><dt>Số điện thoại</dt><dd><c:out value="${appointment.phone}" default="Chưa cập nhật" /></dd></div>
                                <div><dt>Mã bệnh nhân</dt><dd>#PT-<c:out value="${appointment.patientId}" /></dd></div>
                                <div class="doctor-detail-field-wide"><dt>Địa chỉ</dt><dd><c:out value="${appointment.address}" default="Chưa cập nhật" /></dd></div>
                            </dl>
                        </section>

                        <section class="doctor-detail-card" aria-labelledby="visit-heading">
                            <div class="doctor-detail-card-heading">
                                <span class="doctor-detail-card-icon blue"><i class="bi bi-calendar2-check" aria-hidden="true"></i></span>
                                <div>
                                    <h2 id="visit-heading">Ca khám hiện tại</h2>
                                    <p>Thông tin tiếp nhận và phân công</p>
                                </div>
                            </div>
                            <dl class="doctor-detail-fields">
                                <div><dt>Ngày khám</dt><dd>
                                    <c:choose>
                                        <c:when test="${not empty appointment.appointmentDate}"><fmt:formatDate value="${appointment.appointmentDate}" pattern="dd/MM/yyyy" /></c:when>
                                        <c:otherwise><span class="doctor-detail-muted">Chưa cập nhật</span></c:otherwise>
                                    </c:choose>
                                </dd></div>
                                <div><dt>Giờ hẹn</dt><dd><c:out value="${appointment.timeSlot}" default="Chưa cập nhật" /></dd></div>
                                <div><dt>Bác sĩ phụ trách</dt><dd><c:out value="${appointment.doctorName}" default="Chưa phân công" /></dd></div>
                                <div><dt>Phòng khám</dt><dd><c:out value="${appointment.roomName}" default="Chưa phân phòng" /></dd></div>
                                <div class="doctor-detail-field-wide"><dt>Thời gian check-in</dt><dd>
                                    <c:choose>
                                        <c:when test="${not empty appointment.checkinTime}"><c:out value="${appointment.checkinTime}" /></c:when>
                                        <c:otherwise><span class="doctor-detail-muted">Chưa check-in</span></c:otherwise>
                                    </c:choose>
                                </dd></div>
                            </dl>
                        </section>
                    </div>

                    <div class="doctor-detail-support-grid">
                    <section class="doctor-detail-card doctor-detail-staff-notes" aria-labelledby="staff-notes-heading">
                        <div class="doctor-detail-card-heading">
                            <span class="doctor-detail-card-icon teal"><i class="bi bi-journal-medical" aria-hidden="true"></i></span>
                            <div>
                                <h2 id="staff-notes-heading">Ghi chú từ nhân viên tiếp nhận</h2>
                                <p>Triệu chứng và thông tin staff đã ghi cho ca khám này</p>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${not empty appointment.medicalNotes}">
                                <p class="doctor-detail-staff-notes-content"><c:out value="${appointment.medicalNotes}" /></p>
                            </c:when>
                            <c:otherwise><p class="doctor-detail-muted">Chưa có ghi chú từ nhân viên tiếp nhận.</p></c:otherwise>
                        </c:choose>
                    </section>

                    <section class="doctor-detail-card doctor-detail-history" aria-labelledby="history-heading">
                        <div class="doctor-detail-card-heading doctor-detail-history-heading">
                            <span class="doctor-detail-card-icon violet"><i class="bi bi-clock-history" aria-hidden="true"></i></span>
                            <div>
                                <h2 id="history-heading">Lịch sử khám</h2>
                                <p>Các lần khám trước của bệnh nhân, mới nhất ở trên</p>
                            </div>
                            <span class="doctor-detail-history-count"><c:out value="${fn:length(history)}" /> lần khám</span>
                        </div>

                        <c:choose>
                            <c:when test="${empty history}">
                                <div class="doctor-detail-history-empty">
                                    <span><i class="bi bi-journal-medical" aria-hidden="true"></i></span>
                                    <h3>Chưa có lịch sử khám</h3>
                                    <p>Đây có thể là lần đầu bệnh nhân khám tại VisionCare.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <ol class="doctor-detail-timeline">
                                    <c:forEach var="record" items="${history}">
                                        <li class="doctor-detail-timeline-item">
                                            <span class="doctor-detail-timeline-dot" aria-hidden="true"></span>
                                            <div class="doctor-detail-history-row">
                                                <div class="doctor-detail-history-date">
                                                    <i class="bi bi-calendar-event" aria-hidden="true"></i>
                                                    <fmt:formatDate value="${record.createdAt}" pattern="dd/MM/yyyy" />
                                                </div>
                                                <span class="doctor-detail-record-id">#MR-<c:out value="${record.recordId}" /></span>
                                            </div>
                                            <h3><c:out value="${record.clinicalDiagnosis}" default="Chưa có chẩn đoán" /></h3>
                                            <p class="doctor-detail-history-doctor"><i class="bi bi-person-badge" aria-hidden="true"></i> <c:out value="${record.doctorName}" default="Chưa cập nhật" /></p>
                                            <a class="doctor-detail-history-link" href="${pageContext.request.contextPath}/profile/medical-record?id=${record.recordId}"><i class="bi bi-file-earmark-medical" aria-hidden="true"></i> Chi tiết lần khám</a>
                                            <c:if test="${not empty record.examinationResult or not empty record.conclusion}">
                                                <details class="doctor-detail-history-more">
                                                    <summary>Xem kết quả khám <i class="bi bi-chevron-down" aria-hidden="true"></i></summary>
                                                    <div class="doctor-detail-history-result">
                                                        <c:if test="${not empty record.examinationResult}">
                                                            <div><strong>Kết quả khám</strong><p><c:out value="${record.examinationResult}" /></p></div>
                                                        </c:if>
                                                        <c:if test="${not empty record.conclusion}">
                                                            <div><strong>Kết luận</strong><p><c:out value="${record.conclusion}" /></p></div>
                                                        </c:if>
                                                    </div>
                                                </details>
                                            </c:if>
                                        </li>
                                    </c:forEach>
                                </ol>
                            </c:otherwise>
                        </c:choose>
                    </section>
                    </div>

                    <c:if test="${appointment.status eq 'In_Progress' || appointment.status eq 'Completed'}">
                        <div class="doctor-detail-mobile-action">
                            <c:choose>
                                <c:when test="${not empty examinationUrl}">
                                    <a class="doctor-detail-button doctor-detail-button-primary"
                                       href="<c:out value='${examinationUrl}' />">
                                        <i class="bi bi-clipboard2-pulse" aria-hidden="true"></i> ${appointment.status eq 'Completed' ? 'Xem phiếu khám' : 'Mở phiếu khám'}
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <button class="doctor-detail-button doctor-detail-button-primary" type="button" disabled
                                            title="Phiếu khám chưa sẵn sàng">
                                        <i class="bi bi-clipboard2-pulse" aria-hidden="true"></i> Mở phiếu khám
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty prescriptionUrl}">
                                <a class="doctor-detail-button doctor-detail-button-secondary"
                                   href="<c:out value='${prescriptionUrl}' />">
                                    <i class="bi bi-prescription2" aria-hidden="true"></i> Kê đơn
                                </a>
                            </c:if>
                            <c:if test="${appointment.status eq 'In_Progress' && completionReady}">
                                <button type="button" class="doctor-detail-button"
                                        onclick="openDoctorCompleteModal()"
                                        style="background: #059669; color: #fff; border-color: #059669; font-weight: 600;">
                                    <i class="bi bi-check2-circle" aria-hidden="true"></i> Hoàn tất ca khám
                                </button>
                            </c:if>
                            <c:if test="${appointment.status eq 'In_Progress' && not completionReady}">
                                <span class="small text-muted">Lưu kết quả khám, chẩn đoán và kết luận để hoàn tất.</span>
                            </c:if>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <!-- Modal xác nhận hoàn tất ca khám cho Bác sĩ -->
    <c:if test="${appointment.status eq 'In_Progress' && completionReady}">
        <div class="modal fade" id="doctorCompleteModal" tabindex="-1" aria-labelledby="doctorCompleteModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" style="max-width: 440px;">
                <div class="modal-content shadow border-0" style="border-radius: 16px; overflow: hidden;">
                    <div class="modal-header border-bottom px-4 py-3 bg-light">
                        <div class="d-flex align-items-center gap-2">
                            <div style="width: 36px; height: 36px; border-radius: 10px; background: rgba(16, 185, 129, 0.12); color: #059669; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                                <i class="bi bi-check2-circle"></i>
                            </div>
                            <h5 class="modal-title fw-bold text-dark mb-0" id="doctorCompleteModalLabel" style="font-size: 16px;">Xác nhận hoàn tất ca khám</h5>
                        </div>
                        <button type="button" class="btn-close shadow-none" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4 text-start">
                        <p class="text-secondary small mb-3">
                            Bác sĩ xác nhận đã hoàn thành việc khám bệnh cho bệnh nhân <strong class="text-dark"><c:out value="${appointment.patientName}" /></strong> (#APT-<c:out value="${appointment.id}" />).
                        </p>
                        <div class="bg-light p-3 rounded-3 small border mb-3">
                            <div class="d-flex justify-content-between py-1 border-bottom">
                                <span class="text-muted">Bệnh nhân:</span>
                                <strong class="text-dark"><c:out value="${appointment.patientName}" /></strong>
                            </div>
                            <div class="d-flex justify-content-between py-1 border-bottom">
                                <span class="text-muted">Giờ hẹn:</span>
                                <span class="text-dark fw-semibold"><c:out value="${appointment.timeSlot}" /></span>
                            </div>
                            <div class="d-flex justify-content-between py-1">
                                <span class="text-muted">Trạng thái sau hoàn tất:</span>
                                <span class="badge bg-success-subtle text-success border border-success-subtle py-1">Đã khám xong (Chuyển ra quầy lễ tân)</span>
                            </div>
                        </div>
                        <div class="alert alert-info py-2 px-3 small rounded-3 mb-0" style="font-size: 12px;">
                            <i class="bi bi-info-circle-fill me-1"></i> Sau khi hoàn tất, thông tin đơn thuốc và kết quả sẽ tự động đồng bộ sang màn hình của <strong>Lễ tân</strong> để bàn giao và hướng dẫn xuất viện.
                        </div>
                    </div>
                    <div class="modal-footer px-4 py-3 bg-light border-top d-flex justify-content-between">
                        <button type="button" class="btn btn-outline-secondary btn-sm px-3" data-bs-dismiss="modal">Hủy</button>
                        <form action="${pageContext.request.contextPath}/doctor/waiting-list" method="post" class="m-0">
                            <input type="hidden" name="action" value="complete">
                            <input type="hidden" name="appointmentId" value="${appointment.id}">
                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                            <input type="hidden" name="date" value="${appointment.appointmentDate}">
                            <input type="hidden" name="status" value="Completed">
                            <button type="submit" class="btn btn-success btn-sm px-3.5 fw-semibold shadow-sm">
                                <i class="bi bi-check2 me-1"></i> Xác nhận hoàn tất
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <script src="${pageContext.request.contextPath}/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script>
        function openDoctorCompleteModal() {
            var modalEl = document.getElementById('doctorCompleteModal');
            if (modalEl) {
                var modal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                modal.show();
            }
        }
    </script>
</body>
</html>
