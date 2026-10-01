<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<jsp:include page="/views/common/header.jsp">
  <jsp:param name="pageTitle" value="Dịch vụ nhãn khoa" />
  <jsp:param name="pageDescription" value="Các dịch vụ thăm khám và điều trị mắt tại VisionCare." />
  <jsp:param name="bodyClass" value="clinic-services-page" />
  <jsp:param name="activeNav" value="services" />
</jsp:include>

<main class="main">
  <section id="clinic-services" class="services section" aria-labelledby="services-title">
    <div class="container section-title">
      <h2 id="services-title">Dịch vụ nhãn khoa</h2>
      <p>Các dịch vụ thăm khám và điều trị mắt tại VisionCare — đặt lịch tư vấn để được bác sĩ thăm khám cụ thể</p>
    </div>

    <%-- Static frontend fixtures matching the reference. No DAO or request data required. --%>
    <div class="container">
      <div class="row gy-4">
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-general">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-eye"></i></div>
            <h3 id="service-general">Khám mắt tổng quát</h3>
            <p>Đo thị lực, kiểm tra áp lực nhãn cầu, soi đáy mắt và tư vấn chăm sóc mắt định kỳ.</p>
          </article>
        </div>
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-refraction">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-glasses"></i></div>
            <h3 id="service-refraction">Đo khúc xạ &amp; Kính</h3>
            <p>Đo khúc xạ chính xác, tư vấn kính cận/viễn/loạn, kính áp tròng phù hợp từng bệnh nhân.</p>
          </article>
        </div>
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-children">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-child"></i></div>
            <h3 id="service-children">Nhãn khoa trẻ em</h3>
            <p>Sàng lọc cận thị sớm, điều trị nhược thị, lác mắt — phòng khám thân thiện cho bé.</p>
          </article>
        </div>
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-lasik">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-crosshairs"></i></div>
            <h3 id="service-lasik">Phẫu thuật LASIK</h3>
            <p>Phẫu thuật khúc xạ laser LASIK/SMILE điều trị cận thị, viễn thị, loạn thị vĩnh viễn.</p>
          </article>
        </div>
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-cataract">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-cloud-sun"></i></div>
            <h3 id="service-cataract">Đục thủy tinh thể</h3>
            <p>Phẫu thuật thay thể thủy tinh nhân tạo (IOL) điều trị đục thủy tinh thể an toàn, hiệu quả.</p>
          </article>
        </div>
        <div class="col-lg-4 col-md-6">
          <article class="service-item" aria-labelledby="service-retina">
            <div class="icon" aria-hidden="true"><i class="fa-solid fa-notes-medical"></i></div>
            <h3 id="service-retina">Glaucoma &amp; Võng mạc</h3>
            <p>Chẩn đoán và điều trị glaucoma, bệnh võng mạc tiểu đường — can thiệp sớm bảo vệ thị lực.</p>
          </article>
        </div>
      </div>
    </div>
  </section>
</main>

<jsp:include page="/views/common/footer.jsp" />
