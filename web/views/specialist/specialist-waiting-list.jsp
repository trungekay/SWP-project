<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hàng đợi Cận lâm sàng & Thủ thuật - VisionCare</title>
  
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout CSS (Employee Unified Design System) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/employee.css">
  <!-- Screen 34 Dedicated Enhancements -->
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
    <div class="page-content" style="padding: 24px 30px;">

      <!-- Header Section -->
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h2 class="fw-bold text-dark mb-1" style="font-size: 22px;">Hàng đợi Cận lâm sàng & Thủ thuật</h2>
          <p class="text-secondary mb-0 small">Danh sách bệnh nhân được Bác sĩ chỉ định thực hiện kỹ thuật chẩn đoán và thủ thuật chuyên sâu</p>
        </div>
        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list" 
             class="btn btn-white border shadow-sm text-secondary px-3 py-2 d-flex align-items-center gap-1.5" 
             style="font-size: 13.5px; border-radius: 8px;">
            <i class="bi bi-arrow-clockwise"></i> Làm mới danh sách
          </a>
        </div>
      </div>

      <!-- KPI Summary Cards (Bấm trực tiếp để lọc theo trạng thái) -->
      <div class="row g-3 mb-4 align-items-stretch">
        <!-- 1. Tất cả ca trong hàng đợi -->
        <div class="col-12 col-sm-6 col-xl-4 d-flex">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=all&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
             class="metric-card w-100 text-decoration-none ${selectedStatus == 'all' || empty selectedStatus ? 'border border-2 border-primary shadow-sm bg-light' : ''}">
            <div class="metric-icon-box metric-icon-teal">
              <i class="bi bi-clipboard2-pulse"></i>
            </div>
            <div class="metric-info">
              <div class="metric-num"><c:out value="${statusCounts['all'] != null ? statusCounts['all'] : 0}" /></div>
              <div class="metric-title text-secondary">Tổng ca trong hàng đợi</div>
            </div>
          </a>
        </div>

        <!-- 2. Đang chờ thực hiện -->
        <div class="col-12 col-sm-6 col-xl-4 d-flex">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Pending&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
             class="metric-card w-100 text-decoration-none ${selectedStatus == 'Pending' ? 'border border-2 border-warning shadow-sm' : ''}"
             style="${selectedStatus == 'Pending' ? 'background-color: #fffdf5;' : ''}">
            <div class="metric-icon-box metric-icon-warning">
              <i class="bi bi-hourglass-split"></i>
            </div>
            <div class="metric-info">
              <div class="metric-num"><c:out value="${statusCounts['pending'] != null ? statusCounts['pending'] : 0}" /></div>
              <div class="metric-title text-secondary">Chờ thực hiện</div>
            </div>
          </a>
        </div>

        <!-- 3. Đã hoàn tất -->
        <div class="col-12 col-sm-6 col-xl-4 d-flex">
          <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Completed&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
             class="metric-card w-100 text-decoration-none ${selectedStatus == 'Completed' ? 'border border-2 border-success shadow-sm' : ''}"
             style="${selectedStatus == 'Completed' ? 'background-color: #f0fdf4;' : ''}">
            <div class="metric-icon-box metric-icon-success">
              <i class="bi bi-check2-circle"></i>
            </div>
            <div class="metric-info">
              <div class="metric-num"><c:out value="${statusCounts['completed'] != null ? statusCounts['completed'] : 0}" /></div>
              <div class="metric-title text-secondary">Đã hoàn tất</div>
            </div>
          </a>
        </div>
      </div>

      <!-- Main Content Card -->
      <div class="content-card">
        <!-- Toolbar: Tìm kiếm, Ngày & Phạm vi -->
        <form action="${pageContext.request.contextPath}/specialist/waiting-list" method="get" class="p-3 border-bottom bg-white">
          <input type="hidden" name="status" value="${selectedStatus}">
          <div class="d-flex flex-column flex-lg-row align-items-stretch align-items-lg-center justify-content-between gap-3">
            <!-- 1. Thanh tìm kiếm nhanh -->
            <div class="search-filter-input flex-grow-1" style="max-width: 480px;">
              <i class="bi bi-search"></i>
              <input type="text" name="keyword" value="<c:out value='${keyword}'/>"
                     placeholder="Nhập tên bệnh nhân, SĐT, thủ thuật..." class="w-100"
                     style="height: 40px; font-size: 14px; border-radius: 8px;">
            </div>

            <!-- 2. Chọn ngày, phạm vi & nút Tra cứu -->
            <div class="d-flex align-items-center gap-2 flex-wrap flex-md-nowrap">
              <!-- Chọn ngày -->
              <div class="d-flex align-items-center gap-1.5">
                <span class="text-secondary small fw-semibold text-nowrap"><i class="bi bi-calendar3 me-1 text-primary"></i>Ngày:</span>
                <input type="date" name="date" class="form-control fw-semibold text-dark shadow-none"
                       style="height: 40px; font-size: 13.5px; width: 145px; border-radius: 8px; border: 1px solid #cbd5e1; background-color: #f8fafc;"
                       value="${selectedDate}">
              </div>

              <!-- Lọc phạm vi ca -->
              <select name="scope" class="form-select shadow-none" style="height: 40px; font-size: 13.5px; width: 210px; border-radius: 8px; border: 1px solid #cbd5e1;">
                <option value="my" ${selectedScope == 'my' ? 'selected' : ''}>Chỉ ca của tôi</option>
                <option value="all" ${selectedScope == 'all' ? 'selected' : ''}>Toàn bộ phòng khám</option>
              </select>

              <!-- Nút Tra cứu -->
              <button type="submit" class="btn btn-teal px-3 text-nowrap d-flex align-items-center gap-1.5 shadow-sm"
                      style="height: 40px; font-weight: 600;">
                <i class="bi bi-search"></i>
                <span>Tra cứu</span>
              </button>

              <c:if test="${not empty keyword || not empty selectedDate || selectedScope == 'all'}">
                <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=${selectedStatus}" 
                   class="btn btn-outline-secondary d-flex align-items-center justify-content-center"
                   style="height: 40px; width: 40px; border-radius: 8px;" title="Đặt lại bộ lọc">
                  <i class="bi bi-x-lg"></i>
                </a>
              </c:if>
            </div>
          </div>
        </form>

        <!-- Thanh điều hướng Tab trạng thái -->
        <div class="px-3 pt-3 pb-2 bg-light border-bottom d-flex align-items-center justify-content-between flex-wrap gap-2">
          <div class="d-flex align-items-center gap-2 flex-wrap">
            <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=all&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
               class="btn btn-sm ${selectedStatus == 'all' || empty selectedStatus ? 'btn-teal text-white fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
              <i class="bi bi-people-fill me-1"></i> Tất cả (${statusCounts['all'] != null ? statusCounts['all'] : 0})
            </a>
            <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Pending&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
               class="btn btn-sm ${selectedStatus == 'Pending' ? 'btn-warning text-dark fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
              <i class="bi bi-hourglass-split me-1"></i> Chờ thực hiện (${statusCounts['pending'] != null ? statusCounts['pending'] : 0})
            </a>
            <a href="${pageContext.request.contextPath}/specialist/waiting-list?status=Completed&keyword=${keyword}&date=${selectedDate}&scope=${selectedScope}"
               class="btn btn-sm ${selectedStatus == 'Completed' ? 'btn-success fw-bold shadow-sm' : 'btn-white border text-secondary'} rounded-pill px-3">
              <i class="bi bi-check2-circle me-1"></i> Đã hoàn tất (${statusCounts['completed'] != null ? statusCounts['completed'] : 0})
            </a>
          </div>
          <div class="text-secondary small">
            Tổng số: <strong>${orderList != null ? orderList.size() : 0}</strong> ca
          </div>
        </div>

        <!-- Table Danh sách Hàng đợi -->
        <div class="table-container">
          <c:choose>
            <c:when test="${empty orderList}">
              <div class="p-5 text-center">
                <i class="bi bi-clipboard2-x text-muted mb-3" style="font-size: 48px; display: inline-block;"></i>
                <h6 class="fw-bold text-dark mb-1">Hiện không có ca nào trong danh sách</h6>
                <p class="text-muted small mb-3">Không tìm thấy ca chỉ định nào phù hợp với bộ lọc hiện tại.</p>
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                  <i class="bi bi-arrow-repeat me-1"></i> Đặt lại bộ lọc
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <table class="custom-table" style="table-layout: auto; width: 100%;">
                <thead>
                  <tr>
                    <th style="width: 85px; text-align: center;">Mã phiếu</th>
                    <th style="width: 185px;">Bệnh nhân</th>
                    <th style="width: 260px;">Dịch vụ chỉ định</th>
                    <th>Bác sĩ & Chẩn đoán sơ bộ</th>
                    <th style="width: 110px;">Thời gian</th>
                    <th style="width: 125px; text-align: center;">Trạng thái</th>
                    <th style="width: 160px; text-align: center;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${orderList}">
                    <tr>
                      <!-- Mã phiếu -->
                      <td class="text-center fw-semibold text-secondary" style="font-size: 13px;">
                        #CD-${item.orderId}
                      </td>

                      <!-- Bệnh nhân -->
                      <td>
                        <div class="patient-name-title">
                          <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${item.patientId}&orderId=${item.orderId}" 
                             class="text-decoration-none text-dark hover-teal fw-bold" 
                             style="font-size: 13.5px;"
                             title="Xem hồ sơ bệnh nhân">
                            <c:out value="${item.patientName}" />
                          </a>
                        </div>
                        <div class="patient-sub-info text-secondary small mt-1" style="font-size: 12px; line-height: 1.45;">
                          <div class="fw-medium" style="color: #334155;">
                            <i class="bi bi-telephone text-muted me-1"></i><c:out value="${item.patientPhone}" />
                          </div>
                          <c:if test="${not empty item.patientDob}">
                            <div title="Ngày sinh" class="fw-medium" style="color: #334155;">
                              <i class="bi bi-calendar-event text-muted me-1"></i><fmt:formatDate value="${item.patientDob}" pattern="dd/MM/yyyy" />
                            </div>
                          </c:if>
                        </div>
                      </td>

                      <!-- Dịch vụ chỉ định -->
                      <td>
                        <div class="fw-semibold text-dark" style="font-size: 13.5px; line-height: 1.3;">
                          <c:out value="${item.serviceName}" />
                        </div>
                        <div class="d-flex align-items-center gap-2 mt-1">
                          <span class="badge bg-light text-secondary border px-2 py-1" style="font-size: 11px;">
                            <i class="bi bi-door-open me-1 text-success"></i><c:out value="${item.roomName != null ? item.roomName : 'P. Cận lâm sàng'}" />
                          </span>
                          <span class="text-teal fw-bold small">
                            <fmt:formatNumber value="${item.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                          </span>
                        </div>
                      </td>

                      <!-- Bác sĩ & Chẩn đoán sơ bộ -->
                      <td>
                        <div class="fw-semibold text-dark" style="font-size: 13px;">
                          <i class="bi bi-person-badge text-success me-1"></i><c:out value="${item.doctorName}" />
                        </div>
                        <div class="text-secondary small mt-1" style="line-height: 1.35;" title="${item.clinicalDiagnosis}">
                          <c:choose>
                            <c:when test="${not empty item.clinicalDiagnosis}">
                              <i class="bi bi-chat-left-text me-1 text-muted"></i><c:out value="${item.clinicalDiagnosis}" />
                            </c:when>
                            <c:otherwise>
                              <span class="text-muted fst-italic">Chưa có ghi chú chẩn đoán</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <c:if test="${selectedScope == 'all'}">
                          <div class="text-muted small mt-1">
                            <i class="bi bi-person-check text-primary me-1"></i>KTV thực hiện: <strong><c:out value="${item.specialistName != null ? item.specialistName : 'Chưa gán'}" /></strong>
                          </div>
                        </c:if>
                      </td>

                      <!-- Thời gian -->
                      <td>
                        <div class="fw-bold text-dark small">
                          <fmt:formatDate value="${item.recordCreatedAt}" pattern="HH:mm" />
                        </div>
                        <div class="text-muted small">
                          <fmt:formatDate value="${item.recordCreatedAt}" pattern="dd/MM/yyyy" />
                        </div>
                      </td>

                      <!-- Trạng thái -->
                      <td class="text-center">
                        <c:choose>
                          <c:when test="${item.status == 'Pending'}">
                            <span class="badge-status badge-pending">Chờ thực hiện</span>
                          </c:when>
                          <c:when test="${item.status == 'In_Progress'}">
                            <span class="badge-status badge-inprogress"><span class="pulse-dot me-1"></span>Đang làm</span>
                          </c:when>
                          <c:when test="${item.status == 'Completed'}">
                            <span class="badge-status badge-completed">Đã hoàn tất</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge-status badge-cancelled">Đã hủy</span>
                          </c:otherwise>
                        </c:choose>
                      </td>

                      <!-- Thao tác -->
                      <td class="text-center text-nowrap">
                        <div class="d-flex align-items-center justify-content-center gap-2">
                          <c:choose>
                            <c:when test="${item.status == 'Pending'}">
                              <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${item.orderId}" 
                                 class="btn-action-execute shadow-sm" 
                                 title="Thực hiện thủ thuật & ghi nhận kết quả">
                                <i class="bi bi-play-fill"></i>
                                <span>Thực hiện</span>
                              </a>
                            </c:when>
                            <c:when test="${item.status == 'In_Progress'}">
                              <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${item.orderId}" 
                                 class="btn-action-execute shadow-sm" 
                                 style="background-color: #0284c7 !important;"
                                 title="Tiếp tục thực hiện thủ thuật">
                                <i class="bi bi-play-circle-fill"></i>
                                <span>Tiếp tục</span>
                              </a>
                            </c:when>
                            <c:otherwise>
                              <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${item.orderId}" 
                                 class="btn-action-view-result" 
                                 title="Xem kết quả thủ thuật">
                                <i class="bi bi-eye"></i>
                                <span>Xem KQ</span>
                              </a>
                            </c:otherwise>
                          </c:choose>

                          <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${item.patientId}&orderId=${item.orderId}" 
                             class="btn-action-patient-card" 
                             title="Xem hồ sơ bệnh nhân">
                            <i class="bi bi-person-vcard"></i>
                          </a>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </c:otherwise>
          </c:choose>
        </div>

      </div><!-- End content-card -->

    </div><!-- End page-content -->
  </div><!-- End main-wrapper -->

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
