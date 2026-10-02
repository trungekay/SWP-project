<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Cập nhật Danh mục" />
  <jsp:param name="pageDescription" value="Cập nhật danh mục VisionCare" />
  <jsp:param name="bodyClass" value="admin-catalog-page" />
</jsp:include>

<main class="main catalog-page">
  <div class="catalog-breadcrumb"><div class="container"><a href="${pageContext.request.contextPath}/home">Trang chủ</a><span>/</span><a href="${pageContext.request.contextPath}/admin/catalog?tab=${kind == 'service' ? 'services' : 'supplies'}">Danh mục</a><span>/</span><strong>Cập nhật ${kind == 'service' ? 'dịch vụ' : 'vật tư'}</strong></div></div>
  <div class="container catalog-edit-layout">
    <aside class="catalog-panel catalog-edit-sidebar">
      <h2>${kind == 'service' ? 'Dịch vụ phòng khám' : 'Vật tư & Thiết bị'}</h2>
      <p>Chọn mục cần sửa hoặc tạo mục mới.</p>
      <a class="catalog-new-link" href="${pageContext.request.contextPath}/admin/catalog/${kind}?new=1"><i class="bi bi-plus-circle"></i> Thêm mới</a>
      <nav aria-label="Danh mục hiện có">
        <c:forEach items="${choices}" var="choice">
          <a class="catalog-choice ${choice.id == item.id ? 'is-active' : ''}" href="${pageContext.request.contextPath}/admin/catalog/${kind}?id=${choice.id}"><c:out value="${choice.name}" /></a>
        </c:forEach>
      </nav>
    </aside>
    <section class="catalog-panel catalog-edit-panel">
      <div class="catalog-edit-heading"><div><h1>${empty item.id ? 'Thêm mới' : 'Cập nhật'} ${kind == 'service' ? 'dịch vụ' : 'vật tư'}</h1><p>Nhấn “Lưu thay đổi” để ghi trực tiếp vào database.</p></div><a href="${pageContext.request.contextPath}/admin/catalog?tab=${kind == 'service' ? 'services' : 'supplies'}">← Về danh sách</a></div>
      <c:if test="${not empty error}"><div class="catalog-form-error" role="alert"><c:out value="${error}" /></div></c:if>
      <form class="catalog-edit-form" action="${pageContext.request.contextPath}/admin/catalog/${kind}" method="post">
        <input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}">
        <input type="hidden" name="id" value="${fn:escapeXml(item.id)}">
        <c:choose>
          <c:when test="${kind == 'service'}">
            <div class="catalog-form-grid"><label>Mã dịch vụ<input name="code" maxlength="20" value="${fn:escapeXml(item.code)}" placeholder="VD: NK-01"></label><label>Chuyên khoa<select name="specialty"><option value="">Khác</option><option value="general" ${item.specialty == 'general' ? 'selected' : ''}>Nhãn khoa tổng quát</option><option value="refraction" ${item.specialty == 'refraction' ? 'selected' : ''}>Khúc xạ &amp; Kính</option><option value="lasik" ${item.specialty == 'lasik' ? 'selected' : ''}>Phẫu thuật LASIK</option><option value="children" ${item.specialty == 'children' ? 'selected' : ''}>Nhãn khoa trẻ em</option><option value="retina" ${item.specialty == 'retina' ? 'selected' : ''}>Glaucoma &amp; Võng mạc</option><option value="cataract" ${item.specialty == 'cataract' ? 'selected' : ''}>Đục thủy tinh thể</option></select></label></div>
            <label>Tên dịch vụ <span>*</span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <div class="catalog-form-grid"><label>Đơn giá (VNĐ) <span>*</span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label><label>Nhãn hiển thị<input name="tag" maxlength="100" value="${fn:escapeXml(item.tag)}" placeholder="VD: Gói cơ bản"></label></div>
            <label>Tóm tắt ngắn<input name="summary" maxlength="500" value="${fn:escapeXml(item.summary)}"></label>
            <label>Mô tả chi tiết<textarea name="description" rows="5" maxlength="4000"><c:out value="${item.description}" /></textarea></label>
            <label>Ảnh minh họa<select name="image"><option value="">Ảnh mặc định</option><option value="departments-1.jpg" ${item.image == 'departments-1.jpg' ? 'selected' : ''}>Khám tổng quát</option><option value="departments-2.jpg" ${item.image == 'departments-2.jpg' ? 'selected' : ''}>Khúc xạ</option><option value="departments-3.jpg" ${item.image == 'departments-3.jpg' ? 'selected' : ''}>LASIK</option><option value="departments-4.jpg" ${item.image == 'departments-4.jpg' ? 'selected' : ''}>Trẻ em</option><option value="departments-5.jpg" ${item.image == 'departments-5.jpg' ? 'selected' : ''}>Phaco</option><option value="gallery/gallery-1.jpg" ${item.image == 'gallery/gallery-1.jpg' ? 'selected' : ''}>Võng mạc</option></select></label>
          </c:when>
          <c:otherwise>
            <label>Tên vật tư / dược phẩm <span>*</span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <div class="catalog-form-grid"><label>Phân loại <span>*</span><input name="category" maxlength="100" required value="${fn:escapeXml(item.category)}" placeholder="VD: Dung dịch nhỏ mắt"></label><label>Số lô<input name="batch" maxlength="50" value="${fn:escapeXml(item.batch)}"></label></div>
            <div class="catalog-form-grid"><label>Số lượng tồn kho <span>*</span><input name="quantity" type="number" min="0" step="1" required value="${fn:escapeXml(item.quantity)}"></label><label>Đơn vị <span>*</span><input name="unit" maxlength="30" required value="${fn:escapeXml(item.unit)}" placeholder="VD: lọ, hộp, cặp"></label></div>
            <label>Đơn giá (VNĐ) <span>*</span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
          </c:otherwise>
        </c:choose>
        <div class="catalog-form-actions"><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/catalog?tab=${kind == 'service' ? 'services' : 'supplies'}">Hủy</a><button class="catalog-primary" type="submit"><i class="bi bi-check-lg"></i> Lưu thay đổi</button></div>
      </form>
    </section>
  </div>
</main>
<jsp:include page="/views/common/footer.jsp" />
