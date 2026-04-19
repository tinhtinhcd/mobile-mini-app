# Widgetbook

## Purpose

`tools/widgetbook` is the shared UI playground for the monorepo. It exists so
reusable components can be reviewed and iterated on outside the full app flows.

## What It Covers Today

The current Widgetbook setup includes use cases for shared `ui_kit` components
such as:

- primary and secondary buttons
- stat tiles
- settings tiles
- timer display cards
- selection pills
- premium callout cards

## How to Run

From the repo root:

```bash
cd tools/widgetbook
flutter run
```

## How to Extend It

When a shared UI component is added or changed significantly:

1. add a focused Widgetbook use case
2. keep the example small and readable
3. prefer examples that reflect real app states
4. use the shared theme so component behavior is visible in context

## Current Gaps

Widgetbook coverage is still selective. It should keep growing with the shared
UI layer, especially for:

- compact utility layouts
- premium and paywall-adjacent surfaces
- edge states such as locked, loading, and long-text variations
