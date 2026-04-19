# Build Roadmap

## Purpose

This file tracks the current delivery roadmap for the monorepo as it exists
today. It is not a speculative greenfield plan anymore; it reflects what is
already built, what is being hardened, and what remains future work.

## Completed

The following pieces are already present in the current repository:

- Flutter workspace with shared packages and active apps
- shared shell and routing through `app_core`
- shared visual foundation through `design_system` and `ui_kit`
- reusable `timer_engine`
- reusable `habit_engine`
- reusable `discipline_engine`
- local persistence helpers in `storage`
- local notifications package
- monetization package with paywall, entitlement, ads, and store integration
- active apps:
  - `pomodoro_app`
  - `fasting_app`
- app scaffolding script
- launcher icon generation pipeline

## In Progress

Current work should focus on hardening and alignment rather than inventing a
new package graph.

- align documentation with the actual codebase
- broaden test depth for shared infrastructure
- keep app templates and placeholders in sync with the current platform
- reduce drift between active app behavior and top-level planning docs

## Next

The next practical improvements are:

- add broader tests around storage, monetization, and notifications
- improve shared templates for future utility apps
- keep Widgetbook coverage growing with shared UI changes
- promote only selected scaffolded apps into the active workspace when they
  have real product behavior

## Deferred Future Families

These are valid future directions, but they are not active core platform
modules today:

- form-oriented engines
- simple tool-oriented engines
- export features such as PDF, CSV, or file sharing

If those families become real product needs, they should be introduced from
concrete app requirements rather than from documentation alone.

## Definition of Success

The platform is succeeding when:

- a new utility app can be scaffolded quickly
- most shell and infrastructure code comes from shared packages
- active apps stay thin
- shared engines remain reusable across multiple products
- documentation stays aligned with implementation instead of drifting behind it
