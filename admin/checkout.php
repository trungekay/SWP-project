<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán viện phí - MediLab Staff</title>
    <!-- Thư viện CSS Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Thư viện FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .bg-primary-custom { background-color: #1977CC !important; }
        .text-primary-custom { color: #1977CC !important; }
        .bg-dark-custom { background-color: #2C4964 !important; }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar bên trái dành cho STAFF -->
            <div class="col-md-2 text-white min-vh-100 p-3 bg-dark-custom">
                <h5 class="text-center mt-3 mb-4 fw-bold">
                    <i class="fa-solid fa-user-nurse me-2"></i>MediLab Staff
                </h5>
                <div class="small text-white-50 text-center mb-4">Ca làm việc: Sáng (Nguyễn Thu Hà)</div>
                <ul class="nav flex-column gap-2">
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white-50">
                            <i class="fa-solid fa-calendar-check me-2"></i>Tiếp đón bệnh nhân
                        </a>
                    </li>
                    <li class="nav-item">
                        <!-- Tab Thanh toán đang được active -->
                        <a href="#" class="nav-link text-white rounded active bg-primary-custom">
                            <i class="fa-solid fa-file-invoice-dollar me-2"></i>Thanh toán viện phí
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="#" class="nav-link text-white-50">
                            <i class="fa-solid fa-clock-rotate-left me-2"></i>Lịch sử giao dịch
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Nội dung chính bên phải -->
            <div class="col-md-10 p-4">
                <h5 class="text-secondary mb-4">Trang chủ / Thanh toán viện phí</h5>

                <!-- Khu vực Tra cứu bệnh nhân -->
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-body">
                        <div class="row align-items-end">
                            <div class="col-md-5">
                                <label class="form-label fw-medium">Tra cứu hóa đơn bệnh nhân</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="fa-solid fa-phone text-muted"></i></span>
                                    <input type="text" class="form-control" placeholder="Nhập số điện thoại (vd: 0987654321)...">
                                </div>
                            </div>
                            <div class="col-md-3">
                                <button class="btn text-white px-4 bg-primary-custom w-100">
                                    <i class="fa-solid fa-magnifying-glass me-2"></i>Tìm kiếm
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Khu vực Chi tiết Hóa đơn (Mô phỏng sau khi tìm thấy bệnh nhân) -->
                <div class="row">
                    <!-- Cột thông tin bệnh nhân và dịch vụ -->
                    <div class="col-md-8">
                        <div class="card shadow-sm border-0 mb-4 h-100">
                            <div class="card-header bg-white py-3">
                                <h6 class="mb-0 fw-bold text-primary-custom">Chi tiết dịch vụ đã sử dụng</h6>
                            </div>
                            <div class="card-body">
                                <div class="row mb-4 bg-light p-3 rounded mx-0">
                                    <div class="col-sm-6">
                                        <p class="mb-1 text-muted small">Tên bệnh nhân</p>
                                        <h6 class="mb-0 fw-bold">Trần Văn Bình</h6>
                                    </div>
                                    <div class="col-sm-3">
                                        <p class="mb-1 text-muted small">Mã BN</p>
                                        <h6 class="mb-0">BN-202610</h6>
                                    </div>
                                    <div class="col-sm-3">
                                        <p class="mb-1 text-muted small">Trạng thái khám</p>
                                        <span class="badge bg-success">Đã hoàn tất</span>
                                    </div>
                                </div>

                                <table class="table table-bordered mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>STT</th>
                                            <th>Nội dung (Dịch vụ / Thuốc)</th>
                                            <th class="text-center">SL</th>
                                            <th class="text-end">Đơn giá</th>
                                            <th class="text-end">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1</td>
                                            <td>Đo thị lực & Khám mắt tổng quát</td>
                                            <td class="text-center">1</td>
                                            <td class="text-end">150.000 đ</td>
                                            <td class="text-end">150.000 đ</td>
                                        </tr>
                                        <tr>
                                            <td>2</td>
                                            <td>Chụp OCT đáy mắt</td>
                                            <td class="text-center">1</td>
                                            <td class="text-end">450.000 đ</td>
                                            <td class="text-end">450.000 đ</td>
                                        </tr>
                                        <tr>
                                            <td>3</td>
                                            <td>Thuốc nhỏ mắt Systane Ultra 5ml</td>
                                            <td class="text-center">2</td>
                                            <td class="text-end">85.000 đ</td>
                                            <td class="text-end">170.000 đ</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Cột Chốt thanh toán (POS) -->
                    <div class="col-md-4">
                        <div class="card shadow-sm border-0 h-100">
                            <div class="card-header bg-white py-3">
                                <h6 class="mb-0 fw-bold text-primary-custom">Thanh toán hóa đơn</h6>
                            </div>
                            <div class="card-body d-flex flex-column">
                                <div class="d-flex justify-content-between mb-3">
                                    <span class="text-muted">Tổng tiền dịch vụ:</span>
                                    <span class="fw-medium">770.000 đ</span>
                                </div>
                                <div class="d-flex justify-content-between mb-3">
                                    <span class="text-muted">Bảo hiểm Y tế (BHYT):</span>
                                    <span class="text-danger">- 0 đ</span>
                                </div>
                                <hr>
                                <div class="d-flex justify-content-between mb-4">
                                    <span class="fw-bold fs-5">Khách cần trả:</span>
                                    <span class="fw-bold fs-5 text-danger">770.000 đ</span>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted small">Khách thanh toán (Tiền mặt / CK)</label>
                                    <input type="text" class="form-control text-end fw-bold" value="800.000" style="font-size: 1.2rem;">
                                </div>
                                <div class="d-flex justify-content-between mb-4">
                                    <span class="text-muted">Tiền thừa trả khách:</span>
                                    <span class="fw-medium">30.000 đ</span>
                                </div>
                                
                                <div class="mt-auto row g-2">
                                    <div class="col-6">
                                        <button class="btn btn-outline-secondary w-100 py-2">Hủy</button>
                                    </div>
                                    <div class="col-6">
                                        <button class="btn bg-primary-custom text-white w-100 py-2">
                                            <i class="fa-solid fa-print me-2"></i>In biên lai
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Javascript Bootstrap 5 -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>