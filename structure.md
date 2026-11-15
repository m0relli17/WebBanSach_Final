# Cấu trúc Kiến trúc & Danh mục API Hệ thống WebBanSach

> Tài liệu kỹ thuật chi tiết về **kiến trúc phần mềm**, **cơ sở dữ liệu**, **cấu trúc mã nguồn** và **đặc tả toàn bộ hệ thống REST API** của dự án WebBanSach.

---

## 1. Tổng quan Kiến trúc Hệ thống (Architecture Overview)

Hệ thống được thiết kế theo mô hình **Client-Server 3 tầng (3-Tier Architecture)**:

```
+-------------------------------------------------------------+
|                 NGƯỜI DÙNG / TRÌNH DUYỆT WEB                |
|  - HTML5, CSS3 (WebBanSach Design System), Inter Font       |
|  - Bootstrap 5.3 + FontAwesome + JavaScript ES6+ (Async)    |
|  - Responsive đa thiết bị: Mobile, Tablet, FHD, 2K, 4K      |
+-------------------------------------------------------------+
                               |
                   HTTP / RESTful JSON APIs
                               v
+-------------------------------------------------------------+
|               BACKEND WEB SERVER (ASP.NET MVC 5)            |
|  - Microsoft .NET Framework 4.8 (Windows)                   |
|  - Web Server: IIS Express / IIS                            |
|  - Controllers: ApiController.cs, HomeController.cs...      |
|  - Entity Framework 6 (ORM & Database Context: BSDBContext) |
|  - Quản lý phiên làm việc: ASP.NET Session State            |
|  - Mã hóa mật khẩu an toàn: PBKDF2-SHA256 (210,000 vòng)    |
+-------------------------------------------------------------+
                               |
                        Port 1433 (TDS)
                               v
+-------------------------------------------------------------+
|                 DATABASE SERVER (SQL SERVER 2022)           |
|  - Database: BSDB2 (Unicode UTF-8 / Code Page 65001)        |
|  - Bảng chính: Sach, TheLoai, TacGia, NhaXuatBan, KhachHang,|
|    Admin, DonDatHang, ChiTietDDH, DanhGiaSach, LienHe       |
+-------------------------------------------------------------+
```

---

## 2. Cấu trúc Thư mục Dự án (Project Directory Layout)

```
WebBanSach_Final/
├── backend/                             # Ứng dụng ASP.NET MVC 5 thực thi chính
│   ├── App_Data/
│   │   └── OtpEmails/                   # Thư mục lưu file email OTP mô phỏng
│   ├── App_Start/                       # Cấu hình Route, Bundle, Filter
│   ├── Controllers/
│   │   ├── ApiController.cs             # Toàn bộ RESTful API (Auth, Books, Cart, Orders, Admin)
│   │   └── HomeController.cs            # Controller MVC phụ trợ
│   ├── Models/
│   │   ├── BSDBContext.cs               # Entity Framework DbContext
│   │   ├── Data/                        # Các Entity CSDL (Sach, KhachHang, DonDatHang...)
│   │   └── CartModel.cs                 # DTO mô hình Giỏ hàng
│   ├── css/
│   │   └── style.css                    # WebBanSach Theme & Hyper-Care Responsive CSS (16 Sections)
│   ├── js/
│   │   ├── api.js                       # Thư viện gọi API JavaScript (Fetch Client)
│   │   └── auth.js                      # Trình quản lý trạng thái phiên đăng nhập & thanh navbar
│   ├── images/                          # Thư mục hình ảnh sách, biểu ngữ quảng cáo (banner1..3, combo1..3)
│   ├── index.html                       # Trang chủ & Khám phá danh mục sách
│   ├── book-details.html                # Trang chi tiết sản phẩm, tồn kho & đánh giá
│   ├── cart.html                        # Trang giỏ hàng, tính toán tài chính & kiểm soát mua hàng
│   ├── checkout.html                    # Trang thanh toán (COD / Thẻ tín dụng)
│   ├── login.html                       # Trang đăng nhập thành viên & quản trị
│   ├── register.html                    # Trang đăng ký (Validation mật khẩu 8-128 ký tự, không dấu cách)
│   ├── verify-email.html                # Trang xác thực mã OTP email
│   ├── tracking.html                    # Trang lịch sử & theo dõi đơn hàng (5 trạng thái đồng bộ)
│   ├── admin.html                       # Trang bảng điều khiển Quản trị viên & Seller
│   ├── Web.config                       # Tệp cấu hình ứng dụng (Chuỗi kết nối CSDL, Session, Email)
│   └── WebBanSach.csproj                # Tệp dự án MSBuild C#
├── frontend/                            # Bản sao giao diện tĩnh (Đảm bảo đồng bộ 100% với backend/)
├── 00_TaoDatabaseMoi.sql                # Script khởi tạo cấu trúc CSDL BSDB2
├── 01_NangCapDatabase.sql               # Script nâng cấp schema và các chỉ mục hiệu năng
├── 02_DuLieuKiemThu.sql                 # Script nạp dữ liệu kiểm thử tiếng Việt UTF-8 chuẩn
├── README.md                            # Tổng quan hệ thống & hướng dẫn chạy nhanh
├── HUONG_DAN_CHAY.md                    # Hướng dẫn chạy từng bước với Visual Studio
├── HUONG_DAN_MVS.md                     # Hướng dẫn Visual Studio & SQL Server
├── structure.md                         # Tài liệu cấu trúc & API (tài liệu này)
└── user.md                              # Danh mục tài khoản kiểm thử & kịch bản thuyết trình
```

