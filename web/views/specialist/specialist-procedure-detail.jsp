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

          <!-- 2. Bác sĩ chỉ định & Chẩn đoán sơ bộ -->
          <div class="col-lg-5 col-md-7 border-lg-end pe-lg-3">
            <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap gap-1">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-person-badge text-teal fs-5"></i>
                <div class="d-flex align-items-center gap-1.5 flex-wrap">
                  <span class="small text-muted">Bác sĩ chỉ định:</span>
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
                  <i class="bi bi-activity me-1"></i>Chẩn đoán lâm sàng của Bác sĩ
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
          
          <!-- THẺ 1: Y LỆNH VÀ KẾT QUẢ KHÁM CỦA BÁC SĨ -->
          <div class="custom-card doctor-findings-card">
            <div class="card-header-clean bg-light">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-clipboard2-pulse text-teal fs-5"></i>
                <span class="fw-bold text-dark fs-6">Y lệnh & Đánh giá của Bác sĩ</span>
              </div>
            </div>

            <div class="p-3 d-flex flex-column gap-3">
              <!-- Thông tin Bác sĩ khám chính -->
              <div class="doctor-info-badge d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                  <div class="doctor-avatar-circle me-2.5">
                    BS
                  </div>
                  <div>
                    <div class="fw-bold text-dark small"><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></div>
                    <div class="text-muted" style="font-size: 11.5px;"><c:out value="${record.doctorSpecialty != null ? record.doctorSpecialty : 'Bác sĩ Khám & Chẩn đoán'}" /></div>
                  </div>
                </div>
                <div class="text-end">
                  <span class="badge bg-light text-secondary border" style="font-size: 11px;">#MR-${order.recordId}</span>
                  <div class="text-muted" style="font-size: 11px; margin-top: 2px;">
                    <fmt:formatDate value="${order.recordCreatedAt != null ? order.recordCreatedAt : record.createdAt}" pattern="dd/MM/yyyy" />
                  </div>
                </div>
              </div>

              <!-- Chẩn đoán lâm sàng - Card nổi bật chuẩn Y khoa -->
              <div class="diagnosis-callout-card">
                <div class="diagnosis-callout-header">
                  <i class="bi bi-activity text-teal"></i>Chẩn đoán lâm sàng chuyên khoa
                </div>
                <div class="diagnosis-callout-body">
                  <c:choose>
                    <c:when test="${not empty record.clinicalDiagnosis}">
                      <c:out value="${record.clinicalDiagnosis}" />
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted fw-normal fst-italic">Bác sĩ chưa có ghi nhận chẩn đoán.</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>

              <!-- Kết quả đo khám & Thông số mắt của Bác sĩ -->
              <div>
                <label class="form-label-custom d-flex align-items-center gap-1.5 text-secondary mb-2">
                  <i class="bi bi-eye text-teal"></i>Kết quả khám & Thông số mắt
                </label>
                <c:choose>
                  <c:when test="${not empty protocol['doctor_va'] || not empty protocol['doctor_iop']}">
                    <div class="d-flex flex-column gap-2">
                      <!-- Hàng Thị lực & Nhãn áp -->
                      <div class="row g-2">
                        <div class="col-6">
                          <div class="doctor-stat-badge">
                            <div class="doctor-stat-title">
                              <i class="bi bi-eye text-primary"></i>Thị lực
                            </div>
                            <div class="doctor-stat-value"><c:out value="${protocol['doctor_va']}" /></div>
                          </div>
                        </div>
                        <div class="col-6">
                          <div class="doctor-stat-badge">
                            <div class="doctor-stat-title">
                              <i class="bi bi-speedometer2 text-teal"></i>Nhãn áp (IOP)
                            </div>
                            <div class="doctor-stat-value"><c:out value="${protocol['doctor_iop']}" /></div>
                          </div>
                        </div>
                      </div>
                      <!-- Hộp Khám thực thể -->
                      <c:if test="${not empty protocol['doctor_slit_lamp']}">
                        <div class="doctor-physical-box">
                          <div class="doctor-stat-title mb-1.5">
                            <i class="bi bi-search text-warning"></i>Khám thực thể mắt
                          </div>
                          <div class="text-dark small" style="line-height: 1.55;">
                            <c:out value="${protocol['doctor_slit_lamp']}" />
                          </div>
                        </div>
                      </c:if>
                    </div>
                  </c:when>
                  <c:when test="${not empty protocol['doctor_exam_findings']}">
                    <div class="doctor-physical-box">
                      <div class="text-dark small" style="line-height: 1.55;">
                        <c:out value="${protocol['doctor_exam_findings']}" />
                      </div>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="doctor-physical-box text-muted fst-italic">
                      Bác sĩ chưa nhập kết quả khám thực thể ban đầu. Vui lòng căn cứ theo chẩn đoán lâm sàng để thực hiện thủ thuật.
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>

              <!-- Đề xuất điều trị & Kê đơn của Bác sĩ -->
              <c:if test="${not empty record.conclusion}">
                <div class="doctor-proposal-card">
                  <div class="doctor-proposal-header">
                    <i class="bi bi-prescription2 me-1"></i>Đề xuất điều trị & Kê đơn của Bác sĩ
                  </div>
                  <div class="doctor-proposal-body">
                    <c:out value="${record.conclusion}" />
                  </div>
                </div>
              </c:if>

              <!-- Dịch vụ thủ thuật được chỉ định -->
              <div class="p-3 rounded-3 border bg-teal-subtle border-teal-subtle">
                <div class="fw-bold text-teal text-uppercase mb-1.5" style="font-size: 11px; letter-spacing: 0.3px;">
                  <i class="bi bi-tools me-1"></i>Thủ thuật chỉ định thực hiện
                </div>
                <div class="fw-bold text-dark fs-6 mb-1"><c:out value="${order.serviceName}" /></div>
                <div class="d-flex justify-content-between align-items-center small text-secondary">
                  <span>Phòng: <strong><c:out value="${order.roomName != null ? order.roomName : 'P. Tiểu phẫu & Can thiệp'}" /></strong></span>
                  <span class="text-teal fw-bold fs-6">
                    <fmt:formatNumber value="${order.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                  </span>
                </div>
              </div>

            </div>
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
                    <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${todo.orderId}" 
                       class="todo-item ${todo.orderId == order.orderId ? 'active-item' : ''}">
                      
                      <div class="d-flex align-items-start gap-2.5">
                        <div class="pt-0.5">
                          <c:choose>
                            <c:when test="${todo.status == 'Completed'}">
                              <i class="bi bi-check-circle-fill text-success fs-5"></i>
                            </c:when>
                            <c:when test="${todo.status == 'Cancelled'}">
                              <i class="bi bi-x-circle-fill text-danger fs-5"></i>
                            </c:when>
                            <c:otherwise>
                              <i class="bi bi-play-circle-fill text-primary fs-5"></i>
                            </c:otherwise>
                          </c:choose>
                        </div>
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
                    </a>
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
              <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3 py-1 fw-semibold d-inline-flex align-items-center gap-1.5 shadow-sm" onclick="printResultSheet()" title="In biên bản thủ thuật">
                  <i class="bi bi-printer text-teal"></i>
                  <span>In biên bản</span>
                </button>
                <c:choose>
                  <c:when test="${order.status == 'Completed'}">
                    <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1">
                      <i class="bi bi-check2-circle me-1"></i>Thủ thuật đã hoàn tất
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2.5 py-1">
                      <span class="pulse-dot me-1 d-inline-block"></span>Đang tác nghiệp
                    </span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Card Body: Form Lập Biên Bản -->
            <div class="p-4">

              <!-- Thông báo khi Completed -->
              <c:if test="${order.status == 'Completed'}">
                <div class="alert alert-success border-0 bg-success-subtle text-success-emphasis rounded-3 p-3 mb-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
                  <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-check-circle-fill fs-4 text-success"></i>
                    <div>
                      <strong>Thủ thuật đã hoàn tất thành công!</strong>
                      <div class="small">Biên bản đã được lưu và đồng bộ về hồ sơ bệnh án của Bác sĩ.</div>
                    </div>
                  </div>
                  <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn btn-sm btn-outline-success rounded-pill px-3 py-1.5 fw-bold" onclick="printResultSheet()">
                      <i class="bi bi-printer me-1"></i>In biên bản
                    </button>
                    <a href="${pageContext.request.contextPath}/profile/medical-record?id=${order.recordId}" target="_blank" class="btn btn-sm btn-teal rounded-pill px-3 py-1.5 fw-bold text-white shadow-sm d-inline-flex align-items-center gap-1.5">
                      <i class="bi bi-file-earmark-medical"></i>
                      <span>Xem Bệnh án</span>
                    </a>
                  </div>
                </div>
              </c:if>

              <!-- FORM CHÍNH CỦA SPECIALIST -->
              <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST" id="protocolForm">
                <input type="hidden" name="orderId" value="${order.orderId}">
                <input type="hidden" name="action" id="formAction" value="${order.status == 'Completed' ? 'updateResults' : 'saveDraft'}">
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

                  <textarea class="form-control protocol-textarea p-3" 
                            id="procedureSteps" 
                            name="procedure_steps" 
                            rows="5" 
                            placeholder="Mô tả chi tiết các bước sát trùng, thao tác chích rạch / bơm rửa / chiếu laser, diễn biến trong lúc thực hiện..."><c:out value="${protocol['procedure_steps']}" /></textarea>
                  <div class="form-text small text-muted" style="font-size: 11.5px;">Bắt buộc ghi nhận quy trình thực hiện theo quy chuẩn y khoa.</div>
                </div>

                <!-- 3. TÌNH TRẠNG NGAY SAU THỦ THUẬT -->
                <div class="mb-4">
                  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-1.5">
                    <label for="procedureOutcome" class="form-label-custom mb-0">
                      <i class="bi bi-heart-pulse text-success me-1"></i>
                      Tình trạng mắt ngay sau thủ thuật <span class="text-danger">*</span>
                    </label>
                    <div class="d-flex align-items-center gap-1 flex-wrap">
                      <span class="quick-chip" onclick="appendOutcome('Mắt êm, không chảy máu, mép rạch áp tốt.')">Mắt êm, sạch</span>
                      <span class="quick-chip" onclick="appendOutcome('Lệ đạo thông hoàn toàn, nước trào xuống họng tốt.')">Lệ đạo thông tốt</span>
                      <span class="quick-chip" onclick="appendOutcome('Bao sau mở trong suốt đường kính 3.5mm, IOL cân đối.')">Bao sau trong</span>
                      <span class="quick-chip" onclick="appendOutcome('Bệnh nhân tỉnh táo, tiếp xúc tốt, sinh hiệu ổn định.')">Sinh hiệu ổn định</span>
                    </div>
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
                    <div class="d-flex align-items-center gap-1 flex-wrap">
                      <span class="quick-chip" onclick="appendPostCare('Băng ép mắt trong 2 giờ đầu. Không dụi tay lên mắt.')">Băng ép 2h</span>
                      <span class="quick-chip" onclick="appendPostCare('Tránh nước vào mắt trong 3 ngày đầu. Đeo kính bảo hộ khi ra ngoài.')">Kiêng nước 3 ngày</span>
                      <span class="quick-chip" onclick="appendPostCare('Nhỏ thuốc kháng sinh và tra mỡ mắt theo đơn Bác sĩ.')">Nhỏ thuốc theo đơn</span>
                      <span class="quick-chip" onclick="appendPostCare('Tái khám sau 24 giờ hoặc liên hệ ngay nếu đau nhức dữ dội.')">Tái khám 24h</span>
                    </div>
                  </div>
                  <textarea class="form-control protocol-textarea p-3" 
                            id="postCare" 
                            name="post_care" 
                            rows="3" 
                            placeholder="Hướng dẫn dùng thuốc, băng mắt, kiêng cữ nước bẩn, lịch tái khám..."><c:out value="${protocol['post_care']}" /></textarea>
                </div>

                <!-- 5. KẾT LUẬN & BÀN GIAO TRẢ VỀ BÁC SĨ -->
                <div class="mb-4">
                  <label for="conclusion" class="form-label-custom">
                    <i class="bi bi-check-circle text-teal me-1"></i>
                    Kết luận của KTV / Phẫu thuật viên & Đề xuất trả về Bác sĩ
                  </label>
                  <textarea class="form-control protocol-textarea p-2.5" 
                            id="conclusion" 
                            name="conclusion" 
                            rows="2" 
                            placeholder="Ghi chú hoàn thành gửi trả Bác sĩ khám chính..."><c:out value="${protocol['ktv_conclusion']}" /></textarea>
                </div>

                <!-- 6. ACTION BUTTONS -->
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-3 border-top">
                  <div>
                    <!-- Nút In biên bản thủ thuật luôn sẵn sàng -->
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-3.5 py-2 fw-semibold d-inline-flex align-items-center gap-1.5 shadow-sm" onclick="printResultSheet()" title="In biên bản thủ thuật">
                      <i class="bi bi-printer text-teal fs-6"></i>
                      <span>In biên bản</span>
                    </button>
                  </div>

                  <div class="d-flex align-items-center gap-2">
                    <c:choose>
                      <c:when test="${order.status != 'Completed'}">
                        <!-- Nút lưu nháp -->
                        <button type="submit" name="action" value="saveDraft" onclick="document.getElementById('formAction').value = 'saveDraft';" class="btn btn-light border rounded-pill px-3.5 py-2 text-secondary fw-semibold d-inline-flex align-items-center gap-1.5 shadow-sm" title="Lưu nháp biên bản thủ thuật">
                          <i class="bi bi-save text-muted"></i>
                          <span>Lưu nháp</span>
                        </button>
                        <!-- Nút Hoàn thành chính -->
                        <button type="submit" name="action" value="complete" onclick="document.getElementById('formAction').value = 'complete';" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-2 fw-bold">
                          <i class="bi bi-check2-circle fs-5"></i>
                          <span>Hoàn thành thủ thuật & Trả kết quả về Bác sĩ</span>
                        </button>
                      </c:when>
                      <c:otherwise>
                        <!-- Trạng thái Completed -->
                        <button type="submit" name="action" value="updateResults" onclick="document.getElementById('formAction').value = 'updateResults';" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-1.5 fw-semibold">
                          <i class="bi bi-arrow-repeat"></i>
                          <span>Lưu cập nhật biên bản</span>
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </div>
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
      <c:out value="${not empty protocol['doctor_exam_findings'] ? protocol['doctor_exam_findings'] : 'Không có ghi nhận bất thường trước thủ thuật.'}" />
      <c:if test="${not empty record.conclusion}">
        <div class="mt-2 pt-2 border-top text-secondary small">
          <strong>Đề xuất điều trị / Kê đơn của Bác sĩ:</strong> <c:out value="${record.conclusion}" />
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
      <c:out value="${not empty protocol['ktv_conclusion'] ? protocol['ktv_conclusion'] : 'Thủ thuật hoàn tất an toàn. Bệnh nhân ổn định.'}" />
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
      const textarea = document.getElementById('procedureSteps');
      if (!textarea) return;
      if (templates[type]) {
        if (textarea.value.trim().length > 0) {
          if (confirm('Bạn có muốn thay thế nội dung quy trình hiện tại bằng mẫu gợi ý này không?')) {
            textarea.value = templates[type];
          }
        } else {
          textarea.value = templates[type];
        }
      }
      textarea.focus();
      syncPrintData();
    }

    // 3. Chèn kết quả & Lời dặn nhanh
    function appendOutcome(text) {
      const el = document.getElementById('procedureOutcome');
      if (!el) return;
      if (el.value.trim().length > 0) {
        el.value += ' ' + text;
      } else {
        el.value = text;
      }
      el.focus();
      syncPrintData();
    }

    function appendPostCare(text) {
      const el = document.getElementById('postCare');
      if (!el) return;
      if (el.value.trim().length > 0) {
        el.value += '\n- ' + text;
      } else {
        el.value = '- ' + text;
      }
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
      const conclusionVal = (document.getElementById('conclusion') || {}).value || 'Thủ thuật hoàn tất an toàn.';

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

    // 5. Kiểm tra Form trước khi submit
    document.addEventListener('DOMContentLoaded', function () {
      syncPrintData();

      const form = document.getElementById('protocolForm');
      if (form) {
        form.addEventListener('submit', function (e) {
          const action = document.getElementById('formAction').value;
          if (action === 'complete') {
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
          }
        });
      }
    });
  </script>

</body>
</html>
