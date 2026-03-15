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

```
mobile_app_factory/

  packages/
    app_core/
    ui_kit/
    monetization/
    storage/
    notifications/
    export/
    timer_engine/
    form_engine/
    tool_engine/

  apps/
    pomodoro_app/
    fasting_app/
    resume_builder_app/
```

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

## monetization

Shared monetization framework.

Includes:

* ads integration
* subscription service
* entitlement logic
* paywall screen
* usage limit guards

---

## storage

Local‑first persistence layer.

Includes:

* database wrapper
* shared preferences wrapper
* repository pattern

No app should access storage directly.

---

## notifications

Local reminder system.

Includes:

* permission management
* scheduling notifications
* update / cancel reminders

Used for:

* fasting reminders
* timer alerts
* daily reminders

---

## export

Utilities for exporting user data.

Includes:

* PDF export
* CSV export
* sharing
* file save helpers

---

## timer_engine

Reusable logic for timer‑based apps.

Used by:

* Pomodoro
* fasting tracker
* workout timers

Includes:

* timer controller
* session model
* history
* statistics

---

## form_engine

Reusable engine for form‑based apps.

Used by:

* resume builder
* receipt organizer
* invoice tools

Includes:

* form schema
* validation
* autosave draft
* export integration

---

## tool_engine

Reusable engine for simple utilities.

Used by:

* converters
* generators
* text tools

Includes:

* input/output pattern
* history storage
* favorites

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

Foundation

* Setup monorepo
* Create `app_core`
* Create `ui_kit`
* Create demo app `pomodoro_app`
* Shared theme and scaffold

---

## Phase 2

Infrastructure

* Add `storage`
* Add `notifications`
* Add `monetization`
* Add `export`

---

## Phase 3

Feature Engines

* `timer_engine`
* `form_engine`
* `tool_engine`

---

## Phase 4

Production Apps

Build first apps:

* Pomodoro App
* Fasting Tracker
* Resume Builder

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

# 🎯 First Milestone

The first goal of the project is:

Make **pomodoro_app** run using shared packages:

* `app_core`
* `ui_kit`

Once this works, the architecture is validated.

---

# 📈 Success Criteria

The project succeeds if:

* Monorepo architecture is stable
* Shared packages contain most logic
* Apps remain small and simple
* New apps can be created in **under 3 days**

---

# 🔜 Next Step

Start with **Phase 1 only**:

1. Scaffold monorepo
2. Create `app_core`
3. Create `ui_kit`
4. Create `apps/pomodoro_app`
5. Implement shared theme and base scaffold

After Phase 1 succeeds, continue building the platform.
