<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tổng quan phòng khám - VisionCare</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/css/admin-dashboard.css?v=20261031-7" rel="stylesheet">
</head>
<body>
<jsp:include page="/views/admin/layout/admin-sidebar.jsp"><jsp:param name="activeNav" value="dashboard" /></jsp:include>
<main class="main-wrapper">
  <jsp:include page="/views/admin/layout/admin-header.jsp" />
  <div class="dashboard-page">
<div class="dashboard-top"><div><h1>Tổng quan phòng khám</h1><p>Theo dõi doanh thu, lịch hẹn và tỷ lệ bệnh nhân đến khám.</p></div></div>
    <nav class="clinic-report-nav" aria-label="Báo cáo phòng khám">
      <a href="${pageContext.request.contextPath}/admin/dashboard" class="active"><i class="bi bi-wallet2"></i> Quản lý doanh thu</a>
      <a href="${pageContext.request.contextPath}/admin/conversion-report" class=""><i class="bi bi-graph-up-arrow"></i> Báo cáo tỷ lệ đến khám</a>
    </nav>
    <div class="dashboard-top">
      <div><h1>Tổng quan doanh thu</h1><p>Doanh thu và giao dịch của phòng khám theo dữ liệu đã ghi nhận.</p></div>
      <a class="dashboard-action" href="${pageContext.request.contextPath}/admin/billing"><i class="bi bi-receipt"></i> Xem hóa đơn</a>
    </div>
    <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" class="dashboard-filter">
      <div class="dashboard-tabs">
        <button name="period" value="today" class="${period=='today'?'active':''}">Hôm nay</button>
        <button name="period" value="month" class="${period=='month'?'active':''}">Tháng nay</button>
        <button name="period" value="year" class="${period=='year'?'active':''}">Năm nay</button>
      </div>
      <span class="dashboard-date-field"><input type="text" id="dashboardFrom" name="from" value="${fromDisplay}" pattern="[0-9]{2}/[0-9]{2}/[0-9]{4}" aria-label="Từ ngày dd/MM/yyyy"><button type="button" class="dashboard-calendar-button" data-picker="dashboardFromPicker" aria-label="Chọn ngày bắt đầu"><i class="bi bi-calendar3"></i></button><input type="date" id="dashboardFromPicker" class="dashboard-native-picker" value="${from}" tabindex="-1" aria-hidden="true"></span>
      <span>đến</span>
      <span class="dashboard-date-field"><input type="text" id="dashboardTo" name="to" value="${toDisplay}" pattern="[0-9]{2}/[0-9]{2}/[0-9]{4}" aria-label="Đến ngày dd/MM/yyyy"><button type="button" class="dashboard-calendar-button" data-picker="dashboardToPicker" aria-label="Chọn ngày kết thúc"><i class="bi bi-calendar3"></i></button><input type="date" id="dashboardToPicker" class="dashboard-native-picker" value="${to}" tabindex="-1" aria-hidden="true"></span>
      <button name="period" value="custom" class="dashboard-apply">Áp dụng</button>
    </form>

    <section class="dashboard-kpis" aria-label="Chỉ số doanh thu">
      <article class="dashboard-card dashboard-kpi">
        <div class="dashboard-kpi-head"><span>Tổng doanh thu thực nhận</span><i class="bi bi-wallet2"></i></div>
        <p>Thanh toán thành công trừ hoàn tiền</p><strong><c:out value="${totalFmt}"/></strong>
        <small>Trong kỳ đã chọn</small>
      </article>
      <article class="dashboard-card dashboard-kpi">
        <div class="dashboard-kpi-head"><span>Doanh thu khám</span><i class="bi bi-clipboard2-pulse"></i></div>
        <p>Khám và các khoản ngoài phẫu thuật</p><strong><c:out value="${examFmt}"/></strong>
        <small>Giao dịch không gắn yêu cầu phẫu thuật</small>
      </article>
      <article class="dashboard-card dashboard-kpi">
        <div class="dashboard-kpi-head"><span>Doanh thu phẫu thuật</span><i class="bi bi-hospital"></i></div>
        <p>Giao dịch gắn yêu cầu thanh toán thủ thuật</p><strong><c:out value="${surgeryFmt}"/></strong>
        <small>Đã thu qua giao dịch thành công</small>
      </article>
    </section>

    <div class="dashboard-middle">
      <section class="dashboard-card dashboard-chart-panel">
        <div class="dashboard-panel-title"><div><h2><c:out value="${chartTitle}"/></h2><p><c:out value="${chartDescription}"/> · các khoản đã thu, trước hoàn tiền</p></div><i class="bi bi-bar-chart"></i></div>
        <div class="dashboard-chart-legend"><span><i class="dashboard-legend-dot surgery"></i>Doanh thu tiểu phẫu</span><span><i class="dashboard-legend-dot exam"></i>Doanh thu khám</span></div>
        <div class="dashboard-chart-scroll"><div class="dashboard-chart" style="grid-template-columns:repeat(${chartCount},minmax(65px,1fr));min-width:${chartCount * 74}px" role="img" aria-label="Doanh thu khám và tiểu phẫu trong kỳ">
          <c:forEach items="${chartBars}" var="bar">
            <div class="dashboard-bar-group"><span class="dashboard-bar-value"><c:out value="${bar.value}"/></span><div class="dashboard-bar-track"><div class="dashboard-bar" style="height:${bar.height}%" title="Tiểu phẫu: ${bar.surgeryValue}; Khám: ${bar.examValue}"><div class="dashboard-bar-surgery" style="height:${bar.surgeryShare}%"></div><div class="dashboard-bar-exam"></div></div></div><span class="dashboard-bar-label"><c:out value="${bar.label}"/></span></div>
          </c:forEach>
        </div></div>
      </section>
      <section class="dashboard-card dashboard-source-panel">
        <div class="dashboard-panel-title"><div><h2>Cơ cấu nguồn thu</h2><p>Trong kỳ đã chọn</p></div><i class="bi bi-pie-chart"></i></div>
        <div class="dashboard-source"><span>Doanh thu khám và dịch vụ khác</span><strong><c:out value="${examFmt}"/></strong></div>
        <div class="dashboard-source"><span>Doanh thu phẫu thuật</span><strong><c:out value="${surgeryFmt}"/></strong></div>
        <div class="dashboard-source dashboard-refund"><span>Đã hoàn tiền</span><strong>−<c:out value="${refundFmt}"/></strong></div>
        <div class="dashboard-source dashboard-source-total"><span>Thực nhận</span><strong><c:out value="${totalFmt}"/></strong></div>
      </section>
    </div>

    <section class="dashboard-card dashboard-journal">
      <div class="dashboard-journal-head">
        <div><h2>Sổ nhật ký thu viện phí &amp; giao dịch</h2><p>Khoản đã thanh toán và đã hoàn tiền trong kỳ, mới nhất trước.</p></div>
        <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" class="dashboard-journal-filter">
          <input type="hidden" name="period" value="${period}"><input type="hidden" name="from" value="${fromDisplay}"><input type="hidden" name="to" value="${toDisplay}">
          <input type="search" name="search" value="${fn:escapeXml(search)}" placeholder="Tên bệnh nhân, SĐT, mã hóa đơn" aria-label="Tìm giao dịch">
          <select name="status" aria-label="Trạng thái"><option value="all">Tất cả trạng thái</option><option value="Paid" ${status=='Paid'?'selected':''}>Đã thanh toán</option><option value="Refunded" ${status=='Refunded'?'selected':''}>Đã hoàn tiền</option></select>
          <button type="submit">Lọc</button>
        </form>
      </div>
      <div class="dashboard-table-wrap"><table class="dashboard-table">
        <thead><tr><th>Mã giao dịch</th><th>Bệnh nhân</th><th>Dịch vụ</th><th>Bác sĩ</th><th>Số tiền</th><th>Phương thức</th><th>Trạng thái</th><th>Thời gian</th></tr></thead>
        <tbody>
        <c:forEach items="${journal}" var="row"><tr>
          <td class="dashboard-code"><c:out value="${row.Event_Status=='Refunded'?'HT':'TT'}"/> #<c:out value="${row.Event_ID}"/><small>HĐ #<c:out value="${row.Invoice_ID}"/></small></td>
          <td><strong><c:out value="${row.Patient_Name}"/></strong><small><c:out value="${row.Phone}"/></small></td>
          <td><c:out value="${row.Event_Status=='Refunded'?'Hoàn tiền':empty row.Service_Name?'Khám / dịch vụ khác':row.Service_Name}"/></td>
          <td><c:out value="${empty row.Doctor_Name?'—':row.Doctor_Name}"/></td>
          <td class="dashboard-amount ${row.Event_Status=='Refunded'?'refunded':''}"><fmt:formatNumber value="${row.Amount}" groupingUsed="true"/> đ</td>
          <td><c:out value="${row.Payment_Gateway}"/></td>
          <td><span class="dashboard-badge ${row.Event_Status=='Paid'?'success':'refunded'}"><c:out value="${row.Event_Status=='Paid'?'Đã thanh toán':'Đã hoàn tiền'}"/></span></td>
          <td><fmt:formatDate value="${row.Event_Time}" pattern="dd/MM/yyyy HH:mm"/></td>
        </tr></c:forEach>
        <c:if test="${empty journal}"><tr><td colspan="8" class="dashboard-empty">Không tìm thấy giao dịch phù hợp.</td></tr></c:if>
        </tbody>
      </table></div>
      <div class="dashboard-pagination">
        <span>Trang <c:out value="${pageNumber}"/></span>
        <form method="get"><input type="hidden" name="period" value="${period}"><input type="hidden" name="from" value="${fromDisplay}"><input type="hidden" name="to" value="${toDisplay}"><input type="hidden" name="search" value="${fn:escapeXml(search)}"><input type="hidden" name="status" value="${status}"><button name="page" value="${previousPage}" ${pageNumber==1?'disabled':''}>Trước</button><button name="page" value="${nextPage}" ${hasNextPage?'disabled':''}>Sau</button></form>
      </div>
    </section>
  </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  document.querySelectorAll('.dashboard-calendar-button').forEach(button => {
    const picker = document.getElementById(button.dataset.picker);
    const display = picker.parentElement.querySelector('input[type="text"]');
    button.addEventListener('click', () => {
      const parts = display.value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      if (parts) picker.value = parts[3] + '-' + parts[2] + '-' + parts[1];
      if (picker.showPicker) picker.showPicker();
      else { picker.focus(); picker.click(); }
    });
    picker.addEventListener('change', () => {
      if (!picker.value) return;
      const parts = picker.value.split('-');
      display.value = parts[2] + '/' + parts[1] + '/' + parts[0];
    });
  });
</script>
</body>
</html>
