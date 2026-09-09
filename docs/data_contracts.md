---
doc_id: data_contracts
version: 1.90.0
updated: 2026-09-09
owner: recursive_audit_loop
status: active
---

# Data Contracts

This is the source of truth for Firestore document shape, Cloud Functions write
ownership, schema tooling, relationship documents, migration policy, and rules
test workflow. It replaces the separate Firestore/Functions contract tracker,
relationship-doc migration tracker, and schema-contract unification tracker.

For a human map of every backend operation, use
`docs/backend_operation_catalog.md`. For environment deploy order, use
`docs/release_operations.md`.

## Read Policy

Read this before changing:

- Firestore rules or Storage rules tied to Firestore documents;
- Cloud Functions mutation boundaries;
- Dart/TypeScript model generation;
- JSON schemas under `contracts/`;
- callable request/response validation;
- seed/demo document builders;
- relationship/action documents;
- data migration or repair tools;
- Firestore rules test execution.

## Sources Of Truth

| Surface | Owner |
|---|---|
| Persisted document, callable, and public HTTP schemas plus fixtures and catalogs | `contracts/` |
| Storage path contracts (upload paths, content-type, size limits, owner) | `contracts/storage/` |
| Generated TypeScript interfaces, Ajv validators, and Admin SDK Timestamp types | `functions/src/shared/generated/` |
| Generated website and Admin browser contract types | `website/src/shared/contracts/generated/` and `admin/src/generated/contracts/` |
| Generated Dart schema constants/registry | `lib/core/schema_contracts/generated/` |
| Tool-side schema registry and validators | `tool/contracts/generated/` |
| Firestore operation ownership metadata | `tool/contracts/firestore_contract.json` |
| Human operation map | `docs/backend_operation_catalog.md` |
| Active policy rules | `tool/policy/rules.json` |

Do not hand-edit generated outputs. Change the contract source, run the schema
generator, and commit the generated diff.

### Rehearsal Assistance Generation

`controlEventRehearsal` requires `expectedSetupRevision` for assistance commands,
alongside the runtime revision and immutable client action id. Reset increments
the setup revision and reuses runtime revisions from zero. The handler checks
the reviewed generation before replaying a receipt and again inside the
transaction, preventing an old pending instruction from publishing into the
new run. Other existing lifecycle controls retain their previous payload;
this additional required field applies to assistance only. Native typed
commands serialize the reviewed generation and also verify it in the result.

Host rehearsal bootstrap also exposes the stored `virtualStartedAtMillis`.
Native practice instruction assembly uses that anchor plus the configured
duration to bound expiry; advancing the virtual clock cannot extend the event
window. Older Host responses without the anchor remain readable, but cannot
assemble a new instruction until a current bootstrap supplies it. The guest
bootstrap shape is unchanged.

`eventRehearsalActors.assistanceAutomation` is optional, callable-owned and
private to Host bootstrap. It stores the clock generation, enabled/paused state,
explicit plan, bounded simulated-outcome script, cursor and typed policy/delivery
evaluation. Guest projections omit the recipe. Automation commands use the
existing assistance generation/revision/request fences. Current-time evaluation
shares the parent actor transaction; failed or duplicate transitions cannot
consume another script item or create another attempt. Reset removes recipes
by rebuilding the synthetic roster. These additions have no live sender or
provider binding.

Native rehearsal readers preserve this optional automation value with a strict
plan parser, immutable one-to-six-item outcome script and bounded cursor.
Policy evaluations reuse the shared late-join decision union; delivery
evaluations have closed variants and reasons. Missing automation remains null,
and uncertain or accepted delivery evidence retains its reconciliation state.
Native configure/pause/resume commands use the existing assistance payload and
receipt checks. Configuration freezes the reviewed plan and script, including
through an uncertain exact retry; no schema or live provider change is required
for these native bindings.

`eventRehearsalCases` is a callable-only collection with correlated open and
settled handling, reusing the live practical-request handling definitions.
Case identity includes the rehearsal clock, synthetic actor and originating
guest action or message response. Creation and resolution share existing parent
rehearsal transactions and action receipts. The Host-only bounded request view
preserves the current clock, reviewed source hash and assignment authority;
old untracked help flags remain explicit. Guest projections omit these records.
Native readers reject foreign clocks/actors and inconsistent resolution state;
only a reviewed open rehearsal case can form its typed handling command.
Rehearsal reset and expiry remove these cases, independently of live cases.

### Explicit Attendance Closeout

The event document accepts an optional, callable-owned `updatedAt` timestamp.
The absolute Host attendance writer already updates it with the event checked-in
aggregate. Older events may omit it; a real-emulator check-in regression validates
the resulting event and attendee documents before reading closeout again.

`event_attendance_disposition.schema.json` defines live-only reads, the typed
`recordNoShow` command payload, response projection, annotation and receipt.
The command distinguishes recording evidence from a clear reason. Its expected
physical-attendance revision and expected disposition revision are independent.
`eventAttendanceDispositions` and `eventAttendanceDispositionReceipts` are
callable-only; their owner validates current organizer authority and canonical
roster/event/plan/guest evidence in the same transaction as the decision.
Source hashes preserve timestamp precision and source generations; they cannot
be reused after attendance, relevant identity, closure or cited guest evidence
changes. Exact receipts preserve the original operation revision separately
from current projected disposition. Old decisions are hidden for replacement
identities or explicitly superseded for changed facts. These documents do not
replace `eventAttendees`, infer attendance, update event totals or alter report
aggregates. Native readers preserve each disposition/closure/evidence variant
and reject cross-field contradictions as well as schema-invalid values. They
use generated request DTOs, retain the reviewed source and revisions for exact
retries, and distinguish an operation's receipt revision from the latest view.
No schema or generated contract change is needed for this native binding.
The same shared schema now defines `getEventAttendanceReport` and its closed
attendance classification/count projection. The current unified Host roster
is read in a single SDK read-only snapshot with the same per-guest validation
and decision policy. Imported or unlinked rows are included. Empty roster,
unresolved review reasons, explicit recording evidence and non-admission are
preserved; counts and compact member ids cover all canonical rows together.
Overflow beyond 1,000 rows or malformed source evidence fails the request.
The aggregate cannot submit a decision or update legacy scorecard caches.
Roster and report UI integration remain separate work.

### Event Assistance Transaction Boundary

Event Assistance routes read/write SDK transactions through
`runAssistanceTransaction`. Explicit read-only snapshots keep the SDK read-only
path and cannot acquire write authority.
The adapter normalizes only the exact closed-transaction read failure into the
SDK's existing bounded ABORTED retry path. It does not wrap commit failures or
retry provider sends, and it preserves other domain and transport errors. Request
receipts still own recovery when a commit outcome is uncertain. The source check
in `transactionCallback.test.ts` rejects direct production read/write SDK
transaction calls outside this adapter; test fixtures remain independent. This applies consistently
to settings, group handovers, guest actions, outbox claims and callback consumers.

### Event Assistance Practical Requests

Guest responses create `eventAssistanceCases` with distinct practical and
restricted-safety ownership. New records bind their roster/event generations
and contain a revisioned handling state. The schema preserves historical
records without those fields as an explicit legacy variant; the Host reader
cannot invent their missing source binding or authorize their mutation.

`listEventAssistanceCases` provides a manager-only, bounded page of practical
requests, with stale identity redaction and no event-wide completeness claim.
`resolveEventAssistanceCase` owns resolution, decline and manager handoff. The
canonical command includes the expected case revision; its callable also
requires the reviewed source hash. `eventAssistanceCaseReceipts` records exact
request hashes, source binding, actor, outcome and committed revision for
transactional retry safety. Both collections deny direct client access.
See `docs/event_success.md` for lifecycle and integration boundaries.

### Event Assistance RCS Configuration

`contracts/operations/event_assistance_rcs_config.schema.json` references the
canonical Google RBM sender shape in `event_assistance_rcs.schema.json`.
Generated TypeScript validators and Dart schema metadata share its agent,
region, credential-version, purpose, approval, quote and queue-limit fields.
The messaging provider union permits `googleRbm` only for `catchEventRcs`.
The sender display name is now required and `eventAssistanceRcsSenders`
references the same canonical configuration as a private Firestore collection.
No public provisioning endpoint or live sender is created by this contract.
It grants no recipient, spending or dispatch authority. See
`docs/event_success.md` for rendering and integration boundaries.

`event_assistance_rcs_consent.schema.json` owns independent RCS permission,
exact consent receipts and preference views. The two App-Check-protected
`getEventRcsPreference` / `setEventRcsPreference` callables require the roster's
linked UID; a grant additionally verifies its signed phone claim. The reviewed
hash binds sender identity, event name and captured window, subject and phone,
attendee and Firestore source generations, and latest STOP. Caller-selected
provider IDs, phone numbers or evidence timestamps are rejected.

The `list_event_rcs_preferences` request/response contracts expose bounded,
participant-only sender discovery. Requests name only event, attendee and a
nullable permission cursor; identity comes from Firebase Auth. Responses retain
configured sender selection separately from previous sender IDs and pagination.
The configured sender uses the canonical runtime source binding, including
paused configurations. Historical discovery uses a composite index over live
context, attendee, subject UID and document ID; source/phone mismatches are
filtered after a bounded read. It never supplies consent or sender readiness.
The existing reviewed preference callables remain the only grant/write path.

The `list_event_whatsapp_preferences` request/response contracts provide the
corresponding bounded discovery for `organizerEventWhatsapp`. They use a distinct
`wa-permission` cursor and index prior verified subject evidence via
`evidence.subjectUid`; an initial revocation without that evidence is excluded.
The shared source reader checks current participant ownership and the saved
runtime binding before either channel's private history query. Channel-specific
permission decoders retain their own consent and identity rules. These read
contracts add no grant, connection, provider or financial authority.

Private `eventAssistanceRcsPermissions` and `eventAssistanceRcsConsentReceipts`
commit together. Granted and revoked records are a closed union; a grant
requires explicit evidence and a matching immutable receipt, while initial
withdrawal has null evidence. Exact request retries cannot reverse later
decisions. Withdrawal preserves the original binding after phone, source or
sender changes. Consent expires at the captured event end plus 24 hours, with
the current event window rechecked by the shared transactional permission
reader. STOP review hashes exclude START and unrelated observation revisions;
a new STOP requires fresh review. No SMS/WhatsApp permission is reused or
mutated. Direct client collection access remains denied.

RCS permission records require a derived `subscriptionId` matching the canonical
agent plus phone hash. The whole record remains covered by its immutable consent
receipt. A composite index over `subscriptionId`, `expiresAt` and document ID
supports bounded conversation STOP discovery without storing raw phones in work
payloads or scanning every recipient of an agent. Do not retrofit an indexed
field onto a previously receipted grant: changing that record invalidates its
proof. These pre-activation contracts require state verification and fresh
review for any older records before live activation; no data backfill or consent
migration is performed by this source change.

The same canonical contract now owns `WithdrawalGrant`, `WithdrawalView` and a
closed `messageLink` revoke-only receipt variant with a null actor. Private
`eventAssistanceRcsWithdrawalGrants` binds the original source generations,
subject, endpoint and agent. Transactional preparation verifies the persisted
guest grant and exact permission/receipt before staging immutable issuance. The
App-Check-protected bearer callables `getEventRcsWithdrawal` / `withdrawEventRcs`
expose only recorded preference and lifetime; revision checks and immutable
receipts fence old requests. Withdrawal works after instructions expire without
restoring read/reply access, and does not depend on current event/roster/sender
records. Retain its referenced guest grant through the independent withdrawal
lifetime. The RCS dispatch store now stages this binding with the outbox claim
and two approved budget charges. The guest update page now reads and withdraws
RCS independently from SMS and WhatsApp, even when instructions are unavailable.
Its shared controller validates the closed response before caching, scopes each
channel and credential separately, and preserves an uncertain request for exact
retry. Bearer controls cannot opt in. Verified guest opt-in controls and live
activation remain open.

The RCS canonical contract also owns `Budget`, `CapabilityObservation` and
`Dispatch`. Private `eventAssistanceRcsBudgets` binds each approved event or UTC
sender-day limit to an agent and currency. Both pessimistic charges commit with
one outbox claim. `eventAssistanceRcsDispatches` stores the corresponding
before/after budget revisions and charges, original scope, permission and
capability hashes, deterministic provider message ID, frozen body hash and
absolute delivery expiry. No phone, bearer secret or message body is persisted
in that record. Capability is an in-memory, at-most-60-second observation tied
to the exact sender and consent; its snapshot is retained in dispatch evidence.
It grants no spending or message permission. The shared channel selector can
use RCS through the production factory for an explicit sender when its default-off
flag is enabled. The credential loader validates an exact sender/agent/region
secret envelope and uses the Google OAuth library with the RCS messaging scope.
The HTTP export resolves independent, pinned webhook endpoint bindings and
commits verified callbacks to the durable inbox. These secret formats and
configuration flags are owned in `docs/event_success.md`; they create no new
client-visible contract or consent. Deployment, authenticated ingress activation
and approved provisioning remain required for live use.

### Event Assistance RCS Callback Evidence

`contracts/shared/event_assistance_rcs_callbacks.schema.json` owns the closed
delivery, expiry, suggestion, subscription and unstructured-message observation
union. Firestore schemas reference its callback, identity and consumer receipt
records;
generated TypeScript validators and Dart metadata share those exact shapes.
Authenticated ingress owns both server-only collections, with all direct client
reads and writes denied:

- `eventAssistanceRcsCallbacks/{callbackId}` stores immutable normalized evidence.
  The ID hashes the scoped receipt key and signed payload hash, so conflicting
  payloads retain separate records without storing the raw provider payload.
- `eventAssistanceRcsCallbackIdentities/{receiptKey}` binds the first callback and
  storage time to the agent, endpoint, event family and provider event identity.
  Its nullable conflict time prevents later consumers from using contradictory
  evidence as an ordinary delivery or guest response.

The inbox writes both records transactionally and preserves first-receipt times
on exact duplicates. Consumers must read the identity in their effect transaction;
acceptance grants no delivery, guest or permission effect. Evidence excludes raw
phone numbers, message text, file URLs, locations, signatures and tokens. Missing
provider time remains null. No automatic retention deletion is configured until
pending-consumer and retry requirements have an implemented lifecycle. See
`docs/event_success.md` for consumer behavior and remaining activation work.

`eventAssistanceRcsCallbackReceipts/{callbackId}` is a third private collection.
Its closed outcome (delivery, reply, ignored or rejected) binds the complete
immutable callback hash and processing time. The inbox conflict identity, outbox
transition, typed guest action and receipt share one transaction; failed commits
leave no partial effect and exact retries return the saved outcome. Missing or
conflicted inbox evidence cannot create a consumer receipt or domain effect.

Dispatch records now include immutable intent and attempt-scope hashes plus a
nullable native reply binding. It freezes only rendered choice indices/IDs, the
guest revision, episode, attendee/event source generations, subject UID and reply
expiry. Reply expiry is independent of provider queue TTL. An authenticated tap
can prove delivery after queue expiry, but its domain action still requires the
current guest identity, instructions and event window. Original replies remain
usable after outbound opt-out without restoring any message permission.

`event_assistance_rcs_subscriptions.schema.json` adds the server-only
`eventAssistanceRcsSubscriptions/{subscriptionId}` projection, keyed by agent
and hashed endpoint across events. It retains independent latest stop and
subscribe-request callback references and their first storage times. At least
one observation is required; neither state grants event consent. The inbox
commits the projection with its callback and identity, including a restriction
from a conflicting signed STOP. Exact retries can repair missing older
projections without moving observation times or overwriting newer evidence.
Readers verify both shape and original callback binding transactionally.
No direct client access or automatic retention deletion is enabled. Event
permission, dispatch, SMS and WhatsApp records are not mutated by this owner.

### Host Today Attention Contract

`contracts/catalogs/host_attention_policies.json` is the exhaustive policy
inventory for the Host Today queue. Every kind declares one source owner,
trigger and resolution semantics, authorization boundary, consequence,
deadline policy, destination, deduplication policy, delivery mode, and source-
truth readiness. The schema validator requires the catalog to match the closed
kind enum in `contracts/shared/host_attention_common.schema.json` exactly and
in order. Adding an attention kind therefore requires an explicit catalog
decision; it cannot appear as widget-local business logic.

The catalog distinguishes four delivery modes:

| Delivery mode | Meaning |
|---|---|
| `serverProjected` | The backend can derive the item from explicit canonical facts and return it after read-through reconciliation. |
| `clientMerged` | The fact is intentionally device-local and Flutter merges it after the server response. |
| `shortcutOnly` | Today exposes an action, but the product does not claim that every organizer has a mandatory task. |
| `blockedMissingTruth` | A desirable archetype lacks an explicit authoritative workflow field; the callable reports the gap instead of inferring it from a weak proxy. |

`organizerAttentionItems/{attentionId}` is a server-only evaluated projection.
It stores stable source provenance and revision, open/resolved lifecycle,
urgency, consequence, deadline, destination, display-safe context, policy and
resolution versions. Open rows use a null TTL; resolved rows receive bounded
cleanup. It never embeds prose predicates or
becomes the source of the underlying event, application, form, provider, or
payout state. Direct client reads and writes are denied.

`listOrganizerAttentionItems` owns the read-through boundary. Before returning
supported server items it must re-read every declared authoritative source,
derive the desired open set, upsert changed rows, and resolve stale rows. Each
source scan is bounded at 400 records and fails closed when exceeded; the
callable must never label a truncated scan exhaustive. The response also
contains one coverage row per catalog kind so clients and tests can distinguish
complete server coverage, required local merging, shortcuts, and missing truth.

The source-ready server kinds are live-event operations, ordinary waitlist
review, manual join-request review, application review, provider-sync failure,
form-automation failure, and payout setup. Attendance retry/conflict work is
merged from the local Host outbox. Flutter consumes the callable through
`HostAttentionRepository`, parses the closed item and coverage vocabularies
into typed domain values, verifies the requested organizer, and rejects any
response that does not contain every catalog kind exactly once. The Today feed
then merges every normalized `HostAttendanceOutbox` row, deduplicates and sorts
the combined queue by urgency, blocking consequence, deadline, and stable id.
The active-event feed remains usable when either optional attention source
fails, but the presentation receives a source-specific issue and must not claim
that the organizer has no outstanding work.

Dress Rehearsal is a Today shortcut. Event Success readiness, room-layout
requirements, staffing requirements, generic form-response review, Inbox reply
obligation, and post-event reconciliation stay blocked until their owning
domains add explicit workflow state. In particular, null optional setup, zero
staff grants, an unread message, a submitted generic form, or aggregate counts
are not sufficient evidence of a mandatory task.

### Event Assistance Group Membership Contract

`eventAssistanceMemberships/{membershipId}` holds at most one accepted group
and one current handover per event/attendee. It binds event/roster creation
generations, authored attendee generation, participation episode and revision.
Accepted membership and proposed destination separately bind saved group source.
Attendance, social allocation, physical placement and participation remain owned
by their existing records. Membership never modifies those facts.

The canonical `transferGroup` command has correlated place/propose/accept/reject/
cancel/leave decisions. Place is an initial manager acknowledgement of
responsibility; propose can name a current receiving operator for either initial
assignment or transfer. Acceptance belongs to that exact operator with current
scope authority. It changes membership and resolves the proposal together.
Cancellation, rejection and expiry preserve the prior group. Direct placement
cannot bypass a pending assignment. Transfer deadlines cannot exceed 30 minutes
or the event end. Sweeps have scoped reads but no transfer authority.

`eventAssistanceMembershipReceipts` atomically preserves the actor, canonical
command, request hash, source generation, episode and resulting revision. Current
manager/scoped operator authority and reviewed source/revision/episode fences are
checked in each transaction. Reads and retries never recreate an earlier effect.
The membership store uses the shared bounded transaction callback adapter for
closed-transaction read failures. Commit uncertainty is not translated or
blindly retried; immutable request receipts remain the replay authority.
Changed event/roster generations, guest re-entry and changed group setup require
fresh review. Membership checks also gate group-specific joining instructions at
publication, guest interactions and SMS/WhatsApp dispatch. Both collections deny
all direct client access. Host controls, bulk/queue projections, responsibility
reassignment, rehearsal adapters and terminal retention remain integration work.

