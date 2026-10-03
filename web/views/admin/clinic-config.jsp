<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình Phòng Khám - VisionCare Admin</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Admin Layout CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-layout.css" rel="stylesheet">

  <style>
    .admin-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
    }
    .page-content { padding: 30px; }
    .page-title { margin-bottom: 24px; }
    .page-title h2 { font-size: 24px; font-weight: 700; color: #0f172a; margin-bottom: 6px; }
    .breadcrumbs { font-size: 14px; color: #64748b; }
    .breadcrumbs ol { list-style: none; padding: 0; margin: 0; display: flex; gap: 8px; }
    .breadcrumbs ol li.current { color: #0f172a; font-weight: 500; }
    .breadcrumbs ol li a { color: var(--primary-color); text-decoration: none; }
  </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="/views/admin/layout/admin-sidebar.jsp">
        <jsp:param name="activeNav" value="config" />
    </jsp:include>

    <!-- Main Content -->
    <main class="main-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="/views/admin/layout/admin-header.jsp" />

        <div class="page-content bg-light pb-5">
            <div class="page-title">
              <div class="container-fluid px-0">
                <h2 class="mb-0">Cấu hình Phòng Khám</h2>
                <nav class="breadcrumbs mt-2">
                  <ol>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                    <li>/</li>
                    <li class="current">Cấu hình</li>
                  </ol>
                </nav>
              </div>
            </div>

            <section class="section pt-4">
              <div class="container-fluid px-0">
                <div class="row g-4">
          <!-- Clinic Rooms -->
          <div class="col-lg-6">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Danh sách Phòng Khám</h5>
                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal"><i class="bi bi-plus"></i> Thêm phòng</button>
              </div>
              <div class="table-responsive">
                <table class="table table-bordered align-middle">
                  <thead class="table-light">
                    <tr>
                      <th>Số phòng</th>
                      <th>Loại phòng</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                  <c:forEach var="room" items="${rooms}">
                    <tr>
                      <td>P${room.id}</td>
                      <td>${room.name}</td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editRoomModal${room.id}"><i class="bi bi-pencil"></i></button>
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
                                <input type="text" name="roomName" class="form-control" value="${room.name}" required>
                              </div>
                              <div class="mb-3">
                                <label class="form-label fw-semibold">Chỉ định bác sĩ trực</label>
                                <select name="doctorId" class="form-select">
                                  <option value="">-- Không có / Bỏ trống --</option>
                                  <c:forEach var="doctor" items="${doctors}">
                                    <c:if test="${doctor.roomId == room.id || doctor.roomId == 0 || empty doctor.roomId}">
                                      <option value="${doctor.id}" ${doctor.roomId == room.id ? 'selected' : ''}>
                                        ${doctor.name} - ${doctor.specialty}
                                      </option>
                                    </c:if>
                                  </c:forEach>
                                </select>
                                <div class="form-text text-muted small">Chỉ hiển thị bác sĩ đang trực tại phòng này hoặc chưa được phân công.</div>
                              </div>
                            </div>
                            <div class="modal-footer border-0 pt-0">
                              <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
                              <button type="submit" class="btn btn-primary px-4 rounded-pill">Cập nhật</button>
                            </div>
                          </form>
                        </div>
                      </div>
                    </div>
                    <!-- End Edit Modal -->
                  </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Appointment Time Slots -->
          <div class="col-lg-6">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Cấu hình Khung giờ khám</h5>
                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addSlotModal"><i class="bi bi-plus"></i> Thêm khung giờ</button>
              </div>
              <div class="table-responsive">
                <table class="table table-bordered align-middle">
                  <thead class="table-light">
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
                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editSlotModal${statusIdx.index}"><i class="bi bi-pencil"></i></button>
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
                                <input type="text" name="slotName" class="form-control" value="${slot.slotName}" required>
                              </div>
                              <div class="row mb-3">
                                <div class="col-6">
                                  <label class="form-label fw-semibold">Giờ bắt đầu</label>
                                  <input type="time" name="startTime" class="form-control" value="${slot.startTime}" required>
                                </div>
                                <div class="col-6">
                                  <label class="form-label fw-semibold">Giờ kết thúc</label>
                                  <input type="time" name="endTime" class="form-control" value="${slot.endTime}" required>
                                </div>
                              </div>
                              <div class="mb-3">
                                <label class="form-label fw-semibold">Trạng thái</label>
                                <select name="status" class="form-select" required>
                                  <option value="Available" ${slot.status == 'Available' ? 'selected' : ''}>Hoạt động</option>
                                  <option value="Canceled" ${slot.status != 'Available' ? 'selected' : ''}>Ngừng hoạt động</option>
                                </select>
                              </div>
                            </div>
                            <div class="modal-footer border-0 pt-0">
                              <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
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
        
        <!-- Doctor Room Assignment -->
        <div class="row g-4 mt-2">
          <div class="col-12">
            <div class="admin-card">
              <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="mb-0">Phân công Bác sĩ vào Phòng</h5>
              </div>
              <div class="table-responsive">
                <table class="table table-bordered align-middle">
                  <thead class="table-light">
                    <tr>
                      <th>Bác sĩ</th>
                      <th>Chuyên khoa</th>
                      <th>Phòng đang trực</th>
                      <th class="text-end" style="width: 250px;">Thao tác Phân công</th>
                    </tr>
                  </thead>
                  <tbody>
                  <c:forEach var="doctor" items="${doctors}">
                    <tr>
                      <td><strong>${doctor.name}</strong></td>
                      <td>${doctor.specialty}</td>
                      <td>
                        <c:choose>
                          <c:when test="${doctor.roomId > 0}">
                            <span class="badge bg-primary">Phòng ${doctor.roomId}</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge bg-secondary">Chưa phân công</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">
                        <form action="${pageContext.request.contextPath}/admin/room-config" method="post" class="d-flex gap-2 justify-content-end">
                          <input type="hidden" name="action" value="assign_doctor">
                          <input type="hidden" name="doctorId" value="${doctor.id}">
                          <select name="roomId" class="form-select form-select-sm" style="width: auto;">
                            <option value="0">-- Chọn phòng --</option>
                            <c:forEach var="room" items="${rooms}">
                              <option value="${room.id}" ${doctor.roomId == room.id ? 'selected' : ''}>P${room.id} - ${room.name}</option>
                            </c:forEach>
                          </select>
                          <button type="submit" class="btn btn-sm btn-success">Lưu</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

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
                <input type="text" name="roomName" class="form-control" required placeholder="VD: Phòng Khám 102">
              </div>
              <div class="mb-3">
                <label class="form-label fw-semibold">Phân công bác sĩ trực (Tùy chọn)</label>
                <select name="doctorId" class="form-select">
                  <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                  <c:forEach var="doctor" items="${doctors}">
                    <c:if test="${doctor.roomId == 0 || empty doctor.roomId}">
                      <option value="${doctor.id}">${doctor.name} - ${doctor.specialty}</option>
                    </c:if>
                  </c:forEach>
                </select>
                <div class="form-text text-muted small">Chỉ hiển thị các bác sĩ chưa được phân công phòng nào.</div>
              </div>
            </div>
            <div class="modal-footer border-0 pt-0">
              <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
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
                <label class="form-label fw-semibold">Ngày làm việc</label>
                <input type="date" name="workDate" class="form-control" required>
              </div>
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
              <div class="mb-3">
                <label class="form-label fw-semibold">Buổi (Session)</label>
                <select name="session" class="form-select" required>
                  <option value="Morning">Buổi Sáng</option>
                  <option value="Afternoon">Buổi Chiều</option>
                  <option value="Evening">Buổi Tối</option>
                </select>
              </div>
            </div>
            <div class="modal-footer border-0 pt-0">
              <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Hủy</button>
              <button type="submit" class="btn btn-primary px-4 rounded-pill">Thêm khung giờ</button>
            </div>
          </form>
        </div>
      </div>
    </div>

              </div>
            </section>
        </div>
    </main>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
