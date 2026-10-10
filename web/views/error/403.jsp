<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="403 — Từ chối truy cập" />
  <jsp:param name="pageDescription" value="Bạn không có quyền truy cập" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <main class="main">
    <section class="section" style="min-height: 60vh; display: flex; align-items: center;">
      <div class="container text-center">
        <i class="bi bi-shield-lock" style="font-size: 100px; color: #dee2e6;"></i>
        <h1 class="display-1 fw-bold" style="color: #dc3545;">403</h1>
        <h3 class="mb-3">Từ chối truy cập</h3>
        <p class="text-muted mb-4">Xin lỗi, bạn không có quyền truy cập vào trang này.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-5 py-2">
          <i class="bi bi-house me-2"></i>Về trang chủ
        </a>
      </div>
    </section>
  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
