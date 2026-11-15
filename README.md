# WebBanSach - Nền tảng Nhà sách Trực tuyến Toàn diện

> **Hệ thống thương mại điện tử chuyên ngành sách**, xây dựng trên nền tảng **ASP.NET MVC 5 (.NET Framework 4.8)**, **Entity Framework 6 Code First / Database First**, **Microsoft SQL Server**, kết hợp giao diện hiện đại **WebBanSach Design System** lấy cảm hứng từ các sàn thương mại điện tử hàng đầu, tối ưu hiển thị đa thiết bị từ Mobile đến màn hình 4K Ultra HD.

---

## 🌟 Tính năng nổi bật của Hệ thống

### 1. Khám phá Sách & Trải nghiệm Người dùng
- **Slideshow Hero đa biểu ngữ:** Hiển thị 2 banner song song trên mỗi lượt trình chiếu, chuyển động mượt mà, tự động điều chỉnh tỷ lệ khung hình.
- **Thanh tìm kiếm thông minh:** Tìm kiếm nhanh theo tựa sách, tác giả, thể loại; hỗ trợ chống rung (debounce 350ms), nút xóa nhanh (Clear X), cùng thanh danh mục thẻ (Quick Tags) cuộn ngang tiện lợi.
- **Bộ lọc & Sắp xếp đa dạng:** Danh mục thể loại bên trái với số lượng đầu sách thực tế; sắp xếp linh hoạt theo Mới cập nhật, Giá thấp đến cao, Giá cao đến thấp, Độ hot 30 ngày, Phổ biến (đánh giá) và Bán chạy nhất.
- **Trình bày lưới sách cân đối:** Tự động hiển thị 12 sách/trang, phân chia hoàn hảo cho giao diện Mobile (2 cột), Tablet (3 cột), Full HD (4 cột), 2K (5 cột) và 4K (6 cột).

### 2. Chi tiết Sách & Nhận xét Độc giả
- **Thông tin chi tiết rõ ràng:** Hiển thị đầy đủ Nhà xuất bản, Tác giả, Thể loại, Tồn kho, Giá gốc gạch ngang, Tỷ lệ giảm giá (%) và Giá ưu đãi.
- **Điều chỉnh số lượng linh hoạt:** Nút tăng/giảm số lượng (+/-) kiểm soát chặt chẽ theo giới hạn tồn kho thực tế.
- **Đánh giá & Bình luận tiếng Việt Unicode:** Hệ thống chấm điểm 1–5 sao kèm nhận xét chi tiết của người mua đã xác minh, hỗ trợ lọc và duyệt bởi quản trị viên.
- **Đầu sách liên quan:** Gợi ý các cuốn sách cùng chuyên mục, giúp nâng cao trải nghiệm mua sắm.

### 3. Giỏ hàng Phản ứng Thời gian thực & Kiểm soát Mua hàng
- **Tính toán tài chính minh bạch:**
  - **Tạm tính:** Tổng tiền theo giá niêm yết gốc.
  - **Giảm giá:** Tổng tiền tiết kiệm từ các chương trình ưu đãi (`Tạm tính - Thành tiền`).
  - **Tiến trình Freeship:** Tự động kích hoạt Miễn phí vận chuyển khi đơn hàng đạt từ **150.000 ₫**; hiển thị số tiền cần mua thêm nếu chưa đủ điều kiện.
  - **Huy hiệu Tiết kiệm:** Nổi bật số tiền khách hàng được giảm trực tiếp trên tổng đơn.
- **Kiểm soát xác thực (Authentication Guard):**
  - Khách vãng lai thoải mái tìm kiếm và thêm sách vào giỏ hàng.
  - Khi nhấn **"Mua Hàng"**, hệ thống kiểm tra trạng thái đăng nhập. Nếu chưa đăng nhập, hành động mua hàng sẽ bị chặn và tự động chuyển hướng đến trang đăng nhập kèm tham số lưu đích đến `?redirect=checkout.html`.
  - Hiển thị chú thích trực quan ngay dưới nút Mua hàng: `🔒 Cần đăng nhập để tiến hành mua hàng` hoặc `✓ Đã đăng nhập: [Tên khách hàng]`.

