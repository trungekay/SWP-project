# Tự chốt hóa đơn cuối ngày

`DayEndInvoiceListener` kiểm tra mỗi 60 giây, bắt đầu sau khi ứng dụng khởi động 30 giây. Mốc ngày dùng `Asia/Ho_Chi_Minh`, độc lập múi giờ máy chủ. Ngày khám phải nhỏ hơn ngày hiện tại: ca ngày 30/10 được xét từ 00:00 ngày 31/10. Khi máy chủ ngừng chạy qua nửa đêm, lần khởi động sau xử lý bù các ca cũ đủ điều kiện.

Chỉ tự chốt khi bác sĩ đã cập nhật lịch thành `Completed`, hóa đơn chỉ có phí khám dương, tiền thực thu đúng bằng phí khám và tổng đã lưu. Bằng chứng thu phải có giao dịch `Success` hoặc khoản thu chuyển tiếp `Invoice_Checkout.Opening_Paid`. Không suy ra đã thu chỉ từ nhãn `Paid`.

Ca có thuốc/dịch vụ phát sinh (kể cả dòng phát sinh cũ đã ghi nhận từ chối), giá chưa rõ, thiếu/thừa tiền, giao dịch đang xử lý, yêu cầu hoàn tiền chưa từ chối, hoặc đã hoàn tiền sẽ giữ lại cho staff đối chiếu. Không tự hủy chỉ định, bỏ thuốc hoặc thay đổi hồ sơ khám.

Mỗi hóa đơn được kiểm tra và chốt trong transaction `SERIALIZABLE`, dùng cùng cơ chế khóa/snapshot của checkout thủ công. Chạy lại không tạo lần chốt thứ hai. Không tạo giao dịch thu tiền mới, không đổi số tiền và không gửi email. Doanh thu không tăng do việc chốt; ngày tạo hóa đơn và giao dịch thu gốc được giữ nguyên.

`Invoice_Checkout.Finalized_At` lưu thời điểm UTC thực tế xử lý; `Finalized_By` để NULL cho tác vụ hệ thống. Giao diện chi tiết/xuất hóa đơn hiển thị **Hệ thống tự chốt cuối ngày** và giờ Việt Nam. Không mượn danh tính staff. Danh sách hóa đơn chuyển thành **Hoàn thành**, bệnh nhân xem được hóa đơn cuối cùng theo kiểm tra quyền sở hữu hiện có.

Không cần bảng/cột hoặc script SQL mới. Khi triển khai bản build mới hoặc khởi động lại ứng dụng, tác vụ bắt đầu hoạt động. Các máy khác phải chạy ứng dụng bản mới; tác vụ không chạy khi Tomcat tắt.

Trước khi xóa bộ test theo yêu cầu của nhóm, chức năng đã kiểm thử bằng database thật trong transaction rollback, kiểm tra thời điểm xét, các trường hợp bị loại, khả năng chạy lại, hóa đơn bệnh nhân và doanh thu không đổi. Không giữ dữ liệu mẫu hoặc gửi tiền/email.