---

## 3. Lược đồ Cơ sở Dữ liệu (Database Schema)

| Tên bảng | Khóa chính | Khóa ngoại | Mô tả |
|---|---|---|---|
| `Sach` | `MaSach` (INT) | `MaLoai`, `MaNXB`, `MaTG` | Thông tin sách: Tên, Mô tả, Giá bán gốc, Giảm giá (%), Số lượng tồn, Ảnh bìa, Ngày cập nhật. |
| `TheLoai` | `MaLoai` (INT) | Không | Danh mục thể loại sách (Sách Kinh Tế, Văn Học, Ngoại Ngữ, Thiếu Nhi...). |
| `TacGia` | `MaTG` (INT) | Không | Tên tác giả, tiểu sử. |
| `NhaXuatBan`| `MaNXB` (INT) | Không | Nhà xuất bản sách (NXB Trẻ, NXB Giáo Dục Việt Nam, Kim Đồng...). |
| `KhachHang` | `MaKH` (INT) | Không | Tài khoản khách: Tên đăng nhập, Mật khẩu băm PBKDF2, Họ tên, Email, SĐT, Địa chỉ, Trạng thái (0: Khóa, 1: Mở), EmailVerified (1: Đã xác thực OTP). |
| `Admin` | `UserAdmin` (VARCHAR) | Không | Tài khoản quản trị: Mật khẩu, Tên hiển thị, Trạng thái hoạt động. |
| `DonDatHang`| `MaDDH` (INT) | `MaKH` | Đơn hàng: Ngày đặt, Ngày giao dự kiến, Tình trạng, Thanh toán (0: COD, 1: Thẻ đã thanh toán), Tracking (0: Chờ xử lý, 1: Đóng gói, 2: Đang giao, 3: Đã giao, 4: Đã hủy), Ghi chú. |
| `ChiTietDDH`| (`MaDDH`, `MaSach`)| `MaDDH`, `MaSach` | Chi tiết mặt hàng trong đơn: Số lượng đặt, Đơn giá sau giảm tại thời điểm mua. |
| `DanhGiaSach`| `MaDanhGia` (INT) | `MaSach`, `MaKH` | Đánh giá sách của độc giả: Số sao (1–5 sao), Nội dung nhận xét tiếng Việt, Ngày đăng. |

---

## 4. Đặc tả Danh mục RESTful API (`/api/...`)

