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

          .config-select-box {
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            font-size: 15px;
            font-weight: 600;
            color: #0f172a;
            border-radius: 10px;
            padding: 9px 16px;
            min-width: 260px;
            cursor: pointer;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            transition: all 0.2s ease;
          }

          .config-select-box:focus {
            border-color: #18a05e;
            box-shadow: 0 0 0 3px rgba(24, 160, 94, 0.15);
            outline: none;
          }

          .config-tab-btn {
            border: 1px solid #e2e8f0;
            background: #fff;
            color: #475569;
            padding: 8px 18px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
          }

          .config-tab-btn:hover {
            background: #f1f5f9;
            color: #0f172a;
          }

          .config-tab-btn.active {
            background: #18a05e;
            color: #fff;
            border-color: #18a05e;
            box-shadow: 0 3px 10px rgba(24, 160, 94, 0.25);
          }
        </style>
      </head>

      <body>
        <c:set var="currentTab" value="${empty param.tab ? 'rooms' : param.tab}" />
        <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
          <jsp:param name="activeNav" value="clinic-config" />
          <jsp:param name="activeSub" value="${currentTab}" />
        </jsp:include>
        <main class="main-wrapper">
          <jsp:include page="/views/admin/layout/admin-header.jsp" />
          <div class="page-content">
            <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-3">
              <div class="page-title">
                <c:choose>
                  <c:when test="${currentTab == 'slots'}">
                    <h2>Cấu hình Khung Giờ Khám</h2>
                    <p class="text-muted">Quản lý các ca khám bệnh và thời gian làm việc trong ngày</p>
                  </c:when>
                  <c:when test="${currentTab == 'intro'}">
                    <h2>Cấu hình Giới thiệu Phòng Khám</h2>
                    <p class="text-muted">Quản lý và thay đổi 8 hình ảnh giới thiệu phòng khám hiển thị trên trang chủ</p>
                  </c:when>
                  <c:otherwise>
                    <h2>Cấu hình Phòng Khám</h2>
                    <p class="text-muted">Quản lý danh sách phòng khám và phân công nhân sự phụ trách</p>
                  </c:otherwise>
                </c:choose>
              </div>

            </div>

            <!-- Tab Navigation Buttons for Quick Switching -->
            <div class="d-flex flex-wrap gap-2 mb-4">
              <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=rooms" class="config-tab-btn ${currentTab == 'rooms' || (currentTab != 'slots' && currentTab != 'intro') ? 'active' : ''}">
                <i class="bi bi-door-open"></i> Cấu hình phòng
              </a>
              <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=slots" class="config-tab-btn ${currentTab == 'slots' ? 'active' : ''}">
                <i class="bi bi-clock-history"></i> Cấu hình khung giờ khám
              </a>
              <a href="${pageContext.request.contextPath}/admin/clinic-config?tab=intro" class="config-tab-btn ${currentTab == 'intro' ? 'active' : ''}">
                <i class="bi bi-images"></i> Cấu hình giới thiệu
              </a>
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
              <c:if test="${currentTab == 'rooms' || (currentTab != 'slots' && currentTab != 'intro')}">
              <!-- Clinic Rooms Screen -->
              <div class="col-lg-12">
                <div class="admin-card">
                  <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0 fw-bold"><i class="bi bi-door-open me-2 text-primary"></i>Danh sách Phòng Khám</h5>
                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal"><i
                        class="bi bi-plus"></i> Thêm phòng</button>
                  </div>
                  <div class="table-responsive">
                    <table class="table align-middle table-custom">
                      <thead>
                        <tr>
                          <th>Số phòng</th>
                          <th>Tên phòng</th>
                          <th>Người phụ trách</th>
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
                                                 <form action="${pageContext.request.contextPath}/admin/room-config" method="post">
                                  <input type="hidden" name="action" value="edit">
                                  <input type="hidden" name="roomId" value="${room.id}">
                                  <input type="hidden" name="tab" value="rooms">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary">Sửa Tên Phòng Khám</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                  </div>
                                  <div class="modal-body p-4">
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Tên phòng</label>
                                      <input type="text" name="roomName" class="form-control" value="${room.name}"
                                        required oninput="checkRoomTypeForEdit(this, ${room.id})">
                                    </div>
                                    <c:set var="lowerRoomName" value="${fn:toLowerCase(room.name)}" />
                                    <c:set var="isSurgery"
                                      value="${fn:contains(lowerRoomName, 'tiểu phẫu') || fn:contains(lowerRoomName, 'điều trị')}" />

                                    <div id="docDivEdit${room.id}" class="mb-3"
                                      style="display: ${isSurgery ? 'none' : 'block'};">
                                      <label class="form-label fw-semibold">Người phụ trách (Bác sĩ)</label>
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
                                      <label class="form-label fw-semibold">Người phụ trách (Chuyên viên y tế)</label>
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
                                  <input type="hidden" name="tab" value="rooms">
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
              </c:if>

              <c:if test="${currentTab == 'slots'}">
              <!-- Appointment Time Slots Screen -->
              <div class="col-lg-12">
                <div class="admin-card">
                  <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Cấu hình Khung giờ khám</h5>
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
              </c:if>

              <c:if test="${currentTab == 'intro'}">
              <!-- Clinic Introduction / Gallery Configuration Screen (Full CRUD) -->
              <div class="col-lg-12">
                <div class="admin-card">
                  <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                    <div>
                      <h5 class="mb-1 fw-bold"><i class="bi bi-images me-2 text-primary"></i>Danh sách Hình ảnh Giới thiệu Phòng Khám</h5>
                      <p class="text-muted small mb-0">Quản lý toàn diện các hình ảnh giới thiệu (Thêm, Xem, Sửa, Xóa ảnh) hiển thị trực tiếp trên trang chủ.</p>
                    </div>
                    <div>
                      <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addGalleryModal">
                        <i class="bi bi-plus-lg me-1"></i> Thêm hình ảnh
                      </button>
                    </div>
                  </div>

                  <c:choose>
                    <c:when test="${empty galleryItems}">
                      <div class="text-center py-5">
                        <i class="bi bi-image text-muted" style="font-size: 3rem;"></i>
                        <p class="text-muted mt-2">Chưa có hình ảnh giới thiệu nào.</p>
                        <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addGalleryModal">
                          <i class="bi bi-plus-lg me-1"></i> Thêm ảnh đầu tiên
                        </button>
                      </div>
                    </c:when>
                    <c:otherwise>
                      <div class="row g-4">
                        <c:forEach var="item" items="${galleryItems}">
                          <div class="col-sm-6 col-lg-4 col-xl-3">
                            <div class="card h-100 border rounded-3 overflow-hidden shadow-sm d-flex flex-column" style="transition: transform 0.2s, box-shadow 0.2s;">
                              <div class="position-relative" style="height: 190px; background-color: #f1f5f9; overflow: hidden;">
                                <img src="${pageContext.request.contextPath}/clinic-gallery-image?id=${item.id}&t=${not empty item.updatedAt ? item.updatedAt : '0'}" 
                                     alt="${item.title}" 
                                     class="w-100 h-100 object-fit-cover"
                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/img/gallery/${not empty item.defaultFilename ? item.defaultFilename : 'gallery-1.jpg'}';">
                                <span class="position-absolute top-0 start-0 m-2 badge ${item.hasCustomImage ? 'bg-success' : 'bg-secondary'} shadow-sm">
                                  <i class="bi ${item.hasCustomImage ? 'bi-check-circle' : 'bi-image'} me-1"></i>
                                  #${item.id} (Thứ tự: ${item.displayOrder})
                                </span>
                              </div>
                              <div class="card-body p-3 d-flex flex-column justify-content-between flex-grow-1">
                                <div>
                                  <h6 class="fw-bold mb-1 text-truncate" title="${item.title}">${item.title}</h6>
                                  <p class="text-muted small mb-3" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 38px;">
                                    ${empty item.description ? 'Hình ảnh giới thiệu cơ sở vật chất phòng khám VisionCare.' : item.description}
                                  </p>
                                </div>
                                <div class="pt-2 border-top d-flex gap-2">
                                  <button type="button" class="btn btn-sm btn-outline-primary flex-grow-1" data-bs-toggle="modal" data-bs-target="#editGalleryModal${item.id}">
                                    <i class="bi bi-pencil me-1"></i> Sửa
                                  </button>
                                  <button type="button" class="btn btn-sm btn-outline-danger" data-bs-toggle="modal" data-bs-target="#deleteGalleryModal${item.id}" title="Xóa hình ảnh này">
                                    <i class="bi bi-trash"></i>
                                  </button>
                                  <c:if test="${item.hasCustomImage && not empty item.defaultFilename}">
                                    <button type="button" class="btn btn-sm btn-outline-warning" data-bs-toggle="modal" data-bs-target="#resetGalleryModal${item.id}" title="Khôi phục ảnh gốc mặc định">
                                      <i class="bi bi-arrow-counterclockwise"></i>
                                    </button>
                                  </c:if>
                                </div>
                              </div>
                            </div>
                          </div>

                          <!-- Edit Gallery Modal -->
                          <div class="modal fade" id="editGalleryModal${item.id}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                              <div class="modal-content border-0 shadow">
                                <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post" enctype="multipart/form-data">
                                  <input type="hidden" name="action" value="update">
                                  <input type="hidden" name="itemId" value="${item.id}">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-primary"><i class="bi bi-pencil-square me-2"></i>Chỉnh sửa Hình ảnh #${item.id}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                  </div>
                                  <div class="modal-body p-4">
                                    <div class="mb-3 text-center">
                                      <label class="form-label d-block text-start fw-semibold">Ảnh hiện tại:</label>
                                      <img id="previewImg${item.id}" 
                                           src="${pageContext.request.contextPath}/clinic-gallery-image?id=${item.id}&t=${not empty item.updatedAt ? item.updatedAt : '0'}" 
                                           alt="${item.title}" 
                                           class="img-thumbnail rounded shadow-sm w-100" 
                                           style="max-height: 200px; object-fit: cover;"
                                           onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/img/gallery/${not empty item.defaultFilename ? item.defaultFilename : 'gallery-1.jpg'}';">
                                    </div>
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Chọn ảnh mới để thay thế (Tùy chọn)</label>
                                      <input type="file" name="imageFile" class="form-control" accept="image/*" 
                                             onchange="previewGalleryImage(this, 'previewImg${item.id}')">
                                      <div class="form-text small text-muted">Hỗ trợ JPG, PNG, WEBP (tối đa 10MB). Giữ trống nếu không muốn đổi file ảnh.</div>
                                    </div>
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Tiêu đề ảnh <span class="text-danger">*</span></label>
                                      <input type="text" name="title" class="form-control" value="${item.title}" required placeholder="VD: Phòng khám mắt hiện đại">
                                    </div>
                                    <div class="row mb-3">
                                      <div class="col-6">
                                        <label class="form-label fw-semibold">Thứ tự hiển thị</label>
                                        <input type="number" name="displayOrder" class="form-control" value="${item.displayOrder}" min="1">
                                      </div>
                                    </div>
                                    <div class="mb-3">
                                      <label class="form-label fw-semibold">Mô tả ngắn</label>
                                      <textarea name="description" class="form-control" rows="2" placeholder="VD: Trang thiết bị nhãn khoa tiên tiến...">${item.description}</textarea>
                                    </div>
                                  </div>
                                  <div class="modal-footer border-0 pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary px-4 rounded-pill"><i class="bi bi-cloud-upload me-1"></i> Lưu thay đổi</button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>

                          <!-- Delete Gallery Modal -->
                          <div class="modal fade" id="deleteGalleryModal${item.id}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                              <div class="modal-content border-0 shadow">
                                <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post">
                                  <input type="hidden" name="action" value="delete">
                                  <input type="hidden" name="itemId" value="${item.id}">
                                  <div class="modal-header border-0 pb-0">
                                    <h5 class="modal-title fw-bold text-danger"><i class="bi bi-trash me-2"></i>Xác nhận Xóa Hình ảnh</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                  </div>
                                  <div class="modal-body p-4 text-center">
                                    <p class="mb-2 fs-6">Bạn có chắc chắn muốn xóa hình ảnh <strong>${item.title}</strong> (Mã #${item.id}) không?</p>
                                    <p class="text-muted small mb-0">Hành động này sẽ xóa vĩnh viễn hình ảnh này khỏi hệ thống.</p>
                                  </div>
                                  <div class="modal-footer border-0 justify-content-center pt-0">
                                    <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-danger px-4 rounded-pill">Xóa hình ảnh</button>
                                  </div>
                                </form>
                              </div>
                            </div>
                          </div>

                          <!-- Reset Gallery Modal -->
                          <c:if test="${item.hasCustomImage && not empty item.defaultFilename}">
                            <div class="modal fade" id="resetGalleryModal${item.id}" tabindex="-1" aria-hidden="true">
                              <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content border-0 shadow">
                                  <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post">
                                    <input type="hidden" name="action" value="reset">
                                    <input type="hidden" name="itemId" value="${item.id}">
                                    <div class="modal-header border-0 pb-0">
                                      <h5 class="modal-title fw-bold text-warning"><i class="bi bi-arrow-counterclockwise me-2"></i>Đặt lại ảnh mặc định</h5>
                                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body p-4 text-center">
                                      <p class="mb-2">Bạn có chắc chắn muốn đặt lại hình ảnh vị trí <strong>#${item.id}</strong> về ảnh mặc định ban đầu?</p>
                                      <p class="text-muted small mb-0">Hệ thống sẽ xóa ảnh đã tải lên và khôi phục hiển thị file gốc (${item.defaultFilename}).</p>
                                    </div>
                                    <div class="modal-footer border-0 justify-content-center pt-0">
                                      <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                                      <button type="submit" class="btn btn-warning px-4 rounded-pill text-white">Xác nhận đặt lại</button>
                                    </div>
                                  </form>
                                </div>
                              </div>
                            </div>
                          </c:if>
                        </c:forEach>
                      </div>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
              </c:if>

              <!-- Add Gallery Item Modal -->
              <div class="modal fade" id="addGalleryModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content border-0 shadow">
                    <form action="${pageContext.request.contextPath}/admin/clinic-intro-config" method="post" enctype="multipart/form-data">
                      <input type="hidden" name="action" value="add">
                      <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold text-primary"><i class="bi bi-plus-circle me-2"></i>Thêm Hình ảnh Giới thiệu Mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                      </div>
                      <div class="modal-body p-4">
                        <div class="mb-3 text-center">
                          <img id="previewImgAdd" src="" alt="Xem trước ảnh" 
                               class="img-thumbnail rounded shadow-sm w-100" 
                               style="max-height: 200px; object-fit: cover; display: none;">
                        </div>
                        <div class="mb-3">
                          <label class="form-label fw-semibold">Chọn tệp hình ảnh <span class="text-danger">*</span></label>
                          <input type="file" name="imageFile" class="form-control" accept="image/*" required
                                 onchange="previewGalleryImage(this, 'previewImgAdd'); document.getElementById('previewImgAdd').style.display='block';">
                          <div class="form-text small text-muted">Hỗ trợ định dạng JPG, PNG, WEBP (tối đa 10MB).</div>
                        </div>
                        <div class="mb-3">
                          <label class="form-label fw-semibold">Tiêu đề ảnh <span class="text-danger">*</span></label>
                          <input type="text" name="title" class="form-control" required placeholder="VD: Phòng phẫu thuật Lasik hiện đại">
                        </div>
                        <div class="row mb-3">
                          <div class="col-6">
                            <label class="form-label fw-semibold">Thứ tự hiển thị</label>
                            <input type="number" name="displayOrder" class="form-control" value="${fn:length(galleryItems) + 1}" min="1">
                          </div>
                        </div>
                        <div class="mb-3">
                          <label class="form-label fw-semibold">Mô tả ngắn</label>
                          <textarea name="description" class="form-control" rows="2" placeholder="VD: Trang thiết bị nhãn khoa tiên tiến..."></textarea>
                        </div>
                      </div>
                      <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary px-4 rounded-pill"><i class="bi bi-check-lg me-1"></i> Thêm ảnh</button>
                      </div>
                    </form>
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
                    <input type="hidden" name="tab" value="rooms">
                    <div class="modal-header border-0 pb-0">
                      <h5 class="modal-title fw-bold text-primary">Thêm Phòng Khám Mới</h5>
                      <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                      <div class="mb-3">
                        <label class="form-label fw-semibold">Tên phòng</label>
                        <input type="text" name="roomName" class="form-control" required
                          placeholder="VD: Phòng Khám 102" oninput="checkRoomTypeForAdd(this)">
                      </div>
                      <div id="docDivAdd" class="mb-3" style="display: block;">
                        <label class="form-label fw-semibold">Người phụ trách - Bác sĩ (Tùy chọn)</label>
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
                        <label class="form-label fw-semibold">Người phụ trách - Chuyên viên y tế (Tùy chọn)</label>
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

          function previewGalleryImage(input, imgId) {
            if (input.files && input.files[0]) {
              const reader = new FileReader();
              reader.onload = function(e) {
                const target = document.getElementById(imgId);
                if (target) {
                  target.src = e.target.result;
                }
              };
              reader.readAsDataURL(input.files[0]);
            }
          }
        </script>
      </body>

      </html>