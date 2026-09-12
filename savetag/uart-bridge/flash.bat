@echo off
echo ========================================
echo   ESP32-C3 UART Bridge - Flash Tool
echo   Cuu the e-ink bi brick
echo ========================================
echo.
echo Huong dan noi day:
echo   GPIO21 (TX) → VRX the e-ink
echo   GPIO20 (RX) ← VTX the e-ink
echo   GND         → GND the e-ink
echo.
echo ⚠️  KHONG noi 5V/3.3V sang the e-ink
echo ⚠️  The e-ink PHAI co nguon (giu pin hoac cap 3.3V ngoai)
echo.
echo ========================================
echo Dang kiem tra COM port...
echo.

REM Tim COM port tu dong
for /f "tokens=1" %%a in ('mode ^| findstr "COM"') do (
    set COMPORT=%%a
    goto :found
)

echo Khong tim thay COM port nao!
echo Hay cam ESP32-C3 vao may tinh.
pause
exit /b 1

:found
echo Tim thay: %COMPORT%
echo.
echo Dang flash firmware...
echo.

pio run -t upload --environment esp32c3

if %errorlevel% neq 0 (
    echo.
    echo ❌ Flash that bai!
    echo Hay kiem tra:
    echo   1. ESP32-C3 da duoc cam vay chua?
    echo   2. Driver USB da cai chua?
    echo   3. Nhan nut BOOT tren ESP32-C3 khi dang flash
) else (
    echo.
    echo ✅ Flash thanh cong!
    echo.
    echo Buoc tiep theo:
    echo   1. Noi day: GPIO21→VRX, GPIO20←VTX, GND→GND
    echo   2. Mo Serial Monitor: pio device monitor
    echo   3. Giu M1 + nhan RST the e-ink de vao Bootloader
)

echo.
pause
