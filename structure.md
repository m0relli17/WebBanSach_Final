# Cấu trúc dự án WebBanSach

Tài liệu này mô tả phiên bản hiện tại: ASP.NET MVC 5 / .NET Framework 4.8, Entity Framework 6, SQL Server `BSDB2`, JSON API và giao diện HTML/Bootstrap/JavaScript. Project chạy từ `backend/`; thư mục `frontend/` giữ bản giao diện tương ứng.

---

## 1. Tổng quan Kiến trúc (Architecture Overview)

Hệ thống chạy cục bộ bằng IIS Express hoặc IIS; không cần Docker hay Nginx:

```
+-------------------------------------------------------------+
|                      NGƯỜI DÙNG / TRÌNH DUYỆT               |
+-------------------------------------------------------------+
                               |
              HTTP (cổng IIS Express do Visual Studio cấp)
                               v
+-------------------------------------------------------------+
|                  ASP.NET MVC 5 / IIS Express                |
|  - Phục vụ HTML, CSS, JS và ảnh từ backend/                 |
|  - REST API: /api/{action}/{id}                             |
|  - Entity Framework 6, session và xác thực admin/khách      |
+-------------------------------------------------------------+
                               |
                        Port 1433 (TDS)
                               v
+-------------------------------------------------------------+
|                    SQL Server: BSDB2                        |
|  - Sách, tồn kho, khách, đơn, đánh giá và quản trị          |
+-------------------------------------------------------------+
```

---

## 2. Cấu trúc Thư mục Chi tiết (Directory Layout)

