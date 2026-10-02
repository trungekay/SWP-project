<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/views/common/header.jsp"><jsp:param name="pageTitle" value="Lỗi danh mục" /><jsp:param name="bodyClass" value="admin-catalog-page" /></jsp:include>
<main class="main catalog-page"><div class="container catalog-error-page"><h1>Không tải được danh mục</h1><p><c:out value="${error}" /></p><a class="catalog-primary" href="${pageContext.request.contextPath}/admin/catalog">Thử lại</a></div></main>
<jsp:include page="/views/common/footer.jsp" />
