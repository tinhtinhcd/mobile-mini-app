# Monorepo Architecture

Repo layout:

mobile_app_factory/
packages/
apps/

---

## Packages

app_core
foundation code used by every app

Includes:
routing
theme
app config
base scaffold
logging
error handling

---

ui_kit

Design system and reusable UI components.

Includes:
buttons
cards
inputs
dialogs
settings tiles
stat widgets
empty states

---

monetization

Shared monetization framework.

Includes:
ads manager
subscription manager
entitlement logic
paywall UI

---

storage

Local data layer.

Includes:
Isar database
SharedPreferences wrapper
repository pattern

---

notifications

Local reminders.

Includes:
permission handling
notification scheduling
reminder helpers

---

export

Data export utilities.

Includes:
PDF export
CSV export
file sharing

---

timer_engine

Reusable logic for timer-based apps.

Includes:
timer controller
session model
timer history
statistics

---

form_engine

Reusable logic for form-based apps.

Includes:
form models
validation
draft autosave
export integration

---

tool_engine

Reusable logic for simple tools.

Includes:
input/output pattern
history storage
favorites

---

## Apps

Each app is a full Flutter project.

Example:

apps/pomodoro_app

Contains:
main.dart
app_config.dart
app specific screens
icons and branding

App imports shared packages.