import com.visioncare.util.PaymentMethod;

public class PaymentMethodTest {
 public static void main(String[] args) {
  String[][] cases={{"Cash","Cash"},{"Cash_At_Counter","Cash"},{" cash ","Cash"},
   {"QR_Banking","QR_Banking"},{"VietQR_Banking","QR_Banking"},{"PayOS_Checkout","QR_Banking"},
   {"Bank_Transfer","QR_Banking"},{"VNPay","QR_Banking"}};
  for(String[] c:cases)if(!c[1].equals(PaymentMethod.canonical(c[0])))throw new AssertionError(c[0]);
  for(String value:new String[]{null,"","Test_Seed","Demo_Seed","Previously_Paid","invalid"}){
   try{PaymentMethod.canonical(value);throw new AssertionError("Invalid method accepted: "+value);}catch(IllegalArgumentException expected){}
  }
  System.out.println("PASS: 14 canonical payment-method cases.");
 }
}