Tất cả các API được định nghĩa tập trung trong [ApiController.cs](file:///c:/Project/WebBanSach_Final/backend/Controllers/ApiController.cs):

### 4.1. Sách & Danh mục
- **`GET /api/categories`**: Trả về danh sách thể loại sách kèm số lượng đầu sách thực tế trong kho.
- **`GET /api/books?page=1&pageSize=12&sortBy=newest&categoryId=&search=`**: Trả về danh sách sách phân trang, hỗ trợ sắp xếp (`newest`, `price-asc`, `price-desc`, `hot`, `popular`, `sales`), lọc theo thể loại và từ khóa tìm kiếm.
- **`GET /api/bookdetail?id={id}`**: Trả về thông tin chi tiết của sách, bao gồm giá gốc, giá giảm, tỷ lệ giảm giá, tồn kho, nhà xuất bản, tác giả, đánh giá sao trung bình, danh sách nhận xét và sách gợi ý liên quan.

### 4.2. Giỏ hàng (Cart)
- **`GET /api/cart`**: Lấy danh sách sản phẩm hiện tại trong giỏ hàng phiên làm việc (`Session`), kèm tính toán `originalTotal`, `discount`, `total`, `totalQuantity`.
- **`POST /api/addtocart`**: Thêm sản phẩm vào giỏ hàng với `id` và `quantity`. Kiểm tra tồn kho trước khi thêm.
- **`POST /api/updatecart`**: Cập nhật số lượng của toàn bộ giỏ hàng, kiểm tra giới hạn tồn kho.
- **`POST /api/deletecartitem`**: Xóa một sản phẩm cụ thể khỏi giỏ hàng.
- **`POST /api/clearcart`**: Xóa sạch toàn bộ sản phẩm trong giỏ hàng.

### 4.3. Xác thực & Khách hàng (Authentication)
- **`GET /api/me`**: Trả về trạng thái đăng nhập hiện tại (`isLoggedIn`), thông tin người dùng (`user`), hoặc cờ yêu cầu OTP (`requireOtp`).
- **`POST /api/login`**: Đăng nhập với `username` và `password`. Kiểm tra mật khẩu băm PBKDF2, tự động nâng cấp nếu mật khẩu cũ dạng plaintext.
- **`POST /api/register`**: Đăng ký tài khoản mới:
  - Kiểm tra độ dài mật khẩu **8 đến 128 ký tự**.
  - Kiểm tra mật khẩu **không được chứa khoảng trắng** (`' '`).
  - Kiểm tra tính duy nhất của tên đăng nhập và email.
  - Tự động tạo và gửi mã xác thực OTP 6 chữ số vào `App_Data/OtpEmails`.
- **`POST /api/verifyotp`**: Xác thực tài khoản bằng mã OTP 6 số.
- **`POST /api/resendotp`**: Gửi lại mã OTP qua email.
- **`POST /api/logout`**: Đăng xuất khỏi hệ thống và hủy phiên làm việc.

### 4.4. Đặt hàng & Thanh toán (Checkout & Orders)
- **`POST /api/checkout`**: Tiến hành đặt hàng:
  - Bắt buộc đăng nhập (`requireLogin: true` nếu chưa đăng nhập).
  - Bắt buộc tài khoản đã xác minh email (`requireOtp: true` nếu chưa xác thực).
  - Kiểm tra trừ kho nguyên tử (`Atomic Update: UPDATE Sach SET SoLuongTon = SoLuongTon - @qty WHERE SoLuongTon >= @qty`).
  - Hỗ trợ COD hoặc Thẻ tín dụng (kiểm tra 13–19 chữ số thẻ, định dạng MM/YY, CVV 3–4 số).
- **`GET /api/myorders`**: Lấy danh sách đơn hàng của khách hàng hiện tại, trả về đầy đủ mã đơn, ngày đặt, ngày giao dự kiến, trạng thái (`0..4`), trạng thái thanh toán, tổng tiền, ghi chú và danh sách sản phẩm.
- **`POST /api/cancelorder`**: Khách hàng hủy đơn hàng (chỉ khả dụng khi đơn ở trạng thái `0 - Chờ xử lý`). Tự động hoàn trả số lượng tồn kho về bảng `Sach`.

### 4.5. Đánh giá Sách (Reviews)
- **`POST /api/addreview`**: Gửi đánh giá 1–5 sao kèm nhận xét tiếng Việt cho một cuốn sách (yêu cầu khách hàng đã đăng nhập và xác minh email).

### 4.6. Quản trị viên (Admin APIs)
- **`POST /api/adminlogin`**: Đăng nhập tài khoản quản trị viên.
- **`GET /api/adminorders`**: Lấy toàn bộ đơn hàng của tất cả khách hàng trong hệ thống kèm bộ đếm theo từng trạng thái.
- **`POST /api/adminupdateorderstatus`**: Cập nhật trạng thái đơn hàng (`0..4`).
- **`GET /api/admincatalog`**: Lấy danh mục thể loại, tác giả, nhà xuất bản để phục vụ form quản trị sách.
- **`POST /api/adminaddbook`**: Thêm sách mới vào kho (hỗ trợ upload ảnh bìa).
- **`POST /api/admineditbook`**: Chỉnh sửa thông tin sách, giá bán, giá gốc, tồn kho.
- **`POST /api/admindeletebook`**: Xóa sách (chặn xóa nếu sách đã nằm trong đơn hàng để bảo toàn dữ liệu).
- **`GET /api/adminreviews`**: Lấy danh sách toàn bộ đánh giá để kiểm duyệt.
- **`POST /api/admindeletereview`**: Gỡ bỏ đánh giá vi phạm.
