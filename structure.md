# Cấu trúc Kiến trúc Dự án WebBanSach (Refactored)

> Tài liệu này mô tả chi tiết kiến trúc decoupled (tách biệt hoàn toàn Backend và Frontend) sau khi loại bỏ toàn bộ giao diện server-rendered Razor (`.cshtml`) cũ và chuyển đổi sang kiến trúc API RESTful kết hợp giao diện Web Client hiện đại (HTML5, Bootstrap 5, Vanilla JavaScript).

---

## 1. Tổng quan Kiến trúc (Architecture Overview)

Hệ thống được tổ chức theo kiến trúc tinh gọn, độc lập và tối giản hạ tầng (không cần Nginx reverse proxy):

```
+-------------------------------------------------------------+
|                      NGƯỜI DÙNG / TRÌNH DUYỆT               |
+-------------------------------------------------------------+
                               |
                        Port 8089 (HTTP)
                               v
+-------------------------------------------------------------+
|                   WEBBANSACH WEB SERVICE                    |
|  - Mono XSP4 Server (Cổng 8084 ánh xạ 8089 ngoài host)      |
|  - Phục vụ trực tiếp Static Frontend:                       |
|      * HTML5 (index.html, cart.html, checkout.html...)      |
|      * CSS (css/style.css), JS (js/api.js, js/auth.js)      |
|      * Images (images/*)                                    |
|  - Bộ điều khiển RESTful JSON API:                          |
|      * ApiController.cs (/api/*)                            |
|  - Entity Framework 6 kết nối CSDL SQL Server              |
|  - Quản lý giỏ hàng & phiên làm việc Session an toàn        |
+-------------------------------------------------------------+
                               |
                        Port 1433 (TDS)
                               v
+-------------------------------------------------------------+
|                     DATABASE CONTAINER                      |
|  - Microsoft SQL Server 2022 (BSDB2)                        |
|  - Tự động nạp dữ liệu kiểm thử qua 02_DuLieuKiemThu.sql    |
+-------------------------------------------------------------+
```

---

## 2. Cấu trúc Thư mục Chi tiết (Directory Layout)

```
WebBanSach_Final/
├── backend/                             # Dịch vụ Backend API (.NET / Mono)
│   ├── App_Data/
│   │   └── OtpEmails/                   # Thư mục lưu mã OTP dạng local pickup
│   ├── App_Start/
│   │   └── RouteConfig.cs               # Cấu hình định tuyến API: /api/{action}/{id}
│   ├── Controllers/
│   │   └── ApiController.cs             # Bộ điều khiển RESTful JSON API toàn hệ thống
│   ├── Models/
│   │   ├── Data/                        # Entity Framework Code/Database First Models
│   │   │   ├── BSDBContext.cs           # DbContext kết nối SQL Server
│   │   │   ├── Sach.cs                  # Entity Sách (MaSach, TenSach, GiaBan, SoLuongTon...)
│   │   │   ├── TheLoai.cs               # Entity Thể loại sách (MaLoai, TenLoai...)
│   │   │   ├── TacGia.cs                # Entity Tác giả
│   │   │   ├── NhaXuatBan.cs            # Entity Nhà xuất bản
│   │   │   ├── KhachHang.cs             # Entity Khách hàng (TaiKhoan, MatKhau, Email, EmailVerified...)
│   │   │   ├── DonDatHang.cs            # Entity Đơn đặt hàng (MaDDH, NgayDat, Tracking...)
│   │   │   ├── ChiTietDDH.cs            # Entity Chi tiết đơn hàng (MaDDH, MaSach, SoLuong, DonGia)
│   │   │   ├── Admin.cs                 # Entity Quản trị viên
│   │   │   ├── FeedBack.cs              # Entity Phản hồi khách hàng
│   │   │   └── ChuDe.cs                 # Entity Chủ đề sách
│   │   └── Process/
│   │       └── CartModel.cs             # Model quản lý phiên Giỏ hàng trong Session
│   ├── Global.asax                      # Khởi tạo ứng dụng ASP.NET
│   ├── Global.asax.cs
│   ├── Web.config                       # Cấu hình kết nối DB, CORS, và EmailOtpMode
│   └── WebBanSach.csproj                # File project MSBuild C# (không còn phụ thuộc Razor views)
│
├── frontend/                            # Giao diện người dùng Web Client (HTML/JS/Bootstrap)
│   ├── css/
│   │   └── style.css                    # Toàn bộ style tùy biến, layout, animations, cards
│   ├── js/
│   │   ├── api.js                       # Module gọi REST API tập trung (Fetch API client)
│   │   └── auth.js                      # Quản lý trạng thái đăng nhập, menu navbar, badge giỏ hàng
│   ├── images/                          # Ảnh bìa sách và biểu tượng giao diện
│   ├── index.html                       # Trang chủ: Danh mục, Tìm kiếm tức thì, Lưới sách, Phân trang
│   ├── book-details.html                # Trang chi tiết sách: Giá, tác giả, tồn kho, thêm giỏ hàng
│   ├── cart.html                        # Giỏ hàng thông minh: Tự động tính toán tổng tiền 0ms, tăng giảm SL
│   ├── login.html                       # Trang đăng nhập người dùng (hỗ trợ bật/tắt xem mật khẩu)
│   ├── register.html                    # Trang đăng ký thành viên mới (form chuẩn Bootstrap 5)
│   ├── verify-email.html                # Trang xác minh mã bảo mật OTP 6 chữ số
│   ├── checkout.html                    # Trang thanh toán: Nhập địa chỉ giao hàng, tóm tắt đơn, COD
│   ├── tracking.html                    # Lịch sử & Theo dõi tiến độ đơn hàng, hỗ trợ hủy đơn chờ xử lý
│   └── admin.html                       # Trang quản trị: Đăng nhập admin & Quản lý cập nhật trạng thái đơn
│
├── 00_TaoDatabaseMoi.sql                # Script tạo cấu trúc CSDL và nạp dữ liệu mẫu
├── 01_NangCapDatabase.sql               # Script nâng cấp bảng KhachHang (EmailVerified, TrangThai)
├── 02_DuLieuKiemThu.sql                 # Script nạp dữ liệu kiểm thử (Users, Orders, Books)
├── configure-web-config.py              # Script tự động cấu hình Web.config khi build Docker
├── docker-compose.yml                   # Cấu hình điều phối container (db, db-init, web)
├── Dockerfile                           # Dockerfile đóng gói Backend & Frontend chạy với Mono XSP4
├── init-db.sh                           # Shell script tự động khởi tạo SQL Server trong container
├── seed-test-data.ps1                   # Script PowerShell nạp nhanh dữ liệu test
├── seed-test-data.sh                    # Script Shell/Bash nạp nhanh dữ liệu test
├── structure.md                         # Tài liệu cấu trúc dự án (file này)
├── user.md                              # Danh mục tài khoản kiểm thử & kịch bản test
└── WebBanSach.sln                       # Solution Visual Studio
```

