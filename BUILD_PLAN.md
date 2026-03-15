# Build Plan

---

## Phase 1

Goal:
create monorepo skeleton.

Tasks:

create repo structure

packages/
app_core
ui_kit

apps/
pomodoro_app

setup Flutter workspace

implement:
base theme
routing
shared scaffold
UI components

Result:
pomodoro demo app runs.

---

## Phase 2

Add shared infrastructure.

packages:
storage
notifications
monetization
export

integrate ads
subscription skeleton
local database wrapper

---

## Phase 3

Create reusable feature engines.

packages:
timer_engine
form_engine
tool_engine

Timer engine supports:
start
pause
resume
session history

Form engine supports:
form models
validation
autosave

Tool engine supports:
input/output tools
history

---

## Phase 4

Build first production apps.

pomodoro_app
fasting_app
resume_builder_app

Each app should take only a few days to build.

---

## Definition of success

New app can be created in less than 3 days.

Most code reused from packages.