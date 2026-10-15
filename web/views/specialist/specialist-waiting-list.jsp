<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hàng đợi Cận lâm sàng - VisionCare</title>
  
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout CSS -->
  <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">
  <!-- Screen 34 Dedicated CSS -->
  <link href="${pageContext.request.contextPath}/assets/css/specialist-waiting-list.css" rel="stylesheet">
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
    <div class="page-content">

      <!-- Header Section -->
      <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
        <div class="page-title">
          <h2>Hàng đợi Cận lâm sàng & Thủ thuật</h2>
          <p>Danh sách bệnh nhân được Bác sĩ chỉ định thực hiện kỹ thuật chẩn đoán và thủ thuật</p>
        </div>
        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="btn btn-outline-secondary d-flex align-items-center gap-2" style="font-size: 13px;">
            <i class="bi bi-arrow-clockwise"></i> Làm mới danh sách
          </a>
        </div>
      </div>

      <!-- KPI Summary Cards -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-xl-4">
          <div class="stat-card">
            <div class="stat-icon total">
              <i class="bi bi-card-checklist"></i>
            </div>
            <div>
              <div class="stat-value"><c:out value="${statusCounts['all'] != null ? statusCounts['all'] : 0}" /></div>
              <div class="stat-label">Tổng số ca chỉ định</div>
            </div>
          </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-4">
          <div class="stat-card">
            <div class="stat-icon pending">
              <i class="bi bi-hourglass-split"></i>
            </div>
            <div>
              <div class="stat-value text-warning"><c:out value="${statusCounts['pending'] != null ? statusCounts['pending'] : 0}" /></div>
              <div class="stat-label">Đang chờ thực hiện</div>
            </div>
          </div>
        </div>

        <div class="col-12 col-sm-6 col-xl-4">
          <div class="stat-card">
            <div class="stat-icon completed">
              <i class="bi bi-check2-circle"></i>
            </div>
            <div>
              <div class="stat-value text-success"><c:out value="${statusCounts['completed'] != null ? statusCounts['completed'] : 0}" /></div>
              <div class="stat-label">Đã hoàn thành</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Filter & Search Section -->
      <div class="filter-card">
        <!-- Status Tabs -->
        <div class="d-flex align-items-center flex-wrap gap-2 mb-3">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=all&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}" 
             class="tab-pill-btn ${selectedStatus == 'all' ? 'active' : ''}">
            Tất cả
            <span class="tab-badge"><c:out value="${statusCounts['all'] != null ? statusCounts['all'] : 0}" /></span>
          </a>

          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Pending&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}" 
             class="tab-pill-btn ${selectedStatus == 'Pending' ? 'active' : ''}">
            <i class="bi bi-clock-history"></i> Chờ thực hiện
            <span class="tab-badge"><c:out value="${statusCounts['pending'] != null ? statusCounts['pending'] : 0}" /></span>
          </a>

          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Completed&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}" 
             class="tab-pill-btn ${selectedStatus == 'Completed' ? 'active' : ''}">
            <i class="bi bi-check-circle"></i> Đã hoàn tất
            <span class="tab-badge"><c:out value="${statusCounts['completed'] != null ? statusCounts['completed'] : 0}" /></span>
          </a>

          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Cancelled&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}" 
             class="tab-pill-btn ${selectedStatus == 'Cancelled' ? 'active' : ''}">
            <i class="bi bi-x-circle"></i> Đã hủy
            <span class="tab-badge"><c:out value="${statusCounts['cancelled'] != null ? statusCounts['cancelled'] : 0}" /></span>
          </a>
        </div>

        <!-- Filter Form -->
        <form method="GET" action="${pageContext.request.contextPath}/specialist/waiting-list" class="row g-2 align-items-center">
          <input type="hidden" name="status" value="${selectedStatus}">
          
          <!-- Keyword input -->
          <div class="col-12 col-md-4">
            <div class="input-group">
              <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
              <input type="text" name="keyword" class="form-control border-start-0" 
                     placeholder="Tìm tên bệnh nhân, SĐT, thủ thuật..." 
                     value="<c:out value='${keyword}'/>">
            </div>
          </div>

          <!-- Date picker -->
          <div class="col-12 col-sm-6 col-md-3">
            <div class="input-group">
              <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-calendar3"></i></span>
              <input type="date" name="date" class="form-control border-start-0" 
                     value="<c:out value='${selectedDate}'/>">
            </div>
          </div>

          <!-- Scope select -->
          <div class="col-12 col-sm-6 col-md-3">
            <select name="scope" class="form-select">
              <option value="my" ${selectedScope == 'my' ? 'selected' : ''}>Chỉ ca của tôi & chưa gán</option>
              <option value="all" ${selectedScope == 'all' ? 'selected' : ''}>Toàn bộ phòng khám</option>
            </select>
          </div>

          <!-- Submit Buttons -->
          <div class="col-12 col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100" style="background-color: var(--vc-primary); border-color: var(--vc-primary);">
              <i class="bi bi-funnel"></i> Lọc
            </button>
            <c:if test="${not empty keyword || not empty selectedDate || selectedScope == 'all'}">
              <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=${selectedStatus}" 
                 class="btn btn-outline-secondary" title="Đặt lại bộ lọc">
                <i class="bi bi-x-lg"></i>
              </a>
            </c:if>
          </div>
        </form>
      </div>

      <!-- Main Waiting List Table -->
      <div class="waiting-table-container">
        <c:choose>
          <c:when test="${empty orderList}">
            <div class="empty-state">
              <i class="bi bi-clipboard2-x empty-icon"></i>
              <h5 class="fw-bold text-dark mb-1">Không có bệnh nhân nào trong hàng đợi</h5>
              <p class="text-muted small mb-3">Hiện chưa có ca chỉ định cận lâm sàng nào phù hợp với bộ lọc đã chọn.</p>
              <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-arrow-repeat me-1"></i> Xóa bộ lọc và tải lại
              </a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-responsive">
              <table class="table-modern">
                <thead>
                  <tr>
                    <th>Mã số</th>
                    <th>Bệnh nhân</th>
                    <th>Dịch vụ chỉ định</th>
                    <th>Bác sĩ chỉ định & Chẩn đoán</th>
                    <th>KTV phụ trách / Phòng</th>
                    <th>Thời gian</th>
                    <th>Trạng thái</th>
                    <th class="text-end">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${orderList}">
                    <tr>
                      <!-- ID -->
                      <td>
                        <span class="fw-bold text-dark">#PO-${item.orderId}</span>
                      </td>

                      <!-- Patient Info -->
                      <td>
                        <div class="d-flex align-items-center gap-3">
                          <div class="patient-avatar">
                            ${item.patientName != null && item.patientName.length() > 0 ? item.patientName.substring(0, 1) : 'BN'}
                          </div>
                          <div>
                            <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${item.patientId}&orderId=${item.orderId}" 
                               class="patient-name-link" title="Xem hồ sơ bệnh nhân (Màn 35)">
                              <c:out value="${item.patientName}" />
                            </a>
                            <div class="text-muted small mt-1">
                              <span class="me-2"><i class="bi bi-cake2 me-1"></i>${item.patientAge} tuổi</span>
                              <span><i class="bi bi-telephone me-1"></i><c:out value="${item.patientPhone}" /></span>
                            </div>
                          </div>
                        </div>
                      </td>

                      <!-- Service Info -->
                      <td>
                        <span class="badge-service">
                          <i class="bi bi-activity text-primary me-1"></i>
                          <c:out value="${item.serviceName}" />
                        </span>
                        <div class="text-muted small mt-1">
                          Giá niêm yết: <fmt:formatNumber value="${item.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </div>
                      </td>

                      <!-- Doctor & Diagnosis -->
                      <td>
                        <div class="fw-semibold text-dark">
                          <i class="bi bi-person-badge text-success me-1"></i>
                          <c:out value="${item.doctorName}" />
                        </div>
                        <div class="text-muted small text-truncate mt-1" style="max-width: 260px;" title="${item.clinicalDiagnosis}">
                          <i class="bi bi-chat-left-dots me-1"></i>
                          <c:out value="${item.clinicalDiagnosis != null ? item.clinicalDiagnosis : 'Chưa có chẩn đoán sơ bộ'}" />
                        </div>
                      </td>

                      <!-- Specialist & Room -->
                      <td>
                        <c:choose>
                          <c:when test="${not empty item.specialistName}">
                            <div class="fw-semibold text-dark">
                              <i class="bi bi-person-check text-primary me-1"></i>
                              <c:out value="${item.specialistName}" />
                            </div>
                            <div class="text-muted small mt-1">
                              <i class="bi bi-door-open me-1"></i><c:out value="${item.roomName != null ? item.roomName : 'Phòng Cận lâm sàng'}" />
                            </div>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-light text-muted border">
                              <i class="bi bi-dash-circle me-1"></i> Chưa nhận ca
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <!-- Created At -->
                      <td>
                        <div class="text-dark fw-medium small">
                          <fmt:formatDate value="${item.recordCreatedAt}" pattern="HH:mm" />
                        </div>
                        <div class="text-muted small">
                          <fmt:formatDate value="${item.recordCreatedAt}" pattern="dd/MM/yyyy" />
                        </div>
                      </td>

                      <!-- Status -->
                      <td>
                        <c:choose>
                          <c:when test="${item.status == 'Pending'}">
                            <span class="badge-status pending">
                              <i class="bi bi-hourglass-split"></i> Chờ thực hiện
                            </span>
                          </c:when>
                          <c:when test="${item.status == 'Completed'}">
                            <span class="badge-status completed">
                              <i class="bi bi-check2-circle"></i> Đã hoàn thành
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge-status cancelled">
                              <i class="bi bi-x-circle"></i> Đã hủy
                            </span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <!-- Actions -->
                      <td class="text-end">
                        <div class="d-flex justify-content-end gap-2">
                          <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${item.orderId}" 
                             class="btn-action-primary" 
                             title="Vào thực hiện thủ thuật & ghi kết quả (Màn 36)">
                            <c:choose>
                              <c:when test="${item.status == 'Pending'}">
                                <i class="bi bi-play-circle-fill"></i> Thực hiện
                              </c:when>
                              <c:otherwise>
                                <i class="bi bi-eye"></i> Xem kết quả
                              </c:otherwise>
                            </c:choose>
                          </a>

                          <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${item.patientId}&orderId=${item.orderId}" 
                             class="btn-action-outline" 
                             title="Xem chi tiết hồ sơ bệnh nhân (Màn 35)">
                            <i class="bi bi-person-vcard"></i>
                          </a>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

    </div><!-- End page-content -->
  </div><!-- End main-wrapper -->

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
