document.addEventListener('DOMContentLoaded', () => {
  const $ = id => document.getElementById(id);
  const today = new Date(new Date().toLocaleString('en-US', {timeZone: 'Asia/Ho_Chi_Minh'}));
  today.setHours(12, 0, 0, 0);
  const iso = date => `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}`;
  const money = n => new Intl.NumberFormat('vi-VN', {style:'currency',currency:'VND',maximumFractionDigits:0}).format(n);
  const rate = (n,total) => total ? (n*100/total).toLocaleString('vi-VN',{maximumFractionDigits:1})+'%' : '\u2014';
  const label = value => new Date(value+'T12:00:00').toLocaleDateString('vi-VN');
  const samples = [...$('conversionData').querySelectorAll('[data-date]')].map(el => ({
    date:el.dataset.date,...Object.fromEntries(['total','arrived','cancelled','absent','pending','revenue'].map(key=>[key,Number(el.dataset[key])]))
  }));
  if ($('conversionData').dataset.error === 'true') {
    $('conversionExport').disabled=true;
    return;
  }
  let selected = [];
  const sum = rows => rows.reduce((a,r) => { ['total','arrived','cancelled','absent','pending','revenue'].forEach(k=>a[k]+=r[k]);return a; },{total:0,arrived:0,cancelled:0,absent:0,pending:0,revenue:0});
  function render() {
    const from=$('conversionFromPicker').value, to=$('conversionToPicker').value;
    const invalid=!from||!to||from>to;
    $('conversionError').hidden=!invalid;
    if(invalid){$('conversionError').textContent='Vui l\u00f2ng ch\u1ecdn ng\u00e0y b\u1eaft \u0111\u1ea7u kh\u00f4ng sau ng\u00e0y k\u1ebft th\u00fac.';return;}
    selected=samples.filter(r=>r.date>=from&&r.date<=to);
    const totals=sum(selected);
    $('totalAppointments').textContent=totals.total.toLocaleString('vi-VN');
    $('totalArrived').textContent=totals.arrived.toLocaleString('vi-VN');
    $('attendanceRate').textContent=rate(totals.arrived,totals.total);
    $('attendanceRevenue').textContent=money(totals.revenue);
    $('averageRevenue').textContent='B\u00ecnh qu\u00e2n / l\u01b0\u1ee3t \u0111\u1ebfn: '+(totals.arrived?money(totals.revenue/totals.arrived):'\u2014');
    $('conversionRange').textContent=label(from)+' \u2013 '+label(to);
    $('conversionDayCount').textContent=selected.length+' ng\u00e0y c\u00f3 d\u1eef li\u1ec7u';
    $('conversionEmpty').hidden=selected.length>0;
    $('conversionExport').disabled=!selected.length;
    $('conversionRows').innerHTML=selected.slice().reverse().map(r=>`<tr><td>${label(r.date)}</td><td>${r.total}</td><td>${r.arrived}</td><td>${r.cancelled}</td><td>${r.absent}</td><td>${r.pending}</td><td><span class="dashboard-badge success">${rate(r.arrived,r.total)}</span></td><td class="dashboard-amount">${money(r.revenue)}</td></tr>`).join('');
    $('conversionTotals').innerHTML=`<tr><th>T\u1ed5ng c\u1ed9ng</th><th>${totals.total}</th><th>${totals.arrived}</th><th>${totals.cancelled}</th><th>${totals.absent}</th><th>${totals.pending}</th><th>${rate(totals.arrived,totals.total)}</th><th>${money(totals.revenue)}</th></tr>`;
    const statuses=[['\u0110\u00e3 \u0111\u1ebfn kh\u00e1m','arrived','#18a05e'],['\u0110\u00e3 h\u1ee7y','cancelled','#e6a23c'],['V\u1eafng m\u1eb7t','absent','#e87979'],['Ch\u1edd \u0111\u1ebfn','pending','#8b9bb4']];
    $('conversionStatuses').innerHTML=statuses.map(([name,key,color])=>`<div class="conversion-funnel-row"><div><span>${name}</span><strong>${totals[key]} \u00b7 ${rate(totals[key],totals.total)}</strong></div><div class="conversion-progress"><span style="width:${totals.total?totals[key]*100/totals.total:0}%;background:${color}"></span></div></div>`).join('');
    const groups=[];
    const size=Math.max(1,Math.ceil(selected.length/7));
    for(let i=0;i<selected.length;i+=size){const rows=selected.slice(i,i+size);groups.push({...sum(rows),label:label(rows[0].date).slice(0,5)});}
    const max=Math.max(1,...groups.map(r=>r.total));
    $('conversionChart').innerHTML=groups.length?groups.map(r=>`<div class="conversion-day"><div class="conversion-track"><span style="height:${r.total/max*100}%" title="L\u1ecbch h\u1eb9n: ${r.total}"></span><span class="arrived" style="height:${r.arrived/max*100}%" title="\u0110\u00e3 \u0111\u1ebfn: ${r.arrived}"></span></div>${r.label}</div>`).join(''):'<p class="conversion-empty">Kh\u00f4ng c\u00f3 d\u1eef li\u1ec7u</p>';
    $('conversionChart').setAttribute('aria-label',`Bi\u1ec3u \u0111\u1ed3 d\u1eef li\u1ec7u: ${totals.total} l\u1ecbch h\u1eb9n, ${totals.arrived} l\u01b0\u1ee3t \u0111\u1ebfn kh\u00e1m.`);
  }
  document.querySelectorAll('.dashboard-calendar-button').forEach(button => {
    const picker = $(button.dataset.picker);
    const display = picker.parentElement.querySelector('input[type="text"]');
    button.addEventListener('click', () => {
      const parts = display.value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      if (parts) picker.value = parts[3] + '-' + parts[2] + '-' + parts[1];
      if (picker.showPicker) picker.showPicker();
      else { picker.focus(); picker.click(); }
    });
    picker.addEventListener('change', () => {
      if (!picker.value) return;
      const parts=picker.value.split('-');
      display.value=parts[2]+'/'+parts[1]+'/'+parts[0];
    });
  });
  $('conversionFilter').addEventListener('submit',e=>{
    if(e.submitter && e.submitter.value!=='custom')return;
    const parse = value => {
      const match=value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      return match ? match[3]+'-'+match[2]+'-'+match[1] : '';
    };
    const from=parse($('conversionFrom').value),to=parse($('conversionTo').value);
    if(!from||!to||from>to){e.preventDefault();$('conversionError').hidden=false;$('conversionError').textContent='Ng\u00e0y b\u1eaft \u0111\u1ea7u kh\u00f4ng \u0111\u01b0\u1ee3c sau ng\u00e0y k\u1ebft th\u00fac.';}
  });
  $('conversionExport').addEventListener('click',()=>{
    const rows=[['B\u00c1O C\u00c1O T\u1ef6 L\u1ec6 \u0110\u1ebeN KH\u00c1M'],['Ng\u00e0y','L\u1ecbch h\u1eb9n','\u0110\u00e3 \u0111\u1ebfn','\u0110\u00e3 h\u1ee7y','V\u1eafng m\u1eb7t','Ch\u1edd \u0111\u1ebfn','T\u1ef7 l\u1ec7 \u0111\u1ebfn','Doanh thu (VND)'],...selected.map(r=>[r.date,r.total,r.arrived,r.cancelled,r.absent,r.pending,rate(r.arrived,r.total),r.revenue])];
    const csv='\uFEFF'+rows.map(row=>row.map(v=>'"'+String(v).replaceAll('"','""')+'"').join(',')).join('\r\n');
    const url=URL.createObjectURL(new Blob([csv],{type:'text/csv;charset=utf-8;'}));const a=document.createElement('a');a.href=url;a.download='bao-cao-ty-le-den-kham.csv';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
  });
  render();
});
