# Catch launch operations board

This folder documents the business launch control surface. Technical
architecture remains in repository documentation, while mutable launch
decisions, owners, blockers, issues, next actions, and evidence live in
Firestore.

The canonical pilot board is
`launchBoards/catch-pilot-launch-2026-07` in the production Firebase project.
Repository launch-board JSON is retired. Database history and
`adminAuditLogs` are the audit trail; an operational update must never require a
Git commit.

## Agent update contract

1. Read `decisions` before acting. Do not silently reverse an accepted decision.
2. Claim a task by setting `status` to `in_progress`, `owner` to a named person
   or agent task, and `updatedAt` to an ISO-8601 timestamp.
3. Put owner-dependent questions in `blockers`; do not bury them in notes.
4. A task becomes `done` only when every acceptance criterion is met and its
   evidence array contains durable URLs, workflow runs, receipts, or repo paths.
5. Deferred work stays visible with a reason and a revisit condition.
6. Add new supply records to the existing supply-intake workflow; this board
   coordinates that work but does not replace its review and publication gates.
7. Record every newly discovered launch defect in `issues` with a stable id,
   severity, owner, next action, and evidence. Mark it fixed only after the
   correction is merged and, when production-facing, verified live.

Allowed task statuses are `todo`, `in_progress`, `blocked`, `ready`, `done`, and
`deferred`. Decision statuses are `accepted`, `pending`, and `superseded`.
Issue statuses are `open`, `in_progress`, `fixed`, and `deferred`.
