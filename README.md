# Mobile App Factory

A Flutter monorepo for building multiple mobile applications from a shared foundation.

The core problem this repository solves is repetition. Small and mid-sized mobile products often re-implement the same shell, routing, theming, persistence, monetization, notifications, and reporting patterns for each new app. That increases delivery time, multiplies maintenance cost, and makes quality uneven across products. This codebase consolidates those concerns into reusable packages so new apps can be assembled quickly without starting from a blank project.

This approach is useful when shipping multiple focused applications matters more than building one large product. Startups, small product teams, studios, and solo developers can use the same foundation to launch and iterate on several apps in parallel while keeping the codebase operationally simple.

## Architecture Overview

The repository uses a single Flutter workspace with app-specific code at the edge and reusable modules at the center.

```text
mobile-mini-app/
  apps/
    pomodoro_app/
    fasting_app/
    ...additional app seeds and prototypes
  packages/
    app_core/
    design_system/
    ui_kit/
    localization/
    analytics/
    storage/
    notifications/
    monetization/
    timer_engine/
    habit_engine/
    discipline_engine/
    ...future placeholders
  tools/
    widgetbook/
```

### Monorepo structure

- `apps/` contains standalone Flutter applications with branding, app-specific configuration, route wiring, and thin presentation logic.
- `packages/` contains reusable modules that can be shared by many apps without duplicating implementation.
- `tools/` contains developer tooling, including Widgetbook for validating shared UI components.

The monorepo keeps dependency changes, package evolution, and app integration in one place. Shared package updates can be tested against active apps immediately instead of being versioned and coordinated across multiple repositories.

### Shared packages and modules

The current workspace is centered around a few clear layers:

- `app_core`: shared application shell, router creation, theme composition, navigation primitives, and startup structure.
- `design_system`: design tokens, spacing, typography, shell dimensions, and layout primitives.
- `ui_kit`: reusable widgets built on top of the design system.
- `storage`: local persistence abstractions and implementations, including timer snapshot storage.
- `timer_engine`: reusable timer state, sessions, snapshots, statistics, and timer controller boundaries.
- `habit_engine`: higher-level habit tracking, streaks, summaries, history, and coaching reports.
- `discipline_engine`: rule-based commitment, status, pressure, and recovery logic layered on top of habit data.
- `monetization`, `notifications`, `analytics`, `localization`: cross-cutting concerns shared by active apps.

This separation keeps business rules in focused packages rather than scattering them across app folders.

### Design system reuse

The design system is intentionally split into two layers:

- `design_system` defines stable tokens and layout rules.
- `ui_kit` provides the concrete widgets apps assemble into screens.

That split makes it possible to preserve a consistent interaction model across apps while still allowing each app to express a different accent color, copy, or screen composition. In practice, new apps reuse the same shell, card patterns, compact stats, buttons, selectors, and scaffold behavior rather than re-creating them.

### Local-first architecture

The repository is designed around local execution and local persistence.

- Core flows continue to work without a backend dependency.
- State is persisted on-device for fast startup and offline behavior.
- Domain engines operate on local models rather than remote APIs.

This matters for utility apps because responsiveness, reliability, and low operational overhead are usually more important than distributed consistency. For focused apps such as timers, trackers, or lightweight planners, local-first design removes backend complexity while still supporting meaningful user value.

## Key Design Principles

### Modularity and separation of concerns

Each package has a narrow responsibility. Timer state does not live in the shell. Monetization policy does not live in the app UI. Drawer and routing primitives are shared in `app_core`, while app-specific routes stay in each application. This makes change impact easier to reason about and reduces accidental coupling.

### Reusability across applications

The foundation is optimized for repeated use. New apps should reuse:

- the app shell
- routing setup
- shared design tokens
- common widgets
- persistence abstractions
- monetization and notification infrastructure
- reusable domain engines such as timer, habit, and discipline logic

Only the app-specific domain rules, copy, branding, and thin presentation wiring should be new.

### Scalability of the codebase

This architecture scales by adding focused packages and thin apps rather than growing one large application layer. As more apps are added, the goal is not to centralize every decision, but to keep reusable concerns stable and push app-specific behavior to the edges.

### Maintainability and developer productivity

A monorepo only pays off if it is easy to change safely. Shared packages reduce duplication, workspace-level analysis catches cross-package breakage early, and new apps inherit proven defaults. That lowers the cost of maintenance and improves iteration speed.

