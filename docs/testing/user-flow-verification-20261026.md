# Xác minh bộ test FLOW-20261026

- BOOKED: APT-111 / INV-77; Thanh toán một phần; tổng=200000; đã thu=200000; còn thu=0
- CANCEL_PENDING: APT-112 / INV-78; Thanh toán một phần; tổng=200000; đã thu=200000; còn thu=0
- REFUND_ELIGIBLE: APT-113 / INV-79; Đã hủy; tổng=200000; đã thu=200000; còn thu=0
- DOCTOR_CANCEL: APT-114 / INV-80; Đã hủy; tổng=200000; đã thu=200000; còn thu=0
- REFUND_PENDING: APT-115 / INV-81; Đã hủy; tổng=200000; đã thu=200000; còn thu=0
- EXPIRED: APT-116 / INV-82; Chưa thanh toán; tổng=200000; đã thu=0; còn thu=0
- EXAM_DONE_BASE: APT-117 / INV-83; Khám xong; tổng=200000; đã thu=200000; còn thu=0
- EXAM_DONE_EXTRAS: APT-118 / INV-84; Khám xong; tổng=545000; đã thu=200000; còn thu=345000
- PAID_FINAL: APT-119 / INV-85; Hoàn thành; tổng=200000; đã thu=200000; còn thu=0

## Kiểm tra khóa ngoại toàn database

