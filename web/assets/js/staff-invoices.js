(() => {
 'use strict';
 const choice = document.getElementById('paymentChoice');
 if (choice) {
  const update = () => {
   const cash = choice.value === 'cash';
   const box = document.getElementById('cashConfirm');
   box.hidden = !cash;
   box.querySelector('input').required = cash;
   document.getElementById('payButton').textContent = cash ? 'X\xe1c nh\u1eadn \u0111\xe3 nh\u1eadn ti\u1ec1n m\u1eb7t' : 'T\u1ea1o m\xe3 QR thanh to\xe1n';
  };
  choice.addEventListener('change', update);
  update();
 }
 const qr = document.getElementById('invoiceQr');
 if (qr && qr.dataset.payload && typeof QRCode !== 'undefined') {
  new QRCode(qr, { text: qr.dataset.payload, width: 220, height: 220, correctLevel: QRCode.CorrectLevel.M });
 }
 const monitor = document.getElementById('qrMonitor');
 const state = document.getElementById('qrState');
 if (!monitor || !state) return;
 let busy = false, stopped = false, timer = null, failures = 0, controller = null;
 const schedule = () => {
  clearTimeout(timer);
  if (!stopped) timer = setTimeout(check, Math.min(30000, 5000 * Math.pow(2, Math.min(failures, 3))));
 };
 const check = async () => {
  if (busy || stopped) return;
  clearTimeout(timer);
  busy = true;
  controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 16000);
  try {
   const response = await fetch(monitor.dataset.endpoint, {
    method: 'POST', credentials: 'same-origin', signal: controller.signal,
    headers: { Accept: 'application/json', 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
    body: new URLSearchParams({ action: 'checkQr', invoiceId: monitor.dataset.invoiceId,
     orderCode: monitor.dataset.orderCode, csrfToken: monitor.dataset.csrfToken })
   });
   if (response.redirected || response.status === 401) {
    stopped = true;
    state.textContent = 'Phi\xean \u0111\u0103ng nh\u1eadp \u0111\xe3 h\u1ebft h\u1ea1n. Vui l\xf2ng \u0111\u0103ng nh\u1eadp l\u1ea1i \u0111\u1ec3 ti\u1ebfp t\u1ee5c theo d\xf5i.';
    return;
   }
   if (!(response.headers.get('content-type') || '').toLowerCase().includes('application/json')) {
    if (response.status === 403) {
     stopped = true;
     state.textContent = 'Phi\xean x\xe1c nh\u1eadn kh\xf4ng c\xf2n hi\u1ec7u l\u1ef1c. Vui l\xf2ng t\u1ea3i l\u1ea1i trang.';
    } else {
     failures++;
     state.textContent = 'K\u1ebft n\u1ed1i t\u1ea1m th\u1eddi gi\xe1n \u0111o\u1ea1n. H\u1ec7 th\u1ed1ng \u0111ang t\u1ef1 k\u1ebft n\u1ed1i l\u1ea1i \u0111\u1ec3 x\xe1c nh\u1eadn thanh to\xe1n.';
    }
    return;
   }
   const result = await response.json();
   if (result.status === 'SessionExpired') {
    stopped = true;
    window.location.reload();
    return;
   }
   if (response.status === 403 || result.status === 'Forbidden') {
    stopped = true;
    state.textContent = result.message || 'T\xe0i kho\u1ea3n kh\xf4ng c\xf2n quy\u1ec1n theo d\xf5i h\xf3a \u0111\u01a1n n\xe0y.';
    return;
   }
   if (!response.ok) {
    failures++;
    state.textContent = 'Ch\u01b0a x\xe1c minh \u0111\u01b0\u1ee3c giao d\u1ecbch. H\u1ec7 th\u1ed1ng s\u1ebd t\u1ef1 th\u1eed l\u1ea1i, kh\xf4ng c\u1ea7n thao t\xe1c th\xeam.';
    return;
   }
   failures = 0;
   if (result.status === 'Paid' || result.status === 'Cancelled') {
    stopped = true;
    state.textContent = result.status === 'Paid' ? 'Thanh to\xe1n th\xe0nh c\xf4ng. \u0110ang c\u1eadp nh\u1eadt h\xf3a \u0111\u01a1n...' : 'Giao d\u1ecbch QR \u0111\xe3 h\u1ee7y.';
    window.location.reload();
    return;
   }
   state.textContent = '\u0110ang ch\u1edd thanh to\xe1n QR. H\xf3a \u0111\u01a1n s\u1ebd t\u1ef1 chuy\u1ec3n sang Ho\xe0n th\xe0nh khi nh\u1eadn \u0111\u01b0\u1ee3c x\xe1c nh\u1eadn th\xe0nh c\xf4ng.';
  } catch (error) {
   if (!stopped) {
    failures++;
    state.textContent = 'K\u1ebft n\u1ed1i t\u1ea1m th\u1eddi gi\xe1n \u0111o\u1ea1n. H\u1ec7 th\u1ed1ng \u0111ang t\u1ef1 k\u1ebft n\u1ed1i l\u1ea1i \u0111\u1ec3 x\xe1c nh\u1eadn thanh to\xe1n.';
   }
  } finally {
   clearTimeout(timeout);
   controller = null;
   busy = false;
   schedule();
  }
 };
 document.addEventListener('visibilitychange', () => { if (!document.hidden && !busy && !stopped) check(); });
 window.addEventListener('pagehide', () => { stopped = true; clearTimeout(timer); if (controller) controller.abort(); });
 timer = setTimeout(check, 1500);
})();
