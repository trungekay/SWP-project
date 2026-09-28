<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="500 — Lỗi hệ thống" />
  <jsp:param name="pageDescription" value="Đã xảy ra lỗi hệ thống" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <main class="main">
    <section class="section" style="min-height: 60vh; display: flex; align-items: center;">
      <div class="container text-center">
        <i class="bi bi-exclamation-triangle" style="font-size: 100px; color: #ffc107;"></i>
        <h1 class="display-1 fw-bold text-danger">500</h1>
        <h3 class="mb-3">Lỗi hệ thống</h3>
        <p class="text-muted mb-2">Xin lỗi, hệ thống đang gặp sự cố. Vui lòng thử lại sau.</p>
        <c:if test="${not empty error}">
          <p class="text-danger small mb-4">${error}</p>
        </c:if>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-5 py-2">
          <i class="bi bi-house me-2"></i>Về trang chủ
        </a>
      </div>
    </section>
  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />
