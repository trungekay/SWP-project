<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Thực hiện thủ thuật: #CD-${order.orderId} - VisionCare</title>
  
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  
  <!-- Layout CSS (Employee Unified Design System) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">
  <!-- Custom Styles for Screen 36 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/specialist-procedure-detail.css">
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
      
      <!-- Thông báo Flash Messages -->
      <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-check-circle-fill me-2 fs-5 align-middle"></i>
          <strong>Thành công!</strong> <c:out value="${sessionScope.successMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session" />
      </c:if>

      <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2 fs-5 align-middle"></i>
          <strong>Lỗi!</strong> <c:out value="${sessionScope.errorMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
      </c:if>

      <c:if test="${not empty sessionScope.infoMessage}">
        <div class="alert alert-info alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-info-circle-fill me-2 fs-5 align-middle"></i>
          <c:out value="${sessionScope.infoMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="infoMessage" scope="session" />
      </c:if>

      <!-- Top Action Bar & Breadcrumbs -->
      <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
        <div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-1" style="font-size: 13px;">
              <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="text-decoration-none text-secondary">
                  <i class="bi bi-clipboard2-pulse me-1"></i>Hàng đợi cận lâm sàng
                </a>
              </li>
              <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${order.patientId}&orderId=${order.orderId}" class="text-decoration-none text-secondary">
                  BN: <c:out value="${order.patientName}" />
                </a>
              </li>
              <li class="breadcrumb-item active fw-semibold text-dark" aria-current="page">
                Ca #CD-${order.orderId}
              </li>
            </ol>
          </nav>
          <h4 class="fw-bold mb-0 text-dark d-flex align-items-center gap-2">
            <span>Thực hiện kỹ thuật: <c:out value="${order.serviceName}" /></span>
            <span class="badge bg-teal text-white fs-6 py-1 px-2.5 rounded-pill">#CD-${order.orderId}</span>
          </h4>
        </div>

        <div class="d-flex align-items-center gap-2">
          <!-- Nút In phiếu kết quả -->
          <button type="button" class="btn btn-sm btn-white border rounded-pill px-3 py-1.5 shadow-sm text-dark fw-semibold d-inline-flex align-items-center gap-1.5" onclick="printResultSheet()">
            <i class="bi bi-printer text-teal"></i>
            <span>In phiếu kết quả</span>
          </button>
          <!-- Nút Xem Bệnh án tổng thể -->
          <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" 
             target="_blank"
             class="btn btn-sm btn-white border rounded-pill px-3 py-1.5 shadow-sm text-primary fw-semibold d-inline-flex align-items-center gap-1.5"
             title="Mở hồ sơ bệnh án tổng hợp của Bác sĩ">
            <i class="bi bi-file-earmark-medical text-primary"></i>
            <span>Bệnh án tổng thể</span>
          </a>
          <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${order.patientId}&orderId=${order.orderId}" 
             class="btn btn-sm btn-outline-teal rounded-pill px-3 py-1.5 d-inline-flex align-items-center gap-1.5 shadow-sm">
            <i class="bi bi-person-vcard"></i>
            <span>Hồ sơ bệnh nhân</span>
          </a>
          <a href="${pageContext.request.contextPath}/specialist/waiting-list" 
             class="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1.5 d-inline-flex align-items-center gap-1.5 shadow-sm">
            <i class="bi bi-arrow-left"></i>
            <span>Về Hàng đợi</span>
          </a>
        </div>
      </div>

      <!-- ======================================================== -->
      <!-- BANNER TỔNG QUAN: BỆNH NHÂN - CHỈ ĐỊNH CỦA BS - TIẾN TRÌNH -->
      <!-- ======================================================== -->
      <div class="patient-overview-card">
        <div class="row align-items-center g-4">
          <!-- 1. Bệnh nhân -->
          <div class="col-lg-4 col-md-12 border-lg-end pe-lg-3">
            <div class="d-flex align-items-center gap-3">
              <div class="patient-avatar-circle">
                ${order.patientName != null && order.patientName.length() > 0 ? order.patientName.substring(0, 1).toUpperCase() : 'B'}
              </div>
              <div>
                <div class="fw-bold text-dark fs-6 mb-0.5"><c:out value="${order.patientName}" /></div>
                <div class="small text-secondary">
                  <span class="badge bg-light text-dark border px-2 py-0.5" style="font-size: 11px;">#BN-${order.patientId}</span>
                  <span class="mx-1">•</span>
                  <span><fmt:formatDate value="${order.patientDob}" pattern="dd/MM/yyyy" /> (${order.patientAge} tuổi)</span>
                </div>
                <div class="small text-muted mt-1">
                  <i class="bi bi-telephone text-teal me-1"></i><c:out value="${order.patientPhone}" />
                  <c:if test="${not empty order.patientAddress}">
                    <span class="mx-1">•</span>
                    <i class="bi bi-geo-alt text-muted me-0.5"></i><c:out value="${order.patientAddress}" />
                  </c:if>
                </div>
              </div>
            </div>
          </div>

          <!-- 2. Bác sĩ chỉ định & Chẩn đoán sơ bộ -->
          <div class="col-lg-5 col-md-7 border-lg-end pe-lg-3">
            <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap gap-1">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-person-badge text-teal fs-5"></i>
                <div class="d-flex align-items-center gap-1.5 flex-wrap">
                  <span class="small text-muted">Bác sĩ:</span>
                  <strong class="text-dark small"><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></strong>
                  <span class="badge bg-light text-secondary border" style="font-size: 10.5px;"><c:out value="${record.doctorSpecialty != null ? record.doctorSpecialty : 'Chuyên khoa Mắt'}" /></span>
                </div>
              </div>
              <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" target="_blank" class="badge bg-white text-teal border border-teal-subtle text-decoration-none fw-semibold px-2.5 py-1 rounded-pill shadow-xs d-inline-flex align-items-center gap-1 hover-teal" title="Mở Bệnh án tổng thể">
                <i class="bi bi-file-earmark-medical"></i>Bệnh án #BA-${order.recordId} <i class="bi bi-box-arrow-up-right" style="font-size: 9px;"></i>
              </a>
            </div>

            <!-- Chẩn đoán lâm sàng -->
            <div class="diagnosis-alert-box">
              <div class="d-flex align-items-center justify-content-between mb-1 text-nowrap">
                <span class="fw-bold text-teal text-uppercase" style="font-size: 11px; letter-spacing: 0.3px;">
                  <i class="bi bi-activity me-1"></i>Chẩn đoán sơ bộ
                </span>
                <span class="text-muted" style="font-size: 11px;">
                  <i class="bi bi-clock me-1"></i><fmt:formatDate value="${order.recordCreatedAt != null ? order.recordCreatedAt : record.createdAt}" pattern="HH:mm - dd/MM" />
                </span>
              </div>
              <div class="fw-semibold text-dark small" style="line-height: 1.45;">
                <c:choose>
                  <c:when test="${not empty record.clinicalDiagnosis}">
                    <c:out value="${record.clinicalDiagnosis}" />
                  </c:when>
                  <c:otherwise>
                    <span class="text-muted fw-normal fst-italic">Bác sĩ chưa ghi nhận chẩn đoán sơ bộ.</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <c:if test="${not empty order.referralNotes}">
            <div class="col-12">
              <div class="alert alert-info mb-0" role="note" style="white-space: pre-wrap; overflow-wrap: anywhere;">
                <strong><i class="bi bi-journal-medical me-1"></i> Ghi chú chỉ định phẫu thuật:</strong>
                <c:out value="${order.referralNotes}" />
              </div>
            </div>
          </c:if>

          <!-- 3. Địa điểm thực hiện & Trạng thái -->
          <div class="col-lg-3 col-md-5 ps-lg-2">
            <div class="d-flex flex-column gap-2">
              <div class="d-flex justify-content-between align-items-center">
                <span class="text-muted small">Phòng kỹ thuật:</span>
                <span class="badge bg-light text-dark border px-2.5 py-1 fw-semibold">
                  <i class="bi bi-door-open text-teal me-1"></i><c:out value="${order.roomName != null ? order.roomName : 'P. Cận lâm sàng'}" />
                </span>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <span class="text-muted small">Chi phí dịch vụ:</span>
                <strong class="text-teal fs-6">
                  <fmt:formatNumber value="${order.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </strong>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <span class="text-muted small">Trạng thái:</span>
                <c:choose>
                  <c:when test="${order.status == 'Completed'}">
                    <span class="badge-status-completed"><i class="bi bi-check-circle-fill"></i>Đã hoàn tất</span>
                  </c:when>
                  <c:when test="${order.status == 'Cancelled'}">
                    <span class="badge-status-cancelled"><i class="bi bi-x-circle-fill"></i>Đã hủy</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge-status-inprogress"><span class="pulse-dot"></span>Đang thực hiện</span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- ======================================================== -->
      <!-- QUY TRÌNH THỰC HIỆN 3 BƯỚC (WORKFLOW STEPPER)             -->
      <!-- ======================================================== -->
      <div class="workflow-stepper">
        <!-- Bước 1 -->
        <div class="step-item completed">
          <div class="step-circle"><i class="bi bi-check-lg"></i></div>
          <div class="step-text">
            <div class="step-title">1. Chỉ định của Bác sĩ</div>
            <div class="step-desc">Đã tạo phiếu chỉ định khám</div>
          </div>
        </div>

        <div class="step-divider"></div>

        <!-- Bước 2 -->
        <div class="step-item ${order.status == 'Completed' ? 'completed' : 'active'}">
          <div class="step-circle">
            <c:choose>
              <c:when test="${order.status == 'Completed'}"><i class="bi bi-check-lg"></i></c:when>
              <c:otherwise>2</c:otherwise>
            </c:choose>
          </div>
          <div class="step-text">
            <div class="step-title">2. Thực hiện đo đạc</div>
            <div class="step-desc">${order.status == 'Completed' ? 'Đã đo xong 2 mắt' : 'Đang thực hiện kỹ thuật'}</div>
          </div>
        </div>

        <div class="step-divider"></div>

        <!-- Bước 3 -->
        <div class="step-item ${order.status == 'Completed' ? 'completed' : 'pending'}">
          <div class="step-circle">
            <c:choose>
              <c:when test="${order.status == 'Completed'}"><i class="bi bi-check-lg"></i></c:when>
              <c:otherwise>3</c:otherwise>
            </c:choose>
          </div>
          <div class="step-text">
            <div class="step-title">3. Hoàn tất & Trả kết quả</div>
            <div class="step-desc">${order.status == 'Completed' ? 'Đã gửi trả Bác sĩ khám' : 'Sẵn sàng trả kết quả'}</div>
          </div>
        </div>
      </div>

      <!-- ======================================================== -->
      <!-- KHU VỰC THAO TÁC CHÍNH (2 CỘT)                           -->
      <!-- ======================================================== -->
      <div class="row g-4">
        
        <!-- CỘT TRÁI (COL-LG-8): FORM NHẬP LIỆU CHUYÊN KHOA MẮT -->
        <div class="col-lg-8">
          
          <div class="custom-card">
            <!-- Card Header -->
            <div class="card-header-clean bg-light">
              <div>
                <span class="badge bg-teal text-white me-1.5" style="font-size: 11px;">Phòng Kỹ thuật</span>
                <span class="fw-bold text-dark fs-6"><c:out value="${order.serviceName}" /></span>
              </div>
              <div>
                <c:choose>
                  <c:when test="${order.status == 'Completed'}">
                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1">
                      <i class="bi bi-check2-circle me-1"></i>Đã trả kết quả cho Bác sĩ
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2.5 py-1">
                      <span class="pulse-dot me-1 d-inline-block"></span>Đang thực hiện ca khám
                    </span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Card Body: Form Nhập Liệu -->
            <div class="p-4">

              <!-- Thông báo khi Completed -->
              <c:if test="${order.status == 'Completed'}">
                <div class="alert alert-success border-0 bg-success-subtle text-success-emphasis rounded-3 p-3 mb-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
                  <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                    <div>
                      <strong>Thủ thuật đã hoàn tất thành công!</strong>
                      <div class="small">Kết quả đã được đồng bộ về bệnh án. KTV: <strong><c:out value="${order.specialistName != null ? order.specialistName : 'Kỹ thuật viên'}" /></strong>.</div>
                    </div>
                  </div>
                  <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" target="_blank" class="btn btn-sm btn-teal rounded-pill px-3 py-1.5 fw-bold text-white shadow-sm d-inline-flex align-items-center gap-1.5">
                      <i class="bi bi-file-earmark-medical"></i>
                      <span>Xem Bệnh án</span>
                    </a>
                    <button type="button" class="btn btn-sm btn-outline-success rounded-pill px-3 py-1.5 fw-bold" onclick="printResultSheet()">
                      <i class="bi bi-printer me-1"></i>In kết quả
                    </button>
                  </div>
                </div>
              </c:if>

              <!-- FORM CHÍNH -->
              <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST" id="procedureForm">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <input type="hidden" name="action" id="formAction" value="${order.status == 'Completed' ? 'updateResults' : 'saveDraft'}">

                <!-- ============================================== -->
                <!-- PHẦN 1: BẢNG ĐO ĐẠC 2 MẮT (OD vs OS)            -->
                <!-- ============================================== -->
                <div class="d-flex align-items-center justify-content-between mb-3">
                  <h6 class="fw-bold text-dark mb-0 d-flex align-items-center gap-2">
                    <i class="bi bi-eyeglasses text-teal fs-5"></i>
                    <span>Thông số đo đạc chuyên sâu 2 Mắt (OD / OS)</span>
                  </h6>
                  <span class="badge bg-light text-secondary border px-2 py-1" style="font-size: 11.5px;">Chuẩn Nhãn khoa Quốc tế</span>
                </div>

                <div class="row g-3 mb-4">
                  <!-- MẮT PHẢI (OD - Oculus Dexter) -->
                  <div class="col-md-6">
                    <div class="eye-box-od">
                      <div class="eye-header-od">
                        <span><i class="bi bi-eye me-1.5"></i>MẮT PHẢI (OD)</span>
                        <span class="badge bg-white text-primary border" style="font-size: 10.5px;">Oculus Dexter</span>
                      </div>
                      <div class="p-3">
                        <!-- Thị lực không kính & có kính -->
                        <div class="row g-2 mb-2.5">
                          <div class="col-6">
                            <label class="form-label-opt" for="od_ucva">Thị lực không kính</label>
                            <div class="input-group input-group-sm">
                              <input type="number" class="form-control input-sm-bold" 
                                     id="od_ucva" name="od_ucva" 
                                     min="0" max="10" step="1" inputmode="numeric"
                                     oninput="validateInt0To10(this)"
                                     value="<c:out value='${examData["od_ucva"]}'/>">
                              <span class="input-group-text input-addon-sm">/10</span>
                            </div>
                          </div>
                          <div class="col-6">
                            <label class="form-label-opt" for="od_bcva">Thị lực có kính</label>
                            <div class="input-group input-group-sm">
                              <input type="number" class="form-control input-sm-bold" 
                                     id="od_bcva" name="od_bcva" 
                                     min="0" max="10" step="1" inputmode="numeric"
                                     oninput="validateInt0To10(this)"
                                     value="<c:out value='${examData["od_bcva"]}'/>">
                              <span class="input-group-text input-addon-sm">/10</span>
                            </div>
                          </div>
                        </div>

                        <!-- Khúc xạ: Cầu - Loạn - Trục -->
                        <div class="row g-2 mb-2.5">
                          <div class="col-4">
                            <label class="form-label-opt" for="od_sph">Độ cầu (SPH)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold diopter-field" 
                                     id="od_sph" name="od_sph" 
                                     value="<c:out value='${examData["od_sph"]}'/>"
                                     onblur="validateDiopter(this)"
                                     title="Độ cầu: chỉ nhận bước nhảy có đuôi .00, .25, .5, .75">
                              <span class="input-group-text input-addon-sm">D</span>
                            </div>
                            <div class="invalid-feedback d-none diopter-err" style="font-size: 10.5px; line-height: 1.2;">Chỉ nhận đuôi .00, .25, .5, .75</div>
                          </div>
                          <div class="col-4">
                            <label class="form-label-opt" for="od_cyl">Độ loạn (CYL)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold diopter-field" 
                                     id="od_cyl" name="od_cyl" 
                                     value="<c:out value='${examData["od_cyl"]}'/>"
                                     onblur="validateDiopter(this)"
                                     title="Độ loạn: chỉ nhận bước nhảy có đuôi .00, .25, .5, .75">
                              <span class="input-group-text input-addon-sm">D</span>
                            </div>
                            <div class="invalid-feedback d-none diopter-err" style="font-size: 10.5px; line-height: 1.2;">Chỉ nhận đuôi .00, .25, .5, .75</div>
                          </div>
                          <div class="col-4">
                            <label class="form-label-opt">Trục (AXIS)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold" name="od_axis" 
                                     value="<c:out value='${examData["od_axis"]}'/>">
                              <span class="input-group-text input-addon-sm">°</span>
                            </div>
                          </div>
                        </div>

                        <!-- Nhãn áp IOP -->
                        <div>
                          <label class="form-label-opt d-flex justify-content-between">
                            <span>Nhãn áp (IOP)</span>
                            <span class="text-muted fw-normal" style="font-size: 11px;">Chuẩn: 10 - 21</span>
                          </label>
                          <div class="input-group input-group-sm">
                            <input type="text" class="form-control input-sm-bold" name="od_iop" 
                                   value="<c:out value='${examData["od_iop"]}'/>">
                            <span class="input-group-text input-addon-sm">mmHg</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- MẮT TRÁI (OS - Oculus Sinister) -->
                  <div class="col-md-6">
                    <div class="eye-box-os">
                      <div class="eye-header-os">
                        <span><i class="bi bi-eye me-1.5"></i>MẮT TRÁI (OS)</span>
                        <span class="badge bg-white text-purple border" style="font-size: 10.5px; color: #6d28d9;">Oculus Sinister</span>
                      </div>
                      <div class="p-3">
                        <!-- Thị lực không kính & có kính -->
                        <div class="row g-2 mb-2.5">
                          <div class="col-6">
                            <label class="form-label-opt" for="os_ucva">Thị lực không kính</label>
                            <div class="input-group input-group-sm">
                              <input type="number" class="form-control input-sm-bold" 
                                     id="os_ucva" name="os_ucva" 
                                     min="0" max="10" step="1" inputmode="numeric"
                                     oninput="validateInt0To10(this)"
                                     value="<c:out value='${examData["os_ucva"]}'/>">
                              <span class="input-group-text input-addon-sm">/10</span>
                            </div>
                          </div>
                          <div class="col-6">
                            <label class="form-label-opt" for="os_bcva">Thị lực có kính</label>
                            <div class="input-group input-group-sm">
                              <input type="number" class="form-control input-sm-bold" 
                                     id="os_bcva" name="os_bcva" 
                                     min="0" max="10" step="1" inputmode="numeric"
                                     oninput="validateInt0To10(this)"
                                     value="<c:out value='${examData["os_bcva"]}'/>">
                              <span class="input-group-text input-addon-sm">/10</span>
                            </div>
                          </div>
                        </div>

                        <!-- Khúc xạ: Cầu - Loạn - Trục -->
                        <div class="row g-2 mb-2.5">
                          <div class="col-4">
                            <label class="form-label-opt" for="os_sph">Độ cầu (SPH)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold diopter-field" 
                                     id="os_sph" name="os_sph" 
                                     value="<c:out value='${examData["os_sph"]}'/>"
                                     onblur="validateDiopter(this)"
                                     title="Độ cầu: chỉ nhận bước nhảy có đuôi .00, .25, .5, .75">
                              <span class="input-group-text input-addon-sm">D</span>
                            </div>
                            <div class="invalid-feedback d-none diopter-err" style="font-size: 10.5px; line-height: 1.2;">Chỉ nhận đuôi .00, .25, .5, .75</div>
                          </div>
                          <div class="col-4">
                            <label class="form-label-opt" for="os_cyl">Độ loạn (CYL)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold diopter-field" 
                                     id="os_cyl" name="os_cyl" 
                                     value="<c:out value='${examData["os_cyl"]}'/>"
                                     onblur="validateDiopter(this)"
                                     title="Độ loạn: chỉ nhận bước nhảy có đuôi .00, .25, .5, .75">
                              <span class="input-group-text input-addon-sm">D</span>
                            </div>
                            <div class="invalid-feedback d-none diopter-err" style="font-size: 10.5px; line-height: 1.2;">Chỉ nhận đuôi .00, .25, .5, .75</div>
                          </div>
                          <div class="col-4">
                            <label class="form-label-opt">Trục (AXIS)</label>
                            <div class="input-group input-group-sm">
                              <input type="text" class="form-control input-sm-bold" name="os_axis" 
                                     value="<c:out value='${examData["os_axis"]}'/>">
                              <span class="input-group-text input-addon-sm">°</span>
                            </div>
                          </div>
                        </div>

                        <!-- Nhãn áp IOP -->
                        <div>
                          <label class="form-label-opt d-flex justify-content-between">
                            <span>Nhãn áp (IOP)</span>
                            <span class="text-muted fw-normal" style="font-size: 11px;">Chuẩn: 10 - 21</span>
                          </label>
                          <div class="input-group input-group-sm">
                            <input type="text" class="form-control input-sm-bold" name="os_iop" 
                                   value="<c:out value='${examData["os_iop"]}'/>">
                            <span class="input-group-text input-addon-sm">mmHg</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- THÔNG SỐ BỔ TRỢ (KHOẢNG CÁCH ĐỒNG TỬ PD) -->
                <div class="row g-3 mb-4 p-3 bg-light rounded-3 border">
                  <div class="col-md-6 col-sm-12">
                    <label class="form-label fw-semibold text-dark small mb-1" for="pd">
                      <i class="bi bi-arrows-expand text-teal me-1"></i>Khoảng cách đồng tử (PD)
                    </label>
                    <div class="input-group input-group-sm" style="max-width: 280px;">
                      <input type="number" class="form-control input-sm-bold" 
                             id="pd" name="pd" 
                             min="40" max="85" step="1" inputmode="numeric"
                             oninput="this.value = this.value.replace(/[^0-9]/g, ''); if(parseInt(this.value, 10) > 100) this.value = 100;"
                             value="<c:out value='${examData["pd"]}'/>">
                      <span class="input-group-text input-addon-sm">mm</span>
                    </div>
                    <div class="form-text small text-muted mt-1" style="font-size: 11.5px;">Khoảng cách tâm đồng tử 2 mắt (Pupillary Distance, số nguyên 40 - 85 mm).</div>
                  </div>
                </div>

                <!-- ============================================== -->
                <!-- PHẦN 2: MÔ TẢ CHI TIẾT & HÌNH THÁI HỌC          -->
                <!-- ============================================== -->
                <div class="mb-4">
                  <label for="detailedFindings" class="form-label fw-bold text-dark d-flex align-items-center justify-content-between">
                    <span>
                      <i class="bi bi-card-text text-teal me-1.5"></i>
                      Mô tả chi tiết kỹ thuật & Hình thái học cận lâm sàng
                    </span>
                    <span class="text-muted fw-normal small">Đáy mắt, Giác mạc, Võng mạc</span>
                  </label>
                  <textarea class="form-control result-textarea p-3" 
                            id="detailedFindings" 
                            name="detailed_findings" 
                            rows="4"><c:out value="${examData['detailed_findings']}" /></textarea>
                </div>

                <!-- ============================================== -->
                <!-- PHẦN 3: KẾT LUẬN & GHI CHÚ TRẢ VỀ CHO BÁC SĨ    -->
                <!-- ============================================== -->
                <div class="mb-4">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-2">
                    <label for="conclusion" class="form-label fw-bold text-dark mb-0">
                      <i class="bi bi-chat-left-dots text-teal me-1.5"></i>
                      Kết luận chuyên môn của KTV & Đề xuất trả về cho Bác sĩ
                    </label>
                    <div class="d-flex align-items-center gap-1 flex-wrap">
                      <span class="small text-muted me-1">Mẫu gợi ý nhanh:</span>
                      <span class="quick-chip" onclick="addConclusion('Khúc xạ ổn định, thị lực chỉnh kính tốt 10/10.')">Khúc xạ ổn định</span>
                      <span class="quick-chip" onclick="addConclusion('Cận loạn thị tiến triển hai mắt, cần cấp đơn kính mới.')">Cận loạn tiến triển</span>
                      <span class="quick-chip" onclick="addConclusion('Nhãn áp tăng nhẹ, đề nghị Bác sĩ kiểm tra chuyên sâu Glaucoma.')">Nghi ngờ nhãn áp cao</span>
                      <span class="quick-chip" onclick="addConclusion('Đáy mắt và hoàng điểm bình thường, không thấy tổn thương.')">Đáy mắt bình thường</span>
                    </div>
                  </div>

                  <textarea class="form-control result-textarea p-3" 
                            id="conclusion" 
                            name="conclusion" 
                            rows="3"><c:out value="${examData['conclusion']}" /></textarea>
                </div>

                <!-- ============================================== -->
                <!-- PHẦN 4: ACTION BUTTONS                         -->
                <!-- ============================================== -->
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-3 border-top">
                  <div>
                    <c:if test="${order.status != 'Completed' && order.status != 'Cancelled'}">
                      <button type="button" class="btn btn-outline-danger rounded-pill px-3 py-2 btn-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#cancelModal">
                        <i class="bi bi-x-circle me-1"></i>Hủy ca chỉ định
                      </button>
                    </c:if>
                  </div>

                  <div class="d-flex align-items-center gap-2">
                    <c:choose>
                      <c:when test="${order.status != 'Completed'}">
                        <!-- Nút lưu nháp -->
                        <button type="submit" name="action" value="saveDraft" onclick="document.getElementById('formAction').value = 'saveDraft';" class="btn btn-light border rounded-pill px-3.5 py-2 text-secondary fw-semibold d-inline-flex align-items-center gap-1.5 shadow-sm" title="Lưu nháp thông số đo đạc">
                          <i class="bi bi-save text-muted"></i>
                          <span>Lưu nháp</span>
                        </button>
                        <!-- Nút Hoàn tất chính -->
                        <button type="submit" name="action" value="complete" onclick="document.getElementById('formAction').value = 'complete';" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-2 fw-bold">
                          <i class="bi bi-check2-circle fs-5"></i>
                          <span>Hoàn thành thủ thuật & Trả kết quả về Bác sĩ</span>
                        </button>
                      </c:when>
                      <c:otherwise>
                        <!-- Trạng thái Completed -->
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-3.5 py-2 fw-semibold d-inline-flex align-items-center gap-1.5" onclick="printResultSheet()">
                          <i class="bi bi-printer"></i>
                          <span>In kết quả</span>
                        </button>
                        <button type="submit" name="action" value="updateResults" onclick="document.getElementById('formAction').value = 'updateResults';" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-1.5 fw-semibold">
                          <i class="bi bi-arrow-repeat"></i>
                          <span>Lưu cập nhật kết quả</span>
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>

              </form>
            </div>
          </div>

        </div>

        <!-- CỘT PHẢI (COL-LG-4): TO-DO LIST & HƯỚNG DẪN KỸ THUẬT -->
        <div class="col-lg-4">
          
          <!-- TO-DO LIST CA KHÁM (FEATURE 2) -->
          <div class="custom-card todo-card">
            <div class="card-header-clean">
              <h5 class="card-title-sm text-dark">
                <i class="bi bi-list-check text-warning fs-5"></i>
                To-do list ca khám (${todoList != null ? todoList.size() : 0})
              </h5>
              <span class="badge bg-light text-secondary border px-2 py-0.5" style="font-size: 11px;">#APT-${record.appointmentId}</span>
            </div>

            <div class="todo-list-group">
              <c:choose>
                <c:when test="${empty todoList}">
                  <div class="p-4 text-center text-muted small">
                    Không có thủ thuật nào khác trong ca khám này.
                  </div>
                </c:when>
                <c:otherwise>
                  <c:forEach var="todo" items="${todoList}">
                    <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${todo.orderId}" 
                       class="todo-item ${todo.orderId == order.orderId ? 'active-item' : ''}">
                      
                      <div class="d-flex align-items-start gap-2.5">
                        <div class="pt-0.5">
                          <c:choose>
                            <c:when test="${todo.status == 'Completed'}">
                              <i class="bi bi-check-circle-fill text-success fs-5"></i>
                            </c:when>
                            <c:when test="${todo.status == 'In_Progress'}">
                              <i class="bi bi-play-circle-fill text-primary fs-5"></i>
                            </c:when>
                            <c:when test="${todo.status == 'Cancelled'}">
                              <i class="bi bi-x-circle-fill text-danger fs-5"></i>
                            </c:when>
                            <c:otherwise>
                              <i class="bi bi-hourglass-split text-warning fs-5"></i>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <div>
                          <div class="todo-title">
                            <c:out value="${todo.serviceName}" />
                            <c:if test="${todo.orderId == order.orderId}">
                              <span class="badge bg-teal text-white ms-1" style="font-size: 10px; font-weight: 500;">Đang chọn</span>
                            </c:if>
                          </div>
                          <div class="todo-subtitle">
                            <span class="text-teal fw-semibold">
                              <fmt:formatNumber value="${todo.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                            <span class="mx-1">•</span>
                            <i class="bi bi-door-open me-0.5"></i><c:out value="${todo.roomName != null ? todo.roomName : 'P. Cận lâm sàng'}" />
                          </div>
                        </div>
                      </div>

                      <div>
                        <c:choose>
                          <c:when test="${todo.status == 'Completed'}">
                            <span class="badge-status-completed" style="font-size: 10.5px;">Đã xong</span>
                          </c:when>
                          <c:when test="${todo.status == 'In_Progress'}">
                            <span class="badge-status-inprogress" style="font-size: 10.5px;">Đang làm</span>
                          </c:when>
                          <c:when test="${todo.status == 'Cancelled'}">
                            <span class="badge-status-cancelled" style="font-size: 10.5px;">Đã hủy</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge-status-pending" style="font-size: 10.5px;">Chờ làm</span>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </a>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <!-- BẢNG THAM CHIẾU TIÊU CHUẨN NHÃN KHOA -->
          <div class="custom-card">
            <div class="card-header-clean">
              <h5 class="card-title-sm text-dark">
                <i class="bi bi-info-circle text-teal fs-5"></i>
                Tiêu chuẩn số đo Nhãn khoa
              </h5>
              <span class="badge bg-light text-muted border" style="font-size: 10.5px;">Tham chiếu y khoa</span>
            </div>
            <div class="p-3 small text-secondary">
              <div class="mb-2.5 pb-2 border-bottom">
                <strong class="text-dark d-block mb-1"><i class="bi bi-speedometer2 text-primary me-1"></i>Nhãn áp tiêu chuẩn (IOP):</strong>
                <ul class="ps-3 mb-0" style="line-height: 1.5;">
                  <li><strong>10 - 21 mmHg:</strong> Trong giới hạn sinh lý bình thường.</li>
                  <li><strong>> 21 mmHg:</strong> Nghi ngờ tăng nhãn áp (nguy cơ Glaucoma).</li>
                  <li><strong>< 10 mmHg:</strong> Nhãn áp thấp (cần kiểm tra bong võng mạc).</li>
                </ul>
              </div>

              <div class="mb-2.5 pb-2 border-bottom">
                <strong class="text-dark d-block mb-1"><i class="bi bi-eye text-teal me-1"></i>Thị lực tiêu chuẩn (Visual Acuity):</strong>
                <ul class="ps-3 mb-0" style="line-height: 1.5;">
                  <li><strong>10/10:</strong> Thị lực tối ưu mắt bình thường.</li>
                  <li><strong>5/10 - 7/10:</strong> Giảm thị lực nhẹ, kiểm tra tật khúc xạ.</li>
                  <li><strong>< 4/10:</strong> Giảm thị lực trung bình/nặng.</li>
                </ul>
              </div>

              <div>
                <strong class="text-dark d-block mb-1"><i class="bi bi-shield-check text-success me-1"></i>Lưu ý thao tác an toàn:</strong>
                <div style="line-height: 1.45;">
                  Nhắc bệnh nhân chớp mắt tự nhiên, đặt cằm sát giá đỡ, mắt nhìn thẳng vào điểm tiêu điểm máy đo.
                </div>
              </div>
            </div>
          </div>

        </div>

      </div>

    </main>
  </div>

  <!-- ======================================================== -->
  <!-- BẢN IN PHIẾU KẾT QUẢ CẬN LÂM SÀNG (@media print)          -->
  <!-- ======================================================== -->
  <div id="printableResultSheet">
    <!-- Header Phòng Khám -->
    <div class="d-flex justify-content-between align-items-start pb-3 mb-3 border-bottom">
      <div>
        <h4 class="fw-bold mb-1" style="color: #008b74;">PHÒNG KHÁM CHUYÊN KHOA MẮT VISIONCARE</h4>
        <div style="font-size: 12px; color: #555;">Địa chỉ: 456 Lê Thị Riêng, Phường Bến Thành, Quận 10, TP.HCM</div>
        <div style="font-size: 12px; color: #555;">Hotline: 1800 599 988 | Email: hotro.visioncare@gmail.com</div>
      </div>
      <div class="text-end">
        <div class="fw-bold" style="font-size: 14px;">MÃ PHIẾU: #CD-${order.orderId}</div>
        <div style="font-size: 12px; color: #555;">Mã bệnh án: #MR-${record.recordId}</div>
        <div style="font-size: 12px; color: #555;">Ngày in: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm" /></div>
      </div>
    </div>

    <!-- Tiêu đề phiếu -->
    <div class="text-center my-3">
      <h3 class="fw-bold text-uppercase mb-1" style="letter-spacing: 0.5px;">PHIẾU KẾT QUẢ CẬN LÂM SÀNG & THỦ THUẬT MẮT</h3>
      <div class="fw-semibold" style="font-size: 14px; color: #008b74;"><c:out value="${order.serviceName}" /></div>
    </div>

    <!-- Thông tin bệnh nhân & Bác sĩ -->
    <table class="table table-bordered mb-3" style="font-size: 13px;">
      <tr>
        <td style="width: 20%; font-weight: bold; background-color: #f9f9f9;">Họ và tên bệnh nhân:</td>
        <td style="width: 30%; font-weight: bold;"><c:out value="${order.patientName}" /></td>
        <td style="width: 20%; font-weight: bold; background-color: #f9f9f9;">Mã bệnh nhân:</td>
        <td style="width: 30%;">#BN-${order.patientId}</td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Ngày sinh (Tuổi):</td>
        <td><fmt:formatDate value="${order.patientDob}" pattern="dd/MM/yyyy" /> (${order.patientAge} tuổi)</td>
        <td style="font-weight: bold; background-color: #f9f9f9;">Số điện thoại:</td>
        <td><c:out value="${order.patientPhone}" /></td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Bác sĩ chỉ định:</td>
        <td><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></td>
        <td style="font-weight: bold; background-color: #f9f9f9;">Phòng thực hiện:</td>
        <td><c:out value="${order.roomName != null ? order.roomName : 'Phòng Cận lâm sàng'}" /></td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Chẩn đoán của Bác sĩ:</td>
        <td colspan="3"><c:out value="${record.clinicalDiagnosis != null ? record.clinicalDiagnosis : 'Chưa ghi nhận'}" /></td>
      </tr>
    </table>

    <!-- Bảng kết quả đo 2 mắt -->
    <h6 class="fw-bold text-uppercase mt-4 mb-2" style="font-size: 13px;">I. KẾT QUẢ ĐO ĐẠC CHUYÊN KHOA 2 MẮT (OD - OS)</h6>
    <table class="table table-bordered text-center mb-3" style="font-size: 12.5px;">
      <thead style="background-color: #f2f2f2;">
        <tr>
          <th style="width: 20%;">Mắt</th>
          <th style="width: 16%;">Thị lực (Không kính)</th>
          <th style="width: 16%;">Thị lực (Có kính)</th>
          <th style="width: 16%;">Độ cầu (SPH)</th>
          <th style="width: 16%;">Độ loạn (CYL)</th>
          <th style="width: 16%;">Nhãn áp (IOP)</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td class="fw-bold text-start ps-3" style="background-color: #f9f9f9;">Mắt Phải (OD)</td>
          <td id="print_od_ucva">
            <c:choose>
              <c:when test="${not empty examData['od_ucva'] && examData['od_ucva'] != '--'}">
                <c:out value="${examData['od_ucva']}" />/10
              </c:when>
              <c:otherwise>--</c:otherwise>
            </c:choose>
          </td>
          <td id="print_od_bcva">
            <c:choose>
              <c:when test="${not empty examData['od_bcva'] && examData['od_bcva'] != '--'}">
                <c:out value="${examData['od_bcva']}" />/10
              </c:when>
              <c:otherwise>--</c:otherwise>
            </c:choose>
          </td>
          <td id="print_od_sph"><c:out value="${not empty examData['od_sph'] ? examData['od_sph'] : '--'}" /> D</td>
          <td id="print_od_cyl_axis"><c:out value="${not empty examData['od_cyl'] ? examData['od_cyl'] : '--'}" /> D (Trục: <c:out value="${not empty examData['od_axis'] ? examData['od_axis'] : '--'}" />°)</td>
          <td id="print_od_iop"><c:out value="${not empty examData['od_iop'] ? examData['od_iop'] : '--'}" /> mmHg</td>
        </tr>
        <tr>
          <td class="fw-bold text-start ps-3" style="background-color: #f9f9f9;">Mắt Trái (OS)</td>
          <td id="print_os_ucva">
            <c:choose>
              <c:when test="${not empty examData['os_ucva'] && examData['os_ucva'] != '--'}">
                <c:out value="${examData['os_ucva']}" />/10
              </c:when>
              <c:otherwise>--</c:otherwise>
            </c:choose>
          </td>
          <td id="print_os_bcva">
            <c:choose>
              <c:when test="${not empty examData['os_bcva'] && examData['os_bcva'] != '--'}">
                <c:out value="${examData['os_bcva']}" />/10
              </c:when>
              <c:otherwise>--</c:otherwise>
            </c:choose>
          </td>
          <td id="print_os_sph"><c:out value="${not empty examData['os_sph'] ? examData['os_sph'] : '--'}" /> D</td>
          <td id="print_os_cyl_axis"><c:out value="${not empty examData['os_cyl'] ? examData['os_cyl'] : '--'}" /> D (Trục: <c:out value="${not empty examData['os_axis'] ? examData['os_axis'] : '--'}" />°)</td>
          <td id="print_os_iop"><c:out value="${not empty examData['os_iop'] ? examData['os_iop'] : '--'}" /> mmHg</td>
        </tr>
      </tbody>
    </table>

    <div id="print_pd_section" class="mb-3 small" style="${not empty examData['pd'] ? '' : 'display:none;'}">
      <strong>Khoảng cách đồng tử (PD):</strong> <span id="print_pd_val"><c:out value="${examData['pd']}" /> mm</span>
    </div>

    <!-- Mô tả chi tiết -->
    <h6 class="fw-bold text-uppercase mt-3 mb-1" style="font-size: 13px;">II. MÔ TẢ HÌNH THÁI HỌC & DẤU HIỆU LÂM SÀNG</h6>
    <div id="print_detailed_findings" class="p-2 border rounded bg-light mb-3" style="font-size: 12.5px; min-height: 50px; white-space: pre-wrap;">
      <c:out value="${not empty examData['detailed_findings'] ? examData['detailed_findings'] : 'Không có ghi nhận bất thường.'}" />
    </div>

    <!-- Kết luận -->
    <h6 class="fw-bold text-uppercase mt-3 mb-1" style="font-size: 13px;">III. KẾT LUẬN CỦA KỸ THUẬT VIÊN</h6>
    <div id="print_conclusion" class="p-2 border rounded bg-light mb-4" style="font-size: 12.5px; min-height: 50px; white-space: pre-wrap;">
      <c:out value="${not empty examData['conclusion'] ? examData['conclusion'] : 'Chưa ghi nhận kết luận.'}" />
    </div>

    <!-- Chữ ký -->
    <div class="d-flex justify-content-between text-center mt-5" style="page-break-inside: avoid;">
      <div style="width: 45%;">
        <div class="fw-bold">BÁC SĨ CHỈ ĐỊNH</div>
        <div class="text-muted small fst-italic">(Ký và ghi rõ họ tên)</div>
        <div style="height: 70px;"></div>
        <div class="fw-bold"><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></div>
      </div>
      <div style="width: 45%;">
        <div class="fw-bold">KỸ THUẬT VIÊN THỰC HIỆN</div>
        <div class="text-muted small fst-italic">(Ký và ghi rõ họ tên)</div>
        <div style="height: 70px;"></div>
        <div class="fw-bold"><c:out value="${order.specialistName != null ? order.specialistName : 'Kỹ thuật viên'}" /></div>
      </div>
    </div>
  </div>

  <!-- Modal Xác nhận Hủy ca thủ thuật -->
  <div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <div class="modal-header border-bottom-0 pb-0">
          <h5 class="modal-title fw-bold text-danger" id="cancelModalLabel">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Xác nhận hủy ca thủ thuật
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body py-3">
          Bạn có chắc chắn muốn hủy ca chỉ định <strong>#CD-${order.orderId}</strong> (<c:out value="${order.serviceName}" />) của bệnh nhân <strong><c:out value="${order.patientName}" /></strong> không?
          <div class="alert alert-warning mt-3 small mb-0">
            <i class="bi bi-info-circle me-1"></i>Ca bị hủy sẽ không thể tiếp tục thực hiện và Bác sĩ sẽ nhận được trạng thái đã hủy.
          </div>
        </div>
        <div class="modal-footer border-top-0 pt-0">
          <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST">
            <input type="hidden" name="orderId" value="${order.orderId}">
            <input type="hidden" name="action" value="cancel">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
            <button type="submit" class="btn btn-danger rounded-pill px-4">Đồng ý Hủy ca</button>
          </form>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  
  <script>
    function validateInt0To10(input) {
      if (!input) return;
      let val = input.value;
      if (val === '') return;
      // Chỉ giữ lại số nguyên
      val = val.replace(/[^0-9]/g, '');
      if (val !== '') {
        let num = parseInt(val, 10);
        if (num > 10) num = 10;
        if (num < 0) num = 0;
        input.value = num;
      } else {
        input.value = '';
      }
    }

    function validateDiopter(input) {
      if (!input) return true;
      let val = input.value.trim();
      const parent = input.closest('.col-4');
      const errEl = parent ? parent.querySelector('.diopter-err') : null;

      if (val === '') {
        input.classList.remove('is-invalid');
        if (errEl) errEl.classList.add('d-none');
        return true;
      }

      // Hỗ trợ cả dấu phẩy và dấu chấm
      val = val.replace(',', '.');

      // Tự động thêm 0 nếu nhập bắt đầu bằng dấu chấm: .25 -> 0.25, -.5 -> -0.5
      if (val.startsWith('.')) val = '0' + val;
      else if (val.startsWith('+.')) val = '+0.' + val.substring(2);
      else if (val.startsWith('-.')) val = '-0.' + val.substring(2);

      // Chuẩn hóa định dạng diop
      if (!val.includes('.')) {
        val = val + '.00';
      } else {
        const parts = val.split('.');
        if (parts.length === 2 && parts[1].length === 1) {
          val = val + '0';
        }
      }

      // Kiểm tra chỉ chấp nhận đuôi .00, .25, .50, .75
      const diopterRegex = /^[+-]?\d+\.(00|25|50|75)$/;

      if (!diopterRegex.test(val)) {
        input.classList.add('is-invalid');
        if (errEl) {
          errEl.textContent = 'Chỉ nhận đuôi .00, .25, .5, .75';
          errEl.classList.remove('d-none');
        }
        return false;
      }

      input.value = val;
      input.classList.remove('is-invalid');
      if (errEl) errEl.classList.add('d-none');
      return true;
    }

    // Đồng bộ tức thì toàn bộ thông số từ Form vào Bản in PDF
    function syncPrintData() {
      const getVal = (id) => {
        const el = document.getElementById(id) || document.querySelector('input[name="' + id + '"]');
        return el ? el.value.trim() : '';
      };

      const odUcva = getVal('od_ucva');
      const odBcva = getVal('od_bcva');
      const odSph = getVal('od_sph');
      const odCyl = getVal('od_cyl');
      const odAxis = getVal('od_axis');
      const odIop = getVal('od_iop');

      const osUcva = getVal('os_ucva');
      const osBcva = getVal('os_bcva');
      const osSph = getVal('os_sph');
      const osCyl = getVal('os_cyl');
      const osAxis = getVal('os_axis');
      const osIop = getVal('os_iop');

      const pd = getVal('pd');
      const detailedEl = document.getElementById('detailedFindings');
      const conclusionEl = document.getElementById('conclusion');
      const detailed = detailedEl ? detailedEl.value.trim() : '';
      const conclusion = conclusionEl ? conclusionEl.value.trim() : '';

      const fmtAcuity = (v) => v ? (v.includes('/') ? v : v + '/10') : '--';
      const fmtDiopter = (v) => v ? v + ' D' : '--';
      const fmtCylAxis = (cyl, axis) => {
        let s = cyl ? cyl + ' D' : '--';
        if (axis) s += ' (Trục: ' + axis + '°)';
        return s;
      };
      const fmtIop = (v) => v ? v + ' mmHg' : '--';

      const setTxt = (id, txt) => {
        const el = document.getElementById(id);
        if (el) el.textContent = txt;
      };

      // Cập nhật Mắt Phải
      setTxt('print_od_ucva', fmtAcuity(odUcva));
      setTxt('print_od_bcva', fmtAcuity(odBcva));
      setTxt('print_od_sph', fmtDiopter(odSph));
      setTxt('print_od_cyl_axis', fmtCylAxis(odCyl, odAxis));
      setTxt('print_od_iop', fmtIop(odIop));

      // Cập nhật Mắt Trái
      setTxt('print_os_ucva', fmtAcuity(osUcva));
      setTxt('print_os_bcva', fmtAcuity(osBcva));
      setTxt('print_os_sph', fmtDiopter(osSph));
      setTxt('print_os_cyl_axis', fmtCylAxis(osCyl, osAxis));
      setTxt('print_os_iop', fmtIop(osIop));

      // Khoảng cách đồng tử (PD)
      const pdSec = document.getElementById('print_pd_section');
      const pdVal = document.getElementById('print_pd_val');
      if (pd) {
        if (pdSec) pdSec.style.display = 'block';
        if (pdVal) pdVal.textContent = pd + ' mm';
      } else {
        if (pdSec) pdSec.style.display = 'none';
      }

      // Mô tả & Kết luận
      setTxt('print_detailed_findings', detailed || 'Không có ghi nhận bất thường.');
      setTxt('print_conclusion', conclusion || 'Chưa ghi nhận kết luận.');
    }

    function printResultSheet() {
      syncPrintData();
      window.print();
    }

    // Tự động lắng nghe sự kiện in của trình duyệt (Ctrl+P / Command+P)
    window.addEventListener('beforeprint', syncPrintData);

    // Kiểm tra toàn bộ form trước khi gửi
    document.addEventListener('DOMContentLoaded', function () {
      // Khởi tạo bản in đồng bộ ngay khi load trang
      syncPrintData();

      const form = document.getElementById('procedureForm');
      if (form) {
        form.addEventListener('submit', function (e) {
          const diopterFields = form.querySelectorAll('.diopter-field');
          let hasError = false;
          diopterFields.forEach(function (field) {
            if (!validateDiopter(field)) {
              hasError = true;
              field.focus();
            }
          });

          if (hasError) {
            e.preventDefault();
            alert('Vui lòng kiểm tra lại độ cầu (SPH) và độ loạn (CYL). Chỉ chấp nhận các bước nhảy có đuôi .00, .25, .5, .75!');
            return false;
          }
        });
      }
    });

    function addConclusion(text) {
      const textarea = document.getElementById('conclusion');
      if (!textarea) return;
      if (textarea.value.trim().length > 0) {
        textarea.value += '\n- ' + text;
      } else {
        textarea.value = '- ' + text;
      }
      textarea.focus();
    }
  </script>

</body>
</html>
