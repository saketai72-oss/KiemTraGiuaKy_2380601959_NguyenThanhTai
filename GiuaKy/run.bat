@echo off
chcp 65001 >nul
title TOEIC Reading - Khoi Dong He Thong

echo =====================================================================
echo       HE THONG THI TOEIC READING - KHOI DONG NHANH DU AN
echo       Sinh vien: Nguyen Thanh Tai - MSSV: 2380601959
echo =====================================================================
echo.

cd /d "%~dp0"

echo [1/3] Dang khoi dong MS SQL Server tren Docker...
docker compose up -d
if %errorlevel% neq 0 (
    echo [CANH BAO] Docker khong khoi dong duoc. Vui long bat Docker Desktop.
) else (
    echo [OK] SQL Server da san sang tren cong 1433.
)

echo.
echo [2/3] Dang khoi dong Backend ASP.NET Core Web MVC & API (Port 5000)...
start "TOEIC Backend (ASP.NET Core)" cmd /k "cd /d "%~dp0backend\src\Toeic2380601959.Web.Mvc" && dotnet run"

echo.
echo [3/3] Dang khoi dong Frontend Flutter App...
start "TOEIC Frontend (Flutter App)" cmd /k "cd /d "%~dp0frontend" && flutter run"

echo.
echo Dang mo Web Admin tren trinh duyet...
timeout /t 3 >nul
start http://localhost:5000

echo.
echo =====================================================================
echo [HOAN TAT] He thong da duoc khoi dong trong 2 cua so rieng biet!
echo.
echo   - Web Admin URL:    http://localhost:5000
echo   - Tai khoan Admin:  admin  /  123qwe
echo   - Mobile Flutter:   Dang chay trong cua so "TOEIC Frontend"
echo.
echo Bam phim bat ky de dong cua so nay...
echo =====================================================================
pause >nul