| Khóa ngoại | Bảng con → bảng cha | Bản ghi mồ côi | Disabled / Not trusted |
|---|---|---:|---|
| FK_ProcedurePayment_Order | Procedure_Payment_Request → Procedure_Order | 0 | 0 / 0 |
| FK_ProcedurePayment_Employee | Procedure_Payment_Request → Employee_Profile | 0 | 0 / 0 |
| FK_ProcedurePayment_Transaction | Procedure_Payment_Request → Payment_Transaction | 0 | 0 / 0 |
| FK__Invoice_C__Invoi__0880433F | Invoice_Checkout → Master_Invoice | 0 | 0 / 0 |
| FK__Invoice_C__Final__0A688BB1 | Invoice_Checkout → Employee_Profile | 0 | 0 / 0 |
| FK__Invoice_C__Invoi__0D44F85C | Invoice_Checkout_Item → Invoice_Checkout | 0 | 0 / 0 |
| FK__Invoice_C__Chang__1209AD79 | Invoice_Checkout_Item → Employee_Profile | 0 | 0 / 0 |
| FK__Invoice_C__Invoi__15DA3E5D | Invoice_Checkout_Payment → Invoice_Checkout | 0 | 0 / 0 |
| FK__Account__Role_ID__17F790F9 | Account → Role | 0 | 0 / 0 |
| FK__Invoice_C__Creat__18B6AB08 | Invoice_Checkout_Payment → Employee_Profile | 0 | 0 / 0 |
| FK__Account__Role_ID__18EBB532 | Account → Role | 0 | 0 / 0 |
| FK__Account__Role_ID__19DFD96B | Account → Role | 0 | 0 / 0 |
| FK__Account__Role_ID__1AD3FDA4 | Account → Role | 0 | 0 / 0 |
| FK__Invoice_C__Trans__1B9317B3 | Invoice_Checkout_Payment → Payment_Transaction | 0 | 0 / 0 |
| FK__Employee___Accou__1BC821DD | Employee_Profile → Account | 0 | 0 / 0 |
| FK__Employee___Accou__1CBC4616 | Employee_Profile → Account | 0 | 0 / 0 |
| FK__Employee___Accou__1DB06A4F | Employee_Profile → Account | 0 | 0 / 0 |
| FK__Employee___Accou__1EA48E88 | Employee_Profile → Account | 0 | 0 / 0 |
| FK__Employee___Room___1F98B2C1 | Employee_Profile → Room | 0 | 0 / 0 |
| FK__Employee___Room___208CD6FA | Employee_Profile → Room | 0 | 0 / 0 |
| FK__Employee___Room___2180FB33 | Employee_Profile → Room | 0 | 0 / 0 |
| FK__Employee___Room___22751F6C | Employee_Profile → Room | 0 | 0 / 0 |
| FK__Work_Sche__Docto__236943A5 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Docto__245D67DE | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Docto__25518C17 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Docto__2645B050 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Speci__2739D489 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Speci__282DF8C2 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Speci__29221CFB | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Work_Sche__Speci__2A164134 | Work_Schedule → Employee_Profile | 0 | 0 / 0 |
| FK__Patient__Account__2B0A656D | Patient → Account | 0 | 0 / 0 |
| FK__Patient__Account__2BFE89A6 | Patient → Account | 0 | 0 / 0 |
| FK__Patient__Account__2CF2ADDF | Patient → Account | 0 | 0 / 0 |
| FK__Patient__Account__2DE6D218 | Patient → Account | 0 | 0 / 0 |
| FK__Appointme__Patie__2EDAF651 | Appointment → Patient | 0 | 0 / 0 |
| FK__Appointme__Patie__2FCF1A8A | Appointment → Patient | 0 | 0 / 0 |
| FK__Appointme__Patie__30C33EC3 | Appointment → Patient | 0 | 0 / 0 |
| FK__Appointme__Patie__31B762FC | Appointment → Patient | 0 | 0 / 0 |
| FK__Appointme__Sched__32AB8735 | Appointment → Work_Schedule | 0 | 0 / 0 |
| FK__Appointme__Sched__339FAB6E | Appointment → Work_Schedule | 0 | 0 / 0 |
| FK__Appointme__Sched__3493CFA7 | Appointment → Work_Schedule | 0 | 0 / 0 |
| FK__Appointme__Sched__3587F3E0 | Appointment → Work_Schedule | 0 | 0 / 0 |
| FK__Appointme__Staff__367C1819 | Appointment → Employee_Profile | 0 | 0 / 0 |
| FK__Appointme__Staff__37703C52 | Appointment → Employee_Profile | 0 | 0 / 0 |
| FK__Appointme__Staff__3864608B | Appointment → Employee_Profile | 0 | 0 / 0 |
| FK__Appointme__Staff__395884C4 | Appointment → Employee_Profile | 0 | 0 / 0 |
| FK__Master_In__Appoi__3A4CA8FD | Master_Invoice → Appointment | 0 | 0 / 0 |
| FK__Master_In__Appoi__3B40CD36 | Master_Invoice → Appointment | 0 | 0 / 0 |
| FK__Master_In__Appoi__3C34F16F | Master_Invoice → Appointment | 0 | 0 / 0 |
| FK__Master_In__Appoi__3D2915A8 | Master_Invoice → Appointment | 0 | 0 / 0 |
| FK__Payment_T__Invoi__3E1D39E1 | Payment_Transaction → Master_Invoice | 0 | 0 / 0 |
| FK__Payment_T__Invoi__3F115E1A | Payment_Transaction → Master_Invoice | 0 | 0 / 0 |
| FK__Payment_T__Invoi__40058253 | Payment_Transaction → Master_Invoice | 0 | 0 / 0 |
| FK__Payment_T__Invoi__40F9A68C | Payment_Transaction → Master_Invoice | 0 | 0 / 0 |
| FK__Medical_R__Appoi__41EDCAC5 | Medical_Record → Appointment | 0 | 0 / 0 |
| FK__Medical_R__Appoi__42E1EEFE | Medical_Record → Appointment | 0 | 0 / 0 |
| FK__Medical_R__Appoi__43D61337 | Medical_Record → Appointment | 0 | 0 / 0 |
| FK__Medical_R__Appoi__44CA3770 | Medical_Record → Appointment | 0 | 0 / 0 |
| FK__Medical_R__Docto__45BE5BA9 | Medical_Record → Employee_Profile | 0 | 0 / 0 |
| FK__Medical_R__Docto__46B27FE2 | Medical_Record → Employee_Profile | 0 | 0 / 0 |
| FK__Medical_R__Docto__47A6A41B | Medical_Record → Employee_Profile | 0 | 0 / 0 |
| FK__Medical_R__Docto__489AC854 | Medical_Record → Employee_Profile | 0 | 0 / 0 |
| FK__Prescript__Recor__498EEC8D | Prescription → Medical_Record | 0 | 0 / 0 |
| FK__Prescript__Recor__4A8310C6 | Prescription → Medical_Record | 0 | 0 / 0 |
| FK__Prescript__Recor__4B7734FF | Prescription → Medical_Record | 0 | 0 / 0 |
| FK__Prescript__Recor__4C6B5938 | Prescription → Medical_Record | 0 | 0 / 0 |
| FK__Prescript__Presc__4D5F7D71 | Prescription_Detail → Prescription | 0 | 0 / 0 |
| FK__Procedure__Recor__4E53A1AA | Procedure_Order → Medical_Record | 0 | 0 / 0 |
| FK__Procedure__Recor__4F47C5E3 | Procedure_Order → Medical_Record | 0 | 0 / 0 |
| FK__Procedure__Recor__503BEA1C | Procedure_Order → Medical_Record | 0 | 0 / 0 |
| FK__Procedure__Recor__51300E55 | Procedure_Order → Medical_Record | 0 | 0 / 0 |
| FK__Procedure__Servi__5224328E | Procedure_Order → Service_Catalog | 0 | 0 / 0 |
| FK__Procedure__Servi__531856C7 | Procedure_Order → Service_Catalog | 0 | 0 / 0 |
| FK__Procedure__Servi__540C7B00 | Procedure_Order → Service_Catalog | 0 | 0 / 0 |
| FK__Procedure__Servi__55009F39 | Procedure_Order → Service_Catalog | 0 | 0 / 0 |
| FK__Procedure__Speci__55F4C372 | Procedure_Order → Employee_Profile | 0 | 0 / 0 |
| FK__Procedure__Speci__56E8E7AB | Procedure_Order → Employee_Profile | 0 | 0 / 0 |
| FK__Procedure__Speci__57DD0BE4 | Procedure_Order → Employee_Profile | 0 | 0 / 0 |
| FK__Procedure__Speci__58D1301D | Procedure_Order → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Appro__59C55456 | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Appro__5AB9788F | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Appro__5BAD9CC8 | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Appro__5CA1C101 | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Reque__5D95E53A | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Reque__5E8A0973 | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Reque__5F7E2DAC | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Reque__607251E5 | Leave_Cancel_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Leave_Can__Sched__6166761E | Leave_Cancel_Request → Work_Schedule | 0 | 0 / 0 |
| FK__Leave_Can__Sched__625A9A57 | Leave_Cancel_Request → Work_Schedule | 0 | 0 / 0 |
| FK__Leave_Can__Sched__634EBE90 | Leave_Cancel_Request → Work_Schedule | 0 | 0 / 0 |
| FK__Leave_Can__Sched__6442E2C9 | Leave_Cancel_Request → Work_Schedule | 0 | 0 / 0 |
| FK__Refund_Re__appro__65370702 | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__appro__662B2B3B | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__appro__671F4F74 | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__appro__681373AD | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__creat__690797E6 | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__creat__69FBBC1F | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK_Examination_Detail_Record | Examination_Detail → Medical_Record | 0 | 0 / 0 |
| FK__Refund_Re__creat__6AEFE058 | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__creat__6BE40491 | Refund_Request → Employee_Profile | 0 | 0 / 0 |
| FK__Refund_Re__Invoi__6CD828CA | Refund_Request → Master_Invoice | 0 | 0 / 0 |
| FK__Refund_Re__Invoi__6DCC4D03 | Refund_Request → Master_Invoice | 0 | 0 / 0 |
| FK__Refund_Re__Invoi__6EC0713C | Refund_Request → Master_Invoice | 0 | 0 / 0 |
| FK__Refund_Re__Invoi__6FB49575 | Refund_Request → Master_Invoice | 0 | 0 / 0 |
| FK__Refund_Re__Patie__70A8B9AE | Refund_Request → Patient | 0 | 0 / 0 |
| FK__Refund_Re__Patie__719CDDE7 | Refund_Request → Patient | 0 | 0 / 0 |
| FK__Refund_Re__Patie__72910220 | Refund_Request → Patient | 0 | 0 / 0 |
| FK__Refund_Re__Patie__73852659 | Refund_Request → Patient | 0 | 0 / 0 |

Số khóa ngoại kiểm tra: 108; tổng bản ghi mồ côi: 0.

PASS: 89 kiểm tra bộ ca. Chỉ đọc; không gọi PayOS, không gửi email, không thay đổi trạng thái test.
