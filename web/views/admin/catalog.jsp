<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý Danh mục" />
  <jsp:param name="pageDescription" value="Quản lý dịch vụ và vật tư" />
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
        <h2 class="mb-0">Quản lý Danh mục (Dịch vụ & Vật tư)</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="current">Danh mục</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
        
        <ul class="nav nav-tabs mb-4" id="catalogTabs" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#services" type="button" role="tab">Dịch vụ Phòng Khám</button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#items" type="button" role="tab">Vật tư (Thuốc/Kính)</button>
          </li>
        </ul>

        <div class="tab-content" id="catalogTabsContent">
          <!-- Services Tab -->
          <div class="tab-pane fade show active" id="services" role="tabpanel">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Danh sách Dịch vụ</h5>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addServiceModal"><i class="bi bi-plus-circle me-1"></i>Thêm dịch vụ</button>
              </div>
              <div class="table-responsive">
                <table class="table table-hover align-middle border">
                  <thead class="table-light">
                    <tr>
                      <th>Mã DV</th>
                      <th>Tên dịch vụ</th>
                      <th>Đơn giá</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>SV01</td>
                      <td>Khám mắt tổng quát</td>
                      <td class="text-danger fw-bold">200,000 đ</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" title="Cập nhật giá" data-bs-toggle="modal" data-bs-target="#updatePriceModal"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                    <tr>
                      <td>SV02</td>
                      <td>Đo khúc xạ, cắt kính</td>
                      <td class="text-danger fw-bold">150,000 đ</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" title="Cập nhật giá" data-bs-toggle="modal" data-bs-target="#updatePriceModal"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Items Tab -->
          <div class="tab-pane fade" id="items" role="tabpanel">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Danh sách Vật tư (Thuốc, Kính)</h5>
                <button class="btn btn-primary"><i class="bi bi-plus-circle me-1"></i>Thêm vật tư</button>
              </div>
              <div class="table-responsive">
                <table class="table table-hover align-middle border">
                  <thead class="table-light">
                    <tr>
                      <th>Mã VT</th>
                      <th>Tên vật tư</th>
                      <th>Loại</th>
                      <th>Đơn giá</th>
                      <th>Tồn kho</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>IT01</td>
                      <td>Thuốc nhỏ mắt V.Rohto</td>
                      <td>Thuốc</td>
                      <td class="text-danger fw-bold">55,000 đ</td>
                      <td>120 hộp</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" title="Cập nhật"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
                    <tr>
                      <td>IT02</td>
                      <td>Gọng kính Titanium</td>
                      <td>Kính</td>
                      <td class="text-danger fw-bold">850,000 đ</td>
                      <td>45 cái</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" title="Cập nhật"><i class="bi bi-pencil"></i></button>
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

  <!-- Modal Update Price -->
  <div class="modal fade" id="updatePriceModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <form>
          <div class="modal-header">
            <h5 class="modal-title">Cập nhật đơn giá</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Đơn giá mới (VNĐ)</label>
              <input type="number" class="form-control" required value="200000">
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
            <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
          </div>
        </form>
      </div>
    </div>
  </div>

<jsp:include page="/views/common/footer.jsp" />
