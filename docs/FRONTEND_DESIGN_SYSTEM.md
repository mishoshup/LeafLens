# LeafLens — Frontend Design System & Project Documentation

> **Project:** LeafLens — AI-Powered Plant Health Monitoring  
> **Stack:** Flutter (Material 3) + Riverpod (3.x) + GoRouter + freezed + json_serializable + flutter_svg  
> **Codegen:** freezed, json_serializable, riverpod_generator via build_runner  
> **Architecture:** ESP32 → ThingsBoard → FastAPI → Flutter (BLE-provisioned)  
> **Last updated:** 24 May 2026

---

## Table of Contents

1. [Design Tokens](#1-design-tokens)
   - 1.1 [Colors](#11-colors)
   - 1.2 [Typography](#12-typography)
2. [Architecture Pattern](#2-architecture-pattern)
3. [Screens](#3-screens)
   - 3.1 [Splash Screen](#31-splash-screen)
   - 3.2 [Login Page](#32-login-page)
4. [Navigation Flow](#4-navigation-flow)
5. [Asset Inventory](#5-asset-inventory)
6. [Conventions](#6-conventions)
7. [Shared Widgets](#7-shared-widgets)

---

## 1. Design Tokens

### 1.1 Colors

All defined in `lib/theme/app_colors.dart`. No hardcoded hex in widgets.

| Token | Hex | Usage |
|-------|-----|-------|
| `offWhite` | `#F8F9FA` | Screen backgrounds |
| `offBlack` | `#1A1A1A` | Google button bg, text on light |
| `lightGreenBg` | `#A3B88C` | Splash screen background |
| `mediumGreen` | `#409761` | Primary actions, links |
| `deepGreen` | `#083722` | Headings, brand emphasis |
| `white` | `#FFFFFF` | Text on dark backgrounds |
| `redAlert` | `#D05555` | Error states |

Full list in `lib/theme/app_colors.dart`.

### 1.2 Typography

**Single font: Lexend** (variable weight, embedded in binary via pubspec.yaml). No `google_fonts` dependency.

| Weight | UI Role |
|--------|---------|
| Light 300 | Muted footer, graph labels |
| Regular 400 | Body text, sensor descriptions |
| Medium 500 | Form input labels |
| SemiBold 600 | Screen titles, button text |
| Bold 700 | Card titles, section headers |
| ExtraBold 800 | GHS gauge score, sensor values |

All tokenized in `lib/theme/app_typography.dart`. Per-screen custom styles use file-private `extension on BuildContext` with plain `const TextStyle` — never `GoogleFonts.*()`.

---

## 2. Architecture Pattern

### File Structure

```
lib/
├── main.dart                       # App entry
├── app.dart                        # MaterialApp.router with GoRouter
├── core/
│   ├── config/app_config.dart     # API URLs, Hive box names
│   ├── network/
│   │   ├── api_client.dart        # HTTP client for FastAPI
│   │   └── ws_client.dart         # WebSocket client
│   └── errors/
│       ├── failures.dart           # Typed exception classes
│       └── error_handler.dart      # 3-tier: toast + Sentry + metrics
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart       # AuthRepository + @riverpod providers
│   │   │   └── login_response.dart        # @JsonSerializable token model
│   │   └── domain/auth_state.dart         # Sealed class
│   └── dashboard/
│       ├── data/dashboard_providers.dart   # DashRepo + @riverpod providers
│       └── domain/
│           ├── dashboard_update.dart       # @freezed sealed union
│           ├── growth_health_score.dart    # GHS algorithm
│           ├── sensor_key.dart
│           ├── sensor_reading.dart
│           └── water_system_state.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── leaf_lens_auth.dart
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       └── signup_page.dart
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── dashboard_providers.dart
│   │   ├── domain/
│   │   │   ├── dashboard_update.dart
│   │   │   ├── growth_health_score.dart    # GHS algorithm
│   │   │   ├── sensor_key.dart
│   │   │   ├── sensor_reading.dart
│   │   │   └── water_system_state.dart
│   │   └── presentation/
│   │       └── dashboard_screen.dart
│   └── splash/
│       └── presentation/
│           └── splash_screen.dart
├── shared/
│   ├── widgets/
│       ├── app_text_field.dart
│       ├── app_button.dart
│       ├── background_ellipse.dart
│       ├── leaf_lens_logo.dart
│       ├── health_gauge.dart
│       ├── sensor_tile.dart
│       ├── status_badge.dart
│       ├── sensor_error_boundary.dart
│       └── offline_banner.dart
│   └── notifications/
│       ├── notification_service.dart  # Toastification wrapper
│       └── app_dialog.dart            # Modal dialog utility
└── theme/
    ├── app_colors.dart
    ├── app_typography.dart
    └── app_theme.dart
```

Generated files (`.g.dart` and `.freezed.dart`) are committed to the repo.

---

## 3. Screens

### 3.1 Splash Screen

**File:** `lib/features/splash/presentation/splash_screen.dart`  
**Route:** `/splash`  
**State:** `StatelessWidget`

| Layer | Element | Layout |
|-------|---------|--------|
| 1 | Green background | `Scaffold(backgroundColor: lightGreenBg)` |
| 2 | Decorative SVG | `BackgroundEllipse()` — 90% × 90%, bottomRight |
| 3 | Leaf logo | `LeafLensLogo()` |
| 4 | "LEAFLENS" + tagline | `Text` (SemiBold 28px, white) |
| 5 | "Get Started" button | `FilledButton` with `StadiumBorder` |

### 3.2 Login Page

**File:** `lib/features/auth/presentation/login_page.dart`  
**Route:** `/login`  
**State:** `ConsumerStatefulWidget`

- Email + Password form with validation
- Google Sign-In button (stub)
- Loading state + inline error on wrong credentials
- "Sign up" link navigates to `/signup`

---

## 4. Navigation Flow

```
/splash  ── "Get Started" ──→  /login
/login   ── "Sign up"  ──→     /signup
/signup  ── "Login" ──→       /login
/login   ── Login success ──→ /dashboard
```

GoRouter redirect guard:

```dart
if (path == '/splash') return null;
if (!isLoggedIn && notPublicRoute) return '/login';
if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
```

---

## 5. Asset Inventory

| File | Used By |
|------|---------|
| `assets/images/splash_ellipse.svg` | `BackgroundEllipse` (splash) |
| `assets/images/splash_illustration.svg` | `LeafLensLogo` |
| `assets/images/google_logo.svg` | Google Sign-In buttons |

---

## 6. Conventions

### Naming
- Files: `snake_case`
- Classes: `PascalCase`
- Private widgets: `_PascalCase`
- Private extensions: file-private `extension on BuildContext`

### Code Style
- Comments explain WHY, not WHAT
- No decorative comment blocks
- `const` constructors everywhere
- `StadiumBorder()` for pills, not `RoundedRectangleBorder`
- `.withValues(alpha:)`, never `.withOpacity()`

### State Management
- Riverpod 3.x with `@riverpod` codegen
- `ConsumerStatefulWidget` for screens with forms
- `ref.invalidate()` after auth mutations
- `mounted` checks after async gaps
- `throw UnimplementedError('message')` for stubs — never empty `() {}`

### Theming
- Colours from `AppColors` only
- Typography tokens from `AppTypography`

---

## 7. Shared Widgets

| Widget | Props | States |
|--------|-------|--------|
| `AppTextField` | hint, obscureText, controller, validator, keyboardType, icons | Normal, error |
| `AppButton` | label, onPressed, variant (4), loading, icon, width | Normal, disabled, loading |
| `BackgroundEllipse` | assetPath, widthFactor, heightFactor, alignment, fit | — |
| `LeafLensLogo` | — | SVG render |
| `HealthGauge` | HealthScoreResult, size | All 5 status colours |
| `SensorTile` | SensorKey, SensorReading? | Normal, skeleton, stale |
| `StatusBadge` | HealthStatus | All 5 status colours |
| `SensorErrorBoundary` | label, child | Normal, error + retry |
| `OfflineBanner` | (watches authStateProvider) | Hidden, shown |
