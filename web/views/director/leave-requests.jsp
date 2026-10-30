<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Duyệt yêu cầu hủy lịch / Nghỉ phép - Ban Giám Đốc VisionCare</title>
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <!-- Layout CSS -->
  <link href="${pageContext.request.contextPath}/assets/css/employee.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/director-refunds.css?v=20261030-2" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/director-leave.css?v=20261030-2" rel="stylesheet">
</head>
<body>

  <!-- Director Sidebar -->
  <jsp:include page="/views/director/layout/director-sidebar.jsp">
    <jsp:param name="activeNav" value="leave-requests" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <div class="page-content refund-page leave-page">

      <!-- Page Title -->
      <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
        <div>
          <h2 class="fw-bold mb-1"><i class="bi bi-calendar-x text-danger me-2"></i>Duyệt yêu cầu Hủy lịch / Nghỉ phép</h2>
          <p class="text-muted mb-0">Ban Giám đốc xét duyệt đơn xin nghỉ ca trực, hủy lịch đột xuất của Bác sĩ, Chuyên viên và Nhân viên phòng khám</p>
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
          <div class="refund-card leave-stat">
            <span class="text-muted small fw-semibold">Tổng số yêu cầu</span>
            <h3 class="fw-bold mt-2 mb-0">${stats.total}</h3>
            <small class="text-muted">Đơn từ nhân sự</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="refund-card leave-stat border-warning">
            <div class="d-flex justify-content-between align-items-center">
              <span class="text-warning small fw-bold">Chờ Giám đốc duyệt</span>
              <span class="badge bg-warning text-dark">${stats.pending}</span>
            </div>
            <h3 class="fw-bold text-danger mt-2 mb-0">${stats.pending}</h3>
            <small class="text-danger fw-semibold">Cần giải quyết ngay</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="refund-card leave-stat">
            <span class="text-muted small fw-semibold">Đã chấp thuận</span>
            <h3 class="fw-bold text-success mt-2 mb-0">${stats.approved}</h3>
            <small class="text-muted">Đã chuyển trạng thái ca</small>
          </div>
        </div>
        <div class="col-6 col-xl-3">
          <div class="refund-card leave-stat">
            <span class="text-muted small fw-semibold">Đã từ chối</span>
            <h3 class="fw-bold text-secondary mt-2 mb-0">${stats.rejected}</h3>
            <small class="text-muted">Yêu cầu không được duyệt</small>
          </div>
        </div>
      </div>

      <!-- Filters & Actions -->
      <div class="refund-card refund-filters d-block">
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
          <!-- Status Filters -->
          <div class="d-flex flex-wrap gap-2 align-items-center">
            <span class="text-muted small fw-bold me-1"><i class="bi bi-funnel me-1"></i>Trạng thái:</span>
            <a href="${pageContext.request.contextPath}/director/leave-requests?status=all&role=${currentRole}"
               class="filter-tab ${currentStatus == 'all' ? 'active' : ''}">Tất cả (${stats.total})</a>
            <a href="${pageContext.request.contextPath}/director/leave-requests?status=Pending&role=${currentRole}"
               class="filter-tab ${currentStatus == 'Pending' ? 'active' : ''}">Chờ duyệt (${stats.pending})</a>
            <a href="${pageContext.request.contextPath}/director/leave-requests?status=Approved&role=${currentRole}"
               class="filter-tab ${currentStatus == 'Approved' ? 'active' : ''}">Đã chấp thuận (${stats.approved})</a>
            <a href="${pageContext.request.contextPath}/director/leave-requests?status=Rejected&role=${currentRole}"
               class="filter-tab ${currentStatus == 'Rejected' ? 'active' : ''}">Đã từ chối (${stats.rejected})</a>
          </div>

          <!-- Role Filter -->
          <div class="d-flex align-items-center gap-2">
            <span class="text-muted small fw-semibold">Phân loại nhân sự:</span>
            <select class="form-select form-select-sm" style="width: 170px;"
                    onchange="location.href='${pageContext.request.contextPath}/director/leave-requests?status=${currentStatus}&role=' + this.value">
              <option value="all" ${currentRole == 'all' ? 'selected' : ''}>Tất cả đối tượng</option>
              <option value="doctor" ${currentRole == 'doctor' ? 'selected' : ''}>Bác sĩ</option>
              <option value="specialist" ${currentRole == 'specialist' ? 'selected' : ''}>Kỹ thuật viên</option>
              <option value="staff" ${currentRole == 'staff' ? 'selected' : ''}>Nhân viên tiếp đón</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Requests Table -->
      <div class="refund-card p-0 overflow-hidden">
        <div class="table-responsive">
          <table class="table refund-table leave-table mb-0">
            <colgroup><col style="width:7%"><col style="width:23%"><col style="width:20%"><col style="width:20%"><col style="width:14%"><col style="width:16%"></colgroup>
            <thead>
              <tr>
                <th>Mã đơn</th>
                <th>Nhân sự gửi yêu cầu</th>
                <th>Ca trực xin hủy</th>
                <th>Lý do xin nghỉ</th>
                <th>Thời gian gửi</th>
                <th>Thao tác</th>

              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty requests}">
                  <c:forEach var="r" items="${requests}">
                    <tr>
                      <td class="fw-bold font-monospace text-teal">#LR-${r.requestId}</td>

                      <td>
                        <div class="fw-bold text-dark">${r.requesterName}</div>
                        <div class="leave-person-meta">
                          <span class="badge ${r.requesterRole == 'doctor' ? 'badge-soft-primary' : (r.requesterRole == 'staff' ? 'badge-soft-teal' : 'badge-soft-success')} small" style="font-size: 11px;">
                            ${r.requesterRoleName}
                          </span>
                          <c:if test="${not empty r.roomName && r.roomName != 'Chưa xếp phòng'}">
                            <small class="text-muted"><i class="bi bi-door-open me-1"></i>${r.roomName}</small>
                          </c:if>
                        </div>
                        <small class="text-muted d-block"><i class="bi bi-telephone me-1"></i>${r.requesterPhone}</small>
                      </td>
                      <td>
                        <div class="fw-bold text-danger"><i class="bi bi-calendar-event me-1"></i>${r.leaveDate}</div>
                        <div class="small text-dark fw-semibold font-monospace">${r.slotName} (${r.startTime} - ${r.endTime})</div>
                        <small class="text-muted">Mã ca: #WS-${r.scheduleId}</small>
                      </td>
                      <td>
                        <div class="leave-reason">
                          ${r.reason}
                        </div>
                      </td>
                      <td>
                        <small class="text-muted d-block">${r.createdAt}</small>
                      </td>
                      <td class="refund-action">
                        <c:choose>
                          <c:when test="${r.requestStatus == 'Pending'}">
                            <div class="leave-actions">
                              <!-- Nút Chấp thuận -->
                              <button type="button" class="btn btn-sm btn-outline-success"
                                      onclick="openApproveModal(${r.requestId}, '${fn:escapeXml(r.requesterName)}', '${r.leaveDate}', '${r.slotName}')">
                                <i class="bi bi-check-circle-fill"></i>Duyệt
                              </button>
                              <!-- Nút Từ chối -->
                              <button type="button" class="btn btn-sm btn-outline-danger"
                                      onclick="openRejectModal(${r.requestId}, '${fn:escapeXml(r.requesterName)}')">
                                <i class="bi bi-x-circle-fill"></i>Từ chối
                              </button>
                            </div>
                          </c:when>
                          <c:otherwise>
                            <span class="text-muted small fst-italic">Đã hoàn tất xử lý</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="6" class="text-center py-5 text-muted">
                      <i class="bi bi-inbox fs-1 d-block mb-2 text-muted opacity-50"></i>
                      Không tìm thấy yêu cầu hủy lịch trực nào phù hợp với bộ lọc hiện tại.
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

  <!-- Modal Chấp thuận Duyệt Hủy Ca -->
  <div class="modal fade" id="approveModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <form action="${pageContext.request.contextPath}/director/leave-requests" method="POST">
          <input type="hidden" name="action" value="approve">
          <input type="hidden" name="requestId" id="approveRequestId">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold text-success"><i class="bi bi-check-circle-fill me-2"></i>Chấp thuận đơn xin nghỉ ca trực</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body py-3">
            <p class="mb-2">Bạn có chắc chắn muốn phê duyệt đơn xin hủy ca trực này không?</p>
            <div class="p-3 rounded-3 bg-light border mb-2">
              <div class="mb-1"><b>Nhân sự:</b> <span id="approveEmpName"></span></div>
              <div class="mb-1"><b>Ngày nghỉ:</b> <span id="approveLeaveDate"></span></div>
              <div><b>Khung giờ:</b> <span id="approveSlotName"></span></div>
            </div>
            <div class="alert alert-info py-2 px-3 small mb-0 rounded-3">
              <i class="bi bi-info-circle me-1"></i> Ca trực trong hệ thống sẽ tự động chuyển sang trạng thái <b>Nghỉ phép (On_Leave)</b> và không nhận bệnh nhân đặt lịch.
            </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-success px-4 py-2" style="font-size: 14px;">
              <i class="bi bi-check-circle-fill"></i> Xác nhận chấp thuận
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Modal Từ chối Yêu Cầu Hủy Ca -->
  <div class="modal fade" id="rejectModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <form action="${pageContext.request.contextPath}/director/leave-requests" method="POST">
          <input type="hidden" name="action" value="reject">
          <input type="hidden" name="requestId" id="rejectRequestId">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold text-danger"><i class="bi bi-x-circle-fill me-2"></i>Từ chối đơn xin nghỉ ca trực</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body py-3">
            <p class="mb-2">Từ chối đơn xin nghỉ của: <b id="rejectEmpName"></b></p>
            <div class="mb-3">
              <label for="rejectReason" class="form-label small fw-bold text-muted">Lý do từ chối (Gửi thông báo tới nhân sự):</label>
              <textarea class="form-control rounded-3" id="rejectReason" name="rejectReason" rows="3" placeholder="Nhập lý do không thể duyệt nghỉ (ví dụ: ca trực thiếu nhân sự, lịch khám đã kín...)" required></textarea>
            </div>
            <div class="alert alert-warning py-2 px-3 small mb-0 rounded-3">
              <i class="bi bi-exclamation-triangle me-1"></i> Ca trực sẽ tiếp tục được giữ nguyên trạng thái hoạt động bình thường.
            </div>
          </div>
          <div class="modal-footer border-0 pt-0">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
            <button type="submit" class="btn btn-danger px-4 py-2">
              <i class="bi bi-x-circle-fill"></i> Xác nhận từ chối
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    function openApproveModal(id, name, date, slot) {
      document.getElementById('approveRequestId').value = id;
      document.getElementById('approveEmpName').innerText = name;
      document.getElementById('approveLeaveDate').innerText = date;
      document.getElementById('approveSlotName').innerText = slot;
      new bootstrap.Modal(document.getElementById('approveModal')).show();
    }

    function openRejectModal(id, name) {
      document.getElementById('rejectRequestId').value = id;
      document.getElementById('rejectEmpName').innerText = name;
      document.getElementById('rejectReason').value = '';
      new bootstrap.Modal(document.getElementById('rejectModal')).show();
    }
  </script>
</body>
</html>
