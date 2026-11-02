# Đổi lịch, hoàn tiền và hóa đơn cuối

## Kiểm tra trên giao diện

1. Bệnh nhân mở **Lịch sử hẹn khám**. Lịch đã thanh toán phí khám, còn trước giờ khám và chưa check-in có nút **Đổi bác sĩ / ca khám**. Chọn bác sĩ, ngày và ca trống. Phí khám, dịch vụ và hóa đơn đã trả được giữ nguyên; bác sĩ phụ trách trong hồ sơ chưa khám được cập nhật. Hệ thống dùng dữ liệu lịch trống của `WorkScheduleDAO`, dùng chung khung giờ đặt lịch và kiểm tra lại trong giao dịch khi lưu, chặn ca bị chiếm và trùng lịch bệnh nhân.
2. Hủy lịch và tạo yêu cầu refund theo điều kiện trước check-in hiện có. Director mở **Quản lý yêu cầu → Quản lý yêu cầu hoàn tiền**. Duyệt chuyển `Pending → Approved`; chưa chi trả và chưa giảm doanh thu. Từ chối cần nhập lý do, lưu riêng với lý do yêu cầu ban đầu. Lịch đã hủy không tự khôi phục khi bị từ chối refund.
3. Staff mở yêu cầu trên danh sách lịch hẹn, chọn **Xem / Xác nhận chi trả**, hoặc tìm hóa đơn trong **Quản lý hóa đơn & thanh toán → Xem hóa đơn**. Quyết định director và lý do từ chối hiển thị tại đây. Yêu cầu bị từ chối cũng có thể xem từ danh sách lịch hẹn.
   Trong bộ lọc **Trạng thái ghi nhận**, chọn **Chờ hoàn tiền** để xem các yêu cầu director đã duyệt nhưng staff chưa xác nhận chi trả. Mỗi dòng có nút **Xử lý hoàn tiền** dẫn thẳng đến phần xác nhận. Bộ lọc này vẫn kết hợp với tìm kiếm và ngày khám; yêu cầu đang chờ director hoặc bị từ chối không nằm trong danh sách. Sau xác nhận, hóa đơn chuyển sang bộ lọc **Đã hoàn tiền**.

4. Với yêu cầu hợp lệ đã được duyệt, staff thực hiện hoàn tiền bên ngoài rồi đánh dấu đã chi trả và xác nhận. Có thể ghi mã giao dịch/ghi chú và gửi ảnh PNG/JPEG tối đa 5 MB. Ảnh được kiểm tra nội dung thực, lưu trong database; staff/director/admin mới được truy cập ảnh. Director không có quyền xác nhận chi trả thay staff qua endpoint này.
5. Xác nhận thành công chuyển `Approved → Completed`, lưu nhân viên, thời điểm, ghi chú và ảnh. Hoàn phí khám do hủy trước check-in chuyển hóa đơn thành `Refunded`; hoàn từng khoản phát sinh giữ nguyên ca khám và hóa đơn gốc để tiếp tục đối chiếu phần còn lại. Chỉ lúc này doanh thu trừ số tiền thực hoàn. Chặn gửi xác nhận lặp và đường cập nhật trạng thái hóa đơn cũ; giao dịch tiền thu ban đầu được giữ lại để đối chiếu.
6. Hóa đơn bệnh nhân chỉ mở khi ca khám `Completed`, hóa đơn `Paid`, staff đã chốt `Invoice_Checkout.Finalized_At`, tiền thu bằng tổng và không có yêu cầu refund đang xử lý. Hóa đơn được hoàn từng khoản hiển thị dòng giảm trừ và tổng thực giữ sau hoàn. Kiểm tra cả quyền sở hữu và URL trực tiếp. Bản hóa đơn chỉ hiển thị các khoản thu, số lượng, đơn giá, thành tiền và tổng tiền đã thanh toán; không có phần cọc/còn thiếu.

## Email

Quyết định mới của director tạo thông báo bền vững trong `Refund_Request`. Email duyệt nói sẽ hoàn tiền trong vòng **1 tuần**; email từ chối ghi lý do director. Worker gửi theo cấu hình SMTP hiện có, tự thử lại khi lỗi, tối đa 10 lần. Director có nút gửi lại khi thất bại. Không gửi lại email cho dữ liệu lịch sử khi nâng cấp cấu trúc.

