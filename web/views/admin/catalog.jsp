<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
        <button type="button" class="catalog-tab is-active" data-tab="services" aria-selected="true"><span><i class="bi bi-clipboard2-pulse"></i> Dịch vụ phòng khám</span><b>6</b></button>
        <button type="button" class="catalog-tab" data-tab="supplies" aria-selected="false"><span><i class="bi bi-box-seam"></i> Vật tư &amp; Thiết bị</span><b>4</b></button>
      </div>
    
    </aside>

    <div class="catalog-content">
      <section class="catalog-view" id="servicesView" aria-label="Danh sách dịch vụ">
        <div class="catalog-panel catalog-heading"><div><div class="catalog-heading-line"><h1>Danh sách Dịch vụ Phòng khám</h1><span class="catalog-count"><i class="bi bi-circle-fill"></i> 6 Đang kích hoạt</span></div><p>Quản lý danh mục khám bệnh, phẫu thuật, quy trình đo khám &amp; chi phí dịch vụ</p></div><button type="button" class="catalog-primary" id="updateService"><i class="bi bi-pencil-square"></i> Cập nhật dịch vụ</button></div>
        <div class="catalog-panel catalog-filters"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="serviceSearch" placeholder="Tìm tên dịch vụ, chuyên khoa..." aria-label="Tìm dịch vụ"></label><div class="catalog-filter-selects"><select id="specialtySelect" aria-label="Lọc chuyên khoa"><option value="all">Tất cả chuyên khoa</option><option value="general">Nhãn khoa tổng quát</option><option value="refraction">Khúc xạ &amp; Kính</option><option value="lasik">Phẫu thuật LASIK</option><option value="children">Nhãn khoa trẻ em</option><option value="retina">Glaucoma &amp; Võng mạc</option><option value="cataract">Đục thủy tinh thể</option></select><select id="statusSelect" aria-label="Lọc trạng thái"><option value="all">Tất cả trạng thái</option><option value="ready">Sẵn sàng tiếp nhận</option><option value="scheduled">Hẹn lịch chuyên gia</option></select></div></div>
        <div class="catalog-service-list" id="serviceList">
          <c:forEach items="${catalogServices}" var="service">
            <article class="catalog-service" data-id="${service.id}" data-specialty="${service.specialty}" data-status="${service.status}" data-price="${service.price}">
              <div class="catalog-service-body"><div class="catalog-service-main"><div class="catalog-meta"><span class="catalog-tag catalog-tag-${service.specialty}"><c:out value="${service.tag}" /></span><span>Mã: <c:out value="${service.id}" /></span><span class="catalog-duration"><i class="bi bi-clock"></i> <c:out value="${service.duration}" /></span><span class="catalog-status ${service.status == 'scheduled' ? 'is-scheduled' : ''}"><i class="bi ${service.status == 'scheduled' ? 'bi-calendar-check-fill' : 'bi-check-circle-fill'}"></i> ${service.status == 'scheduled' ? 'Hẹn lịch chuyên gia' : 'Sẵn sàng tiếp nhận'}</span></div><h2 class="catalog-service-name"><c:out value="${service.name}" /></h2><p class="catalog-summary"><c:out value="${service.summary}" /></p><p class="catalog-description"><c:out value="${service.description}" /></p></div><div class="catalog-service-actions"><strong class="catalog-price"><i class="bi bi-tag-fill"></i> <span><c:out value="${service.priceLabel}" /></span></strong><div><button type="button" class="catalog-edit"><i class="bi bi-pencil"></i> Sửa</button><button type="button" class="catalog-detail">Chi tiết</button></div></div></div>
              <div class="catalog-service-image"><img src="${pageContext.request.contextPath}/assets/img/${service.image}" alt="Hình minh họa dịch vụ"></div>
            </article>
          </c:forEach>
        </div><p class="catalog-empty" id="serviceEmpty" hidden>Không tìm thấy dịch vụ phù hợp.</p>
      </section>

      <section class="catalog-view" id="suppliesView" aria-label="Danh sách vật tư" hidden>
        <div class="catalog-panel catalog-heading"><div><h1>Danh mục Vật tư &amp; Dược phẩm Y tế</h1><p>Quản lý thuốc nhỏ mắt, vật tư tiêu hao, tròng kính và kính áp tròng</p></div><button type="button" class="catalog-primary" id="updateSupply"><i class="bi bi-pencil-square"></i> Cập nhật vật tư</button></div>
        <div class="catalog-panel catalog-supply-panel"><div class="catalog-supply-toolbar"><label class="catalog-search"><i class="bi bi-search"></i><input type="search" id="supplySearch" placeholder="Tìm tên vật tư, dược phẩm..." aria-label="Tìm vật tư"></label><span>4 mặt hàng</span></div><div class="catalog-table-wrap"><table class="catalog-table"><thead><tr><th>Tên vật tư / Dược phẩm</th><th>Phân loại</th><th>Tồn kho</th><th>Đơn giá</th><th>Trạng thái</th><th>Hành động</th></tr></thead><tbody>
          <tr data-quantity="142" data-price="95000"><td><strong>Thuốc nhỏ mắt Systane Ultra (10ml)</strong><small>Lô: SYS-2026A</small></td><td>Dung dịch nhỏ mắt</td><td>142 lọ</td><td>95.000 VNĐ</td><td><span class="catalog-stock">Còn hàng</span></td><td><button type="button" class="catalog-supply-edit"><i class="bi bi-pencil"></i> Cập nhật</button></td></tr>
          <tr data-quantity="45" data-price="1250000"><td><strong>Tròng kính Essilor Crizal Alize 1.60</strong><small>Lô: ESL-8839</small></td><td>Tròng kính</td><td>45 cặp</td><td>1.250.000 VNĐ</td><td><span class="catalog-stock">Còn hàng</span></td><td><button type="button" class="catalog-supply-edit"><i class="bi bi-pencil"></i> Cập nhật</button></td></tr>
          <tr data-quantity="8" data-price="88000"><td><strong>Nước mắt nhân tạo Sanlein 0.1% (5ml)</strong><small>Lô: SNL-091</small></td><td>Dung dịch nhỏ mắt</td><td>8 lọ</td><td>88.000 VNĐ</td><td><span class="catalog-stock is-low">Sắp hết hàng</span></td><td><button type="button" class="catalog-supply-edit"><i class="bi bi-pencil"></i> Cập nhật</button></td></tr>
          <tr data-quantity="22" data-price="320000"><td><strong>Que thử màu huỳnh quang Fluorescein Strips</strong><small>Lô: FLS-002</small></td><td>Vật tư chẩn đoán</td><td>22 hộp</td><td>320.000 VNĐ</td><td><span class="catalog-stock">Còn hàng</span></td><td><button type="button" class="catalog-supply-edit"><i class="bi bi-pencil"></i> Cập nhật</button></td></tr>
        </tbody></table></div><p class="catalog-empty" id="supplyEmpty" hidden>Không tìm thấy vật tư phù hợp.</p></div>
      </section>
    </div>
  </div>
