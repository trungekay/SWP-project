<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>VisionCare | Thanh toán VietQR</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/bootstrap-icons/bootstrap-icons.css"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/walkin-payment.css"></head><body><header><div class="brand"><span class="brand-icon"><i class="bi bi-eye"></i></span><span>VisionCare</span></div><span class="header-label"><i class="bi bi-shield-check"></i> Thanh toán tại quầy</span></header><div class="page-heading"><div><span class="eyebrow">TIẾP ĐÓN KHÁCH VÃNG LAI</span><h1>Thanh toán phí khám</h1><p>Quét mã VietQR để hoàn tất thanh toán phí khám ban đầu.</p></div><span class="payment-badge"><span></span> Chuyển khoản VietQR</span></div><main>
<section class="qr-panel"><div class="card-icon"><i class="bi bi-qr-code-scan"></i></div><h2>Quét mã VietQR</h2><div class="muted">Mở ứng dụng Ngân hàng hoặc Ví điện tử để quét</div><div id="payment"><img src="<c:out value='${display.qrUrl}'/>" alt="QR thanh toán"><div class="timer-box"><div class="timer-row"><span>Thời hạn thanh toán:</span><span class="countdown">--:--</span></div><progress id="progress" max="${display.holdSeconds}" value="${display.holdSeconds}"></progress><small class="muted">Chỉ sử dụng mã cho giao dịch này khi còn hiệu lực.</small></div></div><div id="result" hidden></div></section>
<section><div class="detail"><h2><i class="bi bi-receipt"></i> Chi tiết thanh toán</h2>
<div class="row"><span>Mã lịch hẹn:</span><strong>#VC<c:out value="${appointment.id}"/></strong></div>
<div class="row"><span>Bệnh nhân:</span><strong><c:out value="${appointment.patientName}"/></strong></div>
<div class="row"><span>Bác sĩ khám:</span><strong><c:out value="${appointment.doctorName}"/></strong></div>
<div class="row"><span>Thời gian hẹn:</span><strong><c:out value="${appointment.timeSlot}"/> — <c:out value="${appointment.appointmentDate}"/></strong></div>
<div class="row"><span>Thời hạn thanh toán:</span><strong class="countdown">--:--</strong></div><hr>
<div class="row"><span>Ngân hàng:</span><strong>Ngân hàng Quân Đội (MB Bank)</strong></div>
<div class="row"><span>Số tài khoản:</span><strong>0877757889</strong></div>
<div class="row"><span>Chủ tài khoản:</span><strong>NGUYEN DINH TRUNG</strong></div>
<div class="row"><span>Nội dung chuyển khoản:</span><strong><c:out value="${display.description}"/></strong></div>
<div class="row"><strong>Tổng phí khám cần thanh toán:</strong><strong class="amount"><c:out value="${display.amount}"/></strong></div></div>
<p id="status" class="notice" role="status" aria-live="polite">Hệ thống tự động kiểm tra thanh toán. Sau khi nhận tiền, lịch hẹn chuyển sang Chờ tiếp đón.</p>
<button id="check" type="button"><i class="bi bi-shield-check"></i> Tôi đã chuyển khoản · Kiểm tra thanh toán</button>
<div class="tools"><button id="cancel" class="secondary-action" type="button">Hủy thanh toán và trả chỗ khám</button><a class="back" href="${pageContext.request.contextPath}/staff/appointments">← Về danh sách lịch hẹn</a></div></section></main>
<dialog id="cancelDialog" aria-labelledby="cancelTitle" aria-describedby="cancelDescription">
    <div class="dialog-icon" aria-hidden="true">!</div>
    <h2 id="cancelTitle">Hủy thanh toán?</h2>
    <p id="cancelDescription">Bạn có chắc muốn hủy thanh toán và trả lại chỗ khám? Lượt chưa thanh toán sẽ không được đưa vào danh sách lịch hẹn.</p>
    <div class="dialog-actions">
        <button class="keep" id="keepPayment" type="button" autofocus>Tiếp tục thanh toán</button>
        <button class="danger" id="confirmCancel" type="button">Xác nhận hủy</button>
    </div>
</dialog>
<script>
let expiresAt=${display.expiresAt};let stopped=false,busy=false;
function renderState(state){const terminal=['paid','cancelled','expired'].includes(state);const message={paid:'Đã thanh toán — Chờ tiếp đón. Staff bấm Check-in để đưa vào danh sách chờ khám.',cancelled:'Giao dịch đã hủy. Vui lòng liên hệ lễ tân.',expired:'Mã đã hết hạn. Vui lòng liên hệ lễ tân.',pending:'Chưa nhận được xác nhận thanh toán. Hệ thống đang tự động kiểm tra.',error:'Chưa kiểm tra được thanh toán. Vui lòng thử lại.'}[state];document.getElementById('status').textContent=message;document.getElementById('payment').hidden=terminal;document.getElementById('result').hidden=!terminal;document.getElementById('result').textContent=message;document.getElementById('check').hidden=terminal;stopped=terminal;if(terminal&&document.getElementById('cancelDialog').open)document.getElementById('cancelDialog').close();document.getElementById('cancel').hidden=terminal;}
function tick(){if(stopped)return;const left=Math.max(0,Math.ceil((expiresAt-Date.now())/1000));document.querySelectorAll('.countdown').forEach(el=>el.textContent=String(Math.floor(left/60)).padStart(2,'0')+':'+String(left%60).padStart(2,'0'));document.getElementById('progress').value=left;if(!left)renderState('expired');}
const cancelDialog=document.getElementById('cancelDialog');
document.getElementById('cancel').addEventListener('click',()=>{if(!stopped&&!busy)cancelDialog.showModal();});
document.getElementById('keepPayment').addEventListener('click',()=>cancelDialog.close());
document.getElementById('confirmCancel').addEventListener('click',async()=>{
    if(stopped){cancelDialog.close();return;}
    if(busy)return;
    busy=true;
    const button=document.getElementById('confirmCancel');button.disabled=true;button.textContent='Đang hủy…';
    try{
        const response=await fetch(location.pathname,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({token:new URLSearchParams(location.search).get('token')})});
        renderState((await response.json()).state);
    }catch(e){renderState('error');}
    finally{busy=false;button.disabled=false;button.textContent='Xác nhận hủy';cancelDialog.close();}
});
async function check(){if(stopped||busy)return;busy=true;const button=document.getElementById('check');button.disabled=true;try{const url=new URL(location.href);url.searchParams.set('action','status');const response=await fetch(url,{cache:'no-store'});const data=await response.json();if(data.expiresAt)expiresAt=data.expiresAt;if(data.holdSeconds)document.getElementById("progress").max=data.holdSeconds;renderState(data.state);tick();}catch(e){renderState('error');}finally{busy=false;button.disabled=false;}}
renderState('${paymentState}');tick();setInterval(tick,1000);setInterval(check,2500);document.getElementById('check').addEventListener('click',check);
</script></body></html>