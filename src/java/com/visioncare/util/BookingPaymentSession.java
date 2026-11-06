package com.visioncare.util;

import jakarta.servlet.http.HttpSession;
import java.net.URI;

/** Reuse the original gateway QR when a patient resumes an unpaid booking. */
public final class BookingPaymentSession {
    private BookingPaymentSession() {}
    @FunctionalInterface public interface Links {
        PayOSUtil.PaymentLinkResult create(long order, int amount, String description, String cancel, String back);
    }
    public static PayOSUtil.PaymentLinkResult link(HttpSession session, int appointment, int amount,
            String cancel, String back) {
        return link(session, appointment, amount, cancel, back, PayOSUtil::createPaymentLink);
    }
    public static PayOSUtil.PaymentLinkResult link(HttpSession session, int appointment, int amount,
            String cancel, String back, Links gateway) {
        synchronized (session) {
            String key="bookingPayment:"+appointment;
            Object saved=session.getAttribute(key);
            if (saved instanceof Saved prior && prior.amount==amount) return prior.link;
            Object original=session.getAttribute("payos_order_"+appointment);
            long order=original instanceof Long ? (Long)original
                    : (long)appointment*1000000L+(System.currentTimeMillis()/1000L%1000000L);
            session.setAttribute("payos_order_"+appointment,order);
            PayOSUtil.PaymentLinkResult result=gateway.create(order,amount,"VC"+appointment,cancel,back);
            if (result!=null && result.success) {
                // Existing PayOS orders may omit bank QR data. Encode their verified
                // checkout link instead of falling back to an unrelated static transfer.
                if (result.qrCode==null || result.qrCode.isBlank()) {
                    if (result.checkoutUrl==null) throw new IllegalStateException("Không lấy được QR thanh toán.");
                    URI url=URI.create(result.checkoutUrl);
                    if (!"https".equalsIgnoreCase(url.getScheme()) || !"pay.payos.vn".equalsIgnoreCase(url.getHost()))
                        throw new IllegalStateException("Đường dẫn thanh toán không hợp lệ.");
                    result.qrCode=result.checkoutUrl;
                }
                session.setAttribute(key,new Saved(amount,result));
            }
            return result;
        }
    }
    private record Saved(int amount, PayOSUtil.PaymentLinkResult link) {}
    public static boolean matches(int appointment,long order,long expected,PayOSUtil.VerifiedReceipt receipt) {
        return appointment>0 && expected>0 && (order==appointment || order/1000000L==appointment)
                && receipt!=null && receipt.orderCode==order && "PAID".equalsIgnoreCase(receipt.status)
                && receipt.amount==expected && receipt.amountPaid>=expected;
    }
}
