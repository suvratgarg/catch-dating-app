# Typography Migration Todo

Scope: app-facing Catch Flutter typography polish and migration.

## Done

- [x] Added expressive semantic type roles in `CatchTextStyles`.
- [x] Migrated auth, onboarding, dashboard headers, swipe hub, profile header,
      empty states, chat bubbles, event hero tiles, stride cards, app shell,
      payment history, and calendar surfaces to semantic roles.
- [x] Strengthened the global text scale and migrated club directory cards,
      chat list tiles, profile prompt answers, profile signal copy, event rail
      tiles, event agenda tiles, and event tile metadata.

## Active Todo

- [x] Close scanner-reported app-facing `Text` candidates that still bypass
      typography primitives.
- [x] Tighten reusable core primitives so menu, select, top-bar, button, chip,
      snackbar, and action surfaces inherit stronger text roles by default.
- [x] Audit profile and profile-edit surfaces for flat title/body hierarchy.
- [x] Audit clubs and host surfaces for muted card titles, weak metadata, and
      raw menu/snackbar copy.
- [x] Audit events and event-detail/create surfaces for title, time, location,
      and policy typography.
- [x] Audit dashboard, notifications, reviews, safety, force-update, and image
      upload surfaces for remaining weak text roles.
- [x] Audit event-success development surfaces without breaking their active
      in-development status.
- [x] Update widget catalog for material typography primitive changes.
- [x] Run focused format, analyzer, tests, scanner, audit report, and hot
      restart after the migration loops.

## Newly Identified

- [x] Remove nonzero/negative letter-spacing from typography primitives and
      Material fallback styles so the system follows the app design constraints.
- [x] Migrate Suvbot's local Material buttons and text field to Catch primitives
      so demo/admin controls do not look typographically detached from the app.
- [x] Lift feature screens off low-level `bodyS`, `bodyM`, and `titleS` calls
      so app-facing surfaces use semantic typography roles instead.
- [x] Lift core primitive defaults off low-level `bodyS`, `bodyM`, and `titleS`
      where a semantic role is clearer.
- [x] Record the semantic typography migration in the widget catalog so future
      audit passes inherit the stronger type system.
