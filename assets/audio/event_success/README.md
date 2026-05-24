# Event Success — Audio Palette

Six curated stock sounds drive the kinetic companion experience. Source from
[Zapsplat](https://www.zapsplat.com) (free with attribution) or
[Freesound.org](https://freesound.org) (CC0 / CC-BY).

Each file should be **MP3 or M4A**, **mono or stereo**, **44.1kHz**, and
**< 80kB** where possible. Trim leading silence and normalize to roughly
-3 dBFS peak so volume feels consistent across the palette.

## Inventory

| File | Length | Used for | Search terms |
|---|---|---|---|
| `ui_confirm.mp3` | 200-400ms | Chip select, save, button commit | "ui confirm bright", "soft pop confirm", "interface select shimmer" |
| `transition_whoosh.mp3` | 400-700ms | Moment transition, card replace | "whoosh subtle", "transition swipe", "ui swipe air" |
| `countdown_rise.mp3` | 3-3.2s | Reveal anticipation build (loops 3s window) | "tension build cinematic", "rising drone short", "anticipation low rumble" |
| `reveal_climax.mp3` | 1.2-1.5s | Reveal climax (thunk + chime) | "magical reveal", "cinematic impact chime", "treasure unlock" |
| `ambient_warm_pad.mp3` | 8-20s (loop) | Theatrical vibe pack ambient bed (loops seamlessly) | "ambient warm pad loop", "cinematic atmosphere warm", "soft drone bed loopable" |
| `afterglow_settle.mp3` | 1.0-1.4s | Afterglow recap close | "soft bell settle", "warm chime ending", "gentle conclusion" |

## Selection guidance

- Avoid anything that reads as "phone ringtone," "video game arcade," or
  "social media notification." We want **theatrical / cinematic / premium**
  not **gamified / casual / app-jingle**.
- `ambient_warm_pad.mp3` must loop seamlessly — splice the head and tail
  by 50ms with a crossfade if the source doesn't loop cleanly.
- `countdown_rise.mp3` should peak near the end (so it climbs into the
  reveal cinematic's climax). Lower-register / sub-rumble works better than
  treble swells.
- `reveal_climax.mp3` is the marquee moment — spend the most time on this
  one. Two-stage envelope (low thunk → bright chime tail) is the target.

## License compliance

If you pull from Zapsplat, the free tier requires attribution somewhere in
the app (Settings → Credits or About page). CC-BY sounds from Freesound
need the same. CC0 / public domain sounds don't.

Add credits in [docs/event_success.md](../../../docs/event_success.md) once
sources are finalized.

## Runtime behavior

`EventSuccessLiveEffectsController` plays these via
`audioplayers.AudioPlayer`. If a file is missing, the controller falls back
to haptic-only — the app still works with zero audio files in this folder.
This unblocks UI work while audio is being sourced.
