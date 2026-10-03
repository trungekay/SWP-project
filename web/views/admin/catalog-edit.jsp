<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật Danh mục - VisionCare Admin</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">
    
    <!-- Catalog specific CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css" rel="stylesheet">

  <style>
    .page-content { padding: 30px; }
  </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="catalog" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content catalog-page bg-light pb-5">

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
      <form class="catalog-edit-form" action="${pageContext.request.contextPath}/admin/catalog/${kind}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}">
        <input type="hidden" name="id" value="${fn:escapeXml(item.id)}">
        <c:choose>
          <c:when test="${kind == 'service'}">
            <div class="catalog-form-grid"><label>Mã dịch vụ<input name="code" maxlength="20" value="${fn:escapeXml(item.code)}" placeholder="VD: NK-01"></label><label>Chuyên khoa<select name="specialty"><option value="">Khác</option><option value="general" ${item.specialty == 'general' ? 'selected' : ''}>Nhãn khoa tổng quát</option><option value="refraction" ${item.specialty == 'refraction' ? 'selected' : ''}>Khúc xạ &amp; Kính</option><option value="lasik" ${item.specialty == 'lasik' ? 'selected' : ''}>Phẫu thuật LASIK</option><option value="children" ${item.specialty == 'children' ? 'selected' : ''}>Nhãn khoa trẻ em</option><option value="retina" ${item.specialty == 'retina' ? 'selected' : ''}>Glaucoma &amp; Võng mạc</option><option value="cataract" ${item.specialty == 'cataract' ? 'selected' : ''}>Đục thủy tinh thể</option></select></label></div>
            <label>Tên dịch vụ <span>*</span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <div class="catalog-form-grid"><label>Đơn giá (VNĐ) <span>*</span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label><label>Nhãn hiển thị<input name="tag" maxlength="100" value="${fn:escapeXml(item.tag)}" placeholder="VD: Gói cơ bản"></label></div>
            <label>Tóm tắt ngắn<input name="summary" maxlength="500" value="${fn:escapeXml(item.summary)}"></label>
            <label>Mô tả chi tiết<textarea name="description" rows="5" maxlength="4000"><c:out value="${item.description}" /></textarea></label>
            <label>Ảnh minh họa từ máy<input type="file" name="imageFile" accept="image/jpeg,image/png,image/webp"><small>JPG, PNG hoặc WebP, tối đa 5 MB. Để trống nếu muốn giữ ảnh hiện tại.</small></label><c:if test="${not empty item.id}"><c:choose><c:when test="${item.uploadedImage}"><img class="catalog-image-preview" src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${item.id}" alt="Ảnh dịch vụ hiện tại"></c:when><c:when test="${not empty item.image}"><img class="catalog-image-preview" src="${pageContext.request.contextPath}/assets/img/${fn:escapeXml(item.image)}" alt="Ảnh dịch vụ hiện tại"></c:when></c:choose></c:if>
          </c:when>
          <c:otherwise>
            <label>Tên vật tư / dược phẩm <span>*</span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <div class="catalog-form-grid"><label>Phân loại <span>*</span><input name="category" maxlength="100" required value="${fn:escapeXml(item.category)}" placeholder="VD: Dung dịch nhỏ mắt"></label><label>Số lô<input name="batch" maxlength="50" value="${fn:escapeXml(item.batch)}"></label></div>
            <div class="catalog-form-grid"><label>Số lượng tồn kho <span>*</span><input name="quantity" type="number" min="0" step="1" required value="${fn:escapeXml(item.quantity)}"></label><label>Đơn vị <span>*</span><input name="unit" maxlength="30" required value="${fn:escapeXml(item.unit)}" placeholder="VD: lọ, hộp, cặp"></label></div>
            <label>Đơn giá (VNĐ) <span>*</span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
            <label>Ảnh vật tư từ máy<input type="file" name="imageFile" accept="image/jpeg,image/png,image/webp"><small>JPG, PNG hoặc WebP, tối đa 5 MB. Để trống nếu muốn giữ ảnh hiện tại.</small></label><c:if test="${not empty item.id && item.uploadedImage}"><img class="catalog-image-preview" src="${pageContext.request.contextPath}/catalog-image?kind=supply&amp;id=${item.id}" alt="Ảnh vật tư hiện tại"></c:if>
          </c:otherwise>
        </c:choose>
        <div class="catalog-form-actions"><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/catalog?tab=${kind == 'service' ? 'services' : 'supplies'}">Hủy</a><button class="catalog-primary" type="submit"><i class="bi bi-check-lg"></i> Lưu thay đổi</button></div>
      </form>
    </section>
  </div>
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
