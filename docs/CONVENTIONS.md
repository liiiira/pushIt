# Conventions — both agents

One style for the whole codebase. If a rule here conflicts with a habit, the rule wins. If a rule needs to change, Agent A changes this file in its own PR.

## 1. Tooling

- **Flutter 3.50.0 stable, Dart 3.14.0** on both machines and in CI.
- **Formatting:** `dart format .` (the default tall style). CI fails on unformatted code.
- **Lints:** `very_good_analysis` (version resolved in Phase 0), with:
  ```yaml
  include: package:very_good_analysis/analysis_options.yaml
  analyzer:
    language:
      strict-casts: true
      strict-inference: true
      strict-raw-types: true
    exclude: [lib/core/l10n/generated/**]
  linter:
    rules:
      public_member_api_docs: false
  ```
- **Analyzer:** `flutter analyze --fatal-infos` must report nothing.
- **Imports:** package imports only (`package:pushit/...`) under `lib/`; tests may import their helpers relatively (`import '../helpers/helpers.dart';`).
- **Icons:** `lucide_icons_flutter` (^4.0.5), e.g. `Icon(LucideIcons.house)`. Use only that set; never `Icons.*`.
- **Material comes from `material_ui`:**
  - Flutter 3.50 deprecates `package:flutter/material.dart`, and `--fatal-infos` fails on it. Import `package:material_ui/material_ui.dart`, which also re-exports `package:flutter/widgets.dart`.
  - Never mix in the legacy import. The two Material libraries have separate `Theme`s and localizations, so a legacy widget would not see the app theme.
  - `go_router` 18 already uses `material_ui`.
- **Localizations:** `MaterialApp` takes `appLocalizationsDelegates` from `lib/core/l10n/l10n.dart`. Do not use `AppLocalizations.localizationsDelegates`: gen-l10n fills it with the legacy Material delegate.
- **Dart 3.14 syntax** (enforced by `very_good_analysis` 11; `dart fix --apply` does all three):
  - constructors are written `const new(...)` instead of repeating the class name
  - empty class bodies are written `class MockX extends Mock implements X;`
  - non-obvious top-level types are annotated (`const Set<String> _x = {...}`)

## 2. Separation of concerns

