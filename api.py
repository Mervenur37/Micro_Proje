import tkinter as tk
from tkinter import ttk, messagebox
from api import initialize_system


# =========================
# MAIN APPLICATION
# =========================
class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Home Automation System")
        self.geometry("360x380")
        self.resizable(False, False)

        # === API INIT ===
        self.ac_api, self.curtain_api = initialize_system()

        self.frames = {}
        for F in (MainMenu, AirConditioner, CurtainControl):
            frame = F(self)
            self.frames[F] = frame
            frame.place(x=0, y=0, relwidth=1, relheight=1)

        self.show_frame(MainMenu)

    def show_frame(self, frame_class):
        self.frames[frame_class].tkraise()


# =========================
# MAIN MENU
# =========================
class MainMenu(tk.Frame):
    def __init__(self, parent):
        super().__init__(parent)

        ttk.Label(self, text="MAIN MENU", font=("Arial", 14, "bold")).pack(pady=20)

        ttk.Button(
            self, text="Air Conditioner",
            command=lambda: parent.show_frame(AirConditioner)
        ).pack(pady=10, fill="x", padx=40)

        ttk.Button(
            self, text="Curtain Control",
            command=lambda: parent.show_frame(CurtainControl)
        ).pack(pady=10, fill="x", padx=40)

        ttk.Button(
            self, text="Exit",
            command=parent.destroy
        ).pack(pady=10, fill="x", padx=40)


# =========================
# AIR CONDITIONER
# =========================
class AirConditioner(tk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.api = parent.ac_api

        ttk.Label(self, text="AIR CONDITIONER", font=("Arial", 13, "bold")).pack(pady=10)

        self.lbl1 = ttk.Label(self)
        self.lbl2 = ttk.Label(self)
        self.lbl3 = ttk.Label(self)
        self.update_labels()

        ttk.Separator(self).pack(fill="x", pady=10)

        ttk.Button(
            self, text="Enter the desired temperature",
            command=self.enter_temp
        ).pack(pady=5, fill="x", padx=40)

        ttk.Button(
            self, text="Return",
            command=lambda: parent.show_frame(MainMenu)
        ).pack(pady=5, fill="x", padx=40)

    def update_labels(self):
    # Ambient Temperature
        ambient = self.api.get_ambient_temperature()
        if ambient is None:
            ambient_text = "Home Ambient Temperature: N/A"
        else:
            ambient_text = f"Home Ambient Temperature: {ambient:.1f} °C"

    # Desired Temperature
        desired = self.api.get_desired_temperature()
        if desired is None:
            desired_text = "Home Desired Temperature: N/A"
        else:
            desired_text = f"Home Desired Temperature: {desired:.1f} °C"

    # Fan Speed
        fan_speed = self.api.get_fan_speed()
        if fan_speed is None:
            fan_text = "Fan Speed: N/A"
        else:
            fan_text = f"Fan Speed: {fan_speed} rps"

        self.lbl1.config(text=ambient_text)
        self.lbl2.config(text=desired_text)
        self.lbl3.config(text=fan_text)

        self.lbl1.pack(pady=5)
        self.lbl2.pack(pady=5)
        self.lbl3.pack(pady=5)



    def enter_temp(self):
        popup = tk.Toplevel(self)
        popup.title("Enter Desired Temperature")
        popup.geometry("250x150")
        popup.resizable(False, False)

        popup.transient(self)
        popup.grab_set()
        popup.focus_force()

        ttk.Label(popup, text="Desired Temperature (°C)").pack(pady=10)
        entry = ttk.Entry(popup)
        entry.pack(pady=5)
        entry.focus()

        def save():
            try:
                value = float(entry.get())
                self.api.set_desired_temperature(value)
                self.update_labels()
                popup.grab_release()
                popup.destroy()
            except ValueError:
                messagebox.showerror("Error", "Enter numeric value")

        ttk.Button(popup, text="OK", command=save).pack(pady=10)


# =========================
# CURTAIN CONTROL
# =========================
class CurtainControl(tk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.api = parent.curtain_api

        ttk.Label(self, text="CURTAIN CONTROL", font=("Arial", 13, "bold")).pack(pady=10)

        self.l1 = ttk.Label(self)
        self.l2 = ttk.Label(self)
        self.l3 = ttk.Label(self)
        self.l4 = ttk.Label(self)
        self.update_labels()

        ttk.Separator(self).pack(fill="x", pady=10)

        ttk.Button(
            self, text="Enter the desired curtain status",
            command=self.enter_status
        ).pack(pady=5, fill="x", padx=40)

        ttk.Button(
            self, text="Return",
            command=lambda: parent.show_frame(MainMenu)
        ).pack(pady=5, fill="x", padx=40)

    def update_labels(self):
        temp = self.api.get_outdoor_temperature()
        pres = self.api.get_outdoor_pressure()
        light = self.api.get_light_intensity()
        status = self.api.get_curtain_status()

        # Outdoor Temperature
        if temp is None:
                temp_text = "Outdoor Temperature: N/A"
        else:
                temp_text = f"Outdoor Temperature: {temp:.1f} °C"

        # Outdoor Pressure
        if pres is None:
                pres_text = "Outdoor Pressure: N/A"
        else:
                pres_text = f"Outdoor Pressure: {pres:.1f} hPa"

        # Curtain Status
        if status is None:
            status_text = "Curtain Status: N/A"
        else:
            status_text = f"Curtain Status: {status:.1f} %"

        # Light Intensity
        if light is None:
            light_text = "Light Intensity: N/A"
        else:
            light_text = f"Light Intensity: {light:.1f} Lux"

        self.l1.config(text=temp_text)
        self.l2.config(text=pres_text)
        self.l3.config(text=status_text)
        self.l4.config(text=light_text)

        self.l1.pack(pady=5)
        self.l2.pack(pady=5)
        self.l3.pack(pady=5)
        self.l4.pack(pady=5)


    def enter_status(self):
        popup = tk.Toplevel(self)
        popup.title("Enter Desired Curtain Status")
        popup.geometry("250x150")
        popup.resizable(False, False)

        popup.transient(self)
        popup.grab_set()
        popup.focus_force()

        ttk.Label(popup, text="Curtain Status (%)").pack(pady=10)
        entry = ttk.Entry(popup)
        entry.pack(pady=5)
        entry.focus()

    # save fonksiyonu popup içinde ama button dışında
        def save():
            try:
                value = float(entry.get())
                self.api.set_curtain_status(value)
                self.update_labels()
                popup.grab_release()
                popup.destroy()
            except ValueError:
                messagebox.showerror("Error", "Enter numeric value")

    # Button save fonksiyonunu çağıracak şekilde fonksiyon dışında tanımlanmalı
        ttk.Button(popup, text="OK", command=save).pack(pady=10)



# =========================
# RUN
# =========================
if __name__ == "__main__":
    app = App()
    app.mainloop()
