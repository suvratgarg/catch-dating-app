# Native Branding Assets

`generate_native_brand_assets.dart` keeps native launcher and splash branding
aligned with the cached design tokens in
`design_context_pack/design_system/tokens.json`.

Run it after token or base icon changes:

```bash
dart run tool/branding/generate_native_brand_assets.dart
```

The script regenerates:

- the launcher web colors and native splash colors in `pubspec.yaml`
- `assets/branding/generated/catch_icon_dev.png`
- `assets/branding/generated/catch_icon_staging.png`
- Android `dev`/`staging` launcher icon resource overlays
- iOS `AppIcon-dev` and `AppIcon-staging` asset catalogs
- macOS `AppIcon-dev` and `AppIcon-staging` asset catalogs
- `tool/branding/native_branding.generated.json`

Production keeps using `assets/branding/catch_icon.png` and the default
`AppIcon` catalogs until the base logo is intentionally redesigned.