Kiểm thử dùng bộ gửi giả; chưa xác minh nhận thư thật trong hộp thư. Không gọi SMTP hoặc cổng thanh toán trong kiểm thử.

## Database và doanh thu

`Refund_Request` bổ sung quyết định, thông tin chi trả, ảnh giao dịch và trạng thái gửi email. Script chuẩn là `database/eye_clinic_db.sql`; bản sao trong `src/java/database` đã được bỏ khi đồng bộ main. Listener khi khởi động ứng dụng chỉ nâng cấp cấu trúc còn thiếu trong database đang dùng; không reset dữ liệu.

Yêu cầu lịch sử `Approved` chỉ chuyển `Completed` nếu hóa đơn đã là `Refunded`. Yêu cầu cũ mâu thuẫn với điều kiện trước check-in được giữ để đối chiếu; không tự ghi nhận một khoản chi trả mới hoặc bịa thêm giao dịch.

Doanh thu ròng dựa trên tiền thu thành công và khoản tiền đã ghi nhận từ dữ liệu cũ, trừ `Refund_Request.Completed`. Giữ cách lọc kỳ theo **ngày tạo hóa đơn** của báo cáo hiện tại. Hoàn tiền một phần chỉ trừ phần thực hoàn; dư nợ chưa thu không được tính thành doanh thu khi chuyển trạng thái.

Các bảng liên quan: `Appointment`, `Work_Schedule`, `Medical_Record`, `Master_Invoice`, `Invoice_Checkout`, `Invoice_Checkout_Item`, `Payment_Transaction`, `Refund_Request`; thông tin người dùng lấy từ `Patient`, `Account`, `Employee_Profile`.

## Kiểm thử

Trước khi xóa bộ test theo yêu cầu của nhóm, các luồng đã được kiểm thử bằng giao dịch SQL rồi rollback toàn bộ lịch/hóa đơn thử. Không tạo tài khoản mới hay dữ liệu mẫu tồn tại sau kiểm thử. Nhóm sẽ kiểm thử thủ công; không chạy lại toàn bộ file tạo database trên database cần giữ dữ liệu.

Đã kiểm tra biên dịch Java/JSP, build WAR, kiểm thử chuyên viên hiện có và các trang HTTP sau khi reload Tomcat.


## Hoàn thuốc / thủ thuật sau check-in

Staff vào **Quản lý hóa đơn & thanh toán → Xem hóa đơn → Hoàn thuốc / thủ thuật chưa sử dụng → Tạo yêu cầu hoàn khoản phát sinh**. Chọn khoản, số lượng, lý do và xác nhận đã đối chiếu thuốc chưa giao / thủ thuật chưa thực hiện. Số tiền tính trên server theo giá đã thu, không nhập tiền tùy ý.

- Thuốc: phải có khoản thu trong hóa đơn đã chốt, có giá và đủ bằng chứng tiền đã thu. Nhân viên chịu trách nhiệm xác nhận thuốc chưa giao; hệ thống hiện chưa có sổ bàn giao thuốc độc lập, nên không tự suy đoán tình trạng giao thuốc.
- Thủ thuật: phải có thanh toán riêng được xác nhận hoặc nằm trong hóa đơn đã thanh toán đủ; chưa có kết quả, chưa hoàn tất. Khoản khấu trừ phí khám không được hoàn lần hai. Chỉ định được hủy khỏi hàng đợi khi staff lập yêu cầu, tránh vẫn thực hiện trong lúc xét duyệt; từ chối refund không tự phục hồi chỉ định bệnh nhân đã từ chối.
- Không hoàn phí khám đã sử dụng qua luồng này. Không hủy lịch khám hoặc xóa đơn thuốc/bệnh án khi hoàn khoản phát sinh.
- `Refund_Request.Request_Kind` phân biệt `Appointment` và `Items`. `Refund_Request_Item` lưu tên khoản, mã gốc, số lượng và đơn giá; xác nhận chưa sử dụng có nhân viên/thời điểm riêng. Mỗi hóa đơn chỉ có một yêu cầu đang chờ duyệt/chi trả; sau khi hoàn có thể yêu cầu tiếp phần số lượng chưa hoàn.
- Director thấy đầy đủ các khoản rồi duyệt/từ chối và gửi email theo luồng hiện có. Staff xác nhận chi trả và đính kèm ảnh như trước. Cả duyệt và chi trả đều kiểm tra lại điều kiện, số lượng còn được hoàn và tiền thực thu còn lại.
- Doanh thu chỉ trừ tiền đã hoàn thực tế. Danh sách hóa đơn thể hiện **Đã hoàn tiền một phần** và vẫn tìm được bằng bộ lọc **Đã hoàn tiền**. Hóa đơn giữ nguyên các khoản gốc, ghi rõ số đã hoàn và tiền thực giữ; không thu lại phần vừa hoàn khi staff chốt phần còn lại.

