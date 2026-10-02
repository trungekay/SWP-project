<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MediLab Eye Clinic</title>
    <style>
        /* CSS Khung Layout Tổng thể */
        body { margin: 0; font-family: Arial, sans-serif; display: flex; height: 100vh; background-color: #f4f6f9; }
        
        /* Sidebar chuẩn màu xanh MediLab (#1977cc) */
        .sidebar { width: 250px; background: #1977cc; color: #fff; display: flex; flex-direction: column; box-shadow: 2px 0 5px rgba(0,0,0,0.1); }
        .sidebar h2 { text-align: center; padding: 20px 0; border-bottom: 1px solid rgba(255, 255, 255, 0.2); margin: 0; font-size: 20px; letter-spacing: 0.5px; }
        .sidebar a { color: #e6f2ff; padding: 15px 20px; text-decoration: none; display: block; border-bottom: 1px solid rgba(255, 255, 255, 0.1); font-size: 15px; transition: 0.2s; }
        .sidebar a:hover { background: #145c9e; color: #fff; padding-left: 25px; }
        
        /* Khu vực hiển thị chính bên phải */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .header { background: #fff; padding: 15px 25px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: flex; justify-content: flex-end; align-items: center; }
        .content { padding: 25px; overflow-y: auto; flex: 1; }

        /* CSS Nút bấm chuẩn phong cách MediLab */
        .btn-medilab {
            background-color: #1977cc;
            color: #ffffff;
            padding: 10px 22px;
            font-size: 14px;
            font-weight: 600;
            border: none;
            border-radius: 50px; /* Bo tròn dạng viên thuốc */
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(25, 119, 204, 0.3);
        }
        .btn-medilab:hover {
            background-color: #166ab5;
            box-shadow: 0 6px 15px rgba(25, 119, 204, 0.4);
            transform: translateY(-1px);
            color: #ffffff;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>MediLab Admin</h2>
        <a href="user.php">Quản lý User</a>
        <a href="#">Quản lý Dịch vụ</a> 
    </div>

    <!-- Khu vực bên phải -->
    <div class="main-content">
        <!-- Header -->
        <div class="header">
            <span>Xin chào, Admin | <a href="logout.php" style="color: #dc3545; text-decoration: none; font-weight: bold;">Đăng xuất</a></span>
        </div>
        
        <!-- Mở thẻ content để chèn nội dung từng trang -->
        <div class="content">