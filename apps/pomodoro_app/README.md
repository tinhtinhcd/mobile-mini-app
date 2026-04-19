# Pomodoro App

## Purpose

`pomodoro_app` is a focused timer app built on the shared monorepo platform.
It is one of the two active workspace apps and serves as a concrete example of
how the shared timer, habit, discipline, notification, and monetization layers
fit together.

## Current Features

- focus, short break, and long break sessions
- preset-based session durations
- persisted timer snapshots for safe restore
- local completion notifications
- habit tracking and streaks
- weekly summary and coaching surfaces
- premium paywall, entitlement gating, and banner ads

## Shared Packages Used

The app currently depends on:

- `app_core`
- `analytics`
- `discipline_engine`
- `habit_engine`
- `monetization`
- `notifications`
- `storage`
- `timer_engine`
- `ui_kit`

## Premium Gates

Premium currently unlocks:

- advanced coaching and weekly review
- premium duration presets
- ad removal

The core timer flow remains usable without premium state.

## Test Coverage

Current tests cover:

- coaching logic
- core integration flow such as launch, start, pause, reset, mode switching,
  safe restore, drawer navigation, and paywall access

## Current Limitations

- the app README is intentionally short and only documents the current shipped
  flow
- advanced infrastructure behavior still depends on shared package maturity
- future Pomodoro-specific features should stay thin and continue leaning on
  shared packages where possible
