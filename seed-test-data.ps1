# PowerShell script to seed/reseed test data into SQL Server container
Write-Host "=== Đang nạp dữ liệu kiểm thử vào SQL Server (BSDB2) ===" -ForegroundColor Cyan

docker exec -i webbansach-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "BookStore@123456" -C -i /dev/stdin < 02_DuLieuKiemThu.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "=== Nạp dữ liệu kiểm thử thành công! ===" -ForegroundColor Green
} else {
    Write-Host "=== Lỗi khi nạp dữ liệu kiểm thử! ===" -ForegroundColor Red
}
