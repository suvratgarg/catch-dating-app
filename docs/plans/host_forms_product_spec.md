---
doc_id: host_forms_product_spec
version: 1.0.0
updated: 2026-09-05
owner: host_tooling
status: active
---

# Host Forms Product Specification

## Decision

Catch Forms is an Audience-owned Host capability for collecting structured
information before, during, and after an event. A Host can create, publish,
share, embed, pause, duplicate, and analyze a form without requiring the
respondent to install Catch or complete a Consumer profile.

Forms is a platform primitive. Applications are one form purpose with an
additional review workflow; registrations, waivers, feedback, surveys, and
general intake must not be forced into application-review state.

## Audience ownership and source status

Forms is an Audience-owned navigation and source capability. The canonical Host
destination is `/host/audience`, where Forms and Responses are peer modes; legacy
`/host/forms` links redirect into that destination. The generated [Audience
responsibility README](../../lib/hosts/audience/README.md) owns route composition,
source roots, and handoffs. This document remains the sole Forms product and
implementation contract.

This specification extends
`docs/plans/standalone_host_product_and_crm_delivery_plan.md`. Data authority
remains owned by `docs/data_contracts.md`, client architecture by
`docs/app_architecture.md`, and public route architecture by
`docs/web_surface_architecture.md` and
`docs/marketing_website_architecture.md`. Source implementation does not by
itself establish deployment, configured provider state, runtime availability, or
released-client availability.

## Outcome

A Host can complete this loop:

1. Start from a template or blank form.
2. Compose sections and questions, configure validation and conditional logic,
   and preview the exact phone and desktop experience.
3. Publish an immutable version and distribute its stable URL, QR code, or
   embed snippet.
4. Receive responses from app-free respondents under the selected identity and
   consent policy.
5. Inspect individual responses and aggregate results, export permitted data,
   and run explicit automations.
6. Convert a response into an application, CRM contact, event attendee, or
   follow-up workflow only through a reviewed, idempotent action.
7. Pause, revise, republish, duplicate, archive, or delete eligible drafts
   without corrupting historical responses.

## Product Boundary

### In scope

- Host form library and complete lifecycle.
- Blank forms and event-type templates.
- Sectioned builder with all supported field types.
- Required rules, field validation, branching, and conditional visibility.
- Branding within the Catch design system.
- Public app-free response routes.
- Configurable anonymous, email, and phone identity policies.
- File uploads with scoped asset ownership.
- Draft recovery, review, consent, submit, confirmation, and respondent copy.
- Stable share links, QR assets, source attribution, and safe embeds.
- Response inbox, detail, search, filters, exports, and aggregate analytics.
- Explicit automations and idempotent downstream conversion.
- Application-review projection for application-purpose forms.
- Environment deployment and exact-route smoke verification.

### Not in scope

- A general website builder or arbitrary custom CSS/JavaScript.
- Payment collection inside arbitrary questions. Event checkout remains the
  payment owner and may be linked only through an explicit completion action.
- Hidden enrichment from Consumer dating-profile fields.
- Selling or uploading respondent data to advertising platforms without a
  separate policy and consent gate.
- Guessing delivery permission from form submission, imported contact data, or
  authentication.
- A promise that embedded forms can bypass browser, platform, CAPTCHA, or
  third-party cookie restrictions.

## Product Model

### Form purposes

Every form declares one immutable-at-publish purpose:

| Purpose | Primary job | Optional downstream projection |
| --- | --- | --- |
| `application` | Collect and review applicants | Host application queue |
| `registration` | Request a place at an event | Reviewed event attendee or booking handoff |
| `intake` | Collect operational information | CRM contact or event attendee |
| `waiver` | Capture acknowledged terms and required signatures | Event-scoped waiver receipt |
| `feedback` | Collect post-event outcomes | Event feedback aggregate |
| `survey` | Collect structured research | No automatic operational projection |

Purpose selects safe defaults and available completion actions. It never grants
authority by itself.

### Lifecycle

Forms use these states:

```text
draft -> published <-> paused -> archived
  |          |
  +----------+-> new immutable published version
```

- `draft`: editable and unavailable to respondents.
- `published`: active version accepts responses.
- `paused`: stable public route remains valid but rejects new starts/submits
  with Host-authored availability copy.
- `archived`: excluded from the default library and permanently closed to new
  responses. Historical versions and responses remain readable under policy.

Only drafts with no dependent published history may be hard-deleted. Published
forms are archived, not deleted. Duplicating creates a new draft with new form,
section, question, option, link, and automation identities.

### Versioning

- Builder edits write an optimistic-revision draft document.
- Publishing creates one immutable version snapshot and atomically selects it
  as the active version.
- In-flight respondents stay bound to the version they started.
- A later publish never mutates earlier questions, labels, logic, consent, or
  completion behavior.
- Response answers store question identity plus an immutable label/type
  snapshot so historical review does not depend on the current draft.

## Actors And Authority

| Actor | Capability |
| --- | --- |
| Organizer owner/manager | Create, edit, publish, pause, duplicate, archive, inspect responses, export permitted fields, and configure allowed automations |
| Event-scoped staff | Read or review only forms/responses explicitly attached to the granted event; no organizer-wide form administration |
| Respondent | Read one published version, save an eligible draft, submit, receive confirmation, and withdraw where policy permits |
| Support/Trust & Safety | Purpose-scoped audited access only through existing operations policy |
| Public guest | Resolve only bounded public-form presentation; never list organizer forms or responses |

Authentication proves the respondent controls an authentication factor. It does
not grant the Host access to unrelated account or profile fields.

## Host Experience

### Form library

The Forms root belongs in the Host workspace as a first-class destination, not
inside a Customers overflow menu. It provides:

- purpose, lifecycle, target, response count, completion rate, and last-response
  columns/rows;
- search and filters for purpose, state, target, and template;
- create, open, preview, share, pause/resume, duplicate, archive, and eligible
  draft-delete actions;
- bounded cursor pagination;
- useful empty, loading, failure, and permission states; and
- separate `Forms` and `Responses` views without inventing another customer
  identity model.

### Builder

The builder is an autosaved controller-owned workspace with three panes on
large screens and progressive routes/sheets on phones:

1. **Outline:** sections and questions, reorder, duplicate, delete.
2. **Canvas:** editable content using canonical Catch field and section
   primitives.
3. **Inspector:** question type, required state, mapping, validation, logic,
   presentation, and privacy settings.

The builder supports:

- title, description, purpose, target, availability, and response limit;
- sections with title, description, page-break behavior, and stable ids;
- short text, long text, single choice, multiple choice, date, phone, email,
  URL, number, boolean, file, acknowledgement, and signature fields;
- options with stable ids, reorder, and safe deletion warnings;
- required state and type-appropriate validation;
- canonical person-field mapping only where the catalog permits it;
- respondent-visible help and privacy copy;
- conditional visibility and section routing;
- completion message and optional reviewed next action;
- Catch-owned appearance presets, organizer logo, cover image, and activity
  pigment without arbitrary CSS; and
- undo/redo for local edits plus server revision-conflict recovery.

Builder state must remain serializable and deterministic. Widgets do not own
publishing, validation, persistence, or identity generation.

### Preview

Preview renders the same response components and validation engine used by the
public route. It supports phone/desktop widths, light/dark policy where allowed,
logic-path simulation, required/error states, upload states, confirmation, and
paused/closed states. Preview never writes a real response or analytics event.

## Template Gallery

Templates are versioned source data, not hard-coded widget branches. Initial
templates are:

| Template | Purpose | Format-aware content |
| --- | --- | --- |
| Event application | `application` | Identity, motivation, availability, consent |
| Event registration | `registration` | Contact, ticket/context questions, organizer updates opt-ins |
| Dinner guest intake | `intake` | Dietary requirements, seating notes, accessibility |
| Run/walk participation | `intake` | Pace, distance, route/accessibility, emergency contact policy |
| Racket-sport session | `intake` | Level, preferred side, pairing/rotation inputs |
| Quiz/team night | `registration` | Team/table preference, team name, accessibility |
| Event waiver | `waiver` | Terms version, acknowledgements, signature |
| Post-event feedback | `feedback` | Rating, structured outcomes, private note, safety escalation |
| Blank form | Host-selected | No questions until the Host adds them |

