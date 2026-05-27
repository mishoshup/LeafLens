# LeafLens Screens & Navigation

**Routes defined in:** `lib/app.dart`

---

## Route Map

| Route | Screen | Widget Type | Status |
|-------|--------|-------------|--------|
| `/splash` | SplashScreen | `StatelessWidget` | ✅ Done |
| `/login` | LoginPage | `ConsumerStatefulWidget` | ✅ Done |
| `/signup` | SignUpPage | `ConsumerStatefulWidget` | ✅ Done |
| `/dashboard` | DashboardScreen | `ConsumerWidget` | ⏳ Placeholder |

---

## SplashScreen

**File:** `lib/screens/splash/splash_screen.dart`

The first screen users see. Purely decorative — no auth logic, no state.

### Layout (bottom → top)

```
Scaffold(lightGreenBg)
└── Stack
    ├── BackgroundEllipse()          ← decorative SVG, edge-to-edge, no SafeArea
    └── SafeArea
        └── _SplashContent
            └── Center → Column
                ├── Spacer(flex: 4)
                ├── LeafLensLogo()
                ├── SizedBox(height: 12)
                ├── _BrandHeader     ← "LEAFLENS" + "Smarter Care for Healthier Plants"
                ├── Spacer(flex: 2)
                ├── _GetStartedButton  ← navigates to /login
                └── Spacer(flex: 1)
```

### Key Points

- Decorative ellipse (`BackgroundEllipse`) is **not** in `SafeArea` — needs to bleed to screen edge on notched devices
- No GoRouter redirect logic checks splash — it's always public
- `LeafLensLogo` renders `assets/images/splash_illustration.svg`
- `BackgroundEllipse` renders `assets/images/splash_ellipse.svg`

---

## LoginPage

**File:** `lib/screens/login/login_page.dart`

Email/password authentication form. Talks to FastAPI through `AuthRepository`.

### Layout

```
Scaffold(offWhite)
└── SafeArea
    └── Center
        └── Form
            └── SingleChildScrollView
                └── Column(CrossAxisAlignment.stretch)
                    ├── Center → _LoginHeader      ← "Login" (38px SemiBold)
                    ├── _GoogleSignInButton        ← stub (UnimplementedError)
                    ├── _OrDivider                 ← "Or continue with Email"
                    ├── _EmailField                ← AppTextField with email validation
                    ├── SizedBox(height: 12)
                    ├── _PasswordField             ← AppTextField with visibility toggle
                    ├── SizedBox(height: 28)
                    ├── _LoginButton               ← loading spinner when submitting
                    ├── SizedBox(height: 12)
                    └── _SignUpRow                 ← "Don't have an account? Sign up"
```

### State

| Variable | Type | Purpose |
|----------|------|---------|
| `_formKey` | `GlobalKey<FormState>` | Form validation |
| `_emailCtrl` | `TextEditingController` | Email input |
| `_passwordCtrl` | `TextEditingController` | Password input |
| `_obscurePassword` | `bool` | Password visibility toggle |
| `_loading` | `bool` | Button spinner state |
| `_formError` | `String?` | Inline error message (wrong credentials) |

### Flow

1. User taps "Login"
2. Form validates (empty fields show errors)
3. `AuthRepository.login(email, password)` called
4. On success: `authStateProvider` invalidated → GoRouter redirects to `/dashboard`
5. On `InvalidCredentialsFailure`: inline red text above the button
6. On other `Failure`: `ErrorHandler.handle()` → top-of-screen toast + Sentry + metrics
7. Button re-enabled in `finally` block (`mounted`-safe)

---

## SignUpPage

**File:** `lib/screens/signup/signup_page.dart`

Registration form with name, email, phone, password, and terms acceptance.

### Layout

```
Same pattern as LoginPage with:
├── Center → _SignUpHeader          ← "Sign up" (30px SemiBold)
├── _GoogleSignUpButton            ← stub (UnimplementedError)
├── _OrDivider
├── _NameField                     ← AppTextField
├── _EmailField                    ← AppTextField
├── _PhoneField                    ← AppTextField
├── _PasswordField                 ← AppTextField
├── _TermsCheckbox                 ← Checkbox with RichText
├── _SignUpButton                  ← loading spinner
└── _LoginRow                      ← "Already have an account? Login"
```

### Extra State

| Variable | Type | Purpose |
|----------|------|---------|
| `_nameCtrl` | `TextEditingController` | Full name |
| `_phoneCtrl` | `TextEditingController` | Phone number |
| `_agreeToTerms` | `bool` | Terms checkbox |
| `_formError` | `String?` | Inline error message (duplicate email) |
| `_termsError` | `String?` | Inline error below checkbox (terms not accepted) |

### Flow

Same as login but calls `AuthRepository.register()` instead. Terms checkbox must be checked before submission — shows inline red text below the checkbox if skipped.

---

## DashboardScreen (Placeholder)

**File:** `lib/app.dart`

Currently renders "Dashboard — next build". Will contain:

- `HealthGauge` — circular score indicator with colour-coded arc
- 4× `SensorTile` — moisture, temperature, humidity, water level
- Quick action row — Water Now, Mist Now, Refill
- `OfflineBanner` — shows when WebSocket disconnects

---

## Navigation

GoRouter with auth redirect (defined in `lib/app.dart`):

```dart
redirect: (context, state) {
  final isLoggedIn = auth.value != null;
  final path = state.matchedLocation;

  if (path == '/splash') return null;                       // splash always public
  if (!isLoggedIn && path != '/login' && path != '/signup') return '/login';
  if (isLoggedIn && (path == '/login' || path == '/signup')) return '/dashboard';
  return null;
}
```

### Rules

| Current Route | Auth State | Redirect |
|---------------|------------|----------|
| `/splash` | Any | None (stay on splash) |
| Any (not login/signup/splash) | Unauthenticated | → `/login` |
| `/login` or `/signup` | Authenticated | → `/dashboard` |
| All other routes | Authenticated | None |
