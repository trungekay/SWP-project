(() => {
 'use strict';
 const form=document.getElementById('rescheduleForm');if(!form)return;
 const doctor=document.getElementById('rescheduleDoctor'),date=document.getElementById('rescheduleDate'),slot=document.getElementById('rescheduleSlot'),save=document.getElementById('rescheduleSave'),status=document.getElementById('rescheduleStatus');
 let version=0;
 async function load(){const request=++version;slot.replaceChildren(new Option('Ch\u1ecdn ca kh\u00e1m',''));slot.disabled=true;save.disabled=true;status.textContent='';if(!doctor.value||!date.value)return;
  status.textContent='\u0110ang t\u1ea3i l\u1ecbch tr\u1ed1ng\u2026';
  try{const url=new URL(form.dataset.url,location.origin);url.searchParams.set('doctorId',doctor.value);url.searchParams.set('date',date.value);const response=await fetch(url,{credentials:'same-origin',headers:{Accept:'application/json'}});
   if(!response.ok||!response.headers.get('content-type')?.includes('application/json'))throw new Error();const slots=await response.json();if(request!==version)return;
   for(const item of slots)slot.add(new Option(item.label,String(item.id)));slot.disabled=slots.length===0;status.textContent=slots.length?'Ch\u1ecdn m\u1ed9t ca kh\u00e1m c\u00f2n tr\u1ed1ng.':'Kh\u00f4ng c\u00f3 ca tr\u1ed1ng trong ng\u00e0y n\u00e0y.';
  }catch(error){if(request===version)status.textContent='Kh\u00f4ng t\u1ea3i \u0111\u01b0\u1ee3c l\u1ecbch tr\u1ed1ng. Vui l\u00f2ng t\u1ea3i l\u1ea1i trang ho\u1eb7c \u0111\u0103ng nh\u1eadp l\u1ea1i.';}
 }
 doctor.addEventListener('change',load);date.addEventListener('change',load);slot.addEventListener('change',()=>{save.disabled=!slot.value;});form.addEventListener('submit',()=>{save.disabled=true;});load();
})();
