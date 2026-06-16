# Celebration — Audio

Optional one-shot sounds layered on top of the haptic for full-screen
celebration moments (`CatchCelebrationScreen` via
`CelebrationEffectsController`). The haptic always fires; the sound is a
graceful enhancement that no-ops if the file is absent, so the app ships and
behaves correctly before these are added.

Source from [Zapsplat](https://www.zapsplat.com) (free with attribution) or
[Freesound.org](https://freesound.org) (CC0 / CC-BY). Each file should be
**MP3**, **mono or stereo**, **44.1kHz**, **< 80kB**, trimmed of leading
silence and normalized to roughly -3 dBFS peak.

## Inventory

| File | Length | Used for | Search terms |
|---|---|---|---|
| `match.mp3` | 600-1200ms | New mutual match (heaviest) | "celebration chime sparkle", "magical success reveal", "positive notification rise" |
| `event_created.mp3` | 400-800ms | Host published an event | "success confirm bright", "publish complete shimmer", "achievement soft" |
| `event_joined.mp3` | 400-800ms | Attendee booked an event | "booking confirm pop", "join success", "soft positive ding" |
| `checked_in.mp3` | 200-400ms | Self check-in (lightest) | "soft confirm tap", "check-in blip", "gentle success tick" |

Drop the files here with these exact names; no code change is needed —
`CelebrationEffectsController` already references them by path and tunes the
per-kind volume.
