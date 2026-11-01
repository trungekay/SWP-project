package com.visioncare.model;

import java.time.LocalDate;

/** One daily attendance cohort, with net receipts attributed to its appointment date. */
public class ConversionReportDay {
    private final LocalDate date;
    private final long total, arrived, cancelled, absent, pending, revenue;
    public ConversionReportDay(LocalDate date, long total, long arrived, long cancelled,
            long absent, long pending, long revenue) {
        this.date=date; this.total=total; this.arrived=arrived; this.cancelled=cancelled;
        this.absent=absent; this.pending=pending; this.revenue=revenue;
    }
    public LocalDate getDate(){return date;}
    public long getTotal(){return total;}
    public long getArrived(){return arrived;}
    public long getCancelled(){return cancelled;}
    public long getAbsent(){return absent;}
    public long getPending(){return pending;}
    public long getRevenue(){return revenue;}
}
