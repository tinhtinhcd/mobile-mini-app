# Platform Spec

## Goal

Build multiple small utility mobile apps quickly from one reusable Flutter
monorepo.

The platform is aimed at products where simplicity, local execution, and
consistent delivery matter more than backend complexity.

## Product Philosophy

Apps built on this platform should generally be:

- focused
- local-first
- operationally simple
- thin at the app layer
- built from reused infrastructure instead of duplicated scaffolding

The primary product shape today is timer and tracker style apps.

## Engineering Principles

### Shared infrastructure first

If a concern is repeated across multiple apps, it belongs in `packages/`, not
in app folders.

Examples:

- shell and routing
- design tokens and reusable widgets
- timer lifecycle
- local persistence helpers
- notifications
- monetization

### Thin apps at the edge

App folders should mostly own:

- branding
- copy
- presets and rules
- presentation composition

Apps should not duplicate:

- shell setup
- reusable domain engines
- common notification or monetization plumbing

### Reuse proven engines, not hypothetical abstractions

Shared modules should reflect concrete reuse. The current codebase is centered
on:

- `timer_engine`
- `habit_engine`
- `discipline_engine`

Additional engine families should only be added when real apps require them.

## Monetization Principles

The default monetization model is:

- free core flow
- light ads for free usage where appropriate
- premium for advanced guidance, advanced plans or modes, and ad removal

The repo should preserve a usable free path and avoid making core utility
behavior dependent on premium state.

## Non-Goals

This platform is not currently optimized for:

- backend-heavy collaboration features
- login-first products
- real-time synchronized multi-user workflows
- one giant flagship app with all features in a single codebase

It also does not claim that every speculative package in older planning notes
already exists as active implementation.

## Decision Rules

Something belongs in `packages/` when:

- more than one app needs it now, or likely will soon
- it is infrastructure rather than product framing
- keeping it app-local would create duplication or divergence

Something stays app-local when:

- it is product-specific
- it is mostly copy, plans, or pacing rules
- there is no real reuse signal yet

## Current Scope

The current active scope is a reusable utility-app platform with two working
products:

- `pomodoro_app`
- `fasting_app`

Future scaffolded app folders are part of the pipeline, not proof of active
support.

## Future Expansion Criteria

A new shared engine or package family should be added only when:

1. an active or near-active app needs it
2. the boundary is clear
3. the abstraction removes real duplication
4. the implementation can be tested and documented without guesswork
