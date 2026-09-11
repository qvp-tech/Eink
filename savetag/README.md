# Hướng dẫn cứu thẻ E-Ink bị Brick

## Nguyên nhân bị brick

Thẻ e-ink bị brick khi update firmware sai thiết bị hoặc ngắt nguồn giữa chừng.
Code web đã được sửa để **không cho update firmware trên thiết bị không phải ONE-2.13L**.

---

## Thông tin thẻ E-Ink

| Thông tin | Giá trị |
|---|---|
| Tên thiết bị | Alibaba Group 20190605 1044 |
| Tên BLE | DLG-CLOCK-xxxx |
| Loại màn hình | E-Ink 2.13 inch |
| Chip | ARM Cortex-M (có SWD) |

### Cấu hình chân trên mạch

```
┌─────────────────────────────────────┐
│                                     │
│  RST  GND  VRX  VTX  VBAT          │  ← Hàng trên
│                                     │
│         SWDIO    SWCLK              │  ← Giữa mạch
│                                     │
│          M1         M2              │  ← Hàng dưới
│                                     │
└─────────────────────────────────────┘
```

| Chân | Chức năng | Ghi chú |
|---|---|---|
| RST | Reset | Giữ LOW để reset |
| GND | Mass / Đất | Nối chung GND |
| VRX | UART Receive | Nối TX từ programmer |
| VTX | UART Transmit | Nối RX từ programmer |
| VBAT | Nguồn pin | Cấp nguồn 3.3V |
| SWDIO | SWD Data | Debug ARM |
| SWDIO | SWD Clock | Debug ARM |
| M1 | Mode 1 / Test point | Có thể dùng boot mode |
| M2 | Mode 2 / Test point | Có thể dùng boot mode |

---

## Bluetooth Services (sau khi restore)

| Service UUID | Tên | Characteristic UUID | Vai trò |
|---|---|---|---|
| `0000ff00-...` | ONE Service | `0000ff01-...` | longValue (đọc/ghi) |
| | | `0000ff02-...` | ADC (đọc điện áp) |
| | | `0000ff03-...` | Control Point |
| `00001f10-...` | RXTX Service | `00001f1f-...` | GHI lệnh |
| `13187b10-...` | EPD Service | `4b646063-...` | ĐỌC/NHẬN dữ liệu |

---

## Phương pháp cứu thiết bị

### Phương pháp 1: UART Bootloader (Dễ nhất)

#### Cần mua (giá rẻ):
- **USB to TTL CP2102** hoặc **CH340G** → ~25k-50k
- Hoặc **CH341A** → ~30k-50k (nếu đã có)
- Hoặc **ESP32-C3** (dùng làm UART bridge)

#### Nối dây (USB-TTL):
```
USB-TTL (CP2102/CH340)    Thẻ e-ink
─────────────────────     ──────────
TX      ────────────────  VRX
RX      ←───────────────  VTX
GND     ────────────────  GND
                          (KHÔNG nối VCC/5V/3.3V)
```

#### Thực hiện:
1. Ngắt toàn bộ nguồn thẻ e-ink (tháo pin/battery)
2. Nối dây UART (TX→VRX, RX→VTX, GND→GND)
3. Mở Serial Monitor (115200 baud)
4. **Giữ RST xuống GND** (hoặc giữ M1)
5. Cắm nguồn lại
6. Thả RST/M1
7. Xem Serial Monitor có output không

#### Flash firmware:
Nếu có output → chip còn sống → dùng phần mềm flash:
- **ESP Flash Download Tool** (nếu chip ESP32): https://www.espressif.com/en/support/download/other-tools
- **STM32CubeProgrammer** (nếu chip STM32): https://www.st.com/en/development-tools/stm32cubeprog.html
- **nRF Connect Programmer** (nếu chip nRF52): https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-Desktop

---

### Phương pháp 2: SWD (Chuyên nghiệp, chắc chắn thành công)

#### Cần mua:
- **ST-Link V2** → ~40k-70k trên Shopee

#### Nối dây:
```
ST-Link V2            Thẻ e-ink
─────────────         ──────────
SWDIO  ────────────   SWDIO
SWCLK  ────────────   SWCLK
GND    ────────────   GND
3.3V   ────────────   VBAT (hoặc cấp riêng)
```

#### Thực hiện:
1. Cài **STM32CubeProgrammer**
2. Mở phần mềm → chọn **SWD** → bấm **Connect**
3. Nếu connect thành công → chip còn sống
4. **Erase chip** → Flash lại firmware `.bin`
5. Bấm **Start** để flash

---

### Phương pháp 3: Dùng ESP32-C3 làm UART Bridge

#### Ưu điểm:
- Không cần mua thêm thiết bị (nếu đã có ESP32-C3)
- Tự làm UART bridge bằng code

#### Nối dây:
```
ESP32-C3 Super Mini          Thẻ e-ink
───────────────────          ──────────
GPIO21 (TX)  ─────────────→  VRX
GPIO20 (RX)  ←─────────────  VTX
GND          ─────────────→  GND
```

⚠️ **Quan trọng:**
- **KHÔNG** nối 5V hay 3.3V từ ESP32-C3 sang thẻ e-ink
- Thẻ e-ink **PHẢI có nguồn** (giữ nguyên pin hoặc cấp 3.3V ngoài + nối chung GND)
- Nếu tháo pin thẻ e-ink mà chỉ nối TX/RX/GND → thẻ mất điện hoàn toàn → không hoạt động

#### Bước 1: Cài Arduino IDE
1. Tải: https://www.arduino.cc/en/software
2. Mở IDE → **File → Preferences**
3. Ở **Additional Board Manager URLs**, paste:
```
https://espressif.github.io/arduino-esp32/package_esp32_index.json
```
4. **Tools → Board → Board Manager** → tìm **esp32** → cài **esp32 by Espressif**

