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

2026-11-28 · #7 · Fake data: `Dependencies` + `Dependencies.fake`, one shared `FakeDatabase`, fixtures, the six scenarios, upload and deletion simulations · Decisions:
- Fixtures follow B1, E1, E2 and the docs. Where mock-ups disagree, the data wins:
  - "Studio tour, part 2" is today 19:00 (B1, E1, docs), not Tue 17 Nov (F1, D4, D9, D13).
  - "Behind the desk" is assisted on Instagram today 21:00 (E1, G1, G2), not published yesterday (F1, B3).
  - "Mic test": YouTube published, Instagram processing, TikTok failed (F4); 0:21 video (F4 reuses 0:38).
  - Extra published posts "Desk cable fix" (Mon 12:00) and "Lighting test" (Wed 18:30) from E2.
  - Stats add up to B1's last 7 days: 12 480 views, 1 932 likes, 214 comments. Morning b-roll matches F3.
  - Drafts are not on the calendar (E2 shows them on Fri and Sat; D12 says Unboxing has no time set).
  - Morning b-roll deletes: YouTube automatic, Instagram and TikTok assisted (docs), not Instagram automatic and Facebook (F6, F7).
- `freeLimit` keeps the populated posts and activity; only the plan, accounts (no TikTok) and usage differ.
- Auth starts signed out in every scenario; `signInWithGoogle()` signs in as "Lyes B.".
- `error` fails list loads only (posts, post, accounts, activity, gallery, caption suggestions), so sign-in and settings still work.
- `offline`: uploads pause and automatic deletes fail; reading the cached data still works.
- Cancelling a scheduled post removes it and gives back one video of the month's usage.
- Dev-menu hooks live on the fakes: `FakePostsRepository.triggerAssistedReminder`, `FakeConnectivityRepository.setOnline`.


2026-11-28 · #12 · F1 Library (tabs, status lines, platform marks) and F2 empty, with the shared skeleton and error views · Decisions:
- Domain rule `relativeDayOf` added for "today / yesterday / tomorrow" labels.
- Tabs: Scheduled = scheduled or publishing; Failed = failed or partially failed; drafts never show.
- View counts use the locale's grouping ("8,204"); the mock-up shows "8 204".
- `/library` still routes to `PlaceholderPage` until `app_router_test` provides repositories (issue #9).
- Reported to A on #9: `AppSegmentedControl` truncates "Scheduled" and "Published" at 412 dp.

2026-11-28 · #14 · F3 post detail (totals, per-platform status, links, refresh age) and F4 failure card with reconnect and retry · Decisions:
- Statistics (totals, per-platform views and likes, refresh age) show only on plans with statistics; otherwise rows show the publish time.
- F4 header reads "Failed Thu 12 Nov, 13:30" (F3's absolute style) instead of "Today, 13:30".
- "Reconnect and retry" reconnects directly until A exports `showReconnectDialog` (C5, issue #9).
- The "···" button opens a sheet with Edit everywhere and Delete everywhere.

2026-11-28 · #17 · F5 edit everywhere (title, caption, per-platform scope, apply count) · Decisions:
- Rows follow the post's real targets; F5's Facebook row for "Morning b-roll" is not shown (the fixture has no Facebook target).
- Platforms not posted yet take the whole edit before they go out; published ones follow the capability table.
- The form loads the post once; cubits avoid `Stream.first` on the fakes, which hangs widget tests (the cancel completes outside the test's fake clock).

2026-11-28 · #20 · F6 delete confirmation, F7 live delete result, and the library routes serving the real F1–F7 pages · Decisions:
- Rows follow the post's targets and the capability table: Instagram and TikTok deletes are assisted (F6 shows Instagram automatic and a Facebook row).
- F7 Retry runs `deleteEverywhere` again: failed automatic platforms retry, assisted ones keep waiting.
- "Open <platform>" pushes G3 (`assistedDeleteFor`); Done and close go to `/library`.

2026-11-28 · #21 · F4 opens A's reconnect prompt (C5) before reconnecting and retrying · Decisions:
- The account is the failed target's, else any account on that platform; without one it reconnects and retries directly.

2026-11-28 · #23 · Composer part 1: D1 pick video (gallery and drafts tabs), D2/D3 upload, D12 drafts; a shell route shares one ComposerCubit across /compose · Decisions:
- D1 preselects the first gallery video, as on the mock-up.
- Continue (D2 → D4) stays available while uploading; it is disabled only after a failed upload.
- D12 rows read "Edited <age> · <time or no time set>"; the mock-up's "3 platforms" variant is not used.
- New domain rules: `draftFromPost` and `elapsedBetween` (moved from the library).

2026-11-28 · #25 · Composer part 2: D4 composer, D6 cover, D7 TikTok settings; closing saves a draft · Decisions:
- Default platforms: every connected platform the video fits (X only with a plan that has X), applied once; a resumed draft keeps its own.
- D4 lists connected platforms only; an expired account (TikTok in the fixtures) stays selectable and is flagged by the D8 check.
- The caption is an `AppTextField` with a "Caption" label (the mock-up shows plain text).
- D6 frames are 52 dp wide and scroll under 412 dp, to keep 48 dp tap targets.

2026-11-28 · #26 · Composer part 3: D5 text per platform (YouTube title and description, reset) and D11 caption variants · Decisions:
- A platform text equal to the main caption, without a title, is not kept as a change.
- D11 on a plan without variants offers "See plans" (H2) instead of the list.

2026-11-28 · #28 · Composer part 4: D8 platform check with fixes, D9/D10 schedule sheet, D13 scheduled, H3 on the monthly limit; every composer route is real · Decisions:
- "Continue with N platforms" drops the platforms with a problem, then asks When if no time is set.
- A D8 row shows its platform's first problem (sign-in before TikTok privacy).
- The schedule sheet proposes an hour from now on the next quarter; the day strip starts today (the mock-up shows a Mon–Sun week); 15-minute steps.
- D13 splits automatic and assisted platforms from each account's mode.

2026-11-28 · #30 · Calendar: E1 day, E2 week, E3 empty day, E4 reschedule, edit or cancel · Decisions:
- A post appears once per day, at its earliest target time that day; drafts never appear.
- "Assisted · <platform>" when every platform of a scheduled post publishes assisted (capability table).
- Only posts that can still change (every target scheduled) open E4; the others open F3/F4.
- Reschedule reuses the composer's When sheet (exported from the composer barrel).

2026-11-28 · #32 · G2 assisted posting and G3 assisted delete; G1 requested from A (#31) · Decisions:
- The checklist can be ticked by hand; "Open <platform>" ticks the steps it does (caption copied, app opened).
- G2 opens the platform's home (`platformHomeUri`); G3 opens the post's own link when known.
- G1 needs flutter_local_notifications and Android setup (A's area); the fakes' `triggerAssistedReminder` already drives the flow.
