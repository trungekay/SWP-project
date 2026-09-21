<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Dịch vụ y tế - MediLab Admin</title>
    <!-- Thư viện CSS Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Thư viện FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar bên trái (Đã chuẩn RBAC) -->
            <div class="col-md-2 text-white min-vh-100 p-3" style="background-color: #2C4964;">
                <h5 class="text-center mt-3 mb-4 fw-bold">MediLab Admin</h5>
                <ul class="nav flex-column gap-2">
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white-50">
                            <i class="fa-solid fa-chart-line me-2"></i>Tổng quan
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white rounded active" style="background-color: #1977CC;">
                            <i class="fa-solid fa-stethoscope me-2"></i>Quản lý Dịch vụ
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white-50">
                            <i class="fa-solid fa-pills me-2"></i>Quản lý Thuốc
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white-50">
                            <i class="fa-solid fa-users-gear me-2"></i>Quản lý Nhân sự
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Nội dung chính bên phải -->
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="text-secondary">Trang chủ / Quản lý Dịch vụ y tế</h5>
                    
                    <!-- Nút Thêm mới -->
                    <button class="btn text-white px-3" style="background-color: #1977CC;" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                        Thêm mới
                    </button>
                </div>

                <!-- Bảng danh sách dịch vụ (Đã cập nhật dữ liệu Phòng khám Mắt) -->
                <div class="card shadow-sm border-0">
                    <div class="card-body p-0">
                        <table class="table table-hover mb-0">
                            <thead style="background-color: #F1F7FD;">
                                <tr>
                                    <th class="py-3 px-4">Mã DV</th>
                                    <th class="py-3 px-4">Tên dịch vụ</th>
                                    <th class="py-3 px-4">Danh mục</th>
                                    <th class="py-3 px-4">Đơn giá</th>
                                    <th class="py-3 px-4">Trạng thái</th>
                                    <th class="py-3 px-4">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="py-3 px-4">DV001</td>
                                    <td class="py-3 px-4">Đo thị lực & Khám mắt tổng quát</td>
                                    <td class="py-3 px-4">Khám lâm sàng</td>
                                    <td class="py-3 px-4">150.000 đ</td>
                                    <td class="py-3 px-4"><span class="text-success fw-medium">Hoạt động</span></td>
                                    <td class="py-3 px-4">
                                        <a href="#" class="text-primary text-decoration-none me-3">Sửa</a>
                                        <a href="#" class="text-danger text-decoration-none">Xoá</a>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="py-3 px-4">DV002</td>
                                    <td class="py-3 px-4">Đo nhãn áp bằng nhãn áp kế</td>
                                    <td class="py-3 px-4">Khám cận lâm sàng</td>
                                    <td class="py-3 px-4">200.000 đ</td>
                                    <td class="py-3 px-4"><span class="text-success fw-medium">Hoạt động</span></td>
                                    <td class="py-3 px-4">
                                        <a href="#" class="text-primary text-decoration-none me-3">Sửa</a>
                                        <a href="#" class="text-danger text-decoration-none">Xoá</a>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="py-3 px-4">DV003</td>
                                    <td class="py-3 px-4">Chụp OCT đáy mắt</td>
                                    <td class="py-3 px-4">Chẩn đoán hình ảnh</td>
                                    <td class="py-3 px-4">450.000 đ</td>
                                    <td class="py-3 px-4"><span class="text-success fw-medium">Hoạt động</span></td>
                                    <td class="py-3 px-4">
                                        <a href="#" class="text-primary text-decoration-none me-3">Sửa</a>
                                        <a href="#" class="text-danger text-decoration-none">Xoá</a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Popup Modal Thêm mới dịch vụ y tế -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" style="color: #2C4964;">Thêm mới dịch vụ y tế</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form>
                        <div class="mb-3">
                            <label class="form-label fw-medium">Tên dịch vụ *</label>
                            <input type="text" class="form-control" placeholder="dịch vụ y tế....">
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Danh mục *</label>
                                <select class="form-select text-secondary">
                                    <option>-- Chọn danh mục --</option>
                                    <option>Khám lâm sàng</option>
                                    <option>Khám cận lâm sàng</option>
                                    <option>Chẩn đoán hình ảnh</option>
                                    <option>Tiểu phẫu / Phẫu thuật</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Đơn giá (VNĐ) *</label>
                                <input type="number" class="form-control" value="0">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-medium">Mô tả / Ghi chú</label>
                            <textarea class="form-control" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light border px-4" data-bs-dismiss="modal">Huỷ</button>
                    <button type="button" class="btn text-white px-4" style="background-color: #1977CC;">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Javascript Bootstrap 5 -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>