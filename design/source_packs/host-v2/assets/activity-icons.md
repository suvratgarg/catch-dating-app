# Catch — Iconography & Activity Glyphs

**System:** [Phosphor Icons](https://phosphoricons.com) — regular (outline) weight.
The Catch app ships on Phosphor glyphs; bespoke per-activity emblems are a *deferred*
design task (ship on Phosphor now, swap emblems later).

**Loading (CDN):** the app's bundled glyph set isn't in the context pack, so artifacts
load Phosphor from CDN. Add to `<head>`:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.1/src/regular/style.css">
<!-- usage --> <i class="ph ph-heart"></i>
```

Regular weight is the default. Do **not** mix thin/duotone. Tint a glyph with the activity
accent only on an activity surface; otherwise glyphs are `--ink` / `--ink2`.

## Activity → Phosphor glyph map

| ActivityKind | Pigment (light accent) | Phosphor glyph |
|---|---|---|
| social run | `#D85A3C` | `ph-sneaker-move` |
| running | `#C9482E` | `ph-person-simple-run` |
| walking | `#6E9A5A` | `ph-person-simple-walk` |
| pickleball | `#2F9E7A` | `ph-ping-pong` |
| padel | `#2E9AA0` | `ph-tennis-ball` |
| tennis | `#4E9A4E` | `ph-tennis-ball` |
| badminton | `#4F70C8` | `ph-shuttlecock` |
| cycling | `#3A6FD0` | `ph-bicycle` |
| spin class | `#3E55C0` | `ph-bicycle` |
| yoga | `#8A5FB0` | `ph-flower-lotus` |
| strength training | `#B0573C` | `ph-barbell` |
| pub quiz | `#4356A8` | `ph-brain` |
| bar crawl | `#B14488` | `ph-beer-stein` |
| dinner | `#C44D6A` | `ph-fork-knife` |
| singles mixer | `#D85A6E` | `ph-martini` |
| open activity | `#7A7166` | `ph-sparkle` |

## Common UI glyphs

| Use | Glyph |
|---|---|
| Like | `ph-heart` (filled `ph-fill ph-heart` when active) |
| Message | `ph-chat-circle` |
| List tick | `ph-check` (tint = activity accent on activity surfaces) |
| Search | `ph-magnifying-glass` |
| Filters | `ph-sliders-horizontal` |
| Calendar | `ph-calendar-blank` |
| Location | `ph-map-pin` |
| Save | `ph-bookmark-simple` |
| Settings | `ph-gear` |
| Back | `ph-arrow-left` |
| More | `ph-dots-three` |

**Emoji:** never. **Unicode icons:** only `·` (meta separator) and `–` (mono range dash).
