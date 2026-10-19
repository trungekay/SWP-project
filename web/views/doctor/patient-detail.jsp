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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-patient-detail.css?v=3">
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
                                    <span>Mã lịch hẹn <strong>#APPT-<c:out value="${appointment.id}" /></strong></span>
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
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</body>
</html>
