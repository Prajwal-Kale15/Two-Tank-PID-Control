// ============================================================
//  ESP8266 NodeMCU - Two Tank PID Control Web Server
//  Project: Two Tank Interacting System (IoT PID Control)
//  Author: Prajwal Kale
//  VIT Pune - Instrumentation & Control Engineering
//
//  Endpoints:
//    GET /       → Live dashboard (HTML)
//    GET /data   → Returns JSON with water level
//    GET /control?in=1&out=0 → Controls inlet/outlet pumps
// ============================================================

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// ── WiFi Credentials ─────────────────────────────────────────
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// ── Pin Definitions ──────────────────────────────────────────
#define TRIG_PIN     D6   // HC-SR04 Trigger
#define ECHO_PIN     D7   // HC-SR04 Echo
#define INLET_PUMP   D1   // Relay IN1 → Inlet pump
#define OUTLET_PUMP  D2   // Relay IN2 → Outlet pump

// ── Tank Parameters ──────────────────────────────────────────
const float TANK_HEIGHT_CM = 30.0;  // Sensor to empty tank bottom (cm)
const float SETPOINT_CM    = 15.0;  // Desired water level

// ── Web Server ───────────────────────────────────────────────
ESP8266WebServer server(80);

// ── Read Water Level from HC-SR04 ────────────────────────────
float getWaterLevel() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  float distance = duration * 0.034 / 2.0;  // cm
  float level = TANK_HEIGHT_CM - distance;

  if (level < 0)               level = 0;
  if (level > TANK_HEIGHT_CM)  level = TANK_HEIGHT_CM;

  return level;
}

// ── GET /data → JSON response ─────────────────────────────────
void handleData() {
  float level = getWaterLevel();

  StaticJsonDocument<128> doc;
  doc["level"]    = level;
  doc["setpoint"] = SETPOINT_CM;
  doc["unit"]     = "cm";

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

// ── GET /control?in=1&out=0 ───────────────────────────────────
void handleControl() {
  int inPump  = 0;
  int outPump = 0;

  if (server.hasArg("in"))  inPump  = server.arg("in").toInt();
  if (server.hasArg("out")) outPump = server.arg("out").toInt();

  // Relay modules are typically ACTIVE LOW
  digitalWrite(INLET_PUMP,  inPump  ? LOW : HIGH);
  digitalWrite(OUTLET_PUMP, outPump ? LOW : HIGH);

  String status = "Inlet=" + String(inPump) + " Outlet=" + String(outPump);
  server.send(200, "text/plain", status);

  Serial.println("Control: " + status);
}

// ── GET / → Live HTML Dashboard ──────────────────────────────
void handleRoot() {
  float level = getWaterLevel();

  String inletState  = (digitalRead(INLET_PUMP)  == LOW) ? "ON"  : "OFF";
  String outletState = (digitalRead(OUTLET_PUMP) == LOW) ? "ON"  : "OFF";

  String html = "<!DOCTYPE html><html><head>";
  html += "<title>IoT Water Level Controller</title>";
  html += "<meta http-equiv='refresh' content='2'>";
  html += "<style>body{font-family:Arial;padding:20px;background:#f0f0f0;}";
  html += "h2{color:#1a3c6e;} .box{background:white;padding:15px;border-radius:8px;margin:10px 0;}";
  html += "</style></head><body>";
  html += "<h2>IoT Water Level Controller</h2>";
  html += "<div class='box'>";
  html += "<p><b>Current Level:</b> " + String(level, 2) + " cm</p>";
  html += "<p><b>Setpoint:</b> " + String(SETPOINT_CM, 2) + " cm</p>";
  html += "<p><b>Inlet Pump:</b> " + inletState + "</p>";
  html += "<p><b>Outlet Pump:</b> " + outletState + "</p>";
  html += "<p><b>NodeMCU IP:</b> " + WiFi.localIP().toString() + "</p>";
  html += "</div>";
  html += "<p style='color:gray;font-size:12px;'>Auto-refreshes every 2 seconds</p>";
  html += "</body></html>";

  server.send(200, "text/html", html);
}

// ── Setup ────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  Serial.println("\nBooting ESP8266...");

  // Pin modes
  pinMode(TRIG_PIN,    OUTPUT);
  pinMode(ECHO_PIN,    INPUT);
  pinMode(INLET_PUMP,  OUTPUT);
  pinMode(OUTLET_PUMP, OUTPUT);

  // Default: both pumps OFF (relay active LOW → set HIGH)
  digitalWrite(INLET_PUMP,  HIGH);
  digitalWrite(OUTLET_PUMP, HIGH);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Register server routes
  server.on("/",        handleRoot);
  server.on("/data",    handleData);
  server.on("/control", handleControl);
  server.begin();

  Serial.println("Web server started. Ready.");
}

// ── Loop ─────────────────────────────────────────────────────
void loop() {
  server.handleClient();
}
