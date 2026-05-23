# LeafLens Project Structure

```
leaflens/
├── lib/
│   ├── main.dart                       # Entry point
│   ├── app.dart                        # MaterialApp.router + GoRouter
│   ├── app.g.dart                      # Generated (riverpod_generator)
│   │
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart         # API_URL (env), staleThreshold, Hive box name
│   │   ├── network/
│   │   │   ├── api_client.dart         # HTTP client → FastAPI
│   │   │   └── ws_client.dart          # WebSocket client → FastAPI
│   │   └── errors/
│   │       └── failures.dart           # Typed exception classes
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart     # AuthRepository + @riverpod providers
│   │   │   │   ├── auth_repository.g.dart   # Generated
│   │   │   │   ├── login_response.dart      # @JsonSerializable JWT model
│   │   │   │   └── login_response.g.dart    # Generated
│   │   │   └── domain/
│   │   │       └── auth_state.dart          # Sealed: AuthInitial/Loading/Authenticated/Failure
│   │   └── dashboard/
│   │       ├── data/
│   │       │   ├── dashboard_providers.dart # DashRepo + @riverpod providers
│   │       │   └── dashboard_providers.g.dart
│   │       └── domain/
│   │           ├── dashboard_update.dart     # @freezed sealed union (WS payloads)
│   │           ├── dashboard_update.freezed.dart
│   │           ├── dashboard_update.g.dart
│   │           ├── growth_health_score.dart  # GHS algorithm (pure domain logic)
│   │           ├── sensor_key.dart           # Enum with tbKey + unit
│   │           ├── sensor_reading.dart       # Data model + staleness + JSON factory
│   │           └── water_system_state.dart   # Pump/mist/refill model
│   │
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart        # StatelessWidget
│   │   ├── login/
│   │   │   └── login_page.dart           # ConsumerStatefulWidget
│   │   └── signup/
│   │       └── signup_page.dart          # ConsumerStatefulWidget
│   │
│   ├── shared/
│   │   └── widgets/
│   │       ├── app_text_field.dart        # Themed text input
│   │       ├── app_button.dart            # 4 variants + loading
│   │       ├── background_ellipse.dart    # Configurable SVG decoration
│   │       ├── leaf_lens_logo.dart        # Brand SVG
│   │       ├── health_gauge.dart          # Circular gauge (CustomPaint)
│   │       ├── sensor_tile.dart           # Value + skeleton + stale indicator
│   │       ├── status_badge.dart          # Colored chip
│   │       ├── sensor_error_boundary.dart # Per-widget error handling
│   │       └── offline_banner.dart        # Connectivity indicator
│   │
│   └── theme/
│       ├── app_colors.dart              # All colour tokens
│       ├── app_typography.dart          # Typography tokens (Lexend weights)
│       └── app_theme.dart              # Material3 ThemeData
│
├── test/
│   ├── unit/
│   │   └── growth_health_score_test.dart   # 24 tests
│   ├── widgets/
│   │   ├── shared/                         # 9 files, 47 tests
│   │   ├── screens/                        # 4 files, 20 tests (2 skipped)
│   │   └── flows/
│   │       └── navigation_test.dart         # 5 tests
│   └── helpers/
│       └── test_asset_bundle.dart          # Mock SVG for flutter_svg
│
├── docs/
│   ├── ARCHITECTURE.md                  # System architecture
│   ├── PROJECT_STRUCTURE.md             # This file
│   ├── SCREENS_AND_NAVIGATION.md        # Routes and screens
│   ├── WIDGET_LIBRARY.md                # Shared widget reference
│   ├── DOMAIN_MODELS.md                 # Data models + GHS algorithm
│   ├── TESTING.md                       # Test patterns
│   └── CONVENTIONS.md                   # Code style and practices
│
├── assets/
│   └── images/
│       ├── splash_ellipse.svg
│       ├── splash_illustration.svg
│       └── google_logo.svg
│
├── pubspec.yaml
├── README.md
└── analysis_options.yaml
```

---

## Where to put code

| Type | Location | Example |
|------|----------|---------|
| Screen UI | `lib/screens/{screen_name}/` | `lib/screens/login/login_page.dart` |
| Shared widget | `lib/shared/widgets/` | `lib/shared/widgets/app_text_field.dart` |
| Feature data | `lib/features/{name}/data/` | `lib/features/auth/data/auth_repository.dart` |
| Domain logic | `lib/features/{name}/domain/` | `lib/features/dashboard/domain/growth_health_score.dart` |
| Theme token | `lib/theme/` | `lib/theme/app_colors.dart` |
| Network client | `lib/core/network/` | `lib/core/network/api_client.dart` |
| Test | `test/{unit,widgets}/{subdir}/` | `test/widgets/shared/app_button_test.dart` |

---

## Code Generator

This project uses Riverpod codegen, Freezed, and JsonSerializable. Generated files are **committed to git**.

### When to run

```bash
dart run build_runner build
```

After adding/editing any file with `@riverpod`, `@freezed`, or `@JsonSerializable`.

### Package coordination

All codegen packages must be upgraded as a set — never one at a time:

| Package | Version | Role |
|---------|---------|------|
| `flutter_riverpod` | 3.2.1 | Runtime |
| `riverpod_annotation` | ^4.0.2 | Annotations |
| `riverpod_generator` | ^4.0.3 | Codegen (dev) |
| `freezed_annotation` | ^3.1.0 | Sealed unions |
| `freezed` | ^3.2.5 | Codegen (dev) |
| `json_annotation` | ^4.12.0 | JSON |
| `json_serializable` | ^6.14.0 | Codegen (dev) |
| `build_runner` | ^2.15.0 | Runner (dev) |
