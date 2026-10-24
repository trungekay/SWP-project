<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Duyệt yêu cầu hoàn tiền - Ban Giám Đốc VisionCare</title>
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
    .stat-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      padding: 20px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
      transition: all 0.2s ease;
      height: 100%;
    }
    .stat-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
    }
    .filter-tab {
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 500;
      font-size: 0.875rem;
      text-decoration: none;
      color: #64748b;
      background: #f1f5f9;
      transition: all 0.2s;
      display: inline-block;
    }
    .filter-tab:hover {
      background: #e2e8f0;
      color: #1e293b;
    }
    .filter-tab.active {
      background: #0d9488;
      color: #ffffff !important;
      box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
    }
    .content-card {
      background: #ffffff;
      border-radius: 14px;
      border: 1px solid #e2e8f0;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
      overflow: hidden;
    }
    .custom-table th {
      background-color: #f8fafc;
      color: #64748b;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 14px 16px;
      border-bottom: 1px solid #e2e8f0;
    }
    .custom-table td {
      padding: 16px;
      border-bottom: 1px solid #f1f5f9;
      vertical-align: middle;
      font-size: 14px;
    }
  </style>
</head>
<body>

  <!-- Director Sidebar -->
  <jsp:include page="/views/director/layout/director-sidebar.jsp">
    <jsp:param name="activeNav" value="refunds" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <div class="page-content">

      <!-- Page Title -->
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h2 class="fw-bold mb-1"><i class="bi bi-cash-coin text-warning me-2"></i>Duyệt yêu cầu Hoàn tiền viện phí</h2>
          <p class="text-muted mb-0">Ban Giám đốc xem xét tính hợp lệ của đơn hoàn tiền, kiểm tra lý do hủy lịch và chuẩn chi hoàn trả tài chính</p>
        </div>
      </div>

      <!-- Flash Messages -->
      <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm mb-4" role="alert">
          <i class="bi bi-check-circle-fill me-2"></i>${successMessage}
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
      </c:if>
      <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm mb-4" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2"></i>${errorMessage}
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
      </c:if>

      <!-- KPI Summary Stats -->
      <div class="row g-3 mb-4">
        <div class="col-6 col-xl-3">
          <div class="stat-card">
            <span class="text-muted small fw-semibold">Tổng số yêu cầu hoàn tiền</span>
            <h3 class="fw-bold mt-2 mb-0">${stats.total}</h3>
            <small class="text-muted">Đơn yêu cầu hoàn trả</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="stat-card border-warning">
            <div class="d-flex justify-content-between align-items-center">
              <span class="text-warning small fw-bold">Chờ Giám đốc duyệt</span>
              <span class="badge bg-warning text-dark">${stats.pending}</span>
            </div>
            <h3 class="fw-bold text-danger mt-2 mb-0">${stats.pending}</h3>
            <small class="text-danger fw-semibold">Cần giải quyết ngay</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="stat-card">
            <span class="text-muted small fw-semibold">Đã phê duyệt hoàn tiền</span>
            <h3 class="fw-bold text-success mt-2 mb-0">${stats.approved}</h3>
            <small class="text-success fw-bold">Tổng tiền: ${stats.totalApprovedAmountFmt}</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="stat-card">
            <span class="text-muted small fw-semibold">Đã từ chối</span>
            <h3 class="fw-bold text-secondary mt-2 mb-0">${stats.rejected}</h3>
            <small class="text-muted">Không chấp nhận hoàn tiền</small>
          </div>
        </div>
      </div>

      <!-- Filter Tabs -->
      <div class="card border-0 shadow-sm rounded-4 p-3 mb-4 bg-white">
        <div class="d-flex flex-wrap align-items-center gap-2">
          <span class="text-muted small fw-bold me-2"><i class="bi bi-funnel me-1"></i>Trạng thái xét duyệt:</span>
          <a href="${pageContext.request.contextPath}/director/refunds?status=all"
             class="filter-tab ${currentStatus == 'all' ? 'active' : ''}">Tất cả (${stats.total})</a>
          <a href="${pageContext.request.contextPath}/director/refunds?status=Pending"
             class="filter-tab ${currentStatus == 'Pending' ? 'active' : ''}">Chờ duyệt (${stats.pending})</a>
          <a href="${pageContext.request.contextPath}/director/refunds?status=Approved"
             class="filter-tab ${currentStatus == 'Approved' ? 'active' : ''}">Đã phê duyệt (${stats.approved})</a>
          <a href="${pageContext.request.contextPath}/director/refunds?status=Rejected"
             class="filter-tab ${currentStatus == 'Rejected' ? 'active' : ''}">Đã từ chối (${stats.rejected})</a>
        </div>
      </div>

      <!-- Refunds Table -->
      <div class="content-card">
        <div class="table-responsive">
          <table class="custom-table table table-hover mb-0">
            <thead>
              <tr>
                <th style="width: 100px;">Mã đơn</th>
                <th>Bệnh nhân & Hóa đơn</th>
                <th>Lịch hẹn</th>
                <th>Số tiền hoàn</th>
                <th>Lý do yêu cầu</th>
                <th>Người tạo & Người duyệt</th>
                <th>Thời gian</th>
                <th>Trạng thái</th>
                <th class="text-end" style="width: 200px;">Quyết định Giám đốc</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty refunds}">
                  <c:forEach var="rf" items="${refunds}">
                    <tr>
                      <td class="fw-bold font-monospace text-teal">${rf.formattedId}</td>
                      <td>
                        <div class="fw-bold text-dark">${rf.patientName}</div>
                        <small class="text-muted d-block"><i class="bi bi-telephone me-1"></i>${rf.patientPhone}</small>
                        <div class="mt-1">
                          <span class="badge bg-light text-dark border font-monospace" style="font-size: 11px;">
                            ${rf.formattedInvoiceId}
                          </span>
                        </div>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty rf.formattedApptId && rf.formattedApptId != 'N/A'}">
                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle font-monospace">
                              <i class="bi bi-calendar-check me-1"></i>${rf.formattedApptId}
                            </span>
                          </c:when>
                          <c:otherwise>
                            <span class="text-muted small">---</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <div class="fs-6 fw-bold text-danger">${rf.amountFmt}</div>
                      </td>
                      <td>
                        <div class="p-2 rounded bg-light border text-dark" style="max-width: 230px; font-size: 13px;">
                          ${rf.reason}
                        </div>
                      </td>
                      <td>
                        <div class="small text-muted">Lập bởi: <b class="text-dark">${rf.creatorName}</b></div>
                        <div class="small text-muted mt-1">Duyệt bởi: <b class="text-dark">${rf.approverName}</b></div>
                      </td>
                      <td>
                        <small class="text-muted d-block">Tạo: ${rf.createdAt}</small>
                        <c:if test="${not empty rf.updatedAt && rf.updatedAt != rf.createdAt}">
                          <small class="text-muted d-block">Cập nhật: ${rf.updatedAt}</small>
                        </c:if>
                      </td>
                      <td>
                        <span class="badge ${rf.badgeClass} px-3 py-2 rounded-pill font-monospace" style="font-size: 12px;">
                          ${rf.statusVn}
                        </span>
                      </td>
                      <td class="text-end">
                        <c:choose>
                          <c:when test="${rf.status == 'Pending'}">
                            <div class="d-flex justify-content-end gap-2">
                              <!-- Nút Duyệt hoàn tiền -->
                              <button type="button" class="btn btn-sm btn-success rounded-pill px-3 fw-bold"
                                      onclick="openApproveRefundModal(${rf.id}, '${fn:escapeXml(rf.patientName)}', '${rf.amountFmt}', '${rf.formattedInvoiceId}')">
                                <i class="bi bi-check-lg me-1"></i>Duyệt chi
                              </button>
                              <!-- Nút Từ chối -->
                              <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-semibold"
                                      onclick="openRejectRefundModal(${rf.id}, '${fn:escapeXml(rf.patientName)}')">
                                <i class="bi bi-x-lg me-1"></i>Từ chối
                              </button>
                            </div>
                          </c:when>
                          <c:otherwise>
                            <span class="text-muted small fst-italic">Đã hoàn tất</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="9" class="text-center py-5 text-muted">
                      <i class="bi bi-inbox fs-1 d-block mb-2 text-muted opacity-50"></i>
                      Không tìm thấy yêu cầu hoàn tiền nào phù hợp với bộ lọc hiện tại.
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

  <!-- Modal Duyệt Hoàn Tiền -->
  <div class="modal fade" id="approveRefundModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <form action="${pageContext.request.contextPath}/director/refunds" method="POST">
          <input type="hidden" name="action" value="approve">
          <input type="hidden" name="refundId" id="approveRefundId">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold text-success"><i class="bi bi-check-circle-fill me-2"></i>Phê duyệt hoàn tiền cho bệnh nhân</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body py-3">
            <p class="mb-2">Bạn có chắc chắn muốn phê duyệt lệnh hoàn tiền này?</p>
            <div class="p-3 rounded-3 bg-light border mb-2">
              <div class="mb-1"><b>Bệnh nhân:</b> <span id="approvePatName"></span></div>
              <div class="mb-1"><b>Hóa đơn:</b> <span id="approveInvCode"></span></div>
              <div><b>Số tiền hoàn trả:</b> <span id="approveAmount" class="fs-5 fw-bold text-danger ms-1"></span></div>
            </div>
            <div class="alert alert-info py-2 px-3 small mb-0 rounded-3">
              <i class="bi bi-info-circle me-1"></i> Trạng thái hóa đơn sẽ chuyển sang <b>Đã hoàn tiền (Refunded)</b> và lịch hẹn liên quan sẽ được tự động hủy bỏ an toàn.
            </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-success rounded-pill px-4 fw-bold">Xác nhận duyệt hoàn tiền</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Modal Từ Chối Hoàn Tiền -->
  <div class="modal fade" id="rejectRefundModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <form action="${pageContext.request.contextPath}/director/refunds" method="POST">
          <input type="hidden" name="action" value="reject">
          <input type="hidden" name="refundId" id="rejectRefundId">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold text-danger"><i class="bi bi-x-circle-fill me-2"></i>Từ chối yêu cầu hoàn tiền</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body py-3">
            <p class="mb-2">Từ chối yêu cầu hoàn tiền của bệnh nhân: <b id="rejectPatName"></b></p>
            <div class="mb-3">
              <label for="rejectNote" class="form-label small fw-bold text-muted">Lý do từ chối (Ghi chú lưu hồ sơ & gửi bệnh nhân):</label>
              <textarea class="form-control rounded-3" id="rejectNote" name="rejectNote" rows="3" placeholder="Nhập lý do từ chối (ví dụ: đã quá thời hạn hoàn tiền, bệnh nhân đã thực hiện dịch vụ...)" required></textarea>
            </div>
            <div class="alert alert-warning py-2 px-3 small mb-0 rounded-3">
              <i class="bi bi-exclamation-triangle me-1"></i> Lịch hẹn sẽ được khôi phục trạng thái <b>Đã xác nhận (Confirmed)</b>.
            </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
            <button type="submit" class="btn btn-danger rounded-pill px-4 fw-bold">Xác nhận từ chối</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    function openApproveRefundModal(id, patName, amount, invCode) {
      document.getElementById('approveRefundId').value = id;
      document.getElementById('approvePatName').innerText = patName;
      document.getElementById('approveAmount').innerText = amount;
      document.getElementById('approveInvCode').innerText = invCode;
      new bootstrap.Modal(document.getElementById('approveRefundModal')).show();
    }

    function openRejectRefundModal(id, patName) {
      document.getElementById('rejectRefundId').value = id;
      document.getElementById('rejectPatName').innerText = patName;
      document.getElementById('rejectNote').value = '';
      new bootstrap.Modal(document.getElementById('rejectRefundModal')).show();
    }
  </script>
</body>
</html>
