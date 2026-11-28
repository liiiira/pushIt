# Architecture — pushIt MVP

## Layers

```
 UI (pages, views, widgets)      renders state, forwards user intent
        │ calls
 Cubits (features/*/presentation/cubit)   presentation state, orchestration
        │ calls
 Use cases and rules (lib/domain/rules, features/*/domain)   pure Dart business logic
        │ uses
 Repository interfaces (lib/domain/repositories)   contracts
        ▲ implemented by
 Fake repositories (lib/data/fake)   in-memory now; lib/data/remote later (Django REST)
```

**Dependency rules:**
- `lib/domain` imports nothing from Flutter, `lib/data`, `lib/features` or `lib/app`.
- `lib/data` imports `lib/domain` (and `lib/core` for `Clock` and `AppFailure`) only.
- A feature imports `lib/domain`, `lib/core`, `lib/app/router/route_paths.dart`, and other features **only through their barrel** `features/<x>/<x>.dart`.
- Widgets never call repositories directly; only cubits do.

## Folder tree

```
lib/
  main.dart                            reads SCENARIO (dart-define), builds Dependencies, runs PushItApp
  app/                                 (A)
    app.dart                           MaterialApp.router, themes, l10n delegates, MultiRepositoryProvider
    app_repositories.dart              repositoryProvidersOf(Dependencies): one provider per interface + Clock
    router/
      route_paths.dart                 every path constant (all 54 screens): RoutePaths + RouteSegments
      app_redirect.dart                AppAccess + appRedirect(path, access), pure
      app_router.dart                  buildAppRouter: composes <feature>_routes.dart; StatefulShellRoute (4 tabs)
      app_shell.dart                   bottom nav + centre create button + offline banner (top of the tab area)
    connectivity/connectivity_cubit.dart   online or not, from ConnectivityRepository; drives the shell's banner
  core/                                (A)
    clock.dart                         Clock interface, SystemClock, FixedClock (tests)
    preferences/app_preferences.dart   AppPreferences interface + SharedAppPreferences (theme mode, onboarding done)
    theme_mode/theme_mode_cubit.dart   ThemeModeCubit (System, Light, Dark), provided by PushItApp
    failures.dart                      sealed AppFailure
    view_status.dart                   enum ViewStatus { initial, loading, ready, empty, failure }
    l10n/
      arb/app_en.arb                   single template (keys prefixed by feature)
      generated/                       gen-l10n output (gitignored)
      l10n.dart                        context.l10n extension + appLocalizationsDelegates
    design_system/
      tokens/                          app_colors.dart (ThemeExtension), app_typography.dart (ThemeExtension),
                                       app_spacing.dart, app_radii.dart, app_sizes.dart, app_durations.dart
      theme/app_theme.dart             AppTheme.light(), AppTheme.dark(); context.colors, context.textStyles
      widgets/                         shared widgets (see "Shared widgets" below);
                                       placeholder_page.dart until every screen is built
  domain/                              (B) pure Dart
    entities/   enums/   repositories/   rules/
  data/                                (B)
    dependencies.dart                  Dependencies (one final field per repository interface + Clock),
                                       Dependencies.fake({required Scenario scenario, required Clock clock})
    fake/
      scenario.dart                    enum Scenario { populated, firstUse, freeLimit, offline, error, slow }
      fixtures/                        sample data (the only place literal sample text is allowed)
      fake_*_repository.dart
  features/<feature>/                  (owner per docs/PLAN.md)
    <feature>.dart                     barrel: routes + anything other features may use
    <feature>_routes.dart              List<RouteBase> for this feature
    domain/                            feature use cases (pure Dart), e.g. build_dashboard.dart
    presentation/
      cubit/<name>_cubit.dart, <name>_state.dart (part of the cubit)
      pages/<name>_page.dart           creates the cubit (BlocProvider), no layout
      views/<name>_view.dart           layout, BlocBuilder/BlocListener
      widgets/                         feature-only widgets
test/                                  mirrors lib/
  helpers/helpers.dart (barrel), pump_app.dart, test_across_layouts.dart, fakes.dart,
          test_dependencies.dart (testNow, testDependencies({scenario}): B's fakes, no latency) (A)
  architecture/conventions.dart (rules), conventions_test.dart                         (A)
assets/
  fonts/                               Hanken Grotesk (OFL) + OFL.txt
  logos/                               Simple Icons SVGs (CC0): youtube, instagram, tiktok, facebook, threads, linkedin, bluesky, x
tool/check.sh                          local gate
.githooks/commit-msg                   no AI attribution + Conventional Commits
```

