# Architecture Summary

This file is a short architecture summary. The detailed source of truth lives in
`SYSTEM_DESIGN.md`.

## Stable Rules

The monorepo follows a small set of stable structural rules:

- apps depend on packages
- packages do not depend on apps
- reusable infrastructure belongs in shared packages
- product-specific rules and presentation stay in app folders

## Current Active Architecture

The active package graph is centered on:

- `app_core`
- `design_system`
- `ui_kit`
- `storage`
- `notifications`
- `monetization`
- `analytics`
- `localization`
- `timer_engine`
- `habit_engine`
- `discipline_engine`

The active workspace apps are:

- `apps/pomodoro_app`
- `apps/fasting_app`

## What This Repo Is Not

This repository should not be described as if all future package families are
already implemented. Older planning ideas such as form engines, tool engines,
or export layers are future directions, not the active architecture center.

## Why This Summary Exists

The repo had older planning documents that mixed current implementation with
future possibilities. This file now exists only to provide a short, stable
overview and to point readers to `SYSTEM_DESIGN.md` for the detailed current
design.
