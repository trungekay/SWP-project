const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync('web/assets/js/staff-invoices.js', 'utf8');
function app(reply) {
 const timers = new Map(), calls = [], state = {textContent:''};
 let nextId=0, reloads=0;
 const document = {
  hidden:false, addEventListener(){},
  getElementById(id) {
   if(id==='qrMonitor') return {dataset:{endpoint:'/SWP-project/staff/invoices/checkout',invoiceId:'13',orderCode:'900000000000013',csrfToken:'test-token'}};
   if(id==='qrState') return state;
   return null;
  }
 };
 const context = {document, URLSearchParams, AbortController,
  window:{location:{reload(){reloads++;}},addEventListener(){}},
  setTimeout(fn,delay){const id=++nextId;timers.set(id,{fn,delay});return id;},clearTimeout(id){timers.delete(id);},
  async fetch(url,options){calls.push({url,options});if(reply instanceof Error) throw reply;return reply;}
 };
 vm.runInNewContext(source,context);
 return {calls,state,get reloads(){return reloads;},get scheduled(){return [...timers.values()].filter(t=>t.fn.name==='check').length;},async tick(){const entry=[...timers.entries()].find(([id,t])=>t.fn.name==='check');assert.ok(entry,'automatic check must remain scheduled');timers.delete(entry[0]);await entry[1].fn();}};
}
const response=(status,body,type='application/json')=>({status,ok:status>=200&&status<300,redirected:false,headers:{get(){return type;}},async json(){if(type!=='application/json')throw new SyntaxError('Unexpected token <');return body;}});
(async()=>{
 let tests=0;
 const pending=app(response(200,{status:'Pending'}));await pending.tick();
 assert.equal(pending.calls[0].url,'/SWP-project/staff/invoices/checkout');
 assert.equal(pending.calls[0].options.body.get('action'),'checkQr');
 assert.equal(pending.calls[0].options.body.get('csrfToken'),'test-token');tests++;
 for(let n=0;n<50;n++)await pending.tick();assert.equal(pending.calls.length,51);assert.equal(pending.scheduled,1);tests++;
 for(const status of ['Paid','Cancelled']){const a=app(response(200,{status}));await a.tick();assert.equal(a.reloads,1);assert.equal(a.scheduled,0);tests++;}
 const html=app(response(404,null,'text/html'));await html.tick();assert.equal(html.scheduled,1);assert.ok(!html.state.textContent.includes('Unexpected'));assert.ok(!html.state.textContent.includes('<!'));tests++;
 const offline=app(new SyntaxError("Unexpected token '<'"));await offline.tick();assert.equal(offline.scheduled,1);assert.ok(!offline.state.textContent.includes('Unexpected'));tests++;
 const expired=app(response(401,{status:'Unauthenticated'}));await expired.tick();assert.equal(expired.scheduled,0);assert.ok(expired.state.textContent.includes('đăng nhập'));tests++;
 const csrf=app(response(403,{status:'SessionExpired'}));await csrf.tick();assert.equal(csrf.reloads,1);assert.equal(csrf.scheduled,0);tests++;
 const forbidden=app(response(403,{status:'Forbidden',message:'No permission'}));await forbidden.tick();assert.equal(forbidden.scheduled,0);assert.equal(forbidden.reloads,0);tests++;
 const retry=app(response(409,{status:'Retry'}));await retry.tick();assert.equal(retry.scheduled,1);tests++;
 console.log(`PASS: ${tests} automatic QR monitoring scenarios (no real requests or timers).`);
})().catch(error=>{console.error(error);process.exitCode=1;});
