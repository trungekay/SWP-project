<?php include 'includes/header.php'; ?>

<!-- Khu vực code riêng của nhóm Quản lý User -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
    <h2>Danh sách User Account</h2>
    <button style="padding: 8px 15px; background: #007bff; color: #fff; border: none; cursor: pointer;">+ Thêm mới User</button>
</div>

<!-- Khung Bảng dữ liệu (Table) -->
<table style="width: 100%; border-collapse: collapse; background: #fff;">
    <tr style="background: #e9ecef; text-align: left;">
        <th style="padding: 12px; border: 1px solid #dee2e6;">ID</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Tên đăng nhập</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Email</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Quyền</th>
        <th style="padding: 12px; border: 1px solid #dee2e6;">Hành động</th>
    </tr>
    <tr>
        <td style="padding: 12px; border: 1px solid #dee2e6;">1</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">nguyenvana</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">a@gmail.com</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">Khách hàng</td>
        <td style="padding: 12px; border: 1px solid #dee2e6;">
            <button>Sửa</button>
            <button>Xóa</button>
        </td>
    </tr>
</table>

<?php include 'includes/footer.php'; ?>