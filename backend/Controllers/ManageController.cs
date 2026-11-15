using System;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using WebBanSach.Models;
using WebBanSach.Models.Data;

namespace WebBanSach.Controllers
{
    public class ManageController : Controller
    {
        private readonly BSDBContext db = new BSDBContext();
        protected override void OnActionExecuting(ActionExecutingContext context)
        {
            var username = Session["AdminUser"] as string;
            if (username == null || !db.Admins.Any(a => a.TaiKhoan == username && a.TrangThai == true)) { Session.Remove("AdminUser"); context.Result = Redirect("~/admin.html"); return; }
            base.OnActionExecuting(context);
        }
        private bool ValidKind(string kind) { return kind == "category" || kind == "author" || kind == "publisher"; }
        [HttpGet]
        public ActionResult Catalog(string kind = "category")
        {
            if (!ValidKind(kind)) return HttpNotFound();
            ViewBag.Kind = kind;
            var rows = kind == "category" ? db.TheLoais.Select(x => new CatalogRow { Id = x.MaLoai, Name = x.TenLoai, ProductCount = x.Saches.Count() }).ToList()
                : kind == "author" ? db.TacGias.Select(x => new CatalogRow { Id = x.MaTG, Name = x.TenTG, ProductCount = x.Saches.Count() }).ToList()
                : db.NhaXuatBans.Select(x => new CatalogRow { Id = x.MaNXB, Name = x.TenNXB, ProductCount = x.Saches.Count() }).ToList();
            return View(rows.OrderBy(x => x.Name).ToList());
        }
        [HttpGet]
        public ActionResult CatalogEdit(string kind, int id = 0)
        {
            if (!ValidKind(kind)) return HttpNotFound();
            var model = new CatalogEditModel { Kind = kind, Id = id };
            if (id != 0) {
                if (kind == "category") { var x = db.TheLoais.Find(id); if (x == null) return HttpNotFound(); model.Name = x.TenLoai; }
                if (kind == "author") { var x = db.TacGias.Find(id); if (x == null) return HttpNotFound(); model.Name = x.TenTG; model.Address = x.QueQuan; model.BirthDate = x.NgaySinh; model.DeathDate = x.NgayMat; model.Biography = x.TieuSu; }
                if (kind == "publisher") { var x = db.NhaXuatBans.Find(id); if (x == null) return HttpNotFound(); model.Name = x.TenNXB; model.Address = x.DiaChi; model.Phone = x.DienThoai; }
            }
            return View(model);
        }
        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CatalogEdit(CatalogEditModel model)
        {
            if (!ValidKind(model.Kind)) return HttpNotFound();
            model.Name = (model.Name ?? "").Trim();
            if (model.Name.Length == 0) ModelState.AddModelError("Name", "Vui lòng nhập tên.");
            if (model.Kind == "author" && (model.BirthDate > DateTime.Today || model.DeathDate > DateTime.Today || model.BirthDate > model.DeathDate)) ModelState.AddModelError("", "Ngày sinh/ngày mất không được ở tương lai; ngày mất không được trước ngày sinh.");
            var duplicate = model.Kind == "category" ? db.TheLoais.Any(x => x.MaLoai != model.Id && x.TenLoai.Trim() == model.Name)
                : model.Kind == "author" ? db.TacGias.Any(x => x.MaTG != model.Id && x.TenTG.Trim() == model.Name)
                : db.NhaXuatBans.Any(x => x.MaNXB != model.Id && x.TenNXB.Trim() == model.Name);
            if (duplicate) ModelState.AddModelError("Name", "Tên đã tồn tại.");
            if (!ModelState.IsValid) return View(model);
            if (model.Kind == "category") { var x = model.Id == 0 ? new TheLoai() : db.TheLoais.Find(model.Id); if (x == null) return HttpNotFound(); x.TenLoai = model.Name; if (model.Id == 0) db.TheLoais.Add(x); }
            if (model.Kind == "author") { var x = model.Id == 0 ? new TacGia() : db.TacGias.Find(model.Id); if (x == null) return HttpNotFound(); x.TenTG = model.Name; x.QueQuan = model.Address; x.NgaySinh = model.BirthDate; x.NgayMat = model.DeathDate; x.TieuSu = model.Biography; if (model.Id == 0) db.TacGias.Add(x); }
            if (model.Kind == "publisher") { var x = model.Id == 0 ? new NhaXuatBan() : db.NhaXuatBans.Find(model.Id); if (x == null) return HttpNotFound(); x.TenNXB = model.Name; x.DiaChi = model.Address; x.DienThoai = model.Phone; if (model.Id == 0) db.NhaXuatBans.Add(x); }
            db.SaveChanges(); TempData["Notice"] = "Đã lưu danh mục."; return RedirectToAction("Catalog", new { kind = model.Kind });
        }
        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult CatalogDelete(string kind, int id)
        {
            if (!ValidKind(kind)) return HttpNotFound();
            try {
                using (var tx = db.Database.BeginTransaction(IsolationLevel.Serializable)) {
                    bool used = kind == "category" ? db.Saches.Any(b => b.MaLoai == id) : kind == "author" ? db.Saches.Any(b => b.MaTG == id) : db.Saches.Any(b => b.MaNXB == id);
                    if (used) { TempData["Error"] = "Không thể xóa: danh mục đang được sách sử dụng."; return RedirectToAction("Catalog", new { kind }); }
                    if (kind == "category") { var x = db.TheLoais.Find(id); if (x == null) return HttpNotFound(); db.TheLoais.Remove(x); }
                    if (kind == "author") { var x = db.TacGias.Find(id); if (x == null) return HttpNotFound(); db.TacGias.Remove(x); }
                    if (kind == "publisher") { var x = db.NhaXuatBans.Find(id); if (x == null) return HttpNotFound(); db.NhaXuatBans.Remove(x); }
                    db.SaveChanges(); tx.Commit(); TempData["Notice"] = "Đã xóa danh mục.";
                }
            } catch (System.Data.Entity.Infrastructure.DbUpdateException) { TempData["Error"] = "Danh mục có dữ liệu liên quan nên không thể xóa."; }
            return RedirectToAction("Catalog", new { kind });
        }
        [HttpGet]
        public ActionResult CatalogDetails(string kind, int id)
        {
            // Category and publisher have fewer than five scalar columns: their count links open the product list instead.
            if (!ValidKind(kind)) return HttpNotFound();
            var query = db.Saches.AsNoTracking().Include(b => b.TheLoai).Include(b => b.TacGia).Include(b => b.NhaXuatBan);
            ViewBag.Kind = kind;
            ViewBag.Name = kind == "category" ? db.TheLoais.Where(x => x.MaLoai == id).Select(x => x.TenLoai).FirstOrDefault() : kind == "author" ? db.TacGias.Where(x => x.MaTG == id).Select(x => x.TenTG).FirstOrDefault() : db.NhaXuatBans.Where(x => x.MaNXB == id).Select(x => x.TenNXB).FirstOrDefault();
            if (ViewBag.Name == null) return HttpNotFound();
            ViewBag.Author = kind == "author" ? db.TacGias.AsNoTracking().FirstOrDefault(x => x.MaTG == id) : null;
            return View(query.Where(b => kind == "category" ? b.MaLoai == id : kind == "author" ? b.MaTG == id : b.MaNXB == id).ToList());
        }
        [HttpGet]
        public ActionResult Inventory(string tab = "available")
        {
            if (tab != "available" && tab != "restock") return HttpNotFound();
            ViewBag.Tab = tab;
            return View(db.Saches.AsNoTracking().Include(b => b.TheLoai).Where(b => tab == "available" ? (b.SoLuongTon ?? 0) > 0 : (b.SoLuongTon ?? 0) == 0).OrderBy(b => b.TenSach).ToList());
        }
        [HttpGet]
        public ActionResult Admins() { return View(db.Admins.AsNoTracking().OrderBy(a => a.IDAdmin).ToList()); }
        [HttpGet]
        public ActionResult AdminEdit(int id = 0)
        {
            if (id == 0) return View(new AdminEditModel { Active = true });
            var a = db.Admins.Find(id); if (a == null) return HttpNotFound();
            return View(new AdminEditModel { Id = id, Username = a.TaiKhoan, FullName = a.HoTen, Active = a.TrangThai == true });
        }
        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AdminEdit(AdminEditModel model)
        {
            model.Username = (model.Username ?? "").Trim(); model.FullName = (model.FullName ?? "").Trim();
            if (model.Id == 0 && string.IsNullOrEmpty(model.Password)) ModelState.AddModelError("Password", "Vui lòng nhập mật khẩu.");
            if (model.Password != null && model.Password.Any(char.IsWhiteSpace)) ModelState.AddModelError("Password", "Mật khẩu không chứa khoảng trắng.");
            if (model.FullName.Length == 0) ModelState.AddModelError("FullName", "Vui lòng nhập họ tên.");
            using (var tx = db.Database.BeginTransaction(IsolationLevel.Serializable)) {
                var a = model.Id == 0 ? new Admin() : db.Admins.Find(model.Id); if (a == null) return HttpNotFound();
                if (db.Admins.Any(x => x.IDAdmin != model.Id && x.TaiKhoan == model.Username)) ModelState.AddModelError("Username", "Tài khoản đã tồn tại.");
                if (model.Id != 0 && a.TaiKhoan == (string)Session["AdminUser"] && (!model.Active || model.Username != a.TaiKhoan)) ModelState.AddModelError("", "Không thể khóa hoặc đổi tên tài khoản đang đăng nhập.");
                if (!model.Active && a.TrangThai == true && db.Admins.Count(x => x.TrangThai == true) <= 1) ModelState.AddModelError("", "Phải giữ ít nhất một quản trị viên hoạt động.");
                if (!ModelState.IsValid) { model.Password = null; return View(model); }
                a.TaiKhoan = model.Username; a.HoTen = model.FullName; a.TrangThai = model.Active;
                if (!string.IsNullOrEmpty(model.Password)) a.MatKhau = UserController.Hash(model.Password);
                if (model.Id == 0) db.Admins.Add(a);
                db.SaveChanges(); tx.Commit(); TempData["Notice"] = "Đã lưu quản trị viên.";
                if (a.TaiKhoan == (string)Session["AdminUser"]) Session["AdminName"] = a.HoTen;
            }
            return RedirectToAction("Admins");
        }
        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AdminDelete(int id)
        {
            using (var tx = db.Database.BeginTransaction(IsolationLevel.Serializable)) {
                var a = db.Admins.Find(id); if (a == null) return HttpNotFound();
                if (a.TaiKhoan == (string)Session["AdminUser"] || (a.TrangThai == true && db.Admins.Count(x => x.TrangThai == true) <= 1)) TempData["Error"] = "Không thể xóa tài khoản đang đăng nhập hoặc quản trị viên hoạt động cuối cùng.";
                else { db.Admins.Remove(a); db.SaveChanges(); tx.Commit(); TempData["Notice"] = "Đã xóa quản trị viên."; }
            }
            return RedirectToAction("Admins");
        }
        [HttpGet]
        public ActionResult Customers(string search = "")
        {
            ViewBag.Search = search;
            return View(db.KhachHangs.AsNoTracking().Where(c => search == "" || c.TenKH.Contains(search) || c.TaiKhoan.Contains(search)).OrderBy(c => c.MaKH).ToList());
        }
        [HttpGet]
        public ActionResult Customer(int id)
        {
            var c = db.KhachHangs.AsNoTracking().FirstOrDefault(x => x.MaKH == id); if (c == null) return HttpNotFound();
            ViewBag.Orders = db.DonDatHangs.AsNoTracking().Where(o => o.MaKH == id).OrderByDescending(o => o.MaDDH).ToList();
            return View(c);
        }
        protected override void Dispose(bool disposing) { if (disposing) db.Dispose(); base.Dispose(disposing); }
    }
}
