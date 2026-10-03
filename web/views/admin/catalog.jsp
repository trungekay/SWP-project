<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Dịch vụ và Vật tư - VisionCare Admin</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Vendor CSS Files (from header.jsp) -->
    <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/aos/aos.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">
    
    <!-- Main CSS File -->
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/dentalcare-public.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css" rel="stylesheet">

    <jsp:include page="/views/admin/layout/admin-css.jsp" />
</head>
<body>
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="catalog" />
    </jsp:include>
    <main class="main-wrapper catalog-page">
        <jsp:include page="/views/admin/layout/admin-header.jsp" />
        <div class="page-content pb-0">
            <div class="page-header">
                <div class="page-title">
                    <h2>Quản lý Danh mục</h2>
                    <p>Dịch vụ &amp; Vật tư y tế</p>
                </div>
            </div>
        </div>
  <div class="container catalog-layout">
    <aside class="catalog-sidebar" aria-label="Phân mục quản trị">
      <div class="catalog-panel catalog-nav-panel">
        <p class="catalog-eyebrow">Phân mục quản trị</p>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? '' : 'is-active'}" data-tab="services" aria-selected="${param.tab == 'supplies' ? 'false' : 'true'}"><span><i class="bi bi-clipboard2-pulse"></i> Dịch vụ phòng khám</span><b>${catalogServices.size()}</b></button>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? 'is-active' : ''}" data-tab="supplies" aria-selected="${param.tab == 'supplies' ? 'true' : 'false'}"><span><i class="bi bi-box-seam"></i> Vật tư &amp; Thiết bị</span><b>${catalogSupplies.size()}</b></button>
      </div>

      <section class="section pt-4">
        <div class="container">

          <ul class="nav nav-tabs mb-4" id="catalogTabs" role="tablist">
            <li class="nav-item" role="presentation">
              <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#services" type="button"
                role="tab">Dịch vụ Phòng Khám</button>
            </li>
            <li class="nav-item" role="presentation">
              <button class="nav-link" data-bs-toggle="tab" data-bs-target="#items" type="button" role="tab">Vật tư
                (Thuốc/Kính)</button>
            </li>
          </ul>

          <div class="tab-content" id="catalogTabsContent">
            <!-- Services Tab -->
            <div class="tab-pane fade show active" id="services" role="tabpanel">
              <div class="admin-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                  <h5 class="mb-0">Danh sách Dịch vụ</h5>
                  <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addServiceModal"><i
                      class="bi bi-plus-circle me-1"></i>Thêm dịch vụ</button>
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
                          <button class="btn btn-sm btn-outline-primary" title="Cập nhật giá" data-bs-toggle="modal"
                            data-bs-target="#updatePriceModal"><i class="bi bi-pencil"></i></button>
                        </td>
                      </tr>
                      <tr>
                        <td>SV02</td>
                        <td>Đo khúc xạ, cắt kính</td>
                        <td class="text-danger fw-bold">150,000 đ</td>
                        <td class="text-end">
                          <button class="btn btn-sm btn-outline-primary" title="Cập nhật giá" data-bs-toggle="modal"
                            data-bs-target="#updatePriceModal"><i class="bi bi-pencil"></i></button>
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
                          <button class="btn btn-sm btn-outline-primary" title="Cập nhật"><i
                              class="bi bi-pencil"></i></button>
                        </td>
                      </tr>
                      <tr>
                        <td>IT02</td>
                        <td>Gọng kính Titanium</td>
                        <td>Kính</td>
                        <td class="text-danger fw-bold">850,000 đ</td>
                        <td>45 cái</td>
                        <td class="text-end">
                          <button class="btn btn-sm btn-outline-primary" title="Cập nhật"><i
                              class="bi bi-pencil"></i></button>
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
  </div>
</main>
<dialog id="catalogDeleteDialog" class="catalog-delete-dialog" aria-labelledby="catalogDeleteTitle" aria-describedby="catalogDeleteDescription">
  <div class="catalog-delete-dialog-icon" aria-hidden="true"><i class="bi bi-trash3"></i></div>
  <h2 id="catalogDeleteTitle">Xác nhận xóa</h2>
  <p id="catalogDeleteDescription">Bạn có chắc muốn xóa <span id="catalogDeleteKind"></span> <strong id="catalogDeleteName"></strong>?</p>
  <p class="catalog-delete-dialog-note">Mục này sẽ bị xóa khỏi database và không thể khôi phục từ trang quản trị.</p>
  <div class="catalog-delete-dialog-actions">
    <button id="catalogDeleteCancel" type="button" class="catalog-delete-cancel">Hủy</button>
    <button id="catalogDeleteConfirm" type="button" class="catalog-delete-confirm"><i class="bi bi-trash"></i> Xác nhận xóa</button>
  </div>
</dialog>
<script src="${pageContext.request.contextPath}/assets/js/admin-catalog.js?v=2" defer></script>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
