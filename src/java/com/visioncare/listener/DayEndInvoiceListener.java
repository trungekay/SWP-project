package com.visioncare.listener;

import com.visioncare.dao.StaffInvoiceDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/** Rechecks after midnight and catches up after downtime; each invoice is locked and idempotent. */
@WebListener
public class DayEndInvoiceListener implements ServletContextListener {
    private ScheduledExecutorService worker;

    @Override public void contextInitialized(ServletContextEvent event) {
        worker=Executors.newSingleThreadScheduledExecutor(r->{
            Thread thread=new Thread(r,"day-end-invoice");thread.setDaemon(true);return thread;
        });
        worker.scheduleWithFixedDelay(()->{
            StaffInvoiceDAO invoices=new StaffInvoiceDAO();
            LocalDate today=LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            try {
                for(int id:invoices.dayEndCandidates(today)) {
                    if(Thread.currentThread().isInterrupted())return;
                    try {
                        if(invoices.closeConsultationAtDayEnd(id,today))
                            event.getServletContext().log("Day-end invoice automatically finalized: "+id);
                    }catch(Exception e){event.getServletContext().log("Day-end invoice reconciliation failed: "+id,e);}
                }
            }catch(Exception e){event.getServletContext().log("Day-end invoice task unavailable; will retry",e);}
        },30,60,TimeUnit.SECONDS);
    }

    @Override public void contextDestroyed(ServletContextEvent event) {
        if(worker!=null)worker.shutdownNow();
    }
}
