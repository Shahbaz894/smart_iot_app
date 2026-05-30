# smart_iot_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── src/
│   ├── core/
│   │   ├── constants/
│   │   ├── exceptions/
│   │   ├── theme/
│   │   ├── utils/
│   │   ├── routing/
│   │   ├── config/
│   │   ├── providers/
│   │   └── result/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── devices/
│   │   ├── dashboard/
│   │   └── widgets/
│   │
│   ├── services/
│   │   ├── firestore_service.dart
│   │   ├── rtdb_service.dart
│   │   ├── storage_service.dart
│   │   └── network/
│   │
│   └── main.dart


Platform  Firebase App Id
web       1:776211089232:web:079d86b7f912bbb9a30e55
android   1:776211089232:android:93c33186d9a9064da30e55
ios       1:776211089232:ios:5c0c84590d40c008a30e55
macos     1:776211089232:ios:5c0c84590d40c008a30e55
windows   1:776211089232:web:ed43c47900210e00a30e55
flutter pub add firebase_core


#include <WiFi.h>
#include <PubSubClient.h>

// ---------------- CONFIGURATION ----------------
// Wi-Fi Access Point Details
const char* ssid     = "Shehbaz House";
const char* password = "green7890";

// Server Configurations
const char* mqtt_server = "157.245.55.83";
const int mqtt_port     = 1883;

// Topic Configuration (Matches your working database Device UUID)
String device_uid     = "7a966ae8-70e1-494b-925a-0754c93064bb";
String topicTelemetry = "tubewell/" + device_uid + "/telemetry";

// Core Variables for Timing
unsigned long lastMsgTime = 0;
const unsigned long telemetryInterval = 5000; // Send data every 5 seconds
// ----------------------------------------------

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
delay(10);
Serial.println();
Serial.print("Connecting to network: ");
Serial.println(ssid);

WiFi.begin(ssid, password);

while (WiFi.status() != WL_CONNECTED) {
delay(500);
Serial.print(".");
}

Serial.println("");
Serial.println("WiFi Connected successfully!");
Serial.print("ESP32 IP Address: ");
Serial.println(WiFi.localIP());
}

void reconnect() {
// Loop until we are stably reconnected to the broker
while (!client.connected()) {
Serial.print("Attempting MQTT connection to server...");

    // FIX 1: Appending '_HARDWARE' ensures this unique ID never clashes 
    // with your Python consumer worker or Flutter application loops.
    String clientId = "esp32_" + device_uid + "_HARDWARE";
    
    if (client.connect(clientId.c_str())) {
      Serial.println("CONNECTED CLEANLY!");
    } else {
      Serial.print("FAILED, rc=");
      Serial.print(client.state());
      Serial.println(" | Retrying network sequence in 5 seconds...");
      delay(5000);
    }
}
}

String buildTelemetryJSON() {
// Test Mock Metrics matching your verified Swagger schema properties
float freq = 50;            
float current = 14.5;         
float voltage = 382.0;        
float dcbus = 380.2;          
float power = 10.8;            
float energy_in = 1000.3;      
float reference_freq = 45.0;  
float motor_speed = 1326.0;   
float power_percent = 90.5;   
float torque_percent = 76.4;

int fault = 0;                
int fault_code = 0;           
int status_code = 1;          // 1 = Forward Running
int is_live = 1;

long long timestamp = 1779036179;

// Fast string concatenation structure
String json = "{";
json += "\"timestamp\":" + String(timestamp) + ",";
json += "\"freq\":" + String(freq, 1) + ",";
json += "\"current\":" + String(current, 1) + ",";
json += "\"voltage\":" + String(voltage, 1) + ",";
json += "\"dcbus\":" + String(dcbus, 1) + ",";
json += "\"power\":" + String(power, 1) + ",";
json += "\"energy_in\":" + String(energy_in, 1) + ",";
json += "\"fault\":" + String(fault) + ",";
json += "\"fault_code\":" + String(fault_code) + ",";
json += "\"status_code\":" + String(status_code) + ",";
json += "\"reference_freq\":" + String(reference_freq, 1) + ",";
json += "\"motor_speed\":" + String(motor_speed, 1) + ",";
json += "\"power_percent\":" + String(power_percent, 1) + ",";
json += "\"torque_percent\":" + String(torque_percent, 1) + ",";
json += "\"is_live\":" + String(is_live);
json += "}";

return json;
}