Yêu cầu cũ không có danh sách khoản không được tự suy diễn thành hoàn thuốc/thủ thuật: cần đối chiếu đúng khoản đã trả và chưa sử dụng. Không tự gán một phê duyệt cũ cho khoản tiền khác.

Kiểm thử bổ sung: `ItemRefundWorkflowTest` có 38 kiểm tra thực tế trong giao dịch rollback (thuốc, số lượng, thủ thuật, giá/tiền thu, duyệt/chi trả, doanh thu, chốt hóa đơn và hóa đơn bệnh nhân); 45 kiểm tra luồng cũ tiếp tục đạt. Không gửi email, chuyển tiền hoặc lưu lịch mẫu trong kiểm thử.

Khi đối chiếu/xóa dữ liệu thử có quan hệ, xử lý `Refund_Request_Item` trước `Refund_Request`; khóa ngoại giữ các dòng hoàn tiền không bị tách khỏi yêu cầu gốc. Các script khởi tạo SQL đã bao gồm bảng mới.


## Trang chi tiết duyệt và kiểm tra email (30/10/2026)

Danh sách director đã rút gọn còn các thông tin chính; nút **Xem chi tiết** nằm ngay sau mã yêu cầu. Trang `/director/refunds/detail?id=...` hiển thị bệnh nhân, email nhận, lịch/hóa đơn, lý do, từng khoản được hoàn, người tạo/duyệt và trạng thái gửi email. Yêu cầu chờ duyệt có hai form **Duyệt hoàn tiền** và **Từ chối hoàn tiền** (bắt buộc lý do), có kiểm tra quyền và token CSRF. Sau quyết định quay lại đúng trang chi tiết.

Email trạng thái `Sent` nghĩa là SMTP đã chấp nhận thư, không chứng minh thư đã vào Inbox hoặc bệnh nhân đã đọc. Trang chi tiết hiển thị rõ điều này; lỗi có thể gửi lại sau khi kiểm tra cấu hình và địa chỉ nhận. Yêu cầu `Pending` chưa phát sinh email quyết định. Thư kiểm thử dùng cùng kênh SMTP, có nhãn kiểm thử và không làm thay đổi phê duyệt/chi trả hoặc trạng thái gửi quyết định.

Các câu tiếng Việt trong `patient-reschedule.js` dùng escape Unicode trong mã ASCII, kèm phiên bản URL mới. Cách này tránh lỗi ký tự từ bản JavaScript cache/charset cũ; đã kiểm tra nội dung trước khi xóa bộ test theo yêu cầu của nhóm.

## Email sau khi bệnh nhân đổi bác sĩ / ca khám

Sau khi đổi lịch thành công và transaction đã commit, hệ thống gửi email tới địa chỉ trong tài khoản bệnh nhân. Email ghi mã APT, họ tên, bác sĩ/ngày/giờ của lịch cũ và lịch mới, giờ Việt Nam, phí khám đã thanh toán được giữ nguyên và nhắc đến trước 10–15 phút. Thông tin cũ/mới được chụp trong cùng transaction đổi lịch, không đọc lại lịch ở một request khác.

Đổi lịch bị từ chối hoặc gửi lại cùng ca không gửi email. Nếu SMTP lỗi, lịch mới vẫn có hiệu lực: giao diện thông báo đổi thành công kèm cảnh báo chưa gửi được thư, yêu cầu xem lịch sử đặt lịch. Đây là gửi trực tiếp có giới hạn thời gian kết nối, chưa có hàng đợi thử lại tự động như email quyết định hoàn tiền. SMTP chấp nhận thư không bảo đảm thư vào Inbox.

Trước khi xóa bộ test theo yêu cầu của nhóm, luồng email đổi lịch đã kiểm tra bằng sender giả và database transaction rollback; không gửi email hoặc đổi lịch thật trong kiểm thử. Không cần thay đổi schema database.
