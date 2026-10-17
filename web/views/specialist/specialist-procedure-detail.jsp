<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Thực hiện thủ thuật: #CD-${order.orderId} - VisionCare</title>
  
  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <!-- Bootstrap 5 CSS & Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  
  <!-- Layout CSS (Staff & Admin Design System) -->
  <jsp:include page="/views/staff/layout/staff-css.jsp" />
  <!-- Custom Styles for Screen 36 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/specialist-procedure-detail.css">
</head>
<body>

  <!-- Sidebar -->
  <jsp:include page="/views/employee/layout/employee-sidebar.jsp">
    <jsp:param name="activeNav" value="waiting-list" />
  </jsp:include>

  <!-- Main Wrapper -->
  <div class="main-wrapper">
    <!-- Top Header -->
    <jsp:include page="/views/employee/layout/employee-header.jsp" />

    <!-- Page Content -->
    <main class="page-content">
      
      <!-- Thông báo Flash Messages -->
      <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-check-circle-fill me-2 fs-5 align-middle"></i>
          <strong>Thành công!</strong> <c:out value="${sessionScope.successMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="successMessage" scope="session" />
      </c:if>

      <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-exclamation-triangle-fill me-2 fs-5 align-middle"></i>
          <strong>Lỗi!</strong> <c:out value="${sessionScope.errorMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="errorMessage" scope="session" />
      </c:if>

      <c:if test="${not empty sessionScope.infoMessage}">
        <div class="alert alert-info alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
          <i class="bi bi-info-circle-fill me-2 fs-5 align-middle"></i>
          <c:out value="${sessionScope.infoMessage}" />
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="infoMessage" scope="session" />
      </c:if>

      <!-- Top Action Bar & Breadcrumbs -->
      <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
        <div>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-1" style="font-size: 13px;">
              <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/specialist/waiting-list" class="text-decoration-none text-secondary">
                  <i class="bi bi-clipboard2-pulse me-1"></i>Hàng đợi
                </a>
              </li>
              <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${order.patientId}&orderId=${order.orderId}" class="text-decoration-none text-secondary">
                  BN: <c:out value="${order.patientName}" />
                </a>
              </li>
              <li class="breadcrumb-item active fw-semibold text-dark" aria-current="page">
                Thực hiện #CD-${order.orderId}
              </li>
            </ol>
          </nav>
          <h4 class="fw-bold mb-0 text-dark d-flex align-items-center gap-2">
            <span>Chi tiết Thực hiện Thủ thuật & Cận lâm sàng</span>
            <span class="badge bg-teal text-white fs-6 py-1 px-2.5 rounded-pill">#CD-${order.orderId}</span>
          </h4>
        </div>

        <div class="d-flex align-items-center gap-2">
          <a href="${pageContext.request.contextPath}/specialist/patient-detail?patientId=${order.patientId}&orderId=${order.orderId}" 
             class="btn btn-sm btn-outline-teal rounded-pill px-3 d-inline-flex align-items-center gap-1.5 shadow-sm">
            <i class="bi bi-person-vcard"></i>
            <span>Xem Hồ sơ bệnh nhân</span>
          </a>
          <a href="${pageContext.request.contextPath}/specialist/waiting-list" 
             class="btn btn-sm btn-outline-secondary rounded-pill px-3 d-inline-flex align-items-center gap-1.5 shadow-sm">
            <i class="bi bi-arrow-left"></i>
            <span>Về Hàng đợi</span>
          </a>
        </div>
      </div>

      <!-- Main Layout: 2 Cột -->
      <div class="row g-4">
        
        <!-- ========================================== -->
        <!-- CỘT TRÁI (COL-LG-5): REPORT & TO-DO LIST   -->
        <!-- ========================================== -->
        <div class="col-lg-5">
          
          <!-- FEATURE 1: VIEW EXAMINATION REPORT (Phiếu khám & Yêu cầu của Bác sĩ) -->
          <div class="custom-card report-card">
            <div class="card-header-clean">
              <h5 class="card-title-sm text-dark">
                <i class="bi bi-file-earmark-medical text-primary fs-5"></i>
                Báo cáo khám của Bác sĩ
              </h5>
              <span class="badge bg-light text-secondary border px-2 py-1" style="font-size: 11px;">
                #APT-${record.appointmentId}
              </span>
            </div>

            <div class="p-3">
              <!-- Bác sĩ chỉ định -->
              <div class="d-flex align-items-center gap-3 pb-3 border-bottom">
                <div class="rounded-circle bg-light text-primary d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; font-size: 20px;">
                  <i class="bi bi-person-badge"></i>
                </div>
                <div>
                  <div class="small text-muted">Bác sĩ khám chính</div>
                  <strong class="text-dark"><c:out value="${record.doctorName != null ? record.doctorName : order.doctorName}" /></strong>
                  <div class="small text-secondary"><c:out value="${record.doctorSpecialty != null ? record.doctorSpecialty : 'Chuyên khoa Mắt'}" /></div>
                </div>
              </div>

              <!-- Chẩn đoán sơ bộ ban đầu -->
              <div class="diagnosis-box">
                <div class="diagnosis-title">
                  <i class="bi bi-activity me-1"></i>Chẩn đoán lâm sàng của Bác sĩ
                </div>
                <div class="fw-bold text-dark fs-6" style="line-height: 1.5;">
                  <c:choose>
                    <c:when test="${not empty record.clinicalDiagnosis}">
                      <c:out value="${record.clinicalDiagnosis}" />
                    </c:when>
                    <c:otherwise>
                      <span class="text-muted fw-normal fst-italic">Bác sĩ chưa ghi nhận chẩn đoán sơ bộ.</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>

              <!-- Thời gian khám ban đầu -->
              <div class="mt-3 small text-muted d-flex justify-content-between align-items-center">
                <span><i class="bi bi-clock me-1"></i>Thời gian chỉ định:</span>
                <span class="fw-medium text-dark">
                  <fmt:formatDate value="${order.recordCreatedAt != null ? order.recordCreatedAt : record.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                </span>
              </div>
            </div>
          </div>

          <!-- FEATURE 2: VIEW TO-DO LIST (Danh sách thủ thuật của ca khám) -->
          <div class="custom-card todo-card">
            <div class="card-header-clean">
              <h5 class="card-title-sm text-dark">
                <i class="bi bi-check2-square text-warning fs-5"></i>
                To-do list ca khám (${todoList != null ? todoList.size() : 0})
              </h5>
              <span class="small text-muted">Checklist chỉ định</span>
            </div>

            <div class="todo-list-group">
              <c:choose>
                <c:when test="${empty todoList}">
                  <div class="p-4 text-center text-muted small">
                    Không có thủ thuật nào khác trong ca khám này.
                  </div>
                </c:when>
                <c:otherwise>
                  <c:forEach var="todo" items="${todoList}">
                    <a href="${pageContext.request.contextPath}/specialist/procedure-detail?orderId=${todo.orderId}" 
                       class="todo-item ${todo.orderId == order.orderId ? 'active-item' : ''}">
                      
                      <div class="d-flex align-items-start gap-2.5">
                        <div class="pt-0.5">
                          <c:choose>
                            <c:when test="${todo.status == 'Completed'}">
                              <i class="bi bi-check-circle-fill text-success fs-5"></i>
                            </c:when>
                            <c:when test="${todo.status == 'Cancelled'}">
                              <i class="bi bi-x-circle-fill text-danger fs-5"></i>
                            </c:when>
                            <c:otherwise>
                              <i class="bi bi-circle text-warning fs-5"></i>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <div>
                          <div class="todo-title">
                            <c:out value="${todo.serviceName}" />
                            <c:if test="${todo.orderId == order.orderId}">
                              <span class="badge bg-teal text-white ms-1" style="font-size: 10px; font-weight: 500;">Đang chọn</span>
                            </c:if>
                          </div>
                          <div class="todo-subtitle">
                            <span class="text-teal fw-semibold">
                              <fmt:formatNumber value="${todo.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                            <span class="mx-1">•</span>
                            <i class="bi bi-door-open me-0.5"></i><c:out value="${todo.roomName != null ? todo.roomName : 'P. Cận lâm sàng'}" />
                          </div>
                        </div>
                      </div>

                      <div>
                        <c:choose>
                          <c:when test="${todo.status == 'Completed'}">
                            <span class="badge-status-completed"><i class="bi bi-check2"></i>Đã xong</span>
                          </c:when>
                          <c:when test="${todo.status == 'Cancelled'}">
                            <span class="badge-status-cancelled"><i class="bi bi-x"></i>Đã hủy</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge-status-pending"><i class="bi bi-hourglass-split"></i>Chờ làm</span>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </a>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

        </div>

        <!-- ==================================================== -->
        <!-- CỘT PHẢI (COL-LG-7): EXECUTION & UPDATE STATUS       -->
        <!-- ==================================================== -->
        <div class="col-lg-7">
          
          <!-- Thông tin tóm tắt Bệnh nhân -->
          <div class="patient-chip mb-4 d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div class="d-flex align-items-center gap-3">
              <div class="rounded-circle bg-teal text-white fw-bold d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; font-size: 18px;">
                ${order.patientName != null && order.patientName.length() > 0 ? order.patientName.substring(0, 1).toUpperCase() : 'B'}
              </div>
              <div>
                <div class="fw-bold text-dark fs-6"><c:out value="${order.patientName}" /></div>
                <div class="small text-muted">
                  <span>Mã BN: <strong>#BN-${order.patientId}</strong></span>
                  <span class="mx-1.5">•</span>
                  <span>NS: <fmt:formatDate value="${order.patientDob}" pattern="dd/MM/yyyy" /> (${order.patientAge} tuổi)</span>
                  <span class="mx-1.5">•</span>
                  <span><i class="bi bi-telephone me-0.5"></i>${order.patientPhone}</span>
                </div>
              </div>
            </div>

            <div>
              <c:choose>
                <c:when test="${order.status == 'Completed'}">
                  <span class="badge-status-completed fs-6 py-1 px-3">
                    <i class="bi bi-check-circle-fill"></i> Đã hoàn thành
                  </span>
                </c:when>
                <c:when test="${order.status == 'Cancelled'}">
                  <span class="badge-status-cancelled fs-6 py-1 px-3">
                    <i class="bi bi-x-circle-fill"></i> Đã hủy
                  </span>
                </c:when>
                <c:otherwise>
                  <span class="badge-status-pending fs-6 py-1 px-3">
                    <i class="bi bi-hourglass-split"></i> Chờ thực hiện
                  </span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>

          <!-- FEATURE 3: UPDATE PROCEDURE STATUS & GHI NHẬN KẾT QUẢ -->
          <div class="custom-card execution-card">
            <div class="card-header-clean bg-light">
              <div>
                <div class="text-uppercase text-teal fw-bold" style="font-size: 11px; letter-spacing: 0.5px;">Thực hiện thủ thuật</div>
                <h5 class="fw-bold text-dark mb-0"><c:out value="${order.serviceName}" /></h5>
              </div>
              <div class="text-end">
                <div class="text-muted small">Phí dịch vụ:</div>
                <div class="fw-bold text-teal fs-6">
                  <fmt:formatNumber value="${order.servicePrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </div>
              </div>
            </div>

            <div class="p-4">
              
              <c:if test="${order.status == 'Completed'}">
                <div class="alert alert-success border-0 bg-success-subtle text-success-emphasis rounded-3 p-3 mb-4 d-flex align-items-center gap-2">
                  <i class="bi bi-check-circle-fill fs-4"></i>
                  <div>
                    <strong>Thủ thuật này đã được hoàn tất!</strong>
                    <div class="small">KTV thực hiện: <strong><c:out value="${order.specialistName != null ? order.specialistName : 'Kỹ thuật viên'}" /></strong>. Bạn vẫn có thể cập nhật lại kết quả bên dưới nếu cần bổ sung.</div>
                  </div>
                </div>
              </c:if>

              <!-- FORM GHI NHẬN KẾT QUẢ & CẬP NHẬT TRẠNG THÁI -->
              <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST">
                <input type="hidden" name="orderId" value="${order.orderId}">

                <!-- 1. Kết quả cận lâm sàng / đo đạc -->
                <div class="mb-4">
                  <label for="examinationResult" class="form-label fw-bold text-dark d-flex align-items-center justify-content-between">
                    <span>
                      <i class="bi bi-clipboard2-data text-teal me-1.5"></i>
                      Kết quả cận lâm sàng / Thông số kỹ thuật
                    </span>
                    <span class="badge bg-light text-muted border fw-normal" style="font-size: 11px;">Mắt Trái (OS) / Mắt Phải (OD)</span>
                  </label>
                  <textarea class="form-control result-textarea p-3" 
                            id="examinationResult" 
                            name="examinationResult" 
                            rows="6" 
                            placeholder="Nhập chi tiết thông số đo đạc hoặc mô tả kết quả hình ảnh...
