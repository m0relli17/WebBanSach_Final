using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WebBanSach.Models;
using WebBanSach.Models.Data;
using WebBanSach.Models.Process;

namespace WebBanSach.Controllers
{
    public class ApiController : Controller
    {
        private readonly BSDBContext db = new BSDBContext();
        private const string CartSession = "CartSession";

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            Response.Headers.Remove("Access-Control-Allow-Origin");
            Response.AddHeader("Access-Control-Allow-Origin", "*");
            Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            Response.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With");

            if (Request.HttpMethod == "OPTIONS")
            {
                filterContext.Result = new HttpStatusCodeResult(200);
                return;
            }

            base.OnActionExecuting(filterContext);
        }

        // ==========================================
        // 1. SÁCH & DANH MỤC (BOOKS & CATEGORIES)
        // ==========================================

        [HttpGet]
        public JsonResult Books(int? categoryId = null, string search = null, int? page = 1, int? pageSize = 12, bool? bestSeller = null)
        {
            try
            {
                var query = db.Saches.AsNoTracking().Include(s => s.TheLoai).Include(s => s.TacGia).Include(s => s.NhaXuatBan).AsQueryable();

                if (categoryId.HasValue && categoryId.Value > 0)
                {
                    query = query.Where(s => s.MaLoai == categoryId.Value);
                }

                if (!string.IsNullOrWhiteSpace(search))
                {
                    var kw = search.Trim().ToLower();
                    query = query.Where(s => s.TenSach.ToLower().Contains(kw) ||
                                             (s.TacGia != null && s.TacGia.TenTG.ToLower().Contains(kw)));
                }

                if (bestSeller.HasValue && bestSeller.Value)
                {
                    query = query.OrderByDescending(s => s.MaSach);
                }
                else
                {
                    query = query.OrderByDescending(s => s.NgayCapNhat).ThenByDescending(s => s.MaSach);
                }

                int totalItems = query.Count();
                int curPage = Math.Max(1, page ?? 1);
                int limit = Math.Max(1, Math.Min(100, pageSize ?? 12));

                var items = query.Skip((curPage - 1) * limit).Take(limit).ToList();

                var result = items.Select(s => new
                {
                    id = s.MaSach,
                    title = s.TenSach,
                    price = s.GiaBan ?? 0,
                    priceFormatted = string.Format("{0:N0} VND", s.GiaBan ?? 0),
                    image = string.IsNullOrEmpty(s.AnhBia) ? "topSach.png" : s.AnhBia,
                    stock = s.SoLuongTon ?? 0,
                    categoryId = s.MaLoai,
                    categoryName = s.TheLoai != null ? s.TheLoai.TenLoai : "",
                    author = s.TacGia != null ? s.TacGia.TenTG : "Đang cập nhật",
                    publisher = s.NhaXuatBan != null ? s.NhaXuatBan.TenNXB : "Đang cập nhật",
                    description = s.Mota ?? ""
                }).ToList();

                return Json(new
                {
                    status = true,
                    totalItems = totalItems,
                    page = curPage,
                    pageSize = limit,
                    totalPages = (int)Math.Ceiling((double)totalItems / limit),
                    data = result
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult BookDetails(int id)
        {
            try
            {
                var s = db.Saches.AsNoTracking().Include(x => x.TheLoai).Include(x => x.TacGia).Include(x => x.NhaXuatBan).FirstOrDefault(x => x.MaSach == id);
                if (s == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy sách" }, JsonRequestBehavior.AllowGet);
                }

                var related = db.Saches.AsNoTracking()
                    .Where(x => x.MaLoai == s.MaLoai && x.MaSach != s.MaSach)
                    .Take(4)
                    .ToList()
                    .Select(r => new
                    {
                        id = r.MaSach,
                        title = r.TenSach,
                        price = r.GiaBan ?? 0,
                        priceFormatted = string.Format("{0:N0} VND", r.GiaBan ?? 0),
                        image = string.IsNullOrEmpty(r.AnhBia) ? "topSach.png" : r.AnhBia
                    }).ToList();

                return Json(new
                {
                    status = true,
                    data = new
                    {
                        id = s.MaSach,
                        title = s.TenSach,
                        price = s.GiaBan ?? 0,
                        priceFormatted = string.Format("{0:N0} VND", s.GiaBan ?? 0),
                        image = string.IsNullOrEmpty(s.AnhBia) ? "topSach.png" : s.AnhBia,
                        stock = s.SoLuongTon ?? 0,
                        categoryId = s.MaLoai,
                        categoryName = s.TheLoai != null ? s.TheLoai.TenLoai : "",
                        author = s.TacGia != null ? s.TacGia.TenTG : "Đang cập nhật",
                        publisher = s.NhaXuatBan != null ? s.NhaXuatBan.TenNXB : "Đang cập nhật",
                        description = s.Mota ?? "Chưa có mô tả chi tiết cho sách này.",
                        updatedDate = s.NgayCapNhat.HasValue ? s.NgayCapNhat.Value.ToString("dd/MM/yyyy") : ""
                    },
                    related = related
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult Categories()
        {
            try
            {
                var list = db.TheLoais.AsNoTracking().Select(t => new
                {
                    id = t.MaLoai,
                    name = t.TenLoai,
                    count = t.Saches.Count()
                }).ToList();

                return Json(new { status = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ==========================================
        // 2. GIỎ HÀNG (SHOPPING CART)
        // ==========================================

        private List<CartModel> GetSessionCart()
        {
            var cart = Session[CartSession] as List<CartModel>;
            if (cart == null)
            {
                cart = new List<CartModel>();
                Session[CartSession] = cart;
            }
            return cart;
        }

        [HttpGet]
        public JsonResult Cart()
        {
            var cart = GetSessionCart();
            decimal total = cart.Sum(x => x.Total).GetValueOrDefault(0);
            int count = cart.Sum(x => x.Quantity);

            return Json(new
            {
                status = true,
                items = cart.Select(x => new
                {
                    id = x.sach.MaSach,
                    title = x.sach.TenSach,
                    price = x.sach.GiaBan ?? 0,
                    priceFormatted = string.Format("{0:N0} VND", x.sach.GiaBan ?? 0),
                    image = string.IsNullOrEmpty(x.sach.AnhBia) ? "topSach.png" : x.sach.AnhBia,
                    quantity = x.Quantity,
                    subtotal = x.Total.GetValueOrDefault(0),
                    subtotalFormatted = string.Format("{0:N0} VND", x.Total.GetValueOrDefault(0))
                }).ToList(),
                total = total,
                totalFormatted = string.Format("{0:N0} VND", total),
                totalQuantity = count,
                itemCount = cart.Count
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult AddToCart(int id, int quantity = 1)
        {
            if (quantity < 1 || quantity > 999) quantity = 1;
            var book = db.Saches.Find(id);
            if (book == null)
            {
                return Json(new { status = false, message = "Không tìm thấy cuốn sách này." });
            }

            var cart = GetSessionCart();
            var existing = cart.FirstOrDefault(x => x.sach.MaSach == id);
            if (existing != null)
            {
                existing.Quantity = Math.Min(999, existing.Quantity + quantity);
            }
            else
            {
                cart.Add(new CartModel { sach = book, Quantity = quantity });
            }
            Session[CartSession] = cart;

            return Cart();
        }

        [HttpPost]
        public JsonResult UpdateCart(string cartModel)
        {
            try
            {
                var jsonCart = new JavaScriptSerializer().Deserialize<List<CartModel>>(cartModel);
                var cart = GetSessionCart();
                if (jsonCart != null)
                {
                    foreach (var item in cart)
                    {
                        var updated = jsonCart.FirstOrDefault(x => x.sach != null && x.sach.MaSach == item.sach.MaSach);
                        if (updated != null && updated.Quantity >= 1 && updated.Quantity <= 999)
                        {
                            item.Quantity = updated.Quantity;
                        }
                    }
                    Session[CartSession] = cart;
                }
                return Cart();
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult DeleteCartItem(int id)
        {
            var cart = GetSessionCart();
            cart.RemoveAll(x => x.sach.MaSach == id);
            Session[CartSession] = cart;
            return Cart();
        }

        [HttpPost]
        public JsonResult ClearCart()
        {
            Session[CartSession] = new List<CartModel>();
            return Cart();
        }

        // ==========================================
        // 3. TÀI KHOẢN & XÁC THỰC (AUTH & USERS)
        // ==========================================

        private string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(salt);
            using (var kdf = new Rfc2898DeriveBytes(password, salt, 210000, HashAlgorithmName.SHA256))
                return "PBKDF2$210000$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(kdf.GetBytes(32));
        }

        private bool CheckPassword(string input, string stored)
        {
            if (input == null || stored == null) return false;
            if (!stored.StartsWith("PBKDF2$")) return string.Equals(input, stored, StringComparison.Ordinal);
            try
            {
                var a = stored.Split('$');
                using (var kdf = new Rfc2898DeriveBytes(input, Convert.FromBase64String(a[2]), int.Parse(a[1]), HashAlgorithmName.SHA256))
                {
                    var actual = kdf.GetBytes(32);
                    var expected = Convert.FromBase64String(a[3]);
                    if (expected.Length != actual.Length) return false;
                    int diff = 0;
                    for (int i = 0; i < actual.Length; i++) diff |= actual[i] ^ expected[i];
                    return diff == 0;
                }
            }
            catch { return false; }
        }

        [HttpPost]
        public JsonResult Login(string username, string password)
        {
            try
            {
                username = (username ?? "").Trim();
                password = password ?? "";

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                {
                    return Json(new { status = false, message = "Vui lòng nhập tên tài khoản và mật khẩu." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null || !CheckPassword(password, customer.MatKhau))
                {
                    return Json(new { status = false, message = "Tài khoản hoặc mật khẩu không chính xác." });
                }

                if (!customer.TrangThai)
                {
                    return Json(new { status = false, message = "Tài khoản đang bị khóa hoặc chưa được kích hoạt." });
                }

                // Tự động nâng cấp mật khẩu cũ sang PBKDF2 nếu cần
                if (!customer.MatKhau.StartsWith("PBKDF2$"))
                {
                    customer.MatKhau = HashPassword(password);
                    db.SaveChanges();
                }

                if (!customer.EmailVerified)
                {
                    Session["PendingUserId"] = customer.MaKH;
                    Session["User"] = null;
                    return Json(new
                    {
                        status = true,
                        requireOtp = true,
                        userId = customer.MaKH,
                        email = customer.Email,
                        message = "Tài khoản cần xác minh email trước khi tiếp tục."
                    });
                }

                Session["User"] = customer.TaiKhoan;
                Session["UserId"] = customer.MaKH;
                Session["PendingUserId"] = null;

                return Json(new
                {
                    status = true,
                    requireOtp = false,
                    user = new
                    {
                        id = customer.MaKH,
                        username = customer.TaiKhoan,
                        name = customer.TenKH,
                        email = customer.Email,
                        phone = customer.DienThoai,
                        address = customer.DiaChi
                    }
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult Register(KhachHang model, string confirmPassword)
        {
            try
            {
                model.TaiKhoan = (model.TaiKhoan ?? "").Trim();
                model.Email = (model.Email ?? "").Trim().ToLowerInvariant();

                if (!Regex.IsMatch(model.TaiKhoan, @"^[A-Za-z0-9_.-]{3,50}$"))
                    return Json(new { status = false, message = "Tên đăng nhập phải từ 3–50 ký tự, không dấu và không chứa khoảng trắng." });

                if (string.IsNullOrEmpty(model.MatKhau) || model.MatKhau.Length < 8 || model.MatKhau.Length > 128)
                    return Json(new { status = false, message = "Mật khẩu phải từ 8–128 ký tự." });

                if (model.MatKhau != confirmPassword)
                    return Json(new { status = false, message = "Mật khẩu xác nhận không khớp." });

                if (string.IsNullOrEmpty(model.Email) || !model.Email.Contains("@"))
                    return Json(new { status = false, message = "Địa chỉ email không hợp lệ." });

                if (string.IsNullOrEmpty(model.TenKH))
                    return Json(new { status = false, message = "Vui lòng nhập họ và tên." });

                if (string.IsNullOrEmpty(model.DienThoai))
                    return Json(new { status = false, message = "Vui lòng nhập số điện thoại." });

                if (db.KhachHangs.Any(x => x.TaiKhoan == model.TaiKhoan))
                    return Json(new { status = false, message = "Tên tài khoản này đã được sử dụng." });

                if (db.KhachHangs.Any(x => x.Email == model.Email))
                    return Json(new { status = false, message = "Địa chỉ email này đã được sử dụng." });

                var customer = new KhachHang
                {
                    TaiKhoan = model.TaiKhoan,
                    MatKhau = HashPassword(model.MatKhau),
                    TenKH = model.TenKH,
                    Email = model.Email,
                    DiaChi = model.DiaChi ?? "",
                    DienThoai = model.DienThoai,
                    NgaySinh = model.NgaySinh,
                    NgayTao = DateTime.Now,
                    TrangThai = true,
                    EmailVerified = false
                };

                db.KhachHangs.Add(customer);
                db.SaveChanges();

                Session["PendingUserId"] = customer.MaKH;
                Session["User"] = null;

                return Json(new
                {
                    status = true,
                    userId = customer.MaKH,
                    email = customer.Email,
                    message = "Đăng ký thành công! Vui lòng xác minh mã OTP gửi tới email."
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return Json(new { status = true, message = "Đã đăng xuất thành công." });
        }

        [HttpGet]
        public JsonResult Me()
        {
            var username = Session["User"] as string;
            if (string.IsNullOrEmpty(username))
            {
                var pendingId = Session["PendingUserId"] as int?;
                if (pendingId.HasValue)
                {
                    var pendingUser = db.KhachHangs.Find(pendingId.Value);
                    if (pendingUser != null)
                    {
                        return Json(new
                        {
                            isLoggedIn = false,
                            isPendingOtp = true,
                            email = pendingUser.Email,
                            userId = pendingUser.MaKH
                        }, JsonRequestBehavior.AllowGet);
                    }
                }
                return Json(new { isLoggedIn = false }, JsonRequestBehavior.AllowGet);
            }

            var customer = db.KhachHangs.AsNoTracking().FirstOrDefault(x => x.TaiKhoan == username);
            if (customer == null)
            {
                return Json(new { isLoggedIn = false }, JsonRequestBehavior.AllowGet);
            }

            return Json(new
            {
                isLoggedIn = true,
                user = new
                {
                    id = customer.MaKH,
                    username = customer.TaiKhoan,
                    name = customer.TenKH,
                    email = customer.Email,
                    phone = customer.DienThoai,
                    address = customer.DiaChi,
                    verified = customer.EmailVerified
                }
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult SendOtp()
        {
            try
            {
                int? userId = Session["PendingUserId"] as int? ?? Session["UserId"] as int?;
                if (!userId.HasValue)
                {
                    var username = Session["User"] as string;
                    if (!string.IsNullOrEmpty(username))
                    {
                        var user = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                        if (user != null) userId = user.MaKH;
                    }
                }

                if (!userId.HasValue)
                {
                    return Json(new { status = false, message = "Chưa đăng nhập tài khoản cần xác minh." });
                }

                var customer = db.KhachHangs.Find(userId.Value);
                if (customer == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy người dùng." });
                }

                // Tạo mã ngẫu nhiên 6 chữ số
                string code = new Random().Next(100000, 999999).ToString();
                Session["OtpHash"] = HashPassword(code);
                Session["OtpUserId"] = customer.MaKH;
                Session["OtpEmail"] = customer.Email;
                Session["OtpExpires"] = DateTime.UtcNow.AddMinutes(5);

                // Ghi vào file trong App_Data/OtpEmails nếu ở chế độ LocalPickup
                try
                {
                    string dir = Server.MapPath("~/App_Data/OtpEmails");
                    if (!System.IO.Directory.Exists(dir)) System.IO.Directory.CreateDirectory(dir);
                    string filePath = System.IO.Path.Combine(dir, string.Format("otp_{0}_{1}.txt", customer.MaKH, DateTime.Now.ToString("yyyyMMdd_HHmmss")));
                    System.IO.File.WriteAllText(filePath, string.Format("Email: {0}\nOTP Code: {1}\nTime: {2}", customer.Email, code, DateTime.Now));
                }
                catch { }

                return Json(new
                {
                    status = true,
                    message = "Mã xác minh 6 số đã được gửi tới email của bạn (hoặc ghi nhận trong App_Data).",
                    email = customer.Email,
                    // Trong môi trường test local, hỗ trợ trả về mã test để tiện trải nghiệm:
                    testCode = code
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpPost]
        public JsonResult VerifyOtp(string code)
        {
            try
            {
                code = (code ?? "").Trim();
                var storedHash = Session["OtpHash"] as string;
                var expires = Session["OtpExpires"] as DateTime?;
                int? userId = Session["OtpUserId"] as int? ?? Session["PendingUserId"] as int?;

                if (string.IsNullOrEmpty(code) || code.Length != 6)
                {
                    return Json(new { status = false, message = "Vui lòng nhập đủ 6 chữ số mã xác minh." });
                }

                if (string.IsNullOrEmpty(storedHash) || !expires.HasValue || DateTime.UtcNow > expires.Value)
                {
                    return Json(new { status = false, message = "Mã OTP đã hết hạn hoặc chưa được tạo. Hãy bấm gửi lại mã mới." });
                }

                if (!CheckPassword(code, storedHash))
                {
                    return Json(new { status = false, message = "Mã xác minh không chính xác. Vui lòng kiểm tra lại." });
                }

                if (userId.HasValue)
                {
                    var customer = db.KhachHangs.Find(userId.Value);
                    if (customer != null)
                    {
                        customer.EmailVerified = true;
                        db.SaveChanges();
                        Session["User"] = customer.TaiKhoan;
                        Session["UserId"] = customer.MaKH;
                        Session["PendingUserId"] = null;
                        Session.Remove("OtpHash");
                        Session.Remove("OtpExpires");

                        return Json(new
                        {
                            status = true,
                            message = "Xác minh email thành công!",
                            user = new
                            {
                                id = customer.MaKH,
                                username = customer.TaiKhoan,
                                name = customer.TenKH
                            }
                        });
                    }
                }

                return Json(new { status = false, message = "Không tìm thấy thông tin tài khoản." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        // ==========================================
        // 4. ĐẶT HÀNG & THEO DÕI (ORDERS & CHECKOUT)
        // ==========================================

        [HttpPost]
        public JsonResult Checkout(string receiverName, string receiverPhone, string receiverAddress, string note,
            string paymentMethod = "cod", string cardNumber = null, string cardHolder = null, string cardExpiry = null, string cardCvv = null)
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, requireLogin = true, message = "Vui lòng đăng nhập trước khi thanh toán." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null || !customer.EmailVerified)
                {
                    return Json(new { status = false, requireOtp = true, message = "Tài khoản cần xác minh email trước khi đặt hàng." });
                }

                var cart = GetSessionCart();
                if (cart == null || cart.Count == 0)
                {
                    return Json(new { status = false, message = "Giỏ hàng của bạn đang trống." });
                }

                if (string.IsNullOrWhiteSpace(receiverName) || string.IsNullOrWhiteSpace(receiverAddress) || string.IsNullOrWhiteSpace(receiverPhone))
                {
                    return Json(new { status = false, message = "Vui lòng nhập đầy đủ thông tin giao hàng." });
                }

                paymentMethod = (paymentMethod ?? "cod").Trim().ToLowerInvariant();
                bool isCreditCard = (paymentMethod == "credit_card" || paymentMethod == "card");
                string maskedCardNumber = "";

                if (isCreditCard)
                {
                    var cleanNumber = Regex.Replace(cardNumber ?? "", @"[\s-]", "");
                    if (string.IsNullOrEmpty(cleanNumber) || cleanNumber.Length < 13 || cleanNumber.Length > 19 || !Regex.IsMatch(cleanNumber, @"^\d+$"))
                    {
                        return Json(new { status = false, message = "Số thẻ tín dụng không hợp lệ (yêu cầu từ 13 đến 19 chữ số)." });
                    }

                    if (string.IsNullOrWhiteSpace(cardHolder))
                    {
                        return Json(new { status = false, message = "Vui lòng nhập tên chủ thẻ in trên thẻ tín dụng." });
                    }

                    var cleanExpiry = (cardExpiry ?? "").Trim();
                    if (!Regex.IsMatch(cleanExpiry, @"^(0[1-9]|1[0-2])\/([0-9]{2}|[0-9]{4})$"))
                    {
                        return Json(new { status = false, message = "Ngày hết hạn thẻ không đúng định dạng MM/YY (ví dụ: 12/28)." });
                    }

                    var cleanCvv = (cardCvv ?? "").Trim();
                    if (!Regex.IsMatch(cleanCvv, @"^\d{3,4}$"))
                    {
                        return Json(new { status = false, message = "Mã bảo mật CVV/CVC không hợp lệ (yêu cầu 3 hoặc 4 chữ số)." });
                    }

                    maskedCardNumber = "•••• •••• •••• " + cleanNumber.Substring(cleanNumber.Length - 4);
                }

                using (var trans = db.Database.BeginTransaction())
                {
                    var order = new DonDatHang
                    {
                        MaKH = customer.MaKH,
                        NgayDat = DateTime.Now,
                        NgayGiao = DateTime.Now.AddDays(3),
                        TinhTrang = isCreditCard, // true nếu đã thanh toán bằng thẻ
                        ThanhToan = isCreditCard ? 1 : 0, // 1: Thẻ tín dụng (Đã thanh toán), 0: COD
                        Tracking = 0  // 0: Chờ xử lý
                    };

                    db.DonDatHangs.Add(order);
                    db.SaveChanges();

                    foreach (var item in cart)
                    {
                        var book = db.Saches.Find(item.sach.MaSach);
                        if (book == null)
                        {
                            trans.Rollback();
                            return Json(new { status = false, message = string.Format("Sách '{0}' không tồn tại.", item.sach.TenSach) });
                        }

                        // Cập nhật số lượng tồn kho (nếu có)
                        if (book.SoLuongTon.HasValue)
                        {
                            book.SoLuongTon = Math.Max(0, (book.SoLuongTon ?? 0) - item.Quantity);
                        }

                        var detail = new ChiTietDDH
                        {
                            MaDDH = order.MaDDH,
                            MaSach = item.sach.MaSach,
                            SoLuong = item.Quantity,
                            DonGia = item.sach.GiaBan ?? 0
                        };
                        db.ChiTietDDHs.Add(detail);
                    }

                    db.SaveChanges();
                    trans.Commit();

                    // Xóa giỏ hàng sau khi đặt thành công
                    Session[CartSession] = new List<CartModel>();

                    return Json(new
                    {
                        status = true,
                        orderId = order.MaDDH,
                        paymentMethod = isCreditCard ? "credit_card" : "cod",
                        paymentMethodText = isCreditCard ? "Thẻ tín dụng (Credit Card)" : "Thanh toán khi nhận hàng (COD)",
                        isPaid = isCreditCard,
                        maskedCard = isCreditCard ? maskedCardNumber : null,
                        message = isCreditCard
                            ? string.Format("Thanh toán thành công qua Thẻ tín dụng! Mã đơn hàng của bạn là #{0}", order.MaDDH)
                            : string.Format("Đặt hàng thành công! Mã đơn của bạn là #{0}", order.MaDDH)
                    });
                }
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpGet]
        public JsonResult MyOrders()
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, message = "Chưa đăng nhập." }, JsonRequestBehavior.AllowGet);
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                if (customer == null)
                {
                    return Json(new { status = false, message = "Người dùng không tồn tại." }, JsonRequestBehavior.AllowGet);
                }

                var orders = db.DonDatHangs.AsNoTracking()
                    .Where(o => o.MaKH == customer.MaKH)
                    .OrderByDescending(o => o.NgayDat)
                    .ToList();

                var list = orders.Select(o => {
                    var details = db.ChiTietDDHs.AsNoTracking().Where(d => d.MaDDH == o.MaDDH).Include(d => d.Sach).ToList();
                    decimal total = details.Sum(d => (decimal?)d.DonGia * d.SoLuong).GetValueOrDefault(0);
                    bool isPaid = (o.ThanhToan == 1);
                    return new
                    {
                        id = o.MaDDH,
                        orderDate = o.NgayDat.ToString("dd/MM/yyyy HH:mm"),
                        deliveryDate = o.NgayGiao.ToString("dd/MM/yyyy"),
                        status = o.Tracking ?? 0,
                        statusText = GetTrackingStatusText(o.Tracking ?? 0),
                        paymentStatus = o.ThanhToan ?? 0,
                        paymentMethod = isPaid ? "credit_card" : "cod",
                        paymentMethodText = isPaid ? "Thẻ tín dụng (Đã thanh toán)" : "COD (Thu tiền khi nhận)",
                        isPaid = isPaid,
                        total = total,
                        totalFormatted = string.Format("{0:N0} VND", total),
                        itemCount = details.Sum(d => d.SoLuong),
                        items = details.Select(d => new
                        {
                            bookId = d.MaSach,
                            title = d.Sach != null ? d.Sach.TenSach : "",
                            image = d.Sach != null ? d.Sach.AnhBia : "topSach.png",
                            quantity = d.SoLuong,
                            price = d.DonGia,
                            priceFormatted = string.Format("{0:N0} VND", d.DonGia)
                        }).ToList()
                    };
                }).ToList();

                return Json(new { status = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult CancelOrder(int id)
        {
            try
            {
                var username = Session["User"] as string;
                if (string.IsNullOrEmpty(username))
                {
                    return Json(new { status = false, message = "Chưa đăng nhập." });
                }

                var customer = db.KhachHangs.FirstOrDefault(x => x.TaiKhoan == username);
                var order = db.DonDatHangs.FirstOrDefault(o => o.MaDDH == id && o.MaKH == customer.MaKH);
                if (order == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy đơn hàng." });
                }

                if ((order.Tracking ?? 0) != 0)
                {
                    return Json(new { status = false, message = "Chỉ có thể hủy đơn hàng khi đang ở trạng thái 'Chờ xử lý'." });
                }

                // Trả lại số lượng tồn kho
                var details = db.ChiTietDDHs.Where(d => d.MaDDH == id).ToList();
                foreach (var item in details)
                {
                    var book = db.Saches.Find(item.MaSach);
                    if (book != null)
                    {
                        book.SoLuongTon = (book.SoLuongTon ?? 0) + item.SoLuong;
                    }
                }

                order.Tracking = 4; // 4: Đã hủy
                db.SaveChanges();

                return Json(new { status = true, message = "Đã hủy đơn hàng #" + id + " thành công." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        // ==========================================
        // 5. QUẢN TRỊ VIÊN (ADMIN APIS)
        // ==========================================

        [HttpPost]
        public JsonResult AdminLogin(string username, string password)
        {
            try
            {
                username = (username ?? "").Trim();
                password = (password ?? "").Trim();

                var admin = db.Admins.FirstOrDefault(a => a.TaiKhoan == username && a.MatKhau == password && a.TrangThai == true);
                if (admin == null)
                {
                    return Json(new { status = false, message = "Sai tài khoản hoặc mật khẩu quản trị." });
                }

                Session["AdminUser"] = admin.TaiKhoan;
                Session["AdminName"] = admin.HoTen;

                return Json(new
                {
                    status = true,
                    admin = new { username = admin.TaiKhoan, name = admin.HoTen }
                });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        [HttpGet]
        public JsonResult AdminOrders()
        {
            try
            {
                var orders = db.DonDatHangs.AsNoTracking().Include(o => o.KhachHang).OrderByDescending(o => o.NgayDat).ToList();
                var list = orders.Select(o => {
                    var details = db.ChiTietDDHs.AsNoTracking().Where(d => d.MaDDH == o.MaDDH).Include(d => d.Sach).ToList();
                    decimal total = details.Sum(d => (decimal?)d.DonGia * d.SoLuong).GetValueOrDefault(0);
                    bool isPaid = (o.ThanhToan == 1);
                    return new
                    {
                        id = o.MaDDH,
                        customerName = o.KhachHang != null ? o.KhachHang.TenKH : "Khách",
                        customerPhone = o.KhachHang != null ? o.KhachHang.DienThoai : "",
                        orderDate = o.NgayDat.ToString("dd/MM/yyyy HH:mm"),
                        status = o.Tracking ?? 0,
                        statusText = GetTrackingStatusText(o.Tracking ?? 0),
                        paymentStatus = o.ThanhToan ?? 0,
                        paymentMethod = isPaid ? "credit_card" : "cod",
                        paymentMethodText = isPaid ? "Thẻ tín dụng (Đã TT)" : "COD (Chưa TT)",
                        isPaid = isPaid,
                        total = total,
                        totalFormatted = string.Format("{0:N0} VND", total),
                        itemCount = details.Sum(d => d.SoLuong),
                        items = details.Select(d => new
                        {
                            bookId = d.MaSach,
                            title = d.Sach != null ? d.Sach.TenSach : "",
                            quantity = d.SoLuong,
                            price = d.DonGia
                        }).ToList()
                    };
                }).ToList();

                return Json(new { status = true, data = list }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult AdminUpdateOrderStatus(int id, int status)
        {
            try
            {
                var order = db.DonDatHangs.Find(id);
                if (order == null)
                {
                    return Json(new { status = false, message = "Không tìm thấy đơn hàng." });
                }

                order.Tracking = status;
                if (status == 3) // Đã giao
                {
                    order.TinhTrang = true;
                    order.ThanhToan = 1;
                }
                db.SaveChanges();

                return Json(new { status = true, message = "Cập nhật trạng thái đơn hàng thành công." });
            }
            catch (Exception ex)
            {
                return Json(new { status = false, message = ex.Message });
            }
        }

        private static string GetTrackingStatusText(int tracking)
        {
            switch (tracking)
            {
                case 0: return "Chờ xử lý";
                case 1: return "Đã đóng gói";
                case 2: return "Đang giao hàng";
                case 3: return "Đã giao thành công";
                case 4: return "Đã hủy";
                default: return "Đang xử lý";
            }
        }
    }
}
