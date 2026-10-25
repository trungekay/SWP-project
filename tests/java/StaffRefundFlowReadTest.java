import com.visioncare.dao.*;
import com.visioncare.model.Appointment;
import java.util.*;
import java.sql.*;
public class StaffRefundFlowReadTest {
 public static void main(String[] args) throws Exception {
  DriverManager.setLoginTimeout(5);
  AppointmentDAO dao = new AppointmentDAO();
  Set<Integer> eligible = new HashSet<>();
  for (Map<String,Object> inv : new RefundDAO().getInvoicesForStaffRefundSelection()) eligible.add((Integer)inv.get("appointmentId"));
  if (!RefundPolicy.isRefundableCancellationReason(RefundPolicy.PATIENT_AT_COUNTER)
      || !RefundPolicy.isRefundableCancellationReason(RefundPolicy.DOCTOR_UNAVAILABLE)
      || !RefundPolicy.isRefundableCancellationReason("Đã duyệt yêu cầu hủy lịch của bệnh nhân")) throw new AssertionError("Valid cancellation channel cannot proceed to refund");
  for(String reason:new String[]{"Hệ thống: Hết hạn thanh toán", "Báo vắng mặt: Không đến", "Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác", "", null}) {
   if(RefundPolicy.isRefundableCancellationReason(reason)) throw new AssertionError("Invalid refund cancellation reason");
  }
  Map<Integer,Map<String,Object>> activeRefunds = new RefundDAO().getActiveRefundsForStaffAppointments();
  for(Map.Entry<Integer,Map<String,Object>> active:activeRefunds.entrySet()) {
   if(eligible.contains(active.getKey())) throw new AssertionError("An existing refund must be shown instead of creating a duplicate");
   if(active.getValue().get("code")==null || active.getValue().get("statusLabel")==null) throw new AssertionError("Existing refund has no visible status");
  }
  int count=0;
  for(Appointment a:dao.getStaffAppointments(null,"RefundEligible",null,null)) {
   if(!eligible.contains(a.getId()) || !"Canceled".equals(a.getStatus()) || a.getCheckinTime()!=null) throw new AssertionError("Invalid refund action APT-"+a.getId());
   count++;
  }
  if(count!=eligible.size())throw new AssertionError("Refund filter and button eligibility disagree");
  int cancellations=0;
  for(Appointment a:dao.getStaffAppointments(null,"CancellationRequested",null,null)) {
   if(!a.isCancellationRequested() || eligible.contains(a.getId()))throw new AssertionError("Cancellation not yet approved APT-"+a.getId());
   cancellations++;
  }
  System.out.println("PASS: live read-only staff filters; refund eligible="+count+", waiting for cancellation approval="+cancellations+", visible existing refunds="+activeRefunds.size());
 }
}
