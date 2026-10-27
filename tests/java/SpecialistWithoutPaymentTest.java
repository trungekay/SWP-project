package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.*;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.*;
import java.lang.reflect.*;
import java.util.*;

/** No database access: exercise the clinical flow with an unpaid surgery referral. */
public class SpecialistWithoutPaymentTest {
    static class Orders extends ProcedureOrderDAO {
        final ProcedureOrder order = new ProcedureOrder();
        int updates;
        Orders() {
            order.setOrderId(42); order.setRecordId(7); order.setPatientId(3);
            order.setServiceCode("PT-LASIK"); order.setServiceName("LASIK");
            order.setReferralNotes("Referral"); order.setPaymentStatus("Pending");
            order.setStatus("Pending"); order.setSpecialistId(9);
        }
        public ProcedureOrder getOrderById(int id) { return order; }
        public MedicalRecord getMedicalRecordById(int id) {
            MedicalRecord record = new MedicalRecord(); record.setAppointmentStatus("In_Progress"); return record;
        }
        public List<ProcedureOrder> getTodoListByRecordId(int id) { return List.of(order); }
        public Patient getPatientById(int id) { return new Patient(); }
        public List<MedicalRecord> getPatientMedicalHistory(int id) { return List.of(); }
        public List<ProcedureOrder> getOrdersByPatientId(int id) { return List.of(order); }
        public boolean updateOrderStatus(int id,Integer specialist,String status) {
            updates++; order.setStatus(status); return true;
        }
        public boolean saveResults(int id,Integer specialist,String text,String conclusion,String status) {
            updates++; order.setStatus(status); return true;
        }
        public boolean updateMedicalRecordExaminationResult(int id,String result) { return true; }
    }
    static class Completion extends com.visioncare.dao.SpecialistCompletionDAO {
        final Orders orders;
        boolean closed;
        Completion(Orders orders) { this.orders=orders; }
        public void save(int id,int actor,String report,String conclusion,String status,boolean close) {
            orders.updates++; orders.order.setStatus(status); closed=close;
        }
    }
    static class Exchange {
        Map<String,Object> sessionValues = new HashMap<>(), attrs = new HashMap<>();
        Map<String,String> params = new HashMap<>();
        String redirect, forwarded;
        int status;
        HttpSession session = proxy(HttpSession.class,(p,m,a)-> {
            switch(m.getName()) {
                case "getAttribute": return sessionValues.get(a[0]);
                case "setAttribute": sessionValues.put((String)a[0],a[1]); return null;
                case "removeAttribute": sessionValues.remove(a[0]); return null;
                default: return null;
            }
        });
        HttpServletRequest request = proxy(HttpServletRequest.class,(p,m,a)-> {
            switch(m.getName()) {
                case "getSession": return session;
                case "getParameter": return params.get(a[0]);
                case "getContextPath": return "/SWP-project";
                case "setAttribute": attrs.put((String)a[0],a[1]); return null;
                case "getRequestDispatcher":
                    String path=(String)a[0];
                    return proxy(RequestDispatcher.class,(dp,dm,da)-> {forwarded=path;return null;});
                default: return null;
            }
        });
        HttpServletResponse response = proxy(HttpServletResponse.class,(p,m,a)-> {
            if(m.getName().equals("sendRedirect")) redirect=(String)a[0];
            if(m.getName().equals("sendError")) status=(Integer)a[0];
            return null;
        });
        Exchange(int role) {
            User user=new User(); user.setRoleId(role); user.setRole("medical_specialist"); user.setActorId(9);
            sessionValues.put("user",user); params.put("orderId","42"); params.put("patientId","3");
        }
    }
    @SuppressWarnings("unchecked")
    static <T> T proxy(Class<T> type,InvocationHandler handler) {
        return (T)Proxy.newProxyInstance(type.getClassLoader(),new Class<?>[]{type},handler);
    }
    static void inject(Object servlet,Orders orders) throws Exception {
        Field field=servlet.getClass().getDeclaredField("procedureOrderDAO");
        field.setAccessible(true); field.set(servlet,orders);
    }
    static void check(boolean ok,String message) { if(!ok) throw new AssertionError(message); }
    public static void main(String[] args) throws Exception {
        Orders orders=new Orders();
        SpecialistProcedureDetailServlet detail=new SpecialistProcedureDetailServlet(); inject(detail,orders);
        Completion completion=new Completion(orders);
        Field writer=SpecialistProcedureDetailServlet.class.getDeclaredField("completionDAO");
        writer.setAccessible(true); writer.set(detail,completion);
        Exchange get=new Exchange(4); detail.doGet(get.request,get.response);
        check("/views/specialist/specialist-procedure-detail.jsp".equals(get.forwarded),"Unpaid referral must open");
        check(Boolean.TRUE.equals(get.attrs.get("canEditProcedure")),"Active referral must remain editable by its assigned specialist");
        Exchange assigned=new Exchange(4);
        ((User)assigned.sessionValues.get("user")).setActorId(11);
        orders.order.setSpecialistId(11);
        detail.doGet(assigned.request,assigned.response);
        check(Boolean.TRUE.equals(assigned.attrs.get("canEditProcedure")),"Assigned specialist 11 must see action buttons");
        check("".equals(assigned.attrs.get("procedureReadOnlyReason")),"Editable case must not display a lock message");
        orders.order.setSpecialistId(9);
        detail.doGet(assigned.request,assigned.response);
        check(Boolean.FALSE.equals(assigned.attrs.get("canEditProcedure")),"Another specialist must remain read-only");
        check(((String)assigned.attrs.get("procedureReadOnlyReason")).contains("phân công"),"Read-only reason must identify assignment, not claim the visit ended");
        SpecialistPatientDetailServlet patient=new SpecialistPatientDetailServlet(); inject(patient,orders);
        Exchange profile=new Exchange(4); patient.doGet(profile.request,profile.response);
        check("/views/specialist/specialist-patient-detail.jsp".equals(profile.forwarded),"Unpaid patient profile must open");
        Exchange complete=new Exchange(4); complete.params.put("action","complete");
        complete.params.put("procedure_steps","Recorded procedure");
        complete.params.put("procedure_outcome","Recorded outcome");
        complete.params.put("conclusion","Recorded specialist conclusion");
        detail.doPost(complete.request,complete.response);
        check("Completed".equals(orders.order.getStatus()),"Unpaid surgery must complete");
        check("Pending".equals(orders.order.getPaymentStatus()),"Clinical completion must not mark payment paid");
        check(complete.sessionValues.containsKey("successMessage"),"Completion must report success");
        check(!completion.closed,"Returning results must leave the visit open");
        Exchange close=new Exchange(4); close.params.putAll(complete.params);
        close.params.put("action","completeAndClose");
        int beforeClose=orders.updates;
        detail.doPost(close.request,close.response);
        check(orders.updates==beforeClose,"Closing requires explicit confirmation about further doctor work");
        close.params.put("noFurtherDoctorWork","true");
        detail.doPost(close.request,close.response);
        check(completion.closed && orders.updates==beforeClose+1,"Confirmed specialist closure must use the atomic save path");
        int updates=orders.updates;
        Exchange denied=new Exchange(3); denied.params.put("action","complete");
        detail.doPost(denied.request,denied.response);
        check(denied.status==403 && orders.updates==updates,"Role restriction must remain");
        orders.order.setStatus("Pending");
        Exchange invalid=new Exchange(4); invalid.params.put("action","complete");
        detail.doPost(invalid.request,invalid.response);
        check(orders.updates==updates && invalid.sessionValues.containsKey("errorMessage"),
              "Missing clinical results must still be rejected");
        System.out.println("PASS: unpaid detail/profile/completion; payment unchanged; authorization and clinical validation preserved.");
    }
}
