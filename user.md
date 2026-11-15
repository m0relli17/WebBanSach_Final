# Danh mục Tài khoản, Dữ liệu Kiểm thử & Kịch bản Thuyết trình WebBanSach

> **Tài liệu hướng dẫn kiểm thử toàn diện và kịch bản demo mẫu** phục vụ thuyết trình đánh giá sản phẩm **WebBanSach**.

---

## 1. Danh sách Tài khoản Kiểm thử (Test Accounts)

### 1.1. Tài khoản Khách hàng (Customer Users)

| Tên tài khoản (`TaiKhoan`) | Mật khẩu (`MatKhau`) | Họ và tên | Email | Số điện thoại | Trạng thái | Email xác minh | Mục đích kiểm thử |
|---|---|---|---|---|---|---|---|
| **`testuser`** | `12345678` | Nguyễn Văn Test | `testuser@gmail.com` | `0912345678` | Hoạt động | **Đã xác minh** | Tài khoản chuẩn để test mua sách, thanh toán COD / Credit Card, xem giỏ hàng và theo dõi đơn hàng có sẵn. |
| **`testotp`** | `12345678` | Trần Văn OTP | `testotp@gmail.com` | `0987654321` | Hoạt động | **Chưa xác minh** | Dùng để kiểm thử luồng đăng nhập tự động chuyển hướng sang màn hình xác minh OTP 6 chữ số. |
| **`customer_vip`** | `12345678` | Lê Hoàng VIP | `vip@webbansach.local` | `0903112233` | Hoạt động | **Đã xác minh** | Khách hàng VIP với địa chỉ giao hàng đầy đủ tại Quận 3, TP.HCM. |
| **`customer_locked`** | `12345678` | Phạm Khóa | `locked@gmail.com` | `0933445566` | **Đã khóa** | Đã xác minh | Dùng để kiểm thử xử lý khi tài khoản bị khóa (Hệ thống từ chối đăng nhập với thông báo lỗi rõ ràng). |

> [!NOTE]  
> Tất cả mật khẩu khách hàng đều được băm bằng thuật toán an toàn **PBKDF2-SHA256 (210.000 vòng lặp)**. Nếu có dữ liệu văn bản thuần trong CSDL, hệ thống sẽ tự động nâng cấp sang mã băm PBKDF2 ngay trong lần đăng nhập thành công đầu tiên.

---

### 1.2. Tài khoản Quản trị viên (Admin & Seller Users)

