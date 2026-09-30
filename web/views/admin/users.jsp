<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý Người dùng" />
  <jsp:param name="pageDescription" value="Quản lý hệ thống người dùng VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
</jsp:include>

  <style>
    .admin-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
    }
    .table-hover tbody tr:hover {
      background-color: #f8fafc;
    }
  </style>

  <main class="main bg-light pb-5">
    <div class="page-title">
      <div class="container">
        <h2 class="mb-0">Quản lý Người dùng</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="current">Người dùng</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
        <div class="admin-card">
          <div class="d-flex justify-content-between align-items-center mb-4">
            <h5 class="mb-0">Danh sách người dùng hệ thống</h5>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal"><i class="bi bi-plus-circle me-1"></i>Thêm người dùng</button>
          </div>

          <div class="table-responsive">
            <table class="table table-hover align-middle border">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Họ tên</th>
                  <th>Email</th>
                  <th>Vai trò</th>
                  <th>Trạng thái</th>
                  <th class="text-end">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <!-- Mock Data Row -->
                <tr>
                  <td>#US001</td>
                  <td>Nguyễn Văn Admin</td>
                  <td>admin@visioncare.vn</td>
                  <td><span class="badge bg-danger">Admin</span></td>
                  <td><span class="badge bg-success">Hoạt động</span></td>
                  <td class="text-end">
                    <button class="btn btn-sm btn-outline-secondary" title="Xem chi tiết"><i class="bi bi-eye"></i></button>
                    <button class="btn btn-sm btn-outline-primary" title="Cập nhật"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-warning" title="Vô hiệu hóa"><i class="bi bi-pause-circle"></i></button>
                  </td>
                </tr>
                <tr>
                  <td>#US002</td>
                  <td>Trần Thị Bác Sĩ</td>
                  <td>doctor@visioncare.vn</td>
                  <td><span class="badge bg-info">Bác sĩ</span></td>
                  <td><span class="badge bg-success">Hoạt động</span></td>
                  <td class="text-end">
                    <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-eye"></i></button>
                    <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-warning"><i class="bi bi-pause-circle"></i></button>
                  </td>
                </tr>
                <tr>
                  <td>#US003</td>
                  <td>Lê Văn User</td>
                  <td>user@gmail.com</td>
                  <td><span class="badge bg-secondary">Bệnh nhân</span></td>
                  <td><span class="badge bg-danger">Khóa</span></td>
                  <td class="text-end">
                    <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-eye"></i></button>
                    <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-success" title="Kích hoạt"><i class="bi bi-play-circle"></i></button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
        </div>
      </div>
    </section>
  </main>

  <!-- Modal Thêm Người dùng (Mock) -->
  <div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <form>
          <div class="modal-header">
            <h5 class="modal-title">Thêm người dùng hệ thống</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Họ tên</label>
              <input type="text" class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Email</label>
              <input type="email" class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Phân quyền (Vai trò)</label>
              <select class="form-select">
                <option>Admin</option>
                <option>Bác sĩ</option>
                <option>Nhân viên</option>
                <option>Bệnh nhân</option>
              </select>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-primary">Lưu người dùng</button>
          </div>
        </form>
      </div>
    </div>
  </div>

<jsp:include page="/views/common/footer.jsp" />
