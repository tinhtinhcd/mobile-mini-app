# System Design

## Purpose

This repository is a reusable mobile app platform implemented as a Flutter monorepo. It is designed to support rapid development of multiple focused mobile apps from one shared foundation, rather than treating each app as an isolated project.

The core architectural idea is:

- keep product-specific code thin and local to each app
- centralize repeatable capabilities into shared packages
- add new apps by composing existing platform modules instead of rebuilding them

That makes the monorepo suitable for a portfolio of timer, tracker, utility, and habit-oriented apps that share common UX, infrastructure, and runtime behavior.

## Architectural Shape

At a high level, the repository is split into three zones:

```text
mobile-mini-app/
  apps/         -> product-specific applications
  packages/     -> reusable platform modules
  tools/        -> shared developer tooling
```

Within that structure, dependencies flow inward:

- apps depend on packages
- higher-level packages depend on lower-level packages
- shared packages should not depend on app code

This keeps the monorepo platform-oriented. Apps are delivery units. Packages are the reusable system.

## Package Boundaries

The platform is organized into clear layers with narrow responsibilities.

### 1. Foundation and Shell

`packages/app_core`

Responsibility:

- defines the shared app contract through `AppDefinition`
- creates the shared router via `createAppRouter`
- provides the common application shell through `FactoryApp` and `FactoryScaffold`
- standardizes navigation, drawer behavior, startup structure, and theme wiring

Boundary:

- app-specific screens and routes are passed in from each app
- `app_core` owns the shell, not the product logic

Why it matters:

- every new app starts from the same entry model instead of inventing its own bootstrapping pattern

### 2. Design Language

`packages/design_system`

Responsibility:

- owns reusable design tokens such as colors, spacing, typography, radii, elevations, icon sizing, and layout primitives
- provides shared theme construction

Boundary:

- contains style rules and layout primitives, not feature widgets or business logic

`packages/ui_kit`

Responsibility:

- builds reusable widgets on top of `design_system`
- includes cards, buttons, stat tiles, settings rows, empty states, selection controls, timer display widgets, and premium UI surfaces

Boundary:

- contains composable UI building blocks, not app-specific screens

Why the split matters:

- `design_system` keeps visual decisions consistent
- `ui_kit` turns those rules into reusable components
- apps reuse both without copying styling or rebuilding common widgets

### 3. Cross-Cutting Platform Services

`packages/localization`

- shared localization delegates and generated translations

`packages/analytics`

- shared analytics contracts and event logging abstractions

`packages/notifications`

- local notification scheduling and notification channel concerns

`packages/monetization`

- ad integration, entitlement logic, subscription modeling, and paywall foundations

`packages/storage`

- local persistence abstractions and concrete storage helpers
- currently includes timer snapshot persistence and reusable JSON object storage helpers

Boundary for this layer:

- these packages encapsulate platform concerns that almost every app may need
- apps configure and consume them, but should not reimplement them

### 4. Reusable Domain Engines

`packages/timer_engine`

- reusable timer lifecycle, state, session, snapshot, stats, and controller logic

`packages/habit_engine`

- reusable habit tracking, summaries, streaks, coaching data, and persistence-facing services

`packages/discipline_engine`

- reusable rules for discipline status, pressure, goals, and recovery suggestions

Boundary:

- these packages own domain mechanics that can power multiple products
- apps may add presets, labels, and specialized rules, but should not duplicate the underlying engine

This layered setup creates a useful pattern:

- platform shell in `app_core`
- visual consistency in `design_system` and `ui_kit`
- shared services in cross-cutting packages
- reusable behavior in domain engines
- app-specific composition at the edge

## App Boundaries

The `apps/` directory contains full Flutter applications, but each app is intentionally thin.

An app typically owns:

- branding and naming
- app-specific route registration
- app-specific copy and screen composition
- presets, plans, or rules unique to that product
- platform metadata and store-facing assets

An app should not own:

- its own shell framework
- its own design system
- its own notification framework
- its own monetization framework
- duplicated timer, habit, or persistence infrastructure

The active apps in the workspace show this pattern:

- `apps/pomodoro_app` configures a Pomodoro-specific router, screen set, duration presets, and analytics events while reusing `timer_engine`, `storage`, `notifications`, `analytics`, `habit_engine`, `discipline_engine`, `monetization`, `app_core`, and `ui_kit`
- `apps/fasting_app` reuses the same shared foundation but swaps in fasting plans, fasting-specific copy, and fasting-specific presentation

This is the platform model in practice: different products, same foundation.

## Reuse Strategy

Reuse in this monorepo is deliberate, not accidental. The architecture encourages teams to reuse at four levels.

### 1. Reuse the app shell

New apps do not build a new startup stack. They define an `AppDefinition` and run through `FactoryApp`.

That provides:

- shared theme wiring
- shared localization integration
- shared routing conventions
- shared scaffold and drawer behavior

### 2. Reuse UI primitives instead of screens

Apps compose screens from `ui_kit` and `design_system` rather than copying fully custom screen implementations across products.

This keeps reuse flexible:

- the same cards, buttons, stat strips, and layouts can appear in multiple apps
- each app still has room for different screen flows and product framing

### 3. Reuse domain engines

The real leverage comes from engine reuse.

Examples:

- Pomodoro and fasting are different products, but both reuse `timer_engine`
- habit-style progress tracking can sit above multiple app types through `habit_engine`
- discipline and coaching logic can be layered without every app rewriting those rules

This is stronger than simple component reuse because it avoids duplicating core behavioral logic.

