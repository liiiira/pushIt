# Domain — pushIt MVP

Owner: **Agent B** (`lib/domain`, `lib/data`). Agent A consumes these contracts and requests changes with an issue labelled `for-agent-b`. Any change to an interface is its own PR, `feat(domain): …`, and the progress file notes the change.

## 1. Domain contract (`lib/domain`, pure Dart, never imports Flutter)

All entities are `@immutable`, with `final` fields, a `const` constructor, `Equatable` and `copyWith`, and expose lists as unmodifiable. Entities hold data, never display text.

**Enums:**
```dart
enum PlatformId { youtube, instagram, tiktok, facebook, threads, linkedin, bluesky, x }
enum AccountMode { automatic, assisted }
enum AccountHealth { connected, expiringSoon, expired }
enum PlanTier { free, pro, studio }
enum BillingPeriod { monthly, yearly }
enum TargetStatus { scheduled, uploading, processing, published, failed, awaitingUser, removed }
enum PostStatus { draft, scheduled, publishing, published, partiallyFailed, failed } // derived from targets
enum TikTokPrivacy { everyone, friends, onlyMe } // nullable field: null = not chosen yet
enum ActivityKind { published, failed, reconnectNeeded, assistedReminder, assistedConfirmed }
enum FeedbackKind { problem, idea, other }
enum DeleteMethod { automatic, assisted }
enum DeletionOutcome { pending, removed, awaitingUser, failed }
enum EditOutcome { applied, notSupported, failed }
```

**Entities:**
```
User(id, name, email, isEmailVerified)
ConnectedAccount(id, platform, handle, label, accountType, mode, health, signInExpiresAt)
GalleryItem(id, fileName, duration, sizeBytes, width, height)
VideoAsset(id, fileName, duration, sizeBytes, width, height)
TikTokSettings(privacy?, allowComments = false, allowDuet = false, allowStitch = false, isCommercial = false)
PlatformCopy(platform, title?, text)                 // per-platform caption override
PostStats(views, likes, comments, refreshedAt)
PostTarget(platform, accountId, scheduledAt, status, url?, stats?, failureReason?)
Post(id, video, caption, copies, coverAt, tiktok?, targets, isDraft, createdAt, updatedAt)
     derived: status, nextScheduledAt, totals (PostStats summed over targets)
PostDraft(video?, caption, platforms, copies, coverAt, tiktok, schedule?)
sealed ScheduleChoice: SameTime(DateTime at) | PerPlatform(Map<PlatformId, DateTime> times)
sealed PlatformCheckIssue: DurationTooLong(platform, limit, actual) | FileTooLarge(limitBytes, actualBytes)
                          | PrivacyNotChosen() | NotConnected(platform) | PaidPlanRequired(platform)
sealed UploadProgress: Uploading(sentBytes, totalBytes) | Paused(sentBytes, totalBytes)
                      | UploadFailed() | Uploaded(VideoAsset)
EditResult(platform, outcome)
DeletionStep(platform, method, outcome)
Plan(tier, monthlyPriceUsd, yearlyPriceUsd, accountLimit, monthlyPostLimit?, hasStatistics, hasX, hasCaptionVariants)
Subscription(plan, period?, renewsOn?)
Usage(postsThisMonth, connectedAccounts, resetsOn)
ActivityItem(id, kind, occurredAt, postId?, postTitle?, platform?, platformCount?)
NotificationPreferences(published, failed, reconnectReminders, assisted, weeklyPlan)
Referral(code, joinedCount, monthsEarned)
CaptionSuggestion(platform, text)
```

**Repository interfaces** (`abstract interface class`; methods return a `Future` or a `Stream` and throw `AppFailure`):
```
AuthRepository: watchUser(), signIn(email, password), signInWithGoogle(), register(name, email, password),
                resendVerification(), sendPasswordReset(email), signOut(), deleteAccount()
AccountsRepository: watchAccounts(), connect(platform, mode), reconnect(accountId), disconnect(accountId)
MediaRepository: gallery(), upload(galleryItemId) -> Stream<UploadProgress>, pause(), resume(), cancel()
PostsRepository: watchPosts(), watchPost(id), saveDraft(draft, {draftId}), discardDraft(id),
                 schedule(draft, {draftId}) -> Post, reschedule(postId, ScheduleChoice), cancel(postId),
                 retry(postId, platform), editEverywhere(postId, {title, caption}) -> List<EditResult>,
                 deleteEverywhere(postId) -> Stream<List<DeletionStep>>,
                 confirmAssisted(postId, platform), snoozeAssisted(postId, platform, Duration)
CaptionSuggestionsRepository: suggest(caption, platforms) -> List<CaptionSuggestion>
ActivityRepository: watchActivity()
SubscriptionRepository: watchSubscription(), watchUsage(), plans(), purchase(tier, period)
NotificationSettingsRepository: load(), save(preferences)
ReferralRepository: referral()
FeedbackRepository: send(kind, message, includeDeviceDetails)
ConnectivityRepository: watchOnline() -> Stream<bool>
```
`AppFailure` (sealed, in `lib/core`, written by A): `NetworkFailure`, `NotFoundFailure`, `LimitReachedFailure`, `ValidationFailure`, `UnknownFailure`. Cubits catch these and map them to state.