Creating from a template copies it into an organizer-owned draft. Future
template changes never mutate that draft.

## Logic And Validation

### Conditions

Conditions use stable ids and a closed expression language:

- operands: prior answer, respondent identity state, target metadata, or a
  literal;
- operators: equals, not-equals, contains, not-contains, greater/less than,
  answered, and not-answered;
- combinators: all or any;
- actions: show/hide question, show/hide section, route to section, or finish;
  and
- no arbitrary code, remote lookup, or profile-derived condition.

The validator rejects forward-reference cycles, unreachable required questions,
invalid option references, and routes without a terminating completion path.
The server re-evaluates visibility and requiredness on submission; the client is
not authoritative.

### Validation

Validation derives from schema contracts and includes min/max length, numeric
range, date range, option bounds, file count/size/type, regex from a reviewed
preset catalog, and exact phone/email/URL normalization. Host-authored error
copy is optional and bounded; safe system copy is the fallback.

## Respondent Experience

### Public route

The canonical route is `/f/:publicFormId/`. `publicFormId` is opaque and stable
across published versions. The route is `noindex,follow` by default; a future
explicit discoverable-form policy must not be inferred from publication.

The route resolves only:

- bounded organizer presentation;
- the active immutable form version;
- identity requirement and consent/retention copy;
- current availability/response-limit state; and
- safe completion behavior.

### Identity policies

Each published version selects one policy:

| Policy | Use |
| --- | --- |
| `anonymous` | Low-risk surveys/feedback with abuse controls; no CRM/application conversion without later verified identity |
| `emailVerified` | Email-link/OTP verification |
| `phoneVerified` | Phone OTP verification |
| `emailOrPhoneVerified` | Respondent chooses either supported factor |
| `catchAccount` | Explicitly account-required experiences only; never the default for standalone Forms |

Sensitive questions, signatures, participant-private suggestions, and specified
completion actions raise the minimum permitted identity policy. A Host cannot
configure an unsafe lower policy.

### Draft and submit

- Anonymous drafts use a short-lived bearer draft token stored only on that
  device.
- Verified drafts bind to the verified UID and form version.
- Autosave is debounced, revisioned, expires under the form policy, and excludes
  unsaved file bytes.
- The respondent reviews every answer and consent before submit.
- Submission is idempotent and returns a stable receipt.
- Confirmation may show Host-authored copy, a receipt summary, withdrawal link,
  and one reviewed next action.
- Refresh, back navigation, duplicate submit, version replacement, pause, quota,
  upload failure, and expired verification have explicit recovery states.

### Files

Uploads use pre-authorized form/version/question-scoped asset intents. Storage
rules enforce owner/draft token, content type, size, count, readiness, and short
or policy-bound retention. A response may reference only ready assets scoped to
its exact draft or verified respondent. Hosts receive time-bounded download
access only when response authority permits it.

## Distribution

Every published form has:

- stable canonical URL;
- copy-link and native-share actions;
- downloadable SVG and PNG QR code;
- print-safe QR sheet;
- safe responsive embed snippet with allowlisted origins and a hosted fallback;
- optional source links with labels and UTM-compatible attribution; and
- a share preview using bounded organizer/form presentation.

Share-link creation and resolution use opaque tokens. Analytics may count
Catch-controlled share intents, human-filtered opens, starts, verified starts,
submissions, and completions. It must not claim to observe private forwards.

## Responses And Analytics

### Response inbox

Hosts can search/filter/sort bounded response pages by form, version, target,
submission time, completion/review state, source, and permitted mapped fields.
Answer detail renders from the immutable snapshot and clearly distinguishes
anonymous, respondent-granted, organizer-acquired, and revoked data.