### 4. Đăng ký & Bảo mật Tài khoản Khách hàng
- **Bảo mật mật khẩu nghiêm ngặt:** Yêu cầu độ dài **8 đến 128 ký tự**, **tuyệt đối không chứa khoảng trắng** (`' '`), được kiểm tra đồng bộ cả ở Frontend và Backend API.
- **Trải nghiệm nhập mật khẩu:** Nút ẩn/hiện mật khẩu (biểu tượng mắt) được tích hợp tinh tế **bên trong** ô nhập văn bản, không làm biến dạng giao diện.
- **Xác thực OTP qua Email:** Tự động gửi mã OTP 6 chữ số qua hệ thống mô phỏng email cục bộ (`App_Data/OtpEmails`), bảo vệ tài khoản khách hàng khỏi đăng ký ảo.
- **Băm mật khẩu an toàn:** Sử dụng thuật toán băm chuẩn công nghiệp **PBKDF2-SHA256 (210.000 vòng lặp)**.

### 5. Thanh toán Linh hoạt & Đơn hàng
- **Đa dạng hình thức thanh toán:**
  - **COD (Tiền mặt khi nhận hàng):** Thuận tiện, phổ biến.
  - **Thẻ tín dụng / Ghi nợ trực tuyến (Mô phỏng):** Hỗ trợ kiểm tra định dạng thẻ Visa, MasterCard, Amex (13–19 chữ số), ngày hết hạn (MM/YY) và mã bảo mật CVV (3–4 chữ số) kèm giao diện thẻ trực quan cập nhật theo thời gian thực.
- **Kiểm soát trừ kho nguyên tử (Atomic Update):** Ngăn chặn tình trạng đặt hàng vượt quá số lượng tồn kho khả dụng khi có nhiều người cùng mua.

### 6. Theo dõi Đơn hàng Chuẩn 5 Trạng thái
Hệ thống theo dõi đơn hàng đồng bộ hoàn toàn giữa giao diện Khách hàng (`tracking.html`) và Quản trị (`admin.html`):
- `0` - **Chờ xử lý:** Khách hàng có quyền tự bấm hủy đơn hàng kèm hoàn trả số lượng sách về kho ngay lập tức.
- `1` - **Đã đóng gói:** Đơn hàng đang được chuẩn bị tại kho sách.
- `2` - **Đang giao:** Đơn hàng đã bàn giao cho đơn vị vận chuyển.
- `3` - **Đã giao:** Đơn hàng đã phát thành công (Huy hiệu xanh lá `badge bg-success`).
- `4` - **Đã hủy:** Đơn hàng đã bị hủy (Huy hiệu xám `badge bg-secondary`).

### 7. Trang Quản trị Toàn diện (Admin & Seller Dashboard)
- **Đăng nhập quản trị viên:** Bảo vệ bằng phiên làm việc riêng biệt và mã CSRF Token.
- **Điều phối đơn đặt hàng:** Lọc theo từng trạng thái đơn (Tất cả, Chờ xử lý, Đã đóng gói, Đang giao, Đã giao, Đã hủy), tìm kiếm theo mã đơn hoặc tên khách, cập nhật trạng thái đơn hàng tức thì.
- **Quản lý danh mục & sách:** Thêm mới, chỉnh sửa thông tin giá bán, giá gốc, giảm giá, tồn kho, tải lên ảnh bìa (hỗ trợ JPG, PNG, GIF, BMP, JFIF). Chặn xóa sách đã từng có trong lịch sử đơn hàng để đảm bảo tính toàn vẹn dữ liệu kế toán.
- **Kiểm duyệt đánh giá:** Tra cứu và gỡ bỏ bình luận vi phạm tiêu chuẩn cộng đồng.

### 8. Thiết kế Thích ứng Đa Màn hình (Hyper-Care Responsive)
Hệ thống CSS tùy chỉnh theo chuẩn Bootstrap 5 mở rộng, tối ưu hiển thị:
- **Mobile (< 768px):** Thanh tìm kiếm full-width, logo tinh gọn, thanh danh mục cuộn ngang, lưới sách 2 cột hiển thị đầy đủ thông tin, form mua hàng tối ưu chạm vuốt.
- **Tablet / Laptop (768px – 1399px):** Hiển thị danh mục bên cạnh nội dung chính, lưới sách 3 cột.
- **Full HD (1400px – 1999px):** Container mở rộng 1640px, lưới sách 4 cột chuẩn mực.
- **2K QHD (2000px – 3199px):** Font chữ gốc tăng lên 17px, container mở rộng 2200px, lưới sách 5 cột hài hòa.
- **4K UHD (≥ 3200px):** Font chữ gốc tăng lên 20px, container mở rộng 3000px, lưới sách 6 cột sắc nét, tối ưu độ tương phản hình ảnh.

