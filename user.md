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

Truy cập trang quản trị tại `http://localhost:8080/admin.html` theo VS Code `launch.json`; nếu IIS Express cấp cổng khác, thay `8080` bằng cổng đang chạy.

| Tên tài khoản | Mật khẩu | Họ tên hiển thị | Quyền hạn |
|---|---|---|---|
| **`admin`** | `123456` | Quản Trị Viên Hệ Thống | Quản lý sách, xem đơn, cập nhật trạng thái và kiểm duyệt đánh giá |
| **`manager`** | `123456` | Điều Phối Viên Đơn Hàng | Cùng giao diện quản trị; dùng để kiểm thử luồng đơn |

Quản lý sách hỗ trợ thêm/sửa/xóa, giá gốc, giảm giá, tồn kho, ảnh bìa JPG/JFIF/PNG/GIF/BMP và nhập tác giả mới. Sách đã có trong đơn hàng không thể xóa để bảo toàn lịch sử.

Trang chủ có bộ lọc giá, độ hot 30 ngày, phổ biến theo đánh giá và lượt bán. Khách đã xác minh email có thể đánh giá 1–5 sao; admin có thể lọc và xóa đánh giá.

---

## 2. Thông tin Thẻ Tín dụng Kiểm thử (Credit Card Test Credentials)

