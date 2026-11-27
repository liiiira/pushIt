# Plan — pushIt MVP

## Goal

All 54 screens from `docs/design/pushIt_UI_Light_and_Dark.pdf` running in Flutter (Android), in light (Fog) and dark mode, on fake in-memory data behind repository interfaces. When the Django REST backend arrives later, it replaces only `lib/data`.

## Split

| | Agent A | Agent B |
|---|---|---|
| Layers | Foundation, `lib/app`, `lib/core` (design system, l10n setup, core types), test helpers, CI | `lib/domain` (entities, interfaces, rules), `lib/data` (fakes, fixtures, scenarios) |
| Features | `onboarding`, `auth`, `home`, `activity`, `accounts`, `settings`, `plans`, `dev` | `composer`, `calendar`, `library`, `assisted` |
| Screens | A1–A8, B1–B3, C1–C6, H1–H7, I1–I3 (27) | D1–D13, E1–E4, F1–F7, G1–G3 (27) |

## Ownership

| Path | Owner | Others |
|---|---|---|
| `lib/app/**`, `lib/core/**` (except the ARB rule below), `test/helpers/**`, `test/architecture/**` | A | Issue `for-agent-a` |
| `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `.github/**`, `tool/**`, `.githooks/**`, `CLAUDE.md`, `docs/*.md` | A | Issue `for-agent-a` |
| `lib/domain/**`, `lib/data/**` (including `lib/data/dependencies.dart`: `Dependencies` + `Dependencies.fake`) | B | Issue `for-agent-b`; mock with mocktail meanwhile |
| `android/**` (manifest, permissions, Gradle) | A | Ask in the `build(deps)` PR description or an issue, e.g. `<queries>` for `url_launcher`, notification setup |
| `lib/features/{onboarding,auth,home,activity,accounts,settings,plans,dev}/**` and their tests | A | — |
| `lib/features/{composer,calendar,library,assisted}/**` and their tests | B | — |
| `lib/core/l10n/arb/app_en.arb` | Both | Add only keys prefixed with your feature, in alphabetical order. `common…` keys are A's. |
| `docs/progress/agent-a.md` / `agent-b.md` | That agent only | — |
| New dependency | Requester | Its own PR `build(deps): add <pkg>`, announced in an issue |

**Things shared across ownership:** each is exported from its owner's barrel and used by the other.
- `showLimitReachedSheet` (H3): exported by `features/plans/plans.dart`, used by the composer.
- `showReconnectDialog` (C5): exported by `features/accounts/accounts.dart`, used by F4.
- Dev-menu "simulate assisted reminder": built by A in `features/dev`; it calls B's `PostsRepository`.

## Phases and sync points

| Phase | Agent A | Agent B | Gate |
|---|---|---|---|
| 0 | Foundation PR, then tag `foundation-v0` | Toolchain, `gh`, clone, then stop (no polling) until the human restarts it | B writes code only after `foundation-v0` exists |
| 1 | Design system (tokens, themes, shared widgets, `/dev/components` gallery), app shell, theme mode. Tokens PR first. | PR1 domain contracts and rules (merged ASAP), then PR2 fakes, fixtures, scenarios, `Dependencies.fake` | A's features wait for B's PR1; B's screens wait for A's design-system PRs |
| 2 | A1–A8 → B1–B3 → C1–C6 (export C5 early) → H1–H7 (export H3 early, Appearance row, Developer menu) → I1–I3 in the shell | F1–F7 → D1–D13 → E1–E4 → G1–G3 | — |
| 3 | QA: every owned screen × scenario × theme × 360/412 dp; prototype flow A1 → B1; `flutter build apk --release`; README | QA of owned screens; flow compose → schedule → calendar → library → edit → delete → assisted delete | Both: every screen reachable in some scenario |

## Communication

- **GitHub issues:** label `for-agent-a` / `for-agent-b`. Title: `[request] <what>`. Body: why, a proposed API or design, and what you are mocking meanwhile.
- **Progress files:** `docs/progress/agent-x.md`, one line per merged PR: date, PR number, what was merged, decisions taken.
- **Humans** relay anything urgent between the two machines.
