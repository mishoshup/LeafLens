# LeafLens — Frontend Design System & Screen Documentation

> **Project:** LeafLens — AI-Powered Plant Health Monitoring  
> **Stack:** Flutter (Material 3) + Riverpod (3.x) + GoRouter + freezed + json_serializable + flutter_svg  
> **Codegen:** freezed, json_serializable, riverpod_generator via build_runner  
> **Last updated:** 24 May 2026

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Design Tokens](#2-design-tokens)
   - 2.1 [Colors](#21-colors)
   - 2.2 [Typography](#22-typography)
   - 2.3 [Spacing & Radii](#23-spacing--radii)
3. [Architecture Pattern](#3-architecture-pattern)
4. [Screens](#4-screens)
   - 4.1 [Splash Screen](#41-splash-screen)
   - 4.2 [Login Page](#42-login-page)
5. [Navigation Flow](#5-navigation-flow)
6. [Asset Inventory](#6-asset-inventory)
7. [Conventions](#7-conventions)
8. [Shared Widgets](#8-shared-widgets)

---

## 1. Design Philosophy

### Color Philosophy
- **No pure blacks or whites.** `#FFFFFF` and `#000000` are never used directly. Off-white (`#F8F9FA`) and off-black (`#1A1A1A`) provide visual comfort and reduce eye strain.
- **Greens as brand anchors.** Deep green (`#083722`) for headings and emphasis; medium green (`#409761`) for primary actions and links.
- **Light backgrounds for functional screens** (login, sign-up, settings); **dark/green backgrounds for experiential screens** (splash, onboarding).

### Layout Philosophy
- **Responsive, not pixel-mapped.** Screens use `Center`, `SafeArea`, `SingleChildScrollView`, and `FractionallySizedBox` rather than absolute `Positioned` coordinates. The layout adapts to screen size without magic numbers.
- **Decorative SVGs are fractionally sized.** `BackgroundEllipse` defaults to 60% width × 50% height, anchored at `Alignment.bottomRight`. No hardcoded pixel positions.
- **Centered forms with scroll fallback.** Login and future forms use `Center` + `SingleChildScrollView` — content is vertically centered when short, scrollable when long.
- **Layer order:** The bottommost layer is the first child in the `Stack`; the topmost is the last child.

---

## 2. Design Tokens

### 2.1 Colors

All colors are defined in `lib/theme/app_colors.dart`.

```dart
class AppColors {
  // ── Off-whites / Off-blacks ──
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color offBlack = Color(0xFF1A1A1A);

  // ── Primary Greens ──
  static const Color lightGreenBg = Color(0xFFA3B88C);
  static const Color mediumGreen   = Color(0xFF409761);
  static const Color darkGreenText = Color(0xFF1B6F0A);
  static const Color deepGreen     = Color(0xFF083722);

  // ── Status / Alert ──
  static const Color redAlert   = Color(0xFFD05555);
  static const Color redDark    = Color(0xFF981C2B);
  static const Color redAccent  = Color(0xFFE33629);
  static const Color googleRed  = Color(0xFFEA4335);
  static const Color yellowAlert= Color(0xFFF8BD00);

  // ── Chart Colors ──
  static const Color chartCyan    = Color(0xFF319BC5);
  static const Color chartPurple  = Color(0xFFA031C5);
  static const Color chartMagenta = Color(0xFFC53178);
  static const Color chartGreen   = Color(0xFF319F43);
  static const Color chartBlue    = Color(0xFF587DBD);

  // ── Neutrals ──
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);
  static const Color darkCharcoal   = Color(0xFF202124);
  static const Color textDark       = Color(0xFF3C4043);
  static const Color textGrey       = Color(0xFF5F6368);
  static const Color darkGrey       = Color(0xFF444444);
  static const Color mediumGrey     = Color(0xFF757575);
  static const Color grey           = Color(0xFF828282);
  static const Color greyLight      = Color(0xFF838383);
  static const Color greyLighter    = Color(0xFFD9D9D9);
  static const Color borderLight    = Color(0xFFDADCE0);
  static const Color backgroundGrey = Color(0xFF333333);

  // ── Google Brand ──
  static const Color googleBlue   = Color(0xFF4285F4);
  static const Color googleGreen  = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
}
```

#### Color Usage Map

| Token | Used In | Role |
|-------|---------|------|
| `offWhite` | Login page bg | Screen background |
| `offBlack` | Google Sign-In button bg | High-contrast action |
| `deepGreen` | "Login" title, footer "Sign up" link | Brand heading emphasis |
| `mediumGreen` | "Login" CTA button | Primary action |
| `lightGreenBg` | Splash screen bg | Experiential brand colour |
| `white` | Text on dark backgrounds | Readability |

### 2.2 Typography

Defined per-screen via `GoogleFonts` extensions on `BuildContext`. No global `app_typography.dart` — each screen defines its own text styles in a file-private extension.

| Screen | Font | Weight | Size | Usage |
|--------|------|--------|------|-------|
| Splash | Inter Bold 700 | w700 | 28px | "LEAFLENS" title |
| Splash | Inter Bold 700 | w700 | 26px italic | Tagline |
| Splash | Inter ExtraBold 800 | w800 | 22px | "Get Started" button |
| Login | Poppins SemiBold 600 | w600 | 38px | "Login" title |
| Login | Poppins SemiBold 600 | w600 | 16px | Google button text |
| Login | Poppins SemiBold 600 | w600 | 20px | "Login" CTA button |
| Login | Lexend Light 300 | w300 | 16px | Footer muted text |
| Login | Lexend Bold 700 | w700 | 16px | Footer "Sign up" link |

**Note:** All alphas use `.withValues(alpha: ...)` (Flutter 3.27+), not the deprecated `.withOpacity()`.

### 2.3 Spacing & Radii

| Property | Value | Usage |
|----------|-------|-------|
| Input border radius | `5px` | Email, Password fields |
| Button border radius | `50px` (StadiumBorder) | CTA buttons, Google Sign-In |
| Card border radius | `25px` | Sensor cards (future) |
| Avatar border radius | `200px` | Circular profile (future) |
| Input padding horizontal | `14px` | Text inset |
| Button padding | ~16–18px vertical | Touch target |
| Form horizontal padding | `24px` | SingleChildScrollView padding |

---

## 3. Architecture Pattern

### File Structure

```
lib/
├── main.dart                       # App entry
├── app.dart                        # MaterialApp.router with GoRouter
├── app.g.dart                      # Generated (riverpod_generator — router provider)
├── core/
│   ├── config/
│   │   └── app_config.dart         # API URLs, Hive box names
│   ├── network/
│   │   ├── api_client.dart         # HTTP client for FastAPI
│   │   └── ws_client.dart          # WebSocket client
│   └── errors/
│       └── failures.dart           # Typed exception classes
├── features/
│   ├── auth/
│   │   └── data/
│   │       ├── auth_repository.dart       # AuthRepository + @riverpod providers
│   │       ├── auth_repository.g.dart     # Generated (riverpod_generator)
│   │       ├── login_response.dart        # @JsonSerializable token model
│   │       └── login_response.g.dart      # Generated (json_serializable)
│   └── dashboard/
│       ├── data/
│       │   ├── dashboard_providers.dart   # DashboardRepository + @riverpod providers
│       │   └── dashboard_providers.g.dart # Generated (riverpod_generator)
│       └── domain/
│           ├── dashboard_update.dart       # @freezed sealed union for WS messages
│           ├── dashboard_update.freezed.dart
│           └── dashboard_update.g.dart
├── shared/
│   └── widgets/
│       ├── app_text_field.dart        # Reusable text input
│       ├── background_ellipse.dart    # Decorative SVG wrapper
│       └── leaf_lens_logo.dart        # Brand logo (leaf illustration)
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   └── login/
│       └── login_page.dart
└── theme/
    ├── app_colors.dart             # All colour tokens
    └── app_theme.dart              # Material 3 ThemeData wiring
```

### Code Generation Workflow

After adding/editing `@freezed`, `@JsonSerializable`, or `@riverpod` annotations:

```bash
dart run build_runner build
```

Generated files (`.g.dart` and `.freezed.dart`) are committed to the repo — no `.gitignore` entry for them. If a merge conflict occurs, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Note: `go_router_builder` is in pubspec.yaml but routes are still hand-written (3 flat routes don't justify codegen). When the route tree grows, convert to `@TypedGoRoute` annotations.

### Screen Rendering Pattern (current)

Every screen follows a responsive layout:

```dart
class ExampleScreen extends ConsumerStatefulWidget {
  const ExampleScreen({super.key});

  @override
  ConsumerState<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends ConsumerState<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // children use Center wrapper for non-stretching content
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- **`SafeArea`** — avoids notches and home indicators
- **`Center`** — vertically centres content when shorter than viewport
- **`SingleChildScrollView`** — scrolls when content overflows the screen
- **`Column` with `CrossAxisAlignment.stretch`** — full-width children; wrap individual items in `Center` if they shouldn't stretch

### Why not Stack + Positioned?

The earlier build used absolute `LayoutBuilder` + scale factor mapping from Figma. This was replaced because:

| Aspect | Old (Stack + Positioned) | Current (responsive) |
|--------|-------------------------|----------------------|
| **Layout** | Absolute coordinates per device | Flex, auto-margin, proportional |
| **Maintenance** | Every Figma change required recalculating positions | Minimal diff — spacing handled by Column |
| **Scroll** | Not scrollable by default | Automatic via SingleChildScrollView |
| **Orientation** | Broke on landscape / tablet | Adapts naturally |

Exception: decorative backgrounds (`BackgroundEllipse`) still use `Align` inside a `Stack` because they sit behind the safe area and need fractional positioning.

---

## 4. Screens

### 4.1 Splash Screen

**File:** `lib/screens/splash/splash_screen.dart`  
**Route:** `/` (home)  
**State:** `StatelessWidget`  
**Navigation:** Tap "Get Started" → `/login` via GoRouter

#### Layer Map (bottom → top)

| Layer | Element | Type | Layout |
|-------|---------|------|--------|
| 1 | Green background | `Scaffold(backgroundColor: lightGreenBg)` | Full screen |
| 2 | Decorative SVG ellipse | `BackgroundEllipse()` — 60% × 50%, bottomRight | Behind everything |
| 3 | Leaf logo | `LeafLensLogo()` — 157×203 SVG | SafeArea, centered |
| 4 | "LEAFLENS" + tagline | `Text` (Inter Bold 28px, white) | Below logo |
| 5 | "Get Started" button | `FilledButton` with `StadiumBorder` | Bottom of column |

#### Widget Structure

```
Scaffold(lightGreenBg)
└── Stack
    ├── SafeArea → BackgroundEllipse (decorative ellipse, bottom-right)
    └── SafeArea → _SplashContent
        └── Center → Column
            ├── SizedBox(height: 80)       // top breathing room
            ├── LeafLensLogo()
            ├── SizedBox(height: 12)
            ├── _BrandHeader               // "LEAFLENS" + tagline
            ├── SizedBox(height: 48)
            └── _GetStartedButton
```

#### Assets Used

| Asset | Path | Notes |
|-------|------|-------|
| Decorative ellipse SVG | `assets/images/splash_ellipse.svg` | Wrapped in `BackgroundEllipse` |
| Leaf illustration SVG | `assets/images/splash_illustration.svg` | Used in `LeafLensLogo` widget |

#### Button Style

- `FilledButton` with `StadiumBorder()`
- Background: `colorScheme.primary` at 70% opacity
- Text: Inter ExtraBold 22px, white at 90% opacity
- Full-width via `SizedBox(width: double.infinity)`

---

### 4.2 Login Page

**File:** `lib/screens/login/login_page.dart`  
**Route:** `/login`  
**State:** `ConsumerStatefulWidget` with Riverpod  
**Auth:** `AuthRepository.login()` → invalidates `authStateProvider` → redirect to `/dashboard`

#### Layout

```
Scaffold(offWhite)
└── SafeArea
    └── Center
        └── Form
            └── SingleChildScrollView(padding: 24px horizontal)
                └── Column(Center, CrossAxisAlignment.stretch)
                    ├── Center → _LoginHeader          // "Login" title
                    ├── _GoogleSignInButton             // Full-width pill with icon
                    ├── _OrDivider                      // "Or continue with Email"
                    ├── _EmailField
                    ├── SizedBox(height: 12)
                    ├── _PasswordField (with visibility toggle)
                    ├── SizedBox(height: 28)
                    ├── _LoginButton (with loading spinner)
                    ├── SizedBox(height: 12)
                    └── _SignUpRow                      // "Don't have an account? Sign up"
```

#### Input Fields (`AppTextField`)

- Defined in `lib/shared/widgets/app_text_field.dart`
- Border radius: `5px`
- Validates via `FormState.validate()`
- Password field has toggleable obscurity via `suffixIcon`

#### Login CTA Button

- `FilledButton` with `StadiumBorder()`
- Background: `mediumGreen` (`#409761`)
- Text: Poppins SemiBold 20px, white
- Shows `CircularProgressIndicator` when `loading` is true

#### Error Handling

- Catches `AuthRepository.login()` exceptions
- Displays error via `ScaffoldMessenger.showSnackBar` with red background
- Button re-enabled in `finally` block

#### Unimplemented Handlers

- Google sign-in: `throw UnimplementedError('Google sign-in')`
- "Sign up" link: `throw UnimplementedError('Sign up')`

---

## 5. Navigation Flow

```
App Launch
    │
    ▼
┌──────────────┐       GoRouter
│ SplashScreen │  ── tap "Get Started" ──→  /login
│ (route: /)   │
└──────────────┘
                     ┌──────────────┐
                     │  LoginPage   │
                     │ (route: /login)
                     │              │
                     │ [Login]  ──→ /dashboard (on success)
                     │ [Sign up] ──→ throw UnimplementedError
                     └──────────────┘
```

- Back navigation uses GoRouter's default pop (back gesture/button).
- Auth redirect: after successful login, `authStateProvider` is invalidated, and GoRouter redirect logic (defined in `core/router.dart`) navigates to `/dashboard`.
- Productive auth check redirects to `/login` if `authStateProvider` is `unauthenticated`.

---

## 6. Asset Inventory

| File | Type | Source | Used By |
|------|------|--------|---------|
| `assets/images/splash_ellipse.svg` | Vector | Figma export | `BackgroundEllipse` (splash) |
| `assets/images/splash_illustration.svg` | Vector | Figma export | `LeafLensLogo` |
| `assets/images/google_logo.svg` | Vector | Manual | Login Google Sign-In button |

---

## 7. Conventions

### Naming
- **Files:** `snake_case` (e.g., `splash_screen.dart`, `app_colors.dart`)
- **Classes:** `PascalCase` (e.g., `SplashScreen`, `LoginPage`, `AppColors`)
- **Private widgets:** `_PascalCase` prefixed with underscore (e.g., `_LoginHeader`)
- **Private extensions:** file-private `extension on BuildContext` (not global)
- **Controllers:** `_emailCtrl`, `_passwordCtrl` (Ctrl suffix, not Controller)

### Imports
- Dart/Flutter SDK first (`dart:convert`, `package:flutter/...`)
- Third-party packages second (`package:flutter_riverpod/...`, `package:go_router/...`)
- Project imports last, grouped by feature (`package:leaflens/theme/...`, `package:leaflens/features/...`)

### Theming
- **Colours** come from `AppColors` only — never hardcode hex values in widgets
- **Typography** uses `GoogleFonts.*()` via file-private `extension on BuildContext` getters
- **Alphas** use `.withValues(alpha: ...)` (Flutter 3.27+), never `.withOpacity()`
- **Radii** use `StadiumBorder` for pills, not `RoundedRectangleBorder` with magic radius

### State Management
- **Riverpod 3.x** (`flutter_riverpod` 3.2.1 + `riverpod_annotation` 4.0.2) for all state
- Providers generated via `@riverpod` annotation + `riverpod_generator` — see `auth_repository.g.dart`, `dashboard_providers.g.dart`, `app.g.dart`
- `ConsumerStatefulWidget` for screens with controllers and form state
- `ref.invalidate()` after auth mutations to trigger redirects
- No `setState` for global state — only local UI state (loading, obscure toggles)
- **AsyncValue API change (v3):** `valueOrNull` is now `value`. `auth.value` returns `null` when loading/error, the value when data. Use `auth.value` for nullable access, `auth.requireValue` if you're sure the data is present.
- **Build workflow:** `dart run build_runner build` after adding/editing `@riverpod` annotations. Generated files (`.g.dart`) are committed.

### Widget Decomposition
- **Per-screen private widgets** for rebuild boundaries (e.g., `_LoginHeader`, `_EmailField`)
- **Explicit spacing** via `SizedBox(height: ...)` over `Spacer(flex: ...)`
- **`const` constructors** everywhere — constructor params passed explicitly, not inherited

### Error Handling
- `throw UnimplementedError('message')` for not-yet-wired interactions — never empty `(){}`
- SnackBar for user-visible errors
- `mounted` checks after async gaps before `setState` or navigation

---

## 8. Shared Widgets

Located in `lib/shared/widgets/`.

### `AppTextField`
Reusable text input with label, validation, password toggle support.
```
AppTextField(
  controller: _emailCtrl,
  label: 'Email',
  keyboardType: TextInputType.emailAddress,
  validator: (v) => v.isEmpty ? 'Enter your email' : null,
)
```

### `BackgroundEllipse`
Decorative SVG with fractional sizing and configurable alignment.
```
BackgroundEllipse(                    // defaults
  widthFactor: 0.6,                   // 60% of parent width
  heightFactor: 0.5,                  // 50% of parent height
  alignment: Alignment.bottomRight,   // anchor corner
  fit: BoxFit.contain,                // scale behaviour
)
```

### `LeafLensLogo`
Brand logo — the leaf illustration SVG. Used on splash screen above the title.
```
const LeafLensLogo()  // defaults to 156×202
```

---

*Documentation generated from Flutter source code. Updated 23 May 2026.*