Truy cập trang quản trị tại: **[http://localhost:8089/admin.html](http://localhost:8089/admin.html)** (hoặc port IIS Express tương ứng).

| Tên tài khoản | Mật khẩu | Họ tên hiển thị | Quyền hạn |
|---|---|---|---|
| **`admin`** | `123456` | Quản Trị Viên Hệ Thống | Quản lý sách, tồn kho, điều phối đơn hàng, cập nhật trạng thái và duyệt đánh giá |
| **`manager`** | `123456` | Điều Phối Viên Đơn Hàng | Điều phối và xử lý trạng thái đơn hàng của khách |

---

## 2. Thông tin Thẻ Tín dụng Kiểm thử (Credit Card Test Credentials)

Tại màn hình thanh toán **[http://localhost:8089/checkout.html](http://localhost:8089/checkout.html)**, chọn hình thức **"Thẻ tín dụng / Ghi nợ"** và nhập thông tin:

| Loại thẻ | Số thẻ mẫu | Ngày hết hạn | CVV/CVC | Tên in trên thẻ | Kết quả mong đợi |
|---|---|---|---|---|---|
| **Visa** | `4532 1122 3344 5566` | `12/28` | `888` | `NGUYEN VAN TEST` | Thanh toán trực tuyến thành công |
| **MasterCard** | `5412 7512 3412 3456` | `10/27` | `555` | `NGUYEN VAN TEST` | Thanh toán trực tuyến thành công |
| **Amex** | `3782 8224 6310 005` | `08/29` | `1234` | `NGUYEN VAN TEST` | Nhận diện thẻ Amex, thanh toán thành công |
| **Thẻ lỗi (Số thẻ ngắn)** | `4532 1122` | `12/28` | `888` | `NGUYEN VAN TEST` | Bị chặn: Thông báo số thẻ 13–19 chữ số |
| **Thẻ lỗi (Sai hạn thẻ)** | `4532 1122 3344 5566` | `13/28` | `888` | `NGUYEN VAN TEST` | Bị chặn: Thông báo định dạng MM/YY không hợp lệ |
| **Thẻ lỗi (Sai CVV)** | `4532 1122 3344 5566` | `12/28` | `12` | `NGUYEN VAN TEST` | Bị chặn: Mã bảo mật CVV phải có 3 hoặc 4 chữ số |

---

## 3. Bảng Vòng đời Trạng thái Đơn hàng (Order Lifecycle)

| Mã trạng thái | Tên trạng thái | Màu huy hiệu | Quyền Khách hàng (`tracking.html`) | Quyền Quản trị viên (`admin.html`) |
|---|---|---|---|---|
| `0` | **Chờ xử lý** | Vàng (`bg-warning text-dark`) | Có nút **"Hủy đơn"** (hoàn trả tồn kho tự động) | Chuyển sang 1 (Đã đóng gói) hoặc 4 (Đã hủy) |
| `1` | **Đã đóng gói** | Xanh nhạt (`bg-info text-dark`) | Theo dõi tiến độ | Chuyển sang 2 (Đang giao) |
| `2` | **Đang giao** | Xanh dương (`bg-primary`) | Theo dõi tiến độ | Chuyển sang 3 (Đã giao) |
| `3` | **Đã giao** | Xanh lá (`bg-success`) | Đơn hoàn tất, hiển thị dấu check | Khóa cập nhật (Đã kết thúc đơn) |
| `4` | **Đã hủy** | Xám (`bg-secondary`) | Hiển thị biểu tượng cấm | Khóa cập nhật (Đơn đã bị hủy) |

---

## 4. Kịch bản Thuyết trình Demo Chuẩn (Presentation Walkthrough)

Dưới đây là kịch bản thuyết trình từng bước từ góc độ người dùng (End-to-End User Journey) sẵn sàng cho buổi báo cáo:

```
[BƯỚC 1: Trang chủ] 
-> Giới thiệu Slideshow 2 banner, Thanh tìm kiếm Debounce + Clear X
-> Giới thiệu Danh mục tiếng Việt Unicode & Bộ lọc sắp xếp
   
[BƯỚC 2: Chi tiết sách & Đánh giá]
-> Bấm vào sách "Luyện Thi TOEFL iBT Cấp Tốc"
-> Xem Nhà xuất bản Giáo Dục Việt Nam, Tác giả, Giá gốc & Giảm giá 25%
-> Tăng số lượng lên 2 -> Bấm "Chọn Mua"

[BƯỚC 3: Giỏ hàng & Kiểm soát Mua hàng]
-> Vào "Giỏ hàng"
-> Giới thiệu: Tạm tính theo giá gốc, Tiết kiệm giảm giá, Tiến trình Freeship 150k
-> Khi chưa đăng nhập: Nút có cảnh báo "🔒 Cần đăng nhập để tiến hành mua hàng"
-> Bấm nút "Mua Hàng": Hệ thống chặn mua và chuyển hướng sang login.html?redirect=checkout.html

[BƯỚC 4: Đăng ký & Validation mật khẩu]
-> Chuyển sang trang "Đăng ký thành viên mới"
-> Nhập mật khẩu có dấu cách ("pass word123") -> Bấm Đăng ký -> Bị chặn với thông báo rõ ràng
-> Nhập mật khẩu < 8 ký tự -> Bị chặn
-> Nhập mật khẩu chuẩn từ 8-128 ký tự không dấu cách -> Hợp lệ

[BƯỚC 5: Đăng nhập & Chuyển hướng Thanh toán]
-> Đăng nhập với tài khoản "testuser" / "12345678"
-> Hệ thống nhận diện tham số redirect và đưa thẳng người dùng vào "checkout.html"
-> Thông tin người nhận tiếng Việt tự động điền sẵn
-> Chọn thanh toán Thẻ tín dụng hoặc COD -> Bấm "Xác nhận Đặt hàng" -> Hiện mã đơn hàng thành công

[BƯỚC 6: Theo dõi đơn hàng Khách hàng]
-> Vào "Đơn hàng của tôi" (tracking.html)
-> Đơn mới hiển thị "Chờ xử lý" (màu vàng) kèm nút "Hủy đơn"
-> Các đơn đã giao thành công (#8, #6) hiển thị huy hiệu xanh "Đã giao" khớp 100% với Admin

[BƯỚC 7: Quản trị Admin Dashboard]
-> Vào "admin.html", đăng nhập bằng "admin" / "123456"
-> Xem danh sách đơn hàng, tìm kiếm đơn mới tạo
-> Đổi trạng thái từ "0 - Chờ xử lý" sang "1 - Đã đóng gói" -> Hệ thống cập nhật thời gian thực
-> Giới thiệu quản lý sách và kiểm duyệt đánh giá
```
