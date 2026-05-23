# LeafLens Architecture

> **System:** LeafLens — AI-Powered Plant Health Monitoring  
> **Thesis:** Available on request

---

## Device Provisioning (BLE Onboarding)

The ESP32 ships with base firmware broadcasting a BLE signal. No static IP, no hardcoded Wi-Fi. The user never sees a ThingsBoard token, Docker port, or admin credential — FastAPI handles all of that server-side.

```
┌─────────────┐   (1) BLE: Wi-Fi creds + user_id   ┌─────────────┐
│   Flutter   │ ────────────────────────────────→   │    ESP32    │
│     App     │                                     │  (base FW)  │
└─────────────┘                                     └──────┬──────┘
                                                           │ (2) connects to Wi-Fi
                                           (3) POST /api/v1/devices/register
                                               { mac_address, user_id, device_name }
                                                           │
                                                           ▼
                                                   ┌─────────────┐
                                                   │   FastAPI   │ →(4a) POST /api/device → ThingsBoard
                                                   │   Backend   │ ←(4b) GET /api/device/{id}/credentials
                                                   │             │   saves user_id ↔ device_id to PostgreSQL
                                                   └──────┬──────┘
                                                           │ (5) HTTP response: { thingsboard_token }
                                                           ▼
                                                   ┌─────────────┐
                                                   │    ESP32    │ saves token to flash (Preferences.h)
                                                   └──────┬──────┘
                                                           │ (6) MQTT with token
                                                           ▼
                                                   ┌─────────────┐
                                                   │ ThingsBoard │ receives telemetry stream
                                                   └─────────────┘
```

**Token ownership:** ThingsBoard auto-generates the device access token when the device is created (step 4a). FastAPI retrieves it via a second call (step 4b) and forwards it to ESP32. FastAPI never generates tokens — it only retrieves what ThingsBoard created.

**No TB Customers needed:** Since Flutter never talks to ThingsBoard directly, there is no need to create a ThingsBoard Customer per app user. Devices live under the tenant. FastAPI owns the tenant admin JWT server-side and maps `user_id → tb_device_id` in PostgreSQL.

### Step by Step

| Step | From | To | Data | Protocol |
|------|------|----|------|----------|
| 1 | Flutter app | ESP32 | Wi-Fi SSID + password, user_id | BLE |
| 2 | ESP32 | Home router | Wi-Fi connection | Wi-Fi |
| 3 | ESP32 | FastAPI | `{ mac_address, user_id, device_name }` | HTTP POST |
| 4a | FastAPI | ThingsBoard | Create device | REST API |
| 4b | FastAPI | ThingsBoard | GET device credentials (token) | REST API |
| 4c | FastAPI | PostgreSQL | Save `user_id ↔ tb_device_id` | SQL |
| 5 | FastAPI | ESP32 | `{ thingsboard_token }` | HTTP response |
| 6 | ESP32 | ThingsBoard | Telemetry stream | MQTT |

**Why this works anywhere:** ESP32 makes an outbound connection to your public ThingsBoard server. No port forwarding. Works on 4G/5G, any network.

---

## Steady State Data Flow

```
ESP32 ──MQTT──→ ThingsBoard ←──REST/WS──→ FastAPI ──REST/WS──→ Flutter
```

Flutter never talks to ThingsBoard directly. All TB credentials stay on the FastAPI server. Flutter authenticates with FastAPI's own JWT.

When Flutter requests data:
1. FastAPI verifies Flutter JWT → extracts `user_id`
2. PostgreSQL lookup → gets `tb_device_id`
3. FastAPI queries ThingsBoard using tenant admin JWT
4. Returns data to Flutter

| Layer | Technology | Role |
|-------|-----------|------|
| Hardware | 2× ESP32 + sensors + actuators | Data collection, actuation |
| Cloud | ThingsBoard | Telemetry storage, device management, alarms, RPC |
| Backend | FastAPI + PostgreSQL | User auth, device mapping, GHS computation, TB proxy |
| Mobile | Flutter | Dashboard UI, offline mode, BLE provisioning |

---

## Data Split

| What | Where | Why |
|------|-------|-----|
| User accounts | PostgreSQL | FastAPI issues JWT on login/register |
| User ↔ device mapping | PostgreSQL | FastAPI knows which TB device belongs to which user |
| Telemetry (soil, temp, humidity, water level) | ThingsBoard | Time-series storage, MQTT ingestion, alarm rules |
| Device config (thresholds, actuator state) | ThingsBoard shared attributes | RPC commands, no extra DB needed |
| Alarms (low water, critical health) | ThingsBoard rule engine | Built-in, no alarm logic to write |
| Growth Health Score | FastAPI (Python) | Reads telemetry from TB API, computes, returns to Flutter |

FastAPI + PostgreSQL is minimal on purpose:
- User registration/login
- Token management
- GHS computation (reads from ThingsBoard API)
- Proxy: Flutter asks FastAPI → FastAPI asks ThingsBoard

Sensor data is never stored in PostgreSQL. Alarm logic is never written in Python. ThingsBoard handles all IoT plumbing.

