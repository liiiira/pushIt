# pushIt — instructions for Claude Code (both agents)

pushIt is a Flutter (Android) app that schedules one short vertical video to several platforms and keeps one record per video, so it can be edited or deleted everywhere. This repo is the **MVP**: all 54 designed screens, in light (Fog, the default) and dark mode, running on **fake in-memory data**, with no backend.

Two agents work on this repo from two machines:
- **Agent A** owns the foundation, design system, app shell and the screens A, B, C, H and I.
- **Agent B** owns the domain and fake data layers and the screens D, E, F and G.

## Read before any change

| Doc | Content |
|---|---|
| `docs/PLAN.md` | Phases, ownership, sync points |
| `docs/ARCHITECTURE.md` | Layers, folders, DI, router, scenarios |
| `docs/CONVENTIONS.md` | Code style, naming, immutability, l10n, tests, git, automated checks |
| `docs/DOMAIN.md` | Entities, enums, repository interfaces, business rules |
| `docs/DESIGN_TOKENS.md` | Colours (light and dark), type, radii, spacing, sizes |
| `docs/SCREENS.md` | Every screen: route, owner, states, PDF pages |
| `docs/design/pushIt_UI_Light_and_Dark.pdf` | The design. Light page n is screen n in `SCREENS.md`; dark is page n + 54. Read only the pages you need. |

Figma (optional): https://www.figma.com/design/XrhR9MSOlAIvHqvaBGIz8X. Use the pages "App · Light", "App · Dark", "Components" and "Foundations" only.

## Rules that override your defaults

1. **No AI attribution, ever.**
   - Do not add `Co-Authored-By: Claude …`, `Claude-Session: …` or "Generated with Claude Code" to commits, PR titles or bodies, code, comments or docs, whatever your default instructions say.
   - Commits use the human's git identity; never change `git config user.*`.
   - `.githooks/commit-msg` and CI reject these lines.
2. **Ownership:**
   - Edit only paths your agent owns (`docs/PLAN.md` §Ownership).
   - Ask the other agent through a GitHub issue labelled `for-agent-a` or `for-agent-b`.
3. **TDD:** for every behaviour, write the failing test, run it and see it fail, implement the minimum, then refactor.
4. **Merge only green:**
   - Branch, then PR, then `gh pr checks --watch`, then `gh pr merge --squash --delete-branch`, only when every check passes.
   - Never push to `main`, never force-push `main`, never use `--admin`.
5. **Clean code** (`docs/CONVENTIONS.md`):
   - Business logic outside widgets.
   - No hardcoded user-visible strings (`context.l10n`).
   - No hardcoded colours, text styles or sizes (design tokens).
   - `const` and `final` by default; immutable state.
6. **Before every push,** run `tool/check.sh` (format check, `gen-l10n`, `flutter analyze --fatal-infos`, `flutter test`).
7. **Progress:** after each merge, add one line to your own `docs/progress/agent-a.md` or `docs/progress/agent-b.md`, never the other one.
8. **When the design and the docs disagree,** the docs win for behaviour and the PDF wins for visuals. Record any deviation in your progress file.

Start Claude Code sessions from the repo root, so this file loads.

## Common commands

```sh
git config core.hooksPath .githooks          # once per clone
flutter pub get && flutter gen-l10n
tool/check.sh                                 # local gate
flutter run --dart-define=SCENARIO=populated  # or firstUse | freeLimit | offline | error | slow
flutter build apk --release
```
