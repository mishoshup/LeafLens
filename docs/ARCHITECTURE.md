# LeafLens Architecture

> **System:** LeafLens — AI-Powered Plant Health Monitoring  
> **Thesis:** Available on request

---

## Device Provisioning (BLE Onboarding)

The ESP32 ships with base firmware broadcasting a BLE signal. No static IP, no hardcoded Wi-Fi.

```
┌──────────┐    BLE (Wi-Fi + user ID)    ┌──────────┐
│  Flutter  │ ──────────────────────────→ │   ESP32  │
│   App     │                             │ (base FW)│
└──────────┘                             └────┬─────┘
                                               │ connects to Wi-Fi
                                               ▼
                                        ┌──────────┐
                                        │  FastAPI  │ ←── POST /api/v1/devices/register
                                        │  Backend  │      { mac_address, user_id, device_name }
                                        └────┬─────┘
                                             │ creates device via TB REST API
                                             ▼
                                        ┌──────────┐
                                        │ ThingsBoard│
                                        └──────────┘
                                             │ returns access token
                                             ▼
                                        ┌──────────┐
                                        │   ESP32   │ ←── saves token to flash (Preferences.h)
                                        └──────────┘
                                             │ connects MQTT with token
                                             ▼
                                        ┌──────────┐
                                        │ ThingsBoard│ ←── streams telemetry
                                        └──────────┘
```

### Step by Step

| Step | From | To | Data | Protocol |
|------|------|----|------|----------|
| 1 | Flutter app | ESP32 | Wi-Fi SSID + password, user ID | BLE |
| 2 | ESP32 | Home router | Wi-Fi connection | Wi-Fi |
| 3 | ESP32 | FastAPI | `{ mac_address, user_id, device_name }` | HTTP POST |
| 4 | FastAPI | ThingsBoard | Create device + generate access token | REST API |
| 5 | FastAPI | ESP32 | `{ thingsboard_token }` | HTTP response |
| 6 | ESP32 | ThingsBoard | Telemetry (MQTT with token) | MQTT |

**Why this matters:** ESP32 connects outbound to a public ThingsBoard server. No port forwarding. The user can monitor from anywhere on 4G/5G.

---

## Steady State Data Flow

```
ESP32 ──MQTT──→ ThingsBoard ──REST──→ FastAPI ──REST/WS──→ Flutter
```

| Layer | Technology | Role |
|-------|-----------|------|
| Hardware | 2× ESP32 + sensors + actuators | Data collection, actuation |
| Cloud | ThingsBoard (public) | Telemetry storage, device management, alarms, RPC |
| Backend | FastAPI (Python) | Device registration, user auth, GHS computation, TB proxy |
| Mobile | Flutter | Dashboard UI, offline mode, BLE provisioning |

**Flutter never talks to ThingsBoard directly.** All ThingsBoard credentials stay on the FastAPI server. Flutter only talks to FastAPI (authenticated with a user JWT).

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
| App User | Flutter → FastAPI | FastAPI RS256 JWT | register / login / logout |
| ThingsBoard | FastAPI → ThingsBoard | TB API key + service account JWT | Proxy calls, never in app |

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
