# LeafLens Coding Conventions

---

## Analysis & Linting

### Package

We use [`very_good_analysis`](https://github.com/VeryGoodOpenSource/very_good_analysis) (v10.x) — the de facto industry-standard lint ruleset from Very Good Ventures (Google's top Flutter agency). ~200 rules covering style, docs, performance, null safety edge cases, and anti-patterns.

| Package | Rules | Strictness |
|---------|-------|-----------|
| `flutter_lints` | ~30 | Moderate — what `flutter create` gives you |
| `very_good_analysis` | ~200 | Strict — production-grade, examiners love it |

### Config (`analysis_options.yaml`)

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "build/**"
    - ".dart_tool/**"
    - "tools/**"
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

The analyzer already sets `strict-casts`, `strict-inference`, `strict-raw-types` — no need to re-declare.

Excluded directories prevent dartls from indexing 4GB+ of build artifacts.

### CLI Commands

| Command | Description |
|---------|------------------|
| `dart analyze` | Lint analysis (200+ rules) |
| `dart fix --apply` | Auto-fix what the fix engine can |
| `dart format .` | Format all Dart files |

### Key Rules Enforced

- `public_member_api_docs` — every public class, method, and field needs a `///` doc comment
- `avoid_print` — use a logging framework or remove before committing
- `require_trailing_commas` — trailing commas everywhere for cleaner diffs
- `prefer_const_constructors` / `prefer_const_declarations` — const wherever possible
- `lines_longer_than_80_chars` — hard limit at 80 columns
- `always_use_package_imports` — no relative `../` imports
- `omit_local_variable_types` — `var` over `final String x` when the type is obvious

Run `dart fix --apply` after major edits to auto-fix the majority of violations.

## Naming

| Thing | Convention | Example |
|-------|-----------|---------|
| Files | `snake_case` | `splash_screen.dart`, `app_colors.dart` |
| Classes | `PascalCase` | `SplashScreen`, `AuthRepository` |
| Private widgets | `_PascalCase` | `_LoginHeader`, `_EmailField` |
| Private extensions | `extension on BuildContext` (file-private) | No `library` declaration |
| Controllers | `Ctrl` suffix | `_emailCtrl`, `_passwordCtrl` |
| Providers | `Provider` suffix (from codegen) | `authStateProvider`, `authRepositoryProvider` |

---

## Code Style

### Comments

Comments explain **WHY**, not **WHAT**. The code already says what it does.

```dart
// GOOD — explains non-obvious intent
// 504 = device offline, command queued by TB. Not an error.
if (response.statusCode == 504) return {'queued': true};

// BAD — restating what the code does
// If the response status code is 504, it means the device is offline
// and the command has been queued by ThingsBoard.
```

Rules:
- No multi-sentence explanations for single lines
- No block comments before every class/method. `///` doc comments for public API surfaces only
- No paraphrasing what a method name already says
- `// TODO:` with context is fine if actionable

### Imports Order

1. Dart/Flutter SDK (`dart:convert`, `package:flutter/...`)
2. Third-party (`package:flutter_riverpod/...`, `package:go_router/...`)
3. Project (`package:leaflens/...`), grouped by feature

Blank line between groups.

---

## Widget Architecture

### Per-screen `extension on BuildContext`

File-private extensions for convenience getters. Scoped to one screen.

```dart
extension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextStyle get loginTitleStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 38,
    color: AppColors.deepGreen,
  );
}
```

Rules:
- `this` is the `BuildContext` — use `Theme.of(this)`, not `Theme.of(context)`
- Only include getters used by private widgets
- Do NOT put globally reusable styles here — those go in `app_typography.dart`

### Private widget decomposition

Extract by rebuild boundary, not by line count.

```dart
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
    );
  }
}
```

Rules:
- `const` constructors everywhere — every `const _Widget()` skips instantiation
- Pass only what each widget needs as constructor params
- Extract to `lib/shared/widgets/` at first cross-screen use

### Form layout pattern

```dart
Scaffold(
  body: SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: _Header()),     // centered
            _InputField(),                       // stretches
            _Button(),                           // stretches
            const Center(child: _Footer()),      // centered
          ],
        ),
      ),
    ),
  ),
)
```

- `Center` at Column children level, not inside the component
- Explicit `SizedBox` gaps over `Spacer(flex:)`
- `StadiumBorder()` for pills, not `RoundedRectangleBorder` with magic radius

---

## State Management

### Riverpod 3.x

- `@riverpod` annotation generates `.g.dart` via `riverpod_generator`
- `ConsumerStatefulWidget` for screens with forms and controllers
- `ConsumerWidget` for screens that just read state
- `ref.watch()` in widget tree, `ref.read()` in callbacks
- `ref.invalidate()` after auth mutations to trigger redirects

### AsyncValue API (v3 change)

| v2 API | v3 API |
|--------|--------|
| `auth.valueOrNull` | `auth.value` (returns `T?`) |
| `auth.requireValue` | Same (throws if not data) |

### Provider patterns

```dart
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.read(apiClientProvider));
}
```

### No setState for global state

`setState` only for local UI state (loading flag, obscure toggle). Global state goes in Riverpod providers.

---

## Error Handling

### Stubs

```dart
// GOOD — crashes fast, visible in testing
onPressed: () => throw UnimplementedError('Google sign-in'),

// BAD — silent no-op, passes review
onPressed: () {},
```

### User-visible errors

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(e.toString()), backgroundColor: cs.error),
);
```

### Async safety

```dart
if (mounted) setState(() => _loading = false);
```

Always check `mounted` after async gaps before `setState` or navigation.

---

## Theming

- **Colours** from `AppColors` only — never hardcode hex in widgets
- **Typography** tokens from `AppTypography` — per-screen overrides via file-private extension
- **Alpha** — `.withValues(alpha:)` (Flutter 3.27+), never `.withOpacity()`
- **Design tokens** — use the token directly. `AppColors.offWhite` not `Colors.white.withValues(alpha: 0.9)`. If a token already matches the visual intent, use it with no alpha manipulation.

---

## Build Workflow

```bash
# Before committing
dart analyze                    # very_good_analysis, 200+ rules
dart fix --apply                # auto-fix what the fix engine can
dart format .                   # format all Dart files
dart run build_runner build     # if annotations changed
flutter test

# Upgrade codegen packages as a SET, never individually:
#   flutter_riverpod + riverpod_annotation + riverpod_generator
#   freezed_annotation + freezed
#   json_annotation + json_serializable
```

Generated files (`.g.dart`, `.freezed.dart`) are **committed to git**.

---

## Conventional Commits

```
feat(scope): description

- Bullet points of changes
- Group by scope
```

Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `perf`, `test`.  
Scopes: `splash`, `login`, `signup`, `dashboard`, `core`, `deps`, `ios`, `shared`, `theme`.
