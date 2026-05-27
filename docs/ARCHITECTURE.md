# LeafLens Architecture

> **System:** LeafLens — AI-Powered Plant Health Monitoring  
> **Thesis:** Available on request

---

## Flutter Architecture (MVVM)

LeafLens follows Google's recommended [MVVM architecture pattern](https://docs.flutter.dev/app-architecture/guide). The app is organized into feature modules with a clear separation of concerns: **Views** (Flutter widgets) → **ViewModels** (Riverpod providers) → **Repositories** → **Services**. The domain layer is omitted for LeafLens's scope — domain logic lives directly in providers.

### Directory Structure

```
lib/
├── main.dart                              # Entry point only
├── app.dart                               # LeafLensApp widget only
├── core/
│   ├── config/app_config.dart
│   ├── errors/failures.dart, error_handler.dart
│   ├── init/sentry_init.dart, leaf_lens_auth_init.dart
│   ├── network/api_client.dart, ws_client.dart
│   ├── router/app_router.dart, auth_guard.dart
│   └── theme/app_theme.dart, app_colors.dart, app_typography.dart
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart, leaf_lens_auth.dart
│   │   └── presentation/login_page.dart, signup_page.dart
│   ├── dashboard/
│   │   ├── data/dashboard_providers.dart
│   │   ├── domain/dashboard_update.dart, growth_health_score.dart, sensor_key.dart, sensor_reading.dart, water_system_state.dart
│   │   └── presentation/dashboard_screen.dart
│   └── splash/presentation/splash_screen.dart
└── shared/
    ├── widgets/app_text_field.dart, app_button.dart, background_ellipse.dart, leaf_lens_logo.dart, health_gauge.dart, sensor_tile.dart, status_badge.dart, sensor_error_boundary.dart, offline_banner.dart
    └── notifications/notification_service.dart, leaf_lens_notification_overlay.dart, leaf_lens_toast.dart, app_dialog.dart
```

### Key Principles

- **Feature-first organization:** Each feature (`auth`, `dashboard`, `splash`) contains its own `data/`, `domain/`, and `presentation/` layers.
- **Core is shared infrastructure:** `core/` holds config, error handling, networking, routing, and theming used across all features.
- **Shared is reusable UI:** `shared/` contains widgets and notification utilities that multiple features depend on.
- **main.dart is minimal:** Only bootstraps the app. `app.dart` owns the `LeafLensApp` widget. Feature screens live in `features/*/presentation/`.
- **Screens folder eliminated:** No top-level `screens/` directory. Each screen belongs to its feature module.

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

Flutter never talks to ThingsBoard directly. All TB credentials stay on the FastAPI server. Flutter authenticates via Supabase (user accounts) and FastAPI proxies ThingsBoard data using a tenant admin JWT.

When Flutter requests data:
1. FastAPI verifies the Supabase JWT → extracts `user_id`
2. PostgreSQL lookup → gets `tb_device_id`
3. FastAPI queries ThingsBoard using tenant admin JWT
4. Returns data to Flutter

| Layer | Technology | Role |
|-------|-----------|------|
| Hardware | 2× ESP32 + sensors + actuators | Data collection, actuation |
| Cloud | ThingsBoard | Telemetry storage, device management, alarms, RPC |
| Auth | Supabase | User accounts, sessions, JWT issuance |
| Backend | FastAPI + PostgreSQL | Device mapping, GHS computation, TB proxy |
| Mobile | Flutter | Dashboard UI, offline mode, BLE provisioning |

---

## Data Split

| What | Where | Why |
|------|-------|-----|
| User accounts | Supabase (PostgreSQL) | Supabase handles registration, login, JWT issuance, session refresh |
| User ↔ device mapping | PostgreSQL (FastAPI) | FastAPI knows which TB device belongs to which user |
| Telemetry (soil, temp, humidity, water level) | ThingsBoard | Time-series storage, MQTT ingestion, alarm rules |
| Device config (thresholds, actuator state) | ThingsBoard shared attributes | RPC commands, no extra DB needed |
| Alarms (low water, critical health) | ThingsBoard rule engine | Built-in, no alarm logic to write |
| Growth Health Score | FastAPI (Python) | Reads telemetry from TB API, computes, returns to Flutter |

FastAPI + PostgreSQL is minimal on purpose:
- Device registration and mapping
- TB proxy (Flutter asks FastAPI → FastAPI asks ThingsBoard)
- GHS computation (reads from ThingsBoard API)

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

Flutter uses **Supabase** for user authentication. Supabase handles registration, login, session persistence, and token refresh. The rest of the app never imports the Supabase SDK directly — `LeafLensAuth` wraps it.

| Layer | Who | Token | Flows |
|-------|-----|-------|-------|
| App user | Flutter → Supabase | Supabase JWT (auto-refreshed) | register / login / logout |
| FastAPI proxy | Flutter → FastAPI → ThingsBoard | Supabase JWT (verified server-side) | Data fetch, RPC commands |
| ThingsBoard | FastAPI → ThingsBoard | TB tenant admin JWT | Proxy calls, never leaves server |
| ESP32 | ESP32 → ThingsBoard | TB device access token | MQTT only, provisioned once |

### LeafLensAuth (Supabase wrapper)

**File:** `lib/features/auth/data/leaf_lens_auth.dart`

Wraps `supabase_flutter` so no other file imports it directly. All methods are static.

```
LeafLensAuth.init(url, anonKey)          // Called once from main.dart
LeafLensAuth.signInWithPassword(...)     // Returns access token
LeafLensAuth.signUp(...)                 // Returns access token (or null if email confirmation required)
LeafLensAuth.signOut()                   // Clears session
LeafLensAuth.onAuthChange               // Stream<AuthState> — emits on login, logout, token refresh
LeafLensAuth.accessToken                // Current token, or null
```

### GoRouter Auth Guard

The auth guard is encapsulated in `lib/core/router/auth_guard.dart` and consumed by `AppRouter` (`lib/core/router/app_router.dart`). `AppRouter` is a class that owns the `GoRouter` instance:

```dart
// lib/core/router/app_router.dart
class AppRouter {
  final Ref _ref;
  AppRouter(this._ref);

  GoRouter get router => GoRouter(
        initialLocation: '/splash',
        routes: [/* route definitions */],
        redirect: (context, state) => _ref.read(authGuardProvider)(context, state),
      );
}

// lib/core/router/auth_guard.dart
final authGuardProvider = Provider<GoRouterRedirect>((ref) {
  final auth = ref.watch(authStateProvider);
  return (context, state) {
    final isLoggedIn = auth.value != null;
    final path = state.matchedLocation;
    if (path == '/splash') return null;
    if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
    if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
    return null;
  };
});
```

### Session Lifecycle

1. Login → `AuthRepository.login()` → calls `LeafLensAuth.signInWithPassword()` → Supabase returns JWT → token set on `ApiClient`
2. `authStateProvider` (StreamProvider) emits new token → GoRouter detects auth → redirects to `/dashboard`
3. App restart → Supabase restores session from its internal storage → `authStateProvider` emits current token automatically
4. Logout → `LeafLensAuth.signOut()` → stream emits null → GoRouter redirects to `/login`

### Build-time Configuration

Supabase credentials are injected at build time via
`--dart-define-from-file`. Copy `.env.example` to `.env` and fill in
your values:

```bash
cp .env.example .env
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

All four values (`API_URL`, `WS_URL`, `SUPABASE_URL`,
`SUPABASE_ANON_KEY`) are required — the app won't compile without
them. Same for `SENTRY_DSN` (optional).

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