#### Bước 2: Cấu hình Arduino IDE (QUAN TRỌNG)

**Tools → USB CDC On Boot: Enabled**

> Phải bật tùy chọn này để `Serial` (USB) không bị trùng GPIO20/21 với `Serial1`.
> Nếu không bật → Serial và Serial1 dùng chung UART0 → xung đột, dữ liệu bị trộn.

Các tùy chọn khác:
- **Board**: ESP32C3 Dev Module
- **Upload Speed**: 921600
- **Flash Mode**: DIO

#### Bước 3: Nạp sketch UART Bridge

```cpp
// UART Bridge - ESP32-C3 Super Mini
// Nối GPIO20/21 → VRX/VTX thẻ e-ink

#define RX_PIN 20  // GPIO20 RX
#define TX_PIN 21  // GPIO21 TX
#define LED_PIN 8  // GPIO8 = LED onboard (Active LOW)
#define BAUD  115200

void setup() {
  Serial.begin(BAUD);       // USB CDC (máy tính)

  // Dùng setPins() trước begin() để tương thích cả core ESP32 v2.x và v3.x
  Serial1.setPins(RX_PIN, TX_PIN);
  Serial1.begin(BAUD);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW); // LED sáng (Active LOW)
}

void loop() {
  // Đọc toàn bộ dữ liệu từ PC → Thẻ e-ink
  if (Serial.available()) {
    while (Serial.available()) {
      Serial1.write(Serial.read());
    }
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); // nháy LED 1 lần cho cả khối
  }

  // Đọc toàn bộ dữ liệu từ Thẻ e-ink → PC
  if (Serial1.available()) {
    while (Serial1.available()) {
      Serial.write(Serial1.read());
    }
  }
}
```

#### Bước 4: Mở Serial Monitor
1. **Tools → Port** → chọn COM của ESP32-C3
2. **Tools → Serial Monitor** → chọn **115200 baud**
3. Bấm **RST** trên thẻ e-ink
4. Xem có text hiện ra không?

#### Bước 5: Flash firmware
Nếu Serial Monitor hiện text → chip còn sống!
Dùng **ESP Flash Download Tool** hoặc **STM32CubeProgrammer** để flash.

---

### Phương pháp 4: Dùng CH341A

#### Nối dây (UART mode):
```
CH341A (UART mode)      Thẻ e-ink
─────────────────       ──────────
TXD  ───────────────→   VRX
RXD  ←───────────────   VTX
GND  ───────────────→   GND
                         (KHÔNG nối VCC)
```

#### Lưu ý:
- CH341A **không hỗ trợ SWD** → chỉ flash được qua UART bootloader
- Nếu bootloader bị brick → cần ST-Link

---

## So sánh các phương pháp

| Phương pháp | Giá | Khó khăn | Đảm bảo thành công |
|---|---|---|---|
| CP2102/CH340 | ~25k-50k | ⭐ Dễ | Nếu bootloader còn sống |
| ST-Link V2 | ~40k-70k | ⭐⭐ Trung bình | ✅ Luôn được |
| ESP32-C3 | Đã có | ⭐ Dễ | Nếu bootloader còn sống |
| CH341A | Đã có | ⭐ Dễ | Nếu bootloader còn sống |

### Khuyến nghị:
1. **Nếu là người mới** → Mua CP2102 (~25k) hoặc dùng ESP32-C3 (nếu có)
2. **Nếu muốn chắc chắn** → Mua ST-Link V2 (~40k) → flash qua SWD
3. **Nếu đã có CH341A** → thử UART trước

---

## Kiểm tra chip trên mạch

Trước khi flash, cần biết chip gì trên mạch để chọn đúng phần mềm:

| Tên chip | Phần mềm flash |
|---|---|
| ESP32 / ESP32-C3 | ESP Flash Download Tool |
| STM32 | STM32CubeProgrammer |
| nRF52 | nRF Connect Programmer |
| AT32 | Artery ICP Programmer |

**Cách nhận biết:**
- Nhìn tên in trên chip (zoom ảnh rõ)
- Hoặc đo UART output → dòng đầu tiên thường ghi tên chip

---

## Download Firmware

File firmware nằm trong thư mục `firmware/`:
- `ONE-2.13L-V0.7.bin` - Phiên bản 0.7
- `ONE-2.13L-V0.8.bin` - Phiên bản 0.8
- `ONE-2.13L-V0.9.bin` - Phiên bản 0.9

Hoặc download từ GitHub: https://github.com/qvp-tech/Eink

---

## Links hữu ích

- ESP Flash Download Tool: https://www.espressif.com/en/support/download/other-tools
- STM32CubeProgrammer: https://www.st.com/en/development-tools/stm32cubeprog.html
- nRF Connect Programmer: https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-Desktop
- Arduino ESP32 Board Manager: https://espressif.github.io/arduino-esp32/package_esp32_index.json

---

## Troubleshooting

### Không thấy COM port?
- Cài driver CP2102/CH340
- Thử cổng USB khác
- Kiểm tra dây USB

### Flash tool không kết nối được?
- Đảm bảo đúng baud rate (115200)
- Reset thẻ e-ink trong khi flash
- Kiểm tra dây nối (TX/RX có bị ngược không?)

### Serial Monitor không hiện gì?
- Thử baud rate khác (9600, 115200, 921600)
- Kiểm tra dây nối
- Thử giữ RST/M1 khi cắm nguồn

### Chip không detect được?
- Có thể chip đã chết phần cứng
- Cần thay chip hoặc mua thẻ mới
