# Mobile App Factory

A **Flutter monorepo** designed to build and maintain many small **utility mobile apps** quickly using reusable packages, a shared design system, and a local‑first architecture.

This project focuses on **speed, reuse, and simplicity** so new apps can be created in days instead of weeks.

---

# 🚀 Vision

Build a **mobile app factory** where:

* One reusable framework powers many apps
* Most logic lives in shared packages
* Each app is lightweight and easy to maintain
* New apps can be created in **1–3 days**

Target apps are **simple utility apps** that:

* Work offline
* Have minimal UI
* Are easy to maintain
* Monetize through ads + subscription

Examples:

* Pomodoro timer
* Fasting tracker
* Resume builder
* Unit converter
* Password generator
* Text utilities

---

# 🧱 Architecture Overview

The repository uses a **monorepo structure**.

Active workspace modules that are compile-ready today:

```
mobile_app_factory/

  packages/
    app_core/
    notifications/
    storage/
    timer_engine/
    ui_kit/

  apps/
    pomodoro_app/
    fasting_app/
```

Placeholder directories also exist for future work, but they are **not** in the active workspace and are **not compile-ready yet**:

* `packages/monetization`
* `packages/export`
* `packages/form_engine`
* `packages/tool_engine`
* `apps/resume_builder_app`

## packages/

Shared reusable modules.

These contain **most of the logic**.

## apps/

Each folder is a **standalone Flutter app**.

Apps only contain:

* branding
* configuration
* feature wiring

This keeps each app small and easy to maintain.

---

# 📦 Package Responsibilities

## app_core

Application foundation used by every app.

Includes:

* app initialization
* routing
* theme setup
* configuration loading
* logging
* error handling
* base scaffold

---

## ui_kit

Reusable **design system and UI components**.

Includes:

* buttons
* cards
* input fields
* dialogs
* settings tiles
* stat widgets
* empty states
* layout primitives

All apps must use components from **ui_kit**.

---

## notifications

Active local notification layer for timer-family apps.

Includes:

* permission requests
* scheduling notifications for timer completion
* canceling or updating scheduled local notifications
* immediate local notifications

---

## storage

Active local-first persistence layer for the current timer apps.

Includes:

* `TimerSnapshotStore` abstraction
* `SharedPreferencesTimerSnapshotStore` implementation
* timer snapshot serialization boundary shared by multiple apps

Apps wire storage through providers, but persistence implementation stays in `storage`.

---

## timer_engine

Active reusable logic for timer-based apps.

Used by:

* Pomodoro
* fasting tracker
* future timer-based apps

Includes:

* timer controller
* session model
* snapshot model
* timer state
* statistics

---

## Planned Placeholder Modules

These directories exist only as placeholders right now and are not wired into the workspace yet:

* `monetization`
* `notifications`
* `export`
* `form_engine`
* `tool_engine`
* `resume_builder_app`

---

# 🎨 Design Principles

All apps follow a **consistent minimal design system**.

Principles:

* Minimal UI
* Card‑based layout
* Large spacing
* One primary action per screen
* Single accent color per app
* Reusable components only

Goals:

* Simple
* Clean
* Easy to use

---

# 💰 Monetization Model

All apps follow the same model.

## Free

* Ads enabled
* Basic features available
* Light usage limits

## Premium

* No ads
* Unlimited usage
* Advanced features

Suggested pricing:

```
$0.99 / month
$9.99 / year
```

---

# ⚙️ Tech Stack

* Flutter
* Riverpod
* go_router
* Isar or Drift
* SharedPreferences
* google_mobile_ads
* flutter_local_notifications
* pdf / printing / share_plus

Architecture goals:

* modular
* reusable
* offline‑first

---

# 🛠 Development Roadmap

## Phase 1

Foundation implemented

* Setup monorepo
* Create `app_core`
* Create `ui_kit`
* Create demo app `pomodoro_app`
* Shared theme and scaffold

---

## Phase 2

Infrastructure partially implemented

* `storage` implemented
* `notifications` implemented
* `monetization` planned
* `export` planned

---

## Phase 3

Feature engines partially implemented

* `timer_engine` implemented
* `form_engine` planned
* `tool_engine` planned

---

## Phase 4

Production apps partially implemented

Build first apps:

* Pomodoro App implemented
* Fasting Tracker implemented
* Resume Builder planned

---

# 🧑‍💻 Getting Started

## Prerequisites

Install:

* Flutter
* Dart
* Android Studio or Xcode

Check installation:

```bash
flutter --version
```

---

# ▶ Running an App

Each app is an independent Flutter project.

Example:

```bash
cd apps/pomodoro_app
flutter pub get
flutter run
```

---

# 🎯 Current Workspace Scope

The active workspace currently validates these modules together:

* `app_core`
* `notifications`
* `storage`
* `timer_engine`
* `ui_kit`
* `apps/pomodoro_app`
* `apps/fasting_app`

The placeholder modules remain outside the workspace until they have real compile-ready code.

---

# 📈 Success Criteria

The project succeeds if:

* Monorepo architecture is stable
* Shared packages contain most logic
* Apps remain small and simple
* New apps can be created in **under 3 days**

---

# 🔜 Next Step

Keep the current workspace coherent, then add new modules only when they have real compile-ready code and a clear place in the existing package boundaries.
