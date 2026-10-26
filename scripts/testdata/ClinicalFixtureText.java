/** Narrative based on the consultation, procedure status and prescribed supply already present. */
public final class ClinicalFixtureText {
 private ClinicalFixtureText(){}
 public static String diagnosis(String code){return switch(code){
  case "EXAM_DONE_EXTRAS" -> "Chắp/lẹo mi mắt; kèm khô mắt.";
  case "EXAM_DONE_BASE","PAID_FINAL" -> "Khám mắt tổng quát định kỳ.";
  default -> null; // Not examined: do not invent a clinical diagnosis.
 };}
 public static String result(String code){return switch(code){
  case "EXAM_DONE_EXTRAS" -> "Đã thực hiện chích rạch chắp lẹo mi mắt theo chỉ định; có kê nước mắt nhân tạo.";
  case "EXAM_DONE_BASE","PAID_FINAL" -> "Đã hoàn tất khám mắt tổng quát; không ghi nhận chỉ định thủ thuật hoặc đơn thuốc bổ sung trong hồ sơ.";
  default -> null;
 };}
 public static String conclusion(String code){return switch(code){
  case "EXAM_DONE_EXTRAS" -> "Đã hoàn tất tiểu phẫu; dùng thuốc theo đơn và tái khám theo hướng dẫn của bác sĩ.";
  case "EXAM_DONE_BASE","PAID_FINAL" -> "Kết thúc khám, không có chỉ định can thiệp bổ sung tại lần khám này.";
  default -> null;
 };}
 public static String complaint(String code){return code.equals("EXAM_DONE_EXTRAS")?"Chắp/lẹo mi mắt, khô mắt.":"Khám mắt định kỳ.";}
}
