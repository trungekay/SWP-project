<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Cấu hình Phòng Khám" />
  <jsp:param name="pageDescription" value="Cấu hình phòng khám và khung giờ" />
  <jsp:param name="bodyClass" value="starter-page-page" />
</jsp:include>

  <style>
    .admin-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
    }
  </style>

  <main class="main bg-light pb-5">
    <div class="page-title">
      <div class="container">
        <h2 class="mb-0">Cấu hình Phòng Khám</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="current">Cấu hình</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="row g-4">
          <!-- Clinic Rooms -->
          <div class="col-lg-6">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Danh sách Phòng Khám</h5>
                <button class="btn btn-sm btn-primary"><i class="bi bi-plus"></i> Thêm phòng</button>
              </div>
              <div class="table-responsive">
                <table class="table table-bordered align-middle">
                  <thead class="table-light">
                    <tr>
                      <th>Mã phòng</th>
                      <th>Tên phòng</th>
                      <th>Chức năng</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>P101</td>
                      <td>Phòng Khám 01</td>
                      <td>Khám tổng quát</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                    <tr>
                      <td>P102</td>
                      <td>Phòng Khúc Xạ</td>
                      <td>Đo khúc xạ</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Appointment Time Slots -->
          <div class="col-lg-6">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Cấu hình Khung giờ khám</h5>
                <button class="btn btn-sm btn-primary"><i class="bi bi-plus"></i> Thêm khung giờ</button>
              </div>
              <div class="table-responsive">
                <table class="table table-bordered align-middle">
                  <thead class="table-light">
                    <tr>
                      <th>Ca</th>
                      <th>Thời gian</th>
                      <th>Trạng thái</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>Sáng 1</td>
                      <td>07:30 - 08:30</td>
                      <td><span class="badge bg-success">Hoạt động</span></td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                    <tr>
                      <td>Sáng 2</td>
                      <td>08:30 - 09:30</td>
                      <td><span class="badge bg-success">Hoạt động</span></td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

<jsp:include page="/views/common/footer.jsp" />
