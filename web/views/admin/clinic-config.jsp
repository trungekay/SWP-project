<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

      <!DOCTYPE html>
      <html lang="vi">

      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cấu hình Phòng Khám - VisionCare Admin</title>
        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

        <!-- Vendor CSS Files (from header.jsp) -->
        <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css"
          rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/aos/aos.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">

        <!-- Main CSS File -->
        <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">

        <jsp:include page="/views/admin/layout/admin-css.jsp" />
        <style>
          .admin-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 24px;
          }

          /* Modern Premium Table Styling with Borders */
          .table-custom {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #cbd5e1;
            /* Visible outer border */
          }

          .table-custom thead {
            background-color: #f0fdf4;
            /* Modern subtle green */
          }

          .table-custom thead th {
            color: #15803d;
            /* Crisp green text */
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 24px;
            border-bottom: 2px solid #dcfce7;
            border-right: 1px solid #dcfce7;
            /* Vertical divider */
            border-top: none;
          }

          .table-custom thead th:last-child {
            border-right: none;
          }

          .table-custom tbody td {
            padding: 18px 24px;
            vertical-align: middle;
            color: #334155;
            font-size: 15px;
            font-weight: 500;
            border-bottom: 1px solid #f1f5f9;
            border-right: 1px solid #f1f5f9;
            /* Vertical divider */
          }

          .table-custom tbody td:last-child {
            border-right: none;
          }

          .table-custom tbody tr:last-child td {
            border-bottom: none;
          }

          .table-custom tbody tr {
            transition: all 0.2s ease;
          }

          .table-custom tbody tr:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(24, 160, 94, 0.3);
            position: relative;
            z-index: 1;
          }

          /* Bootstrap 5 applies background to td, so we must change td background on hover */
          .table-custom tbody tr:hover td {
            background-color: #ffffff !important;
            /* Logo green */
            color: #12824b !important;
            border-bottom-color: #ffffff !important;
            border-right-color: #ffffff !important;
          }

          /* Ensure bold text turns white */
          .table-custom tbody tr:hover td strong {
            color: #12824b !important;
          }

          /* Adjust outline buttons to be visible on green background */
          .table-custom tbody tr:hover .btn-outline-primary {
            color: #ffffff !important;
            border-color: #ffffff !important;
          }

          .table-custom tbody tr:hover .btn-outline-primary:hover {
            background-color: #ffffff !important;
            color: #18a05e !important;
          }

          /* Add a small white border to badges so they don't blend in */
          .table-custom tbody tr:hover .badge {
            box-shadow: 0 0 0 1px #ffffff;
          }

          .table-custom .badge {
            padding: 8px 12px;
            font-weight: 600;
            letter-spacing: 0.3px;
            border-radius: 6px;
          }

          /* Override Primary Colors to Logo Green */
          .btn-primary {
            background-color: #18a05e !important;
            border-color: #18a05e !important;
            color: #fff !important;
          }

          .btn-primary:hover,
          .btn-primary:focus,
          .btn-primary:active {
            background-color: #12824b !important;
            border-color: #12824b !important;
            color: #fff !important;
            box-shadow: 0 4px 12px rgba(24, 160, 94, 0.3) !important;
          }

          .btn-outline-primary {
            color: #18a05e !important;
            border-color: #18a05e !important;
          }

          .btn-outline-primary:hover,
          .btn-outline-primary:focus,
          .btn-outline-primary:active {
            background-color: #18a05e !important;
            border-color: #18a05e !important;
            color: #fff !important;
          }

          .text-primary {
            color: #18a05e !important;
          }

          .bg-primary {
            background-color: #18a05e !important;
          }
        </style>
      </head>

      <body>
        <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
          <jsp:param name="activeNav" value="clinic-config" />
        </jsp:include>
        <main class="main-wrapper">
          <jsp:include page="/views/admin/layout/admin-header.jsp" />
          <div class="page-content">
            <div class="page-header">
              <div class="page-title">
                <h2>Cấu hình Phòng Khám</h2>
                <p>Cấu hình phòng khám và khung giờ</p>
              </div>
            </div>

            <c:if test="${not empty sessionScope.errorMsg}">
              <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>${sessionScope.errorMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
              </div>
              <c:remove var="errorMsg" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.successMsg}">
              <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>${sessionScope.successMsg}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
              </div>
              <c:remove var="successMsg" scope="session" />
            </c:if>

            <div class="row g-4">
              <!-- Clinic Rooms -->
              <div class="col-lg-12">
                <div class="admin-card">
                  <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0">Danh sách Phòng Khám</h5>
                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal"><i
                        class="bi bi-plus"></i> Thêm phòng</button>
                  </div>
                  <div class="table-responsive">
                    <table class="table align-middle table-custom">
                      <thead>
                        <tr>
                          <th>Số phòng</th>
                          <th>Loại phòng</th>
                          <th>Người trực</th>
                          <th class="text-end">Thao tác</th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach var="room" items="${rooms}">
                          <tr>
                            <td>P${room.id}</td>
                            <td><strong>${room.name}</strong></td>
                            <td>
                              <c:set var="assignedDoctor" value="" />
                              <c:set var="assignedSpecialist" value="" />
                              <c:forEach var="doc" items="${doctors}">
                                <c:if test="${doc.roomId == room.id}">
                                  <c:set var="assignedDoctor" value="${doc}" />
                                </c:if>
                              </c:forEach>
                              <c:forEach var="spec" items="${specialists}">
                                <c:if test="${spec.roomId == room.id}">
                                  <c:set var="assignedSpecialist" value="${spec}" />
                                </c:if>
                              </c:forEach>

                              <c:choose>
                                <c:when test="${not empty assignedDoctor}">
                                  <span class="badge bg-primary" style="font-size: 0.9em;"><i
                                      class="bi bi-person-badge"></i> ${assignedDoctor.name}</span>
                                </c:when>
                                <c:when test="${not empty assignedSpecialist}">
                                  <span class="badge bg-info text-dark" style="font-size: 0.9em;"><i
                                      class="bi bi-person-workspace"></i> ${assignedSpecialist.name}</span>
                                </c:when>
                                <c:otherwise>
                                  <span class="badge bg-secondary" style="font-size: 0.9em;">Chưa phân công</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                            <td class="text-end">
                              <button class="btn btn-sm btn-outline-primary me-1" data-bs-toggle="modal"
                                data-bs-target="#editRoomModal${room.id}" title="Sửa phòng"><i
                                  class="bi bi-pencil"></i></button>
                              <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal"
                                data-bs-target="#deleteRoomModal${room.id}" title="Xóa phòng"><i
                                  class="bi bi-trash"></i></button>
                            </td>
                          </tr>

                          <!-- Edit Room Modal -->
                          <div class="modal fade" id="editRoomModal${room.id}" tabindex="-1">
                            <div class="modal-dialog">
                              <div class="modal-content">
                                <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                  <input type="hidden" name="action" value="edit">
                                  <input type="hidden" name="roomId" value="${room.id}">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary">Sửa Tên Phòng Khám</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                  </div>
                                  <div class="modal-body p-4">
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Loại phòng (Tên phòng)</label>
                                      <input type="text" name="roomName" class="form-control" value="${room.name}"
                                        required oninput="checkRoomTypeForEdit(this, ${room.id})">
                                    </div>
                                    <c:set var="lowerRoomName" value="${fn:toLowerCase(room.name)}" />
                                    <c:set var="isSurgery"
                                      value="${fn:contains(lowerRoomName, 'tiểu phẫu') || fn:contains(lowerRoomName, 'điều trị')}" />

                                    <div id="docDivEdit${room.id}" class="mb-3"
                                      style="display: ${isSurgery ? 'none' : 'block'};">
                                      <label class="form-label fw-semibold">Chỉ định Bác sĩ trực</label>
                                      <select name="doctorId" class="form-select">
                                        <option value="">-- Không có / Bỏ trống --</option>
                                        <c:forEach var="doctor" items="${doctors}">
                                          <c:if
                                            test="${doctor.roomId == room.id || doctor.roomId == 0 || empty doctor.roomId}">
                                            <option value="${doctor.id}" ${doctor.roomId==room.id ? 'selected' : '' }>
                                              ${doctor.name} - ${doctor.specialty}
                                            </option>
                                          </c:if>
                                        </c:forEach>
                                      </select>
                                      <div class="form-text text-muted small">Chỉ phòng khám mắt mới chọn được Bác sĩ.
                                      </div>
                                    </div>

                                    <div id="specDivEdit${room.id}" class="mb-3"
                                      style="display: ${isSurgery ? 'block' : 'none'};">
                                      <label class="form-label fw-semibold">Chỉ định Chuyên viên y tế</label>
                                      <select name="specialistId" class="form-select">
                                        <option value="">-- Không có / Bỏ trống --</option>
                                        <c:forEach var="specialist" items="${specialists}">
                                          <c:if
                                            test="${specialist.roomId == room.id || specialist.roomId == 0 || empty specialist.roomId}">
                                            <option value="${specialist.id}" ${specialist.roomId==room.id ? 'selected'
                                              : '' }>
                                              ${specialist.name} - ${specialist.specialty}
                                            </option>
                                          </c:if>
                                        </c:forEach>
                                      </select>
                                      <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn
                                        được Chuyên viên y tế.</div>
                                    </div>
                                  </div>
                                  <div class="modal-footer border-0 pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                      data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill">Cập nhật</button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>
                          <!-- End Edit Modal -->

                          <!-- Delete Room Modal -->
                          <div class="modal fade" id="deleteRoomModal${room.id}" tabindex="-1">
                            <div class="modal-dialog modal-dialog-centered">
                              <div class="modal-content border-0 shadow">
                                <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                  <input type="hidden" name="action" value="delete">
                                  <input type="hidden" name="roomId" value="${room.id}">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-danger"><i
                                        class="bi bi-exclamation-triangle me-2"></i>Xác nhận Xóa Phòng Khám</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                  </div>
                                  <div class="modal-body p-4 text-center">
                                    <p class="mb-2 fs-6">Bạn có chắc chắn muốn xóa phòng <strong>${room.name}</strong>
                                      không?</p>
                                    <p class="text-muted small mb-0">Hành động này sẽ xóa phòng khỏi hệ thống.</p>
                                  </div>
                                  <div class="modal-footer border-0 justify-content-center pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                      data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-danger px-4 rounded-pill">Xóa phòng</button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>
                          <!-- End Delete Room Modal -->
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <!-- Appointment Time Slots -->
              <div class="col-lg-12 mt-4">
                <div class="admin-card">
                  <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0">Cấu hình Khung giờ khám</h5>
                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addSlotModal"><i
                        class="bi bi-plus"></i> Thêm khung giờ</button>
                  </div>
                  <div class="table-responsive">
                    <table class="table align-middle table-custom">
                      <thead>
                        <tr>
                          <th>Ca</th>
                          <th>Thời gian</th>
                          <th>Trạng thái</th>
                          <th class="text-end">Thao tác</th>
                        </tr>
                      </thead>
                      <tbody>
                        <c:forEach var="slot" items="${timeSlots}" varStatus="statusIdx">
                          <tr>
                            <td>${slot.slotName}</td>
                            <td>${slot.startTime} - ${slot.endTime}</td>
                            <td>
                              <c:choose>
                                <c:when test="${slot.status eq 'Available'}">
                                  <span class="badge bg-success">Hoạt động</span>
                                </c:when>
                                <c:otherwise>
                                  <span class="badge bg-danger">Ngừng hoạt động</span>
                                </c:otherwise>
                              </c:choose>
                            </td>
                            <td class="text-end">
                              <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal"
                                data-bs-target="#editSlotModal${statusIdx.index}"><i class="bi bi-pencil"></i></button>
                            </td>
                          </tr>

                          <!-- Edit Slot Modal -->
                          <div class="modal fade" id="editSlotModal${statusIdx.index}" tabindex="-1">
                            <div class="modal-dialog">
                              <div class="modal-content">
                                <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                                  <input type="hidden" name="action" value="edit">
                                  <input type="hidden" name="oldSlotName" value="${slot.slotName}">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary">Sửa Khung Giờ Khám</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                  </div>
                                  <div class="modal-body p-4">
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Tên ca (Slot Name)</label>
                                      <input type="text" name="slotName" class="form-control" value="${slot.slotName}"
                                        required>
                                    </div>
                                    <div class="row mb-3">
                                      <div class="col-6">
                                        <label class="form-label fw-semibold">Giờ bắt đầu</label>
                                        <input type="time" name="startTime" class="form-control"
                                          value="${slot.startTime}" required>
                                      </div>
                                      <div class="col-6">
                                        <label class="form-label fw-semibold">Giờ kết thúc</label>
                                        <input type="time" name="endTime" class="form-control" value="${slot.endTime}"
                                          required>
                                      </div>
                                    </div>
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Trạng thái</label>
                                      <select name="status" class="form-select" required>
                                        <option value="Available" ${slot.status=='Available' ? 'selected' : '' }>Hoạt
                                          động</option>
                                        <option value="Canceled" ${slot.status !='Available' ? 'selected' : '' }>Ngừng
                                          hoạt động</option>
                                      </select>
                                    </div>
                                  </div>
                                  <div class="modal-footer border-0 pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill"
                                      data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill">Cập nhật</button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>
                          <!-- End Edit Slot Modal -->
                        </c:forEach>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <!-- Add Room Modal -->
            <div class="modal fade" id="addRoomModal" tabindex="-1">
              <div class="modal-dialog">
                <div class="modal-content">
                  <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header border-0 pb-0">
                      <h5 class="modal-title fw-bold text-primary">Thêm Phòng Khám Mới</h5>
                      <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                      <div class="mb-3">
                        <label class="form-label fw-semibold">Tên phòng khám</label>
                        <input type="text" name="roomName" class="form-control" required
                          placeholder="VD: Phòng Khám 102" oninput="checkRoomTypeForAdd(this)">
                      </div>
                      <div id="docDivAdd" class="mb-3" style="display: block;">
                        <label class="form-label fw-semibold">Phân công Bác sĩ trực (Tùy chọn)</label>
                        <select name="doctorId" class="form-select">
                          <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                          <c:forEach var="doctor" items="${doctors}">
                            <c:if test="${doctor.roomId == 0 || empty doctor.roomId}">
                              <option value="${doctor.id}">${doctor.name} - ${doctor.specialty}</option>
                            </c:if>
                          </c:forEach>
                        </select>
                        <div class="form-text text-muted small">Chỉ phòng khám mắt mới chọn được Bác sĩ.</div>
                      </div>
                      <div id="specDivAdd" class="mb-3" style="display: none;">
                        <label class="form-label fw-semibold">Phân công Chuyên viên y tế (Tùy chọn)</label>
                        <select name="specialistId" class="form-select">
                          <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                          <c:forEach var="specialist" items="${specialists}">
                            <c:if test="${specialist.roomId == 0 || empty specialist.roomId}">
                              <option value="${specialist.id}">${specialist.name} - ${specialist.specialty}</option>
                            </c:if>
                          </c:forEach>
                        </select>
                        <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn được Chuyên viên
                          y tế.</div>
                      </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                      <button type="button" class="btn btn-secondary px-4 rounded-pill"
                        data-bs-dismiss="modal">Hủy</button>
                      <button type="submit" class="btn btn-primary px-4 rounded-pill">Thêm phòng</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>

            <!-- Add Time Slot Modal -->
            <div class="modal fade" id="addSlotModal" tabindex="-1">
              <div class="modal-dialog">
                <div class="modal-content">
                  <form action="${pageContext.request.contextPath}/admin/timeslot-config" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header border-0 pb-0">
                      <h5 class="modal-title fw-bold text-primary">Thêm Khung Giờ Khám Mới</h5>
                      <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                      <div class="mb-3">
                        <label class="form-label fw-semibold">Tên ca (Slot Name)</label>
                        <input type="text" name="slotName" class="form-control" required placeholder="VD: Slot 5">
                      </div>
                      <div class="row mb-3">
                        <div class="col-6">
                          <label class="form-label fw-semibold">Giờ bắt đầu</label>
                          <input type="time" name="startTime" class="form-control" required>
                        </div>
                        <div class="col-6">
                          <label class="form-label fw-semibold">Giờ kết thúc</label>
                          <input type="time" name="endTime" class="form-control" required>
                        </div>
                      </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                      <button type="button" class="btn btn-secondary px-4 rounded-pill"
                        data-bs-dismiss="modal">Hủy</button>
                      <button type="submit" class="btn btn-primary px-4 rounded-pill">Thêm khung giờ</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>

          </div>
        </main>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
          function checkRoomTypeForEdit(inputElement, roomId) {
            const val = inputElement.value.toLowerCase();
            const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật') || val.includes('điều trị');
            if (isSurgery) {
              document.getElementById('docDivEdit' + roomId).style.display = 'none';
              document.getElementById('docDivEdit' + roomId).querySelector('select').value = '';
              document.getElementById('specDivEdit' + roomId).style.display = 'block';
            } else {
              document.getElementById('specDivEdit' + roomId).style.display = 'none';
              document.getElementById('specDivEdit' + roomId).querySelector('select').value = '';
              document.getElementById('docDivEdit' + roomId).style.display = 'block';
            }
          }

          function checkRoomTypeForAdd(inputElement) {
            const val = inputElement.value.toLowerCase();
            const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật') || val.includes('điều trị');
            if (isSurgery) {
              document.getElementById('docDivAdd').style.display = 'none';
              document.getElementById('docDivAdd').querySelector('select').value = '';
              document.getElementById('specDivAdd').style.display = 'block';
            } else {
              document.getElementById('specDivAdd').style.display = 'none';
              document.getElementById('specDivAdd').querySelector('select').value = '';
              document.getElementById('docDivAdd').style.display = 'block';
            }
          }
        </script>
      </body>

      </html>