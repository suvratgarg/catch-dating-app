---
result: passed
surface: admin-overview-and-safety
date: 2026-07-13
viewport: 1422x800
---

# Admin design QA

## Comparison input

- Reference: `/tmp/catch-admin-visual-audit/03-overview-reference.png` and
  `/tmp/catch-admin-visual-audit/04-safety-reference.png`
- Implementation: `/tmp/catch-admin-visual-audit/05-overview-after.png` and
  `/tmp/catch-admin-visual-audit/06-safety-after.png`
- Same-input review board:
  `/tmp/catch-admin-visual-audit/08-side-by-side-comparison.png`

The reference and implementation captures use the same 1422x800 viewport and
the corresponding populated Overview and Safety list states.

## Visible QA

- Passed: route eyebrow, Archivo heading, paper/ink hierarchy, compact account
  controls, and grouped collapsible sidebar are consistent across both routes.
- Passed: six Overview metrics form one aligned row, include concise context and
  ownership, and precede the full-width live queue router.
- Passed: analytics controls are below live operations and explicitly describe
  their scope, so they no longer look global.
- Passed: Safety uses four full-width queue-health metrics followed by two
  aligned analytics panels and then the actionable queue.
- Passed: routine panels use hairlines instead of decorative elevation; red and
  amber are reserved for meaningful attention and priority states.
- Passed: machine queue codes are adapted into readable operational titles.
- Passed: no visible clipping, overlap, broken radius, or unintended nested
  panel depth appears in the captured desktop states.

## Behavior and accessibility QA

- Passed: Overview queue action routes to its owning workflow.
- Passed: Safety opens an encoded list-to-detail URL and returns with
  `All safety cases`.
- Passed: account disclosure opens, closes on Escape, returns focus, and keeps
  environment/auth context visible.
- Passed: sidebar collapse and expansion preserve the current route.
- Passed: charts expose labels and values as readable content; zero bars render
  as zero and signal color is supplementary.
- Passed: 63 unit tests and 259 Storybook accessibility checks.
- Passed: Storybook visual compare across 252 ready stories at 1280x800 and
  375x812, for 504 passing captures.

## Intentional production differences

- Production retains environment, account, Firebase-auth, claim, and role-based
  navigation controls that the mockup omits.
- Overview uses backed values and keeps moderation and payment queues under
  unambiguous owners instead of combining unrelated workflows.
- Safety queue composition uses complete aggregate counts. Priority and age are
  explicitly limited to the capped returned preview; they are not described as
  the full backlog or an SLA breach.

## Non-blocking follow-up

Full-backlog aging remains deferred until the backend exposes an uncapped
aggregate age distribution or a bounded ordered analytics endpoint. The wider
route-by-route adoption backlog remains in
`docs/audit_registry/admin_console_design_adoption.json`.
