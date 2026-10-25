<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bàn làm việc Giám đốc - VisionCare</title>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout CSS -->
  <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
  <style>
    body {
      font-family: 'Inter', sans-serif;
      background-color: #f8fafc;
      color: #1e293b;
    }
    .director-hero-card {
      background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
      color: #ffffff;
      border-radius: 16px;
      padding: 28px;
      box-shadow: 0 10px 25px rgba(13, 148, 136, 0.15);
      position: relative;
      overflow: hidden;
    }
    .director-hero-card::after {
      content: '';
      position: absolute;
      top: -30px;
      right: -30px;
      width: 180px;
      height: 180px;
      background: rgba(255, 255, 255, 0.08);
      border-radius: 50%;
    }
    .kpi-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      padding: 22px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
      transition: all 0.25s ease;
      height: 100%;
    }
    .kpi-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.07);
    }
    .kpi-icon {
      width: 52px;
      height: 52px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
    }
    .card-table {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
      overflow: hidden;
    }
    .card-table-header {
      padding: 18px 22px;
      border-bottom: 1px solid #f1f5f9;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .badge-soft-primary { background-color: #e0f2fe; color: #0284c7; }
    .badge-soft-success { background-color: #dcfce7; color: #16a34a; }
    .badge-soft-warning { background-color: #fef3c7; color: #d97706; }
    .badge-soft-danger { background-color: #fee2e2; color: #dc2626; }
    .badge-soft-teal { background-color: #ccfbf1; color: #0d9488; }
    .btn-review-action {
      background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
      color: #ffffff !important;
      border: none;
      padding: 5px 14px;
      border-radius: 50px;
      font-size: 12px;
      font-weight: 600;
      box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
      transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
      display: inline-flex;
      align-items: center;
      gap: 5px;
      text-decoration: none;
    }
    .btn-review-action:hover {
      background: linear-gradient(135deg, #0f766e 0%, #115e59 100%);
      transform: translateY(-1px);
      box-shadow: 0 4px 10px rgba(13, 148, 136, 0.35);
    }
    .btn-review-warning {
      background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
      color: #ffffff !important;
      box-shadow: 0 2px 6px rgba(217, 119, 6, 0.25);
    }
    .btn-review-warning:hover {
      background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
      box-shadow: 0 4px 10px rgba(217, 119, 6, 0.35);
    }
  </style>
</head>
<body>

  <!-- Director Sidebar -->
  <jsp:include page="/views/director/layout/director-sidebar.jsp">
    <jsp:param name="activeNav" value="dashboard" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <div class="page-content">

      <!-- Hero Greeting -->
      <div class="director-hero-card mb-4">
        <div class="row align-items-center">
          <div class="col-lg-8">
            <span class="badge bg-white bg-opacity-25 text-white px-3 py-1 rounded-pill mb-2">
              <i class="bi bi-shield-check me-1"></i> Ban Giám đốc Điều hành VisionCare
            </span>
            <h2 class="fw-bold mb-1">Xin chào, ${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Giám đốc'}!</h2>
            <p class="mb-0 text-white text-opacity-85">
              Hệ thống quản lý nhân sự y tế, theo dõi lịch trực và trung tâm phê duyệt điều hành phòng khám.
            </p>
          </div>
          <div class="col-lg-5 text-lg-end mt-3 mt-lg-0">
            <div class="d-inline-flex flex-wrap gap-2 justify-content-lg-end">
              <a href="${pageContext.request.contextPath}/director/revenue" class="btn btn-light fw-bold text-teal px-3 py-2 shadow-sm rounded-3">
                <i class="bi bi-graph-up me-1"></i> Dashboard Doanh thu
              </a>
              <a href="${pageContext.request.contextPath}/director/leave-requests" class="btn btn-outline-light fw-bold px-3 py-2 shadow-sm rounded-3">
                <i class="bi bi-calendar-x me-1"></i> Nghỉ phép (${pendingLeaveCount})
              </a>
              <a href="${pageContext.request.contextPath}/director/refunds" class="btn btn-warning fw-bold text-dark px-3 py-2 shadow-sm rounded-3">
                <i class="bi bi-cash-coin me-1"></i> Hoàn tiền (${pendingRefundCount})
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- Financial / Revenue Overview for Director -->
      <div class="row g-3 mb-4">
        <!-- Month Revenue -->
        <div class="col-md-6 col-xl-4">
          <div class="kpi-card border-success" style="background: linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%);">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold text-uppercase">Doanh thu tháng này</span>
              <div class="kpi-icon bg-success bg-opacity-10 text-success">
                <i class="bi bi-cash-stack"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1 text-success">${revenueStats.monthRevenueFmt != null ? revenueStats.monthRevenueFmt : '0'} ₫</h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">${revenueStats.monthPaidCount != null ? revenueStats.monthPaidCount : 0} hóa đơn đã thanh toán</span>
              <a href="${pageContext.request.contextPath}/director/revenue?timeRange=month" class="small fw-bold text-success text-decoration-none">
                Chi tiết <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>

        <!-- Today Revenue -->
        <div class="col-md-6 col-xl-4">
          <div class="kpi-card" style="background: linear-gradient(135deg, #ffffff 0%, #f0fdfa 100%);">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold text-uppercase">Doanh thu hôm nay</span>
              <div class="kpi-icon bg-teal bg-opacity-10 text-teal">
                <i class="bi bi-wallet2"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1 text-teal">${revenueStats.todayRevenueFmt != null ? revenueStats.todayRevenueFmt : '0'} ₫</h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">${revenueStats.todayPaidCount != null ? revenueStats.todayPaidCount : 0} lượt khám hôm nay</span>
              <a href="${pageContext.request.contextPath}/director/revenue?timeRange=today" class="small fw-bold text-teal text-decoration-none">
                Chi tiết <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>

        <!-- All Time Revenue -->
        <div class="col-md-6 col-xl-4">
          <div class="kpi-card" style="background: linear-gradient(135deg, #ffffff 0%, #eff6ff 100%);">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold text-uppercase">Tổng doanh thu toàn thời gian</span>
              <div class="kpi-icon bg-primary bg-opacity-10 text-primary">
                <i class="bi bi-trophy"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1 text-primary">${revenueStats.allTimeRevenueFmt != null ? revenueStats.allTimeRevenueFmt : '0'} ₫</h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">${revenueStats.allTimePaidCount != null ? revenueStats.allTimePaidCount : 0} tổng hóa đơn thành công</span>
              <a href="${pageContext.request.contextPath}/director/revenue" class="small fw-bold text-primary text-decoration-none">
                Xem toàn bộ <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- KPI Summary Cards -->
      <div class="row g-3 mb-4">
        <!-- Doctors -->
        <div class="col-md-6 col-xl-3">
          <div class="kpi-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold">Bác sĩ chuyên khoa</span>
              <div class="kpi-icon bg-primary bg-opacity-10 text-primary">
                <i class="bi bi-person-badge"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1">${doctorCount} <span class="fs-6 fw-normal text-muted">bác sĩ</span></h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">Đang phụ trách khám</span>
              <a href="${pageContext.request.contextPath}/director/doctors" class="small fw-bold text-primary text-decoration-none">
                Xem lịch trực <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>

        <!-- Specialists -->
        <div class="col-md-6 col-xl-3">
          <div class="kpi-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold">Kỹ thuật viên / Chuyên viên</span>
              <div class="kpi-icon bg-success bg-opacity-10 text-success">
                <i class="bi bi-clipboard2-pulse"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1">${specialistCount} <span class="fs-6 fw-normal text-muted">nhân sự</span></h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">Cận lâm sàng & Thủ thuật</span>
              <a href="${pageContext.request.contextPath}/director/specialists" class="small fw-bold text-success text-decoration-none">
                Xem lịch trực <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>

        <!-- Staffs -->
        <div class="col-md-6 col-xl-3">
          <div class="kpi-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold">Nhân viên tiếp đón & thu ngân</span>
              <div class="kpi-icon bg-info bg-opacity-10 text-info">
                <i class="bi bi-people"></i>
              </div>
            </div>
            <h3 class="fw-bold mb-1">${staffCount} <span class="fs-6 fw-normal text-muted">nhân sự</span></h3>
            <div class="d-flex align-items-center justify-content-between mt-3">
              <span class="small text-muted">Quầy lễ tân & Hành chính</span>
              <a href="${pageContext.request.contextPath}/director/staffs" class="small fw-bold text-info text-decoration-none">
                Xem lịch làm việc <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>

        <!-- Pending Leave & Refunds -->
        <div class="col-md-6 col-xl-3">
          <div class="kpi-card border-warning">
            <div class="d-flex align-items-center justify-content-between mb-3">
              <span class="text-muted small fw-semibold">Yêu cầu chờ giám đốc duyệt</span>
              <div class="kpi-icon bg-warning bg-opacity-10 text-warning">
                <i class="bi bi-exclamation-octagon"></i>
              </div>
            </div>
            <div class="d-flex align-items-baseline gap-2">
              <h3 class="fw-bold text-danger mb-0">${pendingLeaveCount + pendingRefundCount}</h3>
              <span class="badge bg-danger bg-opacity-10 text-danger border border-danger-subtle">Cần xử lý</span>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
              <small class="text-muted">Hủy lịch: <b>${pendingLeaveCount}</b></small>
              <small class="text-muted">Hoàn tiền: <b>${pendingRefundCount}</b></small>
            </div>
          </div>
        </div>
      </div>

      <!-- 2 Tables Side-by-Side: Recent Pending Leave & Recent Pending Refunds -->
      <div class="row g-4">
        <!-- 1. Yêu cầu hủy ca làm việc đang chờ duyệt -->
        <div class="col-lg-6">
          <div class="card-table h-100">
            <div class="card-table-header">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-calendar-x fs-5 text-danger"></i>
                <h5 class="fw-bold text-dark mb-0">Yêu cầu hủy ca / Nghỉ phép</h5>
                <c:if test="${pendingLeaveCount > 0}">
                  <span class="badge bg-danger rounded-pill">${pendingLeaveCount}</span>
                </c:if>
              </div>
              <a href="${pageContext.request.contextPath}/director/leave-requests" class="btn btn-sm btn-outline-danger rounded-pill px-3">
                Xem tất cả
              </a>
            </div>
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Nhân sự</th>
                    <th>Ngày & Ca trực</th>
                    <th>Lý do xin nghỉ</th>
                    <th class="text-end">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:choose>
                    <c:when test="${not empty recentLeaveRequests}">
                      <c:forEach var="req" items="${recentLeaveRequests}" begin="0" end="4">
                        <tr>
                          <td>
                            <div class="fw-bold text-dark">${req.requesterName}</div>
                            <span class="badge ${req.requesterRole == 'doctor' ? 'badge-soft-primary' : (req.requesterRole == 'staff' ? 'badge-soft-teal' : 'badge-soft-success')} small" style="font-size: 11px;">
                              ${req.requesterRoleName}
                            </span>
                          </td>
                          <td>
                            <div class="fw-semibold text-danger"><i class="bi bi-calendar3 me-1"></i>${req.leaveDate}</div>
                            <small class="text-muted font-monospace">${req.slotName} (${req.startTime} - ${req.endTime})</small>
                          </td>
                          <td>
                            <div class="text-truncate" style="max-width: 160px;" title="${req.reason}">
                              ${req.reason}
                            </div>
                          </td>
                          <td class="text-end">
                            <a href="${pageContext.request.contextPath}/director/leave-requests" class="btn-review-action">
                              <i class="bi bi-arrow-right-circle"></i> Xét duyệt
                            </a>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <tr>
                        <td colspan="4" class="text-center py-4 text-muted">
                          <i class="bi bi-check-circle fs-3 text-success d-block mb-1"></i>
                          Hiện không có yêu cầu hủy ca trực nào đang chờ duyệt.
                        </td>
                      </tr>
                    </c:otherwise>
                  </c:choose>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- 2. Yêu cầu hoàn tiền đang chờ duyệt -->
        <div class="col-lg-6">
          <div class="card-table h-100">
            <div class="card-table-header">
              <div class="d-flex align-items-center gap-2">
                <i class="bi bi-cash-coin fs-5 text-warning"></i>
                <h5 class="fw-bold text-dark mb-0">Yêu cầu hoàn tiền cần duyệt</h5>
                <c:if test="${pendingRefundCount > 0}">
                  <span class="badge bg-warning text-dark rounded-pill">${pendingRefundCount}</span>
                </c:if>
              </div>
              <a href="${pageContext.request.contextPath}/director/refunds" class="btn btn-sm btn-outline-warning rounded-pill px-3 text-dark">
                Xem tất cả
              </a>
            </div>
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                  <tr>
                    <th>Mã REF & Bệnh nhân</th>
                    <th>Số tiền</th>
                    <th>Lý do</th>
                    <th class="text-end">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:choose>
                    <c:when test="${not empty recentRefundRequests}">
                      <c:forEach var="rf" items="${recentRefundRequests}" begin="0" end="4">
                        <tr>
                          <td>
                            <div class="fw-bold font-monospace text-teal">${rf.formattedId}</div>
                            <div class="small text-dark fw-semibold">${rf.patientName}</div>
                            <small class="text-muted font-monospace">${rf.formattedInvoiceId}</small>
                          </td>
                          <td>
                            <div class="fw-bold text-danger">${rf.amountFmt}</div>
                          </td>
                          <td>
                            <div class="text-truncate" style="max-width: 160px;" title="${rf.reason}">
                              ${rf.reason}
                            </div>
                          </td>
                          <td class="text-end">
                            <a href="${pageContext.request.contextPath}/director/refunds" class="btn-review-action btn-review-warning">
                              <i class="bi bi-arrow-right-circle"></i> Xét duyệt
                            </a>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <tr>
                        <td colspan="4" class="text-center py-4 text-muted">
                          <i class="bi bi-check-circle fs-3 text-success d-block mb-1"></i>
                          Không có yêu cầu hoàn tiền nào đang chờ duyệt.
                        </td>
                      </tr>
                    </c:otherwise>
                  </c:choose>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
