# Danh mục Tài khoản & Dữ liệu Kiểm thử Hệ thống WebBanSach

> Tài liệu này cung cấp toàn bộ danh sách tài khoản kiểm thử (Khách hàng, Quản trị viên), thông tin thẻ tín dụng mẫu, các kịch bản kiểm thử (Test Cases), cùng với script tự động khởi tạo dữ liệu mẫu (`02_DuLieuKiemThu.sql`).

---

## 1. Danh sách Tài khoản Kiểm thử (Test Accounts)

### 1.1. Tài khoản Khách hàng (Customer Users)

| Tên tài khoản (`TaiKhoan`) | Mật khẩu (`MatKhau`) | Họ và tên | Email | Số điện thoại | Trạng thái | Email xác minh | Mục đích kiểm thử |
|---|---|---|---|---|---|---|---|
| **`testuser`** | `12345678` | Nguyễn Văn Test | `testuser@gmail.com` | `0912345678` | Hoạt động | **Đã xác minh** | Tài khoản chuẩn để test mua sách, thanh toán COD / Credit Card, xem giỏ hàng và theo dõi đơn hàng có sẵn. |
| **`testotp`** | `12345678` | Trần Văn OTP | `testotp@gmail.com` | `0987654321` | Hoạt động | **Chưa xác minh** | Dùng để kiểm thử luồng đăng nhập tự động chuyển hướng sang màn hình xác minh OTP 6 chữ số. |
| **`customer_vip`** | `12345678` | Lê Hoàng VIP | `vip@webbansach.local` | `0903112233` | Hoạt động | **Đã xác minh** | Khách hàng VIP với địa chỉ giao hàng đầy đủ tại Quận 3, TP.HCM. |
| **`customer_locked`** | `12345678` | Phạm Khóa | `locked@gmail.com` | `0933445566` | **Đã khóa** | Đã xác minh | Dùng để kiểm thử xử lý khi tài khoản bị khóa (Hệ thống từ chối đăng nhập với thông báo lỗi). |

> [!NOTE]  
> Tất cả mật khẩu của khách hàng trên hệ thống đều được băm bằng thuật toán an toàn **PBKDF2-SHA256 (210,000 vòng)**. Nếu nhập mật khẩu dạng chữ thuần trong CSDL, hệ thống sẽ tự động nâng cấp sang mã băm PBKDF2 ngay trong lần đăng nhập thành công đầu tiên.

---

### 1.2. Tài khoản Quản trị viên (Admin Users)

