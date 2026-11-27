# Screens — pushIt MVP

Design PDF: `docs/design/pushIt_UI_Light_and_Dark.pdf`. **Light page = #, dark page = # + 54.** Figma frames have the same names (`D4 · Composer`) on the pages "App · Light" and "App · Dark".

Navigation: bottom tabs Home, Calendar, [create], Library, Accounts. Settings opens from the Home avatar, Activity from the Home bell. The create button opens `/compose` full screen.

| # | ID | Screen | Route / kind | Owner | Features | States and notes | PDF light / dark |
|---|---|---|---|---|---|---|---|
| 1 | A1 | Splash | `/splash` | A | F17 | Wordmark; decides onboarding, sign-in or home | 1 / 55 |
| 2 | A2 | Onboarding 1 | `/onboarding (page 0)` | A | F17 | Pager, Skip | 2 / 56 |
| 3 | A3 | Onboarding 2 | `/onboarding (page 1)` | A | F17 | Pager, Skip | 3 / 57 |
| 4 | A4 | Onboarding 3 | `/onboarding (page 2)` | A | F17 | CTA: Connect an account | 4 / 58 |
| 5 | A5 | Sign in | `/sign-in` | A | F1 | Validation errors; Google; forgot password | 5 / 59 |
| 6 | A6 | Create account | `/register` | A | F1 | Validation; terms checkbox | 6 / 60 |
| 7 | A7 | Verify email | `/verify-email` | A | F1 | Resend countdown | 7 / 61 |
| 8 | A8 | Reset password | `/reset-password` | A | F1 | Sent confirmation | 8 / 62 |
| 9 | B1 | Home | `/home (tab)` | A | F13, F12 | Countdown from Clock; reconnect alert; last 7 days | 9 / 63 |
| 10 | B2 | Home, first use | `/home, firstUse state` | A | F13, F17 | Three-step checklist | 10 / 64 |
| 11 | B3 | Activity | `/home/activity` | A | F9, F20 | Grouped by day; retry action; 30 days | 11 / 65 |
| 12 | C1 | Accounts | `/accounts (tab)` | A | F2 | Mode, health; Reconnect; Add account | 12 / 66 |
| 13 | C2 | Add account | `/accounts/add` | A | F2, F14, F15 | 8 platforms; X locked on Free | 13 / 67 |
| 14 | C3 | Connect, choose mode | Bottom sheet on C2 | A | F2 | Sign in vs Assisted without sign-in | 14 / 68 |
| 15 | C4 | Account detail | `/accounts/:accountId` | A | F2 | Mode, health, expiry, delete method; Reconnect, Disconnect | 15 / 69 |
| 16 | C5 | Reconnect prompt | Dialog (exported showReconnectDialog) | A | F2, F9 | Used by C1, B1 and F4 | 16 / 70 |
| 17 | C6 | X on paid plans | Bottom sheet on C2 | A | F15, F10 | See plans | 17 / 71 |
| 18 | D1 | Pick video | `/compose (full screen)` | B | F3, F19 | Gallery and Drafts tabs; empty gallery | 18 / 72 |
| 19 | D2 | Uploading | `/compose/upload, uploading` | B | F3 | Progress, Pause, Cancel | 19 / 73 |
| 20 | D3 | Upload paused | `/compose/upload, paused` | B | F3 | No connection; Retry now | 20 / 74 |
| 21 | D4 | Composer | `/compose/post` | B | F4, F5 | Caption; platform logos; rows; Schedule | 21 / 75 |
| 22 | D5 | Text per platform | `/compose/post/captions` | B | F4, F16 | YouTube title; Reset; Suggest variants | 22 / 76 |
| 23 | D6 | Cover frame | `/compose/post/cover` | B | F4 | Frame strip; selection | 23 / 77 |
| 24 | D7 | TikTok settings | `/compose/post/tiktok` | B | F4 | Privacy required (no default); switches off by default | 24 / 78 |
| 25 | D8 | Platform check | `/compose/post/check` | B | F4 | Issues per platform; continue with N | 25 / 79 |
| 26 | D9 | Schedule, one time | Bottom sheet on D4 | B | F5 | Week strip; time wheel | 26 / 80 |
| 27 | D10 | Schedule, per platform | Bottom sheet on D4 | B | F5 | Time per platform | 27 / 81 |
| 28 | D11 | Caption variants | Bottom sheet on D5 | B | F16 (Could, Pro) | Use per platform | 28 / 82 |
| 29 | D12 | Drafts | `/compose/drafts` | B | F19 | Resume, discard; empty | 29 / 83 |
| 30 | D13 | Scheduled | `/compose/scheduled` | B | F5, F7 | Confirmation; View in calendar | 30 / 84 |
| 31 | E1 | Calendar, day | `/calendar (tab), day` | B | F5 | Week strip with dots; timeline; failed row with retry | 31 / 85 |
| 32 | E2 | Calendar, week | `/calendar, week` | B | F5 | Seven days; Nothing scheduled | 32 / 86 |
| 33 | E3 | Calendar, empty day | `/calendar, empty day` | B | F5 | Empty state; New post | 33 / 87 |
| 34 | E4 | Reschedule or cancel | Bottom sheet on E1/E2 | B | F5 | Only before publishing starts | 34 / 88 |
| 35 | F1 | Library | `/library (tab)` | B | F8 | Filter: All, Scheduled, Published, Failed | 35 / 89 |
| 36 | F2 | Library, empty | `/library, empty` | B | F8 | Empty state; New post | 36 / 90 |
| 37 | F3 | Post detail | `/library/:postId` | B | F6, F8, F12 | Totals; per-platform status, stats, link | 37 / 91 |
| 38 | F4 | Post, failed | `/library/:postId, failed` | B | F6, F9 | Reconnect and retry (showReconnectDialog) | 38 / 92 |
| 39 | F5 | Edit everywhere | `/library/:postId/edit` | B | F11 | Editable vs not editable per platform | 39 / 93 |
| 40 | F6 | Delete everywhere | `/library/:postId/delete` | B | F8 | Per-platform method; confirm | 40 / 94 |
| 41 | F7 | Delete result | `/library/:postId/delete/result` | B | F8 | Removed, waiting for user, failed + retry | 41 / 95 |
| 42 | G1 | Assisted notification | Local notification (or dev-menu simulate) | B | F7 | Open app; remind in 30 min | 42 / 96 |
| 43 | G2 | Assisted posting | `/assisted/:postId/:platform` | B | F7 | Steps; Open app; I posted it; Remind me | 43 / 97 |
| 44 | G3 | Assisted delete | `/assisted/:postId/:platform/delete` | B | F8 | Open TikTok; I deleted it; Keep it | 44 / 98 |
| 45 | H1 | Settings | `/settings` | A | F18, F1, F10 | Plan card + usage; rows; sign out; delete account; + Appearance row (deviation) | 45 / 99 |
| 46 | H2 | Plans | `/settings/plans` | A | F10 | Monthly/Yearly; Free, Pro, Studio | 46 / 100 |
| 47 | H3 | Limit reached | Bottom sheet (exported showLimitReachedSheet) | A | F10 | Opened by the composer on LimitReachedFailure | 47 / 101 |
| 48 | H4 | Notification settings | `/settings/notifications` | A | F9 | Five switches | 48 / 102 |
| 49 | H5 | Invite a creator | `/settings/invite` | A | F18 | Code; Share; Copy | 49 / 103 |
| 50 | H6 | Feedback | `/settings/feedback` | A | F18 | Kind; message; device details switch | 50 / 104 |
| 51 | H7 | Delete account | Dialog on H1 | A | F1 | Destructive confirmation | 51 / 105 |
| 52 | I1 | Offline | OfflineBanner in the shell | A (widget); all pages | — | offline scenario | 52 / 106 |
| 53 | I2 | Loading | SkeletonList in every list page | A (widget); all pages | — | slow scenario | 53 / 107 |
| 54 | I3 | Error | ErrorStateView in every list page | A (widget); all pages | — | error scenario | 54 / 108 |

