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
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    
    <!-- Catalog specific CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css?v=2" rel="stylesheet">

  <style>
    .page-content { padding: 30px; }
  </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="catalog" />
        <jsp:param name="activeSub" value="${kind == 'supply' ? 'supplies' : 'services'}" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content catalog-page bg-light pb-5">

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
            <div class="catalog-form-grid">
              <label>Mã dịch vụ<input name="code" maxlength="20" value="${fn:escapeXml(item.code)}" placeholder="VD: NK-01"></label>
              <label><span class="catalog-label-title catalog-service-label">Nhóm dịch vụ <em>*</em></span>
                <select name="category" required>
                  <option value="" disabled ${empty item.category ? 'selected' : ''}>Chọn nhóm dịch vụ</option>
                  <c:forEach items="${serviceCategories}" var="category">
                    <option value="${fn:escapeXml(category.vietnameseName)}" ${item.category eq category.vietnameseName ? 'selected' : ''}><c:out value="${category.vietnameseName}" /></option>
                  </c:forEach>
                </select>
              </label>
            </div>
            <label><span class="catalog-label-title catalog-service-label">Tên dịch vụ <em>*</em></span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <label><span class="catalog-label-title catalog-service-label">Đơn giá (VNĐ) <em>*</em></span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
            <label>Tóm tắt ngắn<input name="summary" maxlength="500" value="${fn:escapeXml(item.summary)}"></label>
            <label>Mô tả chi tiết<textarea name="description" rows="5" maxlength="4000"><c:out value="${item.description}" /></textarea></label>
          </c:when>
          <c:otherwise>
            <label><span class="catalog-label-title">Tên vật tư / dược phẩm <em>*</em></span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <label><span class="catalog-label-title">Phân loại <em>*</em></span>
              <select name="category" required>
                <option value="" disabled ${empty item.category ? 'selected' : ''}>Chọn phân loại</option>
                <c:forEach items="${supplyCategories}" var="category">
                  <option value="${fn:escapeXml(category.vietnameseName)}" ${item.category eq category.vietnameseName ? 'selected' : ''}><c:out value="${category.vietnameseName}" /></option>
                </c:forEach>
              </select>
            </label>
            <label><span class="catalog-label-title">Đơn giá (VNĐ) <em>*</em></span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
          </c:otherwise>
        </c:choose>
        <div class="catalog-image-field">
          <label class="catalog-image-label" for="catalogImageFile">Ảnh minh họa</label>
          <div class="catalog-upload-control">
            <input class="catalog-upload-input" id="catalogImageFile" type="file" name="imageFile" accept="image/jpeg,image/png,image/webp" aria-describedby="catalogImageHint catalogFileName">
            <label class="catalog-upload-button" for="catalogImageFile"><i class="bi bi-image" aria-hidden="true"></i> Chọn ảnh</label>
            <span class="catalog-upload-name" id="catalogFileName" aria-live="polite">Chưa chọn ảnh mới</span>
          </div>
          <small id="catalogImageHint">JPG, PNG hoặc WebP, tối đa 5 MB. Để trống nếu muốn giữ ảnh hiện tại.</small>
          <c:choose>
            <c:when test="${kind == 'service' && item.uploadedImage}"><div class="catalog-image-current"><span>Ảnh hiện tại</span><img class="catalog-image-preview" src="${pageContext.request.contextPath}/catalog-image?kind=service&amp;id=${item.id}" alt="Ảnh dịch vụ hiện tại"></div></c:when>
            <c:when test="${kind == 'service' && not empty item && not item.uploadedImage}"><div class="catalog-image-current"><span>Ảnh mặc định</span><img class="catalog-image-preview" src="${pageContext.request.contextPath}/assets/img/${item.defaultImagePath}" alt="Ảnh mặc định của dịch vụ"></div></c:when>
            <c:when test="${kind == 'supply' && item.uploadedImage}"><div class="catalog-image-current"><span>Ảnh hiện tại</span><img class="catalog-image-preview" src="${pageContext.request.contextPath}/catalog-image?kind=supply&amp;id=${item.id}" alt="Ảnh vật tư hiện tại"></div></c:when>
          </c:choose>
          <div class="catalog-image-selected" id="catalogSelectedImage" hidden><span>Ảnh vừa chọn</span><img class="catalog-image-preview" alt="Ảnh minh họa vừa chọn"></div>
        </div>
        <div class="catalog-form-actions"><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/catalog?tab=${kind == 'service' ? 'services' : 'supplies'}">Hủy</a><button class="catalog-primary" type="submit"><i class="bi bi-check-lg"></i> Lưu thay đổi</button></div>
      </form>
    </section>
  </div>
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/admin-catalog-edit.js"></script>
</body>
</html>
