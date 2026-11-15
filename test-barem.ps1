param([string]$BaseUrl = 'http://localhost:54921')
$ErrorActionPreference = 'Stop'
$connection = [System.Data.SqlClient.SqlConnection]::new('Data Source=.\SQLEXPRESS;Initial Catalog=BSDB2;Integrated Security=True')
$connection.Open()
function Scalar($sql) { $cmd=$connection.CreateCommand(); $cmd.CommandText=$sql; try { $cmd.ExecuteScalar() } finally { $cmd.Dispose() } }
function Assert($condition, $message) { if (!$condition) { throw $message } }
function GetPage($path, $session) { Invoke-WebRequest "$BaseUrl/$path" -UseBasicParsing -WebSession $session -Headers @{'Accept-Encoding'='gzip, deflate, br'} -TimeoutSec 30 }
function Submit($path, $body, $session, $formPath) {
    $page=GetPage $formPath $session
    $match=[regex]::Match($page.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
    Assert $match.Success "Missing anti-forgery token: $formPath"
    $body['__RequestVerificationToken']=[System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
    Invoke-WebRequest "$BaseUrl/$path" -Method Post -Body $body -WebSession $session -UseBasicParsing -TimeoutSec 30
}
$tag='BaremTest_'+[Guid]::NewGuid().ToString('N').Substring(0,10)
$category=0; $author=0; $publisher=0; $book=0; $customer=0; $order=0; $adminId=0
try {
    $login=Invoke-RestMethod "$BaseUrl/api/AdminLogin" -Method Post -Body @{username='admin';password='123456'} -SessionVariable adminSession
    Assert $login.status 'Admin login failed'
    foreach($path in @('index.html','admin.html','cart.html','checkout.html','tracking.html','book-details.html','login.html','register.html','verify-email.html','Manage/Catalog','Manage/CatalogEdit?kind=category','Manage/CatalogEdit?kind=author','Manage/CatalogEdit?kind=publisher','Manage/Inventory','Manage/Inventory?tab=restock','Manage/Admins','Manage/AdminEdit','Manage/Customers')) {
        $page=GetPage $path $adminSession
        Assert ($page.Content.Contains('data-mvc-layout=')) "Not rendered with MVC layout: $path"
    }
    Assert ((GetPage 'css/style.css' $adminSession).StatusCode -eq 200) 'Static CSS broken'
    Write-Output 'PASS: all MVC page layouts, forms and static assets render'
    $null=Submit 'Manage/CatalogEdit' @{Id=0;Kind='category';Name=$tag} $adminSession 'Manage/CatalogEdit?kind=category'
    $category=[int](Scalar "SELECT MaLoai FROM dbo.TheLoai WHERE TenLoai='$tag'")
    Assert ($category -gt 0) 'Category creation failed'
    $null=Submit 'Manage/CatalogEdit' @{Id=0;Kind='category';Name=$tag} $adminSession 'Manage/CatalogEdit?kind=category'
    Assert ((Scalar "SELECT COUNT(*) FROM dbo.TheLoai WHERE TenLoai='$tag'") -eq 1) 'Duplicate category was accepted'
    $null=Submit 'Manage/CatalogEdit' @{Id=0;Kind='category';Name=($tag + ('x' * 60))} $adminSession 'Manage/CatalogEdit?kind=category'
    Assert ((Scalar "SELECT COUNT(*) FROM dbo.TheLoai WHERE TenLoai LIKE '$tag%'") -eq 1) 'Over-length category was accepted'
    $null=Submit 'Manage/CatalogEdit' @{Id=$category;Kind='category';Name=($tag+'_edited')} $adminSession "Manage/CatalogEdit?kind=category&id=$category"
    Assert ((Scalar "SELECT TenLoai FROM dbo.TheLoai WHERE MaLoai=$category") -eq ($tag+'_edited')) 'Category edit failed'
    $null=Submit 'Manage/CatalogEdit' @{Id=0;Kind='author';Name=$tag;Address='Test hometown';Biography='Test biography';BirthDate='1828-01-01'} $adminSession 'Manage/CatalogEdit?kind=author'
    $author=[int](Scalar "SELECT MaTG FROM dbo.TacGia WHERE TenTG='$tag'")
    $null=Submit 'Manage/CatalogEdit' @{Id=0;Kind='publisher';Name=$tag;Address='Test publisher';Phone='0900000000'} $adminSession 'Manage/CatalogEdit?kind=publisher'
    $publisher=[int](Scalar "SELECT MaNXB FROM dbo.NhaXuatBan WHERE TenNXB='$tag'")
    Assert ($author -gt 0 -and $publisher -gt 0) 'Author or publisher creation failed'
    $book=[int](Scalar "INSERT dbo.Sach(MaLoai,MaTG,MaNXB,TenSach,GiaBan,SoLuongTon,GiamGia) VALUES($category,$author,$publisher,'$tag',90000,0,0); SELECT CAST(SCOPE_IDENTITY() AS int);")
    foreach ($entry in @(@{kind='category';id=$category},@{kind='author';id=$author},@{kind='publisher';id=$publisher})) {
        $null=Submit 'Manage/CatalogDelete' $entry $adminSession 'Manage/Catalog'
    }
    Assert ((Scalar "SELECT COUNT(*) FROM dbo.TheLoai WHERE MaLoai=$category") -eq 1 -and (Scalar "SELECT COUNT(*) FROM dbo.TacGia WHERE MaTG=$author") -eq 1 -and (Scalar "SELECT COUNT(*) FROM dbo.NhaXuatBan WHERE MaNXB=$publisher") -eq 1) 'A used catalogue entry was deleted'
    $page=GetPage "Manage/CatalogDetails?kind=author&id=$author" $adminSession
    Assert ($page.Content.Contains($tag) -and $page.Content.Contains('Test biography')) 'Author detail/product list missing'
    $page=GetPage 'Manage/Inventory?tab=restock' $adminSession
    Assert ($page.Content.Contains($tag)) 'Zero stock missing from restock list'
    $books=Invoke-RestMethod "$BaseUrl/api/Books?search=$tag"
    Assert ($books.totalItems -eq 0) 'Out-of-stock book exposed in customer catalogue'
    $null=Scalar "UPDATE dbo.Sach SET SoLuongTon=10 WHERE MaSach=$book"
    $books=Invoke-RestMethod "$BaseUrl/api/Books?search=$tag"
    Assert ($books.totalItems -eq 1) 'In-stock book missing from catalogue'
    $page=GetPage 'Manage/Inventory?tab=available' $adminSession
    Assert ($page.Content.Contains($tag)) 'In-stock book missing from inventory'
    Write-Output 'PASS: catalogue create/edit, related products, delete constraints, inventory and stock filtering'
    $null=Submit 'Manage/AdminEdit' @{Id=0;Username=$tag;FullName='Test administrator';Password='BaremTest123';Active='true'} $adminSession 'Manage/AdminEdit'
    $adminId=[int](Scalar "SELECT IDAdmin FROM dbo.Admin WHERE TaiKhoan='$tag'")
    Assert ($adminId -gt 0) 'Admin creation failed'
    $login=Invoke-RestMethod "$BaseUrl/api/AdminLogin" -Method Post -Body @{username=$tag;password='BaremTest123'} -SessionVariable secondaryAdmin
    Assert $login.status 'Hashed admin login failed'
    $null=Submit 'Manage/AdminEdit' @{Id=$adminId;Username=$tag;FullName='Test administrator edited';Active='false'} $adminSession "Manage/AdminEdit?id=$adminId"
    try { $null=Invoke-RestMethod "$BaseUrl/api/AdminBooks" -WebSession $secondaryAdmin; throw 'Disabled admin kept access' } catch { Assert ([int]$_.Exception.Response.StatusCode -eq 401) 'Disabled admin was not rejected' }
    $null=Submit 'Manage/AdminDelete' @{id=$adminId} $adminSession 'Manage/Admins'
    Assert ((Scalar "SELECT COUNT(*) FROM dbo.Admin WHERE IDAdmin=$adminId") -eq 0) 'Admin deletion failed'
    Write-Output 'PASS: admin create/edit/delete, hashed passwords and disabled-session rejection'
    $customer=[int](Scalar "INSERT dbo.KhachHang(TenKH,Email,DiaChi,DienThoai,TaiKhoan,MatKhau,TrangThai,EmailVerified) VALUES('Original receiver','barem@example.invalid','Original address','0900000000','$tag','BaremTest123',1,1); SELECT CAST(SCOPE_IDENTITY() AS int);")
    $login=Invoke-RestMethod "$BaseUrl/api/Login" -Method Post -Body @{username=$tag;password='BaremTest123'} -SessionVariable customerSession
    Assert $login.status 'Customer fixture login failed'
    $null=Invoke-RestMethod "$BaseUrl/api/AddToCart" -Method Post -WebSession $customerSession -Body @{id=$book;quantity=2}
    $result=Invoke-RestMethod "$BaseUrl/api/Checkout" -Method Post -WebSession $customerSession -Body @{receiverName='Original receiver';receiverPhone='0900000000';receiverAddress='Original address';paymentMethod='cod';note='Barem test'}
    Assert $result.status 'Checkout failed'
    $order=[int]$result.orderId
    Assert ($result.subtotal -eq 180000 -and $result.shippingFee -eq 0 -and $result.total -eq 180000) 'Free-shipping total incorrect'
    $null=Submit 'Portal/Profile' @{Name='Edited profile';Phone='0911111111';Address='Edited address';BirthDate='1998-01-01'} $customerSession 'Portal/Profile'
    Assert ((Scalar "SELECT TenKH FROM dbo.KhachHang WHERE MaKH=$customer") -eq 'Edited profile') 'Profile save failed'
    $invoice=GetPage "Portal/Invoice?id=$order" $customerSession
    Assert ($invoice.Content.Contains('data-partial="invoice"') -and $invoice.Content.Contains('Original receiver') -and !$invoice.Content.Contains('Edited address')) 'Invoice recipient snapshot changed with profile'
    $adminInvoice=GetPage "Portal/Invoice?id=$order" $adminSession
    Assert ($adminInvoice.Content -eq $invoice.Content) 'Admin/customer invoices do not use identical partial'
    $receipt=GetPage "Portal/Receipt?id=$order" $customerSession
    Assert ($receipt.Content.Contains('data-mvc-layout="customer"')) 'Receipt layout failed'
    $detail=GetPage "Manage/Customer?id=$customer" $adminSession
    Assert ($detail.Content.Contains("Receipt/$order") -or $detail.Content.Contains("Receipt?id=$order")) 'Customer order list missing invoice link'
    $product=GetPage "Portal/ProductDetails?id=$book" $customerSession
    $adminProduct=GetPage "Portal/ProductDetails?id=$book&admin=true" $adminSession
    Assert ($product.Content.Contains('data-partial="product-details"') -and $product.Content.Contains('qtyInput') -and !$adminProduct.Content.Contains('qtyInput')) 'Shared product detail purchase visibility incorrect'
    $customerOrders=Invoke-RestMethod "$BaseUrl/api/MyOrders" -WebSession $customerSession
    Assert ($customerOrders.data.Count -eq 1 -and $customerOrders.data[0].id -eq $order) 'Customer history includes other customers orders'
    try { $null=Invoke-WebRequest "$BaseUrl/Portal/Invoice?id=$order" -UseBasicParsing; throw 'Anonymous invoice exposed' } catch { Assert ([int]$_.Exception.Response.StatusCode -eq 403) 'Invoice authentication failed' }
    Write-Output 'PASS: checkout/free shipping, profile, recipient snapshots, shared invoices, shared product detail and order ownership'
    $null=Scalar "DELETE dbo.OrderHistory WHERE OrderId=$order; DELETE dbo.ChiTietDDH WHERE MaDDH=$order; DELETE dbo.DonDatHang WHERE MaDDH=$order; DELETE dbo.StockHistory WHERE BookId=$book; DELETE dbo.Sach WHERE MaSach=$book;"
    foreach ($entry in @(@{kind='category';id=$category},@{kind='author';id=$author},@{kind='publisher';id=$publisher})) {
        $null=Submit 'Manage/CatalogDelete' $entry $adminSession 'Manage/Catalog'
    }
    Assert ((Scalar "SELECT COUNT(*) FROM dbo.TheLoai WHERE MaLoai=$category") -eq 0 -and (Scalar "SELECT COUNT(*) FROM dbo.TacGia WHERE MaTG=$author") -eq 0 -and (Scalar "SELECT COUNT(*) FROM dbo.NhaXuatBan WHERE MaNXB=$publisher") -eq 0) 'Unused catalogue deletion failed'
    Write-Output 'PASS: duplicate/over-length validation and deletion of unused catalogue entries'
} finally {
    if ($order) { $null=Scalar "DELETE dbo.OrderHistory WHERE OrderId=$order; DELETE dbo.ChiTietDDH WHERE MaDDH=$order; DELETE dbo.DonDatHang WHERE MaDDH=$order;" }
    if ($book) { $null=Scalar "DELETE dbo.StockHistory WHERE BookId=$book; DELETE dbo.Sach WHERE MaSach=$book;" }
    if ($customer) { $null=Scalar "DELETE dbo.KhachHang WHERE MaKH=$customer;" }
    if ($adminId) { $null=Scalar "DELETE dbo.Admin WHERE IDAdmin=$adminId;" }
    if ($category) { $null=Scalar "DELETE dbo.TheLoai WHERE MaLoai=$category;" }
    if ($author) { $null=Scalar "DELETE dbo.TacGia WHERE MaTG=$author;" }
    if ($publisher) { $null=Scalar "DELETE dbo.NhaXuatBan WHERE MaNXB=$publisher;" }
    $connection.Dispose()
}
