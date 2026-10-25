package com.visioncare.util;

import com.visioncare.dao.StaffInvoiceDAO;
import java.util.Map;

public final class StaffCheckoutPayments {
 private StaffCheckoutPayments() {}
 @FunctionalInterface public interface Receipts {PayOSUtil.VerifiedReceipt get(long orderCode);}
 public static String refresh(long orderCode,int invoiceId) throws Exception {
  return refresh(new StaffInvoiceDAO(),PayOSUtil::getVerifiedReceipt,orderCode,invoiceId);
 }
 public static String refresh(StaffInvoiceDAO dao,Receipts receipts,long orderCode,int invoiceId) throws Exception {
  Map<String,Object> payment=dao.payment(orderCode);
  if(payment==null || (invoiceId>0&&(Integer)payment.get("invoiceId")!=invoiceId)) throw new IllegalArgumentException("Mã QR không thuộc hóa đơn.");
  if("Paid".equals(payment.get("status")))return "Paid";
  PayOSUtil.VerifiedReceipt receipt=receipts.get(orderCode);
  if(receipt.orderCode!=orderCode)return "Pending";
  if("PAID".equals(receipt.status)) {
   long expected=(Long)payment.get("amount");
   if(receipt.amount!=expected||receipt.amountPaid<expected)throw new IllegalStateException("Số tiền PayOS không khớp yêu cầu.");
   // A creation response may have timed out before the customer paid the existing link.
   if("Creating".equals(payment.get("status"))) dao.qrCreated(orderCode,"https://pay.payos.vn/",null);
   dao.confirmQr(orderCode,expected);return "Paid";
  }
  if("CANCELLED".equals(receipt.status)||"EXPIRED".equals(receipt.status)){dao.cancelledQr(orderCode);return "Cancelled";}
  return "Pending";
 }
}
