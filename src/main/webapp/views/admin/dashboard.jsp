<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Dashboard Doanh thu" />
  <jsp:param name="pageDescription" value="Dashboard quản trị VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <style>
    .admin-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
      height: 100%;
    }
    .stat-icon {
      width: 50px;
      height: 50px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
    }
    .bg-light-primary { background: #e0f2fe; color: #0284c7; }
    .bg-light-success { background: #dcfce7; color: #16a34a; }
    .bg-light-warning { background: #fef08a; color: #ca8a04; }
  </style>

  <main class="main bg-light pb-5">
    <div class="page-title">
      <div class="container">
        <h2 class="mb-0">Dashboard Tổng quan</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Admin Dashboard</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
        
        <div class="row g-4 mb-4">
          <!-- Revenue -->
          <div class="col-md-4">
            <div class="admin-card d-flex align-items-center">
              <div class="stat-icon bg-light-success me-3"><i class="bi bi-cash-stack"></i></div>
              <div>
                <p class="text-muted mb-1 small text-uppercase">Doanh thu tháng này</p>
                <h4 class="mb-0 fw-bold">125,000,000 ₫</h4>
              </div>
            </div>
          </div>
          <!-- Patients -->
          <div class="col-md-4">
            <div class="admin-card d-flex align-items-center">
              <div class="stat-icon bg-light-primary me-3"><i class="bi bi-people"></i></div>
              <div>
                <p class="text-muted mb-1 small text-uppercase">Bệnh nhân hôm nay</p>
                <h4 class="mb-0 fw-bold">42</h4>
              </div>
            </div>
          </div>
          <!-- Conversion -->
          <div class="col-md-4">
            <div class="admin-card d-flex align-items-center">
              <div class="stat-icon bg-light-warning me-3"><i class="bi bi-graph-up"></i></div>
              <div>
                <p class="text-muted mb-1 small text-uppercase">Tỷ lệ chuyển đổi</p>
                <h4 class="mb-0 fw-bold">68%</h4>
              </div>
            </div>
          </div>
        </div>

        <div class="row g-4">
          <div class="col-lg-8">
            <div class="admin-card">
              <h5 class="mb-4">Biểu đồ doanh thu (Mô phỏng)</h5>
              <!-- Mock chart placeholder -->
              <div class="bg-light rounded d-flex align-items-center justify-content-center" style="height: 300px; border: 1px dashed #ccc;">
                <p class="text-muted"><i class="bi bi-bar-chart-fill me-2"></i>[Biểu đồ sẽ được render bằng JS (vd: Chart.js)]</p>
              </div>
            </div>
          </div>
          
          <div class="col-lg-4">
            <div class="admin-card">
              <h5 class="mb-4">Số lượng bệnh nhân / Tháng</h5>
              <ul class="list-group list-group-flush">
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                  Tháng 9 <span class="badge bg-primary rounded-pill">1,240</span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                  Tháng 8 <span class="badge bg-primary rounded-pill">1,120</span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                  Tháng 7 <span class="badge bg-primary rounded-pill">980</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

      </div>
    </section>
  </main>

<jsp:include page="/views/common/footer.jsp" />
