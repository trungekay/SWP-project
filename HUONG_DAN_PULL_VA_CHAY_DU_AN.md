# 🚀 Hướng Dẫn Kéo Code (Git Pull) & Chạy Dự Án VisionCare

Tài liệu này hướng dẫn các thành viên trong nhóm thiết lập và chạy dự án đầy đủ **100% chức năng & đủ 16 dịch vụ khám mắt** sau khi `git pull`.

---

## ⚡ Cách 1: Tự Động 1-Click (Khuyên Dùng - Nhanh Nhất)

Sau khi kéo code về bằng lệnh `git pull origin main`:

1. **Khởi tạo / Đồng bộ Database:**
   * Bạn chỉ cần **nhấp đúp chuột (Double click)** vào file:
     👉 **`setup_database.bat`** (ở ngay thư mục gốc của dự án).
   * Script sẽ tự động:
     - Đọc tài khoản SQL Server trong `src/java/db.properties`.
     - Tự động tạo database `eye_clinic_db` nếu máy bạn chưa có.
     - Tự động nạp đủ **19 bảng và toàn bộ 16 dịch vụ khám mắt**.
     - Thông báo thành công: `KHOI TAO THANH CONG DATABASE EYE_CLINIC_DB VOI DU 16 DICH VU!`.

2. **Chạy ứng dụng:**
   * Mở dự án trên **NetBeans** hoặc **IntelliJ**.
   * Nhấn **Run** (chạy Tomcat).
   * *(Lưu ý: Ngay cả khi bạn quên chạy script, code Java có sẵn `DatabaseInitializerListener` sẽ tự động phát hiện và bơm đủ 16 dịch vụ vào database khi Tomcat khởi động).*

---

## 🛠️ Cách 2: Khôi Phục Thủ Công Qua SSMS (SQL Server Management Studio)

Nếu bạn quen dùng SSMS:

### Cách A: Dùng file Backup `.bak` (Khuyên dùng)
1. Mở SSMS, kết nối vào SQL Server của bạn.
2. Chuột phải vào thư mục **Databases** -> Chọn **Restore Database...**
3. Chọn **Device** -> Bấm nút `...` -> Chọn file:
   👉 **`database/eye_clinic_db.bak`**
4. Bấm **OK** để khôi phục toàn bộ database 100% nguyên bản.

### Cách B: Dùng file Script `.sql`
1. Mở file: 👉 **`database/eye_clinic_db.sql`** trong SSMS.
2. Nhấn **Execute (F5)** để chạy script tạo bảng và nạp dữ liệu.

---

## ⚙️ Cấu Hình Kết Nối Database (Nếu máy bạn dùng mật khẩu khác)
Nếu mật khẩu `sa` của bạn không phải là `123`:
* Mở file: **`src/java/db.properties`**
* Đổi `db.password` thành mật khẩu SQL Server trên máy bạn:
  ```properties
  db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
  db.url=jdbc:sqlserver://localhost:1433;databaseName=eye_clinic_db;encrypt=true;trustServerCertificate=true;
  db.username=sa
  db.password=MẬT_KHẨU_CỦA_BẠN
  ```

---

## 📋 Danh Sách 16 Dịch Vụ Khám Mắt Chuẩn Trong Hệ Thống:
1. **NK-01**: Khám mắt tổng quát & Soi đáy mắt (200.000 ₫)
2. **KX-02**: Đo khúc xạ và tư vấn kính (150.000 ₫)
3. **LS-03**: Khám tiền phẫu & Tư vấn xóa cận LASIK/SMILE (500.000 ₫)
4. **PE-04**: Khám mắt trẻ em và tư vấn nhược thị (300.000 ₫)
5. **TT-05**: Khám tầm soát & Tư vấn phẫu thuật Phaco (300.000 ₫)
6. **GL-06**: Đo nhãn áp & Tầm soát Glaucoma (250.000 ₫)
7. **KX-MAY**: Đo khúc xạ máy (100.000 ₫)
8. **OCT-DM**: Chụp OCT đáy mắt (400.000 ₫)
9. **KM-CVS**: Khám & Điều trị Khô mắt (200.000 ₫)
10. **KM-DM**: Khám & Tầm soát Đáy mắt - Võng mạc tiểu đường (300.000 ₫)
11. **PT-LASIK**: Phẫu thuật Femto-LASIK hai mắt (18.000.000 ₫)
12. **PT-SMILE**: Phẫu thuật ReLEx SMILE xóa cận (42.000.000 ₫)
13. **PT-PHACO**: Phẫu thuật Phaco đặt thủy tinh thể nhân tạo (12.000.000 ₫)
14. **TP-LEO**: Chích rạch chắp lẹo mi mắt (250.000 ₫)
15. **TP-LEDAO**: Bơm thông rửa lệ đạo (300.000 ₫)
16. **TP-YAG**: Bắn Laser YAG bao sau đục (1.500.000 ₫)
