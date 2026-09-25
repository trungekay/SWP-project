<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Lịch làm việc" />
  <jsp:param name="pageDescription" value="Đăng ký và xem lịch làm việc" />
  <jsp:param name="bodyClass" value="starter-page-page" />
</jsp:include>

  <style>
    .schedule-card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.05);
      padding: 24px;
    }
    .calendar-mock {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      gap: 10px;
      margin-top: 20px;
    }
    .calendar-day {
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 10px;
      min-height: 100px;
    }
    .calendar-day.header {
      min-height: auto;
      text-align: center;
      font-weight: bold;
      background: #f8fafc;
    }
    .shift-badge {
      display: block;
      padding: 5px;
      margin-bottom: 5px;
      border-radius: 4px;
      font-size: 12px;
      text-align: center;
    }
    .shift-morning { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }
    .shift-afternoon { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
  </style>

  <main class="main bg-light pb-5">
    <div class="page-title">
      <div class="container">
        <h2 class="mb-0">Lịch làm việc của tôi</h2>
        <nav class="breadcrumbs">
          <ol>
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li class="current">Lịch làm việc</li>
          </ol>
        </nav>
      </div>
    </div>

    <section class="section pt-4">
      <div class="container">
        
        <div class="row g-4">
          <!-- Register Schedule -->
          <div class="col-lg-4">
            <div class="schedule-card">
              <h5 class="mb-4">Đăng ký lịch làm việc</h5>
              <form>
                <div class="mb-3">
                  <label class="form-label fw-bold">Ngày làm việc</label>
                  <input type="date" class="form-control" required>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold">Ca làm việc</label>
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="caSang" value="Sang">
                    <label class="form-check-label" for="caSang">Ca Sáng (07:30 - 11:30)</label>
                  </div>
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="caChieu" value="Chieu">
                    <label class="form-check-label" for="caChieu">Ca Chiều (13:30 - 17:30)</label>
                  </div>
                </div>
                <button type="submit" class="btn btn-primary w-100"><i class="bi bi-calendar-plus me-2"></i>Đăng ký ca</button>
              </form>
            </div>
          </div>

          <!-- View Schedule -->
          <div class="col-lg-8">
            <div class="schedule-card">
              <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">Lịch làm việc (Tháng 9/2026)</h5>
                <div class="btn-group">
                  <button class="btn btn-outline-secondary btn-sm">&lt;</button>
                  <button class="btn btn-outline-secondary btn-sm">Hôm nay</button>
                  <button class="btn btn-outline-secondary btn-sm">&gt;</button>
                </div>
              </div>
              
              <div class="calendar-mock">
                <!-- Headers -->
                <div class="calendar-day header">T2</div>
                <div class="calendar-day header">T3</div>
                <div class="calendar-day header">T4</div>
                <div class="calendar-day header">T5</div>
                <div class="calendar-day header">T6</div>
                <div class="calendar-day header">T7</div>
                <div class="calendar-day header">CN</div>
                
                <!-- Mock days -->
                <div class="calendar-day text-end text-muted">24</div>
                <div class="calendar-day text-end text-muted">25</div>
                <div class="calendar-day text-end text-muted">26</div>
                <div class="calendar-day text-end text-muted">27</div>
                <div class="calendar-day text-end text-muted">28</div>
                <div class="calendar-day text-end text-muted">29</div>
                <div class="calendar-day text-end text-muted">30</div>
                
                <div class="calendar-day text-end">
                  1
                  <span class="shift-badge shift-morning text-start mt-2">Ca Sáng</span>
                  <span class="shift-badge shift-afternoon text-start">Ca Chiều</span>
                </div>
                <div class="calendar-day text-end">
                  2
                  <span class="shift-badge shift-morning text-start mt-2">Ca Sáng</span>
                </div>
                <div class="calendar-day text-end">3</div>
                <div class="calendar-day text-end">4</div>
                <div class="calendar-day text-end">5</div>
                <div class="calendar-day text-end text-danger bg-light">6</div>
                <div class="calendar-day text-end text-danger bg-light">7</div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </section>
  </main>

<jsp:include page="/views/common/footer.jsp" />
