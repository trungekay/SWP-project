<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý hồ sơ" />
  <jsp:param name="pageDescription" value="Quản lý hồ sơ cá nhân VisionCare" />
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
  </style>

  <main class="main bg-light pb-5">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Hồ sơ cá nhân</h1>
              <p class="mb-0">Quản lý thông tin cá nhân và lịch sử khám bệnh.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Hồ sơ cá nhân</li>
          </ol>
        </div>
      </nav>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="row">
          <div class="col-lg-4">
            <div class="profile-card text-center">
              <img src="${pageContext.request.contextPath}/assets/img/testimonials/testimonials-1.jpg" alt="Avatar" class="profile-avatar">
              <h4>${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted">Bệnh nhân</p>
              
              <ul class="nav nav-pills flex-column text-start mt-4" id="profile-nav">
                <li class="nav-item mb-2">
                  <a class="nav-link active" href="${pageContext.request.contextPath}/profile/manage"><i class="bi bi-person me-2"></i> Thông tin cá nhân</a>
                </li>
                <li class="nav-item mb-2">
                  <a class="nav-link" href="${pageContext.request.contextPath}/profile/change-password"><i class="bi bi-lock me-2"></i> Đổi mật khẩu</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>
          
          <div class="col-lg-8">
            <div class="profile-card">
              <h4 class="mb-4">Thông tin cá nhân</h4>
              <form method="post" action="${pageContext.request.contextPath}/profile/update">
                <div class="row mb-3">
                  <div class="col-md-6">
                    <label class="form-label fw-bold">Họ và tên</label>
                    <input type="text" class="form-control" name="fullName" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Nguyễn Văn A'}">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-bold">Số điện thoại</label>
                    <input type="text" class="form-control" name="phone" value="0901234567">
                  </div>
                </div>
                
                <div class="row mb-3">
                  <div class="col-md-6">
                    <label class="form-label fw-bold">Email</label>
                    <input type="email" class="form-control" name="email" value="nguyenvana@example.com" readonly>
                    <div class="form-text">Không thể thay đổi email đã đăng ký.</div>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-bold">Ngày sinh</label>
                    <input type="date" class="form-control" name="dob" value="1990-01-01">
                  </div>
                </div>

                <div class="mb-4">
                  <label class="form-label fw-bold">Địa chỉ</label>
                  <textarea class="form-control" name="address" rows="3">123 Đường Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM</textarea>
                </div>

                <button type="submit" class="btn btn-custom px-4 py-2"><i class="bi bi-save me-2"></i>Cập nhật thông tin</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
