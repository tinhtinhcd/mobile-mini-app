# Mobile App Factory

A Flutter monorepo for shipping multiple small utility apps from a shared
foundation.

The repository is optimized for products that share the same operational shape:
local-first storage, lightweight shell/navigation, reusable UI primitives,
reusable timer and tracking logic, local notifications, and simple
monetization.

## Current Status

The workspace currently has two active apps:

- `apps/pomodoro_app`
- `apps/fasting_app`

The repo also contains scaffolded or placeholder app directories for future
concepts. Those folders are useful for exploration, but they are not active
workspace members unless explicitly listed in the root `pubspec.yaml`.

## Monorepo Structure

```text
mobile-mini-app/
  apps/
  packages/
  tools/
  branding/
  docs/
  scripts/
```

- `apps/` contains standalone Flutter applications.
- `packages/` contains reusable platform modules and domain engines.
- `tools/` contains shared developer tooling, including Widgetbook.
- `branding/` contains shared launcher icon sources and configs.
- `scripts/` contains app scaffolding and asset generation helpers.

## Shared Packages In Use

The current platform is built from these active shared packages:

- `app_core`: shared app definition, routing, shell, drawer/menu screens,
  startup timing, and theme wiring.
- `design_system`: visual tokens, layout primitives, theme construction, and
  shared spacing/radius/typography rules.
- `ui_kit`: reusable widgets built on top of the design system.
- `timer_engine`: generic timer state, controller, snapshots, history, and
  statistics.
- `habit_engine`: local habit history, daily and weekly summaries, streaks, and
  coaching reports.
- `discipline_engine`: rule-based "on track / behind / recover" evaluation on
  top of habit data.
- `storage`: local persistence helpers for timer and JSON-backed snapshots.
- `notifications`: local notification scheduling and permission handling.
- `monetization`: entitlement state, paywall surfaces, ads, and store purchase
  integration.
- `analytics`: analytics abstractions with a debug logger implementation.
- `localization`: generated localization delegates and translations.

## Active Apps

### Pomodoro App

`apps/pomodoro_app` is a focus timer built from the shared shell and timer
stack. It includes:

- focus, short break, and long break sessions
- duration presets
- persisted timer snapshots
- habit tracking and weekly summaries
- discipline and coaching surfaces
- local notifications
- premium gates for advanced coaching, premium presets, and ad removal

### Fasting App

`apps/fasting_app` is a fasting timer and tracker built from the same shared
foundation. It includes:

- fasting plans such as `12:12`, `16:8`, `18:6`, and `20:4`
- persisted timer snapshots
- habit tracking and weekly summaries
- duration-aware coaching and recovery guidance
- local notifications
- premium gates for advanced plans, deeper coaching, and ad removal

## Placeholder Apps

Several app folders under `apps/` are still placeholders or light scaffolds,
including `habit_timer_app`, `water_tracker_app`, `mood_tracker_app`, and
others. They help keep the platform reusable, but they should not be described
as active products yet.

## Development Workflow

Install dependencies at the repo root:

```bash
flutter pub get
```

Run an active app:

```bash
cd apps/pomodoro_app
flutter run
```

or

```bash
cd apps/fasting_app
flutter run
```

Validate the workspace:

```bash
flutter analyze
flutter test
```

If you use Melos:

```bash
melos run analyze
melos run test
```

## App Scaffolding

New app folders can be scaffolded with:

```bash
dart run scripts/create_app.dart habit_timer_app
```

The scaffold creates a thin app shell wired to `app_core` and `ui_kit`. A new
app should only be added to the root workspace when it is ready to participate
in shared analysis, testing, and builds.

## Tooling and Assets

- `tools/widgetbook` provides a shared UI playground for reusable components.
- `scripts/generate_icons.dart` regenerates app launcher icons from shared
  branding sources under `branding/`.

## Current Gaps

The implementation is ahead of some of the documentation. In particular:

- older planning docs still reference future package families that are not part
  of the active code path
- many app folders are still placeholders
- infrastructure packages have focused test coverage, but not broad coverage
  yet

## Next Priorities

- keep documentation aligned with the current package graph and active apps
- harden shared infrastructure with broader test coverage
- improve app templates so future app promotion is faster and cleaner

## Summary

This repo is already a working utility-app platform for timer and tracker style
products. The current engineering direction is straightforward: keep apps thin,
keep shared packages honest, and only promote future app ideas into the active
workspace when they have real product behavior.
