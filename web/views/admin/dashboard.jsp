<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan phòng khám - VisionCare Admin</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin-dashboard.css" rel="stylesheet">

    <style>
      .admin-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        padding: 24px;
        height: 100%;
      }
      .stat-icon {
        width: 50px;
        height: 50px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
      }
      .bg-light-primary { background: #e0f2fe; color: #0284c7; }
      .bg-light-success { background: #dcfce7; color: #16a34a; }
      .bg-light-warning { background: #fef08a; color: #ca8a04; }
      .page-content { padding: 30px; }
      .page-title { margin-bottom: 24px; }
      .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
      .breadcrumbs { font-size: 14px; color: #64748b; }
      .breadcrumbs ol { list-style: none; padding: 0; margin: 0; display: flex; gap: 8px; }
      .breadcrumbs ol li.current { color: #0f172a; font-weight: 500; }
      .breadcrumbs ol li a { color: var(--primary-color); text-decoration: none; }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="dashboard" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="dashboard-page">
            <div class="dashboard-heading">
                <div>
                    <span class="dashboard-eyebrow">VISIONCARE / QUẢN TRỊ</span>
                    <h1>Tổng quan phòng khám</h1>
                    <p>Theo dõi hoạt động khám bệnh và doanh thu tại một nơi.</p>
                </div>
                <a class="dashboard-heading-link" href="${pageContext.request.contextPath}/admin/billing"><i class="bi bi-receipt"></i> Xem hóa đơn <i class="bi bi-arrow-up-right"></i></a>
            </div>

            <div class="dashboard-section-heading"><div><span class="dashboard-section-index">01</span><h2>Chỉ số chính</h2></div><span class="dashboard-section-note">Doanh thu theo dữ liệu thanh toán hiện có</span></div>
            <div class="dashboard-kpis">
                <article class="dashboard-card dashboard-kpi">
                    <div class="dashboard-kpi-top"><span class="dashboard-icon mint"><i class="bi bi-wallet2"></i></span><span class="dashboard-kpi-period">Tháng này</span></div>
                    <p class="dashboard-kpi-label">Doanh thu</p>
                    <strong class="dashboard-kpi-value"><c:out value="${stats.monthRevenueFmt}" default="—" /></strong>
                    <span class="dashboard-kpi-caption">Từ các khoản đã ghi nhận</span>
                </article>
                <article class="dashboard-card dashboard-kpi">
                    <div class="dashboard-kpi-top"><span class="dashboard-icon blue"><i class="bi bi-cash-coin"></i></span><span class="dashboard-kpi-period">Hôm nay</span></div>
                    <p class="dashboard-kpi-label">Doanh thu</p>
                    <strong class="dashboard-kpi-value"><c:out value="${stats.todayRevenueFmt}" default="—" /></strong>
                    <span class="dashboard-kpi-caption">Theo ngày ghi nhận thanh toán</span>
                </article>
                <article class="dashboard-card dashboard-kpi">
                    <div class="dashboard-kpi-top"><span class="dashboard-icon violet"><i class="bi bi-check2-circle"></i></span><span class="dashboard-kpi-period">Hôm nay</span></div>
                    <p class="dashboard-kpi-label">Hóa đơn đã thanh toán</p>
                    <strong class="dashboard-kpi-value"><c:out value="${stats.todayPaidCount}" default="—" /></strong>
                    <span class="dashboard-kpi-caption">Số hóa đơn, không phải số bệnh nhân</span>
                </article>
                <article class="dashboard-card dashboard-kpi">
                    <div class="dashboard-kpi-top"><span class="dashboard-icon amber"><i class="bi bi-person-check"></i></span><span class="dashboard-kpi-period">Lịch hẹn</span></div>
                    <p class="dashboard-kpi-label">Tỷ lệ bệnh nhân đến khám</p>
                    <c:choose><c:when test="${not empty attendanceRate}"><strong class="dashboard-kpi-value"><c:out value="${attendanceRate}" />%</strong></c:when><c:otherwise><strong class="dashboard-kpi-value dashboard-kpi-pending">Chưa có dữ liệu</strong></c:otherwise></c:choose>
                    <span class="dashboard-kpi-caption">Số bệnh nhân đã đến / số lịch hẹn</span>
                </article>
            </div>

            <div class="dashboard-section-heading dashboard-second-section"><div><span class="dashboard-section-index">02</span><h2>Hoạt động chi tiết</h2></div></div>
            <div class="dashboard-details">
                <section class="dashboard-card dashboard-panel">
                    <div class="dashboard-panel-heading"><div><span class="dashboard-panel-kicker">TÀI CHÍNH</span><h3>Tổng quan doanh thu</h3></div><span class="dashboard-icon mint"><i class="bi bi-graph-up-arrow"></i></span></div>
                    <div class="dashboard-revenue-grid">
                        <div><span>Hôm nay</span><strong><c:out value="${stats.todayRevenueFmt}" default="—" /></strong></div>
                        <div><span>Tháng này</span><strong><c:out value="${stats.monthRevenueFmt}" default="—" /></strong></div>
                        <div><span>Toàn thời gian</span><strong><c:out value="${stats.allTimeRevenueFmt}" default="—" /></strong></div>
                    </div>
                    <a class="dashboard-text-link" href="${pageContext.request.contextPath}/admin/billing">Xem chi tiết hóa đơn <i class="bi bi-arrow-right"></i></a>
                </section>
                <section class="dashboard-card dashboard-panel">
                    <div class="dashboard-panel-heading"><div><span class="dashboard-panel-kicker">THANH TOÁN</span><h3>Trạng thái hóa đơn</h3></div><span class="dashboard-icon blue"><i class="bi bi-receipt"></i></span></div>
                    <div class="dashboard-status-row"><span><i class="dashboard-dot paid"></i>Đã thanh toán</span><strong><c:out value="${stats.allTimePaidCount}" default="—" /></strong></div>
                    <div class="dashboard-status-row"><span><i class="dashboard-dot unpaid"></i>Chưa thanh toán</span><strong><c:out value="${stats.allTimeUnpaidCount}" default="—" /></strong></div>
                    <div class="dashboard-status-row"><span><i class="dashboard-dot refunded"></i>Đã hoàn tiền</span><strong><c:out value="${stats.allTimeRefundedCount}" default="—" /></strong></div>
                    <p class="dashboard-panel-footnote">Số liệu tính trên toàn thời gian.</p>
                </section>
                <section class="dashboard-card dashboard-panel">
                    <div class="dashboard-panel-heading"><div><span class="dashboard-panel-kicker">LỊCH KHÁM</span><h3>Bệnh nhân đến khám</h3></div><span class="dashboard-icon amber"><i class="bi bi-calendar2-check"></i></span></div>
                    <p class="dashboard-attendance-copy">Tỷ lệ đến khám = số lịch hẹn có bệnh nhân đã đến / tổng số lịch hẹn trong cùng kỳ.</p>
                    <c:if test="${empty attendanceRate}"><div class="dashboard-attendance-state"><i class="bi bi-info-circle"></i><span>Dashboard chưa nhận số liệu lịch hẹn để hiển thị tỷ lệ này.</span></div></c:if>
                    <a class="dashboard-text-link" href="${pageContext.request.contextPath}/staff/appointments">Xem danh sách lịch hẹn <i class="bi bi-arrow-right"></i></a>
                </section>
            </div>
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
