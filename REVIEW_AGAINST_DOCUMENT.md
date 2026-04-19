# Review Against Current Documentation

## Scope

This review checks whether the top-level documentation reflects the current
state of the repository.

## Documents Reviewed

- `README.md`
- `SYSTEM_DESIGN.md`
- `BUILD_PLAN.md`
- `MASTER_SPEC.md`
- `ARCHITECTURE.md`

## What Matches the Codebase

The updated documentation now matches the current implementation on the main
points:

- the repo is a Flutter monorepo for multiple utility apps
- the active workspace apps are `pomodoro_app` and `fasting_app`
- the shared package graph is centered on `app_core`, `design_system`,
  `ui_kit`, `storage`, `notifications`, `monetization`, `analytics`,
  `localization`, `timer_engine`, `habit_engine`, and `discipline_engine`
- future app folders are treated as placeholders or scaffolds unless promoted
  into the root workspace
- future package families are treated as deferred directions, not active
  implementation

## Remaining Gaps

Some repo areas still need cleanup even after the doc rewrite:

- several placeholder app folders still have minimal or generated content
- infrastructure test coverage is still narrower than the app-level flows
- some secondary docs outside the core set may still need small wording updates
  over time

## Documentation Decisions

The documentation set now has clear roles:

- `README.md`: entry point and current status
- `SYSTEM_DESIGN.md`: detailed architecture source of truth
- `BUILD_PLAN.md`: practical roadmap
- `MASTER_SPEC.md`: platform goals and engineering principles
- `ARCHITECTURE.md`: short summary only

This avoids having multiple files compete to define the same thing.

## Recommended Next Cleanup

The next documentation pass should focus on:

1. keeping active app READMEs aligned as product behavior evolves
2. documenting any newly promoted app only after it is active in the workspace
3. extending tooling docs when Widgetbook or generation scripts change

## Conclusion

The main documentation set is now aligned with the current codebase. The repo
should be described as a working utility-app platform with two active apps and
a pipeline of future placeholders, not as an entirely speculative factory.