void setup() {
Serial.begin(115200);
setup_wifi();

client.setServer(mqtt_server, mqtt_port);

// FIX 2: Set keepAlive to 60 seconds to completely stop 'exceeded timeout' drops
client.setKeepAlive(60);

// FIX 3: Increase internal packet capacity window from standard 128 bytes to 512 bytes
// to ensure your complete JSON schema data isn't missing keys or truncated mid-transmission.
client.setBufferSize(512);
}

void loop() {
if (!client.connected()) {
reconnect();
}

// FIX 4: Call client.loop() constantly. This handles background connection
// heartbeats and MQTT processing. Never add large delay() blocks in loop()!
client.loop();

unsigned long now = millis();
if (now - lastMsgTime > telemetryInterval) {
lastMsgTime = now;

    String payload = buildTelemetryJSON();
    
    Serial.print("Publishing payload data to topic [");
    Serial.print(topicTelemetry);
    Serial.println("]...");
    Serial.println(payload);

    // Ship data down the MQTT broker stream pipeline
    if (client.publish(topicTelemetry.c_str(), payload.c_str())) {
      Serial.println("✨ MQTT TRANSMIT SUCCESSFUL (SENT OK)!");
    } else {
      Serial.println("❌ ERROR: Packet dropped during serialization.");
    }
}
}


accurate code with device id esp32-001-tw
#include <WiFi.h>
#include <PubSubClient.h>

// ---------------- CONFIGURATION ----------------
// Wi-Fi Access Point Details
const char* ssid     = "Shehbaz House";
const char* password = "green7890";

// Server Configurations
const char* mqtt_server = "157.245.55.83";
const int mqtt_port     = 1883;

// 🔥 FIXED: Now using your true device identification string across the system
String device_uid     = "ESP32_001_TW";
String topicTelemetry = "tubewell/" + device_uid + "/telemetry";
// 🔥 MATCHED WITH FASTAPI: Topic name updated from /control to /motor
String topicMotor     = "tubewell/" + device_uid + "/motor";

// Hardware Pin Mapping for your test LED
const int LED_PIN = 13;

// Core Variables for Timing
unsigned long lastMsgTime = 0;
const unsigned long telemetryInterval = 5000; // Send data every 5 seconds
// ----------------------------------------------

WiFiClient espClient;
PubSubClient client(espClient);

// MQTT Listener function to handle incoming ON/OFF commands
void callback(char* topic, byte* payload, unsigned int length) {
Serial.print("Message arrived on topic [");
Serial.print(topic);
Serial.print("]: ");

String message = "";
for (int i = 0; i < length; i++) {
message += (char)payload[i];
}
Serial.println(message);

// Check if the received command payload text matches intent
if (message == "1" || message == "ON" || message == "on") {
digitalWrite(LED_PIN, HIGH);
Serial.println("💡 Physical LED turned ON");
} else if (message == "0" || message == "OFF" || message == "off") {
digitalWrite(LED_PIN, LOW);
Serial.println("🌑 Physical LED turned OFF");
}
}

void setup_wifi() {
delay(10);
Serial.println();
Serial.print("Connecting to network: ");
Serial.println(ssid);

WiFi.begin(ssid, password);

while (WiFi.status() != WL_CONNECTED) {
delay(500);
Serial.print(".");
}

Serial.println("");
Serial.println("WiFi Connected successfully!");
Serial.print("ESP32 IP Address: ");
Serial.println(WiFi.localIP());
}