## Extra routes (debug builds only, Agent A)

- `/settings/appearance`: System, Light or Dark. **A deliberate deviation:** H1 in the design has no Appearance row.
- `/settings/developer`: switch scenario, skip to signed in, simulate an assisted reminder (G1).
- `/dev/components`: the design-system gallery.

## Features (from the spec, plus F17–F20 added during UI design)

| ID | Feature | Priority |
|---|---|---|
| F1 | Account and sign-in (email, Google, verification, reset, delete account) | Must |
| F2 | Connected accounts (connect, disconnect, mode, health, reconnect before expiry, assisted without sign-in) | Must |
| F3 | Video upload (gallery or share, resumable, background, 300 MB maximum, progress, pause, retry) | Must |
| F4 | Composer and platform check (caption per platform, YouTube title, cover, TikTok settings, checks) | Must |
| F5 | Scheduler and calendar (one time or per platform, day and week, reschedule or cancel) | Must |
| F6 | Automatic publishing (per-platform status, retry without duplicates) | Must (simulated) |
| F7 | Assisted posting (notification, open app, caption copied, confirm or remind) | Must |
| F8 | Library and delete everywhere (one record per video; per-platform delete with result) | Must |
| F9 | Notifications (published, failed, reconnect; per-type switches) | Must |
| F10 | Plans and payment (Free, Pro, Studio; limits enforced) | Must (fake purchase) |
| F11 | Edit everywhere (where the platform API allows) | Should |
| F12 | Post statistics | Should |
| F13 | Home dashboard | Should |
| F14 | More platforms (Threads, LinkedIn, Bluesky) | Should |
| F15 | X on paid plans | Could |
| F16 | Caption variants (Pro) | Could |
| F17 | Onboarding | Should |
| F18 | Settings and profile | Must |
| F19 | Drafts | Should |
| F20 | Activity list (30 days) | Should |
