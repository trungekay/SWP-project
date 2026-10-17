<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hồ sơ bệnh nhân: <c:out value="${patient.fullName}" /> - VisionCare</title>
  
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  
  <!-- Layout CSS (Staff & Admin Design System) -->
  <jsp:include page="/views/staff/layout/staff-css.jsp" />
  <!-- Custom Styles for Specialist Patient Detail (Screen 35) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/specialist-patient-detail.css">
</head>
<body>

  <!-- Sidebar -->
  <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="waiting-list" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <main class="page-content">
      
      <!-- Top Action Bar & Breadcrumb -->
      <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
        <div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-1" style="font-size: 13px;">
              <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="text-decoration-none text-secondary">
                  <i class="bi bi-clipboard2-pulse me-1"></i>Hàng đợi
                </a>
              </li>
              <li class="breadcrumb-item text-muted">Hồ sơ bệnh nhân</li>
              <li class="breadcrumb-item active fw-semibold text-dark" aria-current="page">
                <c:out value="${patient.fullName}" />
              </li>
            </ol>
          </nav>
          <h4 class="fw-bold mb-0 text-dark">
            Hồ sơ chi tiết Bệnh nhân
          </h4>
        </div>

        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list" 
             class="btn btn-sm btn-outline-secondary rounded-pill px-3 d-inline-flex align-items-center gap-1.5 shadow-sm">
            <i class="bi bi-arrow-left"></i>
            <span>Quay lại Hàng đợi</span>
          </a>
        </div>
      </div>

      <!-- Khối 1: Thông tin Hành chính Bệnh nhân -->
      <div class="patient-header-card mb-4">
        <div class="row align-items-center g-3">
          <!-- Cột Avatar & Tên -->
          <div class="col-lg-5 col-md-6">
            <div class="d-flex align-items-center gap-3">
              <div class="patient-avatar-circle">
                <c:out value="${patient.fullName != null && !patient.fullName.isEmpty() ? patient.fullName.substring(0, 1).toUpperCase() : 'P'}" />
              </div>
              <div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                  <h5 class="fw-bold text-dark mb-0 fs-5">
                    <c:out value="${patient.fullName}" />
                  </h5>
                  <span class="badge bg-light text-secondary border px-2 py-0.5" style="font-size: 11.5px; font-weight: 600;">
                    Mã BN: #BN-${patient.patientId}
                  </span>
                </div>
                <div class="text-secondary small mt-1">
                  <i class="bi bi-geo-alt text-muted me-1"></i><c:out value="${patient.address != null && !patient.address.isEmpty() ? patient.address : 'Chưa cập nhật địa chỉ'}" />
                </div>
              </div>
            </div>
          </div>

          <!-- Cột Các thông số hành chính -->
          <div class="col-lg-7 col-md-6">
            <div class="row g-2">
              <div class="col-sm-4">
                <div class="info-pill">
                  <i class="bi bi-telephone"></i>
                  <div>
                    <div class="text-muted" style="font-size: 11px;">Số điện thoại</div>
                    <div class="fw-bold text-dark"><c:out value="${patient.phone}" /></div>
                  </div>
                </div>
              </div>

              <div class="col-sm-4">
                <div class="info-pill">
                  <i class="bi bi-calendar-event"></i>
                  <div>
                    <div class="text-muted" style="font-size: 11px;">Ngày sinh (Tuổi)</div>
                    <div class="fw-bold text-dark">
                      <c:choose>
                        <c:when test="${not empty patient.dob}">
                          <fmt:formatDate value="${patient.dob}" pattern="dd/MM/yyyy" />
                          <span class="text-secondary fw-normal">(${patient.age}t)</span>
                        </c:when>
                        <c:otherwise>Chưa rõ</c:otherwise>
                      </c:choose>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-sm-4">
                <div class="info-pill">
                  <i class="bi bi-folder2-open"></i>
                  <div>
                    <div class="text-muted" style="font-size: 11px;">Tổng lượt khám</div>
                    <div class="fw-bold text-teal">
                      ${medicalHistory != null ? medicalHistory.size() : 0} lần khám
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Khối liên kết: Ca chỉ định đang chờ thực hiện (Chỉ hiện khi ca đang ở trạng thái Pending) -->
      <c:if test="${not empty currentOrder && currentOrder.status == 'Pending'}">
        <div class="mb-4 bg-white rounded-3 border d-flex align-items-center justify-content-between flex-wrap gap-2 shadow-sm" 
             style="padding: 11px 18px; border-left: 4px solid #008b74 !important;">
          <div class="d-flex align-items-center flex-wrap gap-2">
            <span class="badge bg-teal text-white px-2 py-1 fw-bold" style="font-size: 11px; letter-spacing: 0.3px;">
              #CD-${currentOrder.orderId}
            </span>
            <span class="fw-bold text-dark" style="font-size: 13.5px;">
              <c:out value="${currentOrder.serviceName}" />
            </span>
            <span class="badge bg-light text-secondary border px-2 py-0.5" style="font-size: 11px;">
              <i class="bi bi-door-open me-1 text-success"></i><c:out value="${currentOrder.roomName != null ? currentOrder.roomName : 'P. Cận lâm sàng'}" />
            </span>
            <span class="text-teal fw-semibold small">
              <fmt:formatNumber value="${currentOrder.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
            </span>
            <span class="text-muted small mx-1">|</span>
            <span class="text-secondary small">
              <i class="bi bi-person-badge text-muted me-1"></i>BS: <strong><c:out value="${currentOrder.doctorName}" /></strong>
              <c:if test="${not empty currentOrder.clinicalDiagnosis}">
                <span class="text-muted ms-1">(<c:out value="${currentOrder.clinicalDiagnosis}" />)</span>
              </c:if>
            </span>
          </div>

          <div class="d-flex align-items-center gap-2">
            <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle rounded-pill px-2.5 py-1" style="font-size: 11.5px;">
              <i class="bi bi-hourglass-split me-1"></i>Chờ thực hiện
            </span>
            <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${currentOrder.orderId}" 
               class="btn btn-sm btn-teal rounded-pill px-3 py-1 fw-bold shadow-sm" style="font-size: 12px;">
              <i class="bi bi-play-fill me-0.5"></i>Làm ca này
            </a>
          </div>
        </div>
      </c:if>

      <!-- Khối 2: Tabs Lịch sử Bệnh án & Cận lâm sàng -->
      <div class="history-card">
        <!-- Tab Navigation -->
        <div class="px-4 pt-3 border-bottom bg-white">
          <ul class="nav custom-nav-tabs" id="patientHistoryTabs" role="tablist">
            <li class="nav-item" role="presentation">
              <button class="nav-link active" id="medical-tab" data-bs-toggle="tab" data-bs-target="#medical-pane" type="button" role="tab" aria-selected="true">
                <i class="bi bi-journal-medical me-1.5"></i>
                Lịch sử các lần khám mắt (${medicalHistory != null ? medicalHistory.size() : 0})
              </button>
            </li>
            <li class="nav-item" role="presentation">
              <button class="nav-link" id="procedures-tab" data-bs-toggle="tab" data-bs-target="#procedures-pane" type="button" role="tab" aria-selected="false">
                <i class="bi bi-clipboard2-pulse me-1.5"></i>
                Các ca Cận lâm sàng & Thủ thuật (${pastOrders != null ? pastOrders.size() : 0})
              </button>
            </li>
          </ul>
        </div>

        <!-- Tab Content -->
        <div class="tab-content" id="patientHistoryTabsContent">
          
          <!-- TAB 1: Lịch sử khám bệnh -->
          <div class="tab-pane fade show active p-0" id="medical-pane" role="tabpanel" aria-labelledby="medical-tab">
            <c:choose>
              <c:when test="${empty medicalHistory}">
                <div class="p-5 text-center text-muted">
                  <i class="bi bi-journal-x mb-2" style="font-size: 40px; display: inline-block;"></i>
                  <p class="mb-0 fw-semibold">Bệnh nhân chưa có lịch sử bệnh án nào được ghi nhận trước đây.</p>
                </div>
              </c:when>
              <c:otherwise>
                <div class="table-responsive">
                  <table class="table history-table mb-0">
                    <thead>
                      <tr>
                        <th style="width: 120px;">Ngày khám</th>
                        <th style="width: 190px;">Bác sĩ phụ trách</th>
                        <th>Chẩn đoán lâm sàng</th>
                        <th>Kết quả đo & Khám mắt</th>
                        <th style="width: 200px;">Kết luận của Bác sĩ</th>
                        <th style="width: 120px; text-align: center;">Thao tác</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="rec" items="${medicalHistory}">
                        <tr>
                          <td>
                            <div class="fw-bold text-dark">
                              <fmt:formatDate value="${rec.createdAt}" pattern="dd/MM/yyyy" />
                            </div>
                            <div class="text-muted small">
                              <fmt:formatDate value="${rec.createdAt}" pattern="HH:mm" />
                            </div>
                          </td>
                          <td>
                            <div class="fw-semibold text-dark">
                              <c:out value="${rec.doctorName}" />
                            </div>
                            <div class="text-teal small">
                              <c:out value="${rec.doctorSpecialty != null ? rec.doctorSpecialty : 'Bác sĩ nhãn khoa'}" />
                            </div>
                          </td>
                          <td>
                            <div class="text-dark" style="line-height: 1.4;">
                              <c:choose>
                                <c:when test="${not empty rec.clinicalDiagnosis}">
                                  <c:out value="${rec.clinicalDiagnosis}" />
                                </c:when>
                                <c:otherwise>
                                  <span class="text-muted fst-italic">Không có ghi chú</span>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </td>
                          <td>
                            <div class="text-secondary small" style="line-height: 1.4;">
                              <c:choose>
                                <c:when test="${not empty rec.examinationResult}">
                                  <c:out value="${rec.examinationResult}" />
                                </c:when>
                                <c:otherwise>
                                  <span class="text-muted fst-italic">Chưa có kết quả kiểm tra</span>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </td>
                          <td>
                            <div class="text-dark small" style="line-height: 1.4;">
                              <c:choose>
                                <c:when test="${not empty rec.conclusion}">
                                  <i class="bi bi-check2 text-success me-1"></i><c:out value="${rec.conclusion}" />
                                </c:when>
                                <c:otherwise>
                                  <span class="text-muted fst-italic">Đang theo dõi</span>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </td>
                          <td class="text-center">
                            <a href="${pageContext.request.contextPath}/profile/medical-record?id=${rec.recordId}" 
                               target="_blank" 
                               class="btn btn-sm btn-outline-teal rounded-pill px-2.5 py-1" 
                               style="font-size: 12px; font-weight: 600;"
                               title="Xem chi tiết phiếu khám & đơn thuốc">
                              <i class="bi bi-eye me-1"></i>Xem chi tiết
                            </a>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- TAB 2: Lịch sử các ca Cận lâm sàng & Thủ thuật -->
          <div class="tab-pane fade p-0" id="procedures-pane" role="tabpanel" aria-labelledby="procedures-tab">
            <c:choose>
              <c:when test="${empty pastOrders}">
                <div class="p-5 text-center text-muted">
                  <i class="bi bi-clipboard2-x mb-2" style="font-size: 40px; display: inline-block;"></i>
                  <p class="mb-0 fw-semibold">Bệnh nhân chưa từng làm thủ thuật hoặc cận lâm sàng nào tại phòng khám.</p>
                </div>
              </c:when>
              <c:otherwise>
                <div class="table-responsive">
                  <table class="table history-table mb-0">
                    <thead>
                      <tr>
                        <th style="width: 100px;">Mã phiếu</th>
                        <th>Dịch vụ thủ thuật / Cận lâm sàng</th>
                        <th style="width: 180px;">Bác sĩ chỉ định</th>
                        <th style="width: 180px;">KTV phụ trách</th>
                        <th style="width: 130px; text-align: center;">Trạng thái</th>
                        <th style="width: 120px; text-align: center;">Thao tác</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="po" items="${pastOrders}">
                        <tr class="${currentOrder != null && currentOrder.orderId == po.orderId ? 'table-light' : ''}">
                          <td>
                            <span class="fw-semibold text-secondary">
                              #CD-${po.orderId}
                            </span>
                          </td>
                          <td>
                            <div class="fw-semibold text-dark">
                              <c:out value="${po.serviceName}" />
                            </div>
                            <div class="d-flex align-items-center gap-2 mt-0.5">
                              <span class="badge bg-light text-secondary border" style="font-size: 11px;">
                                <c:out value="${po.roomName != null ? po.roomName : 'Phòng Cận lâm sàng'}" />
                              </span>
                              <span class="text-teal small fw-bold">
                                <fmt:formatNumber value="${po.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                              </span>
                            </div>
                          </td>
                          <td>
                            <div class="text-dark small">
                              <i class="bi bi-person-badge text-success me-1"></i><c:out value="${po.doctorName}" />
                            </div>
                            <div class="text-muted small">
                              <fmt:formatDate value="${po.recordCreatedAt}" pattern="dd/MM/yyyy HH:mm" />
                            </div>
                          </td>
                          <td>
                            <div class="text-dark small">
                              <c:choose>
                                <c:when test="${not empty po.specialistName}">
                                  <i class="bi bi-person-check text-teal me-1"></i><c:out value="${po.specialistName}" />
                                </c:when>
                                <c:otherwise>
                                  <span class="text-muted fst-italic">Chưa chỉ định</span>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </td>
                          <td class="text-center">
                            <c:choose>
                              <c:when test="${po.status == 'Pending'}">
                                <span class="badge-status-pending">Chờ thực hiện</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge-status-completed">Đã hoàn tất</span>
                              </c:otherwise>
                            </c:choose>
                          </td>
                          <td class="text-center">
                            <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${po.orderId}" 
                               class="btn btn-sm ${po.status == 'Pending' ? 'btn-teal' : 'btn-outline-secondary'} py-1 px-2.5 rounded-pill" 
                               style="font-size: 12px; font-weight: 600;">
                              <c:choose>
                                <c:when test="${po.status == 'Pending'}">
                                  <i class="bi bi-play-fill me-0.5"></i>Làm ca
                                </c:when>
                                <c:otherwise>
                                  <i class="bi bi-eye me-0.5"></i>Xem KQ
                                </c:otherwise>
                              </c:choose>
                            </a>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

        </div>
      </div>

    </main>
  </div>

  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