Truy cập tại trang quản trị: **[http://localhost:8089/admin.html](http://localhost:8089/admin.html)**

| Tên tài khoản | Mật khẩu | Họ tên hiển thị | Quyền hạn |
|---|---|---|---|
| **`admin`** | `123456` | Quản Trị Viên Hệ Thống | Toàn quyền quản trị đơn hàng, cập nhật trạng thái vận chuyển |
| **`manager`** | `123456` | Điều Phối Viên Đơn Hàng | Quản lý đóng gói và xử lý giao nhận đơn |

---

## 2. Thông tin Thẻ Tín dụng Kiểm thử (Credit Card Test Credentials)

Khi thực hiện thanh toán trực tuyến tại trang **[http://localhost:8089/checkout.html](http://localhost:8089/checkout.html)**, bạn có thể bấm nút **"Thử thẻ mẫu"** để điền tự động hoặc nhập các thẻ kiểm thử dưới đây:

| Loại thẻ | Số thẻ (Card Number) | Tên chủ thẻ (Cardholder) | Ngày hết hạn | Mã CVV | Kết quả mong đợi |
|---|---|---|---|---|---|
| **Visa** | `4532 8888 8888 8888` | `NGUYEN VAN TEST` | `12/28` | `888` | **Thành công**: Đơn hàng ghi nhận `Đã thanh toán (Thẻ tín dụng)`. |
| **Mastercard** | `5421 9999 8888 7777` | `LE HOANG VIP` | `08/29` | `666` | **Thành công**: Hiển thị logo Mastercard, thanh toán thành công. |
| **JCB** | `3528 1111 2222 3333` | `TRAN VAN A` | `10/27` | `123` | **Thành công**: Hiển thị logo JCB, thanh toán thành công. |
| **Thẻ lỗi (Hết hạn)** | `4532 8888 8888 8888` | `NGUYEN VAN TEST` | `12/20` | `888` | **Từ chối**: Báo lỗi định dạng hoặc thẻ đã hết hạn. |
| **Thẻ lỗi (Số thẻ sai)** | `1234` | `NGUYEN VAN TEST` | `12/28` | `888` | **Từ chối**: Yêu cầu số thẻ độ dài từ 13–19 chữ số. |

---

## 3. Cách chạy Script Khởi tạo Dữ liệu Kiểm thử (Init Test Data Script)

Dự án cung cấp file SQL khởi tạo dữ liệu mẫu đầy đủ: `02_DuLieuKiemThu.sql`.

### Cách 1: Chạy trực tiếp bằng SSMS (Khuyên dùng)
1. Mở SQL Server Management Studio (SSMS), kết nối vào SQL Server (`.\SQLEXPRESS`).
2. Mở file `02_DuLieuKiemThu.sql` (`Ctrl + O`).
3. Nhấn phím **`F5`** (Execute). Hệ thống sẽ nạp lại tồn kho 100 cuốn/đầu sách, tạo sẵn tài khoản `testuser`, `admin`, `manager` và 5 đơn hàng mẫu bao quát toàn bộ trạng thái.

---

### Cách 2: Chạy trực tiếp qua PowerShell
Chạy script PowerShell có sẵn trong thư mục gốc:
```powershell
.\seed-test-data.ps1
```
*(Mặc định script kết nối vào `.\SQLEXPRESS`. Nếu bạn dùng instance khác, có thể truyền tham số: `.\seed-test-data.ps1 -ServerInstance "localhost"`).*

---

## 4. Các Đơn hàng Kiểm thử Mẫu có sẵn trong CSDL

Tài khoản `testuser` được nạp sẵn 5 đơn hàng minh họa trọn vẹn vòng đời giao hàng và ghi chú đơn hàng để tiện kiểm thử tại **[tracking.html](http://localhost:8089/tracking.html)**:

| Trạng thái | Tên trạng thái | Hình thức thanh toán | Tình trạng thanh toán | Ghi chú đơn hàng mẫu | Hành động có thể test |
|---|---|---|---|---|---|
| **0** | **Chờ xử lý** | Tiền mặt (COD) | Chưa thanh toán | `Giao trong giờ hành chính, gọi điện trước khi giao` | Khách hàng có thể bấm nút **"Hủy đơn"** (hoàn lại tồn kho). |
| **1** | **Đã đóng gói** | Tiền mặt (COD) | Chưa thanh toán | `Bọc bìa cẩn thận giúp tôi, cảm ơn shop!` | Đơn hàng đang được kho chuẩn bị, không cho phép hủy. |
| **2** | **Đang giao hàng**| Tiền mặt (COD) | Chưa thanh toán | `Gửi tại quầy lễ tân nếu không có nhà` | Bưu tá đang giao, hiển thị huy hiệu xanh dương. |
| **3** | **Đã giao thành công** | **Thẻ tín dụng (Credit Card)** | **Đã thanh toán trực tuyến** | `Đã thanh toán thẻ tín dụng, giao tận tay người nhận` | Hoàn tất chu trình mua sách trực tuyến. |
| **4** | **Đã hủy** | Tiền mặt (COD) | Đã hủy | `Khách gọi đổi địa chỉ` | Đơn hàng đã bị hủy bỏ thành công. |

---

## 5. Các Kịch bản Kiểm thử Nhanh (Step-by-step Test Scenarios)

### Kịch bản 1: Mua hàng thanh toán bằng Thẻ tín dụng (Credit Card Flow)
1. Mở [http://localhost:8089/login.html](http://localhost:8089/login.html).
2. Đăng nhập với tài khoản: `testuser` / `12345678`.
3. Chọn một cuốn sách bất kỳ tại trang chủ -> Bấm **"Thêm vào giỏ"**.
4. Vào [Giỏ hàng](http://localhost:8089/cart.html) -> Bấm **"Thanh toán"**.
5. Tại trang [Thanh toán](http://localhost:8089/checkout.html):
   - Chọn mục **"Thẻ tín dụng / Ghi nợ quốc tế (Credit Card)"**.
   - Bấm nút **"Thử thẻ mẫu"** (Form tự động điền `4532 8888 8888 8888`, `12/28`, `888`).
   - Bấm **"Xác nhận & Đặt hàng"**.
6. Màn hình thông báo **"Thanh toán thành công! Mã đơn #..."** hiển thị thẻ `•••• •••• •••• 8888`.
7. Vào [Đơn hàng của tôi](http://localhost:8089/tracking.html) để kiểm tra huy hiệu `Thẻ tín dụng (Đã thanh toán)`.

---

### Kịch bản 2: Kiểm thử xác minh Email với mã OTP (OTP Verification Flow)
1. Mở [http://localhost:8089/login.html](http://localhost:8089/login.html).
2. Đăng nhập bằng tài khoản chưa kích hoạt: `testotp` / `12345678`.
3. Hệ thống tự động chuyển hướng đến trang [verify-email.html](http://localhost:8089/verify-email.html).
4. Mã OTP 6 chữ số kiểm thử sẽ được thông báo ngay trên màn hình (hoặc lưu trong thư mục `backend/App_Data/OtpEmails`).
5. Nhập 6 số mã OTP -> Bấm **"Xác minh ngay"**.
6. Tài khoản được kích hoạt thành công và tự động chuyển về trang chủ để mua sắm.

---

### Kịch bản 3: Ban quản trị điều phối & đổi trạng thái đơn hàng (Admin Flow)
1. Mở trang quản trị: [http://localhost:8089/admin.html](http://localhost:8089/admin.html).
2. Đăng nhập: `admin` / `123456`.
3. Bảng điều khiển tải toàn bộ đơn hàng của hệ thống.
4. Cột **"Ghi chú của khách"** hiển thị nổi bật các yêu cầu giao hàng riêng biệt.
5. Thử các bộ lọc trạng thái: **"Chờ xử lý"**, **"Đang giao"**, **"Hoàn thành"**.
6. Bấm nút **"Chi tiết"** trên đơn bất kỳ để xem Modal Chi tiết Đơn hàng (Thông tin người nhận, địa chỉ, hộp alert ghi chú, bảng sách và ảnh).
7. Tại cột **"Hành động"** (hoặc trong Modal), chọn dropdown để chuyển một đơn từ `0 - Chờ xử lý` sang `1 - Đã đóng gói` hoặc `2 - Đang giao hàng`.
8. Hệ thống cập nhật trạng thái ngay lập tức trên máy chủ.

---

### Kịch bản 4: Kiểm thử Ghi chú Đơn hàng (Order Note Flow)
1. Vào [checkout.html](http://localhost:8089/checkout.html) khi đã đăng nhập `testuser`.
2. Điền thông tin giao hàng và nhập ô **Ghi chú**: `Giao sau 18h tối, gọi trước khi đến`.
3. Bấm **"Xác nhận & Đặt hàng"**.
4. Màn hình xác nhận đặt hàng thành công hiển thị rõ dòng **Ghi chú giao hàng**.
5. Mở [tracking.html](http://localhost:8089/tracking.html): Đơn hàng mới hiển thị hộp thông báo vàng:  
   `Ghi chú đơn hàng: Giao sau 18h tối, gọi trước khi đến`.
6. Mở [admin.html](http://localhost:8089/admin.html): Đơn hàng xuất hiện ở đầu bảng với badge ghi chú; bấm **"Chi tiết"** để xem hộp thoại chi tiết toàn bộ đơn hàng.