```
WebBanSach_Final/
├── backend/                             # ASP.NET MVC app, API và giao diện chạy
│   ├── App_Data/
│   │   └── OtpEmails/                   # Thư mục lưu mã OTP dạng local pickup
│   ├── App_Start/
│   │   └── RouteConfig.cs               # Cấu hình định tuyến API: /api/{action}/{id}
│   ├── Controllers/
│   │   └── ApiController.cs             # Bộ điều khiển RESTful JSON API toàn hệ thống
│   ├── Models/
│   │   ├── CartModel.cs                  # Giỏ hàng session; tính tổng theo giá sau giảm
│   │   ├── Data/                        # Entity Framework Code/Database First Models
│   │   │   ├── BSDBContext.cs           # DbContext kết nối SQL Server
│   │   │   ├── Sach.cs                  # Entity sách, giảm giá và tồn kho
│   │   │   ├── DanhGiaSach.cs           # Đánh giá 1–5 sao và bình luận
│   │   │   ├── TheLoai.cs               # Entity Thể loại sách (MaLoai, TenLoai...)
│   │   │   ├── TacGia.cs                # Entity Tác giả
│   │   │   ├── NhaXuatBan.cs            # Entity Nhà xuất bản
│   │   │   ├── KhachHang.cs             # Entity Khách hàng (TaiKhoan, MatKhau, Email, EmailVerified...)
│   │   │   ├── DonDatHang.cs            # Entity Đơn đặt hàng (MaDDH, NgayDat, Tracking...)
│   │   │   ├── ChiTietDDH.cs            # Entity Chi tiết đơn hàng (MaDDH, MaSach, SoLuong, DonGia)
│   │   │   ├── Admin.cs                 # Entity Quản trị viên
│   │   │   └── LienHe.cs                # Entity liên hệ khách hàng
│   │   └── Process/
│   │       └── AdminProcess.cs          # Nghiệp vụ quản trị sách/danh mục
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
│   └── admin.html                       # Admin: CRUD sách, đơn hàng và đánh giá
│
├── 00_TaoDatabaseMoi.sql                # Script tạo cấu trúc CSDL và nạp dữ liệu mẫu
├── 01_NangCapDatabase.sql               # Migration email, ghi chú, giảm giá, review, BIGINT
├── 02_DuLieuKiemThu.sql                 # Script nạp dữ liệu kiểm thử (Users, Orders, Books)
├── 03_KhoiPhucGhiChuDonHang.sql         # Repair riêng GhiChu (đã có trong 01)
├── 04_SoLuongBigInt.sql                 # Repair riêng số lượng BIGINT (đã có trong 01)
├── seed-test-data.ps1                   # Script PowerShell nạp nhanh dữ liệu test vào SQL Server
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
| `GET` | `/api/Books` | `categoryId`, `search`, `page`, `pageSize`, `sortBy` | Danh sách phân trang; sắp xếp theo giá, hot 30 ngày, đánh giá hoặc lượt bán |
| `GET` | `/api/BookDetails` | `id` (int) | Chi tiết sách, giá giảm, tồn kho, điểm đánh giá và sách liên quan |
| `GET` | `/api/Categories` | Không | Lấy danh sách toàn bộ thể loại sách cùng số lượng sách tương ứng |
| `GET` | `/api/BookReviews` | `id` (sách) | Điểm trung bình, review và review của khách đã xác minh |
| `POST` | `/api/SubmitBookReview` | `bookId`, `rating`, `comment` | Tạo/cập nhật một review 1–5 sao cho mỗi khách/sách |

### 3.2. Giỏ hàng (Cart)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `GET` | `/api/Cart` | Không | Lấy danh sách các cuốn sách trong giỏ, tổng số lượng và tổng thành tiền |
| `POST` | `/api/AddToCart` | `id` (int), `quantity` (long) | Thêm vào giỏ; server giới hạn 1–999 và kiểm tra tồn kho |
| `POST` | `/api/UpdateCart` | `cartModel` (JSON serialized) | Đồng bộ số lượng mới của toàn bộ giỏ hàng lên server |
| `POST` | `/api/DeleteCartItem` | `id` (int) | Xóa một mặt hàng khỏi giỏ hàng |
| `POST` | `/api/ClearCart` | Không | Xóa trắng toàn bộ giỏ hàng |

### 3.3. Tài khoản & Xác thực (Auth)
| Phương thức | Đường dẫn API | Tham số | Mô tả |
|---|---|---|---|
| `POST` | `/api/Login` | `username`, `password` | Đăng nhập tài khoản khách hàng, kiểm tra mã hóa PBKDF2 và trạng thái OTP |
| `POST` | `/api/Register` | Model `KhachHang`, `confirmPassword` | Đăng ký thành viên mới và bắt đầu xác minh email OTP |
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
| `GET` | `/api/AdminSession` | Session | Lấy token phiên admin cho request ghi |
| `GET` | `/api/AdminCatalog` | Session | Lấy thể loại, tác giả, NXB cho form sách |
| `GET` | `/api/AdminBooks` | `search`, `page` | Tìm và phân trang sách trong admin |
| `GET` | `/api/AdminBookDetails` | `id` | Chi tiết sách dành cho admin |
| `POST` | `/api/AdminCreateBook` | Multipart form, cover | Thêm sách; nhận ảnh JPG/JFIF/PNG/GIF/BMP |
| `POST` | `/api/AdminUpdateBook` | Multipart form, cover tùy chọn | Sửa thông tin, giảm giá, tồn kho và ảnh |
| `POST` | `/api/AdminDeleteBook` | `id` | Xóa sách nếu chưa được tham chiếu bởi đơn hàng |
| `GET` | `/api/AdminOrders` | Không | Lấy danh sách tất cả các đơn đặt hàng trong hệ thống |
| `POST` | `/api/AdminUpdateOrderStatus` | `id` (int), `status` (0-4) | Cập nhật tiến độ giao hàng: Chờ xử lý -> Đã đóng gói -> Đang giao -> Đã giao |
| `GET` | `/api/AdminReviews` | `search`, `rating`, `page` | Tìm và lọc đánh giá cho admin |
| `POST` | `/api/AdminDeleteReview` | `id` | Xóa đánh giá không phù hợp |

POST admin yêu cầu cookie session và header `X-Admin-Token`; `AdminLogout` thu hồi phiên.

---

## 4. Các Cải tiến nổi bật của Giao diện Frontend Mới

1. **Loại bỏ phụ thuộc Razor Server-side**:
   - Storefront dùng HTML/CSS/JavaScript và JSON API; project vẫn dùng ASP.NET MVC 5 để host API/session.
   - Bản chạy chính nằm trong `backend/`; `frontend/` giữ bản giao diện tương ứng.
2. **Tính toán Giỏ hàng Thời gian thực (0ms Real-time Auto Calculation)**:
   - Khi người dùng nhấn nút `+` / `-` hoặc nhập số lượng mới, Javascript tính toán và cập nhật ngay lập tức `Thành tiền` của từng dòng và `Tổng thanh toán` của cả giỏ trên màn hình mà không cần chờ mạng hoặc tải lại trang.
   - Cơ chế Debounce tự động gửi đồng bộ ngầm tới máy chủ sau khoảng 300ms.
3. **Form Đăng ký / Đăng nhập Chuẩn UI/UX**:
   - Tích hợp nút con mắt bật/tắt xem mật khẩu ngay trong ô nhập liệu.
   - Kiểm tra định dạng client-side tức thì (khớp mật khẩu, email hợp lệ).
4. **Quy trình Đặt hàng & Xác minh Email Chặt chẽ**:
   - Luồng kích hoạt tài khoản bằng mã OTP 6 chữ số có giao diện trực quan, hỗ trợ gửi lại mã.
   - Trang thanh toán tự động điền sẵn thông tin khách hàng từ hồ sơ cá nhân.
   - Trang theo dõi đơn hàng hiển thị huy hiệu trạng thái sắc nét theo chu trình vận chuyển.
5. **Trang Quản trị (Admin Dashboard)**:
   - CRUD sách, tìm kiếm/phân trang, sửa giá/giảm giá/tồn kho/ảnh bìa.
   - Xem thông tin đơn đầy đủ, ghi chú và cập nhật trạng thái.
   - Tìm/lọc theo sao và xóa đánh giá; mỗi khách đã xác minh có một đánh giá cho mỗi sách.

---

## 5. Hướng dẫn Khởi chạy Hệ thống trên Môi trường Cục bộ

### 5.1. Khởi tạo Cơ sở Dữ liệu (SQL Server)
1. Mở **SQL Server Management Studio (SSMS)** kết nối tới instance SQL Server của bạn (ví dụ: `.\SQLEXPRESS`).
2. Với DB mới: chạy [00_TaoDatabaseMoi.sql](00_TaoDatabaseMoi.sql), [01_NangCapDatabase.sql](01_NangCapDatabase.sql), sau đó [02_DuLieuKiemThu.sql](02_DuLieuKiemThu.sql).
3. Với DB hiện có: chạy `01_NangCapDatabase.sql`; chỉ chạy `02_DuLieuKiemThu.sql` nếu muốn nạp/cập nhật tài khoản, catalog và đơn demo.
4. `03_KhoiPhucGhiChuDonHang.sql` và `04_SoLuongBigInt.sql` là repair riêng; thay đổi của chúng đã có trong migration `01`.
5. Có thể nạp dữ liệu demo bằng PowerShell tại thư mục dự án: `seed-test-data.ps1`.

### 5.2. Khởi chạy Ứng dụng với Visual Studio
1. Mở file [WebBanSach.sln](WebBanSach.sln) bằng **Visual Studio 2019/2022**.
2. Kiểm tra chuỗi kết nối trong `backend/Web.config` (mặc định trỏ đến `.\SQLEXPRESS` hoặc `localhost`).
3. Chuột phải vào project `backend` -> Chọn **Set as Startup Project**.
4. Nhấn **F5** (hoặc `Ctrl + F5`) để khởi chạy IIS Express.
5. IIS Express phục vụ trang chủ `/index.html`, giỏ hàng `/cart.html`, thanh toán `/checkout.html` và admin `/admin.html` trên cổng hiển thị trong Visual Studio.

### 5.3. Tài khoản kiểm thử có sẵn (xem [user.md](user.md)):
- **Khách hàng đã xác minh**: `testuser` / `12345678`
- **Khách hàng thử nghiệm OTP**: `testotp` / `12345678`
- **Tài khoản Quản trị viên**: `admin` / `123456`
