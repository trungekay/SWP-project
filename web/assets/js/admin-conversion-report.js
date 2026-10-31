document.addEventListener('DOMContentLoaded', () => {
  const $ = id => document.getElementById(id);
  const today = new Date(new Date().toLocaleString('en-US', {timeZone: 'Asia/Ho_Chi_Minh'}));
  today.setHours(12, 0, 0, 0);
  const iso = date => `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;
  const money = n => new Intl.NumberFormat('vi-VN', {style:'currency',currency:'VND',maximumFractionDigits:0}).format(n);
  const rate = (n,total) => total ? (n*100/total).toLocaleString('vi-VN',{maximumFractionDigits:1})+'%' : '—';
  const label = value => new Date(value+'T12:00:00').toLocaleDateString('vi-VN');
  // Deterministic sample data for the frontend preview, never presented as live clinic records.
  const samples = [];
  for (let offset=89; offset>=0; offset--) {
    const date = new Date(today); date.setDate(date.getDate()-offset);
    const total = 18 + (date.getDate()*7+date.getMonth()*3)%24;
    const cancelled = 1+date.getDate()%4;
    const absent = date.getDate()%3;
    const arrived = total-cancelled-absent;
    samples.push({date:iso(date),total,arrived,cancelled,absent,revenue:arrived*(180000+date.getDate()%5*25000)});
  }
  let selected = [];
  const sum = rows => rows.reduce((a,r) => { ['total','arrived','cancelled','absent','revenue'].forEach(k=>a[k]+=r[k]);return a; },{total:0,arrived:0,cancelled:0,absent:0,revenue:0});
  function render() {
    const from=$('conversionFrom').value, to=$('conversionTo').value;
    const invalid=!from||!to||from>to;
    $('conversionError').hidden=!invalid;
    if(invalid){$('conversionError').textContent='Vui lòng chọn ngày bắt đầu không sau ngày kết thúc.';return;}
    selected=samples.filter(r=>r.date>=from&&r.date<=to);
    const totals=sum(selected);
    $('totalAppointments').textContent=totals.total.toLocaleString('vi-VN');
    $('totalArrived').textContent=totals.arrived.toLocaleString('vi-VN');
    $('attendanceRate').textContent=rate(totals.arrived,totals.total);
    $('attendanceRevenue').textContent=money(totals.revenue);
    $('averageRevenue').textContent='Bình quân / lượt đến: '+(totals.arrived?money(totals.revenue/totals.arrived):'—');
    $('conversionRange').textContent=label(from)+' – '+label(to);
    $('conversionDayCount').textContent=selected.length+' ngày có dữ liệu';
    $('conversionEmpty').hidden=selected.length>0;
    $('conversionExport').disabled=!selected.length;
    $('conversionRows').innerHTML=selected.slice().reverse().map(r=>`<tr><td>${label(r.date)}</td><td>${r.total}</td><td>${r.arrived}</td><td>${r.cancelled}</td><td>${r.absent}</td><td><span class="dashboard-badge success">${rate(r.arrived,r.total)}</span></td><td class="dashboard-amount">${money(r.revenue)}</td></tr>`).join('');
    $('conversionTotals').innerHTML=`<tr><th>Tổng cộng</th><th>${totals.total}</th><th>${totals.arrived}</th><th>${totals.cancelled}</th><th>${totals.absent}</th><th>${rate(totals.arrived,totals.total)}</th><th>${money(totals.revenue)}</th></tr>`;
    const statuses=[['Đã đến khám','arrived','#18a05e'],['Đã hủy','cancelled','#e6a23c'],['Vắng mặt','absent','#e87979']];
    $('conversionStatuses').innerHTML=statuses.map(([name,key,color])=>`<div class="conversion-funnel-row"><div><span>${name}</span><strong>${totals[key]} · ${rate(totals[key],totals.total)}</strong></div><div class="conversion-progress"><span style="width:${totals.total?totals[key]*100/totals.total:0}%;background:${color}"></span></div></div>`).join('');
    const groups=[];
    const size=Math.max(1,Math.ceil(selected.length/7));
    for(let i=0;i<selected.length;i+=size){const rows=selected.slice(i,i+size);groups.push({...sum(rows),label:label(rows[0].date).slice(0,5)});}
    const max=Math.max(1,...groups.map(r=>r.total));
    $('conversionChart').innerHTML=groups.length?groups.map(r=>`<div class="conversion-day"><div class="conversion-track"><span style="height:${r.total/max*100}%" title="Lịch hẹn: ${r.total}"></span><span class="arrived" style="height:${r.arrived/max*100}%" title="Đã đến: ${r.arrived}"></span></div>${r.label}</div>`).join(''):'<p class="conversion-empty">Không có dữ liệu</p>';
    $('conversionChart').setAttribute('aria-label',`Biểu đồ dữ liệu minh họa: ${totals.total} lịch hẹn, ${totals.arrived} lượt đến khám.`);
  }
  function preset(period){
    const start=new Date(today);
    if(period==='week')start.setDate(start.getDate()-6);else start.setDate(1);
    $('conversionFrom').value=iso(start);$('conversionTo').value=iso(today);
    document.querySelectorAll('[data-period]').forEach(b=>b.classList.toggle('active',b.dataset.period===period));render();
  }
  document.querySelectorAll('[data-period]').forEach(b=>b.addEventListener('click',()=>preset(b.dataset.period)));
  $('conversionFilter').addEventListener('submit',e=>{e.preventDefault();document.querySelectorAll('[data-period]').forEach(b=>b.classList.remove('active'));render();});
  $('conversionExport').addEventListener('click',()=>{
    const rows=[['DỮ LIỆU MINH HỌA - CHƯA KẾT NỐI DATABASE'],['Ngày','Lịch hẹn','Đã đến','Đã hủy','Vắng mặt','Tỷ lệ đến','Doanh thu (VND)'],...selected.map(r=>[r.date,r.total,r.arrived,r.cancelled,r.absent,rate(r.arrived,r.total),r.revenue])];
    const csv='\uFEFF'+rows.map(row=>row.map(v=>'"'+String(v).replaceAll('"','""')+'"').join(',')).join('\r\n');
    const url=URL.createObjectURL(new Blob([csv],{type:'text/csv;charset=utf-8;'}));const a=document.createElement('a');a.href=url;a.download='bao-cao-ty-le-den-kham-minh-hoa.csv';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
  });
  preset('month');
});