### Event Assistance Participation Contract

`eventAssistanceGuests` owns explicit participation independently of its reported
joining intention. `participation` is a correlated state: active and departed
require a null return point; temporaryBreak may carry a currently saved itinerary
unit reference. The record also binds the exact Firestore creation generations
of its event and roster row. Source replacement withholds the old state and
requires a new reviewed episode. Reads expose only participation, source/revision
fences, check-in status and return choices; they contain no contact information
or reported joining intention.

`eventAssistanceParticipationReceipts/{receiptId}` is a server-only immutable
command receipt. Its identity binds event/guest/operation; its request hash
includes the authenticated actor. State and receipt commit together. Exact
retries return the original revision plus current state; changed reuse, source
replacement and stale commands fail. No direct client access or TTL is enabled.
Retention must cover executable commands and outstanding guest capabilities.

The get/set participation callables require Auth, App Check, rate limiting and
current organizer-manager or linked-attendee authority. Set consumes the canonical
`setParticipation` command with episode and revision fences and a reviewed source
hash. Admission must be registered/checked-in and the event must remain open.
Re-entry starts a fresh episode; other state changes preserve it. The command
never checks someone in, allocates them, changes consent or infers that they have
returned. All messaging boundaries suppress affected activity prompts while
retaining independently eligible essential and post-event updates.

### Event Assistance Settings Contract

`eventAssistanceSettings/{settingId}` stores a typed preference for one live
event, group scope and workflow kind. The ID hashes those three identities.
The whole-event default uses `event:whole`; configured pace-group IDs may own
an override. `inherit`, explicit disablement and a correlated configured
template are distinct wire states. Templates bind configuration to workflow
kind without requiring a guest episode during setup; runtime policy binding
supplies the concrete subject and the server-owned implementation version.

`eventAssistanceSettingReceipts/{receiptId}` stores immutable request hashes
and original committed revisions. Actor identity participates in the request
hash; context/group/workflow/request identity determines the receipt ID. Both
records commit together. Exact replay returns its original operation revision
and the latest projected settings. Changed request reuse or an outdated
revision/source hash fails. Neither collection has client access or a TTL;
terminal retention must be decided before activation.

The two settings callables require Auth, App Check, rate limiting and current
organizer-manager authority. They expose only settings and source hashes, not
roster details. A projection cannot claim current configuration after a
structural source change, while explicit disablement remains suppressive.
Current participation, capability/readiness, consent and execution authority
must still be resolved by their owning runtime boundaries. Saving an automatic
preference does not itself send a message or enable a production worker.

The internal late-join source reader uses the same settings inheritance and
source checks as the callables. It joins one canonical guest episode and its
accepted group with current progress without writing records or creating a
parallel projection collection. Its partial typed result excludes delivery
eligibility and message history. Those facts must be supplied explicitly from
the same scoped snapshot before canonical evaluation; the reader alone cannot
produce send authority. It is not exposed to clients and adds no new Firestore
access rules. The live evaluator now obtains those remaining facts through
shared consent/suppression readers and a bounded query of the existing private
outbox. Sender choices and policy-required response deadlines remain trusted
workflow inputs; they are not inferred from an arbitrary connected account.

The episode-history query includes all lateJoin occurrences and lifecycle states
for the exact live organizer/event/attendee/episode. Its six-field composite index
is declared in `firestore.indexes.json`. A maximum of 201 reads detects overflow
beyond the supported complete 200-row history. Reserved or potentially submitted
intents count once even across channel fallback, cancellation or supersession;
queued-only and proven-unsent records do not count. Conflicting evidence, ambiguous
latest material and overflow withhold evaluation. No new projection collection,
client access or cleanup policy is introduced. Active episode history must remain
available for policy caps and cooldowns. Final dispatch rechecks exact message
material, credentials and spending separately from preparation eligibility.
The atomic publisher below now consumes these facts. Durable worker scheduling
is wired in source and remains dormant; terminal retention remains integration
work.

Automatic lateJoin message intents now include an optional strict `automation`
binding in the canonical messaging schema: policy version, setting identity and
revision, group, ordered sender routes and nullable explicit response deadline.
The trusted automatic publisher always emits it; existing explicit publications do
not acquire automation authority by omitting it. Wire validation plus runtime
cross-field checks reject mismatched routes, duplicate route ids, non-live contexts
and a different workflow. Generated Functions/Dart schemas and private Firestore
message types carry the same contract.

The automatic publisher joins source evaluation and message/thread writes in one
transaction. Its semantic identity excludes only creation time, so later retries
reuse the original immutable record while changed content creates a distinct intent.
Final automatic dispatch re-evaluates current policy and exact setting/group/sender
bindings. Episode history excludes only the exact stored intent being dispatched,
after full identity/content/conflict validation; other lifecycle states remain in
the complete query. This prevents a reservation from consuming its own logical slot
twice and preserves the shared cap across replaced instructions. Instruction refresh
and permission to send remain separate. No new collection, client rule, credential
read or provider submission is introduced by publication.

