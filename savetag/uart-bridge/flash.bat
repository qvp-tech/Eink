@echo off
set PIO=C:\Users\Admin\AppData\Roaming\Python\Python314\Scripts\pio.exe

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
echo Dang flash firmware...
echo.

%PIO% run -t upload --environment esp32c3

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
)

echo.
pause
