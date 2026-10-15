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
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    
    <!-- Catalog specific CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css?v=5" rel="stylesheet">

</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="catalog" />
        <jsp:param name="activeSub" value="${param.tab == 'supplies' ? 'supplies' : 'services'}" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content catalog-page">
  <div class="page-header"><div class="page-title"><h2>Quản lý Danh mục</h2><p>Quản lý dịch vụ phòng khám, vật tư và dược phẩm y tế</p></div></div>
  <div class="catalog-layout">
    <aside class="catalog-sidebar" aria-label="Phân mục quản trị">
      <div class="catalog-panel catalog-nav-panel" role="tablist" aria-label="Loại danh mục">
        <p class="catalog-eyebrow">Loại danh mục</p>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? '' : 'is-active'}" id="servicesTab" data-tab="services" role="tab" aria-controls="servicesView" aria-selected="${param.tab == 'supplies' ? 'false' : 'true'}" tabindex="${param.tab == 'supplies' ? '-1' : '0'}"><span><i class="bi bi-clipboard2-pulse"></i> Dịch vụ phòng khám</span></button>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? 'is-active' : ''}" id="suppliesTab" data-tab="supplies" role="tab" aria-controls="suppliesView" aria-selected="${param.tab == 'supplies' ? 'true' : 'false'}" tabindex="${param.tab == 'supplies' ? '0' : '-1'}"><span><i class="bi bi-box-seam"></i> Vật tư &amp; Thiết bị</span></button>
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
      <section class="catalog-view" id="servicesView" role="tabpanel" aria-labelledby="servicesTab" ${param.tab == 'supplies' ? 'hidden' : ''}>
        <div class="catalog-panel catalog-heading"><h5><i class="bi bi-clipboard2-pulse me-2 text-primary"></i>Danh sách Dịch vụ Phòng khám</h5><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/service?new=1"><i class="bi bi-plus-lg"></i> Thêm dịch vụ</a></div>
        <div class="catalog-panel catalog-filters"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="serviceSearch" placeholder="Tìm tên hoặc mã dịch vụ..." aria-label="Tìm dịch vụ"></label></div>
        <div class="table-responsive" id="serviceList"><table class="table align-middle table-custom catalog-table"><thead><tr><th>Mã dịch vụ</th><th>Tên dịch vụ</th><th>Nhóm dịch vụ</th><th>Đơn giá</th><th class="text-end">Thao tác</th></tr></thead><tbody>
          <c:forEach items="${catalogServices}" var="service">
            <tr class="catalog-service">
              <td><c:out value="${empty service.code ? service.id : service.code}" /></td>
              <td><strong><c:out value="${service.name}" /></strong></td>
              <td><c:out value="${service.categoryName}" /></td>
              <td><fmt:formatNumber value="${service.price}" pattern="#,##0" /> VNĐ</td>
              <td><div class="catalog-supply-actions"><a class="catalog-supply-edit" href="${pageContext.request.contextPath}/admin/catalog/service?id=${service.id}" aria-label="Sửa dịch vụ ${fn:escapeXml(service.name)}" title="Sửa dịch vụ"><i class="bi bi-pencil" aria-hidden="true"></i></a><form class="catalog-delete-form" method="post" action="${pageContext.request.contextPath}/admin/catalog/service" data-kind="dịch vụ" data-name="${fn:escapeXml(service.name)}"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${service.id}"><input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}"><button class="catalog-delete" type="button" aria-label="Xóa dịch vụ ${fn:escapeXml(service.name)}" title="Xóa dịch vụ"><i class="bi bi-trash" aria-hidden="true"></i></button></form></div></td>
            </tr>
          </c:forEach>
        </tbody></table></div><p class="catalog-empty" id="serviceEmpty" hidden>Không tìm thấy dịch vụ phù hợp.</p>
      </section>

      <section class="catalog-view" id="suppliesView" role="tabpanel" aria-labelledby="suppliesTab" ${param.tab == 'supplies' ? '' : 'hidden'}>
        <div class="catalog-panel catalog-heading"><h5><i class="bi bi-box-seam me-2 text-primary"></i>Danh sách Vật tư &amp; Thiết bị</h5><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/supply?new=1"><i class="bi bi-plus-lg"></i> Thêm vật tư</a></div>
        <div class="catalog-panel catalog-supply-panel"><div class="catalog-supply-toolbar"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="supplySearch" placeholder="Tìm tên vật tư" aria-label="Tìm vật tư"></label></div><div class="table-responsive catalog-table-wrap"><table class="table align-middle table-custom catalog-table"><thead><tr><th>Tên vật tư / Dược phẩm</th><th>Phân loại</th><th>Đơn giá</th><th class="text-end">Thao tác</th></tr></thead><tbody>
          <c:forEach items="${catalogSupplies}" var="supply"><tr><td><strong><c:out value="${supply.name}" /></strong></td><td><c:out value="${supply.category}" /></td><td><fmt:formatNumber value="${supply.price}" pattern="#,##0" /> VNĐ</td><td><div class="catalog-supply-actions"><a class="catalog-supply-edit" href="${pageContext.request.contextPath}/admin/catalog/supply?id=${supply.id}" aria-label="Sửa vật tư ${fn:escapeXml(supply.name)}" title="Sửa vật tư"><i class="bi bi-pencil" aria-hidden="true"></i></a><form class="catalog-delete-form" method="post" action="${pageContext.request.contextPath}/admin/catalog/supply" data-kind="vật tư" data-name="${fn:escapeXml(supply.name)}"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${supply.id}"><input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}"><button class="catalog-delete" type="button" aria-label="Xóa vật tư ${fn:escapeXml(supply.name)}" title="Xóa vật tư"><i class="bi bi-trash" aria-hidden="true"></i></button></form></div></td></tr></c:forEach>
        </tbody></table></div><p class="catalog-empty" id="supplyEmpty" hidden>Không tìm thấy vật tư phù hợp.</p></div>
      </section>
    </div>
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
<script src="${pageContext.request.contextPath}/assets/js/admin-catalog.js?v=6" defer></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
