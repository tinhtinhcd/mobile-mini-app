# Icon Pipeline

This repo uses shared source assets under `branding/` and `flutter_launcher_icons`
to generate Android and iOS launcher icons reproducibly.

## Source assets

Each app keeps its icon source in:

- `branding/<app_name>/icon_source.png`
- `branding/<app_name>/icon_foreground.png`
- `branding/<app_name>/icon_background.png`
- `branding/<app_name>/flutter_launcher_icons.yaml`

`icon_source.png` drives iOS and the standard Android icon.

`icon_foreground.png` and `icon_background.png` drive Android adaptive icons.

## Generate icons

From the repo root:

```bash
dart run scripts/generate_icons.dart pomodoro_app fasting_app
```

Or regenerate all configured icons:

```bash
dart run scripts/generate_icons.dart
```

The script runs `flutter_launcher_icons` in each app package, so generated icon
sets stay in sync with the shared branding sources.

## Add a future app

1. Create `branding/<app_name>/`.
2. Add `icon_source.png`.
3. Add `icon_foreground.png` and `icon_background.png` if the app should use
   adaptive Android icons.
4. Add `branding/<app_name>/flutter_launcher_icons.yaml`.
5. Add `flutter_launcher_icons` to the app's `dev_dependencies`.
6. Run `dart run scripts/generate_icons.dart <app_name>`.

## Active apps

- `pomodoro_app`: warm focus timer icon
- `fasting_app`: cool fasting hourglass icon
