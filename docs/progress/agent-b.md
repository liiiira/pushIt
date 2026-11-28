# Progress — Agent B

One line per merged PR: `YYYY-MM-DD · #PR · what was merged · decisions or deviations`.

2026-11-28 · #4 · Domain layer: enums, entities, repository interfaces, business rules (post status, platform capabilities, video limits, plans, schedule validation, TikTok readiness, D8 platform check) · Decisions:
- Added `TargetFailureReason` (enum) for `PostTarget.failureReason`, so entities hold no display text.
- `Post.title` is derived: the YouTube title when set, else the first caption line. No stored title field.
- `PostTarget.accountId` and `scheduledAt` are nullable, for drafts only (no account or schedule yet).
- Entities keep `const` constructors and expose collections through unmodifiable views; callers must not mutate what they pass in.
- `confirmAssisted` also confirms an assisted deletion (G3) while a post is being deleted.
- An expired account counts as `NotConnected` in the platform check; `expiringSoon` still counts as connected.
- Durations other than Facebook's 90 s are marked `ASSUMPTION` in `rules/video_limits.dart`.