## How New Apps Are Created in < 3 Days

The target workflow is pragmatic, not magical. The speed comes from reusing a stable foundation, not from code generation alone.

1. Choose the closest app shape.
   Start from an existing thin app layer such as `pomodoro_app` or `fasting_app`, depending on whether the new product is timer-like, tracker-like, or another focused utility.

2. Define app identity.
   Create the new app folder, set the app name, title, accent color, icons, and platform metadata.

3. Wire the shared shell.
   Reuse `app_core` for application definition, router creation, header, footer, drawer behavior, and scaffold composition.

4. Reuse shared UI.
   Build the main screen from `design_system` and `ui_kit` primitives instead of custom one-off widgets.

5. Connect the relevant domain package.
   Use `timer_engine`, `habit_engine`, `discipline_engine`, or another shared module for core behavior. Only app-specific thresholds or rules should be added locally.

6. Add app-specific presentation and rules.
   Implement the few pieces that are unique to the app: copy, feature configuration, domain-specific presets, and minimal screen wiring.

7. Validate at workspace level.
   Run analyze, test, and app builds from the shared workspace so regressions across packages are caught early.

### What is typically reused

- app shell and navigation
- theming and component library
- local persistence boundaries
- monetization and ads wiring
- notification infrastructure
- analytics surface
- reusable domain engines

### What is typically new

- product framing and branding
- app-specific presets and rules
- localized copy
- thin screen composition
- store metadata and assets

## Trade-offs and Design Decisions

### Why monorepo over multi-repo

The main benefit is coordination. Shared packages evolve together with the apps that consume them. A shell change, domain package change, or design system update can be validated across active apps immediately. That is materially simpler than publishing internal packages, updating version ranges, and synchronizing multiple repositories for every cross-cutting change.

### Limitations of this approach

- Workspace changes can affect many apps at once, so discipline around package boundaries matters.
- Build and analysis scope grows as the workspace grows.
- Teams need consistent conventions, or the monorepo becomes a collection of loosely related code instead of a coherent platform.
- Some apps may outgrow the shared assumptions and need more customization than the common foundation initially anticipated.

### When this architecture may not be ideal

This approach is less suitable when:

- each app has a very different domain and shares little code
- teams are fully independent and want isolated release cadences
- backend-driven collaboration, real-time sync, or complex distributed workflows dominate the product
- a single flagship application deserves all attention instead of a portfolio of focused apps

## Real-World Use Cases

This architecture is a good fit for:

- a startup validating several utility app ideas with a small mobile team
- a studio shipping multiple niche productivity apps under one portfolio
- an internal tools team building focused employee apps with shared infrastructure
- a solo developer maintaining several local-first mobile products without backend overhead
- a product organization standardizing shell, monetization, and design patterns across small applications

## Future Improvements

### Scaling to larger teams

- stronger package ownership boundaries
- clearer contribution guides per shared module
- architectural decision records for cross-cutting changes
- more formal release discipline for shared packages

### CI/CD improvements

- affected-package analysis to avoid rebuilding the full workspace on every change
- device farm smoke tests for active apps
- automated screenshot regression checks for shared UI
- artifact publishing for internal app distributions

### Plugin ecosystem and extensions

- more formal app templates for common product types
- additional shared engines for non-timer use cases
- optional feature modules that apps can compose without inheriting unnecessary complexity
- stricter extension points around app menus, premium surfaces, and reporting layers

## Current Workspace

Active applications today:

- `apps/pomodoro_app`
- `apps/fasting_app`

The repository also contains additional app directories and package placeholders that can be promoted into the active workspace as they become real, compile-ready modules.

## Getting Started

### Prerequisites

- Flutter 3.29+
- Dart 3.7+
- Android Studio and/or Xcode

### Install dependencies

```bash
flutter pub get
```

### Run an active app

```bash
cd apps/pomodoro_app
flutter run
```

or

```bash
cd apps/fasting_app
flutter run
```

### Workspace validation

```bash
flutter analyze
```

If you use Melos:

```bash
melos run analyze
melos run test
```

## Summary

This repository is not trying to be a generic Flutter boilerplate. It is a focused app platform for producing multiple small mobile applications from a stable shared foundation. The engineering goal is straightforward: keep apps thin, keep shared modules honest, and make shipping the next app materially faster than building it from scratch.
