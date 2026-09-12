# ESP32-C3 UART Bridge

Cuua the e-ink bi brick thong qua UART Bridge bang ESP32-C3 Super Mini.

## Noi day

```
ESP32-C3 Super Mini          The e-ink
───────────────────          ──────────
GPIO21 (TX)  ─────────────→  VRX
GPIO20 (RX)  ←─────────────  VTX
GND          ─────────────→  GND
```

⚠️ KHONG noi 5V/3.3V sang the e-ink
⚠️ The e-ink PHAI co nguon (giu pin hoac cap 3.3V ngoai + noi chung GND)

## Cau hinh chan ESP32-C3 Super Mini

```
Hang 1 (tren):                Hang 2 (duoi):
┌──────────────────┐          ┌──────────────────┐
│ 5V   — Nguon 5V │          │ 5  (GPIO5)  SCL  │
│ G    — GND       │          │ 6  (GPIO6)  SPI  │
│ 3.3  — Nguon 3.3V│         │ 7  (GPIO7)  SPI  │
│ 4    — GPIO4 SDA │          │ 8  (GPIO8)  Strapping │
│ 3    — GPIO3 ADC │          │ 9  (GPIO9)  BOOT │
│ 2    — GPIO2 ADC │          │ 10 (GPIO10) PWM  │
│ 1    — GPIO1 ADC │          │ 20 (GPIO20) RX ← │
│ 0    — GPIO0 ADC │          │ 21 (GPIO21) TX → │
└──────────────────┘          └──────────────────┘
```

## Su dung

### Flash tu dong
1. Cam ESP32-C3 vao may tinh
2. Chay file `flash.bat`
3. Doan theo huong dan tren man hinh

### Flash thu cong
```bash
# Compile
pio run

# Flash
pio run -t upload

# Mo Serial Monitor
pio device monitor
```

### Flash firmware cho the e-ink
1. Noi day UART (GPIO21→VRX, GPIO20←VTX, GND→GND)
2. Mo Serial Monitor (115200 baud)
3. Giu M1 (hoac M2) xuong GND → nhan nhap RST → tha M1/M2
4. Dung ESP Flash Download Tool hoac STM32CubeProgrammer de flash firmware

## Cau hinh Arduino IDE (neu dung Arduino thay PlatformIO)

⚠️ BAT BUOC: Tools → USB CDC On Boot: Enabled
- Neu khong bat → Serial va Serial1 se xung dot GPIO20/21

## Files

- `platformio.ini` - Cau hinh PlatformIO
- `src/main.cpp` - Ma nguon UART Bridge
- `flash.bat` - Script flash tu dong