## Dependency injection

- `main.dart` reads `const String.fromEnvironment('SCENARIO', defaultValue: 'populated')`.
- It builds `Dependencies.fake(scenario: …, clock: const SystemClock())` (B's `lib/data/dependencies.dart`) and passes it to `PushItApp`.
- `PushItApp` exposes each repository through `MultiRepositoryProvider`. Pages read them with `context.read<XRepository>()` when creating their cubit.
- The debug-only Developer menu (`/settings/developer`) can switch the scenario at runtime by rebuilding `Dependencies` with a new key.
- **Later:** `Dependencies.remote(...)` will implement the same interfaces. No cubit or widget changes.

## Navigation

- `go_router`, built in `app_router.dart` by Agent A.
- A `StatefulShellRoute.indexedStack` holds 4 branches: Home `/home`, Calendar `/calendar`, Library `/library`, Accounts `/accounts`.
- The centre create button pushes `/compose` on the root navigator (full screen, no bottom nav).
- Redirects:
  - not onboarded → `/onboarding`
  - signed out → `/sign-in`
  - `/` → `/splash`
- Bottom sheets and dialogs are not routes. They are opened with the shared `showAppBottomSheet` / `showAppDialog` from the page that owns them.
- Route paths live in `route_paths.dart` only.
  - Navigate with `RoutePaths` and its helpers, e.g. `context.go(RoutePaths.libraryPostFor(id))`, never with string literals.
  - Nested `GoRoute`s declare their relative path with `RouteSegments`.
- **Feature routes:** `<feature>_routes.dart` exposes a function that returns `List<RouteBase>`, e.g. `libraryRoutes(...)`. Each route starts as `PlaceholderPage(screenId: 'F1')`; replace it with the real page when the screen lands.
- **Full-screen sub-routes of a tab:** in the designs, only the four tab roots show the bottom nav. Every sub-route of a tab (B3, C2, C4, F3–F7) sets `parentNavigatorKey: rootNavigatorKey`, including grandchildren. `app_router.dart` passes the key in, e.g. `libraryRoutes(rootNavigatorKey: …)`.
- **Cross-feature nesting** is composed in `app_router.dart` through a `children` parameter, so features never import each other for routing:
  - activity under `/home`: `homeRoutes(children: activityRoutes(...))`
  - plans and the Developer menu under `/settings`
- **Redirects** are the pure function `appRedirect(path, AppAccess)` in `app_redirect.dart`. The router re-runs it whenever its `AppAccess` listenable changes.
  - The splash and the dev routes are never redirected.
  - Verify email stays reachable when signed in.
- Debug-only routes (`/settings/developer`, `/dev/components`) are registered under `kDebugMode`.

## Shared widgets (A, `lib/core/design_system/widgets`)

| Area | Widgets |
|---|---|
| Bars and navigation | `AppTopBar` (title, back, close; trailing slot), `AppBottomNav` (4 tabs + centre create) |
| Buttons | `PrimaryButton`, `SecondaryButton`, `TextActionButton` (full 56, small 40) |
| Platforms and media | `PlatformLogo` (8 platforms × selected or unselected × 48 or 28), `VideoThumbnail` (9:16, duration, play icon, selected ring) |
| Containers and rows | `AppCard`, `AppListRow` (leading, title, subtitle, trailing) |
| Inputs | `AppSwitch`, `AppCheckbox`, `AppRadio`, `AppSegmentedControl`, `AppTextField` (single and multiline) |
| Overlays | `showAppBottomSheet`, `showAppDialog` |
| States | `EmptyStateView`, `ErrorStateView` (I3), `OfflineBanner` (I1), `SkeletonList` (I2) |
| Display | `AppProgressBar`, `StatTile`, `PageIndicator`, `InitialsAvatar` |

A debug-only gallery at `/dev/components` shows every widget in both themes.

## Scenarios (B, `lib/data/fake/scenario.dart`)

| Scenario | Data | Screens it reveals |
|---|---|---|
| `populated` (default) | Pro plan, 4 of 10 accounts, posts and drafts from the designs | Most screens |
| `firstUse` | Signed in, no accounts, no posts | B2, F2, E3, empty states |
| `freeLimit` | Free, 3 of 3 accounts, 10 of 10 videos this month | H1 usage bar, H3, C6 |
| `offline` | Connectivity `false`, cached data | I1 |
| `error` | List loads throw `NetworkFailure` | I3 |
| `slow` | 2 s latency | I2 |

The fake auth starts signed out, so a fresh run shows A1 → onboarding → sign in. The Developer menu offers "skip to signed in".
