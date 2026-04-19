# System Design

## Purpose

This repository is a reusable Flutter platform for building multiple focused
utility apps from one shared monorepo.

The core design choice is simple:

- keep app-specific code thin
- centralize reusable behavior in packages
- add new apps by composing existing platform pieces instead of rebuilding
  infrastructure

That approach is a good fit for local-first timer, tracker, and other compact
utility apps that share the same shell, visual language, and runtime services.

## Repository Shape

At a high level the repository is split into three main zones:

```text
mobile-mini-app/
  apps/
  packages/
  tools/
```

- `apps/` contains product-specific Flutter applications.
- `packages/` contains reusable platform modules and domain engines.
- `tools/` contains shared tooling such as Widgetbook.

Dependency direction is intentionally one-way:

- apps depend on packages
- higher-level packages depend on lower-level packages
- packages do not depend on app code

## Shared Package Boundaries

### Foundation and Shell

`packages/app_core`

Responsibility:

- defines the shared app contract through `AppDefinition`
- creates the router through `createAppRouter`
- provides `FactoryApp`, `FactoryScaffold`, drawer/menu destinations, and app
  shell behavior
- centralizes shared theme wiring and startup timing helpers

Boundary:

- owns shell and navigation patterns
- does not own app-specific business rules or screen logic

### Visual Language

`packages/design_system`

Responsibility:

- colors, spacing, typography, radii, shell metrics, and layout primitives
- shared theme construction

Boundary:

- stable tokens and layouts only
- no app-specific widgets

`packages/ui_kit`

Responsibility:

- reusable widgets built on top of the design system
- buttons, cards, compact stats, selection pills, timer display cards,
  premium callouts, and fixed utility-screen layouts

Boundary:

- feature widgets and reusable surfaces
- no app-specific screens

### Cross-Cutting Platform Services

`packages/storage`

- timer snapshot persistence
- JSON-backed object persistence for local app state

`packages/notifications`

- local notification initialization
- timezone handling
- scheduling, updating, canceling, and permission requests

`packages/monetization`

- entitlement state
- paywall controller and paywall sheet
- ad service interfaces and Google Mobile Ads integration
- store purchase integration through `in_app_purchase`

`packages/analytics`

- analytics event contracts and service abstraction
- debug logger implementation for development

`packages/localization`

- generated localization delegates and translations

### Reusable Domain Engines

`packages/timer_engine`

- timer lifecycle
- timer snapshots and restoration
- tracked session history
- shared timer statistics

`packages/habit_engine`

- session recording on top of local persistence
- daily and weekly summaries
- streak calculation
- habit coaching report generation

`packages/discipline_engine`

- rule-based goal pacing
- "not started / on track / behind / completed" evaluation
- recovery suggestion modeling

## Runtime Composition Model

Active apps use the same broad runtime pattern:

1. create shared services and stores
2. bootstrap the app through `FactoryApp`
3. override Riverpod providers with app-specific service instances
4. restore timer snapshots before normal interaction
5. initialize analytics, notifications, monetization, and ads in deferred
   stages

That pattern is visible in both active apps and is one of the main platform
reusability points.

## Local-First Data Model

The active apps are designed to function without a backend:

- timer state can be restored from local snapshots
- habit and streak history is persisted locally
- notifications are scheduled on-device
- monetization state can use cached owned product ids for fast local startup

This keeps startup fast and avoids introducing distributed system complexity for
small utility products.

## App Composition Pattern

Apps at the edge of the monorepo usually own:

- branding and naming
- app-specific copy
- app-specific plans, presets, and pacing rules
- app-specific presentation screens
- store-facing configuration and assets

Apps should not re-implement:

- app shell and navigation
- shared design tokens
- reusable UI primitives
- timer lifecycle infrastructure
- local snapshot storage
- monetization and notification framework code

## Active App Examples

### Pomodoro

`apps/pomodoro_app`

Composition:

- `timer_engine` for focus and break sessions
- `storage` for timer snapshot persistence
- `habit_engine` for session history and streaks
- `discipline_engine` for pacing and recovery messaging
- `notifications` for completion alerts
- `monetization` for premium coaching, preset gating, and ads

### Fasting

`apps/fasting_app`

Composition:

- `timer_engine` for fasting plan timing
- `storage` for timer snapshot persistence
- `habit_engine` for completed fast history
- `discipline_engine` for daily target and recovery messaging
- `notifications` for fast completion alerts
- `monetization` for advanced plan gating, coaching, and ads

## Tooling

`tools/widgetbook`

- playground for shared UI components
- lets the repo validate and iterate on `ui_kit` surfaces outside full app runs

`scripts/create_app.dart`

- generates thin app scaffolds wired to `app_core` and `ui_kit`
- supports the future-app pipeline without immediately expanding the active
  workspace

`scripts/generate_icons.dart`

- regenerates launcher icons from shared branding configs under `branding/`

## Current Limitations

The platform is real, but not every folder has the same maturity level:

- only `pomodoro_app` and `fasting_app` are active workspace apps
- many app folders are placeholders or simple scaffolds
- infrastructure test coverage exists, but is still narrower than the core app
  flows
- some older documents still describe future package families that are not part
  of the active implementation

## Scaling Guidance

To keep the monorepo healthy as more apps are added:

1. keep package boundaries clear
2. move shared behavior into packages only when reuse is real
3. keep app folders thin and product-specific
4. promote scaffolded apps into the active workspace only when they have real
   implementation
5. use the existing bootstrap pattern unless there is a concrete reason to
   diverge

## Summary

This monorepo already functions as a reusable platform for small timer and
tracker style apps. The scaling model is to add more thin apps at the edge,
evolve the shared engines at the center, and keep the documentation honest
about what is active today versus what is still exploratory.