void reconnect() {
// Loop until we are stably reconnected to the broker
while (!client.connected()) {
Serial.print("Attempting MQTT connection to server...");

    // Appending '_HARDWARE' ensures this unique ID never clashes 
    // with your Python consumer worker or Flutter application loops.
    String clientId = "esp32_" + device_uid + "_HARDWARE";
    
    if (client.connect(clientId.c_str())) {
      Serial.println("CONNECTED CLEANLY!");
      
      // Subscribe to the control topic immediately upon connection
      client.subscribe(topicControl.c_str());
      Serial.print("Subscribed to control pipeline channel: ");
      Serial.println(topicControl);
    } else {
      Serial.print("FAILED, rc=");
      Serial.print(client.state());
      Serial.println(" | Retrying network sequence in 5 seconds...");
      delay(5000);
    }
}
}

String buildTelemetryJSON() {
// Test Mock Metrics matching your verified Swagger schema properties
float freq = 47;            
float current = 20.5;         
float voltage = 382.0;        
float dcbus = 390.2;          
float power = 15.8;            
float energy_in = 1000.3;      
float reference_freq = 45.0;  
float motor_speed = 1326.0;   
float power_percent = 90.5;   
float torque_percent = 76.4;

int fault = 0;                
int fault_code = 0;           
int status_code = 1;          // 1 = Forward Running
int is_live = 1;

long long timestamp = 1779036179;

// Fast string concatenation structure
String json = "{";
json += "\"timestamp\":" + String(timestamp) + ",";
json += "\"freq\":" + String(freq, 1) + ",";
json += "\"current\":" + String(current, 1) + ",";
json += "\"voltage\":" + String(voltage, 1) + ",";
json += "\"dcbus\":" + String(dcbus, 1) + ",";
json += "\"power\":" + String(power, 1) + ",";
json += "\"energy_in\":" + String(energy_in, 1) + ",";
json += "\"fault\":" + String(fault) + ",";
json += "\"fault_code\":" + String(fault_code) + ",";
json += "\"status_code\":" + String(status_code) + ",";
json += "\"reference_freq\":" + String(reference_freq, 1) + ",";
json += "\"motor_speed\":" + String(motor_speed, 1) + ",";
json += "\"power_percent\":" + String(power_percent, 1) + ",";
json += "\"torque_percent\":" + String(torque_percent, 1) + ",";
json += "\"is_live\":" + String(is_live);
json += "}";

return json;
}

void setup() {
// Initialize the hardware pin configuration direction
pinMode(LED_PIN, OUTPUT);
digitalWrite(LED_PIN, LOW); // Turn it off initially

Serial.begin(115200);
setup_wifi();

client.setServer(mqtt_server, mqtt_port);

// Assign the callback execution address to structural listener
client.setCallback(callback);

// Set keepAlive to 60 seconds to completely stop 'exceeded timeout' drops
client.setKeepAlive(60);

// Increase internal packet capacity window from standard 128 bytes to 512 bytes
// to ensure your complete JSON schema data isn't missing keys or truncated mid-transmission.
client.setBufferSize(512);
}

void loop() {
if (!client.connected()) {
reconnect();
}

// Call client.loop() constantly. This handles background connection
// heartbeats and MQTT processing. Never add large delay() blocks in loop()!
client.loop();

unsigned long now = millis();
if (now - lastMsgTime > telemetryInterval) {
lastMsgTime = now;

    String payload = buildTelemetryJSON();
    
    Serial.print("Publishing payload data to topic [");
    Serial.print(topicTelemetry);
    Serial.println("]...");
    Serial.println(payload);

    // Ship data down the MQTT broker stream pipeline
    if (client.publish(topicTelemetry.c_str(), payload.c_str())) {
      Serial.println("✨ MQTT TRANSMIT SUCCESSFUL (SENT OK)!");
    } else {
      Serial.println("❌ ERROR: Packet dropped during serialization.");
    }
}
}