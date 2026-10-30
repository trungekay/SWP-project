package com.visioncare.model;

import java.util.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/** Monetary values are integer VND; all totals are computed on the server. */
public class StaffInvoice {
 public int id, appointmentId;
 public String patientName, phone, date, appointmentStatus, invoiceStatus, finalizedAt, cashierName;
 public long baseAmount, paid, recordedTotal, priorPaid, refundedAmount;
 public boolean finalized, hasActiveRefund;
 public List<Item> items = new ArrayList<>();
 public Map<String,Object> activePayment;
 public List<Map<String,Object>> transactions = new ArrayList<>();
 public static class Item {
  public String key, name, type;
  public int quantity;
  public long unitPrice, refundedAmount;
  public int refundedQuantity;
  public boolean removable, declined, unpriced, unperformed;
  public Item(String key,String name,String type,int quantity,long unitPrice,boolean removable,boolean unpriced,boolean unperformed) {
   if(quantity<=0 || unitPrice<0) throw new IllegalArgumentException("Dữ liệu giá hoặc số lượng không hợp lệ.");
   this.key=key;this.name=name;this.type=type;this.quantity=quantity;this.unitPrice=unitPrice;this.removable=removable;this.unpriced=unpriced;this.unperformed=unperformed;
  }
  public String getKey(){return key;} public String getName(){return name;} public String getType(){return type;}
  public int getQuantity(){return quantity;} public int getRefundedQuantity(){return refundedQuantity;} public long getRefundedAmount(){return refundedAmount;} public long getUnitPrice(){return unitPrice;} public long getAmount(){return Math.multiplyExact(unitPrice,quantity);}
  public boolean isRemovable(){return removable;} public boolean isDeclined(){return declined;} public boolean isUnpriced(){return unpriced;} public boolean isUnperformed(){return unperformed;}
 }
 public int getId(){return id;} public int getAppointmentId(){return appointmentId;}
 public String getPatientName(){return patientName;} public String getPhone(){return phone;} public String getDate(){return date;}
 public String getAppointmentStatus(){return appointmentStatus;} public String getInvoiceStatus(){return invoiceStatus;}
 public String getFinalizedAt(){return finalizedAt;} public String getCashierName(){return cashierName;}
 public boolean isFinalized(){return finalized;} public long getPaid(){return paid;} public long getPriorPaid(){return priorPaid;}
 public List<Item> getItems(){return items;} public List<Map<String,Object>> getTransactions(){return transactions;}
 public Map<String,Object> getActivePayment(){return activePayment;}
 public long getRefundedAmount(){return refundedAmount;}
 public long getNetPaid(){return Math.max(0,paid-refundedAmount);}
 public long getNetTotal(){return Math.max(0,getTotal()-refundedAmount);}
 public long getRecordedTotal(){return recordedTotal;}
 public long getTotal(){long total=0; for(Item item:items) if(!item.declined) total=Math.addExact(total,item.getAmount());return total;}
 public long getDue(){return isBlocked()?0:Math.max(0,getTotal()-paid);}
 public long getOutstanding(){return Math.max(0,getTotal()-paid);}
 public long getOverpaid(){return Math.max(0,paid-getTotal());}
 public boolean isBlocked(){return "Canceled".equals(appointmentStatus)||"Canceled".equals(invoiceStatus)||"Refunded".equals(invoiceStatus)||hasActiveRefund;}
 public boolean isClinicalComplete(){return "Completed".equals(appointmentStatus);}
 public boolean isUnpriced(){return items.stream().anyMatch(i->!i.declined&&i.unpriced);}
 public boolean isUnperformed(){return items.stream().anyMatch(i->!i.declined&&i.unperformed);}
 public boolean isCanEdit(){return !finalized&&!isBlocked()&&activePayment==null&&isClinicalComplete();}
 public boolean isCanCheckout(){return isCanEdit()&&!isUnpriced()&&!isUnperformed()&&getOverpaid()==0;}
 public InvoiceProgress getProgress(){return InvoiceProgress.resolve(id>0,appointmentStatus,invoiceStatus,finalized&&!isBlocked()&&getDue()==0,paid>0);}
 public String getPaymentLabel(){return refundedAmount>0&&!isBlocked()?"Đã hoàn tiền một phần":getProgress().getLabel();}
 public String getProgressColor(){return refundedAmount>0&&!isBlocked()?"refunded":getProgress().getColor();}
 public String fingerprint(){
  try {StringBuilder s=new StringBuilder(id+":"+paid+":"+appointmentStatus+":"+invoiceStatus+":"+hasActiveRefund);
   for(Item i:items)s.append('|').append(i.key).append(':').append(i.quantity).append(':').append(i.unitPrice).append(':').append(i.declined).append(':').append(i.unpriced).append(':').append(i.unperformed);
   return java.util.HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(s.toString().getBytes(StandardCharsets.UTF_8)));
  }catch(Exception e){throw new IllegalStateException(e);}
 }
}