### Aggregate analytics

Analytics include:

- opens, starts, submissions, completion rate, and median completion time;
- abandonment by section/question without storing unsent answer content;
- choice distributions and numeric/date summaries where privacy thresholds
  permit;
- source-link funnel;
- application review outcomes;
- export and automation activity; and
- version comparison without combining incompatible question identities.

Small cohorts and sensitive/free-text fields are not aggregated into misleading
charts. Analytics read precomputed counters/aggregates rather than scanning all
responses on every screen load.

### Export

CSV/XLSX export is asynchronous for large sets, version-aware, and produces an
expiring download. It includes provenance and consent fields, never internal
grant data or private participant suggestions, and records an auditable export
receipt. Advertising-platform customer-list formats remain policy-gated and
separate from ordinary response export.

## Automations And Conversion

### Triggers

- response submitted;
- application review state changed;
- response withdrawn;
- response matches an explicit answer condition; and
- scheduled reminder before a configured close time.

### Actions

- notify organizer team;
- send a respondent confirmation through an authorized service channel;
- add/remove an organizer tag;
- create or link a CRM contact through the identity-resolution boundary;
- create a reviewed event-attendee proposal;
- add to an application review queue;
- invoke an allowlisted signed webhook; and
- enqueue an authorized WhatsApp/email follow-up through the existing campaign
  permission boundary.

Automation runs are idempotent, revision-bound, retryable, observable, and
disableable. A response never silently creates a Consumer profile, booking,
marketing consent, payment, or public identity.

Conversions show a preview, conflicts, exact fields, permissions, and resulting
record before confirmation. The receipt supports safe replay and a bounded undo
where the downstream aggregate permits it.

## Canonical Data Architecture

The generic core uses:

| Path | Role |
| --- | --- |
| `organizerForms/{formId}` | Organizer-owned mutable metadata, lifecycle, public id, active/draft version refs |
| `organizerFormVersions/{versionId}` | Immutable published definition snapshot |
| `organizerFormDrafts/{formId}` | Optimistic-revision builder document |
| `organizerFormResponseDrafts/{draftId}` | Expiring respondent autosave state |
| `organizerFormResponses/{responseId}` | Immutable submitted envelope and answer snapshot |
| `organizerFormAssets/{assetId}` | Scoped upload metadata |
| `organizerFormShareLinks/{linkId}` | Source-specific opaque link and counters |
| `organizerFormAggregates/{aggregateId}` | Version/question/source analytics projections |
| `organizerFormAutomationRules/{ruleId}` | Organizer-owned versioned automation definition |
| `organizerFormAutomationRuns/{runId}` | Idempotent execution status and sanitized error |
| `organizerFormConversionReceipts/{receiptId}` | Reviewed downstream conversion receipt |

The existing `organizerApplicationForms`, versions, responses, imports, and
grants remain compatibility sources during migration. Application-purpose form
submission projects one application review row that references the canonical
form response. Application review must not become the generic response store.

No client writes these collections directly. All writes are contract-validated
callables or idempotent triggers. Public reads are callable projections rather
than Firestore collection reads.

## Callable Surface

### Host management

- `createOrganizerFormDraft`
- `updateOrganizerFormDraft`
- `getOrganizerFormEditor`
- `listOrganizerForms`
- `validateOrganizerFormDraft`
- `publishOrganizerForm`
- `setOrganizerFormLifecycle`
- `duplicateOrganizerForm`
- `deleteOrganizerFormDraft`
- `createOrganizerFormShareLink`
- `getOrganizerFormShareAssets`

### Respondent

- `getPublicOrganizerForm`
- `beginOrganizerFormResponse`
- `saveOrganizerFormResponseDraft`
- `createOrganizerFormAssetIntent`
- `finalizeOrganizerFormAsset`
- `submitOrganizerFormResponse`
- `withdrawOrganizerFormResponse`

### Responses, analytics, and operations