</main>

<dialog class="catalog-dialog" id="serviceDialog"><form id="serviceForm"><div class="catalog-dialog-head"><h2>Cập nhật thông tin dịch vụ</h2><button type="button" class="catalog-close" aria-label="Đóng">&times;</button></div><div class="catalog-dialog-body"><p class="catalog-preview-note">Chế độ xem trước: thay đổi chưa lưu vào cơ sở dữ liệu.</p><label>Tên dịch vụ<input id="editServiceName" required></label><label>Đơn giá niêm yết (VNĐ)<input id="editServicePrice" type="number" min="0" required></label><label>Tóm tắt ngắn<input id="editServiceSummary" required></label><label>Mô tả chi tiết<textarea id="editServiceDescription" rows="4" required></textarea></label></div><div class="catalog-dialog-actions"><button type="button" class="catalog-cancel">Hủy</button><button type="submit" class="catalog-primary">Áp dụng bản xem trước</button></div></form></dialog>
<dialog class="catalog-dialog" id="supplyDialog"><form id="supplyForm"><div class="catalog-dialog-head"><h2>Cập nhật vật tư</h2><button type="button" class="catalog-close" aria-label="Đóng">&times;</button></div><div class="catalog-dialog-body"><p class="catalog-preview-note">Chế độ xem trước: thay đổi chưa lưu vào cơ sở dữ liệu.</p><label>Tên vật tư<input id="editSupplyName" required></label><label>Số lượng tồn kho<input id="editSupplyQuantity" type="number" min="0" required></label><label>Đơn giá (VNĐ)<input id="editSupplyPrice" type="number" min="0" required></label></div><div class="catalog-dialog-actions"><button type="button" class="catalog-cancel">Hủy</button><button type="submit" class="catalog-primary">Áp dụng bản xem trước</button></div></form></dialog>
<script src="${pageContext.request.contextPath}/assets/js/admin-catalog.js" defer></script>
<jsp:include page="/views/common/footer.jsp" />
