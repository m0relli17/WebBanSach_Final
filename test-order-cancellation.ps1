param([string]$BaseUrl = 'http://localhost:54921')
$ErrorActionPreference = 'Stop'
$connection = [System.Data.SqlClient.SqlConnection]::new('Data Source=.\SQLEXPRESS;Initial Catalog=BSDB2;Integrated Security=True')
$connection.Open()
function QueryScalar($sql) {
    $command = $connection.CreateCommand()
    $command.CommandText = $sql
    try { return $command.ExecuteScalar() } finally { $command.Dispose() }
}
$bookId = $null
$orderId = $null
$customerId = $null
$checkoutId = $null
try {
    $bookId = [int](QueryScalar @'
INSERT dbo.Sach (MaLoai, MaNXB, MaTG, TenSach, GiaBan, SoLuongTon, GiamGia)
SELECT TOP (1) MaLoai, MaNXB, MaTG, N'Cancellation API test fixture', 100, 7, 0 FROM dbo.Sach;
SELECT CAST(SCOPE_IDENTITY() AS int);
'@)
    $orderId = [int](QueryScalar @'
INSERT dbo.DonDatHang (MaKH, NgayDat, NgayGiao, TinhTrang, Tracking, ThanhToan)
SELECT TOP (1) MaKH, GETDATE(), GETDATE(), 0, 0, 0 FROM dbo.KhachHang;
SELECT CAST(SCOPE_IDENTITY() AS int);
'@)
    $null = QueryScalar "INSERT dbo.ChiTietDDH (MaDDH, MaSach, SoLuong, DonGia) VALUES ($orderId, $bookId, 3, 100);"
    $login = Invoke-RestMethod "$BaseUrl/api/AdminLogin" -Method Post -Body @{username='admin';password='123456'} -SessionVariable testSession
    if (!$login.status) { throw 'Admin login failed' }
    $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateOrderStatus" -Method Post -WebSession $testSession -Body @{id=$orderId;status=4}
    if ($result.status) { throw 'Cancellation without reason was accepted' }
    $null = QueryScalar "UPDATE dbo.ChiTietDDH SET SoLuong=0 WHERE MaDDH=$orderId;"
    $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateOrderStatus" -Method Post -WebSession $testSession -Body @{id=$orderId;status=4;reason='Invalid quantity rollback test'}
    if ($result.status -or (QueryScalar "SELECT Tracking FROM dbo.DonDatHang WHERE MaDDH=$orderId") -ne 0 -or (QueryScalar "SELECT COUNT(*) FROM dbo.OrderHistory WHERE OrderId=$orderId") -ne 0 -or (QueryScalar "SELECT COUNT(*) FROM dbo.StockHistory WHERE BookId=$bookId") -ne 0) { throw 'Failed cancellation changed data or created audit records' }
    $null = QueryScalar "UPDATE dbo.ChiTietDDH SET SoLuong=3 WHERE MaDDH=$orderId;"
    Write-Output 'PASS: invalid cancellation rolls back and creates no history'
    foreach ($status in @(1, 4, 4)) {
        $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateOrderStatus" -Method Post -WebSession $testSession -Body @{id=$orderId;status=$status;reason='Integration test cancellation'}
        if (!$result.status) { throw "Status $status failed: $($result.message)" }
        $stock = QueryScalar "SELECT SoLuongTon FROM dbo.Sach WHERE MaSach=$bookId"
        $expected = if ($status -eq 1) { 7 } else { 10 }
        if ($stock -ne $expected) { throw "Expected stock $expected, got $stock" }
        Write-Output "PASS: status=$status, stock=$stock"
    }
    $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateOrderStatus" -Method Post -WebSession $testSession -Body @{id=$orderId;status=0}
    if ($result.status) { throw 'Cancelled order was reopened' }
    if ((QueryScalar "SELECT SoLuongTon FROM dbo.Sach WHERE MaSach=$bookId") -ne 10) { throw 'Stock changed after rejected transition' }
    Write-Output 'PASS: reopening cancelled order rejected; stock unchanged'
    $history = Invoke-RestMethod "$BaseUrl/api/AdminStockHistory?id=$bookId" -WebSession $testSession
    if ($history.totalItems -ne 1 -or $history.data[0].before -ne 7 -or $history.data[0].after -ne 10 -or $history.data[0].orderId -ne $orderId -or $history.data[0].actor -ne 'Admin: admin') { throw 'Stock history mismatch' }
    $history = Invoke-RestMethod "$BaseUrl/api/AdminOrderHistory?id=$orderId" -WebSession $testSession
    if ($history.totalItems -ne 2 -or $history.data[0].reason -ne 'Integration test cancellation') { throw 'Order history mismatch or duplicate cancellation log' }
    Write-Output 'PASS: audit records match actual changes; repeated cancellation adds no history'
    $details = (Invoke-RestMethod "$BaseUrl/api/AdminBookDetails?id=$bookId" -WebSession $testSession).data
    $token = (Invoke-RestMethod "$BaseUrl/api/AdminSession" -WebSession $testSession).token
    $body = @{bookId=$bookId;title=$details.title;price=$details.originalPrice;discountPercent=$details.discountPercent;categoryId=$details.categoryId;authorName=$details.author;publisherId=$details.publisherId;stock=15;stockReason='Test restock';translator='';description=''}
    $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateBook" -Method Post -WebSession $testSession -Headers @{'X-Admin-Token'=$token} -Body $body
    if (!$result.status) { throw "Stock adjustment failed: $($result.message)" }
    $history = Invoke-RestMethod "$BaseUrl/api/AdminStockHistory?id=$bookId" -WebSession $testSession
    if ($history.totalItems -ne 2 -or $history.data[0].before -ne 10 -or $history.data[0].after -ne 15 -or $history.data[0].reason -ne 'Test restock') { throw 'Manual adjustment audit mismatch' }
    $body.stock = 20; $body.stockReason = ''
    $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateBook" -Method Post -WebSession $testSession -Headers @{'X-Admin-Token'=$token} -Body $body
    if ($result.status -or (QueryScalar "SELECT SoLuongTon FROM dbo.Sach WHERE MaSach=$bookId") -ne 15) { throw 'Adjustment without reason was not rejected' }
    Write-Output 'PASS: manual restock logged; missing reason rejected without changing stock'
    $history = Invoke-RestMethod "$BaseUrl/api/AdminStockHistory?id=$bookId&page=999" -WebSession $testSession
    if ($history.page -ne 1 -or $history.totalItems -ne 2) { throw 'History pagination bounds incorrect' }
    try {
        $null = Invoke-RestMethod "$BaseUrl/api/AdminOrderHistory?id=$orderId"
        throw 'Unauthenticated history access was allowed'
    } catch {
        if ([int]$_.Exception.Response.StatusCode -ne 401) { throw }
    }
    Write-Output 'PASS: pagination bounds and admin authentication enforced'
    $username = 'audit_test_' + [Guid]::NewGuid().ToString('N')
    $customerId = [int](QueryScalar "INSERT dbo.KhachHang(TenKH,Email,DiaChi,DienThoai,TaiKhoan,MatKhau,TrangThai,EmailVerified) VALUES(N'Audit test','audit@example.invalid',N'Test address','0900000000','$username','AuditTest123',1,1); SELECT CAST(SCOPE_IDENTITY() AS int);")
    $login = Invoke-RestMethod "$BaseUrl/api/Login" -Method Post -Body @{username=$username;password='AuditTest123'} -SessionVariable customerSession
    if (!$login.status) { throw 'Test customer login failed' }
    $result = Invoke-RestMethod "$BaseUrl/api/AddToCart" -Method Post -WebSession $customerSession -Body @{id=$bookId;quantity=2}
    if (!$result.status) { throw 'Test add to cart failed' }
    $result = Invoke-RestMethod "$BaseUrl/api/Checkout" -Method Post -WebSession $customerSession -Body @{receiverName='Audit test';receiverPhone='0900000000';receiverAddress='Test address';paymentMethod='cod';note='Audit integration test'}
    if (!$result.status) { throw "Checkout failed: $($result.message)" }
    $checkoutId = [int]$result.orderId
    if ($result.subtotal -ne 200 -or $result.shippingFee -ne 25000 -or $result.total -ne 25200) { throw 'Checkout shipping fee mismatch' }
    if ((QueryScalar "SELECT ShippingFee FROM dbo.DonDatHang WHERE MaDDH=$checkoutId") -ne 25000) { throw 'Shipping fee was not saved' }
    $history = Invoke-RestMethod "$BaseUrl/api/AdminStockHistory?id=$bookId" -WebSession $testSession
    if ($history.data[0].before -ne 15 -or $history.data[0].after -ne 13 -or $history.data[0].orderId -ne $checkoutId -or $history.data[0].actor -ne "Khách: $username") { throw 'Checkout stock history mismatch' }
    $history = Invoke-RestMethod "$BaseUrl/api/AdminOrderHistory?id=$checkoutId" -WebSession $testSession
    if ($history.totalItems -ne 1) { throw 'Missing order creation audit' }
    $result = Invoke-RestMethod "$BaseUrl/api/CancelOrder" -Method Post -WebSession $customerSession -Body @{id=$checkoutId;reason='Customer integration test'}
    if (!$result.status -or (QueryScalar "SELECT SoLuongTon FROM dbo.Sach WHERE MaSach=$bookId") -ne 15) { throw 'Customer cancellation failed' }
    $history = Invoke-RestMethod "$BaseUrl/api/AdminOrderHistory?id=$checkoutId" -WebSession $testSession
    if ($history.totalItems -ne 2 -or $history.data[0].reason -ne 'Customer integration test') { throw 'Customer cancellation history mismatch' }
    Write-Output 'PASS: checkout and customer cancellation audit both stock and order atomically'
} finally {
    if ($checkoutId) { $null = QueryScalar "DELETE dbo.OrderHistory WHERE OrderId=$checkoutId; DELETE dbo.ChiTietDDH WHERE MaDDH=$checkoutId; DELETE dbo.DonDatHang WHERE MaDDH=$checkoutId;" }
    if ($orderId) { $null = QueryScalar "DELETE dbo.OrderHistory WHERE OrderId=$orderId;" }
    if ($bookId) { $null = QueryScalar "DELETE dbo.StockHistory WHERE BookId=$bookId;" }
    if ($orderId) { $null = QueryScalar "DELETE dbo.ChiTietDDH WHERE MaDDH=$orderId; DELETE dbo.DonDatHang WHERE MaDDH=$orderId;" }
    if ($bookId) { $null = QueryScalar "DELETE dbo.Sach WHERE MaSach=$bookId;" }
    if ($customerId) { $null = QueryScalar "DELETE dbo.KhachHang WHERE MaKH=$customerId;" }
    $connection.Dispose()
}
