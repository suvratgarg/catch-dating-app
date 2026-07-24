# Organizer Intake

Organizer Intake is a Firestore-backed business workflow.

Live candidates and evidence are stored in `operationRuns` and
`operationWorkItems`. Manual decisions are stored in the callable-owned
Firestore collections documented in `contracts/firestore/`:

- `organizerIntakeReviewDecisions`
- `organizerIntakeCurationDecisions`
- `organizerEventCandidateReviewDecisions`
- `organizerEventLocationResolutionDecisions`
- `organizerPolicyGapReviewDecisions`

The Admin console reads and writes those collections through authenticated
callables. Repository JSON must not be used for candidates, decisions, queues,
answer packets, dashboards, or workflow state.

The remaining code in this directory is legacy migration tooling, pure
normalization logic, contracts, and deterministic test fixtures. It is retired
from normal category CI except for the URL normalizer and Firestore boundary
checks. Do not reactivate a JSON producer; add the needed read model or mutation
to the Operations platform and its Admin callable instead.

Public website output may still be a deterministic build artifact. That output
is a projection of reviewed database state, never the source of an Admin
workflow.