---

## 3. Danh sách RESTful API Endpoints (`ApiController.cs`)

Tất cả các endpoint trả về dữ liệu chuẩn JSON, hỗ trợ CORS và cookie phiên làm việc (`ASP.NET_SessionId`).

### 3.1. Sách & Danh mục (Catalog)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `GET` | `/api/Books` | `categoryId`, `search`, `page`, `pageSize`, `bestSeller` | Lấy danh sách sách có phân trang, lọc theo danh mục hoặc từ khóa tìm kiếm |
| `GET` | `/api/BookDetails` | `id` (int) | Lấy thông tin chi tiết một cuốn sách kèm danh sách sách gợi ý cùng thể loại |
| `GET` | `/api/Categories` | Không | Lấy danh sách toàn bộ thể loại sách cùng số lượng sách tương ứng |

### 3.2. Giỏ hàng (Cart)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `GET` | `/api/Cart` | Không | Lấy danh sách các cuốn sách trong giỏ, tổng số lượng và tổng thành tiền |
| `POST` | `/api/AddToCart` | `id` (int), `quantity` (int) | Thêm sản phẩm vào giỏ hàng hoặc cộng dồn số lượng nếu đã tồn tại |
| `POST` | `/api/UpdateCart` | `cartModel` (JSON serialized) | Đồng bộ số lượng mới của toàn bộ giỏ hàng lên server |
| `POST` | `/api/DeleteCartItem` | `id` (int) | Xóa một mặt hàng khỏi giỏ hàng |
| `POST` | `/api/ClearCart` | Không | Xóa trắng toàn bộ giỏ hàng |

### 3.3. Tài khoản & Xác thực (Auth)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `POST` | `/api/Login` | `username`, `password` | Đăng nhập tài khoản khách hàng, kiểm tra mã hóa PBKDF2 và trạng thái OTP |
| `POST` | `/api/Register` | Model `KhachHang`, `confirmPassword` | Đăng ký thành viên mới, tự động gửi mã OTP xác nhận |
| `GET` | `/api/Me` | Không | Kiểm tra trạng thái phiên đăng nhập hiện tại của người dùng |
| `POST` | `/api/Logout` | Không | Xóa phiên đăng nhập và giỏ hàng |
| `POST` | `/api/SendOtp` | Không | Tạo và gửi mã OTP 6 số đến email đăng ký (lưu mã test trong App_Data) |
| `POST` | `/api/VerifyOtp` | `code` (string, 6 ký tự) | Xác minh mã OTP để kích hoạt tài khoản thành viên |

