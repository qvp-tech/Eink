// UART Bridge - ESP32-C3 Super Mini
// Phuc vu cuu the e-ink bi brick
//
// Nối dây:
//   GPIO21 (TX) → VRX thẻ e-ink
//   GPIO20 (RX) ← VTX thẻ e-ink
//   GND         → GND thẻ e-ink
//
// ⚠️ KHÔNG nối 5V/3.3V sang thẻ e-ink
// ⚠️ Thẻ e-ink PHẢI có nguồn (giữ pin hoặc cấp 3.3V ngoài)

#include <Arduino.h>

#define RX_PIN 20  // GPIO20 RX
#define TX_PIN 21  // GPIO21 TX
#define LED_PIN 8  // GPIO8 = LED onboard (Active LOW)
#define BAUD  115200

void setup() {
  Serial.begin(BAUD);       // USB CDC (may tinh)

  // Dung setPins() truoc begin() de tuong thich ca core ESP32 v2.x va v3.x
  Serial1.setPins(RX_PIN, TX_PIN);
  Serial1.begin(BAUD);

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW); // LED sang (Active LOW)
}

void loop() {
  // May tinh → The e-ink
  if (Serial.available()) {
    Serial1.write(Serial.read());
    digitalWrite(LED_PIN, !digitalRead(LED_PIN)); // Nhay LED bao hieu du lieu truyen qua lai
  }
  // The e-ink → May tinh
  if (Serial1.available()) {
    Serial.write(Serial1.read());
  }
}
