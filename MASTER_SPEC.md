# Mobile App Factory

Goal: build multiple small utility mobile apps quickly using a reusable Flutter monorepo.

Apps should be:
- simple
- minimal UI
- offline-first
- reusable architecture

Monetization model:
free + ads + limits
subscription = unlimited + no ads

Subscription price:
$0.99/month
$9.99/year

No backend server required.

---

## Architecture

Monorepo structure:

mobile_app_factory/

packages/
app_core
ui_kit
monetization
storage
notifications
export
timer_engine
form_engine
tool_engine

apps/
pomodoro_app
fasting_app
resume_builder_app

Each app is an independent Flutter project.

Shared logic lives in packages.

---

## App types

3 reusable feature families:

Timer apps
Pomodoro
Fasting
Countdown
Workout timer

Form apps
Resume builder
Receipt organizer
Invoice generator

Tool apps
Unit converter
Password generator
Text tools
Random picker

---

## Design philosophy

Minimal
Clean
Card-based layout
Single accent color
Large whitespace
One primary action per screen

UI should look professional but simple.

---

## Monetization

Free users:
ads enabled
limited usage
basic features

Premium users:
remove ads
unlimited usage
advanced features

---

## Local-first

All apps must function offline.

Allowed storage:
Isar database
SharedPreferences

No login required.

---

## Phase roadmap

Phase 1
monorepo scaffold
app_core
ui_kit
demo app

Phase 2
storage
notifications
monetization
export

Phase 3
timer_engine
form_engine
tool_engine

Phase 4
build first real apps

---

## Coding rules

Flutter
Riverpod
go_router
clean modular architecture
shared UI components
no duplicated logic across apps