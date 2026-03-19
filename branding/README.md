# App Branding Assets

Source launcher icon assets live here so every app can regenerate platform icons
without hand-editing Android or iOS resource folders.

Structure:

- `branding/<app_name>/icon_source.png`
- `branding/<app_name>/icon_foreground.png`
- `branding/<app_name>/icon_background.png`
- `branding/<app_name>/flutter_launcher_icons.yaml`

Current apps:

- `pomodoro_app`
- `fasting_app`

Use `dart run scripts/generate_icons.dart <app_name>` from the repo root to
regenerate launcher icons for one or more apps.