The strict `event_assistance_roster_work.schema.json` payload adds resumable
roster enrollment to the existing Operations collections. It binds the source
identity, organizer/event scope and saved runtime revision, with a bounded
cursor, retry list and explicit stop reason. `work_item.schema.json` binds this
payload to the Event Assistance workflow and `runtime_roster` entity kind.
Current runtime permission and each canonical registration are re-read before
guest enrollment or rebinding; payload snapshots never grant authority. No new
collection or client access rule is introduced. The authoritative execution
limits and lifecycle are documented in
[Operations](operations_platform.md#resumable-roster-enrollment).
Runtime configuration commits its roster run/item with the configuration and
request receipt. Configuration triggers reuse that revision's logical source
identity, while registration/re-entry sources retain their CloudEvent identity.

The strict `event_assistance_delivery_work.schema.json` payload binds an
automatic message to the Event Assistance `message_delivery` entity in existing
Operations collections. Phase-specific schema constraints distinguish queued,
retry, receipt wait, review and completed checkpoints. Runtime validation checks
the entire run/item projection, frozen intent/thread/scope, message revision/hash
and timestamp bounds. The publisher creates the message, thread and delivery
run/item in one transaction. A raw outbox row or unbound legacy intent cannot
create scheduled send authority. No new client-readable collection is added.
[Operations](operations_platform.md#durable-message-delivery-work) owns execution
limits, recovery and receipts; [Event Success](event_success.md#durable-message-delivery-coordination)
owns signing-key configuration and the channel bridge. Private grant/dispatch
records retain their existing hashes and bindings; credentials are never copied
into delivery-work payloads.

`event_assistance_source_work.schema.json` also accepts event-specific SMS and
WhatsApp permission and scoped staff sources. Its bounded cursor/failure set can
reference canonical guest, delivery or checkpoint work ids; scope and immutable record validation
remain mandatory before each wake. Source payloads retain identifiers rather
than consent contents or recipient endpoints. Delivery wake action receipts bind
the signal hash and target, deduplicate source replay, and preserve terminal
work, recovery caps and unresolved provider submissions.

The closed `checkpointMember` scope binds one attendee to a live organizer/event
and accepts only the matching `eventAttendees` source document. Check-in,
registration generation and canonical accountability corrections emit this
scope separately from ordinary guest work. Pure dispositions never enroll a
guest or select delivery work. Its cursors and failures accept checkpoint work
ids only. Discovery reads bounded existing requests in the exact event and
verifies their immutable roster hashes before checking original membership;
missing or corrupt evidence remains retryable work, not an unaffected result.
The signal contains no disposition, attendance assertion or provider authority.

`event_assistance_checkpoint_work.schema.json` binds the `checkpoint_report`
Operations entity to an immutable departure request, full roster hash and exact
checkpoint scope. Departure confirmation atomically creates the run/item when a
request is supplied and rechecks caller/owner expiry, deadline and event end after
those additional reads. Legacy departures create no inferred request work.
The worker stores typed observed/unavailable facts and a finite next due time,
with five scheduled retries for unreadable sources. Completed observations have
no due time, but remain nonterminal so corrected reports can reopen the same
request. The current lease fences run/item/action-receipt commits; source wake
receipts bind signal and target and deduplicate old deliveries. There are no new
collections, client grants, contact fields, provider effects or automatic
attendance mutations. Terminal retention remains unimplemented.

The optional checkpoint-work `closeout` is a separately revisioned close/reopen
decision, excluded from the immutable departure basis. The closed command
accepts only expected revisions, source hash, decision and reason; server-owned
proof binds the full partial report and the exact post-departure dispositions
for its unconfirmed original members. `eventAssistanceCheckpointReceipts`
contains the complete change, request hash, scope, roster hash and work revision.
The atomic Operations action receipt hashes that entire domain receipt, so
historical proof remains verifiable after later work revisions. Reads check
scope, actor, time, revision, original roster coverage and both receipts.
`closedOut` is distinct from a complete arrival report and remains nonterminal
so corrected facts or explicit reopening can restore review. The optional
callable closeout view keeps legacy responses valid. No new collection, client
grant, provider effect or attendance writer is introduced.

Source scopes also distinguish sender discovery and organizer/WhatsApp endpoint
discovery from event fanout. Readiness failures use `targetKey`, a stable
expiry/document-id query tuple; event fanout keeps `workItemId`. Runtime parsing
rejects a failure or cursor from the wrong scope kind. The two private query
indexes bind runtime route selections to configuration expiry, and organizer/
endpoint permissions to permission expiry. Lookup snapshots only locate child
event/guest wake jobs; current runtime, consent and delivery records remain the
authority. Existing event-source work records remain valid under the additive
schema. No new collection or client access rule is introduced.

### Event Assistance Group Progress Contract

`eventAssistanceGroupProgress/{progressId}` is the current explicitly confirmed
destination for one live event/group. Its ID hashes the canonical execution
context and group. The whole-event scope is `event:whole`; saved pace-group IDs
use the source route's IDs. The document pins a monotonic revision, destination,
source hash, confirming manager, command identity and server confirmation time.
The source hash binds the event and plan creation generations, schedule,
meeting place, itinerary and route configuration. It excludes routine live
step changes and attendance counters. A setup change marks the projection
`sourceChanged` and withholds derived current guidance without rewriting history.

`eventAssistanceProgressReceipts/{receiptId}` records the request hash, original
committed revision and time. Its ID binds context, group and operation ID;
actor identity is included in the request hash. Progress and receipt commit
together. Exact replay returns the original operation revision plus the latest
view, including after a later departure; changed reuse fails. These records
have no TTL: command deduplication must survive the executable event lifetime,
and terminal retention/cleanup must be defined before activation.

`getEventAssistanceGroupProgress` and `confirmEventAssistanceDeparture` are
Auth/App-Check-protected and rate-limited. Canonical organizer management is
checked inside the transaction that reads event/plan/source state and writes
the result. The read response exposes only saved destination choices and
progress, without roster data. Confirmation requires matching source and
progress revisions, a current destination, an open event and a live runtime.
The collections deny all direct client reads and writes. This boundary records
a physical fact and does not authorize provider I/O or guest attendance changes.

`eventAssistanceDepartureRosters/{rosterId}` stores an immutable explicitly
selected departure roster. Its ID hashes execution context, group and committed
progress revision. New records also pin the confirmed destination; older records
without it cannot establish which checkpoint was reached. Each member pins the
registration creation generations,
exact check-in plus attendance revision, optional current participation episode
and accepted membership hash for a pace group. It contains no contact fields.
The optional `departureRosterId` on progress references only that departure;
absence denotes an unrecorded roster, while a recorded empty roster is explicit.
An optional `checkpointRequest` pins `responsibleOperatorId` and `dueAt` to this
departure and its checkpoint destination. The departure command explicitly supplies
both; legacy records infer neither. Current managers can name an authorized reporter,
while staff who can confirm departure may name only themselves. It rechecks deadline,
event end, caller expiry and the reporter's current authority after all reads.
Reporter access must extend beyond the deadline, which is limited to seven days from
confirmation and four hours after event end. No staff permission is created.

`getEventAssistanceDepartureRoster` reviews caller-selected attendee IDs under
current scoped read authority. The optional departure command selection carries
these IDs and a reviewed source hash. The write revalidates every selected row
and creates progress, command receipt and roster atomically. Selection is bounded
to 1,000 unique IDs with batched transactional reads; the `members` field is
exempted from indexing. No client can read or write the roster collection.
It has no TTL: checkpoint reconciliation and the retention policy must preserve
the original departure evidence before any terminal cleanup is introduced.

`eventAssistanceCheckpoints/{reportId}` records the current checkpoint report for
an execution context, group, departure revision and checkpoint ID. The typed
command and reviewed source hash bind that immutable departure roster, checkpoint
revision and current visit eligibility. The report stores the roster content hash,
accounted-for attendee IDs, submitting actor/time and correction reason. Missing
members stay in the denominator; guest replies and current memberships are not
physical checkpoint evidence. Any removal from an earlier report requires a reason.

`eventAssistanceCheckpointReceipts/{receiptId}` atomically preserves the authenticated
request hash and full original report. Its ID binds context, group and operation ID.
Reusing an ID with different content fails; an exact retry returns the original
revision and latest view. Reports for earlier legs remain independent of subsequent
progress. The two Auth/App-Check/rate-limited callables require a current scoped
checkpoint duty or organizer management and recheck expiry after transaction reads.
They do not require automatic assistance or an open runtime to settle outstanding
reports. New observations still require the same physical visit and source setup.
The checkpoint read view also projects the optional request's waiting, overdue,
discrepancy, complete or source-unavailable state and current owner availability.
Time and owner availability do not alter the report's reviewed evidence hash.
Complete original observations survive later source changes; partial corrections
reopen the request. These are projections of immutable request facts and current
observations, not a second durable workflow or an automatic arrival inference.
Operations request scheduling now consumes those facts under its own lease.
The optional Operations payload `reassignment` carries the effective reporter and
an independent monotonic assignment revision. The original request basis stays
unchanged. `eventAssistanceCheckpointReceipts` is a closed union of original report
receipts and assignment receipts, whose `checkpoint-reassignment:` identity binds
context, group and operation ID. Assignment evidence pins scope, roster hash,
previous/new reporter, manager, reason, server time and resulting work revision.
Its companion Operations receipt binds that same authenticated request and exact
work item. A missing or mismatched receipt cannot establish a current assignment.
The `reassignCheckpointReporter` command uses an independently reviewed assignment
hash/revision and a new operation ID; background evaluations cannot make that
review stale, while changed physical evidence or ownership can. The original
report evidence hash excludes ownership. The current response adds an optional
`assignment` projection for wire compatibility; current servers emit null when
there is no durable request. Exact retries return the original assignment revision
and current report/owner view, even after later changes. Reassignment changes no
permissions or deadline and checks the new reporter's scoped authority again after
lease/work preparation. Disposition-based closeout and staff notification delivery
remain integration work; this contract does not authorize provider sends.

Both collections deny direct client access and have no TTL. The report's
`accountedFor` and receipt's `report` fields are excluded from indexes. Limits match
the departure contract's 1,000 members, with bounded transactional reads. Terminal
retention and reconciliation must preserve the original observations before cleanup.

Live joining updates must match the canonical guidance derived from current
confirmed progress. Publication, guest-link issuance, guest views/actions and
both channel dispatch paths read that source within their owning transaction.
The destination determines the group scope; guest group-membership authority
is a separate pending fact-reader concern. Material, source identity and
validity must still match, and the message cannot invent a future progress
revision. An identical reconfirmation may advance progress without invalidating
unchanged instructions. A stale source returns no current guest instructions
and stops a pending send; a transient database error remains retryable. The
publisher must supply fresh source-derived guidance before an existing link
can show a changed destination. No additional guidance collection or schema
was introduced.

### Event Service Outbox Contract

`eventAssistanceMessages/{messageId}` is server-only delivery state owned by
trusted Event Assistance workers. Its canonical Firestore schema embeds the
portable message intent and delivery-attempt contracts. The id hashes execution
context, intent identity and revision; the immutable intent holds one guest
episode and bounded choices. Delivery attempts and guest response identities
also bind the execution context. Recipient endpoints are opaque references;
provider credentials and guest bearer grants remain outside this record.

Firestore transactions arbitrate immutable enqueue, attempt reservation,
one-time live dispatch claiming, closure and normalized receipt merging. The
history is capped at six attempts. Reservation and claiming use the same
transaction to read current event/guest/permission facts through the trusted
reader port. A claim commits an uncertain attempt before yielding permission
for provider I/O. Duplicate claims do not return that permission, and delayed
receipts remain reconcilable after closure. Contradictory delivery evidence is
sticky and blocks further dispatch pending an owned resolution.

A reservation still in `reserved` at its authorization deadline can be recorded
as `notDispatched/reservationExpired` by the next reservation transaction.
Release and claim contend on the same outbox document: a committed `unknown`
or accepted attempt can never be released by the clock. A worker with adapter
proof that permit expiry prevented all provider I/O records the separate
`notDispatched/permitExpired` reason. The older `expired` reason continues to
stop the logical message; it is not retroactively treated as retry evidence.

Both new reasons permit fresh evaluation after exponential backoff, provided
the event, guest, instruction and consent still require and allow outreach.
A replacement has a new attempt id and ordinal, and the old sender/permission
snapshot remains unchanged. Unsent attempts count against the total history
ceiling but not a channel's submission allowance. A reservation's reconciliation
hint is capped at its authorization deadline. No budget is charged for an
unclaimed reservation; spending already reserved by a claim remains charged
until separate financial reconciliation. Any later provider receipt that
contradicts an unsent record preserves a conflict and blocks pending dispatch.

No browser or mobile client can read or write this collection directly, even
with an admin claim. Guest responses use the separate scoped grant and atomic
mutation boundary described below; this outbox does not grant full runtime
access or turn self-reported intention into attendance. Scheduling, provider
activation and terminal cleanup remain delivery work. RCS permission readers
are implemented in the shared authority boundary.
The collection currently has no TTL; executable or reconcilable deduplication state
must not be deleted merely because the message's instruction has expired.

### Event Service Native Reply Contract

`eventAssistanceWhatsappReplyBindings/{attemptId}` is an immutable, server-only
choice mapping committed with a claimed live outbox attempt. Its schema pins
intent and attempt hashes, original sender/account/phone, recipient endpoint,
roster generation, guest episode and revision, response kind and offered choice
IDs. It contains no phone number, credential or guest webpage secret. The
correlation ID alone grants no action authority.

`WhatsappReplyStore.consumeQueued` reads signature-verified evidence from the
existing private `organizerMessagingWebhookEvents` queue. Exact sender,
recipient and original provider message correlation precede the shared
`applyGuestChoice` transaction. Unknown delivery correlation yields a waiting
result; expired, replaced or mismatched authority cannot execute a choice.
The webpage and provider consumer share response deduplication and case/intent
writes. Neither can change attendance, assignment or registration.

`onEventAssistanceWhatsappEventCreated` now invokes delivery and native reply
consumers from the authenticated queue. The optional `assistanceProcessing`
checkpoint is independent of campaign/Inbox processing fields. It binds the
immutable queue evidence and ingress receipt to a content hash, validates their
identity and scope, and records only bounded processing outcomes. A waiting
reply throws for the trigger's bounded retry policy; expired or permanently
rejected choices terminate. A failed checkpoint after an applied guest effect
replays the idempotent consumer, and an older waiting result cannot overwrite
terminal completion. Unrelated webhook traffic is ignored. No provider I/O
runs in this processor. These bindings have no TTL yet; activation requires
retention aligned with the outbox's reconciliation window.

Approved template snapshots now retain optional `parameterFormat`,
index-aligned `buttonLabels` and `buttonUrls`, and a `contentHash` of provider
identity, category, parameter format and complete raw components (including
body/footer/buttons). They retain the existing parameter bindings and
button kinds. Older documents still validate; native quick-reply sending
requires complete labels and a known format when variables are present. The
Meta adapter binds every quick-reply slot to an exact expected label and unique
payload, preserves parameter text, and emits names for named header/body
parameters. This metadata does not establish event-service consent or map a
label to a domain action; the trusted dispatch composition owns that mapping.

`eventAssistanceWhatsappPolicies/{senderId}` is a server-only reviewed policy
for one organizer connection and provider account/phone. Its strict schema
binds each supported message purpose to a template document, stable snapshot
hash, complete variable sources, exact native action/label/slot mappings,
maximum template age, recipient-prefix quote and bounded activation window.
Native action selectors distinguish joining intent, acknowledgement and all
four help categories. The template-purpose unions for SMS, WhatsApp and message
intents are checked for exact equality by TypeScript.

`renderEventWhatsapp` requires current matching metadata, a scoped guest grant,
exact instruction content and a complete webpage response path even when only
a subset of choices fits native buttons. Dynamic URL buttons accept only the
Catch event-update base and its grant suffix. Variables cannot be silently
trimmed or truncated; prepared-content hashes fence native payload numbering.
The snapshot hash includes provider content evidence and send metadata while
excluding sync timestamps. It detects edits observed by synchronization, not
provider-side changes after that read. Activation must enforce the reviewed
editing and synchronization policy. This record does not create consent,
debit spending or authorize dispatch; provisioning and composition with those
transactional resources remain required. Guest URL secrets stay in worker
memory, outside the policy and outbox.

`OrganizerTokenStore.accessBound` requires a numbered version in the configured
vault and the exact organizer/connection envelope. It rejects raw migration
tokens, mismatched scope and unknown envelope fields. Provider transport
rejects redirects, bounds response reads, redacts transport/provider errors and
checks a supplied deadline immediately before I/O. Once I/O starts, an uncertain
response cannot prove non-delivery. Optional callback data is correlation only;
its echo and status semantics require verification against the configured
provider account/version before Event Assistance activates it.

### Event Dress Rehearsal Isolation Contract

Event rehearsal is a separate bounded domain with five callable-owned,
server-only collections:

| Collection | Purpose | Limits and authority |
|---|---|---|
| `eventRehearsals/{sessionId}` | Frozen source snapshot, editable pre-start setup, scenario/seed, virtual clock, lifecycle and revisions | Organizer manager reads through Host callables only; 24-hour expiry; at most five active sessions per owner |
| `eventRehearsalActors/{sessionId_actorId}` | Deterministically generated synthetic people, attendance/status, independent connection state, guest moment, Room placement/confirmation, opt-out/help/prompt flags and keep-apart ids | At most 50 actors; no UID, phone, email, booking, payment, match, chat, or production attendee id |
| `eventRehearsalActions/{sessionId_actionKey}` | Idempotent Host/guest controls and deterministic replay history | At most 500 actions; a stable hash of session plus client action id deduplicates delivery |
| `eventRehearsalGuestViews/{sessionId_slotId}` | One browser-instance-to-actor lease with hashed bearer token state | Created only by the public guest bootstrap callable; link rotation invalidates prior slots |
| `eventRehearsalMessages/{messageDocumentId}` | Typed practice plan, joining instruction, simulated delivery evidence and response | Created only by a counted Host action; at most 200 messages per actor and run; no live sender binding or production outbox reference |

The schemas under `contracts/firestore/event_rehearsal_*.schema.json` and
`contracts/callables/*event_rehearsal*.schema.json` are authoritative.
Functions may read `events/{sourceEventId}` exactly once during creation to
copy a bounded title, location, duration, and supported playbook shape after
verifying organizer authority. No rehearsal handler may write a production
collection. Firestore rules deny every direct client read and write to the five
collections; App-Check-protected callables own all Host access.

Host writes carry the expected setup or runtime revision. Mutating controls and
guest actions carry a bounded client action id, exact replays return the same
projection, and stale revisions fail closed. Setup freezes at start. Reset
regenerates actors from the same seed and clears action count; fork creates a
new session. Room moves, confirmation, and pin release use the same revision
and idempotency boundary and may target only deterministic tables owned by the
rehearsal. The scheduled expiry handler deletes the bounded child set after
24 hours. Advanced latency/failure/disconnect/stale/duplicate/legacy/reduced-
motion/low-bandwidth faults require internal/admin authorization; behavioral
scenarios remain available to an ordinary organizer manager.

The public guest response contains only a practice banner, safe session fields,
one synthetic actor, its optional sanitized joining instruction, and a slot
token. `clientInstanceId` stabilizes retries in one browser; the server derives
and stores only deterministic hashes. It never
uses Firebase Auth, OTP, attendee claims, or a production roster.

Practice assistance commands and new guest-action receipts bind the request
contents to their idempotency key. A changed retry is rejected; replay of a new
guest receipt still requires the current slot token. The guest response and
its intention/help effect commit atomically, without changing attendance.
Actor assistance state stores only intention and the latest practice message
id; counters and cooldown derive from complete message history. The composite
history query includes session, actor and clock generation. Reset invalidates
that generation and deletes messages; cleanup drains bounded batches so older
remnants cannot survive a page limit. The Host projection additionally exposes
simulated attempts; the guest projection excludes delivery internals.

### Event Success Moment Presentation Contract

`contracts/catalogs/event_success_moment_presentations.json` is the authored
cross-runtime choreography source. It exhaustively covers every attendee moment
kind and owns palette and motif ids, phase durations, tempo, idle-pulse period,
particle density, the deterministic seed rule, server-clock reference, and
ambient-bed ids. The schema generator rejects missing, duplicate, or unknown
moments and fails closed when the live-reveal ceremony loses its countdown
clock, positive phase durations, or particle field.

The generator emits typed Dart into
`lib/core/schema_contracts/generated/event_success_moment_presentations.g.dart`
and TypeScript into
`functions/src/shared/generated/eventSuccessMomentPresentations.ts`. Both
outputs implement `fnv1a32-utf8-fields-v1` over event id, moment kind, reveal
round, and server anchor, with an unambiguous byte separator. Both resolve the
same anticipation, climax, settle, and completion boundaries. Live reveal uses
the saved `structureConfig.revealCountdownSeconds`; the catalog's anticipation
duration is only the legacy-document fallback, not a hard-coded client policy.
The guest runtime may consume the ambient-bed id as choreography metadata but
must not play per-attendee web audio.

### Event Success Format Primitives

`contracts/shared/event_common.schema.json` owns the closed
`eventSuccessMatchingObjective` enum (`coverage`, `romantic`, `affinity`,
`novelty`, `balance`, and `spread`) and the optional `matchingObjective` format
primitive. The same source owns the closed `eventSuccessUnitOutcome` enum
(`none`, `completion`, `score`, and `rank`) and its optional `unitOutcome`
primitive, plus `eventSuccessAccountability` (`none`, `rollCall`, `sweep`) and
its optional `accountability` primitive. The schema generator projects those contracts into Functions, Dart,
and tool registries. Runtime resolution, including the profile-free `coverage`
default, format-bound outcome defaults, and explicit unsupported assignment
algorithms, is owned by the Event Success format resolver documented in
`docs/event_success.md`; generated contract files must not encode a separate
fallback.

### Event Success Accountability Boundary

`eventAttendees/{attendeeId}` carries optional Host-owned accountability fields:
the `returned`/`departed` resolution, the exact `checkedInAt` timestamp it was
resolved for, resolver identity, and server resolution time. A resolution is
current only when its stored check-in timestamp exactly matches the row's
current check-in. This includes Host-imported and unlinked operational guests
without synthesizing a Catch UID.

Direct attendee-row writes remain denied. The generated
`setEventSuccessAccountabilityResolution` callable request accepts one current
attendee and `returned`, `departed`, or `unresolved`; the Functions transaction
validates organizer-manager authority, event identity, current check-in, and
`accountability: sweep`. The live completion request separately carries
`accountabilityAcknowledged` so an unresolved sweep warns by default but an
explicit Host choice can still complete the event.

### Event Success Live-Control Boundary

`contracts/firestore/event_success_plans.schema.json` declares the persisted
live revision and monotonic publication cursors. Direct clients serialize only
setup-owned plan fields; `liveControlRevision`, `assignmentDraftRevision`,
`publishedRotationRoundIndex`, and `publishedRevealRoundIndex` are written by
backend live-control transactions. Legacy documents may omit these fields and
resolve to their schema defaults.

Prepared guided rotations use
`eventSuccessAssignmentDrafts/{eventId_moduleId_uid}` and the source schema
`contracts/firestore/event_success_assignment_drafts.schema.json`. Each wrapper
binds the event, organizer, attendee, module, target round, base assignment
revision, and full Host-preview assignment. Rules permit only the event Host to
read drafts and deny every direct client write. Attendee-readable
`eventSuccessAssignments` contain only slots through the rotation round
published by `publishEventSuccessRotationRound`; later precomputed slots remain
inside the Host-only draft.

Live actions, draft preparation, and rotation publication use the generated
callable request schemas under `contracts/callables/`. Every mutating request
carries an expected revision, and reveal or rotation publication also carries
explicit confirmation. The asynchronous draft trigger's bounded retry count is
deployment configuration, not a persisted plan constant.

### Event Success Presence And Late-Arrival Boundary

`contracts/firestore/event_success_presence.schema.json` owns the server-only
heartbeat record at `eventSuccessPresence/{eventId_uid}`. The document stores
event/organizer/attendee identity, runtime surface, and server timestamps; it
does not persist a presence enum. `present`, `idle`, and `likelyDeparted` are
derived from the Functions server clock and the bounded deployment policy.
Direct clients cannot read or write presence documents.

The heartbeat request/response schemas and Host summary response under
`contracts/callables/` and `contracts/callable_responses/` carry the active
policy into Flutter and web. Defaults are a 30-second heartbeat, a 90-second
present window, and a 300-second likely-departed threshold. Unmonitored
attendees remain eligible; absence of a heartbeat is not departure evidence.

`contracts/firestore/event_success_late_arrivals.schema.json` owns the
deterministic Host resolution at `eventSuccessLateArrivals/{eventId_uid}`.
`resolveEventSuccessLateArrival` carries explicit confirmation and an expected
live revision. The transaction can change only the unpublished next-round
assignment draft, increments its draft revision when changed, and records a
bounded attendee-visible reason. It never writes
`eventSuccessAssignments/{eventId_moduleId_uid}`. Rules allow only the subject
attendee or event Host to get a resolution; collection queries and direct
writes are denied.

### Event Success Conversation Graph Boundary

`contracts/firestore/event_success_conversation_graphs.schema.json` owns the
attendee-private post-event response at
`eventSuccessConversationGraphs/{eventId_uid}`. The server accepts a response
only from a checked-in attendee after the event ends, filters the unified roster
through the block boundary, and stores UID edges only in this private source.
Rules allow only the subject attendee to get the deterministic document; Hosts,
other attendees, collection queries, and every direct client write are denied.

`eventSuccessPlans.conversationGraphConsentMode` is a closed `optIn` / `optOut`
setup field. Missing and legacy values resolve to the reviewed `optIn` default,
which suggests assigned attendees without selecting them. A Host may configure
`optOut` before setup freezes; it preselects visible assigned attendees and
still lets the attendee remove any or all selections or skip the response.

The generated get/submit callable contracts expose the same roster-chip
mechanism for every format while the backend derives only the prompt from
interaction primitives. Raw edges never enter the Host projection.
`eventSuccessScorecards.conversationGraph` contains numeric counts and
exclusion totals only; no attendee identifier or name-to-name edge is present.

### Event Success Spatial Layout Boundary

`contracts/shared/event_success_layout.schema.json` owns the reusable
parametric layout shape: coarse integer-grid units with bounded capacity,
stable order, and the closed `round`, `rect`, `row`, `court`, and `zone` enum.
`contracts/firestore/organizer_event_success_layouts.schema.json` stores those
assets at `organizerEventSuccessLayouts/{organizerId_layoutId}`. Layouts are
organizer-scoped, not event-scoped, and derived coordinates are never stored.
Organizer managers may query their assets; all direct client writes are denied.

`eventSuccessPlans.layoutId` selects an asset. Assignment documents separately
store `layoutUnitId` and nullable `confirmedLayoutUnitId`; assigned position is
not evidence of Host confirmation. `affinityConstraints` and
`spatialOverrides` retain the explicit T2 `thisRound` / `pinned` consequence.
The spatial callable request/response schemas own authoring, authorized layout
fetch, destination preview, reassignment, confirmation, and release. Mutating
actions carry `expectedRevision` and share `liveControlRevision` with the T4
control path.

`contracts/catalogs/event_success_layout.json` is the cross-runtime fixture for
all five shapes and normalized grid-cell rendering. Unit proximity is a
complete Euclidean graph derived from the stored grid with no cutoff. A
`wholeGroup` structure suppresses layout projection even if a legacy plan or
assignment contains stale spatial fields.

### Organizer Saved Event Venues

`contracts/firestore/organizer_event_venues.schema.json` owns reusable meeting
places at `organizerEventVenues/{organizerId_venueId}`. Each asset contains a
team-facing label, the canonical exact `meetingLocation`, an optional default
event capacity, active/archived status, and server timestamps. Organizer
managers may query their assets directly; `upsertOrganizerEventVenue` owns all
creates, edits, archival, and restoration.

Create Event copies the selected venue's location into the event and treats its
capacity only as a suggestion when the draft capacity is empty. The resulting
event may retain `sourceVenueId` as provenance, but `meetingLocation` and
`capacityLimit` remain event-local snapshots. Moving the pin clears the source
link, and later venue edits or archival never rewrite existing events.

### Event Success Sequence Capacity Boundary

`contracts/shared/event_common.schema.json` owns the closed `topology` values
(`set`, `sequence`, `adjacency`) and the optional `resourceCapacity` object.
`concurrentUnits` is a configurable simultaneous-resource limit; null means
unconstrained. `resourceLabelId` is one of `court`, `table`, `lane`, or `board`.
`seatsPerUnit` may be non-null only for `adjacency` and does not enable the
deferred table-seating engine.

`sequence` is implemented only with `pairRotations`. The server scheduler
produces ordered, capacity-bounded rounds, explicit sit-out slots, and stable
`resourceUnitId` values on rotation slots. It consumes the same cumulative
exclusion totals used by T3 and the derived `unitProximity` graph from T5.
`adjacency`, `tableSeating`, and other sequence-algorithm combinations remain
explicitly unsupported in the exhaustive resolution table; no neighbouring
engine fallback is permitted.

### Event Success Unit Outcomes And Standings

`contracts/firestore/event_success_unit_outcomes.schema.json` owns the
server-written round facts at `eventSuccessUnitOutcomes/{eventId}`. One entry
contains exactly one of `completed`, `score`, or `rank`; duplicate units,
partial rank orders, non-sequential new rounds, and values that do not match the
saved `unitOutcome` fail closed. Outcome facts are Host-readable and never
direct-client writable.

`recordEventSuccessUnitOutcomes` is the organizer-manager-only,
App-Check-protected writer. Its generated request carries `expectedRevision`, one round
index, and a complete unit-entry set. Exact replay is idempotent before revision
checking. A correction replaces that round: score projections are recomputed
as accumulated totals, while rank projections use the latest complete ordering.
`completion` persists source facts without creating a standings projection;
`none` rejects recording.

`contracts/firestore/event_success_standings.schema.json` owns the derived
`eventSuccessStandings/{eventId}` snapshots for `score` and `rank`. Authorized
Hosts, active participants, and ready no-download runtime identities may get
the event-scoped projection; list and every direct write are denied. The
projection stores a snapshot for each recorded round so Flutter and the guest
runtime can select only the latest snapshot at or before the plan's published
reveal round. It reuses `publishedRevealRoundIndex` and the existing
server-anchored reveal state; it does not define a second ceremony or cursor.

### TypeScript Timestamp Projections

Functions code has two generated TS projections for Firestore documents. Both
come from JSON Schema; the boundary is the timestamp representation:

- **`functions/src/shared/generated/*.ts` — JSON Schema-derived.** Timestamps
  appear as serialized `{_seconds: number, _nanoseconds: number}` objects.
  Use for callable payload validation, fixtures, demo seed data, and any code
  that reads or writes the persisted JSON shape directly.
- **`functions/src/shared/generated/firestoreAdminTypes.ts` — Admin SDK
  projection.** Timestamps appear as `FirebaseFirestore.Timestamp` instances.
  Use when Functions code interacts with Admin SDK methods that return live
  Timestamp objects, for example `doc.data()` after a Firestore read.

`tool/contracts/generate_schema_contracts.mjs` emits both projections.
`tool/contracts/check_firestore_contract.mjs` cross-checks that the Admin SDK
projection has the expected fields for every collection with a
`typescriptInterface` entry.

### Public HTTP And Admin Callable Boundaries

The public `/api/join-waitlist` endpoint uses the versioned schemas under
`contracts/http/` for both member waitlist and optional Host application
payloads. The generator emits the same types into website and Functions code;
Functions validates incoming requests and every JSON response, while the
website validates response JSON before treating a submission as successful.

High-risk Admin overview, access-decision, role, safety, and marketing mutation
requests/responses use dedicated schemas under `contracts/callables/` and
`contracts/callable_responses/`. The generator emits Functions and Admin types,
and `admin/scripts/generateCallableValidators.mjs` compiles the same schema
sources into the browser runtime validator registry.

## Organizer Authority

`organizers/{organizerId}` is the canonical organization entity. `club` is an
organizer subtype, never a peer top-level entity. The required
`organizerType` enum is `club`, `community`, `individual`, `eventProducer`,
`venue`, or `brand`; no legacy `entityKind` value is read. Missing
`appVisibility` fails closed as `hidden`. The complete
mapping, rollout, parity, and recovery procedure is owned by
`docs/migrations/clubs_to_organizers.md` and
`contracts/migrations/clubs_to_organizers.json`.

New contracts use `organizerId`, `organizerTeamMemberships`,
`organizerFollows`, `organizerClaimRequests`, `organizerScheduleLocks`, and
`organizers/{organizerId}/posts`. Legacy `clubs`, `clubMemberships`,
`clubClaimRequests`, `clubScheduleLocks`, `clubId`, and club-media projections
are not local contracts, callable aliases, rule paths, or client fallbacks.
Production canonical parity completed on 2026-07-22; because the application
has not launched, the owner approved local compatibility retirement rather than
a released-client support window. Remote synthetic-data reset and deployment
remain separately authorized operations.

Public organizer website content is also owned by the canonical organizer
document. `publicPage` controls publication, indexing, canonical and legacy
paths; `publicProfile`, `publicSources`, `provenance`, `claim`, and `ownership`
provide the owner-safe projection inputs. Production Hosting exports those
fields from Firestore at build time. Repository JSON must not be used as the
editing or approval surface.

Organizer document identity and public routing are separate contracts.
`organizers/{organizerId}` uses an opaque Firestore auto-id. A client may
reserve that auto-id before uploading media, but a name or URL slug is never
accepted as the document id. `publicPage.slug` owns the human-readable route
segment, `publicPage.canonicalPath` owns the website URL, and
`publicRouteReservations` transactionally enforces route uniqueness. Renaming
or rerouting an organizer therefore does not require changing its document id
or relationship references.

### Organizer Supply Capabilities

Every canonical organizer, compatibility club projection, and published
external-event organizer snapshot carries the shared
`organizerSupplyCapabilities` contract. It is an explicit product-policy
projection, not a UI inference:

- unclaimed/programmatic supply is not bookable, payable, waitlistable, or
  host-contactable; it is claimable and becomes reviewable only after the
  event's end time;
- claimed/owner-managed supply may enable the supported capabilities, subject
  to the normal event, payment, and availability checks;
- missing or invalid capabilities fail closed.

Create, claim, draft-scaffolding, and claim-decision callables write the
projection. Existing canonical and compatibility documents were repaired with
`tool/data/backfill_organizer_supply_capabilities.mjs`: the production apply on
2026-07-27 repaired 44 organizers and 42 clubs, found no external events, and a
post-apply dry run reported 86 current documents with zero repairs or invalid
records. The migration contract is
`contracts/migrations/organizer_supply_capabilities.json`.

### Required Event Meeting Location

Every persisted `events/{eventId}` and published external event must have a
named, finite, in-range exact location. The canonical object is
`meetingLocation`; `meetingPoint`, `startingPointLat`, and `startingPointLng`
remain synchronized compatibility mirrors while released clients still use
them. They are not nullable escape hatches.

- Create requires an exact scalar pair and canonicalizes it into
  `meetingLocation`; newer clients may send the structured object directly.
- Update resolves the existing or supplied exact location and always rewrites
  the canonical object plus mirrors. It rejects a truly coordinate-less legacy
  document instead of preserving corruption.
- Dart `Event` and `ExternalEvent` keep exact coordinates nullable on reads
  until the production repair is complete. `Event.effectiveMeetingLocation`
  deterministically promotes a complete legacy pair, while coordinate-less
  records remain readable and fail closed anywhere an exact location is
  required.
- Discovery and proximity check-in fail closed when the invariant is broken;
  they never publish a null geo cell or skip the distance guard.
- `node tool/data/backfill_event_meeting_locations.mjs --env <env>` is the
  dry-run-first repair path. It never invents coordinates or mixes latitude
  and longitude from different sources.

Dev was verified clean on 2026-07-13: 146/146 events have structured exact
locations and the location-market and discovery repair tools report zero
remaining work. The production dry run found 138 deterministic repairs and 9
historical records without recoverable coordinates; production was not
mutated, and strict production rollout remains blocked on resolving those nine.

## Normal Workflow

```bash
node tool/contracts/generate_schema_contracts.mjs
node tool/contracts/generate_schema_contracts.mjs --check
node tool/contracts/validate_schema_contracts.mjs
./tool/check_data_contract.sh
```

Run Firestore and Storage rules tests through emulators unless those emulators
are already running:

```bash
firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"
```

A direct `npm --prefix functions run test:rules` expects Firestore on
`127.0.0.1:8080` and Storage on `127.0.0.1:9199`. `ECONNREFUSED` is an emulator
workflow failure first, not proof the rules are wrong.

Storage rules that call Firestore have a second, live dependency which the
emulators cannot prove. Every environment's Firebase Storage service agent must
hold `roles/firebaserules.firestoreServiceAgent`; the checked preflight and
idempotent provisioner are documented in `docs/release_operations.md`. Keep
each Storage evaluation within Firebase's Firestore document-access limit.
Match chat images therefore authorize from the canonical match document, whose
`status: blocked` projection is owned by the block callable/trigger. Their
contract also requires immutable `uploaderUid` custom object metadata: only
that active-match participant may create or compensate-delete the object, and
client updates are denied. Prove this boundary with both emulator rules tests
and the authenticated live upload/delete canary.

### Host Payment Account Provider Boundary

`hostPaymentAccounts` is a user-and-provider projection owned by payment
callables. New documents use `{uid}_{provider}` ids and must carry the explicit
`provider`, generic `providerAccountId`, and provider-specific identifier
fields from `contracts/firestore/host_payment_accounts.schema.json`. The
provider enum is currently `razorpay | stripe`. Legacy Stripe documents at
`{uid}` remain readable and refreshable; new Stripe and Razorpay writes use the
provider-scoped ids so one host can retain both accounts without overwriting
either state.

Razorpay Route setup accepts legal-business, stakeholder, PAN, and bank details
through the callable payload contract. Those values are transient provider
inputs and must never be written to Catch Firestore or logs. The persisted
projection contains only Razorpay linked-account/product ids, normalized
activation state, and bounded requirements. Each provider-created id is
checkpointed before later provider calls so an exact retry resumes the same
linked account or product.

The Flutter repository returns a list of provider accounts. Country-based
recommendation is presentation policy only: India recommends Razorpay and
other countries recommend Stripe, while both setup paths remain available.
Checkout routing and eventual settlement remain server-authoritative and must
not infer readiness from the recommendation badge alone.

## Contract Architecture

JSON Schema draft-07 is the canonical persisted-shape format. Ajv validates
schemas in Functions/tooling, generated Dart constants support Flutter tests and
selected production validation, and Firestore rules remain behavioral security
checks rather than a generated JSON Schema runtime.

The contract layer owns:

- collection ids and storage paths;
- full document shapes and patch/input payloads;
- enum values and scalar limits;
- field optionality/nullability;
- prompt/catalog ids and limits;
- ownership metadata such as client-writable, callable-owned, trigger-owned,
  server-only, and read-only projection (see "Field Ownership Tags" below);
- migration metadata for path/storage renames;
- valid and invalid fixtures.

### Functions Runtime Schema Modules

The schema generator emits independent runtime modules under
`functions/src/shared/generated/schemas/`, `validators/`, and `catalogs/`.
Callable module names use `Input` and `Output` suffixes; exported schema,
validator and TypeScript type names retain their contract-owned identities.
Each validator imports its own schema and the small shared
`schemaValidationRuntime.ts` engine. The engine owns Ajv options, formats,
lazy per-schema compilation, caching, and error messages.

Production Functions import these modules directly. `schemaRegistry.ts` and
`schemaValidators.ts` are aggregate inventories for tests and tools, and must
not be imported or re-exported by runtime modules. Admin SDK projections in
`firestoreAdminTypes.ts` are compile-time types and consumers use explicit
`import type` or `export type`. The schema/type boundary check enforces these
rules; fixture and lazy-loading tests verify unchanged data validation.
The generator removes orphaned runtime module outputs during regeneration and
reports them as stale in `--check` mode.

The deployment dependency graph excludes whole-declaration type-only edges,
which TypeScript erases. Shared runtime/schema changes still select every real
consumer. The Functions codebase and package remain the deployment artifact
boundary; this module split enables narrower explicit targets, not separate
Firebase packages.

### Optional, Nullable, And Patch Fields

Default DTO, view-model, and document fields to plain nullable values when
absence and explicit `null` have the same product meaning. Use required
nullable parameters only when the caller must explicitly confirm that the field
was considered, and prefer avoiding that shape unless it materially improves the
API contract.

Use sentinel-backed parameters only for patch/copy APIs where "leave unchanged"
must be distinguishable from "clear this nullable field." Generated patch
classes use `unsetSentinel` from `lib/core/sentinels.dart` and compare it with
`identical`; callers should pass `null` only when the persisted value should be
cleared. Do not add new ad hoc sentinels outside patch/copy semantics without
first documenting the same clear-versus-omit distinction.

### Field Ownership Tags

Per-field ownership lives next to the property in the Firestore schema as
`x-catch-ownership`. Valid values: `client-writable`, `client-runtime-writable`,
`callable-owned`, `trigger-owned`, `server-only`. Properties without a tag are
unclassified — typically content fields that flow through a callable without
the callable owning their lifecycle.

```json
"hostUserId": {
  "$ref": "../shared/event_common.schema.json#/definitions/documentId",
  "x-catch-ownership": "callable-owned"
}
```

`tool/contracts/firestore_contract.json` deliberately does NOT carry
per-collection field-group arrays (`clientWritableFields`, etc.). Those are
derived from `x-catch-ownership` and validated by
`tool/contracts/check_firestore_contract.mjs`. The contract file still owns
collection-level ownership metadata (paths, rules-match strings, operations,
exported function names, migration notes).

It does not own multi-document business behavior, ranking algorithms,
notification fan-out, dynamic Auth/current-time checks, or full Firestore rules.
Those stay in Functions, repositories, rules, and domain services, consuming
generated constants/validators where useful.

### Generated Dart Callable Request DTOs

`tool/contracts/generate_schema_contracts.mjs` emits typed Dart classes for
every callable payload schema (and the `update_user_profile` patch) into
`lib/core/schema_contracts/generated/callable_request_dtos.g.dart`. Each class
has a named-parameter constructor, typed fields, and a `toJson()` that the
existing `test/core/callable_dto_contracts_test.dart` validates against the
source schema. Generated patch helpers expose `toFieldsJson()` for repository
tests and `toCallableJson()` for the actual callable payload wrapper.

Feature-level `lib/**/data/*_callable_dtos.dart` files remain only when they
own hand-written response parsers, normalization, or other behavior. Pure
re-export barrels should be deleted; callers can import generated request DTOs
directly from `callable_request_dtos.g.dart` with explicit `show` lists.
Hand-written DTO classes remain in feature files only when the JSON Schema
cannot capture the behavior — specifically:

- domain → DTO adapter factories (`CreateEventCallableRequest.fromEvent(Event)`)
  that walk a domain model and convert `DateTime` → `int millis`;
- serialization-time normalization that the generated class does not yet own
  (`EventBookingCallableRequest` and `CreateRazorpayOrderCallableRequest` trim
  `inviteCode` even though dedicated payload schemas exist);
- serialization-time shape transforms (e.g.
  `PlacesAutocompleteCallableRequest` flattens a `LocationCoordinate? bias`
  into top-level `latitude`/`longitude`);
- response decoders (`*CallableResponse` with `fromCallableData` factories)
  and feature-local exceptions.

See backlog item `CONTRACT-DART-GEN-001` for the path to migrating the
remaining cases (custom normalization, generated adapters, and response
decoders).

### Field Constraint Projection

The schema generator also emits
`lib/core/schema_contracts/generated/field_constraints.g.dart`. It projects
UI-relevant requiredness, value and item types, string length, format, pattern,
enum values, collection bounds, uniqueness, numeric bounds, and `multipleOf`
steps from every registered schema into typed
`CatchContractFieldConstraints` constants. The projection includes persisted
documents, callable payloads, and `contracts/forms/mobile_form_state.schema.json`
for editable presentation values that are deterministically transformed before
they are stored.

The presentation-neutral `CatchContractFieldConstraints` value type and
`CatchContractFieldPolicy` live in `packages/catch_ui/lib/src/components/`.
The generated app file imports that shared type and owns the concrete schema
paths, values, and `CatchContractConstraints` lookup. The shared UI package
does not import the generated app constants or the schema generator.

`CatchContractFieldPolicy` applies those constants at runtime. Text controls
derive validators, counters, and length formatters; choices filter values
through an explicit typed-to-wire serializer; steppers and range sliders derive
bounds and steps. Explicit UI values may narrow a contract for product policy
but cannot relax it. Composite controls bind each independently stored endpoint.

Every editable canonical control and descriptor instance under production
`lib/` is covered by the source scanner. Its optional report is generated at
`build/reports/flutter_form_contract_inventory.json`. The scanner
recognizes `CatchField`, `CatchChipField`, selectable chips, option groups/cards,
range sliders, toggles, OTP entry, direct and top-bar search fields,
`CatchForm*Row`, and the retained self-profile descriptors. It fails when a
control lacks its generated contract, a typed choice lacks its serializer, a
range lacks either endpoint, or an exemption is not explicit. The current two
exemptions are disclosure-only Host analytics controls, not editable form
values.

Run the exhaustive gate with:

```sh
node tool/run.mjs check contracts:flutter-form-inventory
```

`test/core/forms/contract_alignment_test.dart` additionally walks the
consumer-profile and host-club descriptor factories and contains a seeded
over-limit probe, so contradictory limits remain detectable. Run it through
`node tool/run.mjs check contracts:form-alignment`. Contract CI runs both gates
and keeps the generated schema projection deterministic with the generator's
`--check` mode.

## Relationship Documents

Root-level edge/action documents are the source of truth for many-to-many state:

| Relationship | Source document |
|---|---|
| Organizer owner/manager seat | `organizerTeamMemberships/{organizerId_uid}` |
| Organizer follow | `organizerFollows/{organizerId_uid}` |
| Event booking, waitlist, attendance, cancellation | `eventParticipations/{eventId_uid}` |
| Unified Host operational roster row | `eventAttendees/{attendeeId}` |
| Roster import audit and idempotency receipt | `eventAttendeeImports/{importId}` |
| Private no-download Event Success identity | server-owned `eventRuntimeParticipants/{eventId_uid}` |
| Short-lived Host venue authority | server-only `eventVenueSessions/{sessionId}` |
| Per-attendee venue redemption | server-only `eventVenueSessionRedemptions/{sha256(eventId_sessionId_uid)}` |
| Ambiguous or walk-in Event Success claim review | server-owned `eventRuntimeClaimRequests/{eventId_uid}` |
| Organizer-scoped communication permission | server-only `organizerCommunicationPreferences/{organizerId_uid}` |
| Organizer-scoped operational contact | server-only `organizerContacts/{contactId}` |
| Contact-to-event fact | server-only `organizerContactEventEdges/{attendeeId}` |
| Contact identity evidence and verified claim | server-only `organizerContactIdentityLinks/{evidenceId}` and `organizerContactIdentityClaims/{claimId}` |
| Contact merge decision and reversible receipt | server-only `organizerContactMergeReviewDecisions/{decisionId}` and `organizerContactMergeReceipts/{receiptId}` |
| Rebuildable contact traits and organizer summary | server-only `organizerContactTraits/{contactId}` and `organizerAudienceSummaries/{organizerId}` |
| Invitation aggregate and isolated bearer token | host-readable `eventInviteLinks/{inviteLinkId}` and server-only `eventInviteLinkSecrets/{inviteLinkId}` |
| Short-lived invite open/share evidence | server-only `eventInviteTouches/{touchId}` and `eventShareIntents/{intentId}` |
| Verified registration/check-in attribution | server-only immutable `eventInviteAttributions/{attributionId}` credit/reversal fact |
| Organizer campaign and recipient snapshot | server-only `organizerCampaigns/{campaignId}` and `organizerCampaignRecipients/{recipientId}` |
| Organizer Announcement history projection | server-only `organizerBroadcastSummaries/{broadcastId}`; manager clients use `listOrganizerCampaigns` and contact-detail callables |
| Organizer WhatsApp sender/template state | server-only `organizerSenderConnections/{connectionId}`, `organizerMessageTemplates/{templateId}`, and webhook receipts/events |
| Organizer WhatsApp Inbox and reply reservation | server-only TTL-bound `organizerWhatsappThreads/{threadId}`, `organizerWhatsappMessages/{messageId}`, and `organizerWhatsappReplyOperations/{operationId}` |
| External provider connection and event mapping | server-only `organizerProviderConnections/{connectionId}`, `externalEventMappings/{mappingId}`, and `providerSyncRuns/{runId}` |
| Event-scoped staff authority | server-owned `eventStaffGrants/{eventId_uid}` with direct reads denied |
| Cross Paths event visibility | `eventCrossPathsConsents/{eventId_uid}` |
| Cross Paths showcase eligibility | server-only `crossPathsShowcaseEligibility/{uid}` |
| Cross Paths suggestion exposure | server-only `crossPathsSuggestionExposures/{exposureId}` |
| Cross Paths invitation | `crossPathsInvitations/{eventId_senderUid}` |
| Cross Paths companion hold | `crossPathsPairHolds/{holdId}` |
| Cross Paths accepted event plan | `matches/{event_pairHash}` with `conversationType: crossPathsEventPlan` |
| Saved events | `savedEvents/{uid_eventId}` |
| Outgoing profile decisions | `profileDecisions/{uid}/outgoing/{targetId}` |
| Match messages | `matches/{matchId}/messages/{messageId}` |
| Notification timeline | `notifications/{uid}/items/{notificationId}` |
| Organizer follower posts | `organizers/{organizerId}/posts/{postId}` |

Retired relationship arrays must not be reintroduced into Flutter models,
Functions writes, Firestore rules, active tooling, or tests. Parent entity docs
keep only aggregate projections such as `followerCount`, `bookedCount`,
`waitlistedCount`, `checkedInCount`, `genderCounts`, `rating`, `reviewCount`,
and `nextEventAt`.

Direct client writes are still allowed only for narrow owner-owned actions that
rules can prove locally: onboarding drafts, launch access applications, saved
events, outgoing profile decisions, match-scoped chat messages, own unread
reset, own notification `readAt`, and own FCM token. The
`accessApplications/{uid}` rule accepts only the authenticated owner's strict
application shape while its status is editable, increments `submissionCount`,
and preserves Admin-owned status, cohort, reviewer, and activation fields.
Multi-document product writes belong in callables or triggers.

Raw `eventParticipations` reads are equally narrow: a participant may read
their own deterministic edge, and an authorized event host may read the roster
for an event they manage. Consumer discovery surfaces must not query a whole event
roster. Post-event Catch, Event Recap, and identified post-event avatar
enrichment use the App-Check-protected `fetchSwipeCandidates` callable, which
returns only public profile projections after the server verifies the
24-hour window, viewer attendance, reciprocal gender and age preferences,
prior decisions, and blocks in both directions. Anonymous attendee volume is
rendered from callable-owned event aggregates instead of roster enumeration.

### Standalone Host Operational Attendees

`eventAttendees` is the Host operations roster. It complements rather than
replaces `eventParticipations`:

- `eventParticipations` requires a real UID and continues to own Consumer
  booking, waitlist, cancellation, payment linkage and profile/network
  eligibility;
- `eventAttendees` uses an opaque event-scoped attendee id and accepts
  `catchBooking`, `hostImport`, `hostManual`, or `webOtp` as its source. Its
  optional `linkedUid` is a server projection, never a synthetic account;
- raw contact fields are private to an authorized organizer manager and
  callable/Admin support boundaries. Public website, Consumer discovery and
  aggregate analytics cannot enumerate them;
- a Catch booking may use the Firebase Auth verified phone only to converge
  with an event row whose contact data the organizer already supplied. It
  never copies `users/{uid}.phoneNumber` or `users/{uid}.email` into a new
  attendee row, organizer event edge, or CRM contact;
- the production website snapshot uses Firestore `count()` aggregation queries
  for registered, checked-in, and waitlisted totals. Only free,
  open-admission events with an explicit Host publication switch qualify; paid,
  invite, membership, approval, and profile-balanced events fail closed. The build identity never
  downloads attendee documents or contact fields;
- direct writes are denied. Host bulk import/manual entry, attendance changes,
  Catch-booking projection, OTP linking and public registration are
  server-owned operations;
- deterministic contact/source keys make retry and re-import idempotent inside
  one event. A phone/email match may converge rows inside that event only; it
  does not build a cross-event identity graph;
- `arrivalGroup` retains an optional provider booking/order/group or
  ticket-buyer key shared by guests expected to arrive together. Adapters keep
  it separate from attendee-level external references, imports include it in
  their canonical payload hash, and it remains private roster data;
- optional attendee revenue fields retain organizer-reported CSV amounts,
  explicit organizer-entered per-guest estimates, or financially complete
  provider facts with their currency and allocation provenance. Repeated equal
  imported totals in one `arrivalGroup` are treated as one shared order and
  allocated across its guest rows exactly once. These facts never become
  verified Catch payments by inference;
- `eventAttendeeImports` records actor, event, client idempotency key, format,
  canonical payload hash, counts, bounded row errors and terminal state. It is
  not a copy of the uploaded file.

Hosts may list operational attendees and import receipts only for events they
manage. An attendee does not gain roster-list access when their UID is linked;
attendee-facing code receives only its own sanitized event state through a
server-owned lookup/registration boundary.

Phone-OTP public registration creates or reuses a private Firebase Auth UID; it
does not create `users/{uid}`, `publicProfiles/{uid}`, or a Consumer
`eventParticipations` edge. On first registration, the callable may create a
private `onboarding_drafts/{uid}` seed using only the attendee-supplied display
name and verified phone. That seed is a continuation convenience for a later,
intentional Consumer onboarding flow, not a profile or advertising permission.
The person must review/edit the draft before any public or dating-profile
projection is created.

### External Booking Event Success Runtime

An event may carry optional server-owned `eventOrigin` and `runtimeAccess`
objects. Their absence preserves legacy behavior. `eventOrigin.mode` records
whether Catch owns the booking (`catchNative`) or overlays an event booked on
another provider (`externalCompanion`); its provider/source identifiers are
provenance, not a claim that Catch owns or has synchronized the source event.
`runtimeAccess.publicRuntimeId` is an opaque join identifier, never the event
document id or a bearer authorization credential. The runtime bootstrap
callable resolves it and returns only a bounded public event projection. That
projection includes non-negative aggregate `checkedInCount` for the anonymous
co-presence visual; it does not include a roster, attendee identifiers, or
per-attendee attendance state.

`eventRuntimeParticipants/{eventId_uid}` is the private bridge between a
Firebase phone-auth identity and an event-scoped operational attendee. It owns
the claim method, optional `eventAttendeeId`, minimum runtime-profile fields,
explicit terms versions, and readiness state. It does not create or imply a
Consumer `users/{uid}`, `publicProfiles/{uid}`, `eventParticipations/{eventId_uid}`,
dating match, or marketing grant. Clients may get only their own deterministic
edge; list and direct writes are denied. Event Success modules authorize a
`ready` runtime edge independently of the Consumer booking/network edge.

Attendance authority is separate from runtime identity and joinability.
`eventVenueSessions/{sessionId}` backs a short-lived signed token issued only to
an organizer manager during the check-in window. The Host screen refreshes it
before expiry. `eventVenueSessionRedemptions/{sha256(eventId_sessionId_uid)}`
atomically binds one authenticated attendee to one displayed session and rejects
replay by that attendee; different attendees may redeem the same live display.
Both collections deny all direct client access and use `expiresAt` TTL. A static
`publicRuntimeId` URL, printable event QR, or latitude/longitude claim carries no
attendance authority.

When the verified phone cannot be matched unambiguously, or when the event's
walk-in policy requires review, the server writes
`eventRuntimeClaimRequests/{eventId_uid}` with only the last four phone digits
and bounded candidate attendee ids. Authorized organizer managers may review
that request through a callable. A rejection cannot expose alternative roster
identities to the claimant.

The minimum event-scoped questionnaire is plan-derived. Display name is always
required; sensitive or compatibility fields are requested only when an enabled
module needs them. Saving the answers as a later Catch onboarding prefill is a
separate explicit consent. A prefill remains private and must never overwrite a
completed Consumer profile or create a public projection.

### Organizer Communication Preferences And CRM

`organizerCommunicationPreferences/{organizerId_uid}` is a server-only,
organizer-scoped permission ledger. WhatsApp and SMS each have independent
`unknown`, `optedIn`, or `optedOut` state, terms version, source event, source,
and timestamp. Public registration writes only an explicit checked opt-in. An
unchecked box does not grant permission and cannot revoke a prior grant;
withdrawal belongs to the future self-service/STOP callable. Host imports and
manual roster entry never create channel permission.

Each non-unknown channel preference carries a permission receipt sufficient to
explain the decision without reading private response content: source kind,
nullable source event/form/response ids as applicable, terms version, consent
copy hash, grant timestamp, and nullable revocation timestamp/source. A legacy
row without complete evidence remains explicitly incomplete or unknown; a
backfill must never infer or promote permission from a phone number, contact
source, roster membership, form answer not bound to the reviewed consent copy,
or prior send.

`tool/data/backfill_organizer_crm_authority_v2.mjs` is the dry-run-first
additive migration. It creates contact origins only when a canonical attendee
edge names both current and original contact identity. Existing non-unknown
preference state without a complete referenced receipt becomes an immutable
`legacyIncomplete` receipt and remains ineligible for managed delivery. The
tool reports, rather than guesses, attendee rows whose canonical edge is
missing. The migration is available in source but has not been applied to any
environment.

`organizerContactOrigins/{originId}` is the immutable multi-source provenance
ledger for organizer CRM contacts. Each deterministic row records organizer,
current contact, origin contact, source kind, source entity kind/id, nullable
form/event/response ids, actor class and bounded actor uid where appropriate,
observed time, and creation time without copying raw response or message bodies.
Merges may move the current contact id while retaining the origin contact id;
unmerge uses receipt-named origin facts and never guesses later ownership.
`organizerContacts.primarySource` remains a compatibility summary during the
additive migration and is not a complete history.

Every canonical `eventAttendees` write projects into an organizer-scoped
contact plus one event fact edge. A contact is operational memory for one
organizer, not a Consumer profile. An imported normalized phone/email creates
only proposed identity evidence; it never silently merges two people. A UID or
person-verified OTP phone may own a singleton identity claim. Conflicting
verified claims stop automatic convergence and require an immutable,
reversible manager merge receipt. Name alone is never merge evidence.

Manager merges are optimistic and receipt-backed. The client supplies the
current survivor and source revisions; the transaction also verifies every
source-origin fact has the same Firestore version observed during planning.
Conflicting UID, phone, or email facts require explicit confirmation. Unmerge
restores only the exact source-origin edge, evidence, claim, and contact-origin
identifiers in the original receipt and creates one deterministic reversal
receipt. Facts
created after a merge remain with the survivor instead of being guessed back.
The manager review boundary lists conflicted verified UID/phone claims plus
exact proposed phone/email hashes. It derives shared events, source kinds and
confidence at read time, never proposes name-only matches, and stores a
`organizerContactMergeReviewDecisions` row when a manager chooses Different
people. Only that manager may reopen the decision. Contact detail returns the
newest active merge receipts for the survivor so each receipt can be reversed
individually.

Account deletion is the only erasure exception to receipt and origin retention:
it deletes permission receipts carrying the participant UID and redacts that
UID from retained contact-origin facts while preserving non-PII source
classification.

`organizerContactTraits` are rebuilt from event edges and verified invite
attribution facts and contain only
attendance, reliability, source and channel-reachability facts. Compatibility
answers, gender, sexual orientation, relationship state, wingman targets,
safety reports and inferred social desirability are prohibited CRM inputs.
An `advocate` has at least one verified referred registration or check-in. A
`high_impact_advocate` has at least three referred verified check-ins in the
trailing 365 days; raw link opens and share-button taps never qualify.
`past_attendee` is the canonical broad attendance segment for at least one
checked-in event; `repeat_attendee` begins at two. New definition-v3 trait rows
store both the broad and applicable narrower segment. Directory, export, and
saved-audience evaluation still resolve `past_attendee` from
`attendedEventCount > 0`, so older trait rows remain correct before they are
recomputed and clients never union independently paginated segment results.
Trait and summary writes use exactly-once TTL receipts, so retries cannot
double-count an organizer. The dry-run-first organizer-audience backfill uses
the same production projector and marks a summary `exact` only after every
current attendee row has completed. Its discovery set is the union of attendee,
contact, and incomplete-summary organizers, so a manual-only organizer with
zero attendees can still be completed. Newer live rows always win over stale
backfill snapshots. A missing or partial summary is also effectively `exact`
when a bounded canonical-history check proves that the organizer has no
`eventAttendees`; absence of projection state alone is not treated as an
incomplete migration.

`getOrganizerCrmSummary` reads `organizerAudienceSummaries` only when its
coverage is `exact` and returns only privacy-bounded counts for contacts, past
and repeat attendees,
linked accounts, imports, and explicit WhatsApp/SMS reachability. During the
dual-write migration it falls back to the legacy bounded attendee/preference
scan for organizers without exact coverage. Partial summaries remain migration
diagnostics and never replace the legacy cards. It never returns attendee
identity or contact fields. `listOrganizerContacts` and
`getOrganizerContactDetail` are separate manager-authorized, server-paginated
boundaries. They return only organizer-owned endpoints plus explainable
attendance/reachability facts; no Event Success private input is a CRM field. The
current detail UI requests `includeHistory: false`: attendance, revenue, memory,
permission, and source provenance remain available, while campaign, broadcast,
manual-send, reply, form-response timeline, and merge-history reads are deferred
until History opens. `historyLoaded: false` and unavailable timeline coverage
keep an unrequested history distinct from no activity. Omission of the request
flag preserves the full response for older clients. A new client retries without
the flag only for the old server's exact `includeHistory: must NOT have
additional properties` diagnostic; other validation and access failures are
not retried. Loading all tabs can add a
second invocation and repeat core reads; overview-only visits omit operational
queries. No minimum instances or new persistent listeners are introduced.
The directory accepts `lastSeen`, `mostAttended`, or `name`; every opaque cursor
is versioned and bound to its query plan, filters, and ordering. Filtered sorts
are computed over a bounded complete candidate set rather than sorting one
already-paginated page, and an over-limit candidate set fails explicitly.
`createOrganizerContact` requires a contact name plus at least one
organizer-entered phone/email evidence value, may add an optional first private
note, and creates its zero-history
trait. Organizer-entered endpoints remain `proposed`, organizer-scoped evidence:
they create no attendee, verified identity, UID, Consumer profile, opt-in, or
messaging grant. Only unlinked contacts whose primary source is `hostManual`
may later edit those endpoints but cannot remove its last endpoint. Legacy and
system-derived name-only records remain readable and can still rename without
being forced through a migration. Customer detail unifies event-scoped
revenue from completed, non-refunded Catch payments, financially complete
provider orders, organizer-imported amounts, and explicit organizer estimates.
Every amount retains its source; reported and estimated values are never
presented as verified payments. A Catch payment takes precedence over a
reported fact for the same customer event so the sale is not counted twice.
Imported and estimated revenue does not require a linked Catch UID. Event rows
hydrate the bounded canonical event set so legacy edges immediately receive an
event label and Catch-native, external-companion, or unknown origin; new edge
projections also retain that snapshot. Revenue reports partial coverage when
the bounded event timeline or an eligible linked-UID payment scan truncates.
Hosts currently retain event-scoped roster access through the existing
authorized roster boundary. The Host Audience client consumes the directory,
detail, export and contact-mutation callables; it never reads these collections
directly. Organizer-authored CRM memory remains structurally separate from
computed traits: `organizerContacts.manualTagIds` references a maximum of five
entries from the organizer's server-owned
`organizerContactTagVocabularies/{organizerId}` document, whose vocabulary is
capped at twenty. `organizerContactNotes` stores author-stamped note records;
new notes append, edits use optimistic revisions, contact detail returns the
newest bounded window, and exports never include note content. Existing contact
documents may omit `manualTagIds` and read as an empty assignment, so neither
feature requires a backfill.

`organizerSavedAudiences/{audienceId}` owns reusable Customers-authored CRM
audiences. A definition contains one to eight predicates joined by `all` or
`any` over the reviewed computed-segment, organizer-tag, attendance-count,
last-seen recency, named-intent reach, application status by form, immutable
filterable choice/boolean answers, named-event attendance, and Catch spend.
Spend specifies a currency, a minimum/maximum minor-unit amount and an optional
trailing-day window. Only unique verified Catch identities qualify; totals use
current completed payments, exclude refunds and failed sign-ups, and check
canonical event ownership. Exact evaluation stops at 1,000 events and 5,000
payments. Different currencies are never added or converted.
A static list instead uses one `staticMembers` predicate with up to 2,500
explicit contact ids and `join: all`. It cannot mix automatic conditions.
`resolveOrganizerAudienceMembers` resolves selected labels in bounded batches
for the manager-only editor. Merges follow the surviving contact; hidden or
deleted records are excluded during evaluation and must be removed on save.
Selecting a person never grants communication permission.
Form-answer predicates carry form, version, question and a validated value;
only non-sensitive questions marked `filterable` can be selected. Current
submitted responses join People through deterministic source origins; merges
follow `currentContactId`, and withdrawals exclude the evidence. Attendance
requires a checked-in, non-cancelled edge for that organizer and event.
Arbitrary collection
paths and raw Firestore queries are forbidden. The server canonicalizes and
hashes definitions, validates organizer-owned tags, and applies optimistic
revisions. Preview returns exact coverage or an explicit incomplete/over-limit
failure; the bounded evaluator refuses organizers above 2,500 active contacts
instead of truncating. Preview pages bind their cursor to the organizer,
audience revision and full ordered membership; changed membership fails closed.
Source reads stop at 5,000; authoring catalogs stop at 200 records per category
and 100 filterable versioned questions, with explicit over-limit errors.
Event-scoped Booked/Prospective audiences remain event
authority and
are referenced directly by event-announcement sends rather than copied into a
CRM audience. Campaign approval freezes resolved recipient ids and revisions;
the selected saved audience id, revision, and definition hash remain on the
campaign. A changed or archived definition blocks draft preview/approval but
does not rewrite an already approved send. Campaign preview also persists an
exact audience-state hash; approval requires the current resolution to match it
before freezing recipients, so a count-preserving membership change cannot
silently pass.

`organizerManualSendTasks/{taskId}` is the server-only durable external-handoff
queue. One task represents one organizer, contact, originating send, intent,
route, permission/capability snapshot, idempotency key, endpoint snapshot/hash,
bounded prefill content with TTL, and progress state. Its only progress states
are `queued`, `handoffOpened`, `hostMarkedSent`, `skipped`, `cancelled`,
`superseded`, and `expired`; it has no delivered/read state. Opening an external
application records only `handoffOpened`. The prepare callable persists or
returns the idempotent queued task only after current manager, contact, endpoint,
permission, and route checks; the client performs the external launch and then
acknowledges the accepted launch against the current revision. An exact prepare
retry revalidates the existing task rather than bypassing those checks. Tasks
opened again from the durable queue first pass a revision-bound, read-only
callable that rechecks the current contact, endpoint, permission, suppression,
and route and returns the already-bounded task payload. The open acknowledgement
repeats those checks after device acceptance; neither check mutates or sends.
Existing tasks never auto-dispatch after a capability change. An explicit host
re-plan rechecks
current authority and returns advice only; it does not write, supersede, remove,
complete, or dispatch any task. A separate explicit host action is required to
close manual work. Active queue reads apply the server-time expiry bound in the
indexed query rather than waiting for asynchronous TTL deletion to hide stale
work.

`organizerContactActivity` is a callable-composed bounded cursor projection,
not a client-readable master collection. It joins sanitized origin, form or
application, attendance, note, permission, send/reply and merge facts for one
active organizer contact. Each row has a typed kind, stable source id,
occurred-at time, safe display payload, and coverage metadata. It never copies
private Consumer profile, compatibility, safety, wingman, raw provider receipt,
or unrelated organizer content.

Contact detail also reads the bounded newest campaign-recipient window from
`organizerCampaignRecipients` and joins safe campaign labels and delivery
state. `sendEventBroadcast` also writes one organizer-scoped
`organizerBroadcastSummaries/{broadcastId}` projection after it finalizes the
server-only operational receipt. Contact detail joins only summaries whose
bounded `recipientContactIds` contains the contact and returns the sanitized
Announcement label, audience, time and available/failed delivery state. It
never exposes message bodies, raw receipt evidence or cross-organizer history.
Campaign approval freezes a server-owned recipient snapshot and
dispatch rechecks current permission, contact suppression, sender/template
health and event state before each attempt. Meta provider tokens live in Secret
Manager. Every environment pre-provisions one
`ORGANIZER_WHATSAPP_ACCESS_TOKENS` vault; each organizer connection is stored
as a distinct immutable secret version containing its organizer and connection
binding, and retired versions are disabled. The Functions runtime receives
secret-level accessor and version-manager roles on that vault only; it may not
create secrets or access unrelated application secrets. Existing raw-token
versions remain readable only for migration compatibility. Meta integration is
reported configured only when `META_WHATSAPP_ENABLED=true` and the real Meta
app/config credentials are present. Webhook receipts are signature-verified,
deduplicated and monotonic;
STOP updates the same organizer-scoped preference/suppression boundary without
creating analytics content. For one unambiguously resolved organizer contact,
the bounded inbound body is also copied into
`organizerWhatsappMessages/{messageId}` and summarized by
`organizerWhatsappThreads/{threadId}`. Both are server-only and carry a rolling
12-month `expiresAt`; the queue copy expires after 30 days. Manager callables
list and open these threads in the existing Inbox scopes. Free-form replies
require the current sender connection, unsuppressed contact state, an unchanged
latest-inbound timestamp, and an open 24-hour customer-service window; the
server rechecks all of those conditions even when the client composer appears
enabled. `organizerWhatsappReplyOperations` reserves each idempotency key before
the provider call, preventing concurrent duplicate sends and preserving an
unknown-outcome state when Meta acceptance cannot be confirmed. Account
deletion removes the onboarding draft, organizer communication grants, UID
identity evidence and verified UID claims. Retained operational attendee,
contact and event-edge history is unlinked from the deleted Catch UID.
Retained organizer roster history is unlinked by setting `linkedUid` and
`linkedAt` to null; any separately retained operational contact field remains
subject to the organizer's stated booking/records purpose rather than Catch
account or marketing permission.

### Person Data Lenses And Canonical Fields

Catch does not have one client-readable master person document. A verified
Firebase Auth identity, the participant's private profile, the dating feed
projection, portable application intake, organizer-submitted answers, and an
organizer's CRM history are separate authority and visibility lenses. A phone
match is an identity-resolution input only; it never grants an organizer access
to private-profile fields or another organizer's records.

| Lens | Canonical storage | Authority and visibility |
|---|---|---|
| Verified account identity | Firebase Auth plus the verified `users/{uid}.phoneNumber` mirror | Firebase Auth is authoritative for phone ownership. The private mirror is not a Host projection. |
| Private Catch/dating profile | `users/{uid}` | Participant-authored source used to build Catch experiences. Its presence does not authorize Host access. |
| Public dating projection | `publicProfiles/{uid}` | Server-derived, redacted feed shape only. A person-field mapping describes where a published value would land; it is not publication consent. |
| Portable application prefill | `participantIntakeProfiles/{uid}` | Participant-private, reviewed values for lower-friction future applications. It neither overwrites `users` nor becomes organizer-visible merely by existing. |
| Organizer application snapshot | `organizerApplicationResponses/{responseId}` plus `participantOrganizerDataGrants/{grantId}` | Exact questions answered for one application and the exact question/field grant receipt. This is the only application-field slice available to that organizer. |
| Organizer CRM/customer history | `organizerContacts` and its organizer-scoped event, note, trait, campaign, and commerce projections | Facts the organizer acquired through its own events and workflows. It must not be hydrated from private `users` fields merely because an identity link exists. |
| Platform reconciliation | Server-side joins across the preceding stores | Catch may resolve the same authenticated person across organizers, but employee-facing reads must remain purpose-scoped, role-gated, masked where possible, and audited. There is no universal raw-PII client projection. |

`contracts/catalogs/person_fields.json` is the single semantic registry for
portable person fields. It owns stable ids, normalized provider-header aliases,
native question kinds, import transforms, privacy classes, prefill review
requirements, Host presentation intent, authority, and structural private/public
profile mappings. The validator requires the organizer-application enum and
real profile paths to match the catalog. Generated Dart, Functions, and tool
registries consume it so Google Forms, Typeform, Fillout, CSV/XLSX, and future
native forms cannot maintain divergent alias maps.

The catalog is classification metadata, not permission. Its organizer policy
is `submittedQuestionGrantOnly`: a Host sees a field only when that organizer's
form asked the question and the response/grant records it. Its public-profile
mapping is also structural metadata only. Choice-shaped fields imported from a
table remain text until the source options are explicitly mapped, preventing a
provider export from silently inventing Catch choice semantics.

Age is derived from date of birth rather than a second mutable profile value.
Phone authority belongs to Firebase Auth even though `users.phoneNumber` keeps
a verified mirror. Provider-specific questions remain organizer-custom answers;
they are not added to this catalog merely because one provider or organizer
uses them.

Historical rows created before this boundary can be assessed with
`node tool/data/audit_legacy_host_contact_projection.mjs --env <environment>`.
The command is permanently read-only, omits raw phone/email values, and splits
exact unprovenanced private-profile matches from rows needing human
reconciliation. It also counts affected CRM edges and contacts. Any repair must
be a separate approval-gated operation because stale identity evidence and
organizer-supplied contact history must be reconciled together; age or source
labels alone are never deletion proof.

After an explicit repair approval, the only supported mutation path is
`node tool/data/repair_legacy_host_contact_projection.mjs`. It requires one
organizer, exact expected high-confidence and reconciliation counts, and both
production confirmation flags. Each row is reclassified transactionally before
phone/email are set to null. The current deployed attendee trigger must then
rebuild the event edge, contact, traits, identity evidence and audience summary;
the repair verifies that postcondition and removes only orphaned phone claims.
It never deletes an attendee, event, organizer contact, or organizer-supplied
contact fact, and never prints raw contact values.

### Generic Organizer Forms

`organizerForms/{formId}` owns generic Host form identity, target, lifecycle,
response counters, stable opaque `publicFormId`, and pointers to editable and
published content. `organizerFormDrafts/{formId}` owns the mutable definition
under an optimistic revision. Publishing copies that definition into immutable
`organizerFormVersions/{formId_vN}` and records `sourceDraftRevision`; an exact
retry reuses the active version instead of incrementing publication history.

`organizerFormResponseDrafts/{draftId}` stores a version-bound, expiring
respondent session with optimistic answer revisions. A submitted session
becomes one immutable `organizerFormResponses/{responseId}` snapshot containing
the published question identities, validated answers, submission consent, and
source-link attribution. An exact submit retry replays the same response;
withdrawal stamps that response instead of deleting the audit record.
`organizerFormShareLinks/{linkId}` owns organizer-created source tokens and
bounded attribution counters. A source token changes measurement only; it
never grants form-management, response, or Firestore authority.

All six collections are server-only. Organizer managers create, update,
validate, publish, pause, resume, archive, duplicate, delete eligible drafts,
and list bounded projections through App-Check-protected callables. Form lists
use the `organizerId + updatedAt desc + __name__ desc` index and opaque cursors;
archived forms are excluded by default. A `publicFormId` is a routing token,
not permission to read Firestore. The public `/f/:publicFormId/` route uses
callables for a safe active-version projection, anonymous or verified identity
bootstrap, autosave, submit, and withdrawal. Public reads never return draft
content, organizer-only metadata, other respondents, or response counters.

`contracts/catalogs/organizer_form_templates.json` is versioned source data.
Creating from a template copies it into organizer-owned draft state with new
section, question, and option identities, so catalog changes never mutate an
existing form. Duplicating a form remaps all nested identities and logic
references. The shared semantic validator permits invalid work-in-progress
drafts but blocks publication on identity collisions, invalid field/validation
combinations, stale logic references, backward section routes, target errors,
and purpose-specific requirements.

Generic Forms is the source for application, registration, intake, waiver,
feedback, and survey definitions. The existing application collections below
remain the application-review projection and import compatibility boundary;
they are not the generic response store.

### Organizer Application Intake

Organizer applications are a provider-neutral intake domain. A Google Form,
Typeform, Fillout form, spreadsheet, or future native Catch form is a source
edge; none of those providers owns the application model. The immutable
`organizerApplicationFormVersions/{versionId}` snapshot defines ordered
questions, canonical field mappings, participant-prefill eligibility, consent
copy, and retention copy. `organizerApplicationForms/{formId}` owns only the
mutable draft/published pointer and target kind. Publishing creates a new
version rather than changing the meaning of answers already collected.

`organizerApplications/{applicationId}` is the organizer-scoped workflow row:
source provenance, event/campaign target, applicant display projection, status,
review revision, and private reviewer note. The corresponding immutable
`organizerApplicationResponses/{responseId}` preserves the exact answer
snapshot and per-question consent evidence. Canonical contact fields and
organizer-only custom answers remain distinct even when they arrived in the
same spreadsheet row. An application is not the Consumer launch-access
`accessApplications/{uid}` document, a CRM contact, an event booking, or a
public dating profile. The manager accept operation now atomically approves
and creates or links an organizer contact through the shared contact writer.
It resolves a unique active contact by provenance or exact endpoint/linked-UID
candidates; conflicts require duplicate review. An exact retry reuses the
completed result. The contact remains unverified unless already verified and
receives no event booking or marketing permission. Source origins retain the
application-response kind for legacy imports and the generic form-response
kind for generic forms, so contact merges preserve the current People link.

Portable participant prefill belongs in private
`participantIntakeProfiles/{uid}` only after an authenticated participant has
explicitly saved eligible fields. Private-profile and verified-Auth suggestions
may be shown to that participant, but every current form question must be
reviewed again before every submission. Authentication proves ownership of the
private suggestions; it grants the organizer nothing. Portable intake is
separate from `users/{uid}` and cannot overwrite an existing Consumer profile.
An organizer receives only the exact
fields and purpose recorded by
`participantOrganizerDataGrants/{grantId}` for that application/response; a
global phone or email
identity never implies cross-organizer visibility. Organizer-proprietary
questions such as a preferred cocktail remain in that organizer's application
response and are never promoted into the portable profile by default.
The native submission callable creates the response and grant atomically.
Revocation stamps only `revokedAt`, withdraws the review row, and immediately
makes manager list/detail projections mask the participant name and return no
answers or outreach actions; the immutable platform audit snapshot is retained.
Generic Host Form applications are deterministic projections of their exact
submitted `organizerFormResponses` and immutable `organizerFormVersions`.
They use that submission authority and do not fabricate a legacy grant; a
withdrawn, foreign or mismatched source is redacted and cannot be accepted.
Imported/connector data remains organizer-acquired and is labeled separately
instead of receiving a fictional participant grant. Field visibility is not
messaging permission: WhatsApp/SMS opt-in remains
exclusively in `organizerCommunicationPreferences`, and an application grant
cannot create or broaden it.

Customer Details can pass `contactId` to `listOrganizerApplications`. The
callable validates the contact's organizer and availability, then selects
explicit application/contact links plus account links only when the customer
identity is verified. It never matches names or raw phone/email values. The
customer scope is included in its pagination cursor. Listing an application
does not bypass its existing grant checks: the customer page reads the same
permission-filtered detail projection and presents answers as a dated
submission, without copying them into editable CRM fields. Approval still
changes review state only; it does not implicitly create a customer.

The provider-neutral import runtime accepts locally decoded CSV/XLSX tables, requires an
explicit mapping for every source column, imports at most 200 rows atomically,
and records a hash-bound idempotent receipt in
`organizerApplicationImportReceipts/{receiptId}`. Known identity/profile
headers map to canonical fields; all other columns remain organizer-only
questions. Hosts list, search, sort, inspect, and review only through manager
callables. Direct client access to forms, versions, applications, responses,
assets, source mappings, receipts, private intake profiles, and grants is
denied. Authenticated native form load/submission/revocation now use these same
contracts: suggestions are private and review-required, response snapshots are
server-built from the published question version, and grant-aware Host reads
enforce exact question/canonical-field ids. Provider connectors remain source
adapters over the same model, not provider-specific schemas.

The executable policies in `contracts/catalogs/person_fields.json` also bind
the role projections:

| Consumer | Allowed projection |
|---|---|
| Organizer manager | Exact active application grant, organizer-acquired CRM facts and notes, and event-scoped completed/non-refunded revenue aggregates. No payment instrument, billing address, provider secret, private dating/profile, feedback, safety or cross-organizer data. |
| Delegated event staff | One event's display name, ticket/registration state and attendance controls under an expiring grant. No CRM, application answers, campaigns, provider setup, commerce enrichment or contact endpoints. |
| Support | Masked, purpose-specific operational projections only. Raw PII is not the default support view. |
| Safety / Finance / Admin | Only the role- and workflow-specific projection required for the case; every action remains audited. Raw PII is break-glass only, never a universal employee client projection. |
| Catch backend | May reconcile the consolidated identity across private stores to enforce product, fraud, safety, finance and deletion duties, but must return only the projection authorized for the caller and purpose. |

### Provider Sync, Staff, And Offline Attendance

`organizerProviderConnections` contains safe organizer/provider identifiers,
capability coverage, state, freshness and a secret reference, never an API key.
`externalEventMappings` pins one Catch event to one external event and records
which fields the provider can authoritatively supply. `providerSyncRuns` owns
cursor, counts, state and sanitized errors. The implemented Luma poller imports
registration and provider check-in facts through the canonical attendee
reconciler. It does not invent orders, refunds, revenue, referral coverage or
webhook freshness that Luma has not supplied.

`eventStaffGrants/{eventId_uid}` grants a bounded subset of `viewRoster`,
`setAttendance`, `reviewRuntimeClaims` and `publishLiveLocation` for one event.
It records organizer,
grantor, role, issue/expiry/revocation and revision; grants expire within 14
days and are capped at 50 active rows per event. Firestore direct access is
denied. Staff operate through callables and the restricted Host operator route,
which never grants CRM, campaign, import, provider, event-edit or organizer-wide
authority. Organizer managers continue to work without a grant.

The same staff document optionally carries `groupDuties`: a lead, pacer or
sweep duty for each saved group, with its own expiry and reviewed source hash.
`operatorExpiresAt` independently limits the event-wide permissions. Legacy
check-in grants without this field use their original expiry; explicit null
means no event-wide access. The top-level expiry is the latest duty/base expiry
for staff discovery and the existing 50-active-staff cap. Extending a group duty
cannot extend or restore expired check-in access, and revoking the staff row
revokes every duty. Group-only staff have no event-wide permissions.

`getEventAssistanceGroupStaff` and `setEventAssistanceGroupStaff` are manager-only
callables. They authorize before resolving a phone to an existing Auth account,
then re-read manager authority in the transaction. Changes require the reviewed
UID, source hash and staff revision. `eventAssistanceStaffReceipts` makes exact
retries return the original operation revision and latest state. Duties are
limited to 20 groups per person, at most 14 days and the event's staff window.
Event creation generation and saved group configuration bind authority; ordinary
attendance/progress updates do not revoke it. Managers can remove obsolete
group duties. Direct staff/receipt reads and writes remain denied. These grants
authorize scoped progress and membership reads, lead/pacer departures and
acknowledged transfers. Checkpoint/accountability commands and staff UI remain
integration work.

The Host attendance outbox is local client state, not Firestore authority. It
contains no names, phones or emails: only account/event/attendee ids, absolute
desired attendance, expected revision, client operation id, timestamps and
retry/conflict state. Server authority remains `setEventAttendeeAttendance`
plus its 30-day receipt. Local operations review after seven days, expire after
30, cap at 200 and never turn a revision conflict into a silent toggle replay.

Cross Paths visibility is a two-part, private consent contract. The optional
`users/{uid}.prefsShowInCrossPaths` master preference resolves to false when
missing and is never projected into `publicProfiles`. The deterministic
`eventCrossPathsConsents/{eventId_uid}` edge records the per-event choice,
terms version, source, and consent/revocation timestamps. A caller may read only
their own edge; direct writes are denied. The App-Check-protected
`setCrossPathsEventConsent` callable is the sole writer and allows enablement
only when the private global preference is explicitly true, the event is active
and upcoming, and the caller owns a current `signedUp` participation. Disable
remains available after those preconditions disappear. Effective visibility is
the conjunction of both consent values plus later server-owned eligibility;
neither consent document alone authorizes an Explore identity. The optional
`events/{eventId}.crossPathsDiscoveryEnabled` field is a third, Admin-owned
pilot gate that defaults to false when absent. Enabling it is restricted to an
active upcoming Mumbai event (`discoveryMarketId: in-mh-mumbai`), a minimum
six-hour lead, and at most three selected upcoming events. An event may use its
canonical, bounded, organizer-controlled companion inventory policy; all hold,
capacity, payment, and release invariants remain server-owned. Disabling the
selected-event gate remains available and invalidates pending invitations
without silently closing an accepted event plan.

Cross Paths showcase eligibility is independently owned by the audited
`adminSetCrossPathsShowcaseEligibility` callable. The record contains only
`eligible`, `needsReview`, or `paused`, coarse reason codes, rule/review
versions, a SHA-256 public-profile fingerprint, the neutral human-review
checklist, reviewer identity/note, and timestamps. It never contains a numeric
attractiveness or desirability score. `adminListCrossPathsShowcaseCandidates`
projects bounded public-profile evidence plus effective status to authorized
reviewers; support is read-only. Approval requires objective readiness and the
complete checklist. Profile or rule changes invalidate approval at read time.
Firestore rules deny every client read/write, and account deletion removes the
record.

Pre-event Cross Paths suggestions are owned by the App-Check-protected
`getCrossPathsSuggestions` callable. Its typed request contains only a bounded
set of current Explore event ids and an opaque session id. The server rechecks
event availability, schedule conflicts, confirmed candidate participation,
both consent gates, reciprocal preferences, showcase readiness, safety state,
active matches, synthetic scope, and exposure fatigue. It returns at most two
sanitized person/event projections plus a short-lived signed token; roster
documents and private preference values never cross the callable boundary.
`crossPathsSuggestionExposures/{exposureId}` is a deterministic server-only
receipt used for seven-day fatigue and repeated-session stability. Firestore
rules deny every client read/write, the document carries a 30-day expiry for
the environment-owned Firestore TTL policy, and account deletion removes
receipts where the member was viewer or candidate.

Cross Paths invitations are deterministic event-and-sender documents. Only the
two participant ids may read an invitation; every create or transition is
owned by `sendCrossPathsInvitation`, `respondCrossPathsInvitation`,
`cancelCrossPathsInvitationOrPlan`, or a lifecycle trigger. A signed suggestion
token is not authority by itself: send and accept revalidate the recipient's
confirmed participation and either the sender's confirmed participation or
explicit companion-inventory admission, plus the applicable consent,
reciprocal eligibility, current showcase approval, blocks/reports/moderation,
event availability, and one-invitation/one-plan cardinality rules. Invitation state is `pending`,
`accepted`, `declined`, `cancelled`, `expired`, or `invalidated`; timestamps and
invalidation reasons are server-owned.

When an organizer enables reserved companion inventory, an accepted invitation
from an otherwise admissible unbooked sender may reference one
`crossPathsPairHolds/{holdId}` document. The server-owned hold records the
event, invitation, both participants, independent booking states, frozen price
quotes, expiry, release reason, optional payment, and optional event-plan
conversation. Only the two participants may get it; list and all client writes
are denied. `active` means reserved, not booked. Free or paid booking authority
atomically converts it to `confirmed`, creates the requester participation and
event plan, and moves the event projection from `crossPathsPairHeldCount` to
`crossPathsPairConfirmedCount`. Expiry, cancellation, event/participation or
safety invalidation, payment failure, and account deletion release exactly
once. Reserved companion capacity remains within total event capacity but
outside general admission and never changes waitlist rank.

Acceptance creates one deterministic `matches` document whose
`conversationType` is `crossPathsEventPlan`, whose participants are the invite
pair, and whose event id and invitation id remain explicit. It is not a dating
match and cannot drive match celebrations or Event Success signals. Rules allow
participants to read the plan and create messages only while it is active,
unblocked, and before `expiresAt` (event end plus 24 hours). Cancellation,
participation loss, event cancellation, or a block closes the plan; revoking
discovery consent invalidates pending invitations but does not silently cancel
an already accepted plan. Invitation delivery uses the separate optional
`prefsCrossPathsInvitations` preference, which defaults to false when missing.

Each device push token lives at
`users/{uid}/pushInstallations/{installationId}` with `token`, `appRole`,
`environment`, `platform`, optional app version/build, `locale`, `timeZone`, and
`updatedAt`. The client owns this device metadata and rules restrict writes to
the authenticated user plus the known role/environment/platform vocabulary.
Consumer clients attempt the legacy `fcmToken` and installation document as
independent compatibility writes, so an older deployed rule set cannot prevent
the other representation from being refreshed. Each failure is still logged
with its own non-PII resource context.
Notification producers select reviewed templates by stable message id and use
the installation locale when the delivery path supports per-installation
fan-out. English remains the bundled server fallback; notification prose must
not be stored as an unversioned remote document.

## Organizer Follower Posts

Organizer follower posts live under
`organizers/{organizerId}/posts/{postId}` and are created only by the
`createOrganizerPost` callable. Clients may read authenticated posts, but
direct writes are denied. The callable verifies organizer-manager authority,
validates optional linked events against the same organizer, enforces the
rolling three-posts-per-seven-days quota, writes the canonical post, and fans
out durable `organizerUpdate` activity notifications to active followers.
`createClubPost` and the nested club post are compatibility shadows.
Manager Sends history reads the same organizer-scoped collection through
`listOrganizerCampaigns` and returns post identity, audience, status, optional
linked event and timestamps without returning the message body.

## Event Broadcast Receipts

Host event broadcasts use the operational receipt
`eventBroadcasts/{broadcastId}`. Only `sendEventBroadcast` creates or advances
the receipt; account-deletion cleanup may delete a host-authored receipt or
remove one recipient's identifiers and delivery evidence. Direct client reads
and writes are denied. The Host client receives only the sanitized callable
response counts.

Finalization also upserts the durable, organizer-scoped
`organizerBroadcastSummaries/{broadcastId}` history projection. It contains the
event/activity label, audience, recipient count, send timestamp, partial-failure
flag and bounded contact delivery states, but no message body, UID, endpoint or
raw provider receipt. Direct client reads and writes are denied.
`listOrganizerCampaigns` is the manager-authorized, rate-limited pagination
boundary for the Host Sends workspace: it merges campaign summaries, these
Announcement summaries and organizer follower updates in reverse chronological
order using an opaque stable cursor. The queries are organizer-scoped and never
use a collection-group scan.

The callable verifies current event-host authority and freezes a server-resolved
audience from `eventParticipations`. Booked means `signedUp` plus `attended`;
prospective means `waitlisted`. Inquiry threads are never an audience source,
and the broadcast never creates a match, conversation, or chat message.

Each eligible recipient gets a deterministic `eventUpdated` Activity item.
Push is preference-gated and attempted at most once: durable Activity creation
is the retry boundary, so an uncertain retry reports an unknown push outcome
instead of sending a duplicate. The receipt stores hashed per-recipient
evidence for repair and aggregate delivery counts, remains server-only, and
requires the `eventBroadcasts.expiresAt` Firestore TTL policy for 90-day
retention.

## Host Analytics Snapshots

The host-facing `getHostAnalytics` callable may reuse a server-owned response
from `hostAnalyticsSnapshots/{uid}_{scopeHash}` for at most 15 minutes. The
scope hash includes the authenticated uid through the document id plus the
current authorized club ids, resolved absolute range, derived granularity,
preset, optional event id, and IANA timezone. Authorization is resolved before
the cache lookup, so host-role changes produce a different cache identity.

Clients cannot read or write snapshots. The callable validates a cached
response against `host_analytics_response.schema.json` before serving it,
falls back to a live BigQuery build on missing/expired/invalid cache data, and
keeps the existing rate limit in front of both paths. `expiresAt` has a
Firestore TTL policy; account deletion also removes snapshots owned by the
deleted uid.

## Durable Operations Records

`contracts/operations/` owns the portable JSON schemas for resumable business
workflows. These contracts are deliberately separate from public product
documents: an operations work item is review state and evidence, not an event,
organizer, or authorization to publish one.

The canonical record family is run, work item, action receipt, decision, lease,
publication plan, rule proposal, and rule evaluation. `functions/src/operations/`
owns semantic validation, optimistic revisions, reducers, and Firestore
repositories. All corresponding Firestore collections are server-only.

The reusable work-item contract accepts workflow-owned stage, entity, and
outcome tokens. Supply Intake's workflow manifest, runtime validator, backend
policy, and callable response then narrow that vocabulary to one exclusive
`primaryStage` from `incoming`, `verify`, `resolve`, or `ready`. Dedupe, source
verification, policy review, and human review are overlapping flags or
blockers. `published`, `rejected`, `expired`, `cancelled`, and `taken_down` are
lifecycle outcomes and must never be encoded as extra Supply Intake stages.
Workflow manifests also bind lifecycle semantics: non-empty active statuses
plus disjoint published and expired status groups. The generic local runtime
uses those frozen groups for queues, canonical lifecycle projection, counters,
and reconciliation cleanup; it does not require another workflow to reuse
Supply Intake's literal status names.

The local `operations/` runner validates its admin projection against the same
run and work-item schemas with full draft-07/Ajv conditional semantics before
exporting it. Functions repositories and the importer use generated validators
from those same bundled schemas, so a record rejected by the contract cannot be
accepted by a hand-written semantic subset. Human owner/blocker signals require
the canonical queryable task flag, and published or terminal records cannot
remain in the active human-review lane. The live admin surface reads
those durable records through `adminListIntakeOperations`; it cannot enqueue a
run or mutate workflow state.

Organizer discovery candidates are normalized into the bounded
`normalizedPayload.intake` projection on organizer work items. The payload
contains only the reviewed candidate fields required by the Admin queue; it is
not a canonical `organizers/{id}` document and grants no publication,
ownership, crawl, or app-visibility authority. Organizer-only shadow runs may
omit an Event Intake bridge, but remain subject to the same immutable export,
contract validation, and trusted importer.

An explicitly unattributed external event is represented only as
`normalizedPayload.intake.recordType=orphan_event_candidate`. The work-item
contract requires `entityKind=event`, the
`organizer_not_in_inventory` blocker, a null matched organizer, and
`publicationEligibility=blocked_orphan`; it rejects a published lifecycle for
that record. The event's evidence also projects a regular organizer discovery
candidate rather than creating a second organizer schema. Deterministic
auto-attribution records the reused source-mention scorecard rationale and is
the only path that clears the orphan blocker.

Organizer review decisions store approval and surface exposure independently.
`organizerIntakeReviewDecisions/{entityId}` requires `publishStatus`,
`indexStatus`, and `appVisibility`; `approve_public` may keep all surfaces off
or enable a reviewed subset. `indexed` requires `published`, `hold` is
`draft` + `noindex` + `hidden`, and `suppress` is `suppressed` + `noindex` +
`hidden`. Web exposure additionally requires claim-target, takedown, and
impersonation review; app discovery also requires operating-status,
event-accuracy, and unclaimed-affordance review. The shared Functions policy
derives effective event visibility as the minimum of the event request and
organizer ceiling on every surface and refuses a request above that ceiling.
Before this contract shipped, the guarded visibility-decision backfill repaired
the two production legacy approvals (`afterfly` and `bhag`) to their exact prior
`published` + `indexed` semantics; the post-apply dry run reported two current
documents and zero remaining repairs.

Supply Intake `0.1.1` records exact field provenance for the candidate title,
canonical URL, snippet, market, reviewed formats, review note, and review
timestamp. Each entry binds the projected field to an evidence artifact,
content hash, locator, extraction method, extractor version, and confidence.
This is deterministic extraction metadata; it grants no truth, ownership, or
publication authority.

`adminCreateOrganizerDraftFromCandidate` is the only candidate-to-entity
scaffolder. It validates the exact work item and reviewed evidence, rejects
existing-entity matches and duplicate identity receipts, allocates an opaque
Firestore organizer id, and separately reserves the reviewed public slug. It
creates an unclaimed `organizers/{id}` draft with `appVisibility=hidden`,
`publishStatus=draft`, and `indexStatus=noindex`. It also writes the legacy
`clubs/{id}` compatibility shadow, reserves the canonical route, and records a
deterministic `organizerIntakeCurationDecisions/{id}` receipt. The receipt
contains the source work-item, candidate, normalized identity key, public slug,
and target-field provenance and is returned by `adminListIntakeOperations` as
a bounded draft link. Intake review notes remain audited operator context; they
are never copied into member-facing description or source summary. Unknown
description, locality, and public listing descriptor values remain empty until
an operator supplies verified content. No crawl enablement or owner binding is
part of this contract.

The canonical organizer draft also carries a bounded, server-only
`intakeLearningSource` snapshot for fields actually seeded from the reviewed
work item. It contains the source profile, work-item and candidate ids,
field-level extracted values, and artifact lineage; it never contains a raw
provider payload. The legacy `clubs/{id}` compatibility shadow deliberately
does not receive this learning metadata.

When an audited organizer update first changes a value that still equals its
source-seeded value, Functions writes one immutable
`organizerIntakeFieldCorrections/{correctionId}` record in the same transaction.
The record binds source, field, extracted value, corrected value, operator
context, artifact lineage, and a deterministic `fixtureId`. Subsequent
editorial changes do not masquerade as extraction corrections because the
stored value no longer equals the original extraction. These records are
server-only learning evidence; they do not publish content or activate rules.

The trusted shadow-projection importer validates the export again, resets only
the Firestore persistence revision to zero, and retains each local source
revision plus the whole-export hash under reserved projection metadata. It
creates work items before exposing the run, verifies every expected item on
replay, repairs missing items, rejects changed records, and refuses inventory
above the run's frozen `maxWorkItems` budget. Apply also binds the environment
label to its configured Firebase project id and requires project-aware
production confirmation. This bridge writes no `events`, `externalEvents`,
`clubs`, public website projection, or publication-plan record.

Local completed runs hash-bind their full work-item inventory. Reconciliation
creates a new lineage-bound run and new work-item ids rather than mutating the
source snapshot, preserving immutable importer semantics across expiry and
staleness sweeps.

`adminActionExecutions/{executionId}` is the separate remote monitor record for
one admin CLI invocation. It stores action/callable identity, actor roles,
target label, request/response hashes, timestamps, and a bounded terminal
error—not the request or response body. A role-gated callable creates the
`started` receipt before the business callable runs and advances it to exactly
one immutable `succeeded`, `failed`, or transport-ambiguous `indeterminate`
outcome. Browser clients can inspect the bounded projection only through
`adminListActionExecutions`; direct Firestore reads and writes remain denied.

Runs must budget between 1 and 10,000 work items. Imported run metadata carries
authoritative total, active, terminal, stage, and human-review aggregates; the
admin read fails closed unless those totals reconcile. The canonical human
review filter is backed by the committed `operationWorkItems` composite index.

## Organizer Claim Documents

Public organizer claims use a dedicated review collection instead of overloading
host locks:

| Collection / field | Owner | Notes |
|---|---|---|
| `organizerClaimRequests/{requestId}` | `requestOrganizerClaim`, `adminDecideOrganizerClaim` | Server-owned claim queue. Clients create and decide only through callables; direct Firestore reads/writes are denied. |
| `organizers/{organizerId}.claim` | organizer claim callables and admin index-review callables | Public-page claim state, latest request id, review audit, and owner-facing status. |
| `organizers/{organizerId}.ownership` | organizer claim/create/update callables | `programmatic` before ownership, `claimed` after approval. |
| `organizers/{organizerId}.publicPage.indexReview` | admin organizer indexing | Audit evidence for source quality, media rights, cadence, and owner/contact verification before a page becomes indexable. |
| `reviews/{reviewId}.ownerResponse` | `setReviewResponse` | Server-owned owner response rendered by app and website review surfaces. |

`organizerTeamMemberships` owns active owner and manager seats. Legacy
`clubHostClaims` remains only long enough to support released club callables;
it is not organizer claim authority.

## Event Policy Applicability

`contracts/shared/event_common.schema.json` owns the versioned event-policy
bundle invariant. Bundle version 2 couples pricing and cancellation semantics:

- `pricing.basePriceInPaise == 0` requires
  `cancellation.policyId == notApplicable`;
- a positive base price requires `flexible`, `standard`, or `strict`;
- external-companion events remain price-zero inside Catch because the external
  booking authority owns payments, refunds, and attendee cancellations.

Backend event create/update normalization derives this relationship rather than
trusting a client-supplied cancellation value. Version 1 remains readable for
legacy event documents.

## Event Discovery Projection

Explore queries `events` directly through callable-owned projection fields
instead of resolving a city to clubs first. The projection currently covers
city, activity kind, coarse geo-cell, availability bucket, gate flags, and age
range:

- `discoveryCityName`, `discoveryActivityKind`, `discoveryGeoCell`;
- `discoveryHasOpenSpots`, `discoveryAvailability`;
- `discoveryOpenCohorts`, `discoveryWaitlistCohorts`;
- `discoveryInviteRequired`, `discoveryMembershipRequired`,
  `discoveryManualApprovalRequired`;
- `discoveryMinAge`, `discoveryMaxAge`.

`functions/src/events/eventDiscoveryProjection.ts` owns the write-time
projection. Event create/update/cancel, paid signup, and signup cancellation
must refresh these fields whenever event capacity, policy, status, activity, or
location inputs change. `discoveryOpenCohorts` gives Firestore a coarse
viewer-cohort open-slot filter for the standard event-policy cohorts; gated
events still require viewer-specific post-query resolution for invite,
membership, and manual-approval state. `firestore.indexes.json` owns the
supporting composite indexes for city, time, activity, geo-cell, coarse
availability, and open-cohort filters.

Existing remote event docs created before this projection must be repaired with
`node tool/data/backfill_event_discovery_fields.mjs` before a release depends on
the direct event index. The repair is dry-run by default and requires
`--allow-prod` when applying against prod.

Admin organizer search uses a separate server-owned
`organizers/{organizerId}.adminSearch` projection for the admin Organizers
canonical directory. It is not consumed by the app or website.
`adminListOrganizerDetails`
accepts either a single `citySlug` or a bounded `citySlugs` array for
admin-only launch-city work queues such as Indore + Mumbai. Existing organizer
docs can be repaired with `node tool/data/backfill_organizer_admin_search.mjs`; the
repair is dry-run by default and requires `--allow-prod` when applying against
prod.

Admin event search uses a separate server-owned
`events/{eventId}.adminSearch` projection for the admin Events canonical
directory. It is not consumed by the app. `adminListEventDetails` accepts either
a single `citySlug` or a bounded `citySlugs` array for admin-only launch-city
work queues such as Indore + Mumbai. Existing event docs can be repaired with
`node tool/data/backfill_event_admin_search.mjs`; the repair is dry-run by
default and requires `--allow-prod` when applying against prod.

External event supply uses `externalEvents/{eventId}`. These records are
sourced from reviewed organizer-intake candidates, preserve source/dedupe
attribution, carry a fail-closed organizer capability snapshot, and keep Catch
booking, payments, reservations, waitlists, and host contact disabled.
`adminListExternalEventDetails` lists that collection for admin event-supply
review with the same bounded launch-city and time-window filters.

`adminPublishExternalEvent` is the only publication writer. It requires a
dry-run or apply execution mode, an idempotency key, exact launch-market
identity, the organizer visibility ceiling, accepted per-blocker decisions,
and the reviewed candidate snapshot. Dry-run and apply append immutable
`externalEventPublicationReceipts/{receiptId}` records; a replay with the same
key returns the same result and changed input is rejected. The callable writes
one outbound-only `externalEvents/{id}` record and never creates a canonical
Catch-hosted `events/{id}` record.

The governed blockers are `missing_exact_coordinates`, `missing_end_time`,
`missing_location_detail`, `requires_event_defaults_policy`,
`requires_owner_safe_copy_review`, and `duplicate_normalized_event_key`.
Every blocker must be explicitly resolved or waived. A waiver is accepted only
when it cites an accepted `organizerPolicyGapReviewDecisions/{decisionId}` with
the exact expected policy id; code defaults and generic acknowledgements do not
clear blockers.

`adminTakedownExternalEvent` is the only takedown writer. Its dry-run/apply
contract is also idempotent and receipt-backed. Apply preserves the source and
audit record, changes publication state to taken down, and records takedown
metadata rather than deleting the document.

Read-only dry-runs on 2026-05-26 found:

| Environment | Events scanned | Repairs needed | Cityless repairs |
|---|---:|---:|---:|
| `dev` | 146 | 146 | 0 |
| `staging` | 0 | 0 | 0 |
| `prod` | 166 | 166 | 0 |

## Read Path Discipline

Firestore reads use an explicit surface policy instead of ad-hoc unbounded
queries:

- **Feed and history surfaces** are growing collections. They require a
  reviewed page size, a stable ordered cursor, refresh behavior, and an honest
  `hasMore` state. Realtime first-page listeners are allowed when freshness is
  product-critical, but older history still loads through a cursor.
- **Rosters and bounded working sets** require a reviewed limit based on the
  product's real domain bound. If the domain is not actually bounded, they use
  the feed/history policy.
- **Point lookups** use deterministic document ids whenever the schema owns
  one. A `where(...).limit(1)` query is not a substitute for a known document
  id.
- **Realtime vs one-shot:** route-visible state that must reflect concurrent
  mutations may use `snapshots()` and follows the lifecycle policy in
  `docs/app_architecture.md#realtime-stream-lifecycle`. Discovery/search pages
  may use one-shot pages when they expose pull-to-refresh and revalidate on
  route or tab re-entry. Administrative reports and explicit exports are
  one-shot unless the workflow contract says otherwise.

Repository-owned composite query builders declare adjacent contracts using:

```dart
// firestore-index: events (marketId:ASCENDING,startTime:ASCENDING)
```

`node tool/run.mjs check contracts:firestore-query-indexes` scans every
handwritten repository source, rejects composite builders with no contract,
verifies each declared ordered field list against `firestore.indexes.json`,
and rejects non-vector one-field composites, with or without an explicit
`__name__`, that Firestore refuses to deploy because built-in single-field
indexes already own those query shapes.
The check also runs inside `./tool/check_data_contract.sh` and Tools CI whenever
repository data code or the index file changes.

### Canonical read limits and cursors

`lib/core/data/read_limit_policy.dart` owns the numeric policy and
`lib/core/data/cursor_page.dart` owns the shared `limit + 1`,
`startAfterDocument`, honest-`hasMore` contract. Repository call sites must not
introduce numeric limits directly. `node tool/run.mjs check
contracts:firestore-read-limits` enforces that boundary and runs in Tools CI
and `./tool/check_data_contract.sh`.

| Surface class | Page size | Notes |
|---|---:|---|
| Explore internal discovery | 80 | Primary mixed-feed supply. |
| Explore external discovery | 40 | Secondary outbound supply. |
| General feed/history | 40 / 50 | Feed page / chronological history page. |
| Directory | 30 | Clubs and other entity directories. |
| Bounded operational set | 1,000 | Contract ceiling for rosters and reviewed exceptions; never a browse-page substitute. |
| Search | 20 | Interactive callable result window. |
| Recommendation rail | 10 | Ranked, explicitly non-exhaustive rail. |
| Deterministic lookup | 1 | Prefer direct document reads; use only where no deterministic id exists. |

The first cursor adopters are Explore internal/external discovery, chat
messages, active matches, club/event/user reviews, activity notifications,
Host Customers, and the Host Events timeline. Payment history uses the same
cursor contract. Their realtime methods now expose only the bounded first
page; their repository page methods advance opaque document cursors for older
or additional supply. Host Customers uses the directory page size. Host Events
holds one session boundary and pages active/future events forward and history
backward independently, so time advancing while the screen is mounted cannot
create cursor gaps or re-read the full archive.
Explore accumulates both discovery cursors, shows `N+` while either has more,
and exposes a load-more action. Its map count includes only records with a
complete coordinate pair.

### Feed freshness policy

Every route-visible feed must provide one explicit manual refresh path and
revalidate on a new route/tab session. Realtime first-page subscriptions count
as continuous revalidation while mounted; they still need manual recovery for
offline/reconnect and older-page failures. Explore invalidates its discovery
window, club source, composed feed, and recommendation providers on pull and on
inactive-to-active tab re-entry. Availability and attendance are recomposed in
that same session refresh.

### Reviewed bounded-set exceptions

The following reads are intentionally not cursor-paged because they are
working sets rather than user-browsed histories. Reclassify them and add a
cursor before expanding their product surface:

| Exception id | Reads | Bound / review trigger |
|---|---|---|
| `READ-EXCEPTION-ACTIVE-EDGES` | active memberships, saved events, blocks, event participations | At most one active edge per deterministic entity pair; paginate if inactive/history states join the query. |
| `READ-EXCEPTION-EVENT-ROSTER` | active event roster and host event report | Bounded by the event admission capacity; exports remain explicit one-shot operations. |
| `READ-EXCEPTION-HOST-CLUBS` | hosted/owned clubs for one user | Small authorization working set; paginate if surfaced as an organization history. |
| `READ-EXCEPTION-CLUB-EVENT-SCHEDULE` | one club's event schedule and invite-link set | Operational club/event working sets; history/archive experiences require cursor pages. |
| `READ-EXCEPTION-RECENT-CLUB-POSTS` | seven-day club post quota window | Server-enforced three-active-post quota; the bounded read exists only to calculate remaining quota. |
| `READ-EXCEPTION-EVENT-SUCCESS` | active event-success module/check-in lists | Bounded to one event's configured workflow; archive/history surfaces require cursor pages. |
| `READ-EXCEPTION-RETIRED-SWIPES` | legacy swipe/profile-decision history | No active `swipes/` product read may be added; migration tooling remains dry-run only. |

Every exception above is still capped with
`ReadLimitPolicy.boundedWorkingSet`; the exception waives cursor UX only, not
the Firestore read ceiling.

`CityRepository` is a deliberate availability exception: it logs normalized
backend errors and falls back to the checked-in launched-city catalog so global
city selection remains usable. Launch-access realtime reads, by contrast, fail
through the standard backend error wrapper and never silently downgrade.

## Current Health

Verified in this consolidation pass from current code and registry state:

- Relationship arrays have already been retired from active app surfaces.
- `tool/data/validate_firestore_data.mjs` validates edge documents and parent
  aggregate drift instead of reconstructing from arrays.
- `createEvent`, `updateEvent`, `cancelEvent`, `deleteEvent`, organizer mutations,
  booking/waitlist/attendance, payments, reviews, safety actions, profile
  updates, Places, and event-success write paths are callable/trigger owned as
  documented in `docs/backend_operation_catalog.md`.
- Contract schemas now cover private/public profiles, events, organizers and
  their explicit legacy club projections,
  relationship docs, social/payment/safety/operational docs, event-success
  documents, callable request payloads, selected responses, direct-write
  payloads, prompt catalogs, seed fixtures, and migration contracts.
- Event discovery projection fields are schema-owned, callable-owned, and have
  dry-run-first backfill tooling for older events.
- `tool/check_data_contract.sh` is the main local gate for generated drift,
  schema validation, Functions checks, rules tests, and focused Flutter
  contract tests.

## Historical Event Rename And Organizer Cutover

The older run/run-club rename is complete. The current authority cutover moves
the organization entity from `Club` to `Organizer`, with `club` retained as an
`organizerType` value:

| Old name | Current name |
|---|---|
| `Run` | `Event` |
| `RunClub` | `Organizer` with `organizerType: club` |
| `RunParticipation` | `EventParticipation` |
| `SavedRun` | `SavedEvent` |

Organizer-named contracts, runtime collections, callables, routes, media paths,
and product-facing copy are the current local authority. `Club`-named Dart
types/folders and callable wrappers are compatibility adapters until the remote
backfill and supported-client window are proven. They must not be used to
introduce new club-only behavior.

### Host media galleries

Organizer and event galleries are ordered `UploadedPhoto` arrays with no
product-level item cap. `position` is a non-negative sequence, the first item is
the explicit cover projection (`imageUrl` for organizers and `photoUrl` for
events), and the organizer `logoPhoto` / `profileImageUrl` remains a separate
optional asset that is never inserted into the gallery. Callable and Firestore
schemas intentionally do not declare `maxItems`; they remain bounded by the
underlying callable and Firestore document-size limits, so clients must render
and edit them through a virtualized/scrolling manager rather than an expanding
inline grid. Consumer dating-profile media retains its independent six-photo
policy and grouped `profilePhotos` contract.

Firebase Storage owns immutable image bytes by stable media identity; Firestore
owns presentation order, cover selection, captions, and the active references.
The canonical object layout is:

```text
organizers/{organizerId}/media/{mediaId}/original.jpg
organizers/{organizerId}/media/{mediaId}/thumbnail.jpg
organizers/{organizerId}/logo/{mediaId}/original.jpg
organizers/{organizerId}/logo/{mediaId}/thumbnail.jpg
events/{eventId}/media/{mediaId}/original.jpg
events/{eventId}/media/{mediaId}/thumbnail.jpg
```

Clients may create and compensation-delete only `original` objects for an
organizer owner or active manager. Replacing an object in place is denied;
editing media creates a new stable `mediaId`. Backend Firestore triggers create
the responsive thumbnails only after the URL is attached to the canonical
document, and organizer/event update and delete operations remove originals and
derived thumbnails after the Firestore commit. This separates unordered object
storage from the ordered gallery contract and prevents gallery reordering from
renaming or re-uploading bytes.

Released-client paths such as `organizers/{organizerId}/photos/{position}_{time}.jpg`,
`organizers/{organizerId}/logo/{time}.jpg`, and the equivalent `clubs` and
`events/{eventId}/photos` paths stay accepted during the compatibility window;
their six-slot filename bound is not the canonical gallery policy. Private form
assets remain separate: `organizerForms/...` and `organizer-form-exports/...`
deny direct SDK access and are exposed only through short-lived backend-signed
requests.

Remote organizer backfill is complete in staging and production; legacy
cleanup is intentionally not complete. Follow
`docs/migrations/clubs_to_organizers.md`. Do not delete or reset Firestore data
in dev, staging, or prod without a separate explicit destructive-action
confirmation. Preserve user documents and both canonical organizer documents
and legacy club projections through any remote migration.

If remote cleanup is approved, first export or back up existing `users`,
`publicProfiles`, and old `runClubs` documents for each Firebase environment.
Then copy any host organizations worth preserving into `organizers`, reset
event-specific legacy collections and edges such as old `runs`,
`runParticipations`, `savedRuns`, reviews, event schedule locks, event-derived
profile decisions, and generated demo event documents, and re-run seed/host tooling against
the canonical `events` and `organizers` collections.

## Open Watch Items

- `RELATIONSHIP-DOC-MIGRATION`: watch only. Do not re-add retired arrays.
- `FIRESTORE-RULES-SIMPLIFICATION-001`: keep `users/{uid}` owner-readable only,
  decide the active club-membership read posture for member-list product needs,
  and keep the final direct writes intentionally narrow.
- `MIGRATION-VALIDATION-001`: before applying legacy migration scripts to
  shared beta data, add or keep seeded fixture tests for duplicates, missing
  docs, deleted users, legacy chats, and count mismatches.
- `DELETE-METHODOLOGY-QUEUE`: core account/event/organizer deletion is
  relationship-doc aware; broader historical event/organizer deletion still needs
  product policy before expanding beyond cancel/archive/delete-unused.
- Retired storage rename from `swipes` to `profileDecisions`: keep legacy
  migration/backfill tooling available for validation and cleanup, but do not
  reintroduce production reads or writes to `swipes/`.
- Retired grouped `ProfilePhoto` migration: profilePhotos is the canonical
  profile photo field after the 1.0.1 app-version floor. Keep legacy-array
  cleanup dry-run-first and do not reintroduce `photoUrls`,
  `photoThumbnailUrls`, or `photoPrompts` as canonical contract fields.
- Nested profile activity preferences: `activityPreferences.running` is the
  canonical home for pace, distance, reason, and run-time preferences. Domain
  decoders can tolerate legacy root fields until remote cleanup completes.

## Historical Evidence

Detailed phase logs and old proof commands were removed from active Markdown.
Use Git history when exact historical wording or retired command output
matters.

### Audience automation ownership

`organizer_form_automation_rules` and `organizer_form_automation_runs` remain
server-only. The existing create callable edits with an expected revision;
nullable form scope enables organizer-wide acceptance and attendance rules.
Published answer conditions carry a server-owned version binding. Runs carry
source identity, original occurrence time, due time and fenced lease fields.
Message actions pin a draft campaign revision and generated campaigns carry
server-only `automationOrigin`; client campaign upserts cannot forge or remove it.
The backend operation catalog owns execution, retry and signed-webhook semantics.

### Event Service WhatsApp Consent Contract

`eventAssistanceWhatsappPermissions` binds the event, attendee creation
generation, verified subject and recipient endpoint to an explicit organizer
sender. Its immutable `eventAssistanceWhatsappConsentReceipts` prove the exact
copy version, displayed sender hash and complete resulting permission hash.
Future-event announcement consent remains separate and is never read as an
Event Assistance grant. The receipt union distinguishes verified-participant
decisions from revocation-only message-link decisions with a null actor UID.
Authenticated endpoint STOP evidence also suppresses the saved preference.

The App-Check-protected `getEventWhatsappPreference` and
`setEventWhatsappPreference` callables require the roster's linked UID. Scope
includes the exact sender ID; most-recently-updated connection selection cannot
silently switch consent. Grants additionally require the matching signed phone
claim, an admitted participant, eligible event, reviewed sender policy and
current verified sender identity. The client submits only scope, decision,
expected revision, request ID, copy version and the previously displayed sender
hash plus the current nullable STOP-record hash. An unseen STOP cannot be
reversed by an older in-flight enable request. Provider identities, recipient
number, consent copy and evidence times
come from trusted server data. The response exposes the sender display name and
business number, masked recipient number and preference state; no provider
account IDs or credentials are exposed.

Credential rotation and health-sync revisions preserve permission. A changed
provider account or sending phone requires fresh consent. Display-name updates
do not erase a saved grant, but a new grant must match the newly displayed
identity. Consent expires no later than 24 hours after the event end captured
at grant time; dispatch must also recheck the current event window. Sender
readiness is independent of a recorded enabled preference.

Permission and receipt commit in one transaction. Exact replays return current
state, while revision conflicts cannot reverse a later withdrawal. The shared
preference transaction adapter maps only the exact closed-transaction callback
RPC error into the SDK's bounded ABORTED retry path. It does not catch commit
uncertainty or reclassify other validation errors. SMS preference and link
withdrawal use this same boundary; paired withdrawal reads are batched. A first
opt-out creates a revoked tombstone without invented grant evidence. Withdrawal
preserves the old recipient/sender evidence even after either changes, and
paused, deleted or malformed sender provisioning cannot obstruct it. These
authenticated APIs still require a current authorized event/roster identity;
the independent message-link withdrawal APIs below require neither. Client
access to permission and receipt collections is denied, including with an admin
claim. Verified opt-in UI and sender activation remain separate delivery work.

`eventAssistanceWhatsappWithdrawalGrants/{linkId}` commits with the dispatch
claim, debits and native reply binding. It pins the original event, attendee
generation, verified subject, recipient endpoint and provider account/phone to
the immutable guest grant hash. A changed identity or longer consent lifetime
requires a new link for dispatch; an existing link cannot silently acquire that
authority. The grant exposes no secret or recipient phone number.

`getEventWhatsappWithdrawal` and `withdrawEventWhatsapp` are App-Check-protected,
network- and credential-rate-limited bearer callables. They return only the
permission state, revision and validity. Withdrawal has the original consent
lifetime and needs no current event, roster, sender or instruction availability.
An expired instruction never regains read/reply authority. Revoked links and
replacement recipients, subjects or provider identities cannot act. Withdrawal
writes a revocation-only immutable receipt and permission revision atomically;
replaying an old request returns the current state without undoing later consent.
A new stop requires the currently displayed revision. It leaves SMS permission,
registration, check-in and organizer announcement preferences untouched. Retain
the guest grant, withdrawal grant and request receipts through this lifetime.

### Event Service WhatsApp Dispatch Contract

`WhatsappDispatchStore` reads event/guest authority, the explicit sender and its
reviewed policy, the original verified recipient, exact consent receipt,
endpoint STOP evidence, CRM pauses/provider blocks, template and scoped guest
link. These facts are read in the same transaction as the outbox claim. The
single-route outbox refuses mixed-route intents; `readFacts` exposes this
channel to the shared composer without silently skipping other channels.
The shared message gate caps all event-service routes at 24 hours after the
current event end, including after a schedule change shortens a previously
granted consent window.

`eventAssistanceWhatsappBudgets` supplies independently approved event and UTC
sender-day ceilings. Budget identity includes currency. Missing, paused, stale,
wrong-scope or exhausted authority withholds the claim. Both conservative cost
debits, `eventAssistanceWhatsappDispatches` material evidence and any native
reply binding commit with the outbox's single unknown attempt. Failure rolls
all of them back. A second outbox still contends on the same spending records.
Unknown/accepted delivery does not release spending or authorize another send.
These records store hashes and scoped references, not credentials, recipient
phone numbers, message text or guest URL secrets. Native payloads are returned
only to the trusted caller. No TTL is applied before reconciliation is defined.

`organizerWhatsappEndpointStops` records the latest authenticated text STOP per
organizer and endpoint independently of CRM contact resolution. It commits with
the signed webhook's receipt and queue item, after transactionally rechecking
an unambiguous provider account/phone connection. Native labels cannot become
STOP commands. Duplicate or older events cannot advance the stop time; absent
or future provider timestamps are conservatively capped at receipt time.
The event preference view reports a stopped grant as disabled. A fresh explicit
grant must acknowledge the current STOP hash and occur later than that stop.
Dispatch requires that later grant and its immutable receipt. Credentials and
sender changes cannot evade an organizer-wide endpoint stop.

CRM admin/provider suppression remains independent. Announcement preference
withdrawal does not revoke separately granted event-service permission. Legacy
CRM inbound-STOP suppression without endpoint evidence stays blocked until
reconciled; the new ledger cannot retroactively prove old consent ordering.
A STOP committed after a dispatch claim prevents later claims but cannot undo
provider I/O already authorized or started.

`EventWhatsappWorker` loads the pinned sender credential before reserving,
claims the exact rendered material and sends once through the Meta adapter
outside the transaction. Submission acceptance is recorded independently from
delivery. A lost response or receipt commit cannot trigger another send. Only
the adapter's proof that permit expiry prevented all I/O can mark an attempt
unsent. HTTP errors and uncertain outcomes retain their conservative debit and
reconciliation hold. The worker requires an explicit provider and is not wired
to a callable, scheduler or live Operations executor.

The worker sends versioned callback correlation containing the attempt and
rendered payload hashes, never credentials, phone numbers or guest secrets.
`WhatsappDeliveryStore` reads the private signed queue and its ingress receipt;
it correlates exact organizer, sender, WABA, phone, recipient endpoint, immutable
dispatch and outbox attempt. Provider timestamps have a five-minute clock-skew
tolerance relative to dispatch and ingestion, not a delivery SLA. The consumer
can recover a lost submission ID from `sent`, `delivered` or `read` evidence.
It merges late/duplicate receipts without regressing delivery, even after event
closure or sender removal; unexpected delivery after an unsent record preserves
a conflict. It does not execute guest choices or grant fallback permission.

`normalizeWhatsappDeliveryStatus` maps only complete signed `failed` status
evidence after that correlation. Technical recovery requires every code to be
`131016` (temporary service failure) or `130429` (throughput limit).
Explicit restrictions (`368`, `130497`, `131031`, `131047`, `131048`, `131049`)
become `policy`; `131050` becomes `suppressed`. A restriction takes precedence
over technical or unknown codes. These classifications stop automatic retries
without rewriting consent or converting a marketing opt-out to an event-service
withdrawal. Unknown codes, `131026`, mixed technical/unknown evidence and failed
statuses without usable codes remain unconfirmed. The first-code field must
agree with the complete list. See the reviewed
[Meta error-code reference](https://developers.facebook.com/documentation/business-messaging/whatsapp/support/error-codes/)
and its [failed status payload](https://www.postman.com/meta/whatsapp-business-platform/request/ocsmpai/status-message-failed).

A normalized failure receipt binds its evidence hash to the attempt, immutable
provider event ID and ingress payload hash. Shared outbox merging preserves
conflicting success/restriction evidence and prevents duplicate state changes.
Technical failure permits the existing delivery evaluator to reconsider an
independently authorized route after backoff; it does not send or refund a
provider debit. A later conflict before the SMS claim withholds that claim.
It cannot recall provider I/O already claimed. The configured Meta API version's
callback echo and terminal-failure behavior still require controlled account
verification before activation. No provider is activated by these changes.

The signed queue's optional `providerErrorEvidence` is a closed union:
`none`, `codes` with one to ten integer codes, or `unusable`. Ingress
preserves code order and duplicates, excludes diagnostic text, and marks the
whole list unusable when any entry is malformed or the bound is exceeded.
The nullable legacy `providerErrorCode` is only the first code of a complete
list. Missing legacy evidence remains readable but cannot establish an
error-free Event Assistance delivery. Positive status plus any error evidence
cannot establish delivery or recovery and retains the spending debit; later
complete signed evidence may resolve an unknown attempt. Unconfirmed outcomes
checkpoint without hot retries. Receipt processing itself has no send authority.

### Event Assistance Accountability Contract

`event_assistance_accountability.schema.json` owns the scoped read, typed
command envelope, response and immutable command receipt. The command names
the assistance episode or explicitly binds its absence; the canonical check-in
and attendance revision independently bind the physical visit. The adapter
uses existing `eventAttendees.accountability*` fields rather than a second
accountability state. All sweep writers advance `accountabilityRevision`,
including clearing. Legacy missing revisions read as zero; overflow fails.

`eventAssistanceAccountabilityReceipts` is server-only. A receipt binds the
actor/request hash, source/attendee generations, visit hash, episode or absence,
applied revision and disposition. It commits with the attendee write. Exact
replay returns the applied operation revision and current view; it never
reapplies an old disposition. Current scoped authority remains necessary on
replay; staff also require current accepted membership for a subgroup. Completion/cancellation do not imply a person
returned. No messaging or participation state is created by this command.
Receipt retention and Host/rehearsal adapters remain subsequent work.

The optional `checkpoint` on read/write scope and response supplies an exact
checkpoint ID and positive departure revision. The receipt additionally freezes
the original roster ID/hash. This branch resolves an original departure member
without requiring event-wide sweep configuration. The absence of this scope
retains existing sweep applicability. Source/read hashes include the frozen
checkpoint evidence; missing or changed receipt scope cannot replay as an event
sweep or another departure. Current registration generations and the departure's
exact check-in/attendance revision must match. The server distinguishes missing
roster, nonmembership, wrong destination, changed visit and changed setup.
Managers retain original-departure review after accepted group transfers; former
group staff do not retain authority over the transferred guest's global result.
All reads now establish scoped permission before fetching attendee or departure
evidence, and writes recheck expiry after the final receipt read. The callback
uses the existing bounded Firestore SDK transaction adapter.

Checkpoint members expose an optional closed `disposition` union: unresolved,
resolved evidence, or unavailable evidence with a reason. Current servers emit
it for every roster member. A resolved value binds the canonical disposition,
positive accountability revision, actor and exact timestamp in a source hash;
the display timestamp is milliseconds. Evidence before departure, after server
time, or from another visit is unavailable. Reported intentions are never used.
Accountability evidence is separate from arrival observations and their review
hash. Request closeout and wake handling for these facts remain subsequent work.

### Event Assistance Channel Selection Contract

`EventMessageWorker` uses one immutable intent and one bounded outbox history
for all permitted channels. It composes the SMS, WhatsApp and RCS workers;
it is a trusted port, not a callable, scheduler or registered live executor.
Only explicitly permitted routes can prepare credentials. Each channel loads
its pinned secret before reservation; a changed sender snapshot makes that
prepared channel ineligible. The production factory now supplies the RCS worker
for an explicit sender when its default-off enablement flag is set. Missing
workers or credentials remain unavailable; enablement grants no send authority.
A malformed source or inconsistent channel gate fails the whole evaluation.

Every route's event gate, consent, suppression, template, recipient and spending
facts are read in the same transaction as reservation, and again at claim.
Channels must agree on the shared event gate and expose exactly their own route.
The shared policy preserves the intent's route order, tries an eligible untried
route before retrying a confirmed failed route, and retains retry backoff and
attempt ceilings. Only the selected channel prepares material, debits its two
budgets and claims the single provider attempt. The channel-specific stores
reject mixed-route reservation so callers cannot accidentally omit competing
channel authority.

A preflight unavailable channel can give way to another independently permitted
and consented route. After submission, unknown or accepted outcomes hold all
fallback even if the original sender, credential or consent later disappears.
Only trusted confirmed technical non-delivery can permit fallback. Policy,
suppression and invalid-recipient rejections require resolution; conflicting
delivery evidence stops a pending fallback claim. Raw Meta failed statuses still
lack a reviewed finality mapping and therefore do not unlock this path. This
composition does not imply provider activation or guaranteed delivery.

An existing unsent reservation keeps its original channel, sender and permission
snapshot. On authorization expiry the outbox records it as unsent; recovery uses
a new bounded attempt and fresh authority, never repurposes the old id. Durable
reconciliation and live Operations integration have their own boundaries above;
their source wiring does not establish deployed scheduling or activation.

### Event Assistance SMS Delivery Contract

The canonical `event_assistance_sms.schema.json` vocabulary supplies private
sender, permission, budget and dispatch documents. `eventAssistanceSmsSenders`
records explicit use-case/header approval, the exact numbered credential
reference, approved template parts and a bounded INR rate quote. It contains
no provider password. Missing, inactive, paused or expired configuration never
implies readiness.

`eventAssistanceSmsPermissions` binds Catch event-service SMS to an event,
attendee creation generation, verified subject, phone endpoint and sender.
The exact consent-copy version, receipt, timestamps, expiry and withdrawal
state are required. Organizer marketing preference records are not permission
for this route. The App-Check-protected preference callables require the roster's
linked Firebase UID. A grant additionally requires the signed phone claim to
match the roster phone and an admitted guest in an eligible event. Client input
contains only event/attendee scope, decision, copy version, expected revision
and request ID. Sender identity, number and evidence timestamps come from the
server. Revocation can proceed without a ready sender or current phone claim.

`eventAssistanceSmsConsentReceipts` records each exact decision atomically with
its permission revision. Grant receipts pin the displayed copy hash and the
hash of the complete resulting permission; dispatch requires that matching
receipt. Receipt timestamps record when the signed phone claim was checked,
not when a new OTP was sent. Revision conflicts return current state; replaying
an earlier grant cannot reverse a later withdrawal. An initial opt-out writes a
revoked tombstone with no fabricated consent evidence. Recreated roster entries
cannot inherit consent. Responses reveal only the participant's masked number,
status, availability and consent text; there is no client collection access.
Sender approval and activation remain separate trusted provisioning steps.

`eventAssistanceSmsBudgets` bounds both event spend and sender-day spend in
Asia/Kolkata. A trusted worker atomically charges both ceilings with the
outbox claim. `eventAssistanceSmsDispatches` keeps one immutable attempt debit,
rendered-material hash and sender/template/permission/quote references. It
also binds the original sender mask and the hash of a random 192-bit reporting
credential. Only the worker receives the plaintext credential, submitted in
Gupshup's `extra` field; decoded delivery reports must prove this credential
and match the dispatch scope before updating the private outbox. The credential
does not authorize a send, opt-in or budget release. Retain the immutable
dispatch and outbox through the provider reconciliation window, independently
of guest-link or event expiry. Cleanup remains unimplemented.
The dispatch stores neither message content, reporting credential nor the guest
URL secret. Conservative debits
remain charged across uncertain outcomes and provider rejections until an
explicit reconciliation implementation accounts for them. They are spending
reservations, not billing receipts. Firestore clients, including admins, cannot
read or write any of these six collections.

The dormant `eventAssistanceSmsDeliveryWebhook` accepts a bounded, strictly
decoded GET report and delegates credential/scope validation to the reporting
store. Duplicate parameters, bodies, unknown fields and partial string matches
are rejected before database access. The HTTP response exposes no internal
identifiers or report contents, waits for completed processing, and returns a
retryable service error on infrastructure failure. Delivery reporting grants
no write authority over attendance, consent or budgets. The handler logs no
request material or thrown error, but GET callback secrets also require verified
platform request-log redaction/exclusion before activation. No new persisted
document or client grant is introduced; existing outbox evidence owns duplicate
and contradictory delivery reports.

`eventAssistanceSmsWithdrawalGrants` is created in the same transaction as a
live SMS dispatch claim. It binds the original guest-link hash to one permission,
attendee generation, subject, sender and phone endpoint. Its separate lifetime
ends with the permission captured at dispatch. An expired instruction does not
expire this narrowly scoped ability to withdraw; it grants no event read/reply
access. A revoked guest grant invalidates both uses. Reusing a link for a new
recipient or a longer consent lifetime requires a fresh grant before dispatch.

`getEventAssistanceSmsWithdrawal` and `withdrawEventAssistanceSms` require that
bearer capability, App Check and network/credential rate limits. They need no
current event, roster or sender status, so cancellation cannot obstruct opt-out.
They expose only text status, revision and validity, with no name, phone or event
identifier. Changing the permission's attendee generation, subject or endpoint
invalidates the old capability. Only an explicit mutation withdraws permission;
link reads and previews never do. Its immutable consent receipt uses
`source: messageLink`, the link id and `actorUid: null`; authenticated preference
receipts use `source: verifiedParticipant` and their verified UID. A bearer
receipt can never grant consent. Replayed withdrawals return current state,
including later verified opt-in, and stale revisions require a new explicit
choice. Retention must keep the guest grant, withdrawal binding and deduplication
receipts through this capability's lifetime and provider reconciliation window.

### Event Assistance Guest Response Contract

`eventAssistanceGuests` stores the event/attendee binding, exact roster creation
generation, explicit participation, episode and revisioned reported intent.
Firestore event/roster creation generations also fence source replacement.
It deliberately
does not extend or mutate the admission/attendance projection. Replacing an
episode invalidates all earlier grants. `eventAssistanceThreads` stores one
current message head per guest episode, workflow kind and occurrence; separate
workflow conversations cannot overwrite each other.

`eventAssistanceGuestGrants` contains only the hashed bearer secret and its
thread/guest/episode scope, signing key id, issue/expiry times and optional
revocation. Grants live for at most 24 hours, bounded by the event end when it
is still upcoming. The raw secret is regenerated only for the trusted worker;
it is never stored in the outbox or returned by the public read endpoint.

Guest response acceptance checks the current thread head and intent revision;
joining intent additionally fences the participation revision. The response,
message closure and any intention/help-case effect commit in one transaction.
The response remains in the message for retry deduplication. `eventAssistanceCases`
correlates a help request with the accepted response; comfort/safety categories
are assigned only to the restricted safety owner, other categories to the event
lead. No SDK client, including an administrator, can access any of these four
collections directly. Host projections and case-resolution commands require
separate authorized boundaries before this feature can be enabled.
