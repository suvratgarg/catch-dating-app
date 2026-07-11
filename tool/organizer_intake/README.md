# Organizer Intake

Private, deterministic intake layer for organizer discovery.

This folder is the boundary between noisy web/search evidence and public Catch
surfaces. Raw candidates, external profiles, social accounts, platform pages,
and future crawl settings are modeled here before anything is promoted into
`clubs`, the website, or the app.

## Naming

- `OrganizerEntity`: the canonical public/business entity. This can be a brand,
  venue, community, individual-run event brand, or multi-city operator.
- `Host`: a person or account with operating rights on Catch.
- `Club`: legacy compatibility projection used by existing app/backend code.

## Pipeline

1. Search and scrape produce private organizer candidates.
2. Platform adapters normalize URLs into typed surfaces with stable dedupe keys,
   crawl defaults, and conservative confidence defaults.
3. Candidates normalize into one `OrganizerEntity` with many `surfaces`.
4. Manual QA can add curation operations for merges, suppressions, rejected
   surfaces, and split-required surfaces.
5. The generator builds dedupe and admin review artifacts from the curated
   effective entity state.
6. Manual QA records promotion decisions in the admin bridge or repo-backed
   decision batches under `review_decisions/`.
7. Approved entities project into public website listings.
8. App discoverability remains a separate gate from website publication.
9. Future recurring event crawls can attach to approved surfaces, but every
   surface defaults to `manualOnly` and `disabled`.

## Commands

```sh
node tool/organizer_intake/organizer_intake.mjs
node tool/organizer_intake/organizer_intake.mjs --check
node tool/organizer_intake/normalize_surface_url.mjs https://luma.com/pxgmph3b
node tool/organizer_intake/capture_search_results.mjs \
  --run-key 'web_search|"after fly" luma|indore|social_run_club|afterfly-run-club-indore' \
  --raw-results tool/organizer_intake/fixtures/search_capture.afterfly.serpapi.raw.json \
  --date 2026-06-17
node tool/organizer_intake/ingest_search_results.mjs
node tool/organizer_intake/capture_luma_events.mjs \
  --entity afterfly \
  --surface afterfly-luma-takeoff-run-rave \
  --raw-results tool/organizer_intake/fixtures/luma_event.afterfly.raw.json \
  --date 2026-06-17
node tool/organizer_intake/ingest_event_sources.mjs
node tool/organizer_intake/plan_event_location_resolution.mjs
node tool/organizer_intake/event_location_resolution.mjs list
node tool/organizer_intake/plan_event_crawl_runs.mjs
node tool/organizer_intake/plan_raw_artifact_storage.mjs
node tool/organizer_intake/event_review_decision.mjs list
node tool/organizer_intake/plan_external_event_imports.mjs
node tool/organizer_intake/preflight_external_event_imports.mjs
node tool/organizer_intake/policy_gap_decision.mjs list
node tool/organizer_intake/curation_decision.mjs list
node tool/organizer_intake/export_curation_decisions_from_firestore.mjs \
  --env dev \
  --date 2026-06-17
node tool/organizer_intake/export_review_decisions_from_firestore.mjs \
  --env dev \
  --date 2026-06-17
node tool/organizer_intake/export_event_review_decisions_from_firestore.mjs \
  --env dev \
  --date 2026-06-17
node tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs \
  --env dev \
  --date 2026-06-17
node tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs \
  --env dev \
  --date 2026-06-17
node tool/organizer_intake/sync_claim_targets_to_firestore.mjs \
  --env dev
node tool/organizer_intake/check_operational_health.mjs --check
node tool/organizer_intake/pending_decision_answer_packet.mjs --format markdown
node tool/organizer_intake/create_decision_answer_packet.mjs \
  --date YYYY-MM-DD \
  --reviewer REVIEWER \
  --slug REVIEW_SLUG
node tool/organizer_intake/reviewed_decision_answer_packets.mjs --check
node tool/organizer_intake/pending_decision_answer_plan.mjs --format markdown
node tool/organizer_intake/apply_pending_decision_answers.mjs --check --allow-partial
node tool/organizer_intake/run_promotion_pipeline.mjs \
  --apply-decision-answers \
  --answer-packet PATH \
  --write-decision-answers
node tool/organizer_intake/pending_input_request.mjs --format markdown
node tool/organizer_intake/pending_work_coverage.mjs --check --require-covered
node tool/organizer_intake/promotion_execution_packet.mjs --format markdown
node tool/organizer_intake/llm_source_resolution.mjs --dry-run
node tool/organizer_intake/check_admin_review_bridge.mjs
node tool/organizer_intake/check_promotion_bridge.mjs
node tool/organizer_intake/run_promotion_pipeline.mjs
```