---

## 🚀 Hướng dẫn Khởi chạy Dự án với Microsoft Visual Studio

1. **Khởi tạo Cơ sở Dữ liệu SQL Server:**
   - Mở SQL Server Management Studio (SSMS), kết nối tới máy chủ SQL Server cục bộ (ví dụ: `.\SQLEXPRESS` hoặc `localhost`).
   - Mở và thực thi lần lượt các script theo thứ tự:
     - `00_TaoDatabaseMoi.sql` (Khởi tạo CSDL `BSDB2` và các bảng cơ sở).
     - `01_NangCapDatabase.sql` (Cập nhật các cột nâng cấp, chỉ mục và ràng buộc).
     - `02_DuLieuKiemThu.sql` (Nạp dữ liệu danh mục sách, tài khoản mẫu và đánh giá có dấu tiếng Việt).
2. **Mở dự án trong Visual Studio:**
   - Khởi động **Microsoft Visual Studio 2019/2022** và mở file giải pháp `WebBanSach.sln`.
   - Chuỗi kết nối trong `backend/Web.config` mặc định kết nối tới `.\SQLEXPRESS;Initial Catalog=BSDB2;Integrated Security=True`.
3. **Biên dịch và Chạy với IIS Express:**
   - Đặt project `backend` làm **Startup Project**.
   - Bấm **F5** hoặc **Ctrl + F5** để khởi chạy với máy chủ IIS Express.
   - Trình duyệt sẽ mở tại `http://localhost:[Port]/index.html`.

---

## 🔑 Tài khoản Kiểm thử & Dữ liệu Thuyết trình Demo

### 1. Khách hàng (Customer)
| Tài khoản | Mật khẩu | Trạng thái | Vai trò kiểm thử |
|---|---|---|---|
| **`testuser`** | `12345678` | Đã xác minh OTP | Tài khoản đầy đủ lịch sử đơn hàng, địa chỉ giao hàng sẵn sàng để demo giỏ hàng, checkout và tracking. |
| **`testotp`** | `12345678` | Chưa xác minh | Dùng để demo luồng xác thực mã OTP 6 số qua email. |
| **`customer_vip`** | `12345678` | Đã xác minh | Khách hàng VIP khu vực TP. Hồ Chí Minh. |
| **`customer_locked`** | `12345678` | Đã khóa | Dùng để demo thông báo từ chối đăng nhập khi tài khoản bị khóa. |

### 2. Quản trị viên (Admin & Seller)
| Tài khoản | Mật khẩu | Quyền hạn |
|---|---|---|
| **`admin`** | `123456` | Quản trị viên tối cao: Quản lý sách, tồn kho, điều phối đơn hàng và duyệt đánh giá. |
| **`manager`** | `123456` | Quản lý điều phối đơn hàng. |

### 3. Thông tin Thẻ Tín dụng Thử nghiệm (Credit Card Sandbox)
- **Số thẻ:** `4532 1122 3344 5566` (Visa) hoặc `5412 7512 3412 3456` (MasterCard)
- **Tên chủ thẻ:** `NGUYEN VAN TEST`
- **Ngày hết hạn:** `12/28` (Định dạng `MM/YY`)
- **Mã CVV:** `888`

---

## 📂 Danh mục Tài liệu Kèm theo
- 📖 [Hướng dẫn chạy chi tiết (HUONG_DAN_CHAY.md)](HUONG_DAN_CHAY.md)
- 🛠️ [Hướng dẫn Visual Studio & SQL Server (HUONG_DAN_MVS.md)](HUONG_DAN_MVS.md)
- 🏗️ [Cấu trúc Kiến trúc & Danh mục API (structure.md)](structure.md)
- 👥 [Kịch bản Kiểm thử & Thuyết trình (user.md)](user.md)
