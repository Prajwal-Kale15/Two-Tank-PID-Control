# Two-Tank Interacting System – Real-Time PID Control (IoT + MATLAB)

**Course Project | Instrumentation & Control Engineering | VIT Pune**

---

## Demo Videos

| Video 1 | Video 2 | Video 3 |
|---|---|---|
| [![Demo 1](https://img.youtube.com/vi/3d1ahmW1kpM/0.jpg)](https://youtu.be/3d1ahmW1kpM) | [![Demo 2](https://img.youtube.com/vi/M7UsVfYNraI/0.jpg)](https://youtu.be/M7UsVfYNraI) | [![Demo 3](https://img.youtube.com/vi/szhlUcdtQvc/0.jpg)](https://youtu.be/szhlUcdtQvc) |

---

## Overview

This project implements a **real-time closed-loop PID control system** for a two-tank interacting system. The goal is to maintain a constant water level in the tank at a desired setpoint using an ESP8266 NodeMCU microcontroller, an ultrasonic sensor, and a MATLAB-based control loop.

The two tanks are interconnected, making the system **second-order and interacting** — a classic control engineering challenge.

---

## Hardware Used

| Component | Purpose |
|---|---|
| ESP8266 NodeMCU | Microcontroller + Wi-Fi communication |
| HC-SR04 Ultrasonic Sensor | Water level measurement |
| Inlet Pump | Fills the tank |
| Outlet Pump | Drains the tank |
| Relay Module | Controls pump switching |

---

## Software & Tools

- **MATLAB** — Real-time PID control loop, live data visualization
- **ESP8266 Web Server** — Hosts `/data` and `/control` REST endpoints
- **IoT Web Dashboard** — Live monitoring of water level and setpoint

---

## PID Parameters

| Parameter | Value |
|---|---|
| Kp (Proportional) | 2.0 |
| Ki (Integral) | 0.4 |
| Kd (Derivative) | 1.0 |
| Setpoint | 15.0 cm |
| Sampling Time | 1 s |

---

## Results

- Water level stabilized at **15 cm setpoint** with minimal overshoot
- Error converged to **near-zero steady-state error**
- PID output correctly switched between inlet and outlet pumps
- Results validated against theoretical **Simulink transfer function analysis**

### Graphs

**Graph 1 – Tank Water Level vs Time**
> Shows actual water level rising and stabilizing at the 15 cm setpoint.

**Graph 2 – PID Controller Output**
> Positive = Inlet pump ON | Negative = Outlet pump ON | Near zero = Stable

**Graph 3 – Pump Activation Pattern**
> Green = Water inlet active | Red = Water outlet active

---

## How to Run

1. Flash the ESP8266 with `ESP8266_TwoTank_WebServer.ino` using Arduino IDE
2. Update `ssid` and `password` in the `.ino` file with your Wi-Fi credentials
3. Connect hardware (HC-SR04, pumps, relay) as per circuit
4. Note the ESP8266 IP from Serial Monitor
5. Update `esp_ip` in `Two_Tank_PID_Control.m` with that IP
6. Run `Two_Tank_PID_Control.m` in MATLAB
7. Monitor real-time graphs and IoT dashboard

---

## Files

| File | Description |
|---|---|
| `Two_Tank_PID_Control.m` | MATLAB PID control loop + live visualization |
| `ESP8266_TwoTank_WebServer.ino` | ESP8266 Arduino web server code |
| `CT_CPReport_group5.docx` | Full project report |

---

## Project By

**Prajwal Kale**
B.Tech Instrumentation & Control Engineering, VIT Pune