Generated files live under `tool/organizer_intake/generated/`.
`generated/canonical_host_entities.json` is the private canonical entity
registry. It is the boundary between noisy organizer intake and downstream
public Host pages, legacy `clubs/{id}` compatibility documents, crawl planning,
and event import planning. Public copy can call the entity a Host, while the
private intake model remains `OrganizerEntity` until the naming migration is
approved. This artifact never writes Firestore and never publishes a page by
itself.
`generated/canonical_evidence_index.json` is the provenance index for canonical
host surfaces. It ties every surface to evidence refs, local artifact hashes
when the referenced file exists, raw payload storage status, curation decisions,
and review state. Manual reports without artifacts remain visible as review
work; raw provider payloads remain forbidden from Firestore and remote upload
stays controlled by the raw artifact storage policy.
`generated/publication_review_packets.json` is the admin publication packet
layer. It gathers canonical host state, evidence coverage, public draft copy,
review gates, curation state, and the local/admin decision command into one
record per candidate. It is decision support only: it never publishes, indexes,
syncs claim targets, writes Firestore, enables app visibility, or enables
crawls/imports. The local publication decision bridge consumes this packet
before drafting `approve_public`; approvals are refused while data blockers,
evidence blockers, incomplete packet checklists, or unreviewed manual reports
remain.
Each packet also carries a bounded `evidenceReview` section derived from
`generated/canonical_evidence_index.json`, with reviewer-facing surface state,
evidence refs, local artifact metadata, candidate correlations, risk flags, and
next actions. It keeps raw provider payload content out of the packet while
letting admin QA review artifact-backed and manual-only evidence in one place.
When a packet contains manual reports without local artifacts, approval
decisions must persist `checklist.manualReportsReviewed: true`. The generator
revalidates that acknowledgement against the pre-approval packet before public
projection, so exported Firestore decisions cannot bypass manual evidence
review.
`generated/publication_decision_impact_preview.json` simulates the exact
website projection and claim-target consequences of approving each ready
publication packet. It shows the future canonical path, index state, sitemap
eligibility, claim-target path, app visibility, and follow-up commands while
recording no decision and writing no remote data.
After website builds, `website/scripts/checkOrganizerBuildOutputs.mjs` verifies
that generated organizer routes, legacy routes, canonical tags, robots tags,
semantic static profile content, Organization JSON-LD, and sitemap lastmod
dates match `website/src/generated/hostListings.json`. The marketing
postbuild step invokes this validator so stale public-page SEO output fails the
build before deploy. In `--claim-sync firestore` mode,
`run_promotion_pipeline.mjs` first creates a read-only, plan-hash-bound
environment receipt and passes it to website listing generation; fixture mode
keeps its local sync preview after the build. Use `--skip-website-build` only
for focused local debugging where deploy readiness is not being asserted.
`generated/organizer_claim_target_sync_preview.json` is the local claim-target
sync review packet. It applies the same create/refresh/owner-bound skip rules
as `sync_claim_targets_to_firestore.mjs` against a no-remote fixture so the
admin bridge can show write consequences durably. It never reads or writes
Firestore; before any remote write, run the sync tool without `--write` against
the target project and review those live actions.
`check_promotion_bridge.mjs` validates this preview against
`generated/organizer_claim_targets.json`, so stale or missing preview actions
cannot pass the promotion bridge before website deploy or claim-target sync.
`generated/event_crawl_plan.json` is the disabled-by-default crawl readiness
artifact. It records crawl-capable organizer surfaces and blockers, but it does
not enable a scheduler, fetch provider pages, write events, or promote any page.
`generated/event_crawl_run_plan.json` is the disabled-by-default execution
preview for those crawl-capable surfaces. It records deterministic run intents
and blockers, but it never fetches provider pages, writes Firestore, schedules
jobs, or creates event candidates. Future crawl results must still become
reviewed `event_source_batches/` files before event import planning.
`generated/raw_artifact_storage_manifest.json` is the disabled-by-default raw
artifact storage manifest. It inventories local raw provider payloads, reviewed
source batches, decision batches, and fixture support files. Raw provider
payloads are explicitly forbidden from Firestore and remote object upload stays
blocked until bucket, retention, deletion, and crawl-cost policy are approved.
`generated/organizer_workflow_readiness.json` is the operator-facing status
rollup. It names the gates that are ready, waiting for admin review, or blocked
on product/policy input so the admin bridge can show the same state as the
tooling pipeline.
`generated/organizer_operator_action_queue.json` is the ordered operator queue
derived from publication packets, publication impact previews, policy decision
packets, claim-target sync preview, and workflow readiness. It gives the admin
panel one durable list of publication decisions, policy inputs, and waiting
workflow gates without approving anything or enabling disabled behavior.
`generated/organizer_operational_health.json` is the read-only cross-workstream
health rollup. It summarizes publication review, policy decisions, promotion,
claim-target sync, raw artifact storage, crawl execution, external event
imports, search intake, and evidence quality into prioritized statuses and
commands. It exists to make the pending workflow auditable; it never writes
Firestore, uploads artifacts, imports events, publishes pages, or enables
crawls.
`generated/organizer_reviewed_decision_answer_packets.json` is the read-only
directory register for reviewed copies under `answer_packets/`. It reports
whether copied answer packets are absent, incomplete, stale against the generated
source, invalid, or ready for the guarded apply step. The admin bridge embeds the
same register so operators can see answer-packet readiness before running the
promotion pipeline.
Use `check_operational_health.mjs --check` to validate that rollup and print
the unresolved workstreams. Add `--require-ready` only for future deploy gates
where pending admin review or policy input should fail the command.
`generated/source_mention_source_artifacts.json`,
`generated/source_mention_extracted_mentions.json`,
`generated/source_mention_resolution_candidates.json`,
`generated/source_mention_resolution_clusters.json`, and
`generated/source_mention_resolution_review_packets.json` are the private
source-mention resolution layer. They keep search results, editorial mentions,
platform event pages, and crawler output separate from canonical Firestore
documents. The resolver uses hard keys, bounded blocking keys, weighted
deterministic scorecards, and cluster review packets before anything can project
to `clubs/{clubId}`, read-only `externalEvents/{eventId}`, or future
`events/{eventId}` writes. These artifacts never publish a website page, write
Firestore, enable Catch booking, or import events by themselves.
`generated/source_mention_resolution_policy.json` is embedded in the admin
bridge and surfaced through the policy-gap review flow as
`source_mention_resolution_policy`. Admin/product review can accept, hold, or
reject the policy direction through the existing policy-gap callable/export
loop, but accepted policy still does not enable LLM calls or canonical writes
until the resolver config is explicitly encoded and checks pass.
`generated/source_mention_llm_prompt_queue.json` is the generated prompt
payload queue for ambiguous clusters. It is embedded in the admin bridge for
review and checked with the rest of organizer intake so prompt payload drift is
not hidden outside the main generation path.
`llm_source_resolution.mjs` prepares strict prompt payloads for ambiguous
clusters only. It refuses `--call-model` by design: future model calls must run
from an approved backend/tool runner with prompt hashing, cache reuse, JSON
schema validation, per-run request caps, and a monthly spend cap. The React
admin app must never call an LLM directly.
`generated/organizer_pending_input_request.json` is the read-only admin/product
input request derived from publication review packets, policy decision packets,
the operator action queue, and operational health. It is the artifact to hand to
the admin review UI or a human operator when deciding what input is still
needed: publication approval/hold/suppress choices, policy accept/hold/reject
choices, required acknowledgements, and blocked workflow follow-ups. Its safe
default is always to hold unresolved work; it never publishes a Host page,
indexes a route, writes Firestore, enables crawls, uploads artifacts, or imports
events. Each actionable request also carries a `callableSubmission` preview with
the callable name, admin API wrapper, Firestore decision collection, and
option-specific payloads for the admin bridge. `check_admin_review_bridge.mjs`
fails if those generated payloads drift from the required callable contract. Use
`pending_input_request.mjs --check` to validate counts, priorities, and callable
payloads, and
`pending_input_request.mjs --format markdown` to print the human review packet.
`generated/organizer_pending_work_coverage.json` cross-checks operational health
against the pending-input request. Every unresolved workstream must be covered
by either an admin/product input request or a workflow follow-up; otherwise the
coverage checker reports an untriaged implementation gap. This artifact is also
read-only and never resolves the blocker itself. Use
`pending_work_coverage.mjs --check --require-covered` before claiming the
remaining organizer work is only waiting on admin/product input.
`generated/organizer_pending_decision_answer_packet.json` is the read-only
answer template for those pending admin/product decisions. It converts pending
publication and policy requests into fillable answer slots with allowed
decisions, safe default payloads, required acknowledgements, blocking
workstreams, and dry-run local commands. It never records a decision, writes
Firestore, publishes or indexes a Host page, enables a crawl, uploads raw
artifacts, resolves locations, or imports events. Use
`pending_decision_answer_packet.mjs --check` to validate the template and
`pending_decision_answer_packet.mjs --format markdown` to print the compact
human answer sheet.
`create_decision_answer_packet.mjs` creates a reviewed copy under
`tool/organizer_intake/answer_packets/` with reviewer/date metadata already set.
Fill decisions only in that copied packet; the generated template should remain
machine-owned and unedited. The copy includes a source fingerprint, and
`apply_pending_decision_answers.mjs` refuses to apply it if the current
generated answer packet no longer matches, unless an operator passes the
explicit stale-source override after manual verification.
`reviewed_decision_answer_packets.mjs --check` scans every reviewed packet copy
and reports whether any packet is source-fresh, complete, and ready for the
guarded apply step.
`pending_decision_answer_plan.mjs --check` validates a copied and filled answer
packet, and `pending_decision_answer_plan.mjs --format markdown` prints the
exact local review-draft commands an operator can run next. The planner is
still dry-run by default: it does not record decisions, write Firestore, publish
Host pages, enable crawls, upload raw artifacts, resolve locations, or import
events. Use `--require-complete` only when the packet is expected to have every
admin and product answer filled.
`apply_pending_decision_answers.mjs` is the controlled local handoff from a
filled answer packet to repo-backed decision JSON. Without `--write`, it runs
the generated decision commands in dry-run mode only. With `--write`, it runs
every dry-run preflight first and then writes the local `review_decisions/` and
`policy_gap_decisions/` JSON files through the existing decision tools. It does
not write Firestore, publish routes, sync claim targets, enable crawls, resolve
locations, upload raw artifacts, or import events. Use `--allow-partial` only
when validating the current generated packet before every answer has been
filled; real application should use a complete copied packet.
`generated/organizer_promotion_execution_packet.json` is the read-only
post-approval execution preflight. It turns the current pending decisions,
workflow readiness, publication impact preview, projection plan, and
claim-target sync preview into ordered phases: review decisions, guarded
Firestore export, local promotion preview, promotion bridge validation,
website build, Firestore dry run, and guarded claim-target write. It never
exports decisions, builds the website, writes Firestore, deploys routes, or
syncs claim targets; it only proves which phase is ready, waiting, or disabled.
Use `promotion_execution_packet.mjs --check` to validate the packet and
`promotion_execution_packet.mjs --format markdown` to hand a release operator
the exact post-approval sequence.
`generated/organizer_policy_gap_register.json` is the product/ops decision
register for disabled-by-default layers. It names the inputs required before
recurring crawls, provider-backed location lookups, event imports, event
defaults, or naming migration can move beyond the current safe state. It does
not enable any of those behaviors.
`generated/organizer_policy_decision_packets.json` turns those gaps into
operator-facing decision packets. Each packet names the decision prompt, safe
default, unanswered required inputs, blocked artifacts, and implementation gate.
It is a question/decision artifact only; it never enables the reviewed behavior.
Manual policy gap decisions live under `policy_gap_decisions/`. They record a
review stance of `accept`, `hold`, or `reject` for a generated gap, but they do
not enable crawls, provider lookups, event writes, defaults, or naming changes
by themselves. Accepted decisions still require the approved policy to be
encoded in the specific repo-backed config or planner that owns the behavior.
Live admin policy-gap decisions are stored in Firestore at
`organizerPolicyGapReviewDecisions/{decisionId}`. The Firestore export command
reads those low-volume decisions and writes the repo-backed
`policy_gap_decisions/*.json` bridge only when `--write` is supplied. It never
enables the reviewed behavior.
`generated/external_event_import_execution_plan.json` is the execution preflight
for proposed event imports. It converts proposed import actions into
`createEvent` callable payloads, validates them against the generated schema
contract, and records blockers. It never invokes `createEvent`, writes
Firestore, creates schedule locks, or sends notifications.
`publish_event_supply_readiness.mjs` publishes the generated import plan and
execution preflight into `eventSupplyReadiness/current` so the live Events admin
tab can display the same deterministic blockers and commands. It is dry-run by
default, writes only that dashboard document when `--apply` is supplied, and
never imports events or writes `externalEvents/{id}`.
`generated/external_event_location_resolution_queue.json` is the queue of
external event candidates that cannot become app events because they lack exact
coordinates. It records deterministic resolution tasks and source location text
without calling Google Places or any geocoding provider.

