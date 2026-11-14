param(
    [string]$ServerInstance = ".\SQLEXPRESS"
)

Write-Host "=== Nạp dữ liệu kiểm thử vào SQL Server cục bộ (BSDB2) ===" -ForegroundColor Cyan
Write-Host "Server: $ServerInstance | Database: BSDB2" -ForegroundColor Gray

if (Get-Command sqlcmd -ErrorAction SilentlyContinue) {
    sqlcmd -S $ServerInstance -d BSDB2 -E -i "02_DuLieuKiemThu.sql"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "=== Nạp dữ liệu kiểm thử thành công! ===" -ForegroundColor Green
    } else {
        Write-Host "=== Lỗi khi chạy script qua sqlcmd! Bạn có thể mở SSMS và chạy trực tiếp file 02_DuLieuKiemThu.sql ===" -ForegroundColor Red
    }
} else {
    Write-Host "[Gợi ý] Không tìm thấy lệnh sqlcmd trên PATH hệ thống." -ForegroundColor Yellow
    Write-Host "Bạn hãy mở SQL Server Management Studio (SSMS), mở file '02_DuLieuKiemThu.sql' và nhấn phím F5 (Execute) để nạp dữ liệu kiểm thử." -ForegroundColor Yellow
}
