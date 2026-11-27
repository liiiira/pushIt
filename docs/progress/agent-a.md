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
