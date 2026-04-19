# Fasting App

## Purpose

`fasting_app` is a fasting timer and tracker built on the same shared platform
as `pomodoro_app`. It is one of the two active workspace apps and demonstrates
how the shared stack adapts to a different timer and coaching model.

## Current Features

- fasting plans including `12:12`, `16:8`, `18:6`, and `20:4`
- persisted timer snapshots for safe restore
- local completion notifications
- habit tracking and streaks
- weekly summary and fasting-specific coaching
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

- advanced plans
- deeper coaching and weekly review
- ad removal

The core fasting flow remains usable without premium state.

## Test Coverage

Current tests cover:

- fasting coaching logic
- core integration flow such as launch, start, pause, reset, plan switching,
  safe restore, drawer navigation, and paywall access

## Current Limitations

- the app is documented as an active utility app, not as a complete production
  health product
- shared infrastructure still needs broader package-level testing over time
- future fasting-specific features should keep reusing the shared timer and
  tracking layers where possible
