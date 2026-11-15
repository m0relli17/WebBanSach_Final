# Hướng dẫn Cài đặt & Vận hành Hệ thống WebBanSach trên Visual Studio

> Tài liệu hướng dẫn chi tiết các bước cài đặt môi trường, cấu hình cơ sở dữ liệu và vận hành hệ thống **WebBanSach** trên môi trường máy tính phát triển Windows với **Microsoft Visual Studio & SQL Server**.

---

## 💻 Các Bước Cài đặt & Khởi chạy Dự án

### Bước 1: Khởi tạo Cơ sở Dữ liệu SQL Server
1. Mở **SQL Server Management Studio (SSMS)** và kết nối tới máy chủ SQL cục bộ (ví dụ: `.\SQLEXPRESS` hoặc `localhost`).
2. Mở và thực thi lần lượt các file script theo thứ tự:
   - **`00_TaoDatabaseMoi.sql`**: Khởi tạo cấu trúc các bảng của cơ sở dữ liệu `BSDB2`.
   - **`01_NangCapDatabase.sql`**: Thêm các cột nâng cấp (`EmailVerified`, `GhiChu`, `Tracking`, chỉ mục hiệu năng).
   - **`02_DuLieuKiemThu.sql`**: Nạp dữ liệu danh mục sách, hình ảnh, tài khoản mẫu và đánh giá có dấu tiếng Việt Unicode.

> [!IMPORTANT]
> Khi chạy `02_DuLieuKiemThu.sql` qua lệnh sqlcmd, luôn kèm cờ `-f 65001` để đảm bảo không bị lỗi font tiếng Việt.

### Bước 2: Mở Dự án trong Visual Studio
1. Khởi động **Visual Studio 2019/2022** (yêu cầu cài đặt workload *.NET desktop development* và *ASP.NET and web development*).
2. Mở file giải pháp `WebBanSach.sln`.
3. Kiểm tra file `backend/Web.config`:
   - Xác nhận chuỗi kết nối `BSDBContext` chỉ đúng tên server SQL của bạn (mặc định: `Data Source=.\SQLEXPRESS;Initial Catalog=BSDB2;Integrated Security=True;`).

### Bước 3: Cấu hình Chế độ Gửi Mã OTP Email
Trong `backend/Web.config`, hệ thống hỗ trợ 2 chế độ OTP:
1. **Chế độ cục bộ (Mặc định - `LocalPickup`):**
   ```xml
   <add key="EmailOtpMode" value="LocalPickup" />
   ```
   Mã OTP sẽ tự động được ghi thành file `.eml` trong thư mục `backend/App_Data/OtpEmails`. Bạn chỉ cần mở file để lấy mã 6 số mà không cần cấu hình email thực.
2. **Chế độ gửi qua Gmail thực (`Smtp`):**
   ```xml
   <add key="EmailOtpMode" value="Smtp" />
   <add key="GmailSenderEmail" value="YOUR_EMAIL@gmail.com" />
   <add key="GmailAppPassword" value="YOUR_APP_PASSWORD" />
   ```
   *(Sử dụng Mật khẩu Ứng dụng tạo từ tài khoản Google Security, không dùng mật khẩu đăng nhập chính)*.

### Bước 4: Chạy Ứng dụng
1. Click chuột phải vào project `backend` $\rightarrow$ chọn **Set as Startup Project**.
2. Nhấn **Ctrl + F5** (hoặc **F5**) để khởi chạy với IIS Express.
3. Trình duyệt sẽ mở tại `http://localhost:[Port]/index.html`.

---

## 🔍 Kiểm tra Nhanh các Tính năng Chính

1. **Khám phá sách & Tìm kiếm:**
   - Thử tìm kiếm "tiếng anh" hoặc click các thẻ danh mục nhanh.
   - Thử sắp xếp sách theo Giá thấp/cao hoặc Bán chạy.
2. **Chi tiết sách & Đánh giá:**
   - Xem thông tin sách, tăng giảm số lượng, xem nhận xét 5 sao tiếng Việt.
   - Bấm **"Chọn Mua"** để thêm vào giỏ hàng.
3. **Giỏ hàng & Kiểm soát mua hàng:**
   - Kiểm tra Tạm tính theo giá gốc, Tiết kiệm giảm giá, Phí ship (Freeship từ 150k).
   - Khi chưa đăng nhập, nút **"Mua Hàng"** có cảnh báo khóa và click vào sẽ tự động chuyển hướng sang trang đăng nhập.
4. **Đăng nhập & Thanh toán:**
   - Đăng nhập bằng tài khoản `testuser` / `12345678`.
   - Hệ thống tự động chuyển tiếp tới `checkout.html`.
   - Chọn phương thức thanh toán (COD hoặc Thẻ tín dụng) và xác nhận đơn hàng.
5. **Theo dõi đơn hàng:**
   - Vào `tracking.html` để kiểm tra đơn hàng vừa tạo (trạng thái *Chờ xử lý* kèm nút *Hủy đơn*).
6. **Bảng điều khiển Quản trị (Admin):**
   - Vào `admin.html`, đăng nhập bằng `admin` / `123456`.
   - Cập nhật trạng thái đơn hàng sang *Đã đóng gói* hoặc *Đã giao*.
