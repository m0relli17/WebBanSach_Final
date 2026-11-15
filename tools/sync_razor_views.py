"""Convert the maintained HTML page bodies into Razor views; shared chrome is rendered by layouts."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
B = ROOT / 'backend'
S = B / 'Views' / 'Shared'
P = B / 'Views' / 'Portal'
S.mkdir(parents=True, exist_ok=True)
P.mkdir(parents=True, exist_ok=True)

def write(path, text):
    path.write_text(text, encoding='utf-8-sig')

def literal(text):
    return text.replace('@', '@("@")')

index = (B / 'index.html').read_text(encoding='utf-8-sig')
detail = (B / 'book-details.html').read_text(encoding='utf-8-sig')
admin = (B / 'admin.html').read_text(encoding='utf-8-sig')
write(S / '_CatalogHeader.cshtml', literal(re.search(r'<header\b.*?</header>', index, re.S).group()))
write(S / '_CustomerHeader.cshtml', literal(re.search(r'<header\b.*?</header>', detail, re.S).group()))
write(S / '_Footer.cshtml', literal(re.search(r'<footer\b.*?</footer>', index, re.S).group()))
write(S / '_AdminHeader.cshtml', literal(re.search(r'<nav\b.*?</nav>', admin, re.S).group()))
head = re.search(r'<head>(.*?)</head>', index, re.S).group(1)
head = re.sub(r'<title>.*?</title>', '<title>@ViewBag.Title - WebBanSach</title>', literal(head), flags=re.S)
write(S / '_Head.cshtml', '<base href="@Url.Content("~/")" />\n' + head)
write(S / '_MasterLayout.cshtml', '''<!DOCTYPE html>
<html lang="vi"><head>@Html.Partial("_Head")
@RenderSection("Head", required: false)
</head><body data-mvc-layout="customer">
@if (ViewBag.IsCatalog == true) { @Html.Partial("_CatalogHeader") } else { @Html.Partial("_CustomerHeader") }
@if (TempData["Notice"] != null) { <div class="container alert alert-success mt-3" role="status">@TempData["Notice"]</div> }
@RenderBody()
@Html.Partial("_Footer")
<script src="https://cdn.jsdelivr.net/npm/bootstrap&#64;5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/api.js"></script><script src="js/auth.js"></script>
@RenderSection("Scripts", required: false)
</body></html>''')
write(S / '_Layout.cshtml', '''<!DOCTYPE html>
<html lang="vi"><head>@Html.Partial("_Head")
@RenderSection("Head", required: false)
</head><body class="bg-light" data-mvc-layout="admin">
@if (ViewBag.AdminDashboard == true) { @Html.Partial("_AdminHeader") }
else {
<header class="bg-dark text-white p-3 d-flex justify-content-between"><a class="text-white fw-bold" href="admin.html">WEBBANSACH ADMIN</a><span>@Session["AdminName"]</span></header>
}
@if (Session["AdminUser"] != null) { @Html.Partial("_AdminNavigation") }
<div class="container-fluid px-4 mt-3">
@if (TempData["Notice"] != null) { <div class="alert alert-success" role="status">@TempData["Notice"]</div> }
@if (TempData["Error"] != null) { <div class="alert alert-danger" role="alert">@TempData["Error"]</div> }
</div>
@RenderBody()
<script src="https://cdn.jsdelivr.net/npm/bootstrap&#64;5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/api.js"></script>
@RenderSection("Scripts", required: false)
</body></html>''')

for page in ['index','admin','cart','checkout','tracking','book-details','login','register','verify-email']:
    html = (B / (page + '.html')).read_text(encoding='utf-8-sig')
    title = re.search(r'<title>(.*?)</title>', html, re.S).group(1)
    body = re.search(r'<body\b[^>]*>(.*?)</body>', html, re.S).group(1)
    scripts = re.findall(r'<script\b[^>]*>.*?</script>', body, re.S)
    inline = '\n'.join(s for s in scripts if not re.match(r'<script\s+src=', s))
    body = re.sub(r'<script\b[^>]*>.*?</script>', '', body, flags=re.S)
    if page == 'admin':
        body = re.sub(r'<nav\b.*?</nav>', '', body, count=1, flags=re.S)
    else:
        body = re.sub(r'<header\b.*?</header>', '', body, count=1, flags=re.S)
        body = re.sub(r'<footer\b.*?</footer>', '', body, count=1, flags=re.S)
    styles = '\n'.join(re.findall(r'<style\b[^>]*>.*?</style>', html, re.S))
    content = '@{ Layout = "~/Views/Shared/' + ('_Layout' if page == 'admin' else '_MasterLayout') + '.cshtml"; ViewBag.Title = "' + title.replace('"','\\"') + '"; }\n'
    if styles:
        content += '@section Head {\n' + literal(styles) + '\n}\n'
    content += literal(body) + '\n@section Scripts {\n' + literal(inline) + '\n}\n'
    write(P / (page + '.cshtml'), content)
print('Generated 9 Razor page views and shared layouts from HTML sources.')
