<style>
    :root {
        --primary-color: #008b74;
        --primary-hover: #00705d;
        --bg-color: #f4f7f9;
        --sidebar-width: 250px;
        --text-main: #333333;
        --text-muted: #6c757d;
        --border-color: #e5e7eb;
    }
    
    body {
        font-family: 'Inter', sans-serif;
        background-color: var(--bg-color);
        color: var(--text-main);
        overflow-x: hidden;
    }

    /* --- Sidebar --- */
    .sidebar {
        width: var(--sidebar-width);
        height: 100vh;
        position: fixed;
        top: 0;
        left: 0;
        background-color: #ffffff;
        border-right: 1px solid var(--border-color);
        z-index: 1000;
    }
    .sidebar-brand {
        height: 70px; display: flex; align-items: center; padding: 0 24px;
        text-decoration: none;
    }
    .logo-mark {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #14b8a6, #0d9488);
        display: inline-flex; align-items: center; justify-content: center;
        color: #fff; font-size: 16px; margin-right: 10px; flex-shrink: 0;
    }
    .brand-text { color: #1e293b; font-weight: 700; font-size: 22px; }
    .sidebar-menu {
        padding: 15px;
        list-style: none;
        margin: 0;
    }
    .sidebar-menu li a {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        color: var(--text-muted);
        text-decoration: none;
        border-radius: 8px;
        font-weight: 500;
        transition: all 0.2s ease;
    }
    .sidebar-menu li a i {
        margin-right: 12px;
        font-size: 18px;
    }
    .sidebar-menu li a.active {
        background-color: #f0f7f6;
        color: var(--primary-color);
    }
    .sidebar-dropdown {
        position: relative;
    }
    .sidebar-submenu {
        display: none;
        list-style: none;
        padding: 5px 0 5px 35px;
        margin: 0;
        background-color: #fcfcfc;
        border-radius: 0 0 8px 8px;
    }
    .sidebar-submenu.show {
        display: block;
    }
    .sidebar-submenu li a {
        padding: 8px 16px;
        font-size: 13px;
        color: var(--text-muted);
        border-radius: 6px;
    }
    .sidebar-submenu li a:hover, .sidebar-submenu li a.active {
        color: var(--primary-color);
        background-color: #f0f7f6;
    }

    /* --- Main Content --- */
    .main-wrapper {
        margin-left: var(--sidebar-width);
        min-height: 100vh;
    }

    /* --- Top Header --- */
    .top-header {
        height: 70px;
        background-color: #f0f7f6;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 30px;
        border-bottom: 1px solid var(--border-color);
    }
    .search-bar {
        position: relative;
        width: 300px;
    }
    .search-bar input {
        width: 100%;
        padding: 8px 16px 8px 40px;
        border: 1px solid transparent;
        background-color: #f1f5f9;
        border-radius: 20px;
        font-size: 14px;
        outline: none;
        transition: all 0.2s;
    }
    .search-bar input:focus {
        background-color: #fff;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.1);
    }
    .search-bar i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94a3b8;
    }
    .header-right {
        display: flex;
        align-items: center;
        gap: 20px;
    }
    .btn-icon {
        background: none;
        border: none;
        color: var(--text-muted);
        font-size: 20px;
        cursor: pointer;
        position: relative;
    }
    .btn-icon .badge-dot {
        position: absolute;
        top: 0;
        right: 0;
        width: 8px;
        height: 8px;
        background-color: #ef4444;
        border-radius: 50%;
    }
    .user-profile {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
    }
    .avatar-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: var(--primary-color);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 16px;
    }
    .user-info .name {
        font-weight: 600;
        font-size: 14px;
        color: #1e293b;
        margin: 0;
        line-height: 1.2;
    }
    .user-info .role {
        font-size: 12px;
        color: var(--text-muted);
        margin: 0;
    }

    /* --- Page Content --- */
    .page-content {
        padding: 30px;
    }
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 24px;
    }
    .page-header .page-title {
        background: transparent !important;
        padding: 0 !important;
        margin: 0 !important;
    }
    .page-title h2 {
        font-size: 24px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 6px;
    }
    .page-title p {
        color: var(--text-muted);
        font-size: 14px;
        margin: 0;
    }
</style>