`lib/platform_adapters.mjs` is the deterministic source boundary for external
URLs. It classifies Luma, Instagram, Partiful, District, BookMyShow, Sort My
Scene, LinkedIn, known press domains, and first-party-looking websites into
schema-shaped surfaces. It is intentionally conservative: event extraction is
modeled only as supported and remains disabled, while Instagram posts and press
articles do not mint strong identity dedupe keys.

`search_result_batches/` is the bridge from captured web/search results into
surface candidates. The ingest command normalizes every result URL, matches
existing organizer surface dedupe keys, and writes
`generated/search_result_candidate_queue.json` for admin or curation review.
Use `capture_search_results.mjs` before ingestion when a reviewed provider
payload needs to be converted into the canonical batch schema. The capture step
is dry-run by default and requires a host-discovery `runKey`, preserving exactly
which planned query produced the evidence.

`event_source_batches/` is the bridge from reviewed provider event payloads into
external event candidates. Use `capture_luma_events.mjs` for reviewed Luma JSON
or JSON-LD payloads, then run `ingest_event_sources.mjs` to write
`generated/external_event_candidate_queue.json`. These candidates are
blocked-by-policy review artifacts only: they do not crawl live pages, write
Firestore `events`, notify hosts, or imply that recurring imports are enabled.
Future platform adapters for Partiful, District, BookMyShow, and Sort My Scene
should emit the same event source batch format before any import planner runs.