### 4. Reuse platform integrations

Analytics, notifications, monetization, localization, and storage are treated as platform capabilities.

That means a new app can inherit:

- proven notification scheduling patterns
- shared monetization and entitlement foundations
- consistent analytics logging abstractions
- standard local persistence patterns

The result is that new apps can focus on product behavior rather than infrastructure assembly.

## How New Apps Are Generated Quickly

This monorepo is optimized for fast app creation through scaffolding plus composition.

### Scaffold path

The repository includes `scripts/create_app.dart`, which generates a starter app under `apps/<app_name>`.

The script creates:

- `pubspec.yaml`
- `lib/main.dart`
- `lib/app_config.dart`
- a placeholder presentation screen
- a README describing the seeded app

The generated app already uses:

- `app_core` for app bootstrap and shell
- `ui_kit` for initial UI composition

So the starting point is not a blank Flutter project. It is a platform-compliant app seed.

### Activation model

Generated apps do not need to become active workspace members immediately.

The script explicitly supports a staged workflow:

- scaffold the app folder first
- explore the concept in isolation
- add the app to the root `workspace` only when it is ready to participate in shared analysis and builds

This allows the repo to act as both:

- a production workspace for active apps
- a pipeline of future app ideas and placeholders

### Why this is fast

Speed comes from minimizing the amount of code that needs to be new.

For a new app, the team usually only needs to define:

- the product identity
- the core screen flow
- app-specific rules or presets
- any additional domain logic not already represented in shared packages

Everything else is inherited from the platform.

## How the Architecture Avoids Duplication

Avoiding duplication is one of the main reasons this repository exists.

### Shared concerns live in packages, not apps

If a concern is likely to appear in more than one app, it belongs in `packages/`.

Examples:

- shell and router setup -> `app_core`
- visual tokens and layouts -> `design_system`
- reusable widgets -> `ui_kit`
- timer behavior -> `timer_engine`
- persistence helpers -> `storage`
- monetization -> `monetization`

This keeps apps from becoming slightly different copies of the same implementation.

### Apps specialize shared engines instead of cloning them

Pomodoro and fasting controllers both extend shared timer behavior and then apply product-specific rules. That is the intended duplication-avoidance pattern:

- reuse the engine
- customize with presets, plans, and event mapping
- keep app-specific logic near the app

### The workspace catches divergence early

The root `pubspec.yaml` defines a shared workspace and Melos scripts for:

- `flutter analyze`
- formatting
- tests

Because apps and packages live together, platform changes can be validated against real consuming apps immediately. That reduces the risk of silent divergence between shared modules and product implementations.

### Placeholder apps reinforce platform discipline

The repository includes seeded future apps such as `habit_timer_app`, `water_tracker_app`, and `mood_tracker_app`.

That matters architecturally because it forces the platform to stay reusable. The repo is not optimized only for the currently active apps. It is structured to support repeated app creation.

## Monorepo Advantages for This Platform

For this repository, the monorepo model provides concrete benefits.

### Shared evolution

When a package changes, active apps can be updated and validated in the same codebase without publishing internal package versions across multiple repositories.

### Faster platform feedback

If a shared timer abstraction, shell pattern, or UI primitive is too narrow, the impact becomes visible across apps immediately. That helps the platform mature faster.

### Lower setup cost for each new product

A new app inherits:

- the same dependency conventions
- the same package graph
- the same build and analysis workflow
- the same architectural rules

### Better portfolio thinking

A monorepo encourages the team to build a family of apps from common capabilities instead of repeatedly building isolated one-off projects.

## Monorepo Trade-Offs

The monorepo has real costs and should be treated as a deliberate trade-off.

### 1. Boundary discipline is mandatory

Without strong package boundaries, shared packages can become a dumping ground for unrelated logic, which makes the platform harder to reason about.

### 2. Shared changes have wider blast radius

A breaking change in a common package can affect multiple apps at once. This is good for visibility, but it requires careful validation.

### 3. Build and analysis scope grows over time

As more apps become active workspace members, full analysis and testing become more expensive. The repo will eventually need more selective CI strategies.

### 4. Not every app fits the platform equally well

The architecture is strongest when products share utility-app patterns. If a future app has radically different behavior, the team must decide whether to extend the platform or isolate the exception.

### 5. Shared abstractions can be over-engineered

There is always a risk of generalizing too early. Shared packages should emerge from repeated needs, not hypothetical reuse.

## Design Rules That Keep the Platform Scalable

To keep this monorepo effective as more apps are added, the architecture should continue following these rules:

1. Put reusable capabilities in packages only after they are proven or clearly cross-cutting.
2. Keep app folders focused on composition, branding, and product-specific behavior.
3. Prevent packages from depending on app code.
4. Prefer extending shared engines over copying and modifying them.
5. Keep UI primitives reusable and screen composition app-specific.
6. Promote scaffolded apps into the active workspace only when they are ready.

## Conclusion

This monorepo is a reusable mobile app platform, not a single-app codebase with some shared folders.

Its structure supports scalable development of multiple mobile apps by:

- enforcing package boundaries around shell, UI, services, and domain engines
- maximizing reuse through shared platform modules
- generating new apps quickly from a platform-compliant scaffold
- reducing duplication by centralizing repeated logic
- accepting monorepo trade-offs in exchange for faster portfolio development

The intended scaling model is simple: add more thin apps at the edge, evolve shared packages at the center, and keep the foundation reusable enough that the next app is materially faster to build than the last one.
