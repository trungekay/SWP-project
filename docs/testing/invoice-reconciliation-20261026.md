# Đối chiếu toàn bộ hóa đơn cũ — 26/10/2026

Chỉ đọc database. Không xóa giao dịch, không tự xác nhận thu tiền/hoàn tiền. Số đã thu kế thừa từ dữ liệu cũ được tách khỏi tổng giao dịch chi tiết. Chênh giữa tổng gốc và tổng hiện tại có thể là khoản phát sinh chưa được staff chốt, không tự động kết luận sai chứng từ.

| Invoice | APT | Clinical | Financial | Tổng gốc | Tổng theo khoản thu | Giao dịch Success | Khoản kế thừa thiếu giao dịch chi tiết | Đã ghi nhận thu | Chênh lệch còn lại | Khóa thu | Chốt | Ghi chú |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
|1|1|Completed|Paid|300000|200000|300000|0|300000|0|true|false|Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt; Tiền đã ghi nhận vượt tổng hóa đơn|
|2|3|Canceled|Canceled|250000|250000|0|0|0|250000|true|false||
|3|4|Completed|Paid|250000|383000|0|250000|250000|133000|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|4|5|Completed|Paid|250000|200000|0|250000|250000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt; Tiền đã ghi nhận vượt tổng hóa đơn|
|5|6|Confirmed|Partial_Paid|250000|200000|0|200000|200000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|6|7|Canceled|Canceled|250000|250000|0|0|0|250000|true|false||
|7|8|Completed|Paid|1500000|1500000|1350000|150000|1500000|0|false|true|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát|
|8|9|Completed|Paid|150000|338000|0|150000|150000|188000|true|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|9|10|Confirmed|Paid|150000|150000|0|150000|150000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát|
|10|11|Completed|Paid|18000000|18576000|0|18000000|18000000|576000|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|11|12|In_Progress|Partial_Paid|18000000|200000|0|200000|200000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|12|13|Canceled|Canceled|18000000|18000000|0|0|0|18000000|true|false||
|13|14|Completed|Partial_Paid|395000|395000|0|300000|300000|95000|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát|
|14|15|Completed|Paid|300000|300000|0|300000|300000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát|
|15|16|Confirmed|Partial_Paid|300000|200000|0|200000|200000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|16|17|Completed|Paid|12000000|12495000|0|12000000|12000000|495000|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|17|18|Confirmed|Partial_Paid|12000000|200000|0|200000|200000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|18|19|Completed|Paid|500000|988000|0|500000|500000|488000|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|19|20|Confirmed|Partial_Paid|500000|200000|0|200000|200000|0|false|false|Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát; Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt|
|20|21|Canceled|Canceled|250000|250000|0|0|0|250000|true|false||
|21|22|Canceled|Canceled|200000|200000|0|0|0|200000|true|false||
|22|23|Confirmed|Paid|200000|200000|400000|0|400000|0|false|false|Tiền đã ghi nhận vượt tổng hóa đơn|
|23|24|Canceled|Canceled|200000|200000|0|0|0|200000|true|false||
|24|25|Canceled|Canceled|500000|500000|0|0|0|500000|true|false||
|25|26|Confirmed|Paid|500000|500000|500000|0|500000|0|false|false||
|26|27|Canceled|Canceled|300000|300000|0|0|0|300000|true|false||
|27|28|Canceled|Canceled|300000|300000|0|0|0|300000|true|false||
|28|29|Confirmed|Paid|200000|200000|200000|0|200000|0|false|false||
|29|30|Canceled|Paid|200000|200000|200000|0|200000|0|true|false||
|30|31|Confirmed|Paid|200000|200000|200000|0|200000|0|false|false||
|31|32|Confirmed|Paid|200000|200000|200000|0|200000|0|false|false||
|32|66|Confirmed|Paid|200000|200000|200000|0|200000|0|false|false||
|56|90|Canceled|Refunded|200000|200000|200000|0|200000|0|true|false||
|62|96|In_Progress|Partial_Paid|450000|450000|200000|0|200000|250000|false|false||
|77|111|Confirmed|Paid|200000|200000|200000|0|200000|0|false|false||
|78|112|Pending|Paid|200000|200000|200000|0|200000|0|false|false||
|79|113|Canceled|Paid|200000|200000|200000|0|200000|0|true|false||
|80|114|Canceled|Paid|200000|200000|200000|0|200000|0|true|false||
|81|115|Canceled|Paid|200000|200000|200000|0|200000|0|true|false||
|82|116|Canceled|Canceled|200000|200000|0|0|0|200000|true|false||
|83|117|Completed|Paid|200000|200000|200000|0|200000|0|false|false||
|84|118|Completed|Partial_Paid|545000|545000|200000|0|200000|345000|false|false||
|85|119|Completed|Paid|200000|200000|200000|0|200000|0|false|true||

## Lịch Confirmed thiếu hóa đơn

|Appointment_ID|Patient_ID|Work_Date|
|---|---|---|
|33|2|2026-10-21|
|34|4|2026-10-21|
|46|1|2026-10-21|
|48|6|2026-10-21|
|52|4|2026-10-21|
|56|1|2026-10-22|
|57|2|2026-10-22|
|58|7|2026-10-22|
|59|8|2026-10-22|
|60|3|2026-10-22|
|61|4|2026-10-22|
|62|9|2026-10-22|
|63|5|2026-10-22|
|64|6|2026-10-22|
|65|10|2026-10-22|

Số dòng: 15.

## Lịch có nhiều master invoice

|Appointment_ID|Invoice_Count|
|---|---|

Số dòng: 0.

## Cặp giao dịch nghi trùng (chỉ cảnh báo, chưa đủ chứng cứ xóa)

|Invoice_ID|First_Transaction|Second_Transaction|Amount|First_Date|Second_Date|
|---|---|---|---|---|---|
|22|3|4|200000|2026-10-18 14:54:18.4000816|2026-10-18 14:54:19.5086844|

Số dòng: 1.

## Refund Pending không đủ điều kiện duyệt hủy trước check-in

|Refund_ID|Invoice_ID|Appointment_ID|Status|checkin_time|Refund_Amount|
|---|---|---|---|---|---|
|2|8|9|Completed|2026-10-18 08:19:54.6551278|150000|

Số dòng: 1.

## Refund Approved nhưng hóa đơn chưa chuyển Refunded

|Refund_ID|Invoice_ID|Appointment_ID|Invoice_Status|Appointment_Status|Refund_Amount|
|---|---|---|---|---|---|
|1|1|1|Paid|Completed|50000|

Số dòng: 1.

## Phương thức thanh toán

|Payment_Gateway|Transaction_Count|Recorded_Amount|
|---|---|---|
|Cash|2|1550000|
|QR_Banking|19|4000000|

Số dòng: 2.

## Kết quả

- Tổng hóa đơn: 43; đọc được: 43; lỗi tải: 0.
- Lỗi số liệu hiển thị patient/staff: 0.
- Hóa đơn có khoản kế thừa thiếu giao dịch chi tiết: 15.
- Hóa đơn tổng gốc khác tổng các khoản hiện tại: 12.
- Hóa đơn tiền đã thu vượt tổng: 3.

Những ca thiếu chứng từ/giao dịch nghi trùng cần đối chiếu nguồn; audit không tự thêm/xóa phiếu thu hoặc thay quyết định refund.
