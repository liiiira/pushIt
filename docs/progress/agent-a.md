# Progress — Agent A

One line per merged PR: `YYYY-MM-DD · #PR · what was merged · decisions or deviations`.


2026-11-28 · #1 · Phase 0 foundation: scaffold, dependencies, lints, l10n, core types, router with every route stubbed, test helpers, architecture checks, local gate and CI · Decisions:
- `material_ui` replaces the deprecated `flutter/material`. `MaterialApp` uses `appLocalizationsDelegates`, not gen-l10n's legacy list.
- Icons come from `lucide_icons_flutter`.
- Hanken Grotesk is bundled as the variable font only, so Phase 1 sets `fontVariations: wght` on every style.
- Dart 3.14 `const new()` constructors (very_good_analysis 11).
- §8 checks extended:
  - check 1 also covers `flutter_*`, `material_ui`, `cupertino_ui` and `dart:ui`
  - check 2 also covers `Color.fromARGB` / `fromRGBO`
- Tab sub-routes are full screen (`parentNavigatorKey: root`).
- Cross-feature nesting (activity under home; plans and developer under settings) is composed in `app_router.dart`.
- Deviation: `/settings/appearance` is available in every build (SCREENS.md updated); only the Developer menu and `/dev/components` are debug-only.
2026-11-28 · #2 · Design tokens and themes: `AppColors`/`AppTypography` ThemeExtensions, spacing, radii, sizes, durations, `AppTheme.light()/dark()`, `context.colors`/`context.textStyles` · Decisions:
- Every Material surface slot maps to `surface`; tint and shadow use `AppColors.transparent`; elevation 0.
- `error` maps to `text` (greys only).
- `context.colors` falls back to the tokens of the theme brightness outside an `AppTheme`.
- `themeMode: light` until the theme-mode cubit lands.
- Extra tokens beyond DESIGN_TOKENS.md:
  - `AppSpacing.screenMargin`/`cardPadding`
  - `AppSizes.ringWidth`, `galleryColumns`/`galleryGap`, `platformGlyph*`
  - `AppDurations.fakeLatencySlow`
