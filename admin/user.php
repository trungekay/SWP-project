<?php include 'header.php'; ?>

<style>
    /* CSS cho Phân trang */
    .pagination { display: flex; list-style: none; padding: 0; justify-content: flex-end; margin-top: 20px; }
    .pagination li { margin: 0 5px; }
    .pagination a { padding: 8px 12px; border: 1px solid #dee2e6; color: #007bff; text-decoration: none; border-radius: 4px; transition: 0.2s; }
    .pagination a:hover, .pagination .active a { background: #007bff; color: white; border-color: #007bff; }

    /* CSS cho Popup (Modal) */
    .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); align-items: center; justify-content: center; }
    .modal-content { background-color: #fff; padding: 20px; border-radius: 8px; width: 450px; box-shadow: 0 4px 15px rgba(0,0,0,0.2); }
    .modal-header { display: flex; justify-content: space-between; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
    .modal-header h3 { margin: 0; font-size: 18px; color: #333; }
    .close-btn { cursor: pointer; font-size: 24px; font-weight: bold; color: #aaa; border: none; background: none; line-height: 1; }
    .close-btn:hover { color: red; }
    
    /* Cấu trúc Form trong Popup */
    .form-group { margin-bottom: 15px; text-align: left; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: bold; font-size: 14px; color: #555;}
    .form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    .btn-submit { background: #28a745; color: white; border: none; padding: 10px 15px; cursor: pointer; border-radius: 4px; width: 100%; font-size: 16px; font-weight: bold; }
    .btn-submit:hover { background: #218838; }
    
    /* Nút bấm trong bảng */
    .btn-action { padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; color: white; margin-right: 5px; font-size: 13px;}
    .btn-edit { background: #ffc107; color: #000; }
    .btn-delete { background: #dc3545; }
</style>

<!-- Tiêu đề trang và Nút Thêm mới chuẩn phong cách MediLab -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
    <h2 style="margin: 0;">Danh sách User Account</h2>
    <button id="btnOpenAddModal" class="btn-medilab">+ Thêm mới User</button>
</div>

<!-- Khung Bảng dữ liệu -->
<table style="width: 100%; border-collapse: collapse; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
    <tr style="background: #e9ecef; text-align: left;">
        <th style="padding: 12px; border: 1px solid #dee2e6;">ID</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Tên đăng nhập</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Email</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Quyền</th>
        <th style="padding: 12px; border: 1px solid #dee2e6; text-align: center;">Hành động</th>
    </tr>
    <tr>
        <td style="padding: 12px; border: 1px solid #dee2e6;">1</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">nguyenvana</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">a@gmail.com</td>
        <td style="padding: 12px; border: 1px solid #dee2e6; color: green; font-weight: bold;">Khách hàng</td>
        <td style="padding: 12px; border: 1px solid #dee2e6; text-align: center;">
            <button class="btn-action btn-edit" onclick="openEditModal()">Sửa</button>
            <button class="btn-action btn-delete">Xóa</button>
        </td>
    </tr>
    <tr>
        <td style="padding: 12px; border: 1px solid #dee2e6;">2</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">admin_phongkham</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">admin@medilab.com</td>
        <td style="padding: 12px; border: 1px solid #dee2e6; color: red; font-weight: bold;">Admin</td>
        <td style="padding: 12px; border: 1px solid #dee2e6; text-align: center;">
            <button class="btn-action btn-edit" onclick="openEditModal()">Sửa</button>
            <button class="btn-action btn-delete">Xóa</button>
        </td>
    </tr>
</table>

<!-- Phân trang (Pagination) -->
<ul class="pagination">
    <li><a href="#">&laquo; Trước</a></li>
    <li class="active"><a href="#">1</a></li>
    <li><a href="#">2</a></li>
    <li><a href="#">3</a></li>
    <li><a href="#">Sau &raquo;</a></li>
</ul>

<!-- Popup 1: Thêm Mới User -->
<div id="addModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Thêm mới User Account</h3>
            <button class="close-btn" onclick="closeModal('addModal')">&times;</button>
        </div>
        <form>
            <div class="form-group">
                <label>Tên đăng nhập *</label>
                <input type="text" placeholder="Nhập tên đăng nhập..." required>
            </div>
            <div class="form-group">
                <label>Email *</label>
                <input type="email" placeholder="Nhập địa chỉ email..." required>
            </div>
            <div class="form-group">
                <label>Mật khẩu khởi tạo *</label>
                <input type="password" placeholder="Nhập mật khẩu..." required>
            </div>
            <div class="form-group">
                <label>Cấp quyền ban đầu</label>
                <select>
                    <option>Khách hàng</option>
                    <option>Nhân viên (Staff)</option>
                    <option>Admin</option>
                </select>
            </div>
            <button type="button" class="btn-submit" onclick="closeModal('addModal')">Lưu thông tin</button>
        </form>
    </div>
</div>

<!-- Popup 2: Cập nhật & Phân quyền -->
<div id="editModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Cập nhật & Phân quyền</h3>
            <button class="close-btn" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form>
            <div class="form-group">
                <label>Tên đăng nhập</label>
                <input type="text" value="nguyenvana" readonly style="background: #e9ecef; color: #666; cursor: not-allowed;">
                <small style="color: #888;">*Không thể thay đổi tên đăng nhập</small>
            </div>
            <div class="form-group">
                <label>Thay đổi Quyền (Role)</label>
                <select>
                    <option selected>Khách hàng</option>
                    <option>Nhân viên (Staff)</option>
                    <option>Admin</option>
                </select>
            </div>
            <button type="button" class="btn-submit" style="background: #ffc107; color: #000;" onclick="closeModal('editModal')">Lưu thay đổi</button>
        </form>
    </div>
</div>

<script>
    // Xử lý mở Popup Thêm mới
    document.getElementById('btnOpenAddModal').addEventListener('click', function() {
        document.getElementById('addModal').style.display = 'flex';
    });

    // Xử lý mở Popup Cập nhật (gắn vào nút Sửa trong bảng)
    function openEditModal() {
        document.getElementById('editModal').style.display = 'flex';
    }

    // Hàm đóng Popup chung
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    // Bấm ra ngoài khoảng đen để đóng Popup
    window.onclick = function(event) {
        if (event.target.className.includes('modal')) {
            event.target.style.display = 'none';
        }
    }
</script>

<?php include 'footer.php'; ?>