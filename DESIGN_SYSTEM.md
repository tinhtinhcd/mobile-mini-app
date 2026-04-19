# Design System

## Goal

Provide a shared visual language for small utility apps built in this monorepo.

The design system is intentionally compact. It should help multiple apps feel
related without forcing them into the same product identity.

## Core Principles

- calm, clear layouts
- high reuse across apps
- compact screens that work well on phones
- one strong primary action per surface
- app identity expressed mostly through accent color, copy, and product rules

## Token Layer

The current token layer lives in `packages/design_system` and includes:

- color tokens for background, surface, text, divider, and semantic states
- spacing tokens
- radius tokens
- icon size tokens
- shell metrics
- typography helpers

Accent color is app-configurable and is injected through shared theme
construction.

## Theme Layer

The shared theme:

- supports light and dark mode
- builds from a per-app accent color
- uses Material 3 with shared overrides
- applies consistent button, card, chip, input, snackbar, and bottom-sheet
  styling

## Layout Layer

The design system also defines shared layout primitives for utility-style apps,
including:

- content framing and max-width rules
- shell header and footer metrics
- timer-oriented layout primitives
- tracker-oriented layout primitives
- section and action zones

## UI Kit Layer

Concrete reusable widgets live in `packages/ui_kit`, including:

- primary and secondary buttons
- section cards
- timer display cards
- compact stat strips
- selection pills
- settings tiles
- empty states
- premium callout cards
- fixed utility-screen layouts

## Screen Patterns In Use

The current active apps use a compact utility pattern:

- short header
- prominent timer or progress hero
- primary action
- small selector controls
- compact progress or coaching panel
- light footer area for ads or shell affordances

That pattern is already visible in both active apps and should remain the
default unless a new product has a concrete reason to diverge.

## Current Constraints

The design system is tuned for small utility apps first. It is not yet trying
to be a full generic component system for every possible product category.

If the repo expands into very different app families later, the design system
may need additional layouts or token families. Those should be added from real
usage, not from speculation.
