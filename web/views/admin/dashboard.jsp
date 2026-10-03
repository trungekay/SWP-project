<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Doanh thu - VisionCare Admin</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">

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
      .page-content { padding: 30px; }
      .page-title { margin-bottom: 24px; }
      .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
      .breadcrumbs { font-size: 14px; color: #64748b; }
      .breadcrumbs ol { list-style: none; padding: 0; margin: 0; display: flex; gap: 8px; }
      .breadcrumbs ol li.current { color: #0f172a; font-weight: 500; }
      .breadcrumbs ol li a { color: var(--primary-color); text-decoration: none; }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="dashboard" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content bg-light pb-5">
            <div class="page-title">
              <div class="container-fluid px-0">
                <h2 class="mb-0">Dashboard Tổng quan</h2>
                <nav class="breadcrumbs mt-2">
                  <ol>
                    <li class="current">Admin Dashboard</li>
                  </ol>
                </nav>
              </div>
            </div>

            <section class="section pt-4">
              <div class="container-fluid px-0">
                
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
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
