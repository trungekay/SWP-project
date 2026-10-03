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
    </aside>

    <div class="catalog-content">
      <c:choose>
        <c:when test="${param.created == '1'}"><c:set var="catalogSuccessMessage" value="Đã tạo thành công" /></c:when>
        <c:when test="${param.updated == '1'}"><c:set var="catalogSuccessMessage" value="Đã sửa thành công" /></c:when>
        <c:when test="${param.deleted == '1'}"><c:set var="catalogSuccessMessage" value="Đã xóa thành công" /></c:when>
      </c:choose>
      <c:if test="${not empty catalogSuccessMessage}"><div id="catalogSuccessToast" class="catalog-success-toast" role="status" aria-live="polite"><i class="bi bi-check-circle-fill" aria-hidden="true"></i><span><c:out value="${catalogSuccessMessage}" /></span></div></c:if>
      <c:if test="${param.deleteError == '1'}"><div class="catalog-delete-error" role="alert">Không thể xóa mục này. Mục có thể đang được sử dụng; hãy kiểm tra dữ liệu liên quan.</div></c:if>
      <section class="catalog-view" id="servicesView" aria-label="Danh sách dịch vụ" ${param.tab == 'supplies' ? 'hidden' : ''}>
        <div class="catalog-panel catalog-heading"><div><div class="catalog-heading-line"><h1>Danh sách Dịch vụ Phòng khám</h1><span class="catalog-count">${catalogServices.size()} dịch vụ</span></div><p>Quản lý danh mục khám bệnh, phẫu thuật, quy trình đo khám &amp; chi phí dịch vụ</p></div><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/service"><i class="bi bi-pencil-square"></i> Cập nhật dịch vụ</a></div>
        <div class="catalog-panel catalog-filters"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="serviceSearch" placeholder="Tìm tên dịch vụ, chuyên khoa..." aria-label="Tìm dịch vụ"></label><select id="specialtySelect" aria-label="Lọc chuyên khoa"><option value="all">Tất cả chuyên khoa</option><option value="general">Nhãn khoa tổng quát</option><option value="refraction">Khúc xạ &amp; Kính</option><option value="lasik">Phẫu thuật LASIK</option><option value="children">Nhãn khoa trẻ em</option><option value="retina">Glaucoma &amp; Võng mạc</option><option value="cataract">Đục thủy tinh thể</option></select></div>
        <div class="catalog-service-list" id="serviceList">
          <c:forEach items="${catalogServices}" var="service">
            <article class="catalog-service" data-specialty="${fn:escapeXml(service.specialty)}">
              <div class="catalog-service-body"><div class="catalog-service-main"><div class="catalog-meta"><span class="catalog-tag"><c:out value="${empty service.tag ? 'Dịch vụ' : service.tag}" /></span><span>Mã: <c:out value="${empty service.code ? service.id : service.code}" /></span></div><h2 class="catalog-service-name"><c:out value="${service.name}" /></h2><c:if test="${not empty service.summary}"><p class="catalog-summary"><c:out value="${service.summary}" /></p></c:if><c:if test="${not empty service.description}"><p class="catalog-description"><c:out value="${service.description}" /></p></c:if></div><div class="catalog-service-actions"><strong class="catalog-price"><i class="bi bi-tag-fill"></i> <fmt:formatNumber value="${service.price}" pattern="#,##0" /> VNĐ</strong><div><a class="catalog-edit" href="${pageContext.request.contextPath}/admin/catalog/service?id=${service.id}"><i class="bi bi-pencil"></i> Sửa</a><form class="catalog-delete-form" method="post" action="${pageContext.request.contextPath}/admin/catalog/service" data-kind="dịch vụ" data-name="${fn:escapeXml(service.name)}"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${service.id}"><input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}"><button class="catalog-delete" type="button"><i class="bi bi-trash"></i> Xóa</button></form></div></div></div>
              <div class="catalog-service-image"><c:choose><c:when test="${service.uploadedImage}"><img src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}" alt="Hình minh họa dịch vụ"></c:when><c:otherwise><img src="${pageContext.request.contextPath}/assets/img/${empty service.image ? 'departments-1.jpg' : fn:escapeXml(service.image)}" alt="Hình minh họa dịch vụ"></c:otherwise></c:choose></div>
            </article>
          </c:forEach>
        </div><p class="catalog-empty" id="serviceEmpty" hidden>Không tìm thấy dịch vụ phù hợp.</p>
      </section>

      <section class="catalog-view" id="suppliesView" aria-label="Danh sách vật tư" ${param.tab == 'supplies' ? '' : 'hidden'}>
        <div class="catalog-panel catalog-heading"><div><h1>Danh mục Vật tư &amp; Dược phẩm Y tế</h1><p>Quản lý thuốc nhỏ mắt, vật tư tiêu hao, tròng kính và kính áp tròng</p></div><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/supply"><i class="bi bi-pencil-square"></i> Cập nhật vật tư</a></div>
        <div class="catalog-panel catalog-supply-panel"><div class="catalog-supply-toolbar"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="supplySearch" placeholder="Tìm tên vật tư, dược phẩm..." aria-label="Tìm vật tư"></label><span>${catalogSupplies.size()} mặt hàng</span></div><div class="catalog-table-wrap"><table class="catalog-table"><thead><tr><th>Ảnh</th><th>Tên vật tư / Dược phẩm</th><th>Phân loại</th><th>Tồn kho</th><th>Đơn giá</th><th>Trạng thái</th><th>Hành động</th></tr></thead><tbody>
          <c:forEach items="${catalogSupplies}" var="supply"><tr><td><c:if test="${supply.uploadedImage}"><img class="catalog-supply-thumb" src="${pageContext.request.contextPath}/catalog-image?kind=supply&amp;id=${supply.id}" alt="Ảnh vật tư"></c:if></td><td><strong><c:out value="${supply.name}" /></strong><small>Lô: <c:out value="${supply.batch}" /></small></td><td><c:out value="${supply.category}" /></td><td>${supply.quantity} <c:out value="${supply.unit}" /></td><td><fmt:formatNumber value="${supply.price}" pattern="#,##0" /> VNĐ</td><td><span class="catalog-stock ${supply.quantity < 10 ? 'is-low' : ''}">${supply.quantity < 10 ? 'Sắp hết hàng' : 'Còn hàng'}</span></td><td><div class="catalog-supply-actions"><a class="catalog-supply-edit" href="${pageContext.request.contextPath}/admin/catalog/supply?id=${supply.id}"><i class="bi bi-pencil"></i> Cập nhật</a><form class="catalog-delete-form" method="post" action="${pageContext.request.contextPath}/admin/catalog/supply" data-kind="vật tư" data-name="${fn:escapeXml(supply.name)}"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${supply.id}"><input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}"><button class="catalog-delete" type="button"><i class="bi bi-trash"></i> Xóa</button></form></div></td></tr></c:forEach>
        </tbody></table></div><p class="catalog-empty" id="supplyEmpty" hidden>Không tìm thấy vật tư phù hợp.</p></div>
      </section>
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
