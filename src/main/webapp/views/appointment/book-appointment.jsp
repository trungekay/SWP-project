<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Include Header --%>
<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Đặt lịch khám mắt" />
  <jsp:param name="pageDescription" value="Form đặt lịch khám mắt trực tuyến — VisionCare" />
  <jsp:param name="bodyClass" value="starter-page-page" />
  <jsp:param name="activeNav" value="" />
</jsp:include>

  <style>
    .wizard-container {
      background: #fff;
      border-radius: 15px;
      box-shadow: 0 5px 30px rgba(0, 0, 0, 0.05);
      padding: 40px;
      margin-bottom: 50px;
    }
    .wizard-steps {
      display: flex;
      justify-content: space-between;
      position: relative;
      margin-bottom: 40px;
    }
    .wizard-steps::before {
      content: "";
      position: absolute;
      top: 50%;
      left: 0;
      right: 0;
      height: 4px;
      background: #e9ecef;
      transform: translateY(-50%);
      z-index: 1;
    }
    .step-item {
      position: relative;
      z-index: 2;
      text-align: center;
      background: #fff;
      padding: 0 10px;
      max-width: 33%;
    }
    .step-circle {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: #e9ecef;
      color: #6c757d;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      margin: 0 auto 10px;
      transition: all 0.3s;
    }
    .step-item.active .step-circle,
    .step-item.completed .step-circle {
      background: #0d9488;
      color: #fff;
    }
    .step-item.active .step-circle {
      box-shadow: 0 0 0 5px rgba(13, 148, 136, 0.2);
    }
    .step-title { font-size: 13px; font-weight: 500; color: #6c757d; }
    .step-item.active .step-title,
    .step-item.completed .step-title { color: #0d9488; }
    .step-content { display: none; animation: fadeIn 0.5s; }
    .step-content.active { display: block; }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .radio-card { position: relative; display: block; }
    .radio-card input { position: absolute; opacity: 0; cursor: pointer; }
    .radio-card-content {
      border: 2px solid #e9ecef;
      border-radius: 10px;
      padding: 20px;
      transition: all 0.3s;
      cursor: pointer;
      text-align: center;
      height: 100%;
    }
    .radio-card input:checked ~ .radio-card-content {
      border-color: #0d9488;
      background: rgba(13, 148, 136, 0.06);
    }
    .radio-card-content i { font-size: 28px; color: #0d9488; margin-bottom: 10px; }
  </style>

  <main class="main bg-light">

    <div class="page-title">
      <div class="heading">
        <div class="container">
          <div class="row d-flex justify-content-center text-center">
            <div class="col-lg-8">
              <h1>Đặt lịch khám mắt</h1>
              <p class="mb-0">Hoàn thành 3 bước: chọn chuyên khoa nhãn khoa &amp; bác sĩ, chọn ngày giờ, nhập thông tin và thanh toán.</p>
            </div>
          </div>
        </div>
      </div>
      <nav class="breadcrumbs">
        <div class="container">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Đặt lịch</li>
          </ol>
        </div>
      </nav>
    </div>

    <%-- Hiển thị lỗi nếu có --%>
    <c:if test="${not empty error}">
      <div class="container mt-3">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
          <i class="bi bi-exclamation-triangle me-2"></i>${error}
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </div>
    </c:if>

    <section class="section pt-4">
      <div class="container">
        <div class="row justify-content-center">
          <div class="col-lg-10">

            <%-- Nếu đặt lịch thành công --%>
            <c:if test="${success == true}">
              <div class="wizard-container text-center py-5">
                <i class="bi bi-check-circle-fill text-success" style="font-size: 80px;"></i>
                <h2 class="mt-4 mb-3">Đặt lịch thành công!</h2>
                <p class="text-muted mb-4">Chúng tôi đã ghi nhận lịch hẹn của bạn (Mã: #${appointmentId}). Thông tin xác nhận sẽ được gửi qua email/SMS.</p>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-4">Về trang chủ</a>
              </div>
            </c:if>

            <%-- Form đặt lịch --%>
            <c:if test="${success != true}">
            <div class="wizard-container">
              <div class="wizard-steps" id="wizardSteps">
                <div class="step-item active" id="step-nav-1">
                  <div class="step-circle">1</div>
                  <div class="step-title">Chuyên khoa &amp; Bác sĩ</div>
                </div>
                <div class="step-item" id="step-nav-2">
                  <div class="step-circle">2</div>
                  <div class="step-title">Ngày &amp; Giờ</div>
                </div>
                <div class="step-item" id="step-nav-3">
                  <div class="step-circle">3</div>
                  <div class="step-title">Thông tin &amp; Thanh toán</div>
                </div>
              </div>

              <form id="bookingForm" method="post" action="${pageContext.request.contextPath}/book-appointment">

                <!-- Step 1: Chuyên khoa & Bác sĩ -->
                <div class="step-content active" id="step-1">
                  <h4 class="mb-4">Chọn chuyên khoa và bác sĩ</h4>

                  <div class="mb-4">
                    <label class="form-label fw-bold">Chuyên khoa nhãn khoa</label>
                    <div class="row g-3">
                      <c:forEach var="dept" items="${departments}">
                        <div class="col-md-3 col-6">
                          <label class="radio-card">
                            <input type="radio" name="department" value="${dept.key}" ${dept.key == 'general' ? 'checked' : ''}>
                            <div class="radio-card-content">
                              <i class="${dept.icon}"></i>
                              <h6 class="mb-0">${dept.name}</h6>
                            </div>
                          </label>
                        </div>
                      </c:forEach>
                    </div>
                  </div>

                  <div class="mb-4">
                    <label for="doctorSelect" class="form-label fw-bold">Bác sĩ</label>
                    <select class="form-select form-select-lg" id="doctorSelect" name="doctorId" required>
                      <option value="">— Chọn bác sĩ nhãn khoa —</option>
                      <c:forEach var="doc" items="${doctors}">
                        <option value="${doc.id}" data-dept="${doc.departmentKey}"
                          ${doc.id == selectedDoctor ? 'selected' : ''}>
                          ${doc.name} — ${doc.specialty}
                        </option>
                      </c:forEach>
                    </select>
                  </div>

                  <div class="text-end mt-5">
                    <button type="button" class="btn btn-primary px-5" onclick="nextStep(1)">Tiếp theo <i class="bi bi-arrow-right ms-2"></i></button>
                  </div>
                </div>

                <!-- Step 2: Ngày & Giờ -->
                <div class="step-content" id="step-2">
                  <h4 class="mb-4">Chọn ngày và khung giờ</h4>

                  <div class="row">
                    <div class="col-md-6 mb-4">
                      <label for="appointmentDate" class="form-label fw-bold">Ngày khám</label>
                      <input type="date" class="form-control form-control-lg" id="appointmentDate" name="appointmentDate" required>
                    </div>
                  </div>

                  <div class="mb-4">
                    <label class="form-label fw-bold">Khung giờ còn trống</label>
                    <div class="d-flex flex-wrap gap-2" id="timeSlotGroup">
                      <input type="radio" class="btn-check" name="timeSlot" id="time1" autocomplete="off" value="08:00">
                      <label class="btn btn-outline-primary" for="time1">08:00</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time2" autocomplete="off" value="08:30">
                      <label class="btn btn-outline-primary" for="time2">08:30</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time3" autocomplete="off" value="09:00">
                      <label class="btn btn-outline-primary" for="time3">09:00</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time4" autocomplete="off" value="09:30">
                      <label class="btn btn-outline-primary" for="time4">09:30</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time5" autocomplete="off" value="14:00">
                      <label class="btn btn-outline-primary" for="time5">14:00</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time6" autocomplete="off" value="15:00">
                      <label class="btn btn-outline-primary" for="time6">15:00</label>
                      <input type="radio" class="btn-check" name="timeSlot" id="time7" autocomplete="off" value="15:30">
                      <label class="btn btn-outline-primary" for="time7">15:30</label>
                    </div>
                  </div>

                  <div class="d-flex justify-content-between mt-5">
                    <button type="button" class="btn btn-outline-secondary px-5" onclick="prevStep(2)"><i class="bi bi-arrow-left me-2"></i> Quay lại</button>
                    <button type="button" class="btn btn-primary px-5" onclick="nextStep(2)">Tiếp theo <i class="bi bi-arrow-right ms-2"></i></button>
                  </div>
                </div>

                <!-- Step 3: Thông tin bệnh nhân & Thanh toán -->
                <div class="step-content" id="step-3">
                  <h4 class="mb-4">Thông tin bệnh nhân</h4>

                  <div class="row g-3 mb-4">
                    <div class="col-md-6">
                      <label class="form-label" for="patientName">Họ và tên</label>
                      <input type="text" class="form-control" id="patientName" name="patientName" placeholder="Nguyễn Văn A" required>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" for="patientPhone">Số điện thoại</label>
                      <input type="tel" class="form-control" id="patientPhone" name="patientPhone" placeholder="0901234567" required pattern="[0-9]{9,11}">
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" for="patientEmail">Email</label>
                      <input type="email" class="form-control" id="patientEmail" name="patientEmail" placeholder="email@example.com" required>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label" for="patientDob">Ngày sinh</label>
                      <input type="date" class="form-control" id="patientDob" name="patientDob" required>
                    </div>
                    <div class="col-12">
                      <label class="form-label" for="visitReason">Lý do khám / Triệu chứng mắt (tùy chọn)</label>
                      <textarea class="form-control" id="visitReason" name="visitReason" rows="3" placeholder="Mô tả ngắn triệu chứng: mờ mắt, đau mắt, cần điều trị cận thị..."></textarea>
                    </div>
                  </div>

                  <h4 class="mb-4 border-top pt-4">Phí khám ban đầu: <span class="text-primary">200.000₫</span></h4>

                  <div class="mb-4">
                    <label class="form-label fw-bold">Phương thức thanh toán</label>
                    <div class="row g-3">
                      <div class="col-md-4">
                        <label class="radio-card">
                          <input type="radio" name="payment" value="vnpay" checked>
                          <div class="radio-card-content p-3"><h5 class="mb-0 text-primary fw-bold">VNPay</h5></div>
                        </label>
                      </div>
                      <div class="col-md-4">
                        <label class="radio-card">
                          <input type="radio" name="payment" value="momo">
                          <div class="radio-card-content p-3"><h5 class="mb-0 text-danger fw-bold">MoMo</h5></div>
                        </label>
                      </div>
                      <div class="col-md-4">
                        <label class="radio-card">
                          <input type="radio" name="payment" value="clinic">
                          <div class="radio-card-content p-3"><h5 class="mb-0 text-success fw-bold">Tại phòng khám</h5></div>
                        </label>
                      </div>
                    </div>
                  </div>

                  <div class="d-flex justify-content-between mt-5">
                    <button type="button" class="btn btn-outline-secondary px-5" onclick="prevStep(3)"><i class="bi bi-arrow-left me-2"></i> Quay lại</button>
                    <button type="submit" class="btn btn-success px-5 btn-lg"><i class="bi bi-check-circle me-2"></i> Xác nhận &amp; Thanh toán</button>
                  </div>
                </div>

              </form>
            </div>
            </c:if>

          </div>
        </div>
      </div>
    </section>

  </main>

<%-- Include Footer --%>
<jsp:include page="/views/common/footer.jsp" />

  <script>
    // Set min date to today
    const today = new Date().toISOString().split('T')[0];
    const appointmentDate = document.getElementById('appointmentDate');
    if (appointmentDate) {
      appointmentDate.min = today;
      appointmentDate.value = today;
    }

    // Pre-select time slot from URL parameter
    const selectedTime = '${selectedTime}';
    if (selectedTime) {
      const slot = document.querySelector('input[name="timeSlot"][value="' + selectedTime + '"]');
      if (slot && !slot.disabled) slot.checked = true;
    }

    // Filter doctors by department
    document.querySelectorAll('input[name="department"]').forEach(radio => {
      radio.addEventListener('change', function () {
        const dept = this.value;
        const select = document.getElementById('doctorSelect');
        Array.from(select.options).forEach(opt => {
          if (!opt.value) return;
          opt.hidden = opt.dataset.dept !== dept;
        });
        if (select.selectedOptions[0]?.hidden) select.value = '';
      });
    });

    function nextStep(currentStep) {
      if (currentStep === 1 && !document.getElementById('doctorSelect').value) {
        alert('Vui lòng chọn bác sĩ.');
        return;
      }
      if (currentStep === 2) {
        if (!appointmentDate.value) {
          alert('Vui lòng chọn ngày khám.');
          return;
        }
        if (!document.querySelector('input[name="timeSlot"]:checked')) {
          alert('Vui lòng chọn khung giờ.');
          return;
        }
      }
      document.getElementById('step-' + currentStep).classList.remove('active');
      document.getElementById('step-' + (currentStep + 1)).classList.add('active');
      document.getElementById('step-nav-' + currentStep).classList.add('completed');
      document.getElementById('step-nav-' + currentStep).classList.remove('active');
      document.getElementById('step-nav-' + (currentStep + 1)).classList.add('active');
    }

    function prevStep(currentStep) {
      document.getElementById('step-' + currentStep).classList.remove('active');
      document.getElementById('step-' + (currentStep - 1)).classList.add('active');
      document.getElementById('step-nav-' + currentStep).classList.remove('active');
      document.getElementById('step-nav-' + (currentStep - 1)).classList.add('active');
      document.getElementById('step-nav-' + (currentStep - 1)).classList.remove('completed');
    }
  </script>
