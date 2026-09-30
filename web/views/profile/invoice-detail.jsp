<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Chi tiết hóa đơn" />
  <jsp:param name="pageDescription" value="Chi tiết hóa đơn VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <style>
    .invoice-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      padding: 40px;
      margin-top: 20px;
      margin-bottom: 40px;
    }
    .invoice-header {
      border-bottom: 2px dashed #eee;
      padding-bottom: 20px;
      margin-bottom: 30px;
    }
    .invoice-footer {
      border-top: 2px dashed #eee;
      padding-top: 20px;
      margin-top: 30px;
    }
    .table-invoice th {
      background-color: #f8f9fa;
      color: #333;
      font-weight: 600;
    }
    .text-teal {
      color: #0d9488;
    }
    .bg-teal {
      background-color: #0d9488;
    }
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Chi tiết hóa đơn</h1>
              <p class="mb-0">Hóa đơn điện tử phòng khám mắt VisionCare</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp">Hồ sơ y tế</a></li>
            <li class="current">Chi tiết hóa đơn</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-9">
            
            <div class="d-flex justify-content-end mb-3 gap-2">
              <button class="btn btn-outline-secondary" onclick="window.print()"><i class="bi bi-printer me-2"></i>In hóa đơn</button>
              <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class="btn text-white bg-teal"><i class="bi bi-arrow-left me-2"></i>Quay lại</a>
            </div>

            <div class="invoice-card">
              <div class="invoice-header d-flex justify-content-between align-items-center flex-wrap">
                <div>
                  <h3 class="fw-bold text-teal mb-0"><i class="bi bi-eye me-2"></i>VisionCare</h3>
                  <p class="text-muted small mt-2 mb-0">Địa chỉ: 456 Lê Thị Riêng, Quận 10, TP.HCM</p>
                  <p class="text-muted small mb-0">Điện thoại: 1800 599 988 | Email: hotro@visioncare.vn</p>
                </div>
                <div class="text-end mt-3 mt-md-0">
                  <h4 class="fw-bold mb-1">HÓA ĐƠN THANH TOÁN</h4>
                  <p class="mb-0 fw-bold text-muted">Mã HĐ: <span class="text-dark">#INV-00123</span></p>
                  <p class="small text-muted mb-0">Ngày lập: 10/09/2026</p>
                  <span class="badge bg-success px-3 py-2 mt-2">Đã thanh toán</span>
                </div>
              </div>

              <div class="row mb-5">
                <div class="col-md-6">
                  <h6 class="fw-bold text-muted mb-3">Thông tin bệnh nhân:</h6>
                  <p class="mb-1 fw-bold">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</p>
                  <p class="mb-1 small text-muted"><i class="bi bi-telephone me-2"></i>${not empty sessionScope.user.phone ? sessionScope.user.phone : '0987654321'}</p>
                  <p class="mb-1 small text-muted"><i class="bi bi-geo-alt me-2"></i>${not empty sessionScope.user.address ? sessionScope.user.address : '123 Nguyễn Trãi, Thanh Xuân, Hà Nội'}</p>
                </div>
                <div class="col-md-6 text-md-end mt-4 mt-md-0">
                  <h6 class="fw-bold text-muted mb-3">Thông tin điều trị:</h6>
                  <p class="mb-1 small"><span class="text-muted">Bác sĩ phụ trách:</span> <span class="fw-bold">Trần Thị B</span></p>
                  <p class="mb-1 small"><span class="text-muted">Mã bệnh án:</span> <span class="fw-bold">#MR-9921</span></p>
                </div>
              </div>

              <div class="table-responsive mb-4">
                <table class="table table-bordered table-invoice align-middle">
                  <thead>
                    <tr>
                      <th class="text-center" width="5%">STT</th>
                      <th>Nội dung / Dịch vụ</th>
                      <th class="text-center" width="10%">SL</th>
                      <th class="text-end" width="20%">Đơn giá (VNĐ)</th>
                      <th class="text-end" width="20%">Thành tiền (VNĐ)</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td class="text-center">1</td>
                      <td>Khám mắt tổng quát</td>
                      <td class="text-center">1</td>
                      <td class="text-end">250,000</td>
                      <td class="text-end">250,000</td>
                    </tr>
                    <tr>
                      <td class="text-center">2</td>
                      <td>Cắt kính cận siêu mỏng (Chống UV)</td>
                      <td class="text-center">1</td>
                      <td class="text-end">1,000,000</td>
                      <td class="text-end">1,000,000</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="row justify-content-end">
                <div class="col-md-5">
                  <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">Tạm tính:</span>
                    <span class="fw-bold">1,250,000 VNĐ</span>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">Giảm giá:</span>
                    <span class="fw-bold text-danger">- 0 VNĐ</span>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between align-items-center">
                    <span class="fw-bold fs-5 text-teal">Tổng cộng:</span>
                    <span class="fw-bold fs-4 text-teal">1,250,000 VNĐ</span>
                  </div>
                </div>
              </div>

              <div class="invoice-footer text-center mt-5">
                <p class="fw-bold mb-1">Cảm ơn bạn đã tin tưởng VisionCare!</p>
                <p class="text-muted small">Lưu ý: Hóa đơn này có giá trị lưu hành nội bộ và có thể sử dụng làm căn cứ hoàn tiền trong vòng 7 ngày kể từ ngày xuất.</p>
              </div>

            </div>
          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