- **Widgets** render state and forward intent (`context.read<XCubit>().onScheduleTapped()`). No business rules, no repository calls, no date maths, no string building beyond l10n.
- **Cubits** hold presentation state. They call repositories and pure rules or use cases, catch `AppFailure` and map it to state. No `BuildContext`, no widgets, no navigation (emit a state; the view's `BlocListener` navigates).
- **Business rules** live in `lib/domain/rules` (shared, Agent B) or in `features/<x>/domain` (feature use cases), as pure Dart functions or classes, fully unit-tested.
- **Repositories** are interfaces in `lib/domain/repositories`; implementations live in `lib/data`.

## 3. Immutability and `const`

- `const` constructors on every widget and value class that allows them; `const` at every call site the analyzer allows.
- `final` for every local and field. `var` only when the variable is reassigned. Never `dynamic`. `late` only with a comment explaining why.
- Entities and states are `@immutable`, with `final` fields, `Equatable` (`props`) and `copyWith`. No setters, and no mutable collections in public APIs: store `List.unmodifiable(...)` and expose `List<T>` / `Set<T>` / `Map<K, V>` views.
- Cubits never mutate state. They only call `emit(state.copyWith(...))`.
- Prefer `sealed` classes and exhaustive `switch` expressions for variants (`ScheduleChoice`, `UploadProgress`, `AppFailure`, …).

## 4. No hardcoded values

| Kind | Where it comes from |
|---|---|
| User-visible text | `context.l10n.<key>` (ARB). Plurals and placeholders use ICU in the ARB. |
| Colours | `context.colors.<token>` (ThemeExtension) |
| Text styles | `context.textStyles.<style>` |
| Spacing, radii, sizes, durations | `AppSpacing`, `AppRadii`, `AppSizes`, `AppDurations` |
| Routes | `RoutePaths` |
| Sample data | `lib/data/fake/fixtures/` only |
| Business numbers (limits, prices) | `lib/domain/rules` constants |

**ARB rules:**
- One template `lib/core/l10n/arb/app_en.arb`.
- Keys are lowerCamelCase, prefixed by the owning feature (`libraryEmptyTitle`, `composerScheduleButton`), or `common…` for shared words (Agent A only).
- Keep the file sorted alphabetically by key. This keeps both agents' additions in different regions, so merges stay clean.
- Every key with placeholders has its `@key` metadata.
- Never put display text in entities or cubits. Pass data (enums, numbers, dates) and format it in the view with l10n and `intl`.

## 5. Naming and structure

| Thing | Convention |
|---|---|
| Files | `snake_case.dart`; one public class (widget) per file |
| Route-level widget | `XPage`: creates the cubit with `BlocProvider`, no layout |
| Page body | `XView`: layout, `BlocBuilder` / `BlocListener` |
| Cubit and state | `XCubit` in `x_cubit.dart`; `XState` in `x_state.dart` as `part of` the cubit |
| Repository | `XRepository` (interface); `FakeXRepository` (fake) |
| Use case | Verb-named class with a `call` method, e.g. `BuildDashboard`, `CheckPlatforms` |
| Booleans | `isX`, `hasX`, `canX` |
| Private widgets | Extract `class _Header extends StatelessWidget`; **no** `Widget _buildHeader()` methods |
| Callbacks | `onXTapped`, `onXChanged` in widgets; cubit methods are named after intents (`scheduleTapped()`, `platformToggled(p)`) |

**Page state shape (all pages):**
```dart
final class LibraryState extends Equatable {
  const LibraryState({this.status = ViewStatus.initial, this.posts = const [], this.filter = LibraryFilter.all, this.failure});
  final ViewStatus status;      // initial | loading | ready | empty | failure
  final List<Post> posts;
  final LibraryFilter filter;
  final AppFailure? failure;
  LibraryState copyWith({...});
  @override
  List<Object?> get props => [status, posts, filter, failure];
}
```
- `loading` shows `SkeletonList` (I2).
- `empty` shows the page's `EmptyStateView`.
- `failure` shows `ErrorStateView` (I3) with retry.

## 6. Layout, responsiveness and accessibility

- The designs are 412 × 915 dp, and every screen must also work at **360 × 800** and up to 600 dp wide:
  - no fixed screen widths
  - `Expanded` / `Flexible` and `maxLines` + ellipsis on dynamic text
- Screens scroll (`CustomScrollView` / `SingleChildScrollView`); primary actions are pinned at the bottom with the 24 dp margin.
- Text scale 1.3 must not overflow.
- Every tappable element is at least 48 × 48 dp.
- Icon-only buttons get a `Semantics` / `tooltip` label from l10n.
- State is never shown by colour alone (icon + word), as in the designs.

## 7. Testing (TDD)

1. **Red:** write the test for the next behaviour, run it, and see it fail for the right reason.
2. **Green:** the smallest change that passes.
3. **Refactor** with all tests green.

| Unit | Test |
|---|---|
| Domain rule or use case | Plain `test`, every branch and edge case |
| Cubit | `blocTest` for every transition, repositories mocked with `mocktail` |
| Page or view | Widget test for **every design state** of the screen, with `testAcrossLayouts` |
| Shared widget | Widget test with `testAcrossLayouts` |
| Fake repository | Unit test per scenario |

`testAcrossLayouts(description, body)` (A, `test/helpers`) runs the body for:
- sizes 360×800 and 412×915
- light and dark
- text scale 1.0 and 1.3

It asserts no overflow exceptions, plus `meetsGuideline(androidTapTargetGuideline)` and `meetsGuideline(textContrastGuideline)`.

Other testing rules:
- Time comes from `Clock`. Tests use `FixedClock(DateTime(2026, 11, 12, 15, 48))`.
- No golden tests: font rasterisation differs between machines.
- Test files mirror `lib/` paths and end in `_test.dart`.

## 8. Automated checks (`test/architecture/conventions_test.dart`, Agent A)

The test scans `lib/` (except `lib/core/l10n/generated/`, and ignoring `//` comment lines) and fails on:
1. a Flutter import under `lib/domain/`: `package:flutter/…`, `package:flutter_*/…`, `package:material_ui/…`, `package:cupertino_ui/…` or `dart:ui`
2. `Color(0x`, `Color.fromARGB(`, `Color.fromRGBO(` or `Colors.` outside `lib/core/design_system/tokens/`
3. `TextStyle(` outside `lib/core/design_system/`
4. `Text('…')` or `Text("…")` with a literal under `lib/features/` or `lib/core/design_system/widgets/`
5. an import of `package:pushit/features/<other>/…` that is not the other feature's barrel `features/<other>/<other>.dart`. This applies from anywhere in `lib/`, including `lib/app`.

The rules live in `test/architecture/conventions.dart` as pure functions, and each one is unit-tested on samples in `conventions_test.dart`.

## 9. Git

**Branches:** `a/<type>/<scope>-<desc>` or `b/<type>/<scope>-<desc>`, for example `b/feat/library-list` or `a/fix/home-countdown`.

**Commits:** Conventional Commits, enforced by `.githooks/commit-msg`.
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `style`, `perf`.
- Scope = feature folder or layer: `library`, `composer`, `domain`, `data`, `design-system`, `router`, …
- Subject in the imperative, at most 72 characters.

**No AI attribution:** no `Co-Authored-By: Claude…`, `Claude-Session:` or "Generated with Claude Code" anywhere. The hook and CI reject them.

**Merge protocol:**
1. `git switch main && git pull --rebase`, then `git switch -c <branch>`.
2. TDD, with small commits.
3. Run `tool/check.sh` and make it green.
4. Run `git fetch origin && git rebase origin/main`, then `tool/check.sh` again.
5. `git push -u origin <branch>`, then `gh pr create --title "<conventional title>" --body "<screens, tests, scenarios checked>"`.
6. Run `gh pr checks --watch`. **Merge only when all checks pass:** `gh pr merge --squash --delete-branch --subject "<title>" --body "<summary>"`.
7. Never: push to `main`, force-push `main`, `--admin`, or merge red or pending checks. `--force-with-lease` is allowed on your own branch only.
8. Add one line to your `docs/progress/agent-x.md`.

**PR size:** one layer or one screen group. Split anything over about 600 changed lines of non-test code.

## 10. Local gate (`tool/check.sh`) and CI

```sh
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

`gen-l10n` runs first, so the analyzer and the tests see the generated localizations. To fix formatting, run `dart format .`.

CI (`.github/workflows/ci.yml`) runs the same on every PR and on every push to `main`, with Flutter 3.50.0, plus an **attribution check** (checkout with `fetch-depth: 0`; range `base.sha..HEAD`): it fails if any commit message in the PR, or the PR body, matches `co-authored-by:.*(claude|anthropic)`, `claude-session:` or `generated with \[?claude` (case-insensitive).
