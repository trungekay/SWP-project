import re

with open('web/views/admin/clinic-config.jsp', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add taglib fn
content = content.replace('<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>', '<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>\n<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>')

# 2. Add custom CSS for tables
css_addition = """
        .admin-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            padding: 24px;
        }
        .table-custom thead {
            background-color: #0d6efd;
            color: #fff;
        }
        .table-custom thead th {
            color: #fff;
            font-weight: 600;
            border-bottom: 2px solid #0a58ca;
        }
        .table-custom tbody tr:hover {
            background-color: #f8f9fa;
        }
"""
content = content.replace('.admin-card {\n            background: #fff;\n            border-radius: 12px;\n            box-shadow: 0 4px 20px rgba(0,0,0,0.05);\n            padding: 24px;\n        }', css_addition.strip())

# 3. Modify Room Table Header
content = content.replace('<thead class="table-light">', '<thead class="table-custom">')

room_header_old = """                    <tr>
                      <th>Số phòng</th>
                      <th>Loại phòng</th>
                      <th class="text-end">Thao tác</th>
                    </tr>"""
room_header_new = """                    <tr>
                      <th>Số phòng</th>
                      <th>Loại phòng</th>
                      <th>Người trực</th>
                      <th class="text-end">Thao tác</th>
                    </tr>"""
content = content.replace(room_header_old, room_header_new)

# 4. Modify Room Table Row
room_row_old = """                      <td>P${room.id}</td>
                      <td>${room.name}</td>
                      <td class="text-end">"""
room_row_new = """                      <td>P${room.id}</td>
                      <td><strong>${room.name}</strong></td>
                      <td>
                        <c:set var="assignedDoctor" value="" />
                        <c:set var="assignedSpecialist" value="" />
                        <c:forEach var="doc" items="${doctors}">
                            <c:if test="${doc.roomId == room.id}"><c:set var="assignedDoctor" value="${doc}" /></c:if>
                        </c:forEach>
                        <c:forEach var="spec" items="${specialists}">
                            <c:if test="${spec.roomId == room.id}"><c:set var="assignedSpecialist" value="${spec}" /></c:if>
                        </c:forEach>
                        
                        <c:choose>
                            <c:when test="${not empty assignedDoctor}">
                                <span class="badge bg-primary" style="font-size: 0.9em;"><i class="bi bi-person-badge"></i> BS. ${assignedDoctor.name}</span>
                            </c:when>
                            <c:when test="${not empty assignedSpecialist}">
                                <span class="badge bg-info text-dark" style="font-size: 0.9em;"><i class="bi bi-person-workspace"></i> CVYT. ${assignedSpecialist.name}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary" style="font-size: 0.9em;">Chưa phân công</span>
                            </c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">"""
content = content.replace(room_row_old, room_row_new)

# 5. Remove the two tables at the bottom (Doctor Room Assignment & Specialist Room Assignment)
# Find the start of the first row containing "Phân công Bác sĩ vào Phòng"
idx_start = content.find('<!-- Doctor Room Assignment -->')
idx_end = content.find('<!-- Add Room Modal -->')
if idx_start != -1 and idx_end != -1:
    content = content[:idx_start] + content[idx_end:]

# 6. Make Room column 12 to make it wider since we removed the bottom ones!
content = content.replace('<div class="col-lg-6">', '<div class="col-lg-12">', 1)
content = content.replace('<div class="col-lg-6">', '<div class="col-lg-12 mt-4">', 1)

# 7. Add JS at the end
js_code = """
    <script>
        function checkRoomTypeForEdit(inputElement, roomId) {
            const val = inputElement.value.toLowerCase();
            const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật');
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
            const isSurgery = val.includes('tiểu phẫu') || val.includes('phẫu thuật');
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
"""
content = content.replace('</body>', js_code)

# 8. Modify Edit Room Modal body
# I will use replace on the precise old block
old_edit_body = """                            <div class="modal-body p-4">
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
                              <div class="mb-3">
                                <label class="form-label fw-semibold">Chỉ định chuyên viên y tế (phẫu thuật/trị liệu)</label>
                                <select name="specialistId" class="form-select">
                                  <option value="">-- Không có / Bỏ trống --</option>
                                  <c:forEach var="specialist" items="${specialists}">
                                    <c:if test="${specialist.roomId == room.id || specialist.roomId == 0 || empty specialist.roomId}">
                                      <option value="${specialist.id}" ${specialist.roomId == room.id ? 'selected' : ''}>
                                        ${specialist.name} - ${specialist.specialty}
                                      </option>
                                    </c:if>
                                  </c:forEach>
                                </select>
                                <div class="form-text text-muted small">Chỉ hiển thị chuyên viên đang trực tại phòng này hoặc chưa được phân công.</div>
                              </div>
                            </div>"""
                            
new_edit_body = """                            <div class="modal-body p-4">
                              <div class="mb-3">
                                <label class="form-label fw-semibold">Loại phòng (Tên phòng)</label>
                                <input type="text" name="roomName" class="form-control" value="${room.name}" required oninput="checkRoomTypeForEdit(this, ${room.id})">
                              </div>
                              <c:set var="lowerRoomName" value="${fn:toLowerCase(room.name)}" />
                              <c:set var="isSurgery" value="${fn:contains(lowerRoomName, 'tiểu phẫu') || fn:contains(lowerRoomName, 'phẫu thuật')}" />
                              
                              <div id="docDivEdit${room.id}" class="mb-3" style="display: ${isSurgery ? 'none' : 'block'};">
                                <label class="form-label fw-semibold">Chỉ định Bác sĩ trực</label>
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
                                <div class="form-text text-muted small">Chỉ phòng khám mắt mới chọn được Bác sĩ.</div>
                              </div>
                              
                              <div id="specDivEdit${room.id}" class="mb-3" style="display: ${isSurgery ? 'block' : 'none'};">
                                <label class="form-label fw-semibold">Chỉ định Chuyên viên y tế</label>
                                <select name="specialistId" class="form-select">
                                  <option value="">-- Không có / Bỏ trống --</option>
                                  <c:forEach var="specialist" items="${specialists}">
                                    <c:if test="${specialist.roomId == room.id || specialist.roomId == 0 || empty specialist.roomId}">
                                      <option value="${specialist.id}" ${specialist.roomId == room.id ? 'selected' : ''}>
                                        ${specialist.name} - ${specialist.specialty}
                                      </option>
                                    </c:if>
                                  </c:forEach>
                                </select>
                                <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn được Chuyên viên y tế.</div>
                              </div>
                            </div>"""
content = content.replace(old_edit_body, new_edit_body)

# 9. Modify Add Room Modal body
old_add_body = """            <div class="modal-body p-4">
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
              <div class="mb-3">
                <label class="form-label fw-semibold">Phân công chuyên viên y tế (Tùy chọn)</label>
                <select name="specialistId" class="form-select">
                  <option value="">-- Bỏ qua / Sắp xếp sau --</option>
                  <c:forEach var="specialist" items="${specialists}">
                    <c:if test="${specialist.roomId == 0 || empty specialist.roomId}">
                      <option value="${specialist.id}">${specialist.name} - ${specialist.specialty}</option>
                    </c:if>
                  </c:forEach>
                </select>
                <div class="form-text text-muted small">Chỉ hiển thị các chuyên viên chưa được phân công phòng nào.</div>
              </div>
            </div>"""
new_add_body = """            <div class="modal-body p-4">
              <div class="mb-3">
                <label class="form-label fw-semibold">Tên phòng khám</label>
                <input type="text" name="roomName" class="form-control" required placeholder="VD: Phòng Khám 102" oninput="checkRoomTypeForAdd(this)">
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
                <div class="form-text text-muted small">Chỉ phòng tiểu phẫu/phẫu thuật mới chọn được Chuyên viên y tế.</div>
              </div>
            </div>"""
content = content.replace(old_add_body, new_add_body)

with open('web/views/admin/clinic-config.jsp', 'w', encoding='utf-8') as f:
    f.write(content)
