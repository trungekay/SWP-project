<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Yêu cầu hoàn tiền" />
  <jsp:param name="pageDescription" value="Yêu cầu hoàn tiền VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <style>
    .profile-card {
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 5px 30px rgba(0, 0, 0, 0.05);
      padding: 30px;
      margin-bottom: 30px;
    }
    .profile-avatar {
      width: 120px;
      height: 120px;
      border-radius: 50%;
      object-fit: cover;
      margin-bottom: 20px;
      border: 4px solid #e0f2fe;
    }
    .btn-custom {
      background: #0d9488;
      color: #fff;
    }
    .btn-custom:hover {
      background: #0f766e;
      color: #fff;
    }
    .nav-pills .nav-link.active {
      background-color: #0d9488;
    }
    .nav-pills .nav-link {
      color: #333;
    }
    .table th {
      font-weight: 600;
      color: #333;
      border-bottom-width: 1px;
    }
    .table td {
      vertical-align: middle;
      color: #555;
    }
    .badge-success-custom {
      background-color: #2e7d32;
      color: #fff;
      padding: 5px 10px;
      border-radius: 4px;
      font-weight: 500;
      font-size: 12px;
      white-space: nowrap;
    }
    .badge-warning-custom {
      background-color: #f59e0b;
      color: #fff;
      padding: 5px 10px;
      border-radius: 4px;
      font-weight: 500;
      font-size: 12px;
      white-space: nowrap;
    }
    .badge-danger-custom {
      background-color: #ef4444;
      color: #fff;
      padding: 5px 10px;
      border-radius: 4px;
      font-weight: 500;
      font-size: 12px;
      white-space: nowrap;
    }
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Hồ sơ cá nhân</h1>
              <p class="mb-0">Quản lý yêu cầu hoàn tiền của bạn.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Yêu cầu hoàn tiền</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="row">
          <div class="col-lg-4">
            <div class="profile-card text-center border-0 shadow-sm" style="border-right: 1px solid #eee !important; border-radius: 0;">
              <div class="mb-3">
                <span class="badge bg-light text-dark rounded-pill border px-3 py-1">Avatar</span>
              </div>
              <h4 class="fw-bold" style="color: #1c355e;">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted small">Bệnh nhân</p>
              
              <hr class="mt-4 mb-0">
              <ul class="nav nav-pills flex-column text-start" id="profile-nav">
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/manage.jsp"><i class="bi bi-person me-3 text-muted"></i> Thông tin chung</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp"><i class="bi bi-calendar-check me-3 text-muted"></i> Lịch sử hẹn khám</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/medical-history.jsp"><i class="bi bi-journal-medical me-3 text-muted"></i> Hồ sơ y tế & Thanh toán</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link active py-3" style="background: transparent; color: #0d9488; font-weight: 500;" href="${pageContext.request.contextPath}/views/profile/refund-request.jsp"><i class="bi bi-cash-coin me-3"></i> Yêu cầu hoàn tiền</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link py-3 text-dark" href="${pageContext.request.contextPath}/views/profile/change-password.jsp"><i class="bi bi-key me-3 text-muted"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item mt-3">
                  <a class="nav-link py-3 text-danger fw-500" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-3"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          
          <div class="col-lg-8 ps-lg-5">
            <div class="pt-2">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                  <h4 class="fw-bold" style="color: #1c355e;">Yêu cầu hoàn tiền</h4>
                  <p class="text-muted small mb-0">Theo dõi tiến trình các yêu cầu hoàn tiền của bạn</p>
                </div>
                <button type="button" class="btn text-white" style="background-color: #0d9488;" data-bs-toggle="modal" data-bs-target="#refundModal">
                  <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu
                </button>
              </div>
              <hr class="mb-4">

              <div class="table-responsive mb-5">
                <table class="table table-borderless table-striped align-middle">
                  <thead class="table-light">
                    <tr>
                      <th class="py-3">Mã Y/C</th>
                      <th class="py-3">Mã Hóa Đơn</th>
                      <th class="py-3">Số tiền hoàn</th>
                      <th class="py-3">Lý do</th>
                      <th class="py-3">Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td class="py-3 fw-bold">#REF-001</td>
                      <td class="py-3">#INV-00123</td>
                      <td class="py-3 text-danger fw-bold">1,250,000 đ</td>
                      <td class="py-3 text-truncate" style="max-width: 150px;">Hủy lịch khám do bận việc đột xuất</td>
                      <td class="py-3"><span class="badge-warning-custom">Đang xử lý</span></td>
                    </tr>
                    <tr>
                      <td class="py-3 fw-bold">#REF-002</td>
                      <td class="py-3">#INV-00085</td>
                      <td class="py-3 text-danger fw-bold">350,000 đ</td>
                      <td class="py-3 text-truncate" style="max-width: 150px;">Bác sĩ dời lịch</td>
                      <td class="py-3"><span class="badge-success-custom">Đã hoàn tiền</span></td>
                    </tr>
                  </tbody>
                </table>
              </div>

            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Modal Tạo Yêu Cầu Hoàn Tiền -->
    <div class="modal fade" id="refundModal" tabindex="-1" aria-labelledby="refundModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 12px; border: none; padding: 10px;">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold" id="refundModalLabel" style="color: #0d9488;"><i class="bi bi-cash-coin me-2"></i>Gửi yêu cầu hoàn tiền</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-3 pb-4">
            <p class="text-muted mb-4 small">Vui lòng chọn hóa đơn và cung cấp lý do để chúng tôi tiến hành xác minh và hoàn tiền cho bạn.</p>
            <form action="${pageContext.request.contextPath}/refund/request" method="POST">
              
              <div class="mb-3">
                <label class="form-label small fw-bold">Chọn hóa đơn cần hoàn tiền <span class="text-danger">*</span></label>
                <select class="form-select" name="invoiceId" required>
                  <option value="" disabled selected>-- Chọn hóa đơn --</option>
                  <option value="INV-00215">#INV-00215 - Khám mắt (500,000 đ)</option>
                  <option value="INV-00300">#INV-00300 - Cắt kính (1,000,000 đ)</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label small fw-bold">Số tiền yêu cầu hoàn (VNĐ) <span class="text-danger">*</span></label>
                <input type="number" class="form-control" name="amount" placeholder="VD: 500000" required>
              </div>

              <div class="mb-3">
                <label class="form-label small fw-bold">Lý do hoàn tiền <span class="text-danger">*</span></label>
                <textarea class="form-control" name="reason" rows="3" placeholder="Nhập lý do chi tiết..." required></textarea>
              </div>

              <div class="d-flex justify-content-end gap-2 mt-4">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                <button type="submit" class="btn text-white" style="background-color: #0d9488;">Gửi yêu cầu</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
