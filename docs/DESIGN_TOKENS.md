# Design tokens — pushIt (from the Figma variables)

Source: the Figma file https://www.figma.com/design/XrhR9MSOlAIvHqvaBGIz8X, variable collection `pushIt`, modes "Light (Fog)" (the default) and "Dark". Agent A implements these in `lib/core/design_system/tokens/`. Nobody else writes raw values.

## Colours (`AppColors`, a ThemeExtension)

| Token | Light (Fog) | Dark | Use |
|---|---|---|---|
| `bg` | `#EDEDED` | `#0B0B0B` | Screen background, bottom nav (as on the PDF) |
| `surface` | `#FFFFFF` | `#1E1E1E` | Cards, inputs, sheets, dialogs |
| `block` | `#C6C6C6` | `#3A3A3A` | Video placeholders, switch off track, skeletons |
| `text` | `#141414` | `#FFFFFF` | Primary text and icons |
| `sub` | `#585858` | `#A3A3A3` | Secondary text and icons, unselected logos |
| `accent` | `#141414` | `#FFFFFF` | Primary buttons, selected states, active nav indicator, create button |
| `onAccent` | `#FFFFFF` | `#0B0B0B` | Text and icons on `accent` |
| `line` | `#D2D2D2` | `#333333` | Dividers, progress track, unselected logo ring |
| `scrim` | `#141414` at 45% | `#000000` at 60% | Behind bottom sheets and dialogs |

**Brand colours** (`brand*`, used only for platform logo glyphs):

| Platform | Light | Dark |
|---|---|---|
| YouTube | `#FF0000` | `#FF0000` |
| Instagram | `#E4405F` | `#E4405F` |
| Facebook | `#0866FF` | `#0866FF` |
| LinkedIn | `#0A66C2` | `#0A66C2` |
| Bluesky | `#0285FF` | `#0285FF` |
| TikTok | `#000000` | `#FFFFFF` |
| Threads | `#000000` | `#FFFFFF` |
| X | `#000000` | `#FFFFFF` |

**Rules:**
- Greys only, plus the brand colours on logos.
- No gradients and no shadows (`elevation: 0` everywhere).
- State (failed, warning, done) is shown with an icon and a word, never by colour alone.

## Typography (`AppTypography`, a ThemeExtension)

Font: **Hanken Grotesk**, bundled under `assets/fonts` (OFL). The colour comes from the context (`text` or `sub`), never from the style.

| Style | Weight | Size | Line height | Letter spacing | Used for |
|---|---|---|---|---|---|
| `h1` | 700 | 26 | 1.20 | −1% (−0.26) | Screen titles (Library, Accounts …), headline numbers |
| `time` | 600 | 64 | 1.00 | −2% (−1.28) | Next post time, splash wordmark |
| `title` | 600 | 20 | 1.25 | −1% (−0.20) | Card titles, sheet titles, dialog titles |
| `body` | 400 | 15 | 1.45 | 0 | Body text, list rows |
| `bodyStrong` | 600 | 15 | 1.45 | 0 | Row titles, top-bar titles, emphasised values |
| `small` | 500 | 12 | 1.35 | 0 | Secondary lines, labels, helper text |
| `tiny` | 700 | 10 | 1.20 | +2% (+0.20) | Nav labels, initials, logo-sized captions |
| `button` | 600 | 16 | 1.20 | 0 | Button labels (small buttons use `bodyStrong`) |

## Spacing (`AppSpacing`)

`xxs 4`, `xs 8`, `sm 12`, `md 16`, `lg 20`, `xl 24`, `xxl 32`, `xxxl 40`

- Screen horizontal margin: **24** (`xl`).
- Gap between stacked sections: 20–32.
- Card padding: 16.

## Radii (`AppRadii`)

| Token | Value | Used for |
|---|---|---|
| `card` | 20 | Cards, list containers |
| `input` | 14 | Text fields |
| `sheet` | 28 | Bottom sheet top corners, dialogs |
| `thumbnail` | 12 | Video thumbnails |
| `thumbnailSmall` | 8 | Small thumbnails in lists and calendar |
| `pill` | 999 | Buttons, chips, segmented control, platform logos, switch |
| `createButton` | 14 | Centre create button (56 × 40) |
| `checkbox` | 6 | Checkbox corners |

## Sizes (`AppSizes`)

| Token | Value |
|---|---|
| `buttonHeight` | 56 |
| `buttonHeightSmall` | 40 |
| `topBarHeight` | 56 |
| `bottomNavHeight` | 64 (plus the system gesture inset) |
| `createButton` | 56 × 40 |
| `icon` | 24 (small 20, tiny 16, large 32 for empty and error states) |
| `sheetHandle` | 40 × 4 |
| `minTapTarget` | 48 |
| `platformLogoLarge` / `Small` | 48 / 28 (glyph 24 / 14) |
| `avatar` | 36 (settings 56) |
| `switch` | 52 × 32, thumb 24 |
| `checkbox` / `radio` | 24 (radio dot 12) |
| `videoPreview` | 9:16 aspect; composer 126 × 224, gallery tile width = (available − 2 × 8) / 3 |
| `progressBar` | 6 high |
| `selectionRingWidth` | 2.5 (selected video thumbnail) |
| `pageDot` / `pageDotActiveWidth` | 8 / 24 (onboarding pager) |

## Platform logo states

| State | Fill | Ring | Glyph |
|---|---|---|---|
| Selected or connected | `surface` | `text`, 1.5 | Brand colour |
| Unselected or unavailable | none | `line`, 1.5 | `sub` |

## Durations (`AppDurations`)

| Token | Value |
|---|---|
| `fast` | 150 ms |
| `normal` | 250 ms |
| `slow` | 400 ms |
| `fakeLatency` | 400 ms (`slow` scenario: 2 s) |