`raw_artifacts/` is a local ignored holding area for high-volume crawl/search
payloads. Do not commit live crawl payloads and do not store them in Firestore.
Use `plan_raw_artifact_storage.mjs` to inventory local payloads and review their
future object-storage keys before any remote upload policy exists. Small,
reviewed, redacted replay fixtures can remain under `fixtures/`.

`generated/external_event_location_resolution_queue.json` identifies event
candidate locations that need exact coordinates before import can proceed. It is
queue-only: provider lookup is disabled, no external API call is made, and no
candidate is mutated. Manual or provider-backed resolution must write reviewed
coordinates back into a reviewed intake artifact before import planning is
allowed to become write-ready.

Manual event location resolution batches live under
`event_location_resolutions/`. They annotate external event candidates with
admin-reviewed exact coordinates and place metadata. Use
`event_location_resolution.mjs` for local drafts when the admin bridge is not
the source of the reviewed decision. The admin callable stores those decisions in
`organizerEventLocationResolutionDecisions/{resolutionId}`; the Firestore export
command reads them back into the repo-backed JSON bridge only when `--write` is
supplied. These batches do not enable provider lookup or event imports by
themselves.

```sh
node tool/organizer_intake/event_location_resolution.mjs draft \
  2026-06-17-afterfly-luma-events:pxgmph3b \
  --name "Nehru Stadium" \
  --address "Nehru Stadium, Indore, Madhya Pradesh" \
  --latitude 22.7196 \
  --longitude 75.8577 \
  --reviewer admin \
  --date 2026-06-17 \
  --note "Manual location QA complete." \
  --confirm-location-checklist
```

