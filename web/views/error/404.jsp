<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="404 — Không tìm thấy" />
  <jsp:param name="pageDescription" value="Trang không tồn tại" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <main class="main">
    <section class="section" style="min-height: 60vh; display: flex; align-items: center;">
      <div class="container text-center">
        <i class="bi bi-emoji-frown" style="font-size: 100px; color: #dee2e6;"></i>
        <h1 class="display-1 fw-bold" style="color: #0d9488;">404</h1>
        <h3 class="mb-3">Trang không tồn tại</h3>
        <p class="text-muted mb-4">Xin lỗi, trang bạn tìm kiếm không có hoặc đã bị di chuyển.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-5 py-2">
          <i class="bi bi-house me-2"></i>Về trang chủ
        </a>
      </div>
    </section>
  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