Ví dụ:
- Mắt phải (OD): Thị lực 10/10, nhãn áp 16 mmHg, gai thị hồng rõ.
- Mắt trái (OS): Thị lực 3/10, nhãn áp 18 mmHg, hình ảnh OCT cho thấy thoái hóa hoàng điểm nhẹ.">${not empty record.examinationResult ? record.examinationResult : ''}</textarea>
                  <div class="form-text small text-muted">
                    <i class="bi bi-info-circle me-1"></i>Ghi nhận các chỉ số máy đo, tình trạng giác mạc, võng mạc hoặc kết quả siêu âm/chụp đáy mắt.
                  </div>
                </div>

                <!-- 2. Kết luận / Ghi chú của KTV -->
                <div class="mb-4">
                  <label for="conclusion" class="form-label fw-bold text-dark">
                    <i class="bi bi-chat-left-text text-teal me-1.5"></i>
                    Kết luận kỹ thuật & Ghi chú trả về cho Bác sĩ
                  </label>
                  <textarea class="form-control result-textarea p-3" 
                            id="conclusion" 
                            name="conclusion" 
                            rows="3" 
                            placeholder="Ví dụ: Đáy mắt bình thường / Nghi ngờ tổn thương hoàng điểm chu biên, đề nghị Bác sĩ kiểm tra chuyên sâu...">${not empty record.conclusion ? record.conclusion : ''}</textarea>
                </div>

                <!-- 3. Action Buttons cập nhật trạng thái -->
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-3 border-top">
                  <div>
                    <c:if test="${order.status == 'Pending'}">
                      <button type="button" class="btn btn-outline-danger rounded-pill px-3 py-2 btn-sm fw-semibold" data-bs-toggle="modal" data-bs-target="#cancelModal">
                        <i class="bi bi-x-circle me-1"></i>Hủy ca chỉ định
                      </button>
                    </c:if>
                  </div>

                  <div class="d-flex align-items-center gap-2">
                    <c:choose>
                      <c:when test="${order.status == 'Pending'}">
                        <button type="submit" name="action" value="complete" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-2">
                          <i class="bi bi-check2-circle fs-5"></i>
                          <span>Hoàn thành thủ thuật & Trả kết quả</span>
                        </button>
                      </c:when>
                      <c:otherwise>
                        <button type="submit" name="action" value="updateResults" class="btn btn-teal rounded-pill px-4 py-2 shadow-sm d-inline-flex align-items-center gap-1.5">
                          <i class="bi bi-save"></i>
                          <span>Lưu cập nhật kết quả</span>
                        </button>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>

              </form>
            </div>
          </div>

        </div>

      </div>

    </main>
  </div>

  <!-- Modal Xác nhận Hủy ca thủ thuật -->
  <div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content rounded-4 border-0 shadow">
        <div class="modal-header border-bottom-0 pb-0">
          <h5 class="modal-title fw-bold text-danger" id="cancelModalLabel">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>Xác nhận hủy ca thủ thuật
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body py-3">
          Bạn có chắc chắn muốn hủy ca chỉ định <strong>#CD-${order.orderId}</strong> (<c:out value="${order.serviceName}" />) của bệnh nhân <strong><c:out value="${order.patientName}" /></strong> không?
          <div class="alert alert-warning mt-3 small mb-0">
            <i class="bi bi-info-circle me-1"></i>Ca bị hủy sẽ không thể tiếp tục thực hiện và Bác sĩ sẽ nhận được trạng thái đã hủy.
          </div>
        </div>
        <div class="modal-footer border-top-0 pt-0">
          <form action="${pageContext.request.contextPath}/specialist/procedure-detail" method="POST">
            <input type="hidden" name="orderId" value="${order.orderId}">
            <input type="hidden" name="action" value="cancel">
            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
            <button type="submit" class="btn btn-danger rounded-pill px-4">Đồng ý Hủy ca</button>
          </form>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap 5 Bundle JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