Manual event review batches live under `event_review_decisions/`. They annotate
external event candidates as `approve_for_import`, `hold`, or `reject` without
creating events. Even approved candidates keep `importState: blocked_by_policy`
until the product crawl/import policy is explicitly changed. Use
`event_review_decision.mjs` for local drafts:

```sh
node tool/organizer_intake/event_review_decision.mjs draft \
  2026-06-17-afterfly-luma-events:pxgmph3b \
  --decision approve_for_import \
  --reviewer admin \
  --date 2026-06-17 \
  --note "Manual event QA complete." \
  --confirm-import-checklist
```

`generated/external_event_import_plan.json` is the disabled-by-default bridge
from reviewed event candidates to proposed `events/{eventId}` writes. It
produces deterministic target event IDs, source provenance, proposed event
draft fields, and write blockers. It is intentionally a plan, not a mutation:
missing exact coordinates, capacity/default policy, owner-safe copy review, or
global import approval keep every action out of Firestore.

`generated/external_event_import_execution_plan.json` is the next no-write
guardrail. It checks whether each proposed create can be converted into a valid
`createEvent` callable payload. Payload validation failures are product/ops
work items, not runtime surprises: exact coordinates, capacity, pace,
event-default policy, and import authority must be resolved before a future
write-enabled importer can exist.

