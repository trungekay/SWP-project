import com.visioncare.dao.SpecialistCompletionDAO;
import java.lang.reflect.*;
import java.sql.*;
import java.util.*;

/** Transaction/ownership regressions with JDBC doubles; never opens a real database. */
public class SpecialistCompletionTransactionTest {
    static class Database implements InvocationHandler {
        boolean closed, otherPending, foreignOwner, failClose, committed, rolledBack;
        String visitStatus="In_Progress", report, conclusion;
        int reportWrites, appointmentWrites;
        List<String> sqls=new ArrayList<>();
        Connection connection() { return proxy(Connection.class,this); }
        public Object invoke(Object p,Method m,Object[] a) {
            switch(m.getName()) {
                case "prepareStatement":
                    String sql=(String)a[0]; sqls.add(sql);
                    Map<Integer,Object> params=new HashMap<>();
                    return proxy(PreparedStatement.class,(sp,sm,sa)->{
                        if(sm.getName().startsWith("set") && sa!=null && sa.length==2) {
                            params.put((Integer)sa[0],sa[1]); return null;
                        }
                        if(sm.getName().equals("executeQuery")) {
                            boolean parent=sql.contains("a.checkin_time");
                            boolean hasRow=parent || otherPending;
                            final boolean[] next={hasRow};
                            return proxy(ResultSet.class,(rp,rm,ra)->{
                                switch(rm.getName()) {
                                    case "next": boolean value=next[0]; next[0]=false; return value;
                                    case "getString": return visitStatus;
                                    case "getInt": return "Appointment_ID".equals(ra[0]) ? 19 : 7;
                                    case "getTimestamp": return Timestamp.valueOf("2026-10-28 10:00:00");
                                    default: return null;
                                }
                            });
                        }
                        if(sm.getName().equals("executeUpdate")) {
                            if(sql.startsWith("UPDATE Procedure_Order")) {
                                if(foreignOwner) return 0;
                                reportWrites++; report=(String)params.get(1); conclusion=(String)params.get(2); return 1;
                            }
                            if(sql.startsWith("UPDATE Appointment")) {
                                if(failClose) throw new SQLException("simulated appointment write failure");
                                appointmentWrites++; closed=true; return 1;
                            }
                            throw new AssertionError("Unexpected write: "+sql);
                        }
                        return null;
                    });
                case "commit": committed=true; return null;
                case "rollback": rolledBack=true; reportWrites=0; appointmentWrites=0; closed=false; report=null; return null;
                default: return null;
            }
        }
    }
    @SuppressWarnings("unchecked")
    static <T> T proxy(Class<T> type,InvocationHandler handler) {
        return (T)Proxy.newProxyInstance(type.getClassLoader(),new Class<?>[]{type},handler);
    }
    static void check(boolean condition,String message) { if(!condition) throw new AssertionError(message); }
    static void run(Database db,boolean close) throws Exception {
        new SpecialistCompletionDAO(db::connection).save(42,9,"Specialist report","Specialist conclusion","Completed",close);
    }
    static void rejected(Database db) throws Exception {
        try { run(db,true); throw new AssertionError("Expected rejection"); }
        catch(IllegalStateException | SQLException expected) {}
        check(db.rolledBack && !db.committed && db.reportWrites==0 && !db.closed,"Failure must roll back the report and visit");
    }
    public static void main(String[] args) throws Exception {
        Database returned=new Database(); run(returned,false);
        check(returned.committed && returned.reportWrites==1 && !returned.closed,"Return results leaves visit open");
        Database ended=new Database(); run(ended,true);
        check(ended.committed && ended.closed && ended.appointmentWrites==1,"Specialist can close visit");
        check(ended.report.contains("VISIT_CLOSURE") && ended.report.contains("#9"),"Closure identifies responsible specialist");
        check("Specialist conclusion".equals(ended.conclusion),"Clinical conclusion stays separate");
        com.visioncare.model.StaffInvoice invoice=new com.visioncare.model.StaffInvoice();
        invoice.appointmentStatus="Completed"; invoice.invoiceStatus="Unpaid";
        invoice.items.add(new com.visioncare.model.StaffInvoice.Item("PROCEDURE:42","LASIK","Thủ thuật",1,100000,false,false,false));
        check(invoice.isCanCheckout() && invoice.getDue()==100000,
              "Specialist closure hands a performed, still unpaid service to staff checkout");
        check(ended.sqls.stream().noneMatch(s->s.contains("Payment")||s.contains("UPDATE Medical_Record")||s.contains("Prescription")),
              "Clinical completion must not depend on payment, rewrite doctor findings or prescribe");
        Database pending=new Database(); pending.otherPending=true; rejected(pending);
        Database other=new Database(); other.foreignOwner=true; rejected(other);
        Database failed=new Database(); failed.failClose=true; rejected(failed);
        Database alreadyEnded=new Database(); alreadyEnded.visitStatus="Completed"; rejected(alreadyEnded);
        Database cancelled=new Database(); cancelled.visitStatus="Canceled"; rejected(cancelled);
        System.out.println("PASS: returned results, specialist closure, audit, pending orders, ownership, atomic rollback and closed/cancelled visits.");
    }
}
