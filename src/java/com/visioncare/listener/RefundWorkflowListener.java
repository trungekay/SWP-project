package com.visioncare.listener;
import com.visioncare.dao.*;
import com.visioncare.util.EmailUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.util.*;
import java.util.concurrent.*;
@WebListener
public class RefundWorkflowListener implements ServletContextListener {
 @FunctionalInterface public interface Sender {void send(Map<String,Object> mail)throws Exception;}
 private ScheduledExecutorService worker;
 public static boolean dispatch(RefundMailDAO dao,Sender sender)throws Exception {
  Map<String,Object> mail=dao.claim();if(mail==null)return false;
  try{sender.send(mail);dao.finish((Integer)mail.get("id"),true,null);}catch(Exception e){dao.finish((Integer)mail.get("id"),false,e.getMessage());}return true;
 }
 @Override public void contextInitialized(ServletContextEvent event){
  try(var c=DBContext.getConnection()){RefundWorkflowSchema.ensure(c);}catch(Exception e){throw new IllegalStateException("Cannot upgrade refund workflow schema",e);}
  worker=Executors.newSingleThreadScheduledExecutor(r->{Thread t=new Thread(r,"refund-notification");t.setDaemon(true);return t;});
  worker.scheduleWithFixedDelay(()->{try{RefundMailDAO dao=new RefundMailDAO();for(int n=0;n<5;n++)if(!dispatch(dao,EmailUtil::sendRefundDecisionEmail))break;}catch(Exception e){event.getServletContext().log("Refund notification queue unavailable",e);}},15,30,TimeUnit.SECONDS);
 }
 @Override public void contextDestroyed(ServletContextEvent event){if(worker!=null)worker.shutdownNow();}
}