Manual curation batches live under `curation_decisions/`. They are applied
before dedupe, review, public projection, and claim-target artifacts are built.
Use them when search evidence reveals duplicate organizer entities, an external
surface belongs to the wrong organizer, or a surface needs a separate organizer
entity before publication can continue.

Reviewed search-result surfaces can be attached without hand-editing entity
batches:

```sh
node tool/organizer_intake/curation_decision.mjs draft attach_surface \
  --entity afterfly \
  --search-candidate 2026-06-17-afterfly-search-fixture:sort-my-scene \
  --reviewer admin \
  --date 2026-06-17 \
  --reason "Surface belongs to this organizer."
```

Attachment is still private curation. It does not publish a page, index a page,
make an organizer app-discoverable, or enable crawling.

Live admin curation operations are stored in Firestore at
`organizerIntakeCurationDecisions/{operationId}`. The Firestore curation export
command reads those low-volume operations and writes the repo-backed
`curation_decisions/*.json` bridge only when `--write` is supplied. Superseded
operations remain audited in Firestore but are excluded from the exported batch.

Live admin decisions are stored in Firestore at
`organizerIntakeReviewDecisions/{entityId}`. The Firestore export command reads
those low-volume admin decisions and writes the repo-backed
`review_decisions/*.json` bridge only when `--write` is supplied. It never
writes Firestore. Local approval drafts must pass the packet-aware
`review_decision.mjs` gate: `approve_public` requires
`--confirm-publication-checklist`, and packets with manual reports without
artifacts also require `--confirm-manual-reports-reviewed`. The main
`organizer_intake.mjs` generator independently reconstructs the pre-approval
publication packet state and rejects any exported `approve_public` decision
whose packet would still have data, evidence, or checklist blockers before the
approval. This prevents stale or bypassed Firestore decisions from projecting
public pages.

