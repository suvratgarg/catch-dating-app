# Native Branding Assets

`generate_native_brand_assets.dart` keeps native launcher and splash branding
aligned with the cached design tokens in
`design_context_pack/design_system/tokens.json`.

Run it after token or base icon changes:

```bash
dart run tool/branding/generate_native_brand_assets.dart
```

`generate_catch_icon.swift` renders the consumer Catch launcher mark and the
host lockup from the handoff source:

```bash
swift tool/branding/generate_catch_icon.swift
```

It regenerates:

- `assets/branding/catch_icon.png`
- `assets/branding/catch_icon_square.png`
- `assets/branding/catch_icon_round.png`
- `assets/branding/catch_splash_mark_light.png`
- `assets/branding/catch_splash_mark_dark.png`
- `assets/branding/catch_hosts_logo.png`
- `assets/branding/catch_hosts_icon.png`
- Android production round launcher icon resources

`generate_native_brand_assets.dart` regenerates:

- the launcher web colors and native splash colors in `pubspec.yaml`
- `assets/branding/generated/catch_icon_dev.png`
- `assets/branding/generated/catch_icon_staging.png`
- `assets/branding/generated/catch_icon_host_dev.png`
- `assets/branding/generated/catch_icon_host_staging.png`
- `assets/branding/generated/catch_icon_host_prod.png`
- Android `dev`/`staging` launcher icon resource overlays
- Android `hostDev`/`hostStaging`/`hostProd` launcher icon resource overlays
- iOS `AppIcon-dev` and `AppIcon-staging` asset catalogs
- iOS `AppIcon-host-dev`, `AppIcon-host-staging`, and
  `AppIcon-host-prod` asset catalogs
- macOS `AppIcon-dev` and `AppIcon-staging` asset catalogs
- macOS `AppIcon-host-dev`, `AppIcon-host-staging`, and
  `AppIcon-host-prod` asset catalogs
- `tool/branding/native_branding.generated.json`

Consumer production keeps using `assets/branding/catch_icon.png` and the
default `AppIcon` catalogs until the base logo is intentionally redesigned.
Host production uses the two-line Catch Hosts icon as its base, through the
generated `AppIcon-host-prod` catalogs and Android `hostProd` launcher
resources. Dev and staging flavors use diagonal corner ribbons, so internal
builds stay visually distinct without covering the consumer or host wordmarks.
