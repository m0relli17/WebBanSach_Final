# WebBanSach

Ứng dụng bán sách trực tuyến xây dựng bằng **ASP.NET MVC 5**, **Entity Framework 6** và **SQL Server**. Dự án gồm website khách hàng và khu vực quản trị để quản lý sách, tồn kho, đơn hàng và doanh thu.

## Chức năng

| Khu vực | Chức năng |
| --- | --- |
| Danh mục sách | Tìm kiếm, lọc thể loại, sắp xếp giá và bán chạy, phân trang |
| Chi tiết sách | Thông tin tác giả/NXB, giá giảm, tồn kho và đánh giá |
| Tài khoản | Đăng ký, đăng nhập, xác minh OTP và cập nhật hồ sơ |
| Giỏ hàng | Cập nhật số lượng, tính giảm giá, phí giao hàng |
| Đặt hàng | COD hoặc thanh toán thẻ mô phỏng, lưu thông tin người nhận |
| Theo dõi đơn | Chờ xử lý → Đã đóng gói → Đang giao → Đã giao; hỗ trợ hủy đơn |
| Quản trị | Quản lý sách, danh mục, kho, quản trị viên, tra cứu khách hàng, duyệt đánh giá |
| Báo cáo | Lọc khoảng ngày, doanh thu theo ngày, trạng thái đơn, top sách bán chạy |
| Lịch sử | Ghi nhận điều chỉnh kho và thay đổi trạng thái đơn trong luồng HTML/API |

Dashboard tính doanh thu tiền sách từ **đơn đã giao**, dựa trên đơn giá lưu trong chi tiết đơn; không bao gồm phí vận chuyển. Khoảng thời gian báo cáo được lọc theo **ngày đặt hàng**.

## Công nghệ

- Backend: C#, ASP.NET MVC 5, .NET Framework 4.8.
- Dữ liệu: Entity Framework 6, Microsoft SQL Server.
- Giao diện: Razor, HTML/CSS, Bootstrap, JavaScript và Fetch API.
- Môi trường chạy: Windows, IIS Express hoặc IIS.

## Cấu trúc thư mục

```text
WebBanSach.sln             Solution mở bằng Visual Studio
backend/                  Ứng dụng ASP.NET MVC
  Controllers/            Xử lý trang, API và nghiệp vụ
  Models/                 Mô hình dữ liệu, DbContext và view model
  Views/                  Razor views, layouts và partials
  Areas/Admin/            Các màn hình quản trị MVC cũ
  App_Start/              Routes, bundles và filters
  css/, js/, images/      Tài nguyên giao diện
  Web.config              Cấu hình mặc định cho môi trường phát triển
frontend/                 Bản HTML tham chiếu của giao diện
database/                Khởi tạo, nâng cấp và dữ liệu mẫu
tools/                   Công cụ đồng bộ HTML sang Razor
```

`backend` là ứng dụng cần build và triển khai. Các URL như `index.html` và `admin.html` được route qua `PortalController` để render Razor; cần chạy qua ASP.NET/IIS để sử dụng đầy đủ chức năng.

## Cài đặt và chạy

### 1. Chuẩn bị môi trường

- Windows và Visual Studio 2019/2022 với workload **ASP.NET and web development**.
- .NET Framework 4.8 Developer Pack.
- SQL Server Express 2019/2022 hoặc SQL Server tương thích và SQL Server Management Studio (SSMS).
- Python 3 chỉ cần khi chỉnh nguồn HTML và sinh lại Razor views.

Clone repository về máy, sau đó mở `WebBanSach.sln`.

### 2. Khởi tạo database

Trong SSMS, kết nối SQL Server và chạy các file theo thứ tự:

| Thứ tự | File | Nội dung |
| --- | --- | --- |
| 1 | [00_TaoDatabaseMoi.sql](database/00_TaoDatabaseMoi.sql) | Tạo database `BSDB2`, các bảng và dữ liệu nền |
| 2 | [01_NangCapDatabase.sql](database/01_NangCapDatabase.sql) | Nâng cấp cột dữ liệu và chỉ mục |
| 3 | [05_LichSuKhoVaDonHang.sql](database/05_LichSuKhoVaDonHang.sql) | Tạo lịch sử kho và trạng thái đơn |
| 4 | [06_BaremMvc.sql](database/06_BaremMvc.sql) | Bổ sung thông tin giao hàng, phí ship và mở rộng cột mật khẩu admin |
| 5 | [02_DuLieuMau.sql](database/02_DuLieuMau.sql) | Nạp tài khoản và dữ liệu trình diễn |

Giữ số hiệu các script nâng cấp để đối chiếu các phiên bản database cũ. Các bản sửa riêng 03/04 đã được tích hợp trong script 01.

Có thể chạy toàn bộ bằng `sqlcmd` từ **thư mục gốc repository**:

```powershell
sqlcmd -S .\SQLEXPRESS -E -b -f 65001 -i database/setup.sql
```

Lệnh này dành cho **database mới**, khi `BSDB2` chưa tồn tại. Với database đang sử dụng, sao lưu trước và chỉ chạy các script nâng cấp cần thiết (01, 05, 06). Dữ liệu mẫu có cập nhật lại tài khoản và danh mục, nên chỉ dùng cho môi trường demo.

