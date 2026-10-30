<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <link href="${pageContext.request.contextPath}/assets/css/admin-catalog.css?v=7" rel="stylesheet">

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

  <div class="container catalog-edit-layout">
    <aside class="catalog-panel catalog-edit-sidebar">
      <h2>${kind == 'service' ? 'Dịch vụ phòng khám' : (catalogReturnTab == 'consumables' ? 'Vật tư tiêu hao' : 'Thiết bị')}</h2>
      <p>Chọn mục cần sửa hoặc tạo mục mới.</p>
      <a class="catalog-new-link" href="${pageContext.request.contextPath}/admin/catalog/${kind}?new=1"><i class="bi bi-plus-circle"></i> Thêm mới</a>
      <nav aria-label="Danh mục hiện có">
        <c:forEach items="${choices}" var="choice">
            <a class="catalog-choice ${choice.id == item.id ? 'is-active' : ''}" href="${pageContext.request.contextPath}/admin/catalog/${kind}?id=${choice.id}"><c:out value="${choice.name}" /></a>
        </c:forEach>
      </nav>
    </aside>
    <section class="catalog-panel catalog-edit-panel">
      <div class="catalog-edit-heading"><div><h1>${empty item.id ? 'Thêm mới' : 'Cập nhật'} ${kind == 'service' ? 'dịch vụ' : (catalogReturnTab == 'consumables' ? 'vật tư tiêu hao' : 'thiết bị')}</h1><p>Nhấn “Lưu thay đổi” để ghi trực tiếp vào database.</p></div><a href="${pageContext.request.contextPath}/admin/catalog?tab=${catalogReturnTab}">← Về danh sách</a></div>
      <c:if test="${not empty error}"><div class="catalog-form-error" role="alert"><c:out value="${error}" /></div></c:if>
      <form class="catalog-edit-form" action="${pageContext.request.contextPath}/admin/catalog/${kind}" method="post" enctype="multipart/form-data">
        <input type="hidden" name="csrf" value="${sessionScope.catalogCsrf}">
        <input type="hidden" name="id" value="${fn:escapeXml(item.id)}">
        <input type="hidden" name="returnTab" value="${catalogReturnTab}">
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
            <label><span class="catalog-label-title catalog-service-label">Đơn giá (VNĐ) <em>*</em></span><input name="price" type="number" min="10000" step="1" required value="${fn:escapeXml(item.price)}"><small>Nhập số nguyên từ 10.000 VNĐ trở lên.</small></label>
            <label>Tóm tắt ngắn<input name="summary" maxlength="500" value="${fn:escapeXml(item.summary)}"></label>
            <label>Mô tả chi tiết<textarea name="description" rows="4" maxlength="4000"><c:out value="${item.description}" /></textarea></label>

            <!-- CẤU HÌNH ĐẶT LỊCH & KHÁM TIỀN PHẪU (DYNAMIC PRE-OP CONFIG) -->
            <div class="card border rounded-3 p-3 mb-3 bg-white shadow-sm mt-3" style="border-color: #99f6e4 !important; background-color: #f0fdfa !important;">
              <div class="d-flex align-items-center gap-2 mb-2">
                <i class="bi bi-shield-check text-success fs-5"></i>
                <h6 class="fw-bold mb-0 text-dark">Quy tắc Đặt lịch & Khám tiền phẫu</h6>
              </div>
              <p class="text-muted small mb-3">Cấu hình điều kiện để bệnh nhân đặt lịch dịch vụ này trực tiếp hoặc yêu cầu qua bước khám tiền phẫu trước.</p>

              <div class="row g-3">
                <div class="col-md-6">
                  <div class="form-check form-switch ps-5 mb-2">
                    <input class="form-check-input ms-n5" type="checkbox" role="switch" id="allowDirectBooking" name="allowDirectBooking" value="true"
                           ${empty item.id or item.allowDirectBooking ? 'checked' : ''}>
                    <label class="form-check-label fw-semibold text-dark small" for="allowDirectBooking">
                      Cho phép bệnh nhân đặt lịch trực tiếp trên Website
                    </label>
                    <div class="text-muted" style="font-size: 11px;">Nếu tắt, dịch vụ chỉ được tạo qua chỉ định Bác sĩ hoặc quy trình tiền phẫu.</div>
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-check form-switch ps-5 mb-2">
                    <input class="form-check-input ms-n5" type="checkbox" role="switch" id="requiresPreOp" name="requiresPreOp" value="true"
                           ${item.requiresPreOp ? 'checked' : ''} onchange="togglePreOpSelect(this.checked)">
                    <label class="form-check-label fw-semibold text-dark small" for="requiresPreOp">
                      Bắt buộc thực hiện khám tiền phẫu / tiền điều kiện trước
                    </label>
                    <div class="text-muted" style="font-size: 11px;">Bệnh nhân khi nhấn Đặt lịch sẽ tự động được dẫn sang gói khám tiền phẫu tương ứng.</div>
                  </div>
                </div>

                <div class="col-12" id="prereqServiceDiv" style="display: ${item.requiresPreOp ? 'block' : 'none'};">
                  <label class="form-label fw-semibold small text-primary mb-1">
                    <i class="bi bi-arrow-return-right me-1"></i>Chọn Gói khám tiền phẫu / tầm soát bắt buộc:
                  </label>
                  <select name="prerequisiteServiceId" class="form-select form-select-sm">
                    <option value="">-- Chọn gói khám tiền phẫu / tầm soát --</option>
                    <c:forEach items="${availablePrereqServices}" var="pSvc">
                      <c:if test="${empty item.id or pSvc.id != item.id}">
                        <option value="${pSvc.id}" ${item.prerequisiteServiceId == pSvc.id ? 'selected' : ''}>
                          ${pSvc.code} - ${pSvc.name} (<fmt:formatNumber value="${pSvc.price}" pattern="#,##0" /> VNĐ)
                        </option>
                      </c:if>
                    </c:forEach>
                  </select>
                </div>
              </div>
            </div>

            <!-- CẤU HÌNH CÁC BƯỚC QUY TRÌNH (DYNAMIC WORKFLOW STEPS BUILDER) -->
            <div class="card border rounded-3 p-3 mb-3 bg-white shadow-sm">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="d-flex align-items-center gap-2">
                  <i class="bi bi-diagram-3 fs-5" style="color: #0d9488;"></i>
                  <div>
                    <h6 class="fw-bold mb-0 text-dark">Quy trình các bước thực hiện (Workflow Timeline)</h6>
                    <small class="text-muted" style="font-size: 11px;">Thêm các bước trước khám (lấy máu, đo máy...), trong khám (khám Bác sĩ) và sau khám (phẫu thuật, dặn dò...).</small>
                  </div>
                </div>
                <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3" onclick="addWorkflowStepRow()">
                  <i class="bi bi-plus-circle me-1"></i>Thêm bước
                </button>
              </div>

              <div class="table-responsive">
                <table class="table table-sm table-bordered align-middle mb-1" id="workflowStepsTable">
                  <thead class="table-light">
                    <tr class="small text-muted">
                      <th style="width: 70px;" class="text-center">Thứ tự</th>
                      <th style="width: 140px;">Giai đoạn</th>
                      <th>Tên bước thực hiện (VD: Lấy máu, đo máy...)</th>
                      <th>Mô tả / Hướng dẫn</th>
                      <th style="width: 50px;" class="text-center">Xóa</th>
                    </tr>
                  </thead>
                  <tbody id="workflowStepsTbody">
                    <c:forEach items="${item.workflowSteps}" var="step" varStatus="st">
                      <tr>
                        <td class="text-center">
                          <input type="number" name="stepOrder" class="form-control form-control-sm text-center" value="${step.stepOrder}" min="1">
                        </td>
                        <td>
                          <select name="stepStage" class="form-select form-select-sm">
                            <option value="PRE_EXAM" ${step.stepStage == 'PRE_EXAM' ? 'selected' : ''}>Trước khám</option>
                            <option value="IN_EXAM" ${step.stepStage == 'IN_EXAM' ? 'selected' : ''}>Trong khám</option>
                            <option value="POST_EXAM" ${step.stepStage == 'POST_EXAM' ? 'selected' : ''}>Sau khám</option>
                          </select>
                        </td>
                        <td>
                          <input type="text" name="stepName" class="form-control form-control-sm" value="${fn:escapeXml(step.stepName)}" placeholder="Tên bước...">
                        </td>
                        <td>
                          <input type="text" name="stepDescription" class="form-control form-control-sm" value="${fn:escapeXml(step.description)}" placeholder="Ghi chú thêm...">
                        </td>
                        <td class="text-center">
                          <button type="button" class="btn btn-outline-danger btn-sm p-1" onclick="this.closest('tr').remove()" title="Xóa bước này">
                            <i class="bi bi-trash"></i>
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
              <div class="d-flex justify-content-between align-items-center mt-2">
                <span class="text-muted small fst-italic" style="font-size: 11px;">
                  💡 Gợi ý: Các bước điển hình: "Lấy máu xét nghiệm", "Đo khúc xạ máy", "Chụp OCT", "Khám lâm sàng Bác sĩ", "Thực hiện phẫu thuật"...
                </span>
                <button type="button" class="btn btn-sm btn-link text-decoration-none p-0 text-primary" onclick="addWorkflowStepRow()">
                  <i class="bi bi-plus-lg me-1"></i>Thêm bước khác
                </button>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <label><span class="catalog-label-title">${catalogReturnTab == 'supplies' ? 'Tên thiết bị' : (catalogReturnTab == 'consumables' ? 'Tên vật tư tiêu hao' : 'Tên vật tư / dược phẩm')} <em>*</em></span><input name="name" maxlength="255" required value="${fn:escapeXml(item.name)}"></label>
            <label><span class="catalog-label-title">Phân loại <em>*</em></span>
              <select name="category" required>
                <option value="" disabled ${empty item.category ? 'selected' : ''}>Chọn phân loại</option>
                <c:forEach items="${supplyCategories}" var="category">
                  <c:if test="${(catalogReturnTab == 'supplies' && category.vietnameseName == 'Khác') || (catalogReturnTab == 'consumables' && category.vietnameseName == 'Vật tư y tế tiêu hao')}">
                    <option value="${fn:escapeXml(category.vietnameseName)}" ${item.category eq category.vietnameseName ? 'selected' : ''}>${catalogReturnTab == 'supplies' ? 'Thiết bị' : fn:escapeXml(category.vietnameseName)}</option>
                  </c:if>
                </c:forEach>
              </select>
            </label>
            <label><span class="catalog-label-title">${catalogReturnTab == 'supplies' ? 'Giá trị (VNĐ)' : 'Đơn giá (VNĐ)'} <em>*</em></span><input name="price" type="number" min="0" step="1" required value="${fn:escapeXml(item.price)}"></label>
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
            <c:when test="${kind != 'service' && item.uploadedImage}"><div class="catalog-image-current"><span>Ảnh hiện tại</span><img class="catalog-image-preview" src="${pageContext.request.contextPath}/catalog-image?kind=${kind}&amp;id=${item.id}" alt="Ảnh vật tư hiện tại"></div></c:when>
          </c:choose>
          <div class="catalog-image-selected" id="catalogSelectedImage" hidden><span>Ảnh vừa chọn</span><img class="catalog-image-preview" alt="Ảnh minh họa vừa chọn"></div>
        </div>
        <div class="catalog-form-actions"><a class="catalog-detail" href="${pageContext.request.contextPath}/admin/catalog?tab=${catalogReturnTab}">Hủy</a><button class="catalog-primary" type="submit"><i class="bi bi-check-lg"></i> Lưu thay đổi</button></div>
      </form>
    </section>
  </div>
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/admin-catalog.js?v=9" defer></script>
    <script>
      function togglePreOpSelect(checked) {
        const div = document.getElementById('prereqServiceDiv');
        if (div) {
          div.style.display = checked ? 'block' : 'none';
        }
      }

      function addWorkflowStepRow() {
        const tbody = document.getElementById('workflowStepsTbody');
        if (!tbody) return;
        const currentCount = tbody.querySelectorAll('tr').length;
        const nextOrder = currentCount + 1;

        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td class="text-center">
            <input type="number" name="stepOrder" class="form-control form-control-sm text-center" value="\${nextOrder}" min="1">
          </td>
          <td>
            <select name="stepStage" class="form-select form-select-sm">
              <option value="PRE_EXAM">Trước khám</option>
              <option value="IN_EXAM">Trong khám</option>
              <option value="POST_EXAM">Sau khám</option>
            </select>
          </td>
          <td>
            <input type="text" name="stepName" class="form-control form-control-sm" placeholder="Nhập tên bước (VD: Lấy máu, đo máy...)" required>
          </td>
          <td>
            <input type="text" name="stepDescription" class="form-control form-control-sm" placeholder="Ghi chú thêm...">
          </td>
          <td class="text-center">
            <button type="button" class="btn btn-outline-danger btn-sm p-1" onclick="this.closest('tr').remove()" title="Xóa bước này">
              <i class="bi bi-trash"></i>
            </button>
          </td>
        `;
        tbody.appendChild(tr);
        tr.querySelector('input[name="stepName"]').focus();
      }
    </script>
</body>
</html>