2026-11-28 · #3 · Shared widgets, part 1, plus the `/dev/components` gallery · Widgets: `PrimaryButton`, `SecondaryButton`, `TextActionButton` (`AppButtonSize.full` 56 / `small` 40, 48 dp tap target), `AppTopBar`, `AppCard`, `AppListRow` · Decisions:
- Disabled primary buttons are `block` with `sub` text.
- Small text actions have no side padding, so they align with the text around them.
- `AppListRow` caps its value/trailing group at 60% of the width.
- The gallery has no cubit (stateless), so `ComponentsPage` holds its layout.
2026-11-28 · #5 · Shared widgets, part 2 (inputs): `AppSwitch`, `AppCheckbox`, `AppRadio<T>`, `AppSegmentedControl<T>`, `AppTextField`; `AppListRow.padding` · Decisions:
- A null `groupValue` on a radio means "not chosen yet" (D7 privacy).
- Text-field errors add a `text` outline plus an icon and message, never colour alone.
- Disabled controls use `sub`/`line`.
- New tokens: `AppRadii.checkbox` 6 and `AppSizes.radioDot` 12, also added to DESIGN_TOKENS.md.
2026-11-28 · #6 · Shared widgets, part 3: `PlatformLogo` (uses B's `PlatformId`), `VideoThumbnail`, `InitialsAvatar`, `AppProgressBar`, `StatTile`, `PageIndicator`; `formatClipDuration`/`initialsOf`; `l10n.platformName` · Decisions:
- `lib/core` imports `lib/domain` for `PlatformId`. This is not a file-level cycle, and the docs require logos for the 8 platforms.
- Lucide has no solid play icon, so the play triangle is painted.
- New tokens: `selectionRingWidth` 2.5 and `pageDot` 8 / 24, also added to DESIGN_TOKENS.md.
2026-11-28 · #8 · Shared widgets, part 4: `showAppBottomSheet`, `showAppDialog` (`AppDialogAction`), `EmptyStateView`, `ErrorStateView` (I3), `OfflineBanner` (I1), `SkeletonList` (I2) · Decisions:
- Dialogs take declarative actions that pop with a value, so callers never handle the dialog's context.
- `ErrorStateView` falls back to a generic message.
- The skeletons are static (no shimmer, since gradients are not allowed).
- New tokens: `iconLarge` 32 and `sheetHandle` 40 × 4, also added to DESIGN_TOKENS.md.
2026-11-28 · #10 · App wiring: `main` builds B's `Dependencies.fake` for the `SCENARIO` define; `PushItApp(dependencies:)` provides every repository interface and `Clock` (`repositoryProvidersOf`); test helper `testDependencies({scenario})` at `testNow` with no latency · Decision: `AppAccess` stays a fixed signed-out value until the splash and auth screens (Phase 2) feed it from preferences and `AuthRepository`.
2026-11-28 · #11 · Theme mode: `AppPreferences` (`SharedAppPreferences`, theme mode and onboarded flag), `ThemeModeCubit`, provided by `PushItApp` · Decisions:
- The default mode is light (Fog), not system.
- Deviation from ARCHITECTURE.md: both live in `lib/core/` instead of `lib/app/`, so features (Appearance, onboarding, splash) can use them. The doc is updated.
2026-11-28 · #13 · App shell: `AppBottomNav` (4 tabs plus a centre create button that pushes `/compose`), `ConnectivityCubit`, and the `OfflineBanner` in the shell while offline · Deviations and decisions:
- The nav background is `bg`, as on the PDF, not `surface` as DESIGN_TOKENS.md said; the doc is updated.
- The offline banner sits at the top of the tab area (shell), not under the page title as on the PDF, so it works on every tab with no per-page code. SCREENS.md and ARCHITECTURE.md are updated.
- There is no active-tab indicator (the PDF has none): the current tab is `text`, the others `sub`.
- Phase 1 (A) is complete with this PR.
2026-11-28 · #15 · Router test checks each route's path, and that any `PlaceholderPage` still shown names the expected screen; it pumps `PushItApp` · Decision: real pages replace placeholders in `*_routes.dart` without touching the router test (unblocks B, issue #9).
2026-11-28 · #16 · `AppSegmentedControl` keeps labels whole (issue #9, F1 at 412 dp) · Decisions:
- Label padding is 4 dp.
- Widths come from `segmentWidths` (pure): an even split when every label fits; otherwise long labels get their natural width and the rest share what is left.
- Segments keep a 48 dp floor.
- Deviation: when nothing fits (360 dp at text scale 1.3), the labels scale down together (`FittedBox`) rather than being cut.
2026-11-28 · #18 · C5 exported: `showReconnectDialog({context, account, risk})` → `bool`; `reconnectRiskOf(account, posts, now:)` → `ReconnectRisk`; shared `context.dayAndTimeLabel` ("today, 19:00", `commonWhen…` keys) · Decisions:
- The dialog never reconnects; the caller's cubit does.
- The message follows the account health (signed out, expiring at a time, or soon). The at-risk sentence is added only when posts are at risk, so F4 can call it with no risk.
- The dialog reads `Clock` from context, like B's library views.
- `date_labels.dart` is not exported from `l10n.dart`, to avoid clashing with library's `whenLabel`. The comma in "today, 19:00" follows C5, while F1 has none.
2026-11-28 · #19 · H3 exported: `showLimitReachedSheet({context, plan, usage})` → `LimitReachedChoice` (`seePlans`, `saveDraft`, `dismissed`); `l10n.planName(tier)`; `context.usdLabel` ("$6") · Decisions:
- `LimitReachedFailure` carries no data, so the composer passes the plan and usage.
- The upgrade offered is always Pro (`proPlan`), the cheapest plan with no monthly limit.
2026-11-28 · #22 · A1 splash, and a live `AppAccess`: `AppAccessNotifier` (from `AppPreferences.watchOnboarded` and `AuthRepository.watchUser`), wired in `main.dart` · Decisions and deviations:
- `AppAccess.unknown` until the first auth event. Every route but the dev ones goes to `/splash` meanwhile; once known, `/splash` redirects to onboarding, sign-in or home.
- The splash has no cubit and does not "decide", as SCREENS.md said: the redirect does, so nothing races the router. ARCHITECTURE.md and SCREENS.md are updated.
- An auth error counts as signed out, so the splash never hangs.
- `AppAccess.isEmailVerified`: a signed-in user who has not verified their email is sent from sign-in, register and reset to `/verify-email`, not home. The app is not gated on it, because `AuthRepository` has no way to verify, so the fake would be stuck.
