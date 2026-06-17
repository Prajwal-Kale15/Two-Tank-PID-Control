# Two-Tank Interacting System – Real-Time PID Control (IoT + MATLAB)

**Course Project | Instrumentation & Control Engineering | VIT Pune**

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

1. Flash the ESP8266 with the NodeMCU firmware (web server serving `/data` and `/control`)
2. Connect the hardware (sensor, pumps, relay) as per the circuit diagram
3. Update `esp_ip` in `Two_Tank_PID_Control.m` with your ESP's IP address
4. Run `Two_Tank_PID_Control.m` in MATLAB
5. Monitor real-time graphs and IoT dashboard

---

## Project By

**Prajwal Kale**
B.Tech Instrumentation & Control Engineering, VIT Pune