### 3. Cấu hình kết nối

Trong `backend/Web.config`, cấu hình mặc định:

```xml
<connectionStrings>
  <add name="BSDBContext"
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=BSDB2;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

Thay `Data Source` nếu SQL Server trên máy bạn có tên khác. Tài khoản Windows chạy ứng dụng cần được cấp quyền truy cập database.

### 4. Khôi phục thư viện và chạy ứng dụng

1. Trong Visual Studio, chuột phải solution → **Restore NuGet Packages**.
2. Đặt project **WebBanSach** làm **Startup Project**.
3. Chọn **Build → Build Solution**.
4. Nhấn **Ctrl + F5** để chạy bằng IIS Express.
5. Mở các đường dẫn dưới đây với cổng mà Visual Studio cấp:

| Trang | Đường dẫn |
| --- | --- |
| Trang chủ | `/index.html` |
| Quản trị và dashboard | `/admin.html` |
| Giỏ hàng | `/cart.html` |
| Theo dõi đơn hàng | `/tracking.html` |

### 5. Tài khoản demo

Sau khi chạy script dữ liệu mẫu:

| Vai trò | Tài khoản | Mật khẩu |
| --- | --- | --- |
| Quản trị | `admin` | `123456` |
| Khách hàng đã xác minh | `testuser` | `12345678` |
| Khách hàng chưa xác minh | `testotp` | `12345678` |

Đây là tài khoản trình diễn. Đổi hoặc vô hiệu hóa trước khi công khai ứng dụng.

## Cấu hình email

Repository không chứa mật khẩu Gmail. Cấu hình mặc định là `LocalPickup` để hỗ trợ phát triển cục bộ. Luồng MVC trong `UserController` ghi email `.eml` vào `backend/App_Data/OtpEmails/` khi truy cập từ localhost.

Để gửi Gmail thật cho luồng MVC, tạo `backend/Web.local.config`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appSettings>
  <add key="EmailOtpMode" value="Smtp" />
  <add key="GmailSenderEmail" value="YOUR_EMAIL@gmail.com" />
  <add key="GmailAppPassword" value="YOUR_APP_PASSWORD" />
</appSettings>
```

File này được Git bỏ qua và ghi đè các giá trị `appSettings` mặc định. Có thể cung cấp email/mật khẩu qua biến môi trường `BOOKSTORE_SMTP_EMAIL` và `BOOKSTORE_SMTP_APP_PASSWORD`; vẫn cần chọn chế độ `Smtp`. File cấu hình riêng không tự được đóng gói khi publish, cần cấu hình trên máy chủ.

Luồng `/api/SendOtp` của giao diện HTML hiện vẫn ghi file `.txt` và trả `testCode` trong phản hồi để trình diễn; luồng này chưa dùng cấu hình SMTP trên. Cần hoàn thiện trước khi dùng xác minh email trong môi trường thực tế.

## Phát triển giao diện

Các nguồn HTML được duy trì trong `backend/*.html`; `frontend/` là bản tham chiếu cần cập nhật khi có thay đổi tương ứng. Sau khi sửa HTML trong backend, chạy:

```powershell
python tools/sync_razor_views.py
```

Công cụ sinh lại `backend/Views/Portal/` và một số layout/header/footer dùng chung. Các view quản lý và partial nghiệp vụ viết tay được giữ riêng. Không chỉnh trực tiếp view được sinh nếu muốn giữ thay đổi qua lần đồng bộ tiếp theo.

## Triển khai

1. Chuẩn bị Windows hosting/IIS có .NET Framework 4.8 và SQL Server.
2. Trong Visual Studio: **Publish → Folder → Release**.
3. Upload nội dung thư mục publish vào thư mục gốc website.
4. Chuyển database lên máy chủ và cập nhật connection string `BSDBContext` bằng thông tin được cấp.
5. Cấp quyền ghi thư mục `images/` để upload bìa sách; cấp quyền `App_Data/OtpEmails/` nếu dùng chế độ ghi email.
6. Cấu hình HTTPS và tài khoản quản trị riêng cho môi trường triển khai.

Ứng dụng hiện gọi API bằng đường dẫn `/api`, vì vậy nên triển khai tại gốc tên miền. Script tạo mới có lệnh `CREATE DATABASE` và `USE [BSDB2]`; với shared hosting đã cấp database riêng, cần điều chỉnh script hoặc import schema/data vào đúng database, không chạy nguyên script tạo local.

## Phạm vi và giới hạn

- Thanh toán thẻ là mô phỏng, chưa kết nối cổng thanh toán thực.
- Luồng HTML/API và các màn hình MVC cũ cùng tồn tại; lịch sử kho/trạng thái hiện được ghi trong luồng HTML/API, chưa bao phủ mọi thao tác MVC cũ hoặc chỉnh SQL trực tiếp.
- Phí ship đơn mới được lưu cùng đơn hàng; đơn cũ thiếu dữ liệu phí ship không được tự suy đoán.
- File build, packages khôi phục bằng NuGet, log, email OTP và cấu hình riêng được loại khỏi repository.