### 3.4. Đặt hàng & Tra cứu (Orders)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `POST` | `/api/Checkout` | `receiverName`, `receiverPhone`, `receiverAddress`, `note`, `paymentMethod`, `cardNumber`, `cardHolder`, `cardExpiry`, `cardCvv` | Xác nhận đặt hàng (hỗ trợ COD hoặc Thẻ tín dụng Credit Card trực tuyến), trừ tồn kho an toàn, xóa giỏ hàng |
| `GET` | `/api/MyOrders` | Không | Lấy danh sách lịch sử đơn hàng của tài khoản đang đăng nhập kèm phương thức thanh toán |
| `POST` | `/api/CancelOrder` | `id` (int) | Hủy đơn hàng (chỉ khả dụng khi đơn đang ở trạng thái 'Chờ xử lý') và hoàn kho |

### 3.5. Quản trị (Admin)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `POST` | `/api/AdminLogin` | `username`, `password` | Đăng nhập tài khoản ban quản trị |
| `GET` | `/api/AdminOrders` | Không | Lấy danh sách tất cả các đơn đặt hàng trong hệ thống |
| `POST` | `/api/AdminUpdateOrderStatus` | `id` (int), `status` (0-4) | Cập nhật tiến độ giao hàng: Chờ xử lý -> Đã đóng gói -> Đang giao -> Đã giao |

---

## 4. Các Cải tiến nổi bật của Giao diện Frontend Mới

1. **Loại bỏ phụ thuộc Razor Server-side**:
   - Tránh hoàn toàn lỗi biên dịch view runtime (`Error. An error occurred while processing your request`).
   - Tách biệt rõ ràng trách nhiệm: Backend thuần API dữ liệu, Frontend thuần hiển thị và tương tác.
2. **Tính toán Giỏ hàng Thời gian thực (0ms Real-time Auto Calculation)**:
   - Khi người dùng nhấn nút `+` / `-` hoặc nhập số lượng mới, Javascript tính toán và cập nhật ngay lập tức `Thành tiền` của từng dòng và `Tổng thanh toán` của cả giỏ trên màn hình mà không cần chờ mạng hoặc tải lại trang.
   - Cơ chế Debounce tự động gửi đồng bộ ngầm tới máy chủ sau 400ms.
3. **Form Đăng ký / Đăng nhập Chuẩn UI/UX**:
   - Tích hợp nút con mắt bật/tắt xem mật khẩu ngay trong ô nhập liệu.
   - Kiểm tra định dạng client-side tức thì (khớp mật khẩu, email hợp lệ).
4. **Quy trình Đặt hàng & Xác minh Email Chặt chẽ**:
   - Luồng kích hoạt tài khoản bằng mã OTP 6 chữ số có giao diện trực quan, hỗ trợ gửi lại mã.
   - Trang thanh toán tự động điền sẵn thông tin khách hàng từ hồ sơ cá nhân.
   - Trang theo dõi đơn hàng hiển thị huy hiệu trạng thái sắc nét theo chu trình vận chuyển.
5. **Trang Quản trị (Admin Dashboard)**:
   - Cho phép lọc đơn hàng theo từng trạng thái (Chờ xử lý, Đã đóng gói, Đang giao, Đã giao, Đã hủy).
   - Cho phép nhân viên thay đổi trạng thái đơn hàng chỉ với một thao tác chọn nhanh.

---

## 5. Hướng dẫn Chạy Hệ thống với Docker

### Khởi động toàn bộ hệ thống
```bash
docker compose up -d --build
```

### Các dịch vụ và cổng truy cập:
- **Trang chủ Web Khách hàng (Frontend)**: [http://localhost:8089](http://localhost:8089)
- **Trang Quản trị Đơn hàng (Admin)**: [http://localhost:8089/admin.html](http://localhost:8089/admin.html)
- **API Trực tiếp (Backend)**: [http://localhost:8084/api/Books](http://localhost:8084/api/Books)
- **Cơ sở dữ liệu SQL Server**: Cổng `14333` (User: `sa`, Password: `BookStore@123456`)

### Tài khoản kiểm thử có sẵn:
- **Khách hàng đã xác minh**: `testuser` / `12345678`
- **Khách hàng chưa xác minh (thử nghiệm OTP)**: `testotp` / `12345678`
- **Tài khoản Quản trị viên**: `admin` / `123456`
