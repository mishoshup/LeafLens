# LeafLens Widget Library

All shared widgets in `lib/shared/widgets/`.

---

## AppTextField

Themed outlined input with floating label. Used in login and signup forms.

```dart
AppTextField({
  String? hint,                          // Label text, floats on focus
  bool obscureText = false,              // Password mode
  TextEditingController? controller,     // External controller
  String? Function(String?)? validator,  // Form validation
  TextInputType keyboardType = TextInputType.text,
  Widget? prefixIcon,                    // Left icon
  Widget? suffixIcon,                    // Right icon (e.g. visibility toggle)
})
```

**States:** Normal, focused, validation error.

---

## AppButton

Styled button with 4 variants and loading state.

```dart
enum AppButtonVariant { primary, secondary, outline, text }

AppButton({
  required String label,
  VoidCallback? onPressed,               // null = disabled
  AppButtonVariant variant = AppButtonVariant.primary,
  IconData? icon,
  bool loading = false,                  // shows spinner, disables
  double? width,                         // fixed width if needed
})
```

| Variant | Widget | Usage |
|---------|--------|-------|
| `primary` | `FilledButton` | Main CTA (Login, Sign Up) |
| `secondary` | `FilledButton.tonal` | Google sign-in |
| `outline` | `OutlinedButton` | Secondary actions |
| `text` | `TextButton` | Tertiary actions |

**States:** Normal, disabled (onPressed null), loading (spinner).

---

## BackgroundEllipse

Decorative SVG with fractional sizing. Used behind splash screen content.

```dart
BackgroundEllipse({
  String assetPath = 'assets/images/splash_ellipse.svg',
  double widthFactor = 0.9,              // % of parent width
  double heightFactor = 0.9,             // % of parent height
  Alignment alignment = Alignment.bottomRight,
  BoxFit fit = BoxFit.contain,
})
```

Must be placed **without** `SafeArea` — decorative elements need to bleed to screen edge.

---

## LeafLensLogo

Brand logo — leaf illustration SVG.

```dart
const LeafLensLogo()
```

Renders `assets/images/splash_illustration.svg` at natural size.

---

## HealthGauge

Circular gauge showing the Growth Health Score with colour-coded arc. Green → yellow → red as score drops.

```dart
HealthGauge({
  required HealthScoreResult result,     // score + status + componentScores
  double size = 200,                     // width and height
})
```

| Score | Status | Arc Colour |
|-------|--------|------------|
| ≥ 80 | Optimal | `#4CAF50` (green) |
| ≥ 65 | Moderate | `#8BC34A` (light green) |
| ≥ 50 | Caution | `#FFC107` (yellow) |
| ≥ 30 | Danger | `#FF9800` (orange) |
| < 30 | Critical | `theme.colorScheme.error` (red) |

Implementation uses `CustomPaint` with `_RingPainter` — background circle + score arc.

---

## SensorTile

Displays a single sensor value with label, unit, and stale indicator.

```dart
SensorTile({
  required SensorKey sensor,             // defines name + unit
  SensorReading? reading,               // null → skeleton placeholder
})
```

**States:**
- **Skeleton** (reading is null) — grey placeholder bars, no text
- **Normal** — sensor name, value, unit, age label
- **Stale** (reading older than 30 min) — warning icon + error colour value

---

## StatusBadge

Coloured chip showing health status at a glance.

```dart
StatusBadge({
  required HealthStatus status,
})
```

| Status | Label | Dot Colour |
|--------|-------|------------|
| `optimal` | "Optimal" | `#4CAF50` |
| `moderate` | "Moderate" | `#8BC34A` |
| `caution` | "Caution" | `#FFC107` |
| `danger` | "Danger" | `#FF9800` |
| `critical` | "Critical" | `theme.colorScheme.error` |

---

## SensorErrorBoundary

Catches build errors in a single sensor widget and shows a fallback instead of crashing the whole dashboard.

```dart
SensorErrorBoundary({
  required String label,                 // "Temperature", "Humidity", etc.
  required Widget child,                 // the sensor widget to guard
})
```

**States:**
- **Normal** — renders `child` transparently
- **Error** — shows "Temperature unavailable" with icon + Retry button

---

## OfflineBanner

Connectivity indicator that watches `authStateProvider`. Shown when user is unauthenticated (no connection to backend).

```dart
const OfflineBanner()
```

**States:**
- **Authenticated** — `SizedBox.shrink()` (hidden)
- **Unauthenticated** — `MaterialBanner` with cloud_off icon + "No connection" message
