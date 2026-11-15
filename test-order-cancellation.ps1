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
    foreach ($status in @(1, 4, 4)) {
        $result = Invoke-RestMethod "$BaseUrl/api/AdminUpdateOrderStatus" -Method Post -WebSession $testSession -Body @{id=$orderId;status=$status}
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
} finally {
    if ($orderId) { $null = QueryScalar "DELETE dbo.ChiTietDDH WHERE MaDDH=$orderId; DELETE dbo.DonDatHang WHERE MaDDH=$orderId;" }
    if ($bookId) { $null = QueryScalar "DELETE dbo.Sach WHERE MaSach=$bookId;" }
    $connection.Dispose()
}
