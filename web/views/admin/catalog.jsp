<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý Dịch vụ và Vật tư" />
  <jsp:param name="pageDescription" value="Danh mục dịch vụ và vật tư VisionCare" />
  <jsp:param name="bodyClass" value="admin-catalog-page" />
</jsp:include>

<main class="main catalog-page">
  <div class="catalog-breadcrumb"><div class="container"><a href="${pageContext.request.contextPath}/home"><i class="bi bi-house-door"></i> Trang chủ</a><span>/</span><span>Quản lý</span><span>/</span><strong>Dịch vụ &amp; Vật tư y tế</strong></div></div>
  <div class="container catalog-layout">
    <aside class="catalog-sidebar" aria-label="Phân mục quản trị">
      <div class="catalog-panel catalog-nav-panel">
        <p class="catalog-eyebrow">Phân mục quản trị</p>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? '' : 'is-active'}" data-tab="services" aria-selected="${param.tab == 'supplies' ? 'false' : 'true'}"><span><i class="bi bi-clipboard2-pulse"></i> Dịch vụ phòng khám</span><b>${catalogServices.size()}</b></button>
        <button type="button" class="catalog-tab ${param.tab == 'supplies' ? 'is-active' : ''}" data-tab="supplies" aria-selected="${param.tab == 'supplies' ? 'true' : 'false'}"><span><i class="bi bi-box-seam"></i> Vật tư &amp; Thiết bị</span><b>${catalogSupplies.size()}</b></button>
      </div>
    </aside>

    <div class="catalog-content">
      <c:if test="${param.saved == '1'}"><div class="catalog-success" role="status">Đã lưu thay đổi vào database.</div></c:if>
      <section class="catalog-view" id="servicesView" aria-label="Danh sách dịch vụ" ${param.tab == 'supplies' ? 'hidden' : ''}>
        <div class="catalog-panel catalog-heading"><div><div class="catalog-heading-line"><h1>Danh sách Dịch vụ Phòng khám</h1><span class="catalog-count">${catalogServices.size()} dịch vụ</span></div><p>Quản lý danh mục khám bệnh, phẫu thuật, quy trình đo khám &amp; chi phí dịch vụ</p></div><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/service"><i class="bi bi-pencil-square"></i> Cập nhật dịch vụ</a></div>
        <div class="catalog-panel catalog-filters"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="serviceSearch" placeholder="Tìm tên dịch vụ, chuyên khoa..." aria-label="Tìm dịch vụ"></label><select id="specialtySelect" aria-label="Lọc chuyên khoa"><option value="all">Tất cả chuyên khoa</option><option value="general">Nhãn khoa tổng quát</option><option value="refraction">Khúc xạ &amp; Kính</option><option value="lasik">Phẫu thuật LASIK</option><option value="children">Nhãn khoa trẻ em</option><option value="retina">Glaucoma &amp; Võng mạc</option><option value="cataract">Đục thủy tinh thể</option></select></div>
        <div class="catalog-service-list" id="serviceList">
          <c:forEach items="${catalogServices}" var="service">
            <article class="catalog-service" data-specialty="${fn:escapeXml(service.specialty)}">
              <div class="catalog-service-body"><div class="catalog-service-main"><div class="catalog-meta"><span class="catalog-tag"><c:out value="${empty service.tag ? 'Dịch vụ' : service.tag}" /></span><span>Mã: <c:out value="${empty service.code ? service.id : service.code}" /></span></div><h2 class="catalog-service-name"><c:out value="${service.name}" /></h2><c:if test="${not empty service.summary}"><p class="catalog-summary"><c:out value="${service.summary}" /></p></c:if><c:if test="${not empty service.description}"><p class="catalog-description"><c:out value="${service.description}" /></p></c:if></div><div class="catalog-service-actions"><strong class="catalog-price"><i class="bi bi-tag-fill"></i> <fmt:formatNumber value="${service.price}" pattern="#,##0" /> VNĐ</strong><div><a class="catalog-edit" href="${pageContext.request.contextPath}/admin/catalog/service?id=${service.id}"><i class="bi bi-pencil"></i> Sửa</a><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/catalog/service?id=${service.id}">Chi tiết</a></div></div></div>
              <div class="catalog-service-image"><c:choose><c:when test="${service.uploadedImage}"><img src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${service.id}" alt="Hình minh họa dịch vụ"></c:when><c:otherwise><img src="${pageContext.request.contextPath}/assets/img/${empty service.image ? 'departments-1.jpg' : fn:escapeXml(service.image)}" alt="Hình minh họa dịch vụ"></c:otherwise></c:choose></div>
            </article>
          </c:forEach>
        </div><p class="catalog-empty" id="serviceEmpty" hidden>Không tìm thấy dịch vụ phù hợp.</p>
      </section>

      <section class="catalog-view" id="suppliesView" aria-label="Danh sách vật tư" ${param.tab == 'supplies' ? '' : 'hidden'}>
        <div class="catalog-panel catalog-heading"><div><h1>Danh mục Vật tư &amp; Dược phẩm Y tế</h1><p>Quản lý thuốc nhỏ mắt, vật tư tiêu hao, tròng kính và kính áp tròng</p></div><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog/supply"><i class="bi bi-pencil-square"></i> Cập nhật vật tư</a></div>
        <div class="catalog-panel catalog-supply-panel"><div class="catalog-supply-toolbar"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="supplySearch" placeholder="Tìm tên vật tư, dược phẩm..." aria-label="Tìm vật tư"></label><span>${catalogSupplies.size()} mặt hàng</span></div><div class="catalog-table-wrap"><table class="catalog-table"><thead><tr><th>Ảnh</th><th>Tên vật tư / Dược phẩm</th><th>Phân loại</th><th>Tồn kho</th><th>Đơn giá</th><th>Trạng thái</th><th>Hành động</th></tr></thead><tbody>
          <c:forEach items="${catalogSupplies}" var="supply"><tr><td><c:if test="${supply.uploadedImage}"><img class="catalog-supply-thumb" src="${pageContext.request.contextPath}/catalog-image?kind=supply&amp;id=${supply.id}" alt="Ảnh vật tư"></c:if></td><td><strong><c:out value="${supply.name}" /></strong><small>Lô: <c:out value="${supply.batch}" /></small></td><td><c:out value="${supply.category}" /></td><td>${supply.quantity} <c:out value="${supply.unit}" /></td><td><fmt:formatNumber value="${supply.price}" pattern="#,##0" /> VNĐ</td><td><span class="catalog-stock ${supply.quantity < 10 ? 'is-low' : ''}">${supply.quantity < 10 ? 'Sắp hết hàng' : 'Còn hàng'}</span></td><td><a class="catalog-supply-edit" href="${pageContext.request.contextPath}/admin/catalog/supply?id=${supply.id}"><i class="bi bi-pencil"></i> Cập nhật</a></td></tr></c:forEach>
        </tbody></table></div><p class="catalog-empty" id="supplyEmpty" hidden>Không tìm thấy vật tư phù hợp.</p></div>
      </section>
    </div>
  </div>
</main>
<script src="${pageContext.request.contextPath}/assets/js/admin-catalog.js" defer></script>
<jsp:include page="/views/common/footer.jsp" />
