# Outreach drafting runtime boundary

This registered Operations workflow creates private, English-language drafts in shadow mode. It cannot send, publish, grant organizer ownership, or infer contact consent. The default factory has no current-eligibility adapter or model activation, so a CLI plan can be prepared but execution fails closed until a trusted adapter is supplied. An approved sentence is rendered exactly as stored; model output selects IDs only and never supplies message prose. Raw source pages and unreviewed excerpts are not valid clauses.

`eligibilityPort.getCurrent({organizerId, contactId, opportunityId})` must read the current canonical sales/account state and return `{organizerId, organizerRevision, contactId, contactRevision, opportunityId, opportunityRevision, stage, identityStatus, contactEligible, suppressed, capabilityClaimsEligible, evidenceConflictStatus, promptVersion, playbookVersion, approvedClauseRevisions, supportedCapabilityIds, permittedReferenceIds, approvedCtaRevisions, priorInteractionRevision}`. The port must derive these fields server-side. `contactEligible` means reviewed for manual drafting only. `capabilityClaimsEligible` covers the factual/capability statements; it is unrelated to organizer ownership claims. `sales-adapter.mjs` implements this projection from a trusted Sales bundle. The Functions adapter in `functions/src/admin/salesIntelligence/runtime.ts` supplies current-source authorization, freezes the job input, rechecks its content hash, and persists the resulting draft through the transactional Sales service. Its local scratch store is disposable; Firestore jobs, source bindings and receipts remain authoritative. This callable execution path uses deterministic selection and makes no model calls.

A model activation is injected only by a trusted worker after a reviewed policy decision. It needs a provider, positive explicit run and monthly ceilings, a persisted model cache, and a durable monthly budget port. `monthlyBudgetPort.reserveAttempt({attemptId, monthKey, limitsHash, expectedConsumed, reservation})` must atomically compare the current durable month's limits and consumed balance, reject a stale or duplicate attempt, and reserve the unique attempt before provider I/O. `completeAttempt({attemptId, monthKey, usage})` may reconcile the reserved amount to validated actual usage idempotently. An uncertain result retains the reservation; it never releases spending merely because a client timed out. The engine persists its leased run reservation before provider I/O. The immutable attempt receipt blocks another provider call when no valid cache entry exists after a crash or timeout. Reconciliation of an uncertain attempt is a separate human-owned operation; there is no automatic retry or sending path.

A model cache hit is considered only after current eligibility checks, and the same checks run again before rendering. With model activation absent, cached model output is not reused; the workflow makes deterministic first-valid-clause selection with zero model budget. Approval requires a completed run, intact inventory, current eligibility, exact text hash, and explicit factual/tone/manual-channel review. The trusted backend adapter must authenticate and authorize the reviewer; the `actorId` field alone is not proof of authority. Its immutable receipt states `sendAuthority: false` and `providerConfirmed: false`. Any later copy/export or manual sent log must check current eligibility again in its own trusted boundary.

The supported `npm --prefix operations test` command includes the nested Sales
adapter tests. Its discovery regression runs that unchanged command against an
isolated failing nested sentinel, so source-located adapter coverage cannot be
silently omitted while top-level platform tests remain green.

`preparation-policy.mjs` validates frozen, independently configured research and
writing inputs for the upcoming partner preparation adapter. Each has its own
provider, model, prompt/version, budget and execution mode. API configuration is
inactive without a current exact policy, stage, owner and billing authorization
from a trusted activation port. There is no implicit provider fallback. This
helper alone performs no provider I/O and is not an activated worker or a claim
that the partner research/writing route is already integrated. Durable attempt,
lease and budget hooks above remain mandatory when that adapter is wired.

`research-proposal.mjs` is the proposal-validation boundary for that upcoming
adapter. Observations must cite literal captured content; interpretations remain
inferred and unknown fields assert no value. Source IDs and content hashes are
bound to the frozen organizer input. Comparison includes visibly sourced tools
and the strongest plausible workflow, with unknown baseline if no tools are
visible. Accepted output remains an unverified suggestion for existing Sales
human review, with no qualification or sending authority. Persistence and
current-source refresh must be supplied by the existing durable worker adapter.
