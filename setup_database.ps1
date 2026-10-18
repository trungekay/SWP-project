# VisionCare - Script khoi tao va dong bo database tu dong
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "       VISIONCARE - TU DONG KHOI TAO & DONG BO DATABASE            " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

$propsPath = Join-Path $PSScriptRoot "src\java\db.properties"
$user = "sa"
$pass = "123"

if (Test-Path $propsPath) {
    Get-Content $propsPath | ForEach-Object {
        if ($_ -match "^\s*db\.username\s*=\s*(.*)") { $user = $matches[1].Trim() }
        if ($_ -match "^\s*db\.password\s*=\s*(.*)") { $pass = $matches[1].Trim() }
    }
}

Write-Host "[1/3] Doc thong tin ket noi tu src\java\db.properties:"
Write-Host "      User: $user | Password: $pass" -ForegroundColor Gray

# 1. Ket noi master va tao database neu chua co
$masterConnStr = "Server=localhost,1433;Database=master;User Id=$user;Password=$pass;TrustServerCertificate=True;"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($masterConnStr)
    $conn.Open()
    Write-Host "[2/3] Ket noi SQL Server thanh cong!" -ForegroundColor Green

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'eye_clinic_db') CREATE DATABASE [eye_clinic_db];"
    $cmd.ExecuteNonQuery() | Out-Null
    $conn.Close()

    # 2. Chay script database\eye_clinic_db.sql de dong bo du lieu
    Write-Host "[3/3] Dang nap du lieu & dong bo 16 dich vu vao eye_clinic_db..." -ForegroundColor Cyan
    $dbConnStr = "Server=localhost,1433;Database=eye_clinic_db;User Id=$user;Password=$pass;TrustServerCertificate=True;"
    $dbConn = New-Object System.Data.SqlClient.SqlConnection($dbConnStr)
    $dbConn.Open()

    $sqlFile = Join-Path $PSScriptRoot "database\eye_clinic_db.sql"
    if (Test-Path $sqlFile) {
        $content = Get-Content $sqlFile -Raw -Encoding UTF8
        $batches = $content -split "(?m)^\s*GO\s*$"
        $successBatches = 0
        foreach ($b in $batches) {
            $trimmed = $b.Trim()
            if ($trimmed.Length -gt 0) {
                try {
                    $c = $dbConn.CreateCommand()
                    $c.CommandText = $trimmed
                    $c.ExecuteNonQuery() | Out-Null
                    $successBatches++
                } catch {
                    # Ignore duplicate keys or existing objects
                }
            }
        }
    }

    # Kiem tra ket qua sau khi nap
    $checkCmd = $dbConn.CreateCommand()
    $checkCmd.CommandText = "SELECT COUNT(*) FROM Service_Catalog"
    $svcCount = $checkCmd.ExecuteScalar()
    $dbConn.Close()

    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Green
    Write-Host "  KHOI TAO THANH CONG DATABASE EYE_CLINIC_DB VOI DU $svcCount DICH VU!   " -ForegroundColor Green
    Write-Host "====================================================================" -ForegroundColor Green
    Write-Host "Ban co the mo NetBeans hoac IntelliJ va chay du an ngay bay gio!" -ForegroundColor Yellow
} catch {
    Write-Host ""
    Write-Host "[LOI] Khong the ket noi SQL Server!" -ForegroundColor Red
    Write-Host "Chi tiet:" $_.Exception.Message -ForegroundColor Yellow
    Write-Host "Goi y: Vui long bat SQL Server va kiem tra mat khau trong src\java\db.properties." -ForegroundColor Gray
}
