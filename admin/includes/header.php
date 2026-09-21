<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; display: flex; height: 100vh; background-color: #f4f6f9; }
        .sidebar { width: 250px; background: #343a40; color: #fff; display: flex; flex-direction: column; }
        .sidebar h2 { text-align: center; padding: 15px 0; border-bottom: 1px solid #4f5962; margin: 0; }
        .sidebar a { color: #c2c7d0; padding: 15px; text-decoration: none; display: block; border-bottom: 1px solid #4f5962; }
        .sidebar a:hover { background: #4f5962; color: #fff; }
        .main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .header { background: #fff; padding: 15px 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: flex; justify-content: flex-end; }
        .content { padding: 20px; overflow-y: auto; flex: 1; }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Admin Panel</h2>
        <a href="user.php">Quản lý User</a>
        <a href="#">Quản lý Bài viết</a> 
    </div>

    <!-- Khu vực bên phải -->
    <div class="main-content">
        <!-- Header -->
        <div class="header">
            <span>Xin chào, Admin | <a href="logout.php" style="color: red; text-decoration: none;">Đăng xuất</a></span>
        </div>
        
        <!-- Mở thẻ content để chèn nội dung từng trang -->
        <div class="content">