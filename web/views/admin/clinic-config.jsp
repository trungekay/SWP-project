<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Cấu hình Phòng Khám" />
  <jsp:param name="pageDescription" value="Cấu hình phòng khám và khung giờ" />
  <jsp:param name="bodyClass" value="starter-page-page" />
</jsp:include>

  <style>
    .admin-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
    }
  </style>

  <main class="main bg-light pb-5">
    <div class="page-title">
      <div class="container">
        <h2 class="mb-0">Cấu hình Phòng Khám</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="current">Cấu hình</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
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
                      <th>Mã phòng</th>
                      <th>Tên phòng</th>
                      <th>Chức năng</th>
                      <th class="text-end">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                  <c:forEach var="room" items="${rooms}">
                    <tr>
                      <td>P${room.id}</td>
                      <td>${room.name}</td>
                      <td>Khám chuyên khoa</td> <!-- Since room functionality isn't strictly defined in DB, defaulting this text -->
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
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
                  <c:forEach var="slot" items="${timeSlots}">
                    <tr>
                      <td>${slot.slotName}</td>
                      <td>${slot.startTime} - ${slot.endTime}</td>
                      <td><span class="badge bg-success">Hoạt động</span></td>
                      <td class="text-end">
                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i></button>
                      </td>
                    </tr>
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

  </main>

<jsp:include page="/views/common/footer.jsp" />
