# Sales assistant HTTPS boundary

`http.ts` exports the versioned HTTP adapter wired directly to
`functions/src/admin/sales/service.ts`. Add this export to the Functions index
only after the server-owned Firestore rules and deployment review:
`export {salesAssistant} from "./salesAssistant/http";`.

The deployed function serves `GET /v1/openapi.json`. Business requests use
`POST /v1/actions/{action}` with the registered non-admin client Firebase ID
token in `Authorization: Bearer`, and the client and delegation IDs in their
named headers. The employee token is never given to the external assistant.
Each request re-verifies the client token, resolves the delegated employee,
and checks current employee admin claims, the active client binding, the live
delegation, its expiry and scope. The shared service rechecks delegation and
client state inside each mutation transaction, including receipt replay. It charges
transactional minute and daily budgets before calling the shared service.
The service remains responsible for strict action payloads, host/field scope,
revision and idempotency receipts, and safe read projections.

An Admin Owner uses their own Firebase ID token to register an existing
non-admin Firebase Auth client UID via
`PUT /v1/clients/{clientId}` with `{authUid,active}`, issue a delegation via
`POST /v1/delegations`, and revoke one via
`POST /v1/delegations/{delegationId}/revoke` with `{}`. The owner endpoint
rechecks current owner claims and has a bounded request budget. Issuance is
limited to existing active employees and clients, explicit host/action scopes,
optional field IDs, a seven-day expiry, and rate and daily ceilings. This API
does not create a client account or obtain its Firebase credentials. Provision
that account and validate a provider's token handling separately before a live
connection is activated.

Gateway collections `assistantClients`, `assistantDelegations`, and
`assistantGatewayBudgets` are server-owned and must be denied to client SDK
reads and writes in Firestore rules before deployment. Budget documents include
`expiresAt` for the same TTL maintenance process used by rate-limit counters.
No assistant route can send, publish, approve claims, change payment state,
merge identities, or export a contact list.
