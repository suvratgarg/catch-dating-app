# Catch launch operations board

This folder is the business launch control surface. It is deliberately outside
`docs/`: technical architecture remains in the repository documentation, while
launch decisions, owners, blockers, next actions, and evidence live here.

`pilot_launch_board.json` is the canonical board. It is plain JSON so people,
Codex, and other agents can update it without a paid project-management tool.
Git history is the audit trail.

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

Allowed task statuses are `todo`, `in_progress`, `blocked`, `ready`, `done`, and
`deferred`. Decision statuses are `accepted`, `pending`, and `superseded`.
