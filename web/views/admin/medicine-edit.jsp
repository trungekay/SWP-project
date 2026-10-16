<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật Vật tư bán lẻ - VisionCare Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css?v=7" rel="stylesheet">
    <style>.page-content { padding: 30px; }</style>
</head>
<body>
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="retail" />
    </jsp:include>
    <main class="main-wrapper">
        <jsp:include page="/views/admin/layout/admin-header.jsp" />
        <div class="page-content catalog-page bg-light pb-5">
            <div class="container catalog-edit-layout">
                <aside class="catalog-panel catalog-edit-sidebar">
                    <h2>Vật tư bán lẻ</h2>
                    <p>Chọn mục cần sửa hoặc tạo mục mới.</p>
                    <a class="catalog-new-link" href="${pageContext.request.contextPath}/admin/medicine/item?new=1"><i class="bi bi-plus-circle"></i> Thêm mới</a>
                    <nav aria-label="Vật tư bán lẻ hiện có"><c:forEach items="${choices}" var="choice"><a class="catalog-choice ${choice.id == item.id ? 'is-active' : ''}" href="${pageContext.request.contextPath}/admin/medicine/item?id=${choice.id}"><c:out value="${choice.name}" /></a></c:forEach></nav>
                </aside>
                <section class="catalog-panel catalog-edit-panel">
                    <div class="catalog-edit-heading"><div><h1>${empty item.id ? 'Thêm mới' : 'Cập nhật'} vật tư bán lẻ</h1><p>Nhấn “Lưu thay đổi” để ghi trực tiếp vào database.</p></div><a href="${pageContext.request.contextPath}/admin/medicine">← Về danh sách</a></div>
                    <c:if test="${not empty error}"><div class="catalog-form-error" role="alert"><c:out value="${error}" /></div></c:if>
                    <form class="catalog-edit-form" action="${pageContext.request.contextPath}/admin/medicine/item" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="csrf" value="${sessionScope.medicineCsrf}">
                        <input type="hidden" name="id" value="${fn:escapeXml(item.id)}">
                        <label><span class="catalog-label-title">Tên vật tư / dược phẩm <em>*</em></span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
                        <label><span class="catalog-label-title">Phân loại <em>*</em></span><select name="category" required><option value="" disabled ${empty item.category ? 'selected' : ''}>Chọn phân loại</option><c:forEach items="${medicineCategories}" var="category"><option value="${fn:escapeXml(category.vietnameseName)}" ${item.category eq category.vietnameseName ? 'selected' : ''}><c:out value="${category.vietnameseName}" /></option></c:forEach></select></label>
                        <label><span class="catalog-label-title">Đơn giá (VNĐ) <em>*</em></span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
                        <div class="catalog-image-field">
                            <label class="catalog-image-label" for="medicineImageFile">Ảnh minh họa</label>
                            <div class="catalog-upload-control"><input class="catalog-upload-input" id="medicineImageFile" type="file" name="imageFile" accept="image/jpeg,image/png,image/webp" aria-describedby="medicineImageHint medicineFileName"><label class="catalog-upload-button" for="medicineImageFile"><i class="bi bi-image" aria-hidden="true"></i> Chọn ảnh</label><span class="catalog-upload-name" id="medicineFileName" aria-live="polite">Chưa chọn ảnh mới</span></div>
                            <small id="medicineImageHint">JPG, PNG hoặc WebP, tối đa 5 MB. Để trống nếu muốn giữ ảnh hiện tại.</small>
                            <c:if test="${item.uploadedImage}"><div class="catalog-image-current"><span>Ảnh hiện tại</span><img class="catalog-image-preview" src="${pageContext.request.contextPath}/medicine-image?id=${item.id}" alt="Ảnh vật tư bán lẻ hiện tại"></div></c:if>
                            <div class="catalog-image-selected" id="medicineSelectedImage" hidden><span>Ảnh vừa chọn</span><img class="catalog-image-preview" alt="Ảnh minh họa vừa chọn"></div>
                        </div>
                        <div class="catalog-form-actions"><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/medicine">Hủy</a><button class="catalog-primary" type="submit"><i class="bi bi-check-lg"></i> Lưu thay đổi</button></div>
                    </form>
                </section>
            </div>
        </div>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/admin-medicine.js?v=1" defer></script>
</body>
</html>