Live admin event-candidate decisions are stored in Firestore at
`organizerEventCandidateReviewDecisions/{decisionId}`. The Firestore event
review export command reads those low-volume decisions and writes the
repo-backed `event_review_decisions/*.json` bridge only when `--write` is
supplied. It never writes Firestore and it never imports events.

`check_admin_review_bridge.mjs` validates the admin-review bridge itself. It
fails if any review channel is missing its admin API wrapper, backend callable
export, contract schema, generated DTO/document, Firestore decision collection,
exporter, local decision folder, tool manifest entry, or promotion-pipeline
flag. It also validates that the generated pending-input, pending-work
coverage, and promotion-execution packets are embedded in
`admin/src/features/intake/organizer/generated/organizerIntakeBridge.json` and
rendered by the admin intake screen. Run it before website deploys, claim-target
syncs, or adding a new manual review channel.

Approved public projections also generate
`generated/organizer_claim_targets.json` and
`generated/organizer_claim_target_sync_preview.json`. Together they bridge
static website listings to the existing `requestClubClaim` flow: after
reviewing the durable preview and a live dry run,
`sync_claim_targets_to_firestore.mjs --write` creates missing
`clubs/{entityId}` claim targets or refreshes public fields on unclaimed/pending
targets. The sync skips claimed or owner-bound club documents.

Before deploying the website or applying claim-target writes, run
`check_admin_review_bridge.mjs` and `check_promotion_bridge.mjs`. The admin
bridge check verifies the review-write/export/generation wiring; the promotion
bridge check verifies that every approved organizer projection has one canonical
website listing, matching legacy path metadata, and a matching unclaimed
Firestore claim target. The website postbuild step then writes route HTML plus
`sitemap.xml` and `robots.txt`; only indexable routes are included in the
sitemap, while legacy paths and noindex directory/search pages stay excluded.

For the normal reviewed promotion pass, use
`run_promotion_pipeline.mjs`. Its default mode is local-only: it regenerates
search-result candidates, external event candidates, intake artifacts, and
website listings; validates the admin and promotion bridges; builds the
marketing website so route metadata/sitemap output is checked; and previews
claim-target sync against the empty fixture. Remote reads/writes require
explicit flags such as
`--apply-decision-answers --answer-packet PATH --write-decision-answers`,
`--export-curation-decisions --export-review-decisions --date YYYY-MM-DD`,
`--export-event-review-decisions`, `--export-event-location-resolutions`,
`--export-policy-gap-decisions`, `--claim-sync firestore`, and
`--write-claim-targets`. The local run always validates the promotion bridge
and website build output before any claim-target preview or write.
`--write-decision-answers` is local-only but still guarded: it requires an
explicit reviewed answer-packet path, runs every answer command as a dry-run
preflight first, and cannot be combined with remote review/policy export flags.
Reviewed answer packets also carry a source fingerprint; use
`--allow-stale-decision-answer-source` only when intentionally applying a
packet whose generated source has changed and the differences have been
manually reviewed.

`sync_claim_targets_to_firestore.mjs --receipt PATH` records the selected
project, exact claim-target plan SHA-256, remote-write count, and per-target
readiness actions. Website generation accepts only a Firestore-read receipt
whose project and plan hash match the current invocation; fixture receipts
cannot enable public claim submission.

## Promotion Rules

Under `organizer-intake-v1`, admin approval publishes and indexes the website
listing by default. That approval does not make the organizer app-discoverable;
app visibility stays hidden until the organizer is claimed or explicitly
approved for native discovery.