## 2. Business rules (`lib/domain/rules`, pure functions, unit-tested first)

**Platform capabilities** (from the spec):

| Platform | Publish | Delete | Edit after posting |
|---|---|---|---|
| YouTube | automatic | automatic | title, description |
| Instagram | assisted (automatic once Meta approves) | assisted | no |
| Facebook Page | automatic | automatic | caption |
| TikTok | assisted (until TikTok's audit) | **assisted** (the API has no delete) | no |
| Threads | automatic | automatic | no |
| LinkedIn | automatic | automatic | text |
| Bluesky | automatic | automatic | no |
| X | automatic, **Pro or Studio only** | automatic | no |

**Video limits:**
- 300 MB maximum file size.
- Facebook Reels: 90 s maximum.
- Other platforms' maximum durations: put them in a single constants file, marked `// ASSUMPTION: verify against official docs before the backend phase`.

**Plans:**

| Plan | Price | Accounts | Videos a month | Extras |
|---|---|---|---|---|
| Free | $0 | 3 | 10 | — |
| Pro | $6 a month or $48 a year | 10 | unlimited | statistics, X, caption variants |
| Studio | $15 a month or $120 a year | 30 | unlimited | several brands |

**TikTok:**
- Privacy must be chosen; there is no default.
- Comments, Duet and Stitch are off until switched on.
- Commercial content disclosure is a switch.

**Schedule:**
- One time for all platforms, or a time per platform.
- Reschedule and cancel are allowed only until publishing starts.

**Post status** is derived from the targets, for example:
- every target published → `published`
- some failed and some published → `partiallyFailed`

**Platform check (D8):** `check(draft, accounts, plan)` returns a `List<PlatformCheckIssue>`. An empty list means ready.

## 3. Fake data (`lib/data/fake`)

- **Fixtures** match the sample data in the designs:
  - user "Lyes B."
  - accounts: YouTube "Lyes makes" (automatic), Instagram "@lyes.makes" (assisted), Facebook "Lyes makes, Page" (automatic), TikTok "@lyes.makes" (session expired)
  - posts: "Studio tour, part 2" (1:42, scheduled today 19:00 on YouTube, Instagram, TikTok), "Mic test" (failed on TikTok, today 13:30), "Morning b-roll" (published 09:00, 8 204 views), "Behind the desk" (assisted, Instagram)
  - drafts: "Unboxing the lav mic", "Q&A, short cut"
- **Times** are relative to the injected `Clock`. The test clock is fixed at **Thu 12 Nov 2026, 15:48**, so the next post reads "in 3 h 12 min".
- **Consistency:** make the fixtures internally consistent. Where the mock-ups disagree with each other, the data wins; log each decision in `docs/progress/agent-b.md`.
- **Scenarios** (`--dart-define=SCENARIO=<name>`, or the debug Developer menu A builds):

| Scenario | What it shows |
|---|---|
| `populated` (default) | Pro plan, 4 of 10 accounts, the posts and drafts above |
| `firstUse` | Signed in, no accounts, no posts: B2, F2, E3 and the empty lists |
| `freeLimit` | Free plan, 3 of 3 accounts, 10 of 10 videos: H1's usage bar, H3 when scheduling, C6 |
| `offline` | `ConnectivityRepository` emits `false` and the data is cached: I1 |
| `error` | List loads throw `NetworkFailure`: I3 |
| `slow` | Two seconds of latency on every call: I2 skeletons |

- **Simulations:**
  - latency
  - upload progress, with pause, resume and cancel
  - per-platform deletion progress: TikTok waits for the user (`awaitingUser`)
  - edit results: platforms that cannot be edited return `notSupported`
- **Wiring:** you own `lib/data/dependencies.dart`. It holds the `Dependencies` class (one `final` field per repository interface, plus `Clock`) and the named constructor `Dependencies.fake(scenario: …, clock: …)`, which builds every fake. A's `main.dart` and `app.dart` only consume it. Every fake gets tests under every scenario.

## 4. Feature use cases owned by Agent A (pure Dart, in `features/<x>/domain`)

| Use case | Feature | What it computes |
|---|---|---|
| `validateEmail`, `validatePassword` (minimum 8 characters), `validateName` | auth | Form validation results (enums, not text) |
| `BuildDashboard` | home | Next scheduled post and the countdown `Duration` from `Clock`; last-7-days totals from post stats; accounts needing reconnection; first-use flag |
| `GroupActivityByDay` | activity | Activity items grouped into today, yesterday and earlier |
| `UsageSummary` | plans / settings | Usage against plan limits; whether the limit is reached |
