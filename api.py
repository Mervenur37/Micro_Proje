"""
API LAYER - UART (STREAM MODE)
==============================
PIC sürekli sicaklik gonderir.
Python sadece UART'tan okur.
GUI bu API'yi kullanir.
"""

import serial
import time


# =========================
# UART CONNECTION
# =========================
class UARTConnection:
    def __init__(self, port: str, baudrate: int = 9600, timeout: float = 1):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.ser = None

    def connect(self):
        try:
            self.ser = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout
            )
            time.sleep(2)  # PIC reset suresi
            print(f"[UART] Connected to {self.port}")
        except serial.SerialException as e:
            raise RuntimeError(f"UART error: {e}")

    def receive(self) -> str:
        if not self.ser or not self.ser.is_open:
            raise RuntimeError("UART not connected")
        return self.ser.readline().decode(errors="ignore").strip()

    def close(self):
        if self.ser and self.ser.is_open:
            self.ser.close()


# =========================
# AIR CONDITIONER API
# =========================
class AirConditionerAPI:
    def __init__(self, uart):
        self.uart = uart
        self.last_temp = None  # None = veri yok

    def get_ambient_temperature(self):
        """
        UART'tan veri okunursa float döner
        Okunamazsa None döner (GUI 'N/A' yazacak)
        """
        try:
            line = self.uart.receive()
            if not line:
                return self.last_temp

            self.last_temp = float(line)
            return self.last_temp

        except (ValueError, TypeError):
            return self.last_temp

    def get_desired_temperature(self):
        return self.last_temp

    def set_desired_temperature(self, value: float):
        self.last_temp = value

    def get_fan_speed(self) -> int:
        return 0



# =========================
# CURTAIN CONTROL API
# (simdilik dummy)
# =========================
class CurtainControlAPI:
    def __init__(self, uart):
        self.uart = uart
        self.outdoor_temp = None
        self.outdoor_pressure = None
        self.light_intensity = None
        self.curtain_status = None

    def _update_from_uart(self):
        try:
            line = self.uart.receive()
            if not line:
                return
            if line.startswith("OUT_TEMP:"):
                self.outdoor_temp = float(line.split(":")[1])
            elif line.startswith("PRESSURE:"):
                self.outdoor_pressure = float(line.split(":")[1])
            elif line.startswith("LIGHT:"):
                self.light_intensity = float(line.split(":")[1])
            elif line.startswith("CURTAIN:"):
                self.curtain_status = float(line.split(":")[1])
        except Exception:
            pass

    def get_outdoor_temperature(self):
        self._update_from_uart()
        return self.outdoor_temp

    def get_outdoor_pressure(self):
        self._update_from_uart()
        return self.outdoor_pressure

    def get_light_intensity(self):
        self._update_from_uart()
        return self.light_intensity

    def get_curtain_status(self):
        self._update_from_uart()
        return self.curtain_status

    # ✅ Bu metod kesin olmalı
    def set_curtain_status(self, value: float):
        if 0 <= value <= 100:
            self.curtain_status = value
            # İleride PIC’e gönderebilirsin
            # self.uart.send(f"SET_CURTAIN:{value}")







# =========================
# SYSTEM INIT
# =========================
def initialize_system():
    """
    ⚠️ COM portu PICSimLab ile AYNI olmali
    Ornek:
    Windows: COM2
    Linux : /dev/ttyUSB0
    """

    uart = UARTConnection(port="COM2", baudrate=9600)
    uart.connect()

    ac_api = AirConditionerAPI(uart)
    curtain_api = CurtainControlAPI(uart)

    return ac_api, curtain_api