Khi chạy tại cổng 8080, mở **[http://localhost:8080/checkout.html](http://localhost:8080/checkout.html)**, bấm nút **"Thử thẻ mẫu"** hoặc nhập các thẻ kiểm thử dưới đây:

| Loại thẻ | Số thẻ (Card Number) | Tên chủ thẻ (Cardholder) | Ngày hết hạn | Mã CVV | Kết quả mong đợi |
|---|---|---|---|---|---|
| **Visa** | `4532 8888 8888 8888` | `NGUYEN VAN TEST` | `12/28` | `888` | **Thành công**: Đơn hàng ghi nhận `Đã thanh toán (Thẻ tín dụng)`. |
| **Mastercard** | `5421 9999 8888 7777` | `LE HOANG VIP` | `08/29` | `666` | **Thành công**: Hiển thị logo Mastercard, thanh toán thành công. |
| **JCB** | `3528 1111 2222 3333` | `TRAN VAN A` | `10/27` | `123` | **Thành công**: Hiển thị logo JCB, thanh toán thành công. |
| **Thẻ lỗi (Hết hạn)** | `4532 8888 8888 8888` | `NGUYEN VAN TEST` | `12/20` | `888` | **Từ chối**: Báo lỗi định dạng hoặc thẻ đã hết hạn. |
| **Thẻ lỗi (Số thẻ sai)** | `1234` | `NGUYEN VAN TEST` | `12/28` | `888` | **Từ chối**: Yêu cầu số thẻ độ dài từ 13–19 chữ số. |

---

## 3. Cách chạy Script Khởi tạo Dữ liệu Kiểm thử (Init Test Data Script)

Dự án cung cấp file SQL khởi tạo dữ liệu mẫu đầy đủ: [02_DuLieuKiemThu.sql](02_DuLieuKiemThu.sql).

### Cách 1: Chạy trực tiếp trong SQL Server Management Studio (SSMS)
1. Mở SSMS và kết nối đến SQL Server cục bộ (ví dụ: `.\SQLEXPRESS` hoặc `localhost`).
2. Mở file [02_DuLieuKiemThu.sql](02_DuLieuKiemThu.sql).
3. Nhấn **Execute (F5)** để nạp toàn bộ tài khoản và đơn hàng kiểm thử vào CSDL `BSDB2`.

---

### Cách 2: Chạy qua PowerShell (Windows)
Mở terminal PowerShell tại thư mục dự án và chạy:
```powershell
.\seed-test-data.ps1
```
*(Mặc định kết nối tới `.\SQLEXPRESS`, nếu dùng instance khác có thể truyền tham số: `.\seed-test-data.ps1 -Server "localhost"`)*

---

### Cách 3: Chạy bằng sqlcmd CLI
```cmd
sqlcmd -S .\SQLEXPRESS -E -i 02_DuLieuKiemThu.sql
```

---

## 4. Các Đơn hàng Kiểm thử Mẫu có sẵn trong CSDL

Tài khoản `testuser` được nạp sẵn 5 đơn hàng minh họa để kiểm thử tại **[tracking.html](http://localhost:8080/tracking.html)**:

| Trạng thái | Tên trạng thái | Hình thức thanh toán | Tình trạng thanh toán | Hành động có thể test |
|---|---|---|---|---|
| **0** | **Chờ xử lý** | Tiền mặt (COD) | Chưa thanh toán | Khách hàng có thể bấm nút **"Hủy đơn"** (hoàn lại tồn kho). |
| **1** | **Đã đóng gói** | Tiền mặt (COD) | Chưa thanh toán | Đơn hàng đang được kho chuẩn bị, không cho phép hủy. |
| **2** | **Đang giao hàng**| Tiền mặt (COD) | Chưa thanh toán | Bưu tá đang giao, hiển thị huy hiệu xanh dương. |
| **3** | **Đã giao thành công** | **Thẻ tín dụng (Credit Card)** | **Đã thanh toán trực tuyến** | Hoàn tất chu trình mua sách trực tuyến. |
| **4** | **Đã hủy** | Tiền mặt (COD) | Đã hủy | Đơn hàng đã bị hủy bỏ thành công. |

---

## 5. Các Kịch bản Kiểm thử Nhanh (Step-by-step Test Scenarios)

### Kịch bản 1: Mua hàng thanh toán bằng Thẻ tín dụng (Credit Card Flow)
1. Mở [http://localhost:8080/login.html](http://localhost:8080/login.html).
2. Đăng nhập với tài khoản: `testuser` / `12345678`.
3. Chọn một cuốn sách bất kỳ tại trang chủ -> Bấm **"Thêm vào giỏ"**.
4. Vào [Giỏ hàng](http://localhost:8080/cart.html) -> Bấm **"Thanh toán"**.
5. Tại trang [Thanh toán](http://localhost:8080/checkout.html):
   - Chọn mục **"Thẻ tín dụng / Ghi nợ quốc tế (Credit Card)"**.
   - Bấm nút **"Thử thẻ mẫu"** (Form tự động điền `4532 8888 8888 8888`, `12/28`, `888`).
   - Bấm **"Xác nhận & Đặt hàng"**.
6. Màn hình thông báo **"Thanh toán thành công! Mã đơn #..."** hiển thị thẻ `•••• •••• •••• 8888`.
7. Vào [Đơn hàng của tôi](http://localhost:8080/tracking.html) để kiểm tra huy hiệu `Thẻ tín dụng (Đã thanh toán)`.

---

### Kịch bản 2: Kiểm thử xác minh Email với mã OTP (OTP Verification Flow)
1. Mở [http://localhost:8080/login.html](http://localhost:8080/login.html).
2. Đăng nhập bằng tài khoản chưa kích hoạt: `testotp` / `12345678`.
3. Hệ thống tự động chuyển hướng đến trang [verify-email.html](http://localhost:8080/verify-email.html).
4. Mã OTP 6 chữ số kiểm thử sẽ được thông báo ngay trên màn hình (hoặc lưu trong thư mục `backend/App_Data/OtpEmails`).
5. Nhập 6 số mã OTP -> Bấm **"Xác minh ngay"**.
6. Tài khoản được kích hoạt thành công và tự động chuyển về trang chủ để mua sắm.

---

### Kịch bản 3: Ban quản trị điều phối & đổi trạng thái đơn hàng (Admin Flow)
1. Mở trang quản trị: [http://localhost:8080/admin.html](http://localhost:8080/admin.html).
2. Đăng nhập: `admin` / `123456`.
3. Bảng điều khiển tải toàn bộ đơn hàng của hệ thống.
4. Thử các bộ lọc trạng thái: **"Chờ xử lý"**, **"Đang giao"**, **"Hoàn thành"**.
5. Tại cột **"Hành động"**, chọn dropdown để chuyển một đơn từ `0 - Chờ xử lý` sang `1 - Đã đóng gói` hoặc `2 - Đang giao hàng`.
6. Hệ thống cập nhật trạng thái ngay lập tức trên máy chủ.

### Kịch bản 4: Quản lý sách và đánh giá
1. Đăng nhập admin tại `http://localhost:8080/admin.html` bằng `admin` / `123456`.
2. Mở danh sách sản phẩm, tìm một cuốn sách và kiểm tra chi tiết.
3. Chọn sửa, đổi giá/giảm giá/tồn kho rồi lưu; thử thay ảnh bìa JPG/JFIF.
4. Thêm một sách với tác giả mới, xác nhận sách xuất hiện trong catalog.
5. Mở mục Đánh giá, lọc theo số sao/từ khóa và xóa đánh giá test.
6. Thử xóa sách chưa có đơn hàng; với sách đã có trong lịch sử, xác nhận server từ chối xóa.