- `listOrganizerFormResponses`
- `getOrganizerFormResponseDetail`
- `getOrganizerFormAnalytics`
- `requestOrganizerFormExport`
- `createOrganizerFormAutomation`
- `setOrganizerFormAutomationState`
- `listOrganizerFormAutomationRuns`
- `previewOrganizerFormConversion`
- `convertOrganizerFormResponse`

All manager callables require organizer authority, App Check, rate limits,
schema validation, optimistic revisions, and bounded reads. Public callables
require App Check or a reviewed public abuse-control substitute, strict public
id validation, rate limits, and response-shape redaction.

## UX And Design Contract

- Forms use the light editorial register, hairlines, whitespace, and canonical
  Catch field/section primitives.
- A form is information, not a stack of decorative cards.
- Builder selection and drag affordances may use quiet functional surfaces;
  respondent output remains section-led and content-first.
- Top bars, async states, mutation feedback, skeletons, sheets, buttons,
  fields, chips, and notices use existing governed primitives.
- Public React fields adapt `@catch/web-ui` through website shared primitives.
- Phone width, keyboard, text-scale 2.0, screen reader, reduced motion, high
  contrast, and light/dark policy are acceptance states, not deferred polish.

## Source implementation and remaining gates

The old delivery tranches are reduced to status because the repository now has
source seams for the complete Forms lifecycle. This is not a claim of deployment
or user availability.

| Capability | Source evidence | Current status |
| --- | --- | --- |
| Audience navigation and Host Forms UI | [Audience README](../../lib/hosts/audience/README.md), [router](../../lib/routing/go_router.dart), `lib/hosts/presentation/forms/` | Audience-owned source implementation; route/state capture and release proof remain separate. |
| Management, lifecycle, builder, validation, publication | [Functions inventory](../../functions/README.md) management entries and `lib/hosts/presentation/forms/` | Source seams are present for draft/editor/lifecycle operations; exact released-client coverage remains a gate. |
| Public respondent and distribution | Functions respondent/distribution entries, website `/f/` route metadata, and the `/f/:publicFormId/` contract above | Source route and callable seams are present; mobile/desktop runtime, environment, abuse, and deployment proof remain open. |
| Responses, analytics, exports, automations, and conversion | [Functions inventory](../../functions/README.md) operations entries and `functions/src/organizers/organizerForm*.ts` | Source seams are present; aggregate/export/automation replay and downstream receipt proof remain open. |

The product contract above remains authoritative for lifecycle, safety, consent,
public respondent privacy, identity policy, uploads, analytics, automations, and
conversion behavior. No delivery status may weaken those requirements.

## Remaining release, runtime, and commercial gates

- Prove contract generation, valid/invalid fixtures, migration compatibility,
  authorization, App Check, rate limits, idempotency, revision conflicts,
  redaction, emulator integration, Firestore/Storage rules, index parity,
  scoped asset access, retention, and deletion behavior.
- Prove Flutter controller/domain/widget/analyzer/route/design checks and
  deterministic captures for library, builder, preview, share, analytics,
  automations, response detail, loading, empty, error, pagination, text scale,
  keyboard, reduced motion, high contrast, and light/dark states. The current
  screen registry contracts these Audience-owned routes under
  `screen.host.customers`; automation visual capture is still pending.
- Prove the public React respondent loop on mobile and desktop, including
  bootstrap, configured identity modes, autosave, review/submit/withdraw,
  refresh, duplicate submit, pause/version replacement, auth expiry, upload
  failure, completion, QR/link/embed resolution, and no private-data leakage.
- Verify dev/staging/production contract versions, exact deployed callable
  revisions, Hosting probes, released-client behavior, public availability,
  submission/automation/export failures, load/abuse thresholds, and support
  runbooks. Source or test presence is not deployment evidence.
- Keep first-100-Host onboarding manual and instrumented until a pilot can publish
  a useful template and share a working app-free link in one guided session.
  Measure time to publish, share-to-start, completion, failed-question rate,
  review turnaround, downstream conversion, and repeat use. Feature count is not
  distribution evidence.
