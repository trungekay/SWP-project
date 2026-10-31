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
  <!-- Doctor Forms Design System (for Read-only Clinical Screen) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/doctor-forms.css?v=9">
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
      <c:remove var="successMessage" scope="session" />

      <c:if test="${not empty sessionScope.errorMessage}">
        <div class="procedure-toast-alert error mb-4" role="alert">
          <div class="d-flex align-items-center gap-2.5">
            <i class="bi bi-exclamation-triangle-fill fs-5 text-danger"></i>
            <span class="text-dark fw-semibold"><c:out value="${sessionScope.errorMessage}" /></span>
          </div>
          <button type="button" class="btn-close" data-bs-dismiss="alert" onclick="this.closest('.procedure-toast-alert').remove()" aria-label="Đóng"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
      </c:if>

      <c:if test="${not empty sessionScope.infoMessage}">
        <div class="procedure-toast-alert mb-4" style="border-left: 4px solid #0284c7 !important; border-color: #bae6fd;" role="note">
          <div class="d-flex align-items-center gap-2.5">
            <i class="bi bi-info-circle-fill fs-5 text-info"></i>
            <span class="text-dark fw-semibold"><c:out value="${sessionScope.infoMessage}" /></span>
          </div>
          <button type="button" class="btn-close" data-bs-dismiss="alert" onclick="this.closest('.procedure-toast-alert').remove()" aria-label="Đóng"></button>
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
                  <i class="bi bi-clipboard2-pulse me-1"></i>Hàng đợi thủ thuật
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
            <span>Thực hiện: <c:out value="${order.serviceName}" /></span>
            <span class="badge bg-teal text-white fs-6 py-1 px-2.5 rounded-pill">#CD-${order.orderId}</span>
          </h4>
        </div>

        <div class="d-flex align-items-center gap-2">
          <!-- Nút In biên bản thủ thuật -->
          <button type="button" class="btn btn-sm btn-white border rounded-pill px-3 py-1.5 shadow-sm text-dark fw-semibold d-inline-flex align-items-center gap-1.5" onclick="printResultSheet()">
            <i class="bi bi-printer text-teal"></i>
            <span>In biên bản thủ thuật</span>
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

          <!-- 2. Bác sĩ chỉ định & Chẩn đoán -->
          <div class="col-lg-5 col-md-6 border-lg-end pe-lg-3">
            <div class="d-flex flex-column gap-2">
              <div class="d-flex align-items-center justify-content-between flex-wrap gap-1">
                <div class="d-flex align-items-center gap-2">
                  <i class="bi bi-person-badge text-teal fs-5"></i>
                  <div class="d-flex align-items-center gap-1.5 flex-wrap">
                    <span class="small text-muted">Bác sĩ chỉ định:</span>
                    <strong class="text-dark small"><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></strong>
                    <span class="badge bg-light text-secondary border fw-medium" style="font-size: 10.5px;">
                      <c:out value="${record.doctorSpecialty != null ? record.doctorSpecialty : 'Chuyên khoa Mắt'}" />
                    </span>
                  </div>
                </div>
                <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" target="_blank" class="badge bg-white text-teal border border-teal-subtle text-decoration-none fw-semibold px-2.5 py-1 rounded-pill shadow-xs d-inline-flex align-items-center gap-1 hover-teal" title="Mở Bệnh án tổng thể">
                  <i class="bi bi-file-earmark-medical"></i>#BA-${order.recordId} <i class="bi bi-box-arrow-up-right" style="font-size: 8.5px;"></i>
                </a>
              </div>

              <!-- Chẩn đoán lâm sàng & Ghi chú chỉ định -->
              <div class="diagnosis-overview-box">
                <div class="d-flex align-items-center justify-content-between mb-1">
                  <span class="diagnosis-overview-label">
                    <i class="bi bi-activity me-1 text-teal"></i>Chẩn đoán lâm sàng
                  </span>
                  <span class="text-muted" style="font-size: 11px;">
                    <i class="bi bi-clock me-1"></i><fmt:formatDate value="${order.recordCreatedAt != null ? order.recordCreatedAt : record.createdAt}" pattern="HH:mm - dd/MM" />
                  </span>
                </div>
                <div class="diagnosis-overview-text">
                  <c:choose>
                    <c:when test="${not empty record.clinicalDiagnosis}">
                      <c:out value="${record.clinicalDiagnosis}" />
                    </c:when>
                    <c:when test="${not empty examForm.clinicalDiagnosis}">
                      <c:out value="${examForm.clinicalDiagnosis}" />
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted fw-normal fst-italic">Chưa ghi nhận chẩn đoán sơ bộ.</span>
                    </c:otherwise>
                  </c:choose>
                </div>
                <c:if test="${not empty order.referralNotes}">
                  <div class="referral-note-inline">
                    <span class="referral-note-tag">Ghi chú chỉ định:</span>
                    <span class="referral-note-content"><c:out value="${order.referralNotes}" /></span>
                  </div>
                </c:if>
              </div>
            </div>
          </div>

          <!-- 3. Địa điểm thực hiện & Trạng thái -->
          <div class="col-lg-3 col-md-6 ps-lg-2">
            <div class="d-flex flex-column gap-2">
              <div class="d-flex justify-content-between align-items-center">
                <span class="text-muted small">Phòng thủ thuật:</span>
                <span class="badge bg-light text-dark border px-2.5 py-1 fw-semibold">
                  <i class="bi bi-door-open text-teal me-1"></i><c:out value="${order.roomName != null ? order.roomName : 'P. Tiểu phẫu & Can thiệp'}" />
                </span>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                <span class="text-muted small">Phí thủ thuật:</span>
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
                    <span class="badge-status-inprogress"><span class="pulse-dot"></span>Đang tiếp nhận</span>
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
            <div class="step-title">1. Y lệnh & Khám mắt ban đầu</div>
            <div class="step-desc">Bác sĩ khám và chỉ định thủ thuật</div>
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
            <div class="step-title">2. Lập Biên bản & Thực hiện</div>
            <div class="step-desc">${order.status == 'Completed' ? 'Đã hoàn tất can thiệp thủ thuật' : 'KTV đang thực hiện kỹ thuật'}</div>
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
            <div class="step-title">3. Bàn giao kết quả cho Bác sĩ</div>
            <div class="step-desc">${order.status == 'Completed' ? 'Đã đồng bộ kết quả về bệnh án' : 'Sẵn sàng trả về ca khám chính'}</div>
          </div>
        </div>
      </div>

      <!-- ======================================================== -->
      <!-- KHU VỰC THAO TÁC CHÍNH: 2 CỘT SONG SONG (SPLIT SCREEN)    -->
      <!-- ======================================================== -->
      <div class="row g-4">
        
        <!-- ====================================================== -->
        <!-- CỘT TRÁI (COL-LG-5): Y LỆNH & ĐO MẮT BÁC SĨ (READ-ONLY)-->
        <!-- ====================================================== -->
        <div class="col-lg-5">
          
          <!-- Header mô phỏng màn hình Bác sĩ thu nhỏ -->
          <div class="doctor-mini-screen-header mb-3">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <span class="doctor-form-eyebrow">HỒ SƠ KHÁM LÂM SÀNG</span>
                <h5 class="fw-bold text-dark mb-0 d-flex align-items-center gap-2">
                  <i class="bi bi-file-earmark-medical text-teal"></i>
                  <span>Phiếu khám của Bác sĩ</span>
                </h5>
              </div>
              <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" target="_blank" class="badge bg-white text-teal border border-teal-subtle text-decoration-none fw-semibold px-2.5 py-1 rounded-pill shadow-xs hover-teal" title="Mở Bệnh án tổng thể">
                <i class="bi bi-box-arrow-up-right me-1"></i>Hồ sơ gốc
              </a>
            </div>
            <p class="text-muted small mb-0 mt-1">Ghi nhận thị lực, nhãn áp và nhận định ban đầu của Bác sĩ khám.</p>
          </div>

          <!-- CỘT TRÁI: MÀN HÌNH KHÁM CỦA BÁC SĨ THU NHỎ (READ-ONLY) -->
          <div class="doctor-form-mini-stack mb-4">
            
            <!-- Phần 1: Lý do đến khám -->
            <section class="doctor-form-card">
              <div class="doctor-form-card-heading">
                <span class="doctor-form-icon"><i class="bi bi-chat-left-text" aria-hidden="true"></i></span>
                <div><h2>Lý do đến khám</h2><p>Triệu chứng và bệnh sử liên quan</p></div>
              </div>
              <div class="doctor-form-fields">
                <c:if test="${not empty examForm.staffNotes}">
                  <div class="doctor-form-prior-diagnoses doctor-form-span">
                    <strong>Ghi chú từ nhân viên tiếp nhận</strong>
                    <p><c:out value="${examForm.staffNotes}" /></p>
                  </div>
                </c:if>
                <label class="doctor-form-field doctor-form-span"><span>Triệu chứng chính</span>
                  <textarea rows="2" readonly><c:out value="${not empty examForm.chiefComplaint ? examForm.chiefComplaint : 'Không ghi nhận'}" /></textarea>
                </label>
                <label class="doctor-form-field doctor-form-span"><span>Tiền sử mắt và bệnh sử liên quan</span>
                  <textarea rows="2" readonly><c:out value="${not empty examForm.medicalHistory ? examForm.medicalHistory : 'Không có tiền sử đặc biệt'}" /></textarea>
                </label>
              </div>
            </section>

            <!-- Phần 2: Thị lực và nhãn áp -->
            <section class="doctor-form-card">
              <div class="doctor-form-card-heading">
                <span class="doctor-form-icon blue"><i class="bi bi-eye" aria-hidden="true"></i></span>
                <div><h2>Thị lực và nhãn áp</h2><p>Ghi riêng kết quả mắt phải (OD) và mắt trái (OS)</p></div>
              </div>
              <div class="doctor-form-table-wrap">
                <table class="doctor-form-matrix">
                  <thead>
                    <tr>
                      <th scope="col">Chỉ số</th>
                      <th scope="col">Mắt phải (OD)</th>
                      <th scope="col">Mắt trái (OS)</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <th scope="row">Thị lực không kính</th>
                      <td><input readonly value="<c:out value='${not empty examForm.odUncorrected ? examForm.odUncorrected : "--"}' />"></td>
                      <td><input readonly value="<c:out value='${not empty examForm.osUncorrected ? examForm.osUncorrected : "--"}' />"></td>
                    </tr>
                    <tr>
                      <th scope="row">Thị lực có kính</th>
                      <td><input readonly value="<c:out value='${not empty examForm.odCorrected ? examForm.odCorrected : "--"}' />"></td>
                      <td><input readonly value="<c:out value='${not empty examForm.osCorrected ? examForm.osCorrected : "--"}' />"></td>
                    </tr>
                    <tr>
                      <th scope="row">Nhãn áp (mmHg)</th>
                      <td><input readonly value="<c:out value='${not empty examForm.odIop ? examForm.odIop : "--"}' />"></td>
                      <td><input readonly value="<c:out value='${not empty examForm.osIop ? examForm.osIop : "--"}' />"></td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <p class="doctor-form-hint">Ghi thị lực theo chuẩn đang sử dụng tại phòng khám.</p>
            </section>

            <!-- Phần 3: Khám thực thể -->
            <section class="doctor-form-card">
              <div class="doctor-form-card-heading">
                <span class="doctor-form-icon amber"><i class="bi bi-clipboard2-pulse" aria-hidden="true"></i></span>
                <div><h2>Khám thực thể</h2><p>Ghi nhận phát hiện qua khám mắt</p></div>
              </div>
              <div class="doctor-form-fields">
                <label class="doctor-form-field"><span>Bán phần trước</span>
                  <textarea rows="3" readonly><c:out value="${not empty examForm.anteriorFindings ? examForm.anteriorFindings : (not empty protocol['doctor_slit_lamp'] ? protocol['doctor_slit_lamp'] : 'Bình thường')}" /></textarea>
                </label>
                <label class="doctor-form-field"><span>Đáy mắt / bán phần sau</span>
                  <textarea rows="3" readonly><c:out value="${not empty examForm.posteriorFindings ? examForm.posteriorFindings : 'Bình thường'}" /></textarea>
                </label>
              </div>
            </section>

            <!-- Phần 4: Kết quả khám -->
            <section class="doctor-form-card">
              <div class="doctor-form-card-heading">
                <span class="doctor-form-icon blue"><i class="bi bi-clipboard2-data" aria-hidden="true"></i></span>
                <div><h2>Kết quả khám</h2><p>Tóm tắt nhận định của Bác sĩ</p></div>
              </div>
              <div class="doctor-form-fields">
                <label class="doctor-form-field doctor-form-span"><span>Kết quả khám</span>
                  <textarea rows="3" readonly><c:out value="${not empty examForm.examinationResult ? examForm.examinationResult : (not empty record.examinationResult ? record.examinationResult : 'Chưa có tóm tắt kết quả')}" /></textarea>
                </label>
              </div>
            </section>

            <!-- Phần 5: Chẩn đoán và kết luận -->
            <section class="doctor-form-card">
              <div class="doctor-form-card-heading">
                <span class="doctor-form-icon violet"><i class="bi bi-journal-check" aria-hidden="true"></i></span>
                <div><h2>Chẩn đoán và kết luận</h2><p>Những thông tin cần thiết để tiếp tục điều trị</p></div>
              </div>
              <div class="doctor-form-fields">
                <label class="doctor-form-field doctor-form-span"><span>Chẩn đoán lâm sàng</span>
                  <input type="text" readonly value="<c:out value='${not empty examForm.clinicalDiagnosis ? examForm.clinicalDiagnosis : (not empty record.clinicalDiagnosis ? record.clinicalDiagnosis : "Chưa có chẩn đoán")}' />">
                </label>
                <label class="doctor-form-field doctor-form-span"><span>Kết luận và hướng xử trí</span>
                  <textarea rows="2" readonly><c:out value="${not empty examForm.conclusion ? examForm.conclusion : (not empty record.conclusion ? record.conclusion : 'Không có ghi nhận bổ sung')}" /></textarea>
                </label>
                <c:if test="${not empty examForm.followUpDate}">
                  <label class="doctor-form-field doctor-form-span"><span>Ngày tái khám dự kiến</span>
                    <input type="text" readonly value="<fmt:formatDate value='${examForm.followUpDate}' pattern='dd/MM/yyyy' />">
                  </label>
                </c:if>
              </div>

              <!-- Khối chỉ định thủ thuật từ bác sĩ -->
              <c:if test="${not empty order.referralNotes || not empty order.serviceName}">
                <div class="doctor-form-surgery">
                  <div class="doctor-form-referral-status active" role="status">
                    <span class="doctor-form-referral-status-icon"><i class="bi bi-clipboard2-check" aria-hidden="true"></i></span>
                    <div>
                      <small>Y LỆNH PHẪU THUẬT / THỦ THUẬT</small>
                      <strong><c:out value="${order.serviceName}" /></strong>
                      <c:if test="${not empty order.referralNotes}">
                        <span class="text-dark mt-1"><c:out value="${order.referralNotes}" /></span>
                      </c:if>
                    </div>
                  </div>
                </div>
              </c:if>
            </section>

          </div>

          <!-- THẺ 2: TO-DO LIST CÁC THỦ THUẬT TRONG CA KHÁM -->
          <div class="custom-card todo-card">
            <div class="card-header-clean">
              <h5 class="card-title-sm text-dark">
                <i class="bi bi-list-check text-warning fs-5"></i>
                Danh mục thủ thuật ca khám (${todoList != null ? todoList.size() : 0})
              </h5>
              <span class="badge bg-light text-secondary border px-2 py-0.5" style="font-size: 11px;">#APT-${record.appointmentId}</span>
            </div>

            <div class="todo-list-group">
              <c:choose>
                <c:when test="${empty todoList}">
                  <div class="p-4 text-center text-muted small">
                    Chỉ có 1 chỉ định thủ thuật này trong ca khám.
                  </div>
                </c:when>
                <c:otherwise>
                  <c:forEach var="todo" items="${todoList}">
                    <div class="todo-item ${todo.orderId == order.orderId ? 'active-item' : ''}" style="cursor: default;">
                      
                      <div class="d-flex align-items-start gap-2.5">
                        <c:if test="${todo.status == 'Completed'}">
                          <div class="pt-0.5">
                            <i class="bi bi-check-circle-fill text-success fs-5"></i>
                          </div>
                        </c:if>
                        <div>
                          <div class="todo-title">
                            <c:out value="${todo.serviceName}" />
                            <c:if test="${todo.orderId == order.orderId}">
                              <span class="badge bg-teal text-white ms-1" style="font-size: 10px; font-weight: 500;">Đang mở</span>
                            </c:if>
                          </div>
                          <div class="todo-subtitle">
                            <span class="text-teal fw-semibold">
                              <fmt:formatNumber value="${todo.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                            <span class="mx-1">•</span>
                            <i class="bi bi-door-open me-0.5"></i><c:out value="${todo.roomName != null ? todo.roomName : 'Phòng Thủ thuật'}" />
                          </div>
                        </div>
                      </div>

                      <div>
                        <c:choose>
                          <c:when test="${todo.status == 'Completed'}">
                            <span class="badge-status-completed" style="font-size: 10.5px;">Đã xong</span>
                          </c:when>
                          <c:when test="${todo.status == 'Cancelled'}">
                            <span class="badge-status-cancelled" style="font-size: 10.5px;">Đã hủy</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge-status-inprogress" style="font-size: 10.5px;">Chờ/Đang làm</span>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </div>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

        </div>

        <!-- ====================================================== -->
        <!-- CỘT PHẢI (COL-LG-7): FORM BIÊN BẢN THỦ THUẬT (SPECIALIST)-->
        <!-- ====================================================== -->
        <div class="col-lg-7">
          
          <div class="custom-card specialist-protocol-card">
            
            <!-- Card Header -->
            <div class="card-header-clean bg-light">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-journal-medical text-primary fs-5"></i>
                <div>
                  <span class="fw-bold text-dark fs-6">Biên bản Thực hiện Thủ thuật</span>
                  <div class="text-muted" style="font-size: 11.5px;">KTV / Phẫu thuật viên: <strong><c:out value="${order.specialistName != null ? order.specialistName : 'Kỹ thuật viên'}" /></strong></div>
                </div>
              </div>
              <c:if test="${order.status == 'Completed'}">
                <div>
                  <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1">
                    <i class="bi bi-check2-circle me-1"></i>Thủ thuật đã hoàn tất
                  </span>
                </div>
              </c:if>
            </div>

            <!-- Card Body: Form Lập Biên Bản -->
            <div class="p-4">

              <!-- FORM CHÍNH CỦA SPECIALIST -->
              <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST" id="protocolForm" data-can-edit="${canEditProcedure}">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <input type="hidden" name="action" id="formAction" value="${order.status == 'Completed' ? 'updateResults' : 'complete'}">
                <input type="hidden" name="noFurtherDoctorWork" id="noFurtherDoctorWork" value="false">
                <!-- Giữ nguyên kết quả khám của Bác sĩ trong trường ẩn để không bị ghi đè mất mát -->
                <input type="hidden" name="doctor_exam_findings" id="doctorExamFindingsInput" value="<c:out value='${protocol["doctor_exam_findings"]}' />">
                <!-- Mắt thực hiện (Hidden input được cập nhật qua các nút bấm) -->
                <input type="hidden" name="procedure_eye" id="procedureEyeInput" value="${not empty protocol['procedure_eye'] ? protocol['procedure_eye'] : 'OD'}">

                <!-- 1. CHỌN MẮT CAN THIỆP (TARGET EYE) -->
                <div class="mb-4">
                  <label class="form-label-custom mb-2">
                    <i class="bi bi-eye-fill text-primary me-1.5"></i>Mắt thực hiện can thiệp
                  </label>
                  <div class="eye-selector-group">
                    <div class="eye-selector-btn ${protocol['procedure_eye'] == 'OD' || empty protocol['procedure_eye'] ? 'active-od' : ''}" 
                         id="btnEyeOD" onclick="selectEye('OD')">
                      <i class="bi bi-arrow-right-circle me-1"></i>Mắt Phải
                    </div>
                    <div class="eye-selector-btn ${protocol['procedure_eye'] == 'OS' ? 'active-os' : ''}" 
                         id="btnEyeOS" onclick="selectEye('OS')">
                      <i class="bi bi-arrow-left-circle me-1"></i>Mắt Trái
                    </div>
                    <div class="eye-selector-btn ${protocol['procedure_eye'] == 'OU' ? 'active-ou' : ''}" 
                         id="btnEyeOU" onclick="selectEye('OU')">
                      <i class="bi bi-arrow-left-right me-1"></i>Cả Hai Mắt
                    </div>
                  </div>
                </div>

                <!-- 2. QUY TRÌNH & DIỄN BIẾN THỦ THUẬT -->
                <div class="mb-4">
                  <label for="procedureSteps" class="form-label-custom mb-2">
                    <i class="bi bi-list-ol text-primary me-1"></i>
                    Quy trình kỹ thuật & Diễn biến thủ thuật <span class="text-danger">*</span>
                  </label>

                  <c:if test="${canEditProcedure}">
                    <!-- Quick Chips cho các bước thực hiện -->
                    <div class="mb-2">
                      <span class="quick-chip" onclick="applyTemplate('chap_leo')">
                        <i class="bi bi-magic me-1 text-teal"></i>Mẫu Chích rạch chắp lẹo
                      </span>
                      <span class="quick-chip" onclick="applyTemplate('le_dao')">
                        <i class="bi bi-magic me-1 text-teal"></i>Mẫu Bơm thông lệ đạo
                      </span>
                      <span class="quick-chip" onclick="applyTemplate('laser_yag')">
                        <i class="bi bi-magic me-1 text-teal"></i>Mẫu Bắn Laser YAG
                      </span>
                      <span class="quick-chip" onclick="applyTemplate('phaco')">
                        <i class="bi bi-magic me-1 text-teal"></i>Mẫu Phẫu thuật Phaco
                      </span>
                      <span class="quick-chip" onclick="applyTemplate('femto')">
                        <i class="bi bi-magic me-1 text-teal"></i>Mẫu Phẫu thuật Lasik/SMILE
                      </span>
                    </div>
                  </c:if>

                  <textarea class="form-control protocol-textarea p-3" 
                            id="procedureSteps" 
                            name="procedure_steps" 
                            rows="5" 
                            placeholder="Mô tả chi tiết các bước sát trùng, thao tác chích rạch / bơm rửa / chiếu laser, diễn biến trong lúc thực hiện..."><c:out value="${protocol['procedure_steps']}" /></textarea>
                  <c:if test="${canEditProcedure}">
                    <div class="form-text small text-muted" style="font-size: 11.5px;">Bắt buộc ghi nhận quy trình thực hiện theo quy chuẩn y khoa.</div>
                  </c:if>
                </div>

                <!-- 3. TÌNH TRẠNG NGAY SAU THỦ THUẬT -->
                <div class="mb-4">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-1.5">
                    <label for="procedureOutcome" class="form-label-custom mb-0">
                      <i class="bi bi-heart-pulse text-success me-1"></i>
                      Tình trạng mắt ngay sau thủ thuật <span class="text-danger">*</span>
                    </label>
                    <c:if test="${canEditProcedure}">
                      <div class="d-flex align-items-center gap-1 flex-wrap">
                        <span class="quick-chip" onclick="appendOutcome('Mắt êm, không chảy máu, mép rạch áp tốt.')">Mắt êm, sạch</span>
                        <span class="quick-chip" onclick="appendOutcome('Lệ đạo thông hoàn toàn, nước trào xuống họng tốt.')">Lệ đạo thông tốt</span>
                        <span class="quick-chip" onclick="appendOutcome('Bao sau mở trong suốt đường kính 3.5mm, IOL cân đối.')">Bao sau trong</span>
                        <span class="quick-chip" onclick="appendOutcome('Bệnh nhân tỉnh táo, tiếp xúc tốt, sinh hiệu ổn định.')">Sinh hiệu ổn định</span>
                      </div>
                    </c:if>
                  </div>
                  <textarea class="form-control protocol-textarea p-3" 
                            id="procedureOutcome" 
                            name="procedure_outcome" 
                            rows="3" 
                            placeholder="Tình trạng vết mổ, mép rạch, cầm máu, cảm giác của bệnh nhân..."><c:out value="${protocol['procedure_outcome']}" /></textarea>
                </div>

                <!-- 4. LỜI DẶN HẬU PHẪU & CHĂM SÓC -->
                <div class="mb-4">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-1.5">
                    <label for="postCare" class="form-label-custom mb-0">
                      <i class="bi bi-prescription2 text-warning me-1"></i>
                      Lời dặn hậu phẫu & Hướng dẫn bệnh nhân
                    </label>
                    <c:if test="${canEditProcedure}">
                      <div class="d-flex align-items-center gap-1 flex-wrap">
                        <span class="quick-chip" onclick="appendPostCare('Băng ép mắt trong 2 giờ đầu. Không dụi tay lên mắt.')">Băng ép 2h</span>
                        <span class="quick-chip" onclick="appendPostCare('Tránh nước vào mắt trong 3 ngày đầu. Đeo kính bảo hộ khi ra ngoài.')">Kiêng nước 3 ngày</span>
                        <span class="quick-chip" onclick="appendPostCare('Nhỏ thuốc kháng sinh và tra mỡ mắt theo đơn Bác sĩ.')">Nhỏ thuốc theo đơn</span>
                        <span class="quick-chip" onclick="appendPostCare('Tái khám sau 24 giờ hoặc liên hệ ngay nếu đau nhức dữ dội.')">Tái khám 24h</span>
                      </div>
                    </c:if>
                  </div>
                  <textarea class="form-control protocol-textarea p-3" 
                            id="postCare" 
                            name="post_care" 
                            rows="3" 
                            placeholder="Ghi nhận lời dặn chăm sóc, theo dõi và bàn giao sau thủ thuật..."><c:out value="${protocol['post_care']}" /></textarea>
                </div>

                <!-- 5. KẾT LUẬN & BÀN GIAO TRẢ VỀ BÁC SĨ -->
                <div class="mb-4">
                  <label for="conclusion" class="form-label-custom">
                    <i class="bi bi-check-circle text-teal me-1"></i>
                    Kết luận của bác sĩ phẫu thuật / thủ thuật
                  </label>
                  <textarea class="form-control protocol-textarea p-2.5" 
                            id="conclusion" 
                            name="conclusion" 
                            rows="2" 
                            placeholder="Ghi kết luận thực hiện và hướng bàn giao..."><c:out value="${protocol['ktv_conclusion']}" /></textarea>
                </div>

                <!-- 6. ACTION BUTTONS -->
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 pt-3 border-top">
                  <div>
                    <!-- Nút In biên bản thủ thuật luôn sẵn sàng -->
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-3.5 py-2 fw-semibold d-inline-flex align-items-center gap-1.5 shadow-sm" onclick="printResultSheet()" title="In biên bản thủ thuật">
                      <i class="bi bi-printer text-teal fs-6"></i>
                      <span>In biên bản</span>
                    </button>
                  </div>

                  <c:if test="${canEditProcedure}">
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                      <c:choose>
                        <c:when test="${order.status != 'Completed'}">
                          <button type="submit" name="action" value="complete" onclick="document.getElementById('formAction').value = 'complete'; document.getElementById('noFurtherDoctorWork').value = 'false';" class="btn btn-primary rounded-pill px-4 py-2 shadow-sm fw-bold">
                            Trả kết quả về BS
                          </button>
                          <button type="submit" name="action" value="completeAndClose" onclick="document.getElementById('formAction').value = 'completeAndClose'; document.getElementById('noFurtherDoctorWork').value = 'true';" class="btn btn-success rounded-pill px-4 py-2 shadow-sm fw-bold">
                            Kết thúc ca khám
                          </button>
                        </c:when>
                        <c:otherwise>
                          <!-- Trạng thái Completed -->
                          <button type="submit" name="action" value="updateResults" onclick="document.getElementById('formAction').value = 'updateResults'; document.getElementById('noFurtherDoctorWork').value = 'false';" class="btn btn-primary rounded-pill px-4 py-2 shadow-sm fw-semibold">
                            Lưu cập nhật biên bản
                          </button>
                          <button type="submit" name="action" value="completeAndClose" onclick="document.getElementById('formAction').value = 'completeAndClose'; document.getElementById('noFurtherDoctorWork').value = 'true';" class="btn btn-success rounded-pill px-4 py-2 shadow-sm fw-bold">
                            Kết thúc ca khám
                          </button>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </c:if>
                </div>

              </form>
            </div>
          </div>

        </div>

      </div>

    </main>
  </div>

  <!-- ======================================================== -->
  <!-- BẢN IN BIÊN BẢN THỦ THUẬT CHUYÊN KHOA (@media print)      -->
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
        <div class="fw-bold" style="font-size: 14px;">MÃ BIÊN BẢN: #CD-${order.orderId}</div>
        <div style="font-size: 12px; color: #555;">Mã bệnh án: #MR-${order.recordId}</div>
        <div style="font-size: 12px; color: #555;">Thời gian in: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm" /></div>
      </div>
    </div>

    <!-- Tiêu đề phiếu -->
    <div class="text-center my-3">
      <h3 class="fw-bold text-uppercase mb-1" style="letter-spacing: 0.5px;">BIÊN BẢN THỰC HIỆN THỦ THUẬT & PHẪU THUẬT MẮT</h3>
      <div class="fw-semibold" style="font-size: 15px; color: #008b74;"><c:out value="${order.serviceName}" /></div>
    </div>

    <!-- Thông tin bệnh nhân & Bác sĩ -->
    <table class="table table-bordered mb-3" style="font-size: 13px;">
      <tr>
        <td style="width: 20%; font-weight: bold; background-color: #f9f9f9;">Họ tên người bệnh:</td>
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
        <td><c:out value="${order.roomName != null ? order.roomName : 'Phòng Tiểu phẫu & Thủ thuật'}" /></td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Chẩn đoán của Bác sĩ:</td>
        <td colspan="3"><c:out value="${record.clinicalDiagnosis != null ? record.clinicalDiagnosis : 'Chưa ghi nhận'}" /></td>
      </tr>
    </table>

    <!-- Kết quả khám ban đầu của Bác sĩ -->
    <h6 class="fw-bold text-uppercase mt-4 mb-2" style="font-size: 13px;">I. KẾT QUẢ ĐO MẮT & KHÁM THỰC THỂ CỦA BÁC SĨ</h6>
    <div class="p-2.5 border rounded bg-light mb-3" style="font-size: 12.5px; min-height: 40px; white-space: pre-wrap;">
      <c:choose>
        <c:when test="${not empty examForm.odUncorrected || not empty examForm.odIop || not empty examForm.anteriorFindings}">
          <div><strong>Thị lực:</strong> OD: ${not empty examForm.odUncorrected ? examForm.odUncorrected : '--'} (có kính: ${not empty examForm.odCorrected ? examForm.odCorrected : '--'}) | OS: ${not empty examForm.osUncorrected ? examForm.osUncorrected : '--'} (có kính: ${not empty examForm.osCorrected ? examForm.osCorrected : '--'})</div>
          <div><strong>Nhãn áp (IOP):</strong> OD: ${not empty examForm.odIop ? examForm.odIop : '--'} mmHg | OS: ${not empty examForm.osIop ? examForm.osIop : '--'} mmHg</div>
          <c:if test="${not empty examForm.anteriorFindings}"><div><strong>Bán phần trước:</strong> <c:out value="${examForm.anteriorFindings}" /></div></c:if>
          <c:if test="${not empty examForm.posteriorFindings}"><div><strong>Đáy mắt:</strong> <c:out value="${examForm.posteriorFindings}" /></div></c:if>
          <c:if test="${not empty examForm.examinationResult}"><div><strong>Tóm tắt:</strong> <c:out value="${examForm.examinationResult}" /></div></c:if>
        </c:when>
        <c:when test="${not empty protocol['doctor_exam_findings']}">
          <c:out value="${protocol['doctor_exam_findings']}" />
        </c:when>
        <c:otherwise>Không có ghi nhận bất thường trước thủ thuật.</c:otherwise>
      </c:choose>
      <c:set var="printDocConclusion" value="${not empty examForm.conclusion ? examForm.conclusion : record.conclusion}" />
      <c:if test="${not empty printDocConclusion}">
        <div class="mt-2 pt-2 border-top text-secondary small">
          <strong>Đề xuất điều trị / Kê đơn của Bác sĩ:</strong> <c:out value="${printDocConclusion}" />
        </div>
      </c:if>
    </div>

    <!-- Chi tiết Biên bản thực hiện thủ thuật -->
    <h6 class="fw-bold text-uppercase mt-4 mb-2" style="font-size: 13px;">II. NỘI DUNG BIÊN BẢN THỰC HIỆN THỦ THUẬT</h6>
    <table class="table table-bordered mb-3" style="font-size: 13px;">
      <tr>
        <td style="width: 25%; font-weight: bold; background-color: #f9f9f9;">Mắt can thiệp:</td>
        <td colspan="3" id="print_eye_val" style="font-weight: bold; color: #008b74;">
          <c:choose>
            <c:when test="${protocol['procedure_eye'] == 'OS'}">Mắt Trái</c:when>
            <c:when test="${protocol['procedure_eye'] == 'OU'}">Cả Hai Mắt</c:when>
            <c:otherwise>Mắt Phải</c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Quy trình kỹ thuật:</td>
        <td colspan="3" id="print_steps_val" style="white-space: pre-wrap;"><c:out value="${protocol['procedure_steps']}" /></td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Tình trạng sau thủ thuật:</td>
        <td colspan="3" id="print_outcome_val" style="white-space: pre-wrap;"><c:out value="${protocol['procedure_outcome']}" /></td>
      </tr>
      <tr>
        <td style="font-weight: bold; background-color: #f9f9f9;">Lời dặn hậu phẫu:</td>
        <td colspan="3" id="print_care_val" style="white-space: pre-wrap;"><c:out value="${protocol['post_care']}" /></td>
      </tr>
    </table>

    <!-- Kết luận -->
    <h6 class="fw-bold text-uppercase mt-3 mb-1" style="font-size: 13px;">III. KẾT LUẬN & ĐỀ XUẤT CỦA KỸ THUẬT VIÊN</h6>
    <div id="print_conclusion_val" class="p-2 border rounded bg-light mb-4" style="font-size: 12.5px; min-height: 40px; white-space: pre-wrap;">
      <c:out value="${protocol['ktv_conclusion']}" default="Chưa ghi nhận kết luận." />
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
        <div class="fw-bold">KỸ THUẬT VIÊN / PHẪU THUẬT VIÊN</div>
        <div class="text-muted small fst-italic">(Ký và ghi rõ họ tên)</div>
        <div style="height: 70px;"></div>
        <div class="fw-bold"><c:out value="${order.specialistName != null ? order.specialistName : 'Kỹ thuật viên'}" /></div>
      </div>
    </div>
  </div>



  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  
  <script>
    // 1. Chuyển đổi nút chọn mắt (Target Eye)
    function selectEye(eye) {
      const form = document.getElementById('protocolForm');
      if (form && form.dataset.canEdit !== 'true') return;
      document.getElementById('procedureEyeInput').value = eye;
      
      const btnOD = document.getElementById('btnEyeOD');
      const btnOS = document.getElementById('btnEyeOS');
      const btnOU = document.getElementById('btnEyeOU');

      btnOD.className = 'eye-selector-btn';
      btnOS.className = 'eye-selector-btn';
      btnOU.className = 'eye-selector-btn';

      if (eye === 'OD') {
        btnOD.className = 'eye-selector-btn active-od';
      } else if (eye === 'OS') {
        btnOS.className = 'eye-selector-btn active-os';
      } else if (eye === 'OU') {
        btnOU.className = 'eye-selector-btn active-ou';
      }
      syncPrintData();
    }

    // 2. Chèn mẫu quy trình nhanh theo thủ thuật
    const templates = {
      chap_leo: '1. Sát khuẩn vùng mắt và mi mắt bằng dung dịch Povidone Iodine 5%.\n2. Trải săng vô khuẩn chuyên dụng.\n3. Tiêm gây tê tại chỗ quanh tổn thương bằng Lidocaine 2% (0.5ml).\n4. Cặp kẹp chắp lẹo Desmarres cố định và bộc lộ nang chắp mi.\n5. Dùng dao vi phẫu rạch dọc mặt kết mạc mi tương ứng nang chắp dài 3mm.\n6. Dùng thìa nạo chuyên dụng nạo sạch hoàn toàn bọc mủ và màng bao chắp.\n7. Rửa sạch bằng nước muối sinh lý 0.9%, cầm máu kỹ bằng gạc vô trùng.',
      
      le_dao: '1. Nhỏ dung dịch gây tê bề mặt Tetracaine 0.5% (2 giọt, cách nhau 2 phút).\n2. Dùng que nong điểm lệ nong nhẹ nhàng lỗ lệ dưới.\n3. Dùng kim bơm đầu tù 27G luồn nhẹ theo trục lệ quản vào túi lệ đến khi chạm thành xương.\n4. Bơm từ từ 2ml nước muối sinh lý 0.9% pha kháng sinh Tobramycin.\n5. Bệnh nhân cảm nhận rõ nước trôi xuống họng, nuốt tự nhiên, không trào ngược ra điểm lệ trên/dưới.\n6. Lệ đạo thông hoàn toàn tốt.',
      
      laser_yag: '1. Tra thuốc dãn đồng tử Mydrin-P 1 giọt trước thủ thuật 20 phút.\n2. Nhỏ dung dịch gây tê bề mặt Alcaine 0.5%.\n3. Đặt kính tiếp xúc Abraham chuyên dụng lên giác mạc với gel bảo vệ Methocel.\n4. Định vị chùm tia ngắm Laser YAG đỏ chính xác vào trung tâm bao sau đục.\n5. Bắn Laser YAG mở bao sau trục quang học đường kính 3.5mm (năng lượng 1.8 mJ, 14 phát xung).\n6. Bao sau mở đều, trong suốt, không tổn thương kính IOL. Tra thuốc nhỏ hạ nhãn áp Alphagan P.',
      
      phaco: '1. Sát trùng Povidone Iodine 5%, trải săng lỗ vô khuẩn, đặt vành mi.\n2. Rạch mép giác mạc 2.2mm hướng 12h, rạch đường phụ 1.0mm hướng 2h.\n3. Bơm chất nhầy Healon, xé bao tròn liên tục đường kính 5.2mm.\n4. Tách nước xoay nhân tự do (Hydrodissection).\n5. Tán nhuyễn và hút sạch nhân bằng máy Phaco Alcon Centurion.\n6. Hút sạch chất vỏ bằng tay cầm I/A.\n7. Bơm chất nhầy, đặt thể thủy tinh nhân tạo IOL đơn tiêu trong bao an toàn, rửa sạch chất nhầy, tái tạo tiền phòng kín nước.',
      
      femto: '1. Nhỏ dung dịch gây tê bề mặt Tetracaine 0.5% 2 lần.\n2. Đặt vòng hút Suction Ring, cố định nhãn cầu.\n3. Dùng Laser Femtosecond tạo vạt giác mạc chiều dày 110µm hoàn hảo.\n4. Bộc lộ giường nhu mô giác mạc, kích hoạt hệ thống bám bắt mắt tự động Eye-tracking.\n5. Chiếu Laser Excimer Schwind Amaris bào mòn nhu mô theo thông số đo khúc xạ cá thể hóa.\n6. Rửa sạch buồng vạt bằng BSS, vuốt phẳng vạt giác mạc, tra kháng sinh và đặt kính áp tròng bảo vệ BCL.'
    };

    function applyTemplate(type) {
      const form = document.getElementById('protocolForm');
      if (form && form.dataset.canEdit !== 'true') return;
      const textarea = document.getElementById('procedureSteps');
      if (!textarea) return;
      if (templates[type]) {
        textarea.value = templates[type];
      }
      textarea.focus();
      syncPrintData();
    }

    // 3. Chèn kết quả & Lời dặn nhanh (các phần có thể kết hợp nhưng mỗi nội dung chỉ hiện 1 lần, xuống dòng riêng biệt)
    const outcomeSnippets = [
      'Mắt êm, không chảy máu, mép rạch áp tốt.',
      'Lệ đạo thông hoàn toàn, nước trào xuống họng tốt.',
      'Bao sau mở trong suốt đường kính 3.5mm, IOL cân đối.',
      'Bệnh nhân tỉnh táo, tiếp xúc tốt, sinh hiệu ổn định.'
    ];

    const postCareSnippets = [
      'Băng ép mắt trong 2 giờ đầu. Không dụi tay lên mắt.',
      'Tránh nước vào mắt trong 3 ngày đầu. Đeo kính bảo hộ khi ra ngoài.',
      'Nhỏ thuốc kháng sinh và tra mỡ mắt theo đơn Bác sĩ.',
      'Tái khám sau 24 giờ hoặc liên hệ ngay nếu đau nhức dữ dội.'
    ];

    function appendOutcome(text) {
      const form = document.getElementById('protocolForm');
      if (form && form.dataset.canEdit !== 'true') return;
      const el = document.getElementById('procedureOutcome');
      if (!el) return;
      let val = el.value.trim();

      // Nếu đã có nhưng đang bị dính liền trên cùng 1 dòng, tách thành các dòng riêng
      if (val.includes(text)) {
        let changed = false;
        outcomeSnippets.forEach(snip => {
          if (val.includes(snip) && !val.includes('- ' + snip) && !val.includes('\n' + snip)) {
            val = val.replace(snip, '\n- ' + snip);
            changed = true;
          }
        });
        if (changed) {
          val = val.replace(/^\n+/, '').trim();
          if (!val.startsWith('- ') && val.length > 0) val = '- ' + val;
          el.value = val;
          syncPrintData();
        }
        return;
      }

      const line = '- ' + text;
      el.value = val ? val + '\n' + line : line;
      el.focus();
      syncPrintData();
    }

    function appendPostCare(text) {
      const form = document.getElementById('protocolForm');
      if (form && form.dataset.canEdit !== 'true') return;
      const el = document.getElementById('postCare');
      if (!el) return;
      let val = el.value.trim();

      // Nếu đã có nhưng đang bị dính liền trên cùng 1 dòng, tách thành các dòng riêng
      if (val.includes(text)) {
        let changed = false;
        postCareSnippets.forEach(snip => {
          if (val.includes(snip) && !val.includes('- ' + snip) && !val.includes('\n' + snip)) {
            val = val.replace(snip, '\n- ' + snip);
            changed = true;
          }
        });
        if (changed) {
          val = val.replace(/^\n+/, '').trim();
          if (!val.startsWith('- ') && val.length > 0) val = '- ' + val;
          el.value = val;
          syncPrintData();
        }
        return;
      }

      const line = '- ' + text;
      el.value = val ? val + '\n' + line : line;
      el.focus();
      syncPrintData();
    }

    // 4. Đồng bộ dữ liệu Form vào Bản in PDF
    function syncPrintData() {
      const eye = document.getElementById('procedureEyeInput').value;
      const eyeText = eye === 'OS' ? 'Mắt Trái' : (eye === 'OU' ? 'Cả Hai Mắt' : 'Mắt Phải');
      
      const stepsVal = (document.getElementById('procedureSteps') || {}).value || '';
      const outcomeVal = (document.getElementById('procedureOutcome') || {}).value || '';
      const careVal = (document.getElementById('postCare') || {}).value || '';
      const conclusionVal = (document.getElementById('conclusion') || {}).value || 'Chưa ghi nhận kết luận.';

      const setTxt = (id, txt) => {
        const el = document.getElementById(id);
        if (el) el.textContent = txt;
      };

      setTxt('print_eye_val', eyeText);
      setTxt('print_steps_val', stepsVal);
      setTxt('print_outcome_val', outcomeVal);
      setTxt('print_care_val', careVal);
      setTxt('print_conclusion_val', conclusionVal);
    }

    function printResultSheet() {
      syncPrintData();
      window.print();
    }

    window.addEventListener('beforeprint', syncPrintData);

    // 5. Kiểm tra Form trước khi submit & Tự động tách dòng nội dung hiện có
    document.addEventListener('DOMContentLoaded', function () {
      // Tự động tách các câu dính liền thành từng dòng gạch đầu dòng rõ ràng
      const formatExistingLines = (id, snippets) => {
        const el = document.getElementById(id);
        if (!el || !el.value) return;
        let v = el.value.trim();
        let changed = false;
        snippets.forEach(snip => {
          if (v.includes(snip) && !v.includes('- ' + snip) && !v.includes('\n' + snip)) {
            v = v.replace(snip, '\n- ' + snip);
            changed = true;
          }
        });
        if (changed) {
          v = v.replace(/^\n+/, '').trim();
          if (!v.startsWith('- ') && v.length > 0) v = '- ' + v;
          el.value = v;
        }
      };

      formatExistingLines('procedureOutcome', outcomeSnippets);
      formatExistingLines('postCare', postCareSnippets);

      syncPrintData();

      const form = document.getElementById('protocolForm');
      if (form) {
        if (form.dataset.canEdit !== 'true') {
          form.querySelectorAll('input, select, textarea').forEach(control => { control.readOnly = true; });
        }
        form.addEventListener('submit', function (e) {
          const action = document.getElementById('formAction').value;
          if (action === 'complete' || action === 'completeAndClose' || action === 'updateResults') {
            const steps = (document.getElementById('procedureSteps') || {}).value || '';
            const outcome = (document.getElementById('procedureOutcome') || {}).value || '';
            if (steps.trim() === '') {
              e.preventDefault();
              alert('Vui lòng nhập Quy trình & Diễn biến kỹ thuật trước khi Hoàn thành!');
              document.getElementById('procedureSteps').focus();
              return false;
            }
            if (outcome.trim() === '') {
              e.preventDefault();
              alert('Vui lòng ghi nhận Tình trạng sau thủ thuật trước khi Hoàn tất!');
              document.getElementById('procedureOutcome').focus();
              return false;
            }
            if (!(document.getElementById('conclusion').value || '').trim()) {
              e.preventDefault();
              alert('Vui lòng nhập kết luận thủ thuật.');
              document.getElementById('conclusion').focus();
              return;
            }
            if (action === 'completeAndClose') {
              if (document.getElementById('noFurtherDoctorWork')) {
                document.getElementById('noFurtherDoctorWork').value = 'true';
              }
              if (!confirm('Xác nhận hoàn tất thủ thuật và kết thúc ca khám này?')) {
                e.preventDefault();
                return false;
              }
            }
          }
        });
      }
    });
  </script>

</body>
</html>
