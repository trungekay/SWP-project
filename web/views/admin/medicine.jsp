<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Vật tư bán lẻ - VisionCare Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <jsp:include page="/views/admin/layout/admin-css.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css?v=10" rel="stylesheet">
</head>
<body>
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="retail" />
    </jsp:include>
    <main class="main-wrapper">
        <jsp:include page="/views/admin/layout/admin-header.jsp" />
        <div class="page-content catalog-page">
            <div class="page-header"><div class="page-title"><h2>Quản lý Vật tư bán lẻ</h2><p>Danh sách thuốc, kính và vật tư kê đơn mang về cho bệnh nhân</p></div></div>
            <div class="catalog-layout">
                <div class="catalog-content">
                    <c:choose>
                        <c:when test="${param.created == '1'}"><c:set var="successMessage" value="Đã tạo thành công" /></c:when>
                        <c:when test="${param.updated == '1'}"><c:set var="successMessage" value="Đã sửa thành công" /></c:when>
                        <c:when test="${param.deleted == '1'}"><c:set var="successMessage" value="Đã xóa thành công" /></c:when>
                    </c:choose>
                    <c:if test="${not empty successMessage}"><div id="medicineSuccessToast" class="catalog-success-toast" role="status" aria-live="polite"><i class="bi bi-check-circle-fill" aria-hidden="true"></i><span><c:out value="${successMessage}" /></span></div></c:if>
                    <c:if test="${param.deleteError == '1'}"><div class="catalog-delete-error" role="alert">Không thể xóa mục này. Mục có thể đang được sử dụng; hãy kiểm tra dữ liệu liên quan.</div></c:if>
                    <section class="catalog-view" id="medicineView">
                        <div class="catalog-panel catalog-heading"><h5><i class="bi bi-bag-check me-2 text-primary"></i>Danh sách Vật tư kê đơn mang về</h5><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/medicine/item?new=1"><i class="bi bi-plus-lg"></i> Thêm vật tư bán lẻ</a></div>
                        <div class="catalog-panel catalog-supply-panel">
                            <div class="catalog-supply-toolbar">
                                <label class="catalog-search"><i class="bi bi-search" aria-hidden="true"></i><input type="search" id="medicineSearch" autocomplete="off" placeholder="Tìm thuốc, kính hoặc phụ kiện" aria-label="Tìm vật tư bán lẻ"></label>
                                <div class="catalog-filter-actions">
                                    <div class="catalog-category-filter" id="medicineCategoryFilter">
                                        <button class="catalog-filter-trigger" id="medicineCategoryTrigger" type="button" aria-expanded="false" aria-controls="medicineCategoryMenu" aria-label="Lọc theo phân loại: Tất cả phân loại">
                                            <span class="catalog-filter-icon"><i class="bi bi-funnel" aria-hidden="true"></i></span>
                                            <span class="catalog-filter-content"><span class="catalog-filter-title">Phân loại</span><span class="catalog-filter-selected" id="medicineCategoryLabel">Tất cả phân loại</span></span>
                                            <i class="bi bi-chevron-down catalog-filter-chevron" aria-hidden="true"></i>
                                        </button>
                                        <div class="catalog-filter-menu" id="medicineCategoryMenu" role="group" aria-label="Chọn phân loại sản phẩm" hidden>
                                            <p class="catalog-filter-menu-title">Chọn phân loại</p>
                                            <button class="catalog-filter-option is-selected" type="button" data-category="" aria-pressed="true"><span class="catalog-filter-option-name">Tất cả phân loại</span><span class="catalog-filter-option-count">0</span><i class="bi bi-check-lg" aria-hidden="true"></i></button>
                                            <c:forEach items="${medicineCategories}" var="category"><button class="catalog-filter-option" type="button" data-category="${fn:escapeXml(category.vietnameseName)}" aria-pressed="false"><span class="catalog-filter-option-name"><c:out value="${category.vietnameseName}" /></span><span class="catalog-filter-option-count">0</span><i class="bi bi-check-lg" aria-hidden="true"></i></button></c:forEach>
                                        </div>
                                    </div>
                                    <span class="catalog-result-count" role="status" aria-live="polite">Hiển thị <strong id="medicineVisibleCount">${fn:length(medicines)}</strong> sản phẩm</span>
                                </div>
                            </div>
                            <div class="table-responsive catalog-table-wrap"><table class="table align-middle table-custom catalog-table">
                                <thead><tr><th>Tên vật tư / Dược phẩm</th><th>Phân loại</th><th>Đơn giá bán</th><th class="text-end">Thao tác</th></tr></thead>
                                <tbody><c:forEach items="${medicines}" var="medicine"><tr data-category="${fn:escapeXml(medicine.category)}"><td><strong><c:out value="${medicine.name}" /></strong></td><td><c:out value="${medicine.category}" /></td><td><fmt:formatNumber value="${medicine.price}" pattern="#,##0" /> VNĐ</td><td><div class="catalog-supply-actions"><a class="catalog-supply-edit" href="${pageContext.request.contextPath}/admin/medicine/item?id=${medicine.id}" aria-label="Sửa vật tư bán lẻ ${fn:escapeXml(medicine.name)}" title="Sửa vật tư bán lẻ"><i class="bi bi-pencil" aria-hidden="true"></i></a><form class="medicine-delete-form" method="post" action="${pageContext.request.contextPath}/admin/medicine/item" data-name="${fn:escapeXml(medicine.name)}"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${medicine.id}"><input type="hidden" name="csrf" value="${sessionScope.medicineCsrf}"><button class="catalog-delete" type="button" aria-label="Xóa vật tư bán lẻ ${fn:escapeXml(medicine.name)}" title="Xóa vật tư bán lẻ"><i class="bi bi-trash" aria-hidden="true"></i></button></form></div></td></tr></c:forEach></tbody>
                            </table></div>
                            <p class="catalog-empty" id="medicineEmpty" hidden>Chưa có vật tư bán lẻ hoặc không tìm thấy mục phù hợp.</p>
                        </div>
                    </section>
                </div>
            </div>
        </div>
    </main>
    <dialog id="medicineDeleteDialog" class="catalog-delete-dialog" aria-labelledby="medicineDeleteTitle" aria-describedby="medicineDeleteDescription">
        <div class="catalog-delete-dialog-icon" aria-hidden="true"><i class="bi bi-trash3"></i></div>
        <h2 id="medicineDeleteTitle">Xác nhận xóa</h2>
        <p id="medicineDeleteDescription">Bạn có chắc muốn xóa vật tư bán lẻ <strong id="medicineDeleteName"></strong>?</p>
        <p class="catalog-delete-dialog-note">Mục này sẽ bị xóa khỏi database và không thể khôi phục từ trang quản trị.</p>
        <div class="catalog-delete-dialog-actions"><button id="medicineDeleteCancel" type="button" class="catalog-delete-cancel">Hủy</button><button id="medicineDeleteConfirm" type="button" class="catalog-delete-confirm"><i class="bi bi-trash"></i> Xác nhận xóa</button></div>
    </dialog>
    <script src="${pageContext.request.contextPath}/assets/js/admin-medicine.js?v=5" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