---

## Multiple Devices Per User

One user can own multiple ESP32 setups (multiple plants, multiple rooms). The mapping table is one-to-many:

```
PostgreSQL — devices table
┌─────────────┬──────────────────────────────────────┬──────────────┐
│ user_id     │ tb_device_id                         │ device_name  │
├─────────────┼──────────────────────────────────────┼──────────────┤
│ user_001    │ xxxx-xxxx-xxxx-xxxx-xxxx-aaaa        │ Living Room  │
│ user_001    │ xxxx-xxxx-xxxx-xxxx-xxxx-bbbb        │ Balcony      │
│ user_002    │ xxxx-xxxx-xxxx-xxxx-xxxx-cccc        │ Kitchen      │
└─────────────┴──────────────────────────────────────┴──────────────┘
```

FastAPI fetches all `tb_device_id`s for the user, queries each from ThingsBoard in parallel, and returns them together.

---

## Scalability

| Layer | Approach |
|-------|----------|
| ESP32 → TB (MQTT) | ThingsBoard handles millions of concurrent MQTT connections |
| ThingsBoard storage | Purpose-built IoT time-series DB — no custom storage layer needed |
| FastAPI | Stateless — horizontal scaling behind nginx / Traefik / ALB |
| PostgreSQL | User accounts + device mappings only — row count stays small |
| GHS computation | Stateless pure computation — scales with FastAPI instances |

Real-time telemetry is delivered over WebSocket (persistent connection). The FastAPI proxy adds one connection setup cost, not a per-message round trip.

At higher load: multiple FastAPI instances behind a gateway, one ThingsBoard WebSocket connection per device fanned out to all subscribing Flutter clients, Redis caching for historical TB queries.

---

## Hardware

### ESP32 #1 — Environmental (leaflens-env)

| Component | Purpose |
|-----------|---------|
| Soil moisture sensor | Reads capacitive/resistive moisture % |
| DHT sensor (DHT11/22) | Ambient temperature + humidity |
| Water pump | Irrigation |
| Mist maker | Humidity control |

### ESP32 #2 — Water Management (leaflens-water)

| Component | Purpose |
|-----------|---------|
| Ultrasonic sensor (HC-SR04) | Water level in internal reservoir |
| Solenoid valve | External water line refill |
| Safety cutoff | Closes valve if target not reached within timeout |

### Telemetry Keys

| Key | Source | Unit |
|-----|--------|------|
| `soil_moisture` | ESP32 #1 | % |
| `temperature` | ESP32 #1 | °C |
| `humidity` | ESP32 #1 | % |
| `water_level` | ESP32 #2 | % |

### Shared Attributes (ESP32-writable)

| Key | Type | Description |
|-----|------|-------------|
| `refill_active` | boolean | Solenoid valve status |
| `pump_active` | boolean | Water pump status |
| `mist_active` | boolean | Mist maker status |
| `safety_lockout` | boolean | Safety cutoff triggered |

---

## Authentication

| Layer | Who | Token | Flows |
|-------|-----|-------|-------|
| App user | Flutter → FastAPI | FastAPI RS256 JWT | register / login / logout |
| ThingsBoard | FastAPI → ThingsBoard | TB tenant admin JWT | Proxy calls, never leaves server |
| ESP32 | ESP32 → ThingsBoard | TB device access token | MQTT only, provisioned once |

### GoRouter Auth Guard

```dart
redirect: (context, state) {
  final isLoggedIn = auth.value != null;
  final path = state.matchedLocation;

  if (path == '/splash') return null;
  if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
  if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
  return null;
}
```

### Session Lifecycle

1. Login → `AuthRepository.login()` → FastAPI returns JWT → saved to `FlutterKeychain`
2. `authStateProvider` invalidated → GoRouter detects auth → redirects to `/dashboard`
3. App restart → `authStateProvider.tryRestore()` → reads stored JWT from keychain
4. Logout → token cleared from keychain → `authStateProvider` → redirects to `/login`

---

## ThingsBoard Data Model

### Alarm Rules

| Alarm | Condition | Severity |
|-------|-----------|----------|
| HealthCritical | healthScore < 30 | CRITICAL |
| HealthDanger | healthScore < 50 | MAJOR |
| TankLow | water_level < 20 | WARNING |
| TankCritical | water_level < 10 | CRITICAL |
| TempHigh | temperature > 35 | MAJOR |
| MoistureEmpty | soil_moisture < 10 | CRITICAL |

### RPC Commands

| Method | Action |
|--------|--------|
| `triggerWatering` | Activates water pump |
| `triggerMisting` | Activates mist maker |
| `triggerRefill` | Opens solenoid valve |
| `setThreshold` | Updates sensor thresholds |

---

## Thesis Document

The full FYP report covers:
- Problem statement and objectives (Chapter 1)
- Literature review — 13 related systems compared (Chapter 2)
- Methodology with use case, activity, sequence, DFD, ERD diagrams (Chapter 3)
- Survey data and UAT results (73 respondents)
- Gantt chart and project schedule

Available on request from the team.
