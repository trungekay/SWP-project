import com.visioncare.controller.DirectorRefundServlet;
import com.visioncare.controller.StaffRefundServlet;
import com.visioncare.filter.AuthenticationFilter;
import com.visioncare.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.lang.reflect.*;
import java.util.*;

/** No database or HTTP server required: exercise authorization and compatibility routes. */
public class RefundAccessTest {
    static final String CONTEXT = "/SWP-project";
    static class Exchange {
        int status;
        String contentType;
        java.io.StringWriter body = new java.io.StringWriter();
        String redirect;
        boolean proceeded;
        Map<String,Object> attributes = new HashMap<>();
        HttpSession session;
        HttpServletRequest request;
        HttpServletResponse response;
        Exchange(User user, String path, String action) {
            attributes.put("user", user);
            session = proxy(HttpSession.class, (p,m,a) -> {
                if (m.getName().equals("getAttribute")) return attributes.get(a[0]);
                if (m.getName().equals("setAttribute")) { attributes.put((String)a[0],a[1]); return null; }
                return fallback(m);
            });
            request = proxy(HttpServletRequest.class, (p,m,a) -> {
                switch(m.getName()) {
                    case "getSession": return session;
                    case "getContextPath": return CONTEXT;
                    case "getRequestURI": return CONTEXT + path;
                    case "getServletPath": return path;
                    case "getParameter": return "action".equals(a[0]) ? action : ("status".equals(a[0]) ? "Pending" : null);
                    default: return fallback(m);
                }
            });
            response = proxy(HttpServletResponse.class, (p,m,a) -> {
                if (m.getName().equals("getWriter")) return new java.io.PrintWriter(body);
                if (m.getName().equals("setContentType")) contentType = (String)a[0];
                if (m.getName().equals("sendError") || m.getName().equals("setStatus")) status = (Integer)a[0];
                if (m.getName().equals("sendRedirect")) redirect = (String)a[0];
                return fallback(m);
            });
        }
    }
    @SuppressWarnings("unchecked")
    static <T> T proxy(Class<T> t, InvocationHandler h) { return (T)Proxy.newProxyInstance(t.getClassLoader(),new Class[]{t},h); }
    static Object fallback(Method m) {
        if (m.getReturnType() == boolean.class) return false;
        if (m.getReturnType() == int.class) return 0;
        if (m.getReturnType() == long.class) return 0L;
        return null;
    }
    static User user(int role) { User u=new User();u.setId(role);u.setRoleId(role);u.setRole(role==2?"director":role==5?"staff":"patient");return u; }
    static void invoke(HttpServlet servlet, String method, Exchange e) throws Exception {
        Method m=servlet.getClass().getDeclaredMethod(method,HttpServletRequest.class,HttpServletResponse.class);
        m.setAccessible(true); m.invoke(servlet,e.request,e.response);
    }
    static void require(boolean ok,String message) { if(!ok)throw new AssertionError(message); }
    public static void main(String[] args) throws Exception {
        int count=0;
        for(String path : new String[]{"/director/refunds","/director/reschedule-requests","/views/director/refund-requests.jsp","/views/admin/refund-management.jsp","/views/employee/reschedule-requests.jsp"}) {
            for(int role : new int[]{2,5,6}) {
                Exchange e=new Exchange(user(role),path,null);
                new AuthenticationFilter().doFilter(e.request,e.response,(req,res)->e.proceeded=true);
                require(role==2 ? e.proceeded : e.status==403,"Management route authorization: "+role+path); count++;
            }
        }
        Exchange e=new Exchange(null,"/director/refunds",null);
        new AuthenticationFilter().doFilter(e.request,e.response,(req,res)->{ throw new AssertionError("Anonymous request passed filter"); });
        require((CONTEXT+"/login").equals(e.redirect),"Anonymous management access");count++;
        e=new Exchange(user(5),"/staff/refunds",null);invoke(new StaffRefundServlet(),"doGet",e);
        require((CONTEXT+"/staff/appointments").equals(e.redirect),"Staff management page is removed");count++;
        for(String action : new String[]{"approve","reject"}) {
            e=new Exchange(user(5),"/staff/refunds",action);invoke(new StaffRefundServlet(),"doPost",e);
            require(e.status==403,"Staff cannot "+action+" refunds");count++;
            e=new Exchange(user(5),"/director/refunds",action);invoke(new DirectorRefundServlet(),"doPost",e);
            require(e.status==403,"Director endpoint rejects staff "+action);count++;
        }
        e=new Exchange(user(2),"/admin/refunds",null);invoke(new StaffRefundServlet(),"doGet",e);
        require((CONTEXT+"/director/refunds?status=Pending").equals(e.redirect),"Legacy refund URL must preserve filters");count++;
        e=new Exchange(user(2),"/admin/reschedule-requests",null);invoke(new StaffRefundServlet(),"doGet",e);
        require((CONTEXT+"/director/reschedule-requests?status=Pending").equals(e.redirect),"Legacy reschedule URL");count++;
        e=new Exchange(user(2),"/director/reschedule-requests","approve");invoke(new DirectorRefundServlet(),"doPost",e);
        require(e.status==405,"Reschedule navigation must not process refund approvals");count++;
        System.out.println("PASS: "+count+" refund management authorization and route checks.");
    }
}
