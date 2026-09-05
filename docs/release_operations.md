---
doc_id: release_operations
version: 2.7.7
updated: 2026-09-05
owner: recursive_audit_loop
status: active
---

# Release Operations

## Local Firebase Safety

The checked `.firebaserc` default points to `catchdates-dev` as a local safety
net. Remote commands must still select `dev`, `staging`, or `prod` explicitly:

```sh
./tool/firebase_with_env.sh dev projects:list
npm --prefix functions run deploy -- staging
npm --prefix functions run logs -- prod --limit 50
```

Do not use bare `firebase deploy` or `firebase functions:log`. The Functions
package scripts route through the checked wrapper and reject a missing or
unknown environment. Hosting targets are intentionally mapped only for the
production project. A development or staging `hosting:<target>` deployment
therefore fails until that target is explicitly created and mapped; do not
work around that failure by falling back to production.

Flutter, Node, Java, Firebase CLI, CocoaPods, the GitHub-hosted Apple runner,
and the minimum Xcode version are owned together in `tool/ci/toolchain.env`.
GitHub Actions and Xcode Cloud read that contract;
`bash tool/ci/check_toolchain_consistency.sh` fails when a required pin, the
Functions Node engine, or an Apple-native workflow runner drifts. Keep the
Apple runner major aligned with the minimum Xcode major. `connectivity_plus`
7.x requires Xcode 26.1.1 or newer, so the native build, release, and hosted
visual-smoke workflows use `macos-26`.

## Deployment Image Retention and Cost Alerts

`tool/firebase/artifact_registry_cleanup_policy.json` owns the seven-day
Artifact Registry policy for `gcf-artifacts` in `asia-south1` and `us-central1`
for dev, staging, and production. Apply the same checked policy explicitly to
each repository and read it back:

```sh
gcloud artifacts repositories set-cleanup-policies gcf-artifacts \
  --project <project-id> --location <region> \
  --policy tool/firebase/artifact_registry_cleanup_policy.json --no-dry-run
gcloud artifacts repositories describe gcf-artifacts \
  --project <project-id> --location <region> --format=json
```

The policy expires tagged and untagged build images after seven days. There is
no keep-count exception that can retain old images indefinitely. Firebase keeps
the deployed runtime separately; these build images are not user uploads or
application data. Artifact Registry executes cleanup asynchronously, and storage
reclamation can lag version deletion. The immutable source-bound GitHub delivery
packages retain their separate 90-day recovery window.

The combined `Catch pre-launch` billing budget is ₹400 per calendar month,
scoped to the three Catch projects, with actual-spend alerts at 50%, 80%, and
100% plus a forecast alert at 100%. Budgets send alerts; they do not cap spending.
Keep unrelated project budgets separate. Attribute changes by project and SKU
before removing resources or claiming savings from the invoice.

## Firebase Environment Readiness

The reusable backend Firebase promotion workflow installs its pinned source
parser without lifecycle scripts and verifies affected targets before cloud
authentication. The target-aware metadata preflight then runs after OIDC
authentication and before Functions runtime dependency installation, Firebase
CLI installation, or any backend mutation.
Hosting and explicit Remote Config/Extensions operations have separate owners:

```sh
node tool/firebase/check_environment_readiness.mjs --manifest-only
node tool/firebase/check_environment_readiness.mjs \
  --env dev \
  --targets firestore:indexes,functions,firestore:rules,storage
```

`tool/firebase/environment_readiness.json` is the source of truth for enabled
Secret Manager versions and Firestore TTL policies required by deploy targets.
The offline mode reconciles every literal Functions `defineSecret` declaration,
exported Function target, and owning source path. The live mode resolves project
ids only from `.firebaserc` and permits three metadata-only `gcloud` command
families: project describe, secret-version list, and Firestore TTL list. It has
no apply mode and never accesses or prints secret payloads.

Confirmed missing state exits `1`; authentication, authorization, unavailable
tooling, or malformed metadata exits `2`; invalid invocation exits `64`. All
non-zero results block deployment. Add a requirement in the same change that
introduces a new `defineSecret`, TTL-dependent capability, or deploy-time
project prerequisite. A missing prerequisite must fail before Functions runtime
dependency installation; do not move this gate into Firebase predeploy hooks.

## Firebase Functions Deployment Parity

Repository checks prove the authored Functions package, not what a Firebase
project currently exposes. After every Functions deployment, the safe deploy
wrapper compares the live inventory with the deployment-eligible exports
derived from `functions/src/index.ts` and confirms that every literal
`defineSecret()` name exists in the selected project:

```sh
node tool/firebase/check_deploy_parity.mjs --env staging
node tool/firebase/check_deploy_parity.mjs --env prod --json
```

Missing deployment-eligible exports or declared secret names fail the
deployment. Environment-only Functions are counted but ignored because
installed Firebase Extensions legitimately own exports that are absent from
this repository. The check uses only `firebase functions:list` and Secret
Manager resource-name metadata; it never requests a secret version or payload.
Authentication, authorization, tooling, and malformed-metadata failures fail
closed.

### Dormant scheduled Functions

Catch's bounded deployment policy in
`tool/firebase/list_firebase_function_targets.mjs` keeps the following recurring
Functions implemented and testable but excludes them from logical and exact
Function deployment plans:

- `dispatchPendingOrganizerFollowerUpdates`
- `dispatchScheduledOrganizerCampaigns`
- `expireCrossPathsInvitations`
- `expireCrossPathsPairHolds`
- `expireEventRehearsals`
- `expireEventWaitlistOffers`
- `reconcileRazorpayOrders`
- `sendEventReminders`

They were undeployed from dev, staging, and production on 2026-09-02 after live
queries found no pending campaigns, delivery operations, rehearsal sessions,
payment reconciliation, waitlist offers, invitations, pair holds, or future
active events. Re-enabling one is a deliberate source-policy change: prove the
corresponding live workload, define its environment scope and monthly budget,
run its focused Functions tests, deploy dev then staging then production, and
verify both the Function and Scheduler job after each environment. Do not use a
bare Firebase CLI deployment to bypass this gate.

Delivery can still encounter an immutable CI package created before a Function
became dormant. Package verification accepts only one of two exact target sets:
all exports recorded by that historical source, or the same exports reduced by
the current dormant policy. It then returns the reduced set for readiness and
the current executor excludes the named dormant targets before batching;
promotion may further narrow that authorized set using verified source dependencies.
Every other missing, added, or unknown exact Function target remains a hard
failure. This lets the queue drain without rebuilding an old artifact or
recreating recurring infrastructure.

## Firebase Rules Deployment Drift

Emulator tests prove the checked-out Firestore and Storage rules, not the rules
currently enforced by a Firebase project. Compare the active releases with an
explicit environment or project:

```sh
node tool/run.mjs check firebase:rules-deployment-drift
node tool/firebase/check_rules_deployment_drift.mjs --env staging
node tool/firebase/check_rules_deployment_drift.mjs --env prod
```

The check lists active Rules releases, fetches their immutable ruleset source,
and compares `firestore.rules` plus every active bucket release using a
normalized SHA-256. Normalization removes a UTF-8 BOM, line-ending differences,
trailing horizontal whitespace, and extra final blank lines. It deliberately
does not discard comments or parse and rewrite the Rules language: a transparent
content comparison is deterministic, while a home-grown semantic parser could
hide a meaningful source change.

Authentication uses `FIREBASE_RULES_ACCESS_TOKEN`,
`GOOGLE_OAUTH_ACCESS_TOKEN`, or an authenticated `gcloud` session. A machine
with no credentials prints a clear skip and exits zero so untrusted CI remains
usable. Once credentials exist, API/authorization errors, missing releases, and
content drift fail. The authenticated backend promotion runs the same check
against the exact CI-approved source after its ordered deploy stages, with a
bounded retry window for Rules release propagation.

## Storage Rules Cross-Service Readiness

Storage rules that use `firestore.get()` or `firestore.exists()` need one
project-level dependency outside the ruleset: the Firebase Storage service
agent must hold `roles/firebaserules.firestoreServiceAgent`. The required
member is derived from each checked Firebase project number:

```text
service-{projectNumber}@gcp-sa-firebasestorage.iam.gserviceaccount.com
```

Check all environments before a Storage deploy. Check mode is read-only and
fails if any binding is absent:

```sh
node tool/firebase/storage_rules_firestore_iam.mjs --all
```

Provision only missing bindings after reviewing the output. Production apply
is intentionally double-guarded:

```sh
node tool/firebase/storage_rules_firestore_iam.mjs \
  --all --apply --allow-prod
```

`tool/deploy_firebase_targets.sh` runs the single-environment check before its
Storage phase, so a ruleset cannot deploy while its cross-service dependency is
known missing. The deploy identity needs `resourcemanager.projects.getIamPolicy`
for that preflight; it does not need permission to change IAM. Owner-operated
apply preserves the policy etag, conditions, unrelated roles, and members.

Emulator rules tests do not prove deployed IAM, App Check, or production
cross-service access-call limits. After rules or this binding changes, run the
authenticated upload/delete canary with an existing active participant and
match. App Check is enforced, so provide a registered environment-owned debug
token without placing it on the command line:

```sh
export FIREBASE_STORAGE_CANARY_APPCHECK_DEBUG_TOKEN='...'
node tool/firebase/probe_chat_storage_rules.mjs \
  --env dev --uid <uid> --match-id <active-match> --apply
node tool/firebase/probe_chat_storage_rules.mjs \
  --env prod --uid <uid> --match-id <active-match> --apply --allow-prod
```

The probe uploads one fixed 1x1 PNG through Firebase Auth and App Check, then
deletes it through the same client rules. It never prints credentials. Chat
image rules use the canonical match document for participant/status checks so
one evaluation stays under Storage Rules' Firestore document-access limit;
blocking projects that match to `status: blocked`. Creates require immutable
`uploaderUid` custom metadata, updates are denied, and only that uploader may
perform compensating deletion. Do not replace this with a blanket signed-in
write rule.

This is the durable owner for CI gates, Firebase deployment ordering, and
release-readiness evidence. It replaces dated one-off runbooks and should stay
short enough to be read before a deploy.

## Native Splash Assets

The native splash is generated from the `flutter_native_splash:` block in
`pubspec.yaml`; edit that config and run `dart run flutter_native_splash:create`
instead of hand-editing platform drawables/storyboards. Before regenerating,
verify the configured splash image is a transparent mark that composites cleanly
on both `#F4F4F1` and `#0F0E10`; a baked app-icon tile is not an acceptable
native splash image. The native splash mark is generated as transparent output
by `tool/branding/generate_catch_icon.swift` and is a separate asset from the
opaque launcher icon; edit the generator and `pubspec.yaml`, then re-run the
Swift generator and `flutter_native_splash:create`. Finally run
`dart run tool/branding/generate_native_brand_assets.dart`: it reapplies the
Consumer-only iOS responsive launch constraints that align `Catch_` with the
Welcome reel and reapplies the Host-specific centered `Catch Host` launch
storyboard/assets on the installable Host target. Never hand-edit those
generated storyboards or platform drawables. The Host static mark uses Archivo
at explicit `wght: 600` / `wdth: 78`, then hands directly to Host auth/home
routing without a Welcome reel.

## Required PR Checks

Configure GitHub branch protection for `main` to require the single stable
`CI / Required CI` result. That aggregate always exists for pull requests,
pushes, and merge queues. It fails when planning fails or any selected lane
fails; unaffected lanes are explicit skips, so path scoping never leaves a
required check permanently pending.

`.github/workflows/ci.yml` is the orchestration owner. Its planner reads
`tool/harness/component_graph.json`, fails closed for an unmapped or ambiguous
path, and invokes reusable validation workflows only for affected targets.
Pull requests, merge queues, main pushes, and nightly full validation use the
explicit `pr`, `merge_group`, `main`, and `nightly` graph modes respectively.
Changes to the shared Harness control plane intentionally run every declared
target. The graph explicitly owns backend-only Delivery, staging, rebaseline,
package-verifier and source-review files: those changes run Functions,
contracts, rules, policy and the affected Tools check closure without compiling
unrelated clients. The tool planner honors the graph's terminal classifications
and includes every declared check plus its transitive dependencies; it does not
reapply a broader workflow glob or drop graph-required checks. Shared CI
orchestration, toolchains, the cross-product delivery core,
unknown files and actual app changes retain their broader validation. A nightly
scheduled full run catches drift hidden by ordinary impact routing.
Dedicated validation-workflow edits run their own lane plus policy validation.
The policy lane runs the existing `agent:harness-v2` wiring suite when Tools is
absent, with the pinned Node version and only root npm dependencies. When Tools
is selected alongside a workflow change, its check closure owns that suite;
ordinary prose keeps its lightweight document checks.
Only direct component ownership may authorize Firebase deployment or a mobile
release; dependency expansion can add validation but cannot authorize mutation.

Root Flutter unit/widget tests are selected by
`tool/harness/lib/flutter_test_selection.dart` from the exact base and head Git
objects. Dart's parser follows imports, exports, conditional imports and parts
in both snapshots, so deleted or moved dependencies remain covered. Tests that
inspect files through `dart:io` remain selected. Mixed ordinary Markdown changes
retain source selection only when both committed component graphs classify the
prose as documentation-only and neither snapshot's package manifests could bundle
it as an asset. Markdown in test or asset directories is never exempt. Assets,
dependency manifests, test configuration, other non-Dart changes, unsupported
inputs, and changes with no provable dependent test retain the full suite.
Scheduled and manual CI resolve their base revision to an exact commit before
binding any lane inputs or artifacts. Nightly and explicit full runs
also execute every test. Native, package, golden, integration, analyzer and
contract checks retain their separate owners.

The same planner follows the lint engine's seeded and generated probe imports.
The expensive Catch UI plugin smoke check runs when its engine, configuration,
corpus or transitive probe APIs change, and on full runs. When the actual Tools
plan already selects that registered check, Flutter consumes the same CI run's
required Tools result and omits its duplicate invocation. Standalone Flutter
runs retain their own engine check. The engine stages its existing fixture
libraries together and supplies every exact file to one analyzer process.
Positive and negative assertions remain per-file; plugin failure, missing
fixtures or malformed diagnostics fail the run. The application analyzer and zero-diagnostic
gate still run on every selected Flutter lane. The workspace analyzer saves its
root diagnostics once; the lint gate and report reuse that output instead of
launching a second root analysis.
Selector safety tests run before any selective job can proceed; planner failure
fails the aggregate. The selected inventory and reasons are CI artifacts, not
a tracked registry.

Each selected test shard collects line coverage during its single test run.
The coverage job requires all planned shard artifacts and merges their observed
lines without rerunning tests or counting shared source files twice. Coverage
is visibility-only; compare nightly reports for full-suite trends. A shard
containing only repository probes can legitimately observe no product lines.
The matrix contains at most four nonempty shards and the required aggregate
rejects missing planner, test or coverage results.

The orchestrator also owns cancellation. Reusable fanout workflows must not
derive a concurrency group from `github.workflow`: inside a called workflow
that value is the caller name, so sibling lanes would share one key and cancel
one another. Standalone/manual workflow dispatches may add a distinct
workflow-specific key, but normal CI fanout inherits the orchestrator boundary.

Local `node tool/harness/verify_local.mjs --base origin/main --list` resolves
Tools checks through the same affected-tool planner and registered runner as CI,
including full fallback. Literal package working directories are preserved;
commands with unresolved environment or Actions context remain explicit gaps.
Each Tools category bucket uses one runner invocation, so identical registered
commands execute once across its categories in their declared order. Repeated
`--category` arguments retain that behavior locally; every category must exist
before any check executes. Local checks
stop on shell pipeline failures and incomplete ownership cannot report success.

When the actual CI plan selects Marketing, Tools reuses that same run's required
React marketing accessibility and screenshot comparisons. It omits only the
two exact registered browser commands; syntax, configuration and scanner
self-tests still execute. The required aggregate owns both lanes, so a failed
or cancelled React check still blocks CI. Reusable and standalone Tools runs
default to executing their own browser checks. No result crosses source commits
or CI attempts, and altered commands lose the omission until their equivalence
is verified again.

The complete impact plan is written to `build/ci/impact-plan.json` and rendered
from that file. Only bounded booleans and role arrays cross the GitHub step/job
output boundary, alongside bounded test-shard descriptors. Do not expand the
per-file plan into an environment variable:
large pull requests can exceed the operating system argument limit before the
summary shell even starts.

Generated Dart bindings under `lib/core/schema_contracts/generated/**` are
validation inputs, not mobile-release authorization. They run the Flutter
analysis/test lane but do not select iOS, Android, web artifact builds, or a
Consumer/Host internal release on their own. A mobile release requires an
owning runtime-source, native-platform, asset/dependency, or mobile-build-control
change. This keeps backend/admin contract generation from producing signed app
artifacts while still detecting stale or invalid Dart bindings.

Backend validation and backend deployment are also separate decisions.
CI-control changes intentionally validate Functions, contracts, and rules, but
they do not authorize a Firebase mutation. Only directly owned Functions,
rules, index, or Storage-rules sources may emit their bounded deploy group;
contract and Firebase configuration changes alone never grant mutation. After
every selected validation lane passes, CI packages those explicit groups once,
and Delivery promotes that exact SHA-, run-attempt-, and checksum-bound package
instead of inferring deployment from validation lanes or rebuilding it.
The Delivery workflow and its deploy helpers execute from the immutable
`github.workflow_sha` control-plane commit. The older CI-approved source is
checked out separately and is used only to verify the package's source-bound
exports and configuration. Recovery therefore keeps the application payload
byte-identical while still receiving reviewed fixes to the delivery machinery;
checking out an old application commit must never reactivate its obsolete CI
or deploy helpers.

The app package-graph gate must also work in a clean checkout before
`flutter pub get`. It validates governed native-package declarations directly
from each app package and enriches the report with Flutter-generated plugin
metadata when available. Release receipt checks remain the authoritative proof
that forbidden native frameworks are absent from the compiled Host payload.

The current workflows are:

| Workflow | Purpose |
|---|---|
| `.github/workflows/ci.yml` | Always-running impact planner, reusable-workflow fanout, scheduled full matrix, and stable required aggregate. |
| `.github/workflows/flutter-ci.yml` | Reusable design parity, exhaustive root-and-nested-package analysis, fail-closed unit/widget test selection, and UI lint smoke checks. |
| `.github/workflows/functions-ci.yml` | Functions lint/test plus Firestore contract check on Node 24. |
| `.github/workflows/firestore-rules-ci.yml` | Firestore contract check plus emulator-backed rules tests. |
| `.github/workflows/contracts-ci.yml` | Validates the `contracts/` schema source of truth: source validity, generated-output freshness, schema/type boundaries, path literals, and rules semantics. |
| `.github/workflows/operations-ci.yml` | Reusable Operations platform contracts, tests, boundaries, and CLI smoke lane, selected independently from general repository tooling. |
| `.github/workflows/app-build-matrix.yml` | Reusable role/platform-selective dev web, Android debug APK, and parallel per-role iOS simulator build gates. Cheap app-structure ratchets run before any expensive compile. |
| `.github/workflows/delivery.yml` | Ordered backend delivery entrypoint. Authorizes a successful same-repository `main` CI run and promotes its exact package through dev and policy-selected production. |
| `.github/workflows/_firebase-promote.yml` | Reusable environment adapter that verifies provenance before authentication, resumes ordered stages, and waits for deployed Firestore indexes to become ready before dependent stages continue. |
| `.github/workflows/data-validation.yml` | Read-only Firestore data validation, nightly and manual. |
| `.github/workflows/_web-hosting-build.yml` | Builds one production Admin or Marketing Vite bundle or standalone Host Flutter web bundle, packages one lifecycle-hook-free Hosting target, and publishes workflow/run/source-bound bytes with an exact file inventory. |
| `.github/workflows/_web-hosting-promote.yml` | Downloads one Hosting artifact by immutable id, installs the pinned Firebase CLI before credentials, verifies the GitHub digest and every packaged byte, then promotes without installing source dependencies, rebuilding frontend bytes, or rematerializing organizer data. |
| `.github/workflows/marketing-website.yml` | Validates marketing source and Storybook accessibility, calls the exact build/promote adapters on matching `main` pushes, then requires production 404 and launch-route postconditions. |
| `.github/workflows/admin-website.yml` | Validates Admin source and live callable dependencies, then calls the exact build/promote adapters for the production `admin` target. |
| `.github/workflows/host-website.yml` | Validates the Host target, standalone roster tests, and Host-owned Flutter surfaces, then builds and promotes the independent production `host` target. |
| `.github/workflows/release-readiness.yml` | Manual staging/prod release gate. |
| `.github/workflows/mobile-internal-release.yml` | Signed package matrix and automatic iOS handoff. It consumes a successful `main` CI authority, builds only exact role/platform targets, publishes 90-day IPA/AAB packages plus a post-comparison build authority, and dispatches one exact promoter for every authorized iOS target without mutating either store itself. |
| `.github/workflows/mobile-internal-promote.yml` | Exact-artifact promoter. Automatic iOS dispatches and manual recovery dispatches both verify the current producer and authority/package ids, digests, provenance, and target before uploading the already-signed IPA to TestFlight or AAB to Play `qa`; it never rebuilds or resigns. After an iOS upload claim is durable, it grants the VALID build to existing internal groups that already contain testers. |
| `.github/workflows/observability-evidence.yml` | Manual Crashlytics and Analytics evidence capture. |
| `.github/workflows/website-production-observability.yml` | Scheduled and manual production website status, canonical-metadata, and launch-content probes. |
| `.github/workflows/branch-hygiene.yml` | Daily semantic branch audit, supervised integrated-ref candidates, and an issue plus failed run for stale code outside `main` without an open PR. |

The Host Website push filter follows its production byte closure explicitly:
Host/runtime source, declared assets and fixtures, production Host Firebase
configuration, the app-target resolver, and the environment wrappers. It must
not use `tool/platform/**`; validator-only and external-store-status changes
belong to CI and must not rebuild or deploy production Hosting.
No production Hosting caller may list `*.test.mjs` in its push filter. Test
changes are validated by CI; they do not alter deployable bytes and therefore
cannot authorize an Admin, Marketing, or Host production promotion.

### Dependency maintenance

GitHub-native Dependabot is the sole routine dependency-update service. It
checks npm, Pub, and GitHub Actions each Wednesday, groups compatible minor and
patch updates into at most one open pull request per ecosystem, and keeps
security updates grouped separately. Major versions are deliberately excluded:
each major upgrade needs its own impact review and full selected CI evidence.

The 2026-08-10 Pub baseline upgraded every release resolvable under the current
constraints: 74 packages (33 in the Firebase family and 41 in the remaining
Flutter/tooling family). `flutter pub outdated --json` then reported zero
upgradeable packages, zero advisory-affected packages, zero discontinued
packages, and 38 packages blocked by coordinated constraints or major-version
boundaries. Do not describe the `flutter pub get` summary as 38 independent
patches.

iOS remains on CocoaPods, not Swift Package Manager. The current
`razorpay_flutter`, `health`, and `google_maps_flutter_ios` plugin graph still
reports missing SPM support, and the FirebaseFirestore prebuilt-pod graph has a
separate duplicate-symbol boundary. Remove `enable-swift-package-manager:
false` only in a dedicated migration after both conditions are resolved and
Consumer plus Host iOS builds pass together.

`tool/app_targets.json#appleNativeDependencies` binds the checked-in
`firebase_core` and `cloud_firestore` Flutter versions to the Firebase Apple SDK
used by all four iOS/macOS Podfiles and lockfiles. The app-target structural
gate fails before native compilation when a compatible Pub update changes one
side without regenerating the CocoaPods graphs.

## Git Branch Hygiene

Treat PR branches as single-use. After a PR branch is merged into `main`, do
not keep committing to that same branch for the next slice of work. GitHub adds
a merge commit to `main`, and a reused branch can look locally ahead while still
missing the new `origin/main` merge commit. That produces repeat PR conflicts
and huge compare diffs.

Before staging or opening a PR:

1. Run `git fetch origin main`.
2. Check `git rev-list --left-right --count origin/main...HEAD`.
3. If the first number is not `0`, the current branch is behind `origin/main`;
   start a fresh `codex/<task>` branch from `origin/main` or rebase before new
   work.
4. If the branch already has a merged or conflicted PR, prefer a fresh branch
   from `origin/main` and cherry-pick only the still-needed commits.

Do not trust stale local `main` for this check. Use `origin/main` as the source
of truth, and close any superseded conflicted PR after the replacement branch is
published.

Push a new branch as soon as it is created; local-only branches and stashes are
not preservation. Before a rebase, reset, amend, or conflict-heavy merge, create
and push a dated `backup/` ref. Do not rewrite a branch with a shared upstream.
For reconciliation merges touching more than 50 paths, run
`node tool/git/audit_merge_drops.mjs` with the base, both sides, and merged result
and require explicit discard receipts. After a squash merge is verified on
`origin/main`, delete the single-use branch and prune tracking refs.

### Daily orphan-branch detection

GitHub's repository-level delete-after-merge setting is enabled, but it only
removes the exact PR head. `.github/workflows/branch-hygiene.yml` evaluates the
remaining gap every day. It fetches all refs, reads current PR state, and uses
`git:branch-hygiene` to report strong semantic proofs: the tip is an ancestor of
`main`, its exact tree exists in `main` history, its exact tip belongs to a
merged PR whose merge is in `main`, or every path changed by the branch has the
same final Git identity in `main`. Open-PR branches and unique-looking branches
never become cleanup candidates.

A branch gets seven days to acquire a PR or integration proof. After that, the
workflow updates one GitHub issue, uploads the complete audit as an expiring
artifact, and fails. The workflow has read-only repository contents permission;
candidate deletion remains a supervised operation. This is the deployment-loss
alarm: routine CI proves code on `main`, while branch hygiene proves that old
code is not silently living only on a forgotten ref.

```sh
node tool/git/branch_hygiene.mjs --base origin/main --remote origin --json
node tool/git/branch_hygiene.mjs --base origin/main --local --json
```

## GitHub Environments And Auth

Firebase deploy and data-validation workflows use GitHub OIDC rather than
long-lived service-account JSON secrets. Use GitHub Environments named `dev`,
`staging`, `prod-hosting`, `prod-mobile`, `backend-review`, `prod-backend`, and `prod`. `prod-hosting` is
approval-free and limited to the automatic marketing and admin Firebase
Hosting workflows. `prod-mobile` is approval-free and `main`-only; it contains
only mobile signing, Maps, App Store Connect, and Play-publisher credentials.
The producer has a matching fail-closed ref guard. Store mutation is isolated in
the exact promoter, whose four role/platform targets each have their own bounded
non-cancelling queue. Every authorized iOS target is dispatched automatically;
manual dispatch remains a recovery surface. `prod-backend` is main-only and
accepts only the reusable Firebase promoter called by the automatic Delivery
workflow. Its OIDC provider binds repository, ref, environment, caller workflow,
reusable workflow, and automatic event type. It reuses the existing deployment
identity; it does not add project permissions. That identity's federation grant
is restricted to the exact `prod`, `prod-hosting`, and `prod-backend` subjects,
replacing its former repository-wide grant. The older production provider
accepts only main jobs in `prod`, `prod-hosting`, or `prod-mobile`.

Keep required reviewers on shared `prod` for production data operations,
non-Functions stages, snapshots, recovery, and older source without review proof.
Same-repository pull requests whose plan selects Functions require the
credential-free `backend-review` environment after selected validation passes.
Its reviewer explicitly reviews the whole backend change, including permissions,
secrets, migrations, initialization and trigger settings, before merge. Required
CI includes this gate. A new PR head requires a new reviewed CI run.

For Functions-only packages, `tool/ci/backend_source_review.mjs` verifies the
merged PR, successful pre-merge CI, required-reviewer approval history, completed
review job, and equality of the reviewed PR tree with the exact packaged source
tree. Delivery and the promoter independently repeat this read-only verification
before authentication. Evidence that is missing, expired, unavailable or bound
to different source retains `prod` review. Source pattern matching cannot prove
that business logic is free of permission changes and is not used as approval.
Verified Functions no-ops need no runtime approval. `backend-review` has no
secrets, variables or cloud federation, allows the sole maintainer to review
self-authored PRs, restricts branches to `refs/pull/*/merge`, and forbids
administrator bypass. Its approval is recorded by
GitHub, not a checked-in receipt. Reviewing before merge keeps human waiting time
outside the shared deployment queue; after dev succeeds, reviewed Functions-only
source uses `prod-backend` automatically.
Both production paths keep the same `firebase-prod` lock and delivery cursor;
automation never skips an older package or deploys production before dev succeeds.

During cutover, reviewer-protected `prod` may still hold duplicate mobile
secrets as rollback material. The mobile workflow does not read them. Delete
those duplicates only after both GitHub iOS lanes process and both signed
Android lanes pass from `prod-mobile`.

Each Firebase deployment environment must define these variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

The corresponding Google Cloud service accounts are:

- `github-actions-deploy@catchdates-dev.iam.gserviceaccount.com`
- `github-actions-deploy@catchdates-staging.iam.gserviceaccount.com`
- `github-actions-deploy@catch-dating-app-64e51.iam.gserviceaccount.com`

Do not add `FIREBASE_SERVICE_ACCOUNT_*` JSON secrets unless the OIDC setup is
intentionally retired.

### Read-only Marketing snapshot identity

Marketing production packaging reads two bounded organizer-listing JSON inputs
from production Firestore before the Vite build. That read is intentionally
separate from both the uncredentialed build job and the Hosting deploy identity.
Target state: the `prod-hosting` environment must define:

- `GCP_WEB_HOSTING_READONLY_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_WEB_HOSTING_READONLY_SERVICE_ACCOUNT_EMAIL`

The production values are the existing provider
`projects/574779808785/locations/global/workloadIdentityPools/github-actions/providers/catch-dating-app`
and the dedicated service account
`github-actions-web-reader@catch-dating-app-64e51.iam.gserviceaccount.com`.
The service account's only project role must be `roles/datastore.viewer`; do not
grant it Hosting, Functions, Rules, Storage, Secret Manager, or Firestore write
authority. Its impersonation policy must be narrower than the shared provider:
only the current GitHub OIDC subject
`repo:suvratgarg/catch-dating-app:environment:prod-hosting` may use it.

Live state verified on 2026-08-08: the dedicated service account has only
`roles/datastore.viewer`, has no user-managed keys, and its sole impersonation
binding is the exact `prod-hosting` environment subject above. Both GitHub
Environment variables are present with the expected provider and service
account values. The first main proof completed successfully in Marketing run
`31254427583`: the environment-scoped job authenticated, materialized the two
bounded Firestore listing inputs, removed its credentials, and handed only the
snapshot artifact to the uncredentialed build job.

Provision and reproduce that boundary with:

```sh
gcloud iam service-accounts create github-actions-web-reader \
  --project=catch-dating-app-64e51 \
  --display-name='GitHub Actions Web Hosting Read-Only Snapshot' \
  --description='Read-only Firestore materialization for prod-hosting web builds'

gcloud projects add-iam-policy-binding catch-dating-app-64e51 \
  --member='serviceAccount:github-actions-web-reader@catch-dating-app-64e51.iam.gserviceaccount.com' \
  --role='roles/datastore.viewer' \
  --condition=None

gcloud iam service-accounts add-iam-policy-binding \
  github-actions-web-reader@catch-dating-app-64e51.iam.gserviceaccount.com \
  --project=catch-dating-app-64e51 \
  --role='roles/iam.workloadIdentityUser' \
  --member='principal://iam.googleapis.com/projects/574779808785/locations/global/workloadIdentityPools/github-actions/subject/repo:suvratgarg/catch-dating-app:environment:prod-hosting'

gh variable set GCP_WEB_HOSTING_READONLY_WORKLOAD_IDENTITY_PROVIDER \
  --repo suvratgarg/catch-dating-app \
  --env prod-hosting \
  --body 'projects/574779808785/locations/global/workloadIdentityPools/github-actions/providers/catch-dating-app'

gh variable set GCP_WEB_HOSTING_READONLY_SERVICE_ACCOUNT_EMAIL \
  --repo suvratgarg/catch-dating-app \
  --env prod-hosting \
  --body 'github-actions-web-reader@catch-dating-app-64e51.iam.gserviceaccount.com'
```

Before merging a workflow that requires this identity, verify the service
account's project roles, its exact impersonation principal, and both GitHub
environment variables. A repository-wide `attribute.repository` principal is
not an acceptable substitute for the environment-scoped subject.

## Public Provider IDs and Server-Side Search Secrets

`ALGOLIA_APPLICATION_ID` and `RAZORPAY_PUBLIC_KEY_ID` identify the provider
account; they are plain Firebase `defineString` parameters. Store them as
GitHub environment variables for `dev`, `staging`, `prod`, and `prod-backend`
(the last two use the same production values). The backend workflow writes
validated values into the disposable Functions `.env.<project-id>` before
Firebase discovers its parameters. Missing or invalid IDs fail deployment.

The parameter names deliberately differ from the older `ALGOLIA_APP_ID` and
`RAZORPAY_KEY_ID` SecretParams, allowing historical immutable packages to run
without an environment-variable/secret-name collision. Keep those legacy
Secret Manager versions until the historical queue and replacement runtime
verification are complete; switching source declarations alone does not retire
live secret versions or their charges.

For an explicit local deployment, provide the same environment's public IDs
to `tool/firebase/prepare_functions_params_for_deploy.mjs --functions-dir
functions --project <project-id>`, then use the environment wrapper. Its output
file is ignored and permission-restricted. Never put a search, write, payment,
or webhook credential in this file.

Explore search keeps `ALGOLIA_SEARCH_API_KEY` and `ALGOLIA_WRITE_API_KEY` in
Firebase Secret Manager. Use one Algolia application per Firebase environment
so data, analytics, write keys, and emergency rotations stay isolated:

| Firebase project | Algolia app |
|---|---|
| `catchdates-dev` | `Catch Dev` |
| `catchdates-staging` | `Catch Staging` |
| `catch-dating-app-64e51` | `Catch Prod` |

Use a search-only key for runtime search and a write-capable key for index
triggers and backfills. Rotate one environment at a time, selecting that
project's matching keys. Do not loop over all projects with one account's key
material:

```sh
search_project=catchdates-dev
printf "Algolia search-only API key: "
stty -echo
IFS= read -r ALGOLIA_SEARCH_API_KEY
stty echo
printf "\nAlgolia write API key: "
stty -echo
IFS= read -r ALGOLIA_WRITE_API_KEY
stty echo
printf "\n"
printf "%s" "$ALGOLIA_SEARCH_API_KEY" |
  firebase functions:secrets:set ALGOLIA_SEARCH_API_KEY \
    --project "$search_project" --data-file -
printf "%s" "$ALGOLIA_WRITE_API_KEY" |
  firebase functions:secrets:set ALGOLIA_WRITE_API_KEY \
    --project "$search_project" --data-file -
unset ALGOLIA_SEARCH_API_KEY ALGOLIA_WRITE_API_KEY
firebase functions:secrets:get ALGOLIA_SEARCH_API_KEY --project "$search_project"
firebase functions:secrets:get ALGOLIA_WRITE_API_KEY --project "$search_project"
```

Index names default to `organizers` and `events`. Only override them with
`ALGOLIA_ORGANIZERS_INDEX` or `ALGOLIA_EVENTS_INDEX` if an environment needs
different index names. `ALGOLIA_CLUBS_INDEX` is a temporary compatibility
fallback and must not be used in new environment configuration. These are not
secrets.

Backfill after first setup or after changing searchable data shape:

```sh
ALGOLIA_APP_ID="<env app id>" \
ALGOLIA_WRITE_API_KEY="<env write key>" \
node tool/data/backfill_algolia_explore_search.mjs \
  --env prod \
  --apply \
  --allow-prod
```

For dev or staging, change `--env` and omit `--allow-prod`.

Algolia index settings must allow the function filters:

- Organizers index: make `location` filterable/facetable.
- Events index: make `discoveryCityName` filterable/facetable and store
  `startTimeEpoch` as a numeric attribute.

## Cross Paths Suggestion Signing And Expiry

The server-owned `getCrossPathsSuggestions` callable binds one environment-
specific Firebase Secret Manager value:

- `CROSS_PATHS_SUGGESTION_SIGNING_KEY`

Use at least 32 random bytes, encoded as a secret string, and use different
material in dev, staging, and prod. Rotating it intentionally invalidates every
outstanding ten-minute suggestion token. Never place the value in Remote
Config, a client build, repository files, or CI logs. Verify secret metadata
without printing the value before deploying the callable. The default
Functions runtime service account for that project must also hold
`roles/secretmanager.secretAccessor` on the individual secret. The metadata-
only environment-readiness gate verifies both the enabled version and that
secret-level runtime binding before Firebase can attempt to mutate IAM during
deployment.

Configure a Firestore TTL policy on
`crossPathsSuggestionExposures.expiresAt` in every environment. The callable
writes a 30-day expiry, but the field does not delete
documents by itself until that environment policy exists. Account deletion
independently deletes exposure receipts involving the member.

### Mumbai selected-event pilot

Cross Paths is a shipped client capability. Its temporary Remote Config
rollout switches were retired after the production QA activation on
2026-08-10 so an environment fetch failure or forgotten template cannot hide
the feature. Every real event must have Admin-owned
`crossPathsDiscoveryEnabled: true`, and the backend accepts
that switch only for an active event at least six hours away in canonical
market `in-mh-mumbai`. At most three upcoming events may be selected. Pair
inventory additionally requires an organizer-authored admission policy and
server-owned capacity validation.

Use this rollout order:

1. Keep the published privacy policy and per-event consent copy aligned with
   the exact product behavior; obtain independent legal review before selecting
   the first real-member event.
2. Select 2–3 eligible upcoming Mumbai events in Admin with an audit note.
3. Onboard 20–50 real members through the normal user-controlled global and
   per-event consent actions; never seed or backfill affirmative consent.
4. Curate the Mumbai showcase queue through the score-free human checklist.
5. Prove eligible-supply, exposure, invitation-abuse, cancellation, safety,
   and support monitoring.
6. Monitor the live client surfaces and enable real discovery only by
   selecting an eligible event after consent/supply evidence is sufficient.
7. Enable pair inventory per event only when that organizer deliberately
   reserves capacity and the event remains eligible.

Rollback is additive and fail-closed: disable selected event switches if
necessary. Turning off an event switch
invalidates pending invitations but preserves an explicitly accepted plan.
Consent controls remain available so members and support can revoke or inspect
consent; never use rollback to rewrite consent history.

Production QA was activated on 2026-08-10 with one hidden, synthetic Mumbai
event, one fictional test-phone viewer, two synthetic opted-in showcase
profiles, and exact read-back of all eleven fixture documents. No real event
or real member was opted in or exposed. The client surfaces are live; real
discovery remains empty until Admin selects an eligible real Mumbai event and
real members make both consent choices themselves.

## Event Venue Session Signing And Expiry

The live Host check-in QR binds one environment-specific Firebase Secret
Manager value:

- `EVENT_VENUE_SESSION_SIGNING_KEY`

Use at least 32 random bytes and different material in dev, staging, and prod.
Rotation intentionally invalidates every outstanding live QR. Never expose the
value to Remote Config, clients, repository files, or CI logs. The Functions
runtime service account needs `roles/secretmanager.secretAccessor` on this
individual secret.

The reviewed defaults are a 90-second lifetime and refresh after 60 seconds.
Deployments may set `EVENT_VENUE_SESSION_TTL_SECONDS` from 30 through 300 and
`EVENT_VENUE_SESSION_REFRESH_SECONDS` from 10 through 240; refresh must remain
strictly less than lifetime or both values fall back to the reviewed defaults.
Firestore TTL must be enabled on `expiresAt` for `eventVenueSessions` and
`eventVenueSessionRedemptions`.

## Required Secrets

Build workflows need environment-specific Google Maps SDK secrets. Do not rely
on a generic fallback secret, because that can silently mix project keys across
flavors:

- `GOOGLE_MAPS_ANDROID_API_KEY_DEV`
- `GOOGLE_MAPS_ANDROID_API_KEY_STAGING`
- `GOOGLE_MAPS_ANDROID_API_KEY_PROD`
- `GOOGLE_MAPS_IOS_API_KEY_DEV`
- `GOOGLE_MAPS_IOS_API_KEY_STAGING`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

The environment-scoped `Mobile Internal Release` workflow needs these
`prod-mobile` environment secrets for iOS:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `IOS_CI_DEVELOPMENT_CERTIFICATE_P12_BASE64`
- `IOS_CI_DEVELOPMENT_CERTIFICATE_PASSWORD`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

`APP_STORE_CONNECT_API_KEY_BASE64` is the base64-encoded contents of the
downloaded `AuthKey_<key-id>.p8` file. Keep the raw `.p8` out of git; it is
ignored by `.gitignore` and should live only in secure local storage and GitHub
Actions secrets.

The reusable iOS archive identity is a dedicated Apple Development certificate,
not a personal signing identity. Store its encrypted PKCS#12 payload and
password in the two `IOS_CI_DEVELOPMENT_CERTIFICATE_*` secrets. Keep these
non-secret `prod-mobile` environment variables beside it:

- `IOS_CI_DEVELOPMENT_CERTIFICATE_ID`
- `IOS_CI_DEVELOPMENT_CERTIFICATE_SHA256`
- `IOS_CI_DEVELOPMENT_CERTIFICATE_EXPIRES_AT`

Each iOS matrix runner imports that same identity into an ephemeral keychain,
checks the certificate type, Apple team, SHA-256 fingerprint, and 30-day
validity floor, then deletes the decoded PKCS#12, public certificate copy,
temporary keychain, and materialized App Store Connect key. Keep Xcode archive
signing automatic and keep `-allowProvisioningUpdates`; the persistent private
key prevents a clean runner from asking Apple to create another development
certificate, while Xcode can still create or repair role-specific profiles.

Rotate the CI identity before the 30-day floor by creating one replacement
certificate/private-key pair, importing the replacement PKCS#12 locally to
prove it is a usable code-signing identity, updating both secrets and all three
variables, and running both iOS release lanes. Re-query Apple certificates and
profile relationships after the run. Revoke the old CI certificate only after
both roles process successfully with the replacement and no new certificate id
appears. Never auto-revoke the active CI certificate at job teardown.

Android release jobs require these `prod-mobile` environment secrets:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `GOOGLE_MAPS_ANDROID_API_KEY_PROD`

Play publishing in `Mobile Internal Exact Promotion` uses the existing GitHub
OIDC provider plus the environment variables `GCP_WORKLOAD_IDENTITY_PROVIDER`
and `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`. There is no rollout Boolean to drift:
every Android promotion must live-probe both Catch Play records, both `qa`
tracks, app-scoped edit access, and at least one Google Group tester per track
before the selected AAB can upload. Play App Signing enrollment remains an
owner-controlled Play Console prerequisite because the Publisher API cannot
prove it before the first bundle exists. Do not add a long-lived Google Play
JSON key.

As of 2026-07-11, `androidpublisher.googleapis.com` is enabled and
`github-actions-play-publisher@catch-dating-app-64e51.iam.gserviceaccount.com`
exists with zero project roles. Its only IAM binding is
`roles/iam.workloadIdentityUser` for the exact GitHub OIDC subject
`repo:suvratgarg/catch-dating-app:environment:prod-mobile`. Play Console must
still invite that identity separately, scoped to the two app records and only
read-app plus testing-track release permissions.

After those grants exist, configure at least one Google Group tester on each
`qa` track. The exact promoter invokes the separately authenticated,
apply-guarded `tool/platform/probe_google_play_access.mjs` for both package
names on every Android promotion. The fleet probe creates an edit, reads the
track and its Google Group testers, and deletes the edit without uploading or
committing. It is not part of package production and must not be replaced by a
trial upload. The promoter still refuses every track except `qa`.

## CD Policy

Staging is refreshed independently on the first day of each month at 02:17 UTC
(07:47 IST), or manually through `Backend Staging Refresh`. That main-only
workflow validates a full current snapshot with the Functions, contract/index,
and rules lanes, then promotes their exact tested package only to staging.
It does not write the production cursor or block routine releases. Its separate
workflow lock and the shared per-environment promotion lock prevent overlapping
staging mutations. Start a fresh refresh instead of partially rerunning it.

Firebase backend delivery is one ordered promotion chain. After a successful
same-repository `main` push, CI packages only the backend groups authorized by
the exact impact plan. `Delivery` verifies that CI-produced package and promotes
the same bytes through `dev`, then production; production waits for dev to
finish. The source review policy described under GitHub Environments And
Auth selects `prod-backend` for explicitly reviewed Functions-only source and
verified Functions no-ops, or reviewer-protected `prod` for the remaining changes. Neither
path rebuilds or changes the approved artifact.

Functions packages retain their full immutable CI-authorized target set. Before
promotion, the current control plane derives an execution subset from the exact
base/source Git objects using TypeScript imports and re-exports. A changed
module selects each exported function that transitively depends on it; new or
retargeted entrypoint exports are included. Selection is at module granularity,
so multiple functions implemented in one file move together. Test-only changes
can produce a verified Functions no-op without invoking Firebase with an empty
or broad selector. Every execution plan is recomputed before mutation.

Whole-declaration `import type`, `export type`, and type-only import-equals
edges are excluded because TypeScript erases them. Inline type specifiers stay
conservative because compiler settings can preserve module evaluation.
Generated Functions validators import individual schema modules; runtime
imports of aggregate schema inventories are rejected by the contract boundary
check. A schema change therefore selects its actual consuming modules. The
shared validation engine remains a real dependency of all its consumers.

Changes to runtime/dependency/build configuration, global initialization or its
dependencies, runtime assets, and uncertain module analysis keep the full
CI-authorized set. Bootstrap, rebaseline, and monthly staging snapshots are
always full. Dormant targets remain excluded, historical package bytes remain
unchanged, and the ordered cursor continues to establish the deployed base.
Out-of-band drift is repaired with an explicit full snapshot, not assumed fixed
by an incremental release. The job log reports the selected targets and reason.

The backend stages inside each environment are ordered
`firestore-indexes` → `functions` → `firestore-rules` → `storage-rules`, omitting
groups the impact plan did not authorize. The index stage is not complete until
every packaged composite index reaches `READY`. Normal delivery is therefore
ordered from dev through policy-selected production. Store, Hosting, and app
releases retain their independent owners.

Manual `Delivery` dispatch is bounded recovery, not an arbitrary deploy path.
It accepts only the id and full SHA of the oldest pending successful
same-repository `main` CI attempt plus a terminal non-success Delivery run id
and attempt. The prior run must contain a source-, base-, package-, and
provenance-digest-bound recovery authorization written before promotion. It
restores a matching checkpoint when present and restarts that same verified
package at stage one when the terminal attempt ended before checkpoint
publication. It cannot rebuild a branch, borrow an unrelated failed run,
broaden the authorized targets, or substitute newer workspace contents.
The original package and its pristine extracted tree remain byte-verified and
immutable. A separate deploy copy may remove only a non-vector one-field
composite index that Firestore cannot create, and only after the current
control plane no longer declares that exact index. This deterministic recovery
normalization changes no query capability because Firestore's built-in
single-field index already owns the shape; all other packaged bytes and stages
remain bound to the original CI authority.

Before each stage, artifact promotion refreshes main and verifies both the
pinned control-plane commit and package source remain ancestors of it. Ordinary
ordered artifacts and independent staging snapshots then use the executor's
explicit older-ref option: an unrelated newer main commit must not interrupt
an already authorized immutable package. Rebaseline additionally requires exact
current-main equality at every stage and does not enable that option. Direct
local deployment keeps the default stale-checkout refusal. This does not permit
queue skipping, package substitution, or source outside main history.

`Backend Rebaseline` is the exceptional cumulative-snapshot lane for an
explicitly approved stale-queue recovery. It is manual-only, shares the
`backend-delivery` concurrency key, and accepts only the exact current `main`
SHA plus a single-line operator reason and an affirmative all-backend
confirmation. It restores the latest verified v4 cursor, binds the current
successful `main` CI authority, and uses the required Harness graph to select
exactly Functions, Firestore indexes, Firestore rules, and Storage rules. It
then reruns the Functions, contract/index, and rules validation lanes and
packages their exact tested output in the rebaseline run; it does not borrow
or rebuild an older pending backend package.

The resulting immutable package follows the ordinary ordered promotion path
through `dev` and protected `prod`. Every environment additionally
requires the package source to remain the exact live `main` head. Only a
successful production promotion may publish a normal v4 delivery cursor for
the current successful `main` CI authority; that cursor supersedes the covered
pending CI window without deleting its artifacts. Rebaseline does not delete
Firestore documents, Storage objects, Extension-owned Functions, or
environment-only Functions. Legacy data and API retirement remains a separate
contract migration with its own read, write, rules, and deletion sequence.

When no verified delivery cursor exists, automatic selection has a separate,
fail-closed bootstrap rule: it may select only the latest successful immutable
CI authority whose source SHA is the live `main` head, and that authority must
contain an actual backend package. This establishes the baseline from current
source instead of replaying an unrelated historical package. A no-op current
head, a successful ancestor, a branch artifact, or any selection while a cursor
exists cannot use this rule. Once the bootstrap promotion reaches protected
production, ordinary oldest-pending cursor order and the manual recovery rules
above apply again.

The promotion process also supplies a fixed disabled profile for the
non-secret Meta WhatsApp parameters during Functions discovery. This lets an
older verified package deploy non-interactively without inventing live Meta
credentials: both identifier values contain only whitespace, which the
source-owned configuration check trims to empty, the graph version remains
`v23.0`, and the newer explicit gate remains `false`. Secret values still come
only from Secret Manager, and the recovery path never enables the provider.

### WhatsApp provider activation

The disabled discovery profile is not a staging or production readiness
receipt. Organizer WhatsApp may be enabled in an environment only after an
operator verifies the following against the live target rather than a checked-in
description:

- `META_WHATSAPP_ENABLED=true` is an intentional environment approval, and the
  Meta app id, Embedded Signup configuration id and supported Graph version are
  non-placeholder values for that same app;
- the app secret and organizer access-token vault secrets exist in Secret
  Manager, the Functions runtime has only the required access, and no token or
  secret is stored in Firestore, logs, CI artifacts or client configuration;
- the public webhook challenge and raw-body signature path are reachable, the
  correct WABA is subscribed, and duplicate/out-of-order status and inbound
  webhook tests pass;
- one organizer-owned number completes onboarding, identity/quality inspection,
  template sync, test delivery and status receipt in the target environment;
- exact organizer-scoped WhatsApp permission, STOP/admin suppression, frequency
  caps, service-window rules, retention, cost/quality monitoring and support
  escalation have named owners; and
- the released Host clients expose provider unavailability and setup blockers
  rather than enabling a campaign composer optimistically.

Catch-owned WhatsApp is a separate activation. It requires a separate Catch
WABA/number, credentials, templates, consent/suppression ledger, webhook/thread
authority, retention policy and support owner. Enabling organizer WhatsApp must
not make the Catch route active. Personal `wa.me` handoff requires no backend
provider activation and generates no Catch delivery receipt.

Mobile artifacts remain separate from backend deployment. A successful
same-repository `main` CI attempt wakes `.github/workflows/mobile-internal-release.yml`,
which verifies CI authority v3 and consumes only the exact
`consumer-ios`, `consumer-android`, `host-ios`, or `host-android` targets in that
plan. The approval-free, main-only `prod-mobile` environment supplies signing
credentials. The producer builds, signs, verifies, size-audits, and retains each
selected IPA/AAB plus its identity, policy, provenance, and immutable upload
receipt for 90 days. Cross-role comparisons finish before it publishes the
aggregate mobile build authority. The producer performs no TestFlight or Play
mutation.

Store mutation remains a separate exact-artifact operation in
`.github/workflows/mobile-internal-promote.yml`. After the aggregate authority is
published, the producer uses its narrowly scoped `actions: write` job to dispatch
one promoter for every authorized iOS target, passing the current producer
run/attempt and exact authority artifact id/digest. GitHub runs the promoter from
`main`; it waits for the dispatching producer to reach terminal success, then
derives the package artifact only from that authority, downloads it by immutable
id, verifies the GitHub digest and every packaged byte, and freshly re-extracts it
for final verification before credentials are created. Manual dispatch accepts
the same inputs and remains available for exact recovery.

The promoter uploads the already-signed IPA to TestFlight or the already-signed
AAB to the Play `qa` track without Flutter, Gradle, Xcode archive/export, or
signing work. For iOS, it waits for the exact build to reach `VALID`, removes the
upload credential, persists the immutable exact-upload claim, then rematerializes
the credential only for an idempotent distribution step. That step selects every
existing internal TestFlight group for the app that already contains testers,
adds the exact build to groups that do not yet have it, reads every relationship
back, and persists a separate 90-day distribution receipt. It never creates a
group, adds a tester, or grants access to an external group. The run fails closed
when no existing internal group contains testers. Play additionally requires the
two-app live readiness gate to pass; public store promotion remains outside this
workflow.

The mobile package receipt intentionally reports two repository-controlled
measurements: compressed bytes in the signed IPA/AAB and the sum of raw archive
member lengths. `tool/platform/mobile_package_policy.json` records the signed
integration baseline for each role/platform and permits at most 20% budget
headroom. App Store Connect and Play report processed download/install
estimates; those values are not compared to either archive metric. Similar
store-displayed sizes do not imply identical applications: the release gate
also requires different compiled binaries and entry sets, and rejects Health
or Razorpay native payloads in Host.

Marketing and admin Hosting deploys require explicit Vite Firebase/App Check
environment variables. The exact Hosting build job runs
`tool/env/check_web_hosting_env.mjs` before producing the bundle, so packaging
fails if the site would fall back to dev Firebase config, sample admin mode, or
missing App Check. The packaged Firebase config contains one production target,
binds the known production Firebase project and surface-specific Hosting site,
points at the packaged site bytes, and has no `predeploy` or `postdeploy`
lifecycle hook. Marketing
production builds also require an
explicit store-link contract. `VITE_STORE_LINKS_MODE=prelaunch` requires both
store URLs to remain empty and preserves the honest coming-soon/waitlist CTA;
`live` requires validated HTTPS `VITE_APP_STORE_URL` and
`VITE_PLAY_STORE_URL` product links on `apps.apple.com` and `play.google.com`.
The automatic workflow defaults an unset mode to `prelaunch`, so the website
can deploy before the mobile listings exist without publishing fake links.

All three Hosting workflows use the approval-free `prod-hosting` GitHub
Environment and deploy automatically after their validation job succeeds on a
matching `main` push. Each deployable output is built once: React source
validation skips its redundant production bundle, while the Host workflow
validates without building; `_web-hosting-build.yml` then produces and packages
the exact production bytes, and `_web-hosting-promote.yml` downloads that
artifact by id and digest without rebuilding it. Keep only Hosting/OIDC
variables in that environment; App Store
Connect and mobile signing secrets are owned by `prod-mobile`; backend
production uses the bounded `prod-backend` path or reviewer-protected `prod`.
Temporary mobile
rollback duplicates in `prod` follow the cutover cleanup above.

The production admin Hosting target has its own `Admin Website` workflow. It
validates Admin source, checks live prod Vite Firebase/App Check env, builds the
production bundle once, probes every callable declared in
`contracts/admin/admin_live_data_sources.json`, then deploys only
`hosting:admin` after matching changes land on `main`. A missing production
callable therefore blocks Hosting before a frontend can ship a dead Admin
route.
The same validation runs the admin unit suite, including the phone-only
guard in `admin/src/app/App.test.tsx` and
`admin/src/shared/api/firebase.test.ts`; a refactor that removes phone OTP or
reintroduces Google sign-in must fail before Hosting deploys.

That local environment check cannot prove Firebase console state. After admin
Auth, Hosting-domain, provider, reCAPTCHA-key, or App Check changes, record live
evidence that `admin.catchdates.com` and `catchdates-admin.web.app` are
authorized Auth domains, the Phone provider is enabled, the Google provider is
disabled, the deployed web app's reCAPTCHA v3 key has a matching Firebase App
Check server secret, and the live page completes App Check token exchange
before sign-in.

The standalone Host target is the Firebase Hosting site `catchdates-host`
(`https://catchdates-host.web.app`) and is mapped as `hosting:host` in
`.firebaserc`. Before making `hosts.catchdates.com` the advertised entrypoint,
attach that custom domain to the site, complete the Firebase DNS verification,
add both domains to Firebase Auth's authorized domains, and verify phone OTP and
App Check in the deployed Host Flutter shell. Public OTP registration on
`catchdates.com` uses the same production Firebase project but a separate
event-scoped registration callable; verify its reCAPTCHA/App Check exchange and
phone-provider state independently. Creating the Hosting site does not prove
any of these console or DNS gates.

Backend `Delivery` never deploys Hosting or forwards Vite variables. The
marketing, Host, and admin workflows own their production Hosting builds and the
`prod-hosting` environment described above. `VITE_GTM_ID` remains optional
until the production GTM container exists; paid-acquisition readiness still
requires setting it and validating consent-aware tags. For marketing Hosting,
an absent environment-level `VITE_STORE_LINKS_MODE` defaults to `prelaunch`;
cut over by setting it to `live` only after setting both official product URLs
in the same GitHub Environment.

Hosting retry is resume, not generic rollback. An empty manual dispatch remains
validation-only. Exact recovery requires the failed producing run id/attempt,
source SHA, artifact id, GitHub digest, and a non-empty operator reason; only a
terminal non-success attempt is eligible. Both automatic promotion and recovery
recheck same-surface freshness immediately before Firebase mutation. Recovery
also requires its source SHA to remain the current `main` head and rejects an
older package attempt at the same SHA, so a historical artifact cannot overwrite
newer Hosting bytes. Packages retain for 90 days.

If a `main` CI attempt reuses successful jobs from an older attempt, Required CI
fails unless that exact current attempt owns its planner artifact and, when
applicable, backend package. Use **Re-run all jobs** so the successful attempt
publishes a complete immutable artifact set.

If backend delivery ends in `failure`, `cancelled`, `timed_out`, `stale`,
`action_required`, or `startup_failure`, do not use GitHub's re-run-job or
re-run-failed-jobs controls: they may reuse successful prerequisite outputs from
an older attempt.
Start a fresh manual `Delivery` dispatch from `main` with the exact oldest
pending successful CI run id and SHA plus that terminal non-success Delivery run
id and attempt. The fresh run re-authorizes queue position and verifies the
prior run's exact source/package authorization. When the prior run stopped
before publishing its first checkpoint, recovery starts the same verified
package at stage one; otherwise it restores the matching environment/project
checkpoint. Successful, neutral, skipped, or nonterminal runs cannot authorize
recovery. A source fix needs a new PR, CI run, and package; do not use recovery
to rebuild or redeploy mutable workspace state. The logical `functions` target
still expands to explicit deployment-eligible Function names so non-interactive
promotion does not prompt to delete unrelated legacy live functions or recreate
a dormant scheduled Function.

## Exact-Artifact Promotion And Resume

Validation and deployment are separate trust decisions. A green CI run proves
the source and checks that ran in that job; it does not prove that bytes rebuilt
later by a deployment job are identical. Delivery paths should therefore build
once and promote the producing run's verified artifact whenever the target
supports artifact promotion.

The reusable delivery contract binds:

- the full 40-character source commit SHA;
- the producing CI run identifier and attempt;
- artifact basename, byte length, and SHA-256 digest; and
- the ordered stages permitted for that artifact.

The Firebase adapter additionally binds the Harness plan's base SHA and exact
deploy groups so the packaged stage order cannot differ from the plan CI
validated.

The final `Required CI` step publishes `catch.ci-delivery-authority/v3` only
after that exact attempt owns its planner artifact and, when deployment is
needed, backend package. The authority binds the numeric CI workflow id,
workflow-scoped run number, run id, attempt, source SHA, and each referenced
artifact's immutable id, name, and GitHub SHA-256 digest. Delivery downloads
the referenced plan and package by artifact id and independently verifies the
downloaded archive digest before extraction.

Before using deployment credentials or mutating remote state, a consuming job
must receive the expected source SHA, run id, and run attempt from trusted queue
selection or explicit recovery input, download the artifact plus provenance
manifest, and verify every binding. A source mismatch, run mismatch, attempt
mismatch, changed size, or digest mismatch fails closed. A successful upstream
run by itself is not artifact identity.

Multi-stage delivery uses an ephemeral checkpoint bound to the provenance
manifest digest, source SHA, source run and attempt, artifact digest, and an
immutable target scope. Firebase scopes include the environment and project id,
so a dev checkpoint cannot authorize staging or production. Checkpoints form an
ordered prefix of the manifest's stages. A stage is complete only after its
documented remote postcondition passes. On retry, the consumer verifies the
same artifact and checkpoint binding, identifies the first incomplete stage,
and resumes there. It cannot skip ahead; replay of an already-passed stage is
idempotent and does not rewrite prior proof.

Provenance, source-bound recovery authorizations, cursors, and checkpoint
documents are CI or bounded recovery artifacts, not tracked repository state.
Writes must be atomic so interruption cannot publish a partial checkpoint. A
verified v4 cursor remains authoritative if its later drain-dispatch step fails
or the originating run is subsequently rerun; selection uses the greatest
verified source run number within the exact CI workflow id, never the mutable
latest conclusion of that Delivery run. One artifact-catalogue scan selects the
cursor and oldest pending `catch.ci-delivery-authority/v3`; when no cursor
exists, it instead selects the latest authority and proves that its SHA is the
current `main` head and that it owns a backend package. Delivery then
downloads and verifies only those selected artifacts and their historical run
attempts. It does not perform an API call or ZIP download per retained merge.
The selected plan's base SHA must equal the cursor source SHA, so a missing or
expired intermediate authority fails visibly rather than skipping work.

CI workflow ids define queue generations because GitHub run numbers restart if
a workflow is deleted and recreated. A cursor from another or legacy generation
causes a hard stop. Review the intended backend baseline and explicitly remove
or migrate the old cursor artifacts before restarting; never compare run numbers
across workflow ids.
Backend plans, packages, authorizations, cursors, and checkpoints retain for 90
days, covering GitHub's 30-day approval and rerun window without turning source
control into a delivery-state database.

Resume is not rollback. Resume continues promotion of the same verified bytes.
Rollback follows the target-specific instructions in this runbook and may use
a prior verified artifact, a compensating configuration change, or a
roll-forward. Partial remote state must be reported explicitly; no generic
delivery helper may claim it reversed a deployment merely because a command
failed.

The shared delivery primitive verifies identity, integrity, order, and resume
state. Each release owner still supplies environment readiness, credentials,
approval, concurrency, stage postconditions, smoke tests, and mutation policy.
Production permission is never inferred from a valid digest. The Firebase
backend consumes this contract through `delivery.yml` and
`_firebase-promote.yml`. Admin and Marketing Hosting consume it through
`_web-hosting-build.yml` and `_web-hosting-promote.yml`. Mobile release routing,
signed package production, and store promotion use separate exact-target
producer and promoter workflows; the promoter cannot rebuild or resign.

## Release Setup Evidence Snapshot

Current setup/build/signing/distribution verdict: local builds and the native
signing contract are healthy. On 2026-07-15, GitHub run `29388936845` exposed
an Apple certificate-capacity blocker in both iOS archive jobs: ephemeral
runners had no reusable development private key, so automatic signing had
accumulated one unusable API-created certificate per runner. Nineteen verified
unused development certificates were revoked, the three working human
Development/Distribution/Developer ID identities were preserved, and dedicated
CI certificate `7P698XNLRP` was installed in `prod-mobile`. Current
final analyzer-clean producer run `31435724862` used the repaired reusable-keychain
path for both roles, and exact promotion runs `31436879851` and `31436882152`
processed the Consumer and Host IPAs as `VALID`. Mobile store distribution still needs
external product-release evidence: current automatic TestFlight distribution
receipts plus install proof for both roles, and Play account verification, enrollment, processing,
tester, signing-fingerprint, install, and launch proof.

Verified setup state:

- Web builds, Android signed APK/AAB creation, iOS App Store IPA export, and
  macOS release builds have passed in the current release setup evidence.
- Android upload-key SHA-1/SHA-256 fingerprints are registered on Firebase for
  the currently verified consumer and host upload artifacts.
- Firebase App Check provider configs and enforcement are verified for the
  consumer Android, iOS/macOS, and web registrations plus the 2026-06-10 host
  Android, iOS, and web registrations. Host Android uses Play Integrity, host
  iOS uses App Attest, and host web uses reCAPTCHA Enterprise across dev,
  staging, and prod.
- Apple Developer App ID `Catch Host` / `com.catchdates.host` is registered
  under team `2HQBK4UMUT` with App Attest, Associated Domains, HealthKit, and
  Push Notifications enabled. App Store Connect app `Catch Host` exists as app
  id `6778927317`, SKU `catch-host-ios`, primary language English (U.S.), iOS
  platform, and Full Access user access. The native Host product deliberately
  signs without HealthKit and Associated Domains even if those capabilities
  remain enabled on the Developer portal record.
- Direct macOS distribution is Developer ID signed, timestamped, notarized,
  stapled, and Gatekeeper accepted.
- Consumer TestFlight upload/install/launch and iOS Maps behavior have legacy
  Xcode Cloud proof. GitHub Actions is now the canonical owner for both roles;
  both current GitHub builds have processed, while the repaired automatic
  tester-group receipt and install/launch proof remain pending for each role.

Still outside this setup verdict:

- Android real-device smoke testing remains hardware-gated until an authorized
  Android phone is connected.
- macOS phone-auth runtime behavior is intentionally deferred because Firebase
  Auth `verifyPhoneNumber()` is unavailable on macOS.
- Play internal testing, store metadata, privacy/data-safety forms,
  screenshots, legal/support URLs, and production Crashlytics/Analytics
  dashboard validation remain release-management/product tasks.
- App Store Connect currently displays an updated Apple Developer Program
  License Agreement notice. The Account Holder should accept it before treating
  host TestFlight uploads or store submissions as release-ready if Apple blocks
  either action.
- Play app-signing certificate fingerprints still need to be added to Firebase
  after Play Console enrollment. Local upload-key fingerprints are already
  registered.
- Mac App Store distribution has not been validated. Direct Developer ID
  distribution is validated.

## App Version And Force-Update Gate

Every store release candidate that may be enforced through Remote Config must
increment the `pubspec.yaml` build number. The marketing version can stay stable
when the release is compatibility or migration focused, but the build number
must still move so Firebase Remote Config can target old binaries precisely.

Current release candidate:

```text
version: 1.0.1+3
```

Flutter maps this to:

- Android `versionCode`: `3`
- iOS `CFBundleVersion`: `3`
- macOS `CFBundleVersion`: `3`

After the compatible binary is available to users, raise only the platform keys
for platforms included in that release:

```text
min_build_ios = 2
min_build_android = 2
min_build_macos = 2
```

Keep `min_version` broad unless the release intentionally changes the public
marketing version. Use the platform build gates for schema/API compatibility
work because they are less ambiguous than semantic version strings.

For storage/API migrations:

1. Deploy backend support that can tolerate both old and new clients.
2. Ship the client release with dual-read/dual-write support.
3. Wait until the released build is actually available through the relevant
   store or distribution channel.
4. Raise the Remote Config `min_build_*` value for released platforms.
5. Rerun the migration-specific parity gate and record the prod evidence before
   cleanup.
6. Cut over backend triggers or remove legacy write support only after the
   parity gate passes with the force-update gate in place.

Remote Config shortens the compatibility window, but it does not eliminate it
at release time. A client can start offline, fetch can fail, and store rollout
timing can lag. Keep legacy-compatible reads/writes until the explicit parity
and force-update cutover step is complete.

The `swipes` to `profileDecisions` migration is already complete: dev, staging,
and prod cleanup finished on 2026-05-26, and the one-time migration tools were
retired on 2026-06-02.

The checked-in baseline template is `firebase/remote_config.template.json`.
Its default values are deliberately non-blocking. Use it to seed a project or
recover missing parameters, then raise `min_build_*` only as a deliberate
release action after the compatible binary is available.

Production release builds throttle Remote Config fetches to a one-hour minimum
interval. Debug builds, emulator builds, and non-production environments keep a
zero interval so config changes are easy to validate during QA.

## Pre-Deploy Checklist

- Review `git diff --stat` and confirm the dirty tree is the intended release
  candidate.
- Run code generation if generated Dart or Firestore TS types are stale.
- Run `./tool/check_data_contract.sh`.
- Run focused Flutter analysis/tests for touched surfaces.
- Run `npm --prefix functions run lint`.
- Run `npm --prefix functions test`.
- Run Firestore rules tests through the emulator:
  `firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"`.
- Make the beta data strategy explicit: reset demo data or validate migration
  tooling before production users depend on the new schema.
- Confirm Remote Config force-update values are planned but not raised until a
  compatible app build is available.

## One-Time Environment Setup

Before rules or Functions depend on them, each Firebase/GCP environment needs:

- Cloud Vision API enabled for photo moderation.
- `config/cities` Firestore document with `cityNames` and full city objects.
- Firestore TTL policies on `rateLimits.expiresAt` and, before enabling Cross
  Paths, `crossPathsSuggestionExposures.expiresAt`.
- Firebase Functions secrets for payment, maps/places, and any other
  environment-owned provider keys.
- Google Maps SDK/Places APIs enabled and key restrictions configured as
  described in `docs/location_stack_plan.md`.
- Firestore BigQuery export extensions installed where marketplace/event-success
  metrics should be queryable.
- Firebase Analytics linked to the intended Google Analytics property, web
  measurement IDs refreshed, GA4 BigQuery export enabled where needed, and
  DebugView evidence captured for the target app id.

### Payment Provider Setup TODO

Do not treat international paid events as launch-ready until these items are
complete for each target environment (`dev`, `staging`, and `prod`):

- [ ] Create environment-owned Stripe platform credentials. Keep test and live
  mode keys separate, and do not reuse another environment's secret key.
- [ ] Set the Stripe Functions secrets in each Firebase project:
  `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET`.
  As of 2026-05-28, `dev`, `staging`, and `prod` have non-real placeholder
  values for both secrets so unrelated Functions deploys are not blocked by
  missing Stripe bindings. Replace those Secret Manager values with
  environment-owned Stripe credentials before enabling Stripe onboarding,
  checkout, or webhooks.
- [ ] Configure Stripe webhook endpoints per environment for the exported
  `stripeWebhook` HTTPS Function. Subscribe at minimum to Checkout Session
  completion and expiration events used by the backend booking flow, then copy
  the endpoint signing secret into `STRIPE_WEBHOOK_SECRET`.
- [ ] Confirm the Stripe Connect platform responsibilities before enabling
  host onboarding. The current backend creates Accounts v2 connected accounts,
  requests merchant card-payment capability, and uses destination Checkout
  Sessions with `transfer_data.destination` and `on_behalf_of`.
- [ ] Decide and configure the platform fee policy through
  `STRIPE_APPLICATION_FEE_BPS` per environment. Leave it at `0` only when
  Catch is intentionally not taking an application fee.
- [ ] Set production-safe redirect URLs for Stripe onboarding and checkout:
  `STRIPE_CONNECT_RETURN_URL`, `STRIPE_CONNECT_REFRESH_URL`,
  `STRIPE_CHECKOUT_SUCCESS_URL`, and `STRIPE_CHECKOUT_CANCEL_URL`. The checked-in
  code defaults point at `catchdates.com` and exist only so noninteractive
  Functions deploys keep working before Stripe launch. Review and override them
  before staging/prod payment rollout.
- [ ] Create environment-owned Razorpay credentials before live INR payments.
  Current non-prod/prod state has reused test-mode Razorpay secrets; replace
  them with the intended `RAZORPAY_PUBLIC_KEY_ID` parameter and
  `RAZORPAY_KEY_SECRET` secret per
  Firebase project.
- [ ] Verify `createRazorpayOrder` returns the public `keyId` from the same
  Firebase project configuration that created the order. Mobile builds do
  not read a local Razorpay `.env` value or embed a generated key. The
  `RAZORPAY_KEY_SECRET` remains server-only and must never enter a client
  contract or artifact.
- [ ] Enable Razorpay Route for each target account before exposing India host
  payout setup, and verify linked-account, stakeholder, Route product, bank
  settlement, and activation-status APIs with that environment's credentials.
  A deployed callable and enabled secrets do not prove Route account approval.
- [ ] Smoke test India host setup with an organizer owner: verify Razorpay is
  recommended while Stripe remains available, KYC and bank fields are absent
  from Firestore, a failed retry continues the same linked account/product, and
  refresh moves pending/clarification/activated states into the matching Host UI.
- [ ] Replace the temporary `RAZORPAY_WEBHOOK_SECRET` values before enabling
  real Razorpay webhooks. As of 2026-06-26, `dev`, `staging`, and `prod` each
  have an enabled placeholder Secret Manager version so unrelated Functions
  deploys are not blocked while Razorpay account approval is pending.
- [ ] Merge the backend change and require `Delivery` to promote the exact
  CI-produced package; do not use a local rebuild for the normal rollout.
- [ ] Confirm packaged indexes reached `READY`, then confirm the Functions phase
  and its automatic callable-invoker sync passed before Firestore or Storage
  rules advanced.
- [ ] Smoke test the full paid-event matrix in the target environment:
  free booking, INR Razorpay checkout success/cancel/refund, non-INR Stripe host
  onboarding, non-INR Stripe checkout success/cancel/expiration webhook, payment
  history, booking count projections, waitlist/race-loss refund behavior, and
  host cancellation refund behavior.
- [ ] Record the smoke evidence in the release notes before enabling production
  host-created international paid events.

## Firebase Backend Delivery Order

For backend/schema-affecting releases, deploy in this order per environment:

1. Firestore indexes, followed by an explicit wait until every packaged index is
   `READY`.
2. Functions, including callable-invoker synchronization.
3. Firestore rules.
4. Storage rules.

The impact plan may omit unaffected stages but cannot reorder the stages it
selects. Hosting and app releases are separate workflows, not a fifth backend
stage. Keep Functions ahead of tighter rules when a release moves writes behind
new callables, and keep indexes ahead of Functions that may immediately depend
on new queries. Do not use Remote Config as a schema migration tool; use it only
to block older app builds after the compatible build is available.

The 2026-07-10 event-scoped Host inquiry change is a concrete two-phase case:
deploy the updated `startClubHostConversation` Function and generated payload
contract before distributing the new client. The client contains a narrow
compatibility retry that removes `eventId` only when the older callable returns
the exact `eventId ... additional properties` validation diagnostic. That
fallback prevents a premature TestFlight build from breaking Message Host, but
it creates a General inquiry and therefore is rollout safety—not event-provenance
closure. Wrong-club and other new-backend validation failures are never retried.

Host event broadcasts completed their backend-first rollout in August 2026:

1. Merge and deploy `sendEventBroadcast`, its receipt schema, TTL field policy,
   indexes/rules, and callable IAM while
   the Host client affordance was still hidden.
2. Exercise dev, staging, and then production callable reachability. Confirm a
   missing-auth request reaches the Firebase callable adapter and returns a
   callable JSON rejection rather than 404, redirect, HTML/GFE, IAM denial, or
   5xx.
3. After that proof passed in production, the temporary client flag was
   removed. The Host job in `Mobile Internal Release` still runs the
manifest-driven live dependency check before Flutter/Xcode work and refuses
to archive if the callable is not reachable. Broadcast visibility is now a
product capability, not a rollout flag.

Organizer follower-update delivery uses the same backend-first boundary, but
its durable retry scheduler is new and must be proved explicitly:

1. Deploy the follower-delivery schemas, TTL policy, index, Firestore rules,
   `createOrganizerPost`, `listOrganizerCampaigns`, and
   `dispatchPendingOrganizerFollowerUpdates` before releasing the matching Host
   client.
2. In dev, then staging, then production, confirm the callable is reachable and
   the scheduler is `ACTIVE`; create one request-id-bound update against a test
   organizer with more than one follower page and prove the operation reaches a
   terminal state without duplicate Activity or push attempts.
3. Release the Host client only after the production callable and scheduler
   postconditions pass. The request id is intentionally required; there is no
   legacy-client fallback or duplicate compatibility path.

`./tool/deploy_firebase_targets.sh` is the bounded stage executor beneath
Delivery and an operator-only recovery helper. It plans selected targets in the
same index → Functions → Firestore-rules → Storage-rules order regardless of
the caller's CSV order. The logical `functions` target expands
deployment-eligible exports from `functions/src/index.ts` into explicit
`functions:<name>` targets. The executor promotes those exact targets in
sequential batches of ten with a short cooldown because Firebase CLI otherwise
fans out up to forty mutations,
which can exceed regional Cloud Functions mutation and temporary Cloud Run CPU
quotas for this repository's large function inventory. This
keeps legacy live Functions, such as old run/run-club callables, deployed until
a deliberate cleanup plan removes them. Exact `functions:<name>` requests use
the same Functions phase. Planner errors and empty or malformed target sets fail
before any deploy begins. After the Functions phase, the helper discovers every
live callable-labeled v2 Function and synchronizes `roles/run.invoker` on its
exact Cloud Run service before continuing to rules. The deploy identity
therefore needs permission to list Cloud Functions and get/set Cloud Run IAM
policies. Delivery additionally owns artifact verification, checkpointing, and
the index-`READY` wait; invoking this helper directly is not normal promotion.
Do not use a broad `firebase deploy --only functions --force` unless deleting
legacy Functions is the intended release action.

Typical commands:

```bash
./tool/deploy_firebase_targets.sh dev firestore:indexes,functions,firestore:rules,storage
./tool/deploy_firebase_targets.sh staging firestore:indexes,functions,firestore:rules,storage
./tool/deploy_firebase_targets.sh prod firestore:indexes,functions,firestore:rules,storage
```

Remote Config is intentionally separate from the standard backend deploy:

```bash
./tool/firebase_with_env.sh dev deploy --only remoteconfig
./tool/firebase_with_env.sh staging deploy --only remoteconfig
./tool/firebase_with_env.sh prod deploy --only remoteconfig
```

Firebase Extensions (`firestore-bigquery-export` instances in `firebase.json`)
are **not** part of the standard backend deploy and are not in the
`deploy_firebase_targets.sh` default target set. When extension parameters
change in `firebase.json`, deploy them explicitly and deliberately:

```bash
./tool/firebase_with_env.sh prod deploy --only extensions
```

Otherwise extension config in the repo silently drifts from what is installed.

Host analytics uses BigQuery as the reporting source of truth. Before deploying
or refreshing it, run the local wiring check:

```bash
node tool/run.mjs check analytics:check-host-bigquery
```

Use this production order so the mart is never refreshed before its source
exports exist:

```bash
# 1. Create the analytics dataset and host analytics tables.
tool/analytics/deploy_host_analytics_bigquery.sh prod --skip-refresh

# 2. Install or update the Firestore-to-BigQuery export extensions.
./tool/firebase_with_env.sh prod deploy --only extensions

# 3. Deploy only the callable code that records and reads analytics.
./tool/firebase_with_env.sh prod deploy --only \
  functions:getHostAnalytics,functions:adminGetHostAnalytics,functions:recordOrganizerAnalyticsEvent

# 4. After the bq-host-* backfill/export views exist, refresh and schedule.
tool/analytics/deploy_host_analytics_bigquery.sh prod \
  --refresh-only \
  --create-schedule

# 5. Verify the live backend state.
node tool/analytics/host_analytics_live_status.mjs --env prod
```

Use `--dry-run` first when validating credentials or SQL syntax locally.
`--create-schedule` is idempotent by display name: it updates the existing
scheduled-query transfer config when exactly one matching config exists, creates
it when none exists, and fails if duplicate configs already exist.

Live prod evidence from 2026-06-18 before the first host analytics deploy:
`catch_analytics` did not exist, no `bq-host-*` extension instances were
installed, no matching scheduled query existed, and
`getHostAnalytics` / `adminGetHostAnalytics` /
`recordOrganizerAnalyticsEvent` were not deployed. Do not treat checked-in
analytics code as live until the four-step sequence above has completed and the
post-deploy smoke checks prove it. The live-status command above is expected to
exit nonzero until all required BigQuery tables/views, extension instances,
scheduled refresh, and callable Functions are present.

The required IAM is not optional. The Functions runtime service account needs
`roles/bigquery.jobUser` at project scope plus access to `catch_analytics`
because the public analytics callable inserts into
`catch_analytics.host_analytics_events` and the host/admin callables read
`catch_analytics.mart_host_event_daily`. The deployer or scheduled-query
identity needs `roles/bigquery.jobUser`, write access to `catch_analytics`, and
read access to `catch_marketplace_metrics` for Event Success scorecard joins.
The `bq-host-*` extension service accounts must retain write access to their
own export tables. The host export env files intentionally use
`EXCLUDE_OLD_DATA=no` so first install backfills existing host data.

The standard deploy helper performs this sync automatically. Use the direct
command only for IAM recovery or auditing a previously deployed environment:

```bash
npm --prefix functions run sync:callable-invokers -- \
  catchdates-dev catchdates-staging catch-dating-app-64e51
```

### Explore Event Discovery Rollout

When a release depends on direct event discovery, do the safe checks before any
write:

```bash
node tool/data/backfill_event_discovery_fields.mjs --env dev --summary-only
node tool/data/backfill_event_discovery_fields.mjs --env staging --summary-only
node tool/data/backfill_event_discovery_fields.mjs --env prod --summary-only
firebase firestore:indexes --project catchdates-dev --pretty
firebase firestore:indexes --project catchdates-staging --pretty
firebase firestore:indexes --project catch-dating-app-64e51 --pretty
```

Read-only index listings on 2026-05-26 showed dev, staging, and prod still had
only the legacy `events` indexes (`status/startTime` and `clubId/startTime`).
Deploy `firestore:indexes` and wait for every discovery index to become
`READY` before enabling an app build that relies on the direct event query.

Require Delivery to promote indexes and then Functions before applying any
backfill. Apply the backfill only after the index stage reports `READY`, the
Functions stage passes, and the dry-run counts for that environment are
reviewed. The direct helper below is for bounded operator recovery only:

```bash
./tool/deploy_firebase_targets.sh dev firestore:indexes,functions
node tool/data/backfill_event_discovery_fields.mjs --env dev --apply
```

Repeat for staging, then prod. Production backfill requires `--allow-prod`.
After each environment, smoke test Explore with city, time, activity, distance,
map pin, saved-event, signed-up-event, hosted-event, and club-metadata cases.
In a release-like build with observability enabled, verify
`explore_event_opened` and `explore_map_event_selected` in Analytics DebugView.

When the admin Organizers and Events canonical directories depend on
token-backed search, dry-run and then apply the admin-search projection repairs
after Functions have been built from the matching code:

```bash
npm --prefix functions run build
node tool/data/backfill_organizer_admin_search.mjs --env dev --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env staging --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env prod --summary-only
node tool/data/backfill_organizer_admin_search.mjs --env dev --apply
node tool/data/backfill_event_admin_search.mjs --env dev --summary-only
node tool/data/backfill_event_admin_search.mjs --env staging --summary-only
node tool/data/backfill_event_admin_search.mjs --env prod --summary-only
node tool/data/backfill_event_admin_search.mjs --env dev --apply
```

Repeat for staging, then prod. Production apply requires `--allow-prod`.

Organizer supply capabilities are a callable-owned product-policy projection.
Dry-run before applying the legacy repair:

```bash
npm --prefix functions run build
node tool/data/backfill_organizer_supply_capabilities.mjs --env dev
node tool/data/backfill_organizer_supply_capabilities.mjs --env staging
node tool/data/backfill_organizer_supply_capabilities.mjs --env prod
node tool/data/backfill_organizer_supply_capabilities.mjs --env prod --apply --allow-prod
```

The 2026-07-27 production run repaired 44 organizers and 42 compatibility
clubs; the post-apply dry run reported 86 current documents and zero remaining
repairs or invalid records. Deploy matching Functions before relying on the
projection. External-event publication/takedown must be smoke-tested through
the Admin dry-run-then-apply actions so the immutable receipt, organizer
ceiling, and outbound-only behavior are verified together.

## Smoke Tests

After a backend deploy, smoke test:

- Phone sign-in and onboarding continuation.
- Profile edit and public profile projection.
- Create/join/leave club.
- Create event, join free event, paid booking where enabled, waitlist, cancellation.
- Self check-in and host attendance.
- Swipe, match, chat message, unread count, block/report.
- Payment history, review prompt, notifications.
- Demo-data validation for the affected environment when demo tooling changed.

## Verifying Analytics, Crashlytics, And BigQuery

Observability collection is gated, so a normal debug `flutter run` deliberately
sends **nothing** — this is expected, not a bug.

### When collection is on

`AppConfig.shouldCollectObservability` (in `lib/core/app_config.dart`) controls
both Firebase Analytics and Crashlytics. It is true only when:

- the build is release mode **and** the environment is `prod`; or
- a release/profile build passes `--dart-define=ENABLE_OBSERVABILITY_COLLECTION=true`.

In a debug build it is always false: `AppAnalytics.initialize()` calls
`setAnalyticsCollectionEnabled(false)`, so even Firebase **DebugView shows
nothing** (DebugView requires collection to be enabled).

Do not use `GoogleService-Info.plist`'s legacy `IS_ANALYTICS_ENABLED` value as
standalone proof that collection is on or off, and do not hand-edit generated
Firebase config files to change it. The runtime gate above plus live DebugView
and release evidence are authoritative. Regenerate the environment/role plist
from Firebase only when the registered app configuration changes.

The Runner Crashlytics symbol-upload phase intentionally evaluates every
non-Debug build and declares no fake output artifact: release dSYM uploads must
not be skipped because Xcode cached a prior script result. The resulting
dependency-analysis warning is accepted build noise, not an open release
defect.

### How to verify Analytics events reach Firebase

1. Run with collection forced on (the env wrapper forwards the flag as a
   dart-define):

   ```bash
   ENABLE_OBSERVABILITY_COLLECTION=true ./tool/flutter_with_env.sh dev run
   ```

2. For iOS DebugView also add the launch argument `-FIRDebugEnabled`
   (Xcode scheme → Run → Arguments), or `adb shell setprop debug.firebase.analytics.app <applicationId>` on Android.
3. Exercise flows that call `AppAnalytics.logEvent` (auth, club view, booking,
   swipe, chat).
4. Confirm the events in Firebase Console → Analytics → **DebugView** for the
   matching environment's project.
5. Record the proof through the `observability-evidence.yml` workflow.

A smoke build can also emit a single canary event with
`--dart-define=EMIT_OBSERVABILITY_SMOKE_EVENT=true` (event name
`observability_smoke`).

### BigQuery — two separate exports, do not conflate them

- **Firestore → BigQuery**: configured in-repo. `firebase.json` declares the
  Event Success, participant metric, and host analytics operational export
  instances. Existing `bq-event-success-*` and `bq-participant-*` instances are
  installed in all three projects; newly declared `bq-host-*` instances must be
  deployed explicitly before host analytics marts can refresh from live data.
  Extension parameter changes are **not** part of the normal
  `deploy_firebase_targets.sh` target set — push them with an explicit
  `firebase deploy --only extensions` when changed.
- **GA4 → BigQuery**: a Google Analytics Admin product link, not repo config.
  Production is linked as of 2026-05-23: GA4 property `catch-dating-app-64e51`
  (`p526484083`) exports daily event data to BigQuery project
  `catch-dating-app-64e51` (`catch-dating-app`, project number
  `574779808785`) in `Mumbai (asia-south1)`. The expected dataset is
  `analytics_526484083`. All 6 streams are included, no events are excluded,
  and streaming export, mobile advertising identifiers, and daily user-data
  export are disabled. GA4→BigQuery only exports from the day it is enabled.
  Capture the dataset link/table proof in the `ga4_bigquery_evidence` input of
  `observability-evidence.yml` after the first daily table lands.
- **Host analytics marts**: source-controlled DDL and refresh SQL live under
  `analytics/sql/**`. `getHostAnalytics` and `adminGetHostAnalytics` read
  `catch_analytics.mart_host_event_daily`; `recordOrganizerAnalyticsEvent`
  writes aggregate-safe discovery events to
  `catch_analytics.host_analytics_events`. The mart also reads
  `analytics_526484083.events_*` for `organizer_<eventName>` GA4 exports when
  the dataset/tables exist, using the larger direct-vs-GA4 daily count per
  club/event/event-name key to avoid double-counting mirrored browser events.
  Apply the warehouse layer with
  `tool/analytics/deploy_host_analytics_bigquery.sh <env>` after deploying the
  `bq-host-*` extension instances.

## Automated Integration Test Backlog

Feature-flow integration tests should cover the same user journeys as the
manual smoke checklist, with Firebase, payment, notification, location, and
image-picker side effects replaced unless the test is explicitly device or
emulator backed.

- Auth and onboarding: phone entry, OTP continuation, profile-step resume,
  required-field validation, photo/running preference completion, and redirect
  to the authenticated shell.
- Routing and app shell: unauthenticated redirects, authenticated redirects,
  five-tab navigation, top-level route back behavior, FCM/deep-link chat routes,
  and inactive-tab stream gating.
- Dashboard: empty state, booked-event state, activity tab, next-event CTA,
  swipe-window CTA, and recommended-event navigation.
- Clubs: city selection, search, joined/discover partitioning, club detail,
  create club, edit club, join, leave, and host-only affordances.
- Events: create event, event detail, free booking, paid booking handoff, waitlist,
  cancellation, self check-in, host attendance, map view, and location picker.
- Catches and swipes: eligible attended-event list, swipe deck, empty candidate
  states, like/pass decisions, match creation result, and event recap.
- Chats: matches list, search, chat route hydration, message send, unread reset,
  block/report, and push/FCM route handling.
- Payments and reviews: payment confirmation, payment history, review prompt,
  create/update/delete review, and post-event review visibility.
- Profile and settings: inline profile edits, photo upload replacement,
  public-profile projection, notification preferences, sign out, and account
  deletion/anonymization entry points.
- Platform/device flows: App Check, real phone auth, push permission/token
  registration, image upload, real map rendering, Razorpay checkout, analytics
  DebugView, and Crashlytics visibility.

### Current Pending Integration Tests

Last updated: 2026-06-04.

The deterministic app-shell integration architecture is folded into this
release runbook. Run the split local suite with:

```bash
node tool/run.mjs run test:app-shell-integration
```

Pull requests that touch Flutter integration or golden surfaces run
`.github/workflows/visual-integration-ci.yml` on macOS. It executes the desktop
goldens with the checked 0.30% hosted-macOS raster tolerance, all deterministic
headless app-shell wrappers, and the bounded app-shell smoke through the native
macOS integration binding sequentially. It retains failure diffs and also runs
on a weekday schedule so platform drift cannot hide behind path filtering. The
tolerance has a focused known-good/known-bad regression test and must not be
widened to accept a visual change.

Use `bash tool/test_app_shell_integration.sh <device> smoke` for the bounded
native lane and `bash tool/test_app_shell_integration.sh <device> all` for every
native suite. The main Flutter workflow separately analyzes and builds
`widgetbook/` for web, runs the unit/widget suite with LCOV, publishes the raw
LCOV plus a handwritten feature-level Markdown summary, and deliberately does
not impose a global coverage percentage threshold. These are repository
integration gates; the live service/device evidence below remains separately
required for affected releases.

The split suite covers app-shell launch/routing plus focused club, event,
dashboard, Catches, chat, settings, review, and regression flows with service
side effects faked at repository/provider boundaries. Keep the pending
live-service tests below out of the default local suite unless they are made
emulator-backed or gated behind an explicit device/live-service test target.

| Area | Local code-side coverage now present | Pending test/evidence | Required environment |
| --- | --- | --- | --- |
| App Check | Backend errors map App Check failures; app bootstrap activates App Check in `main.dart`. | Prove enforced App Check accepts the app's token and rejects missing/invalid tokens for Auth, Firestore, Storage, and callable Functions. | Firebase dev/staging project with App Check enforcement enabled plus registered debug token or release attestation. |
| Real phone auth | App-shell integration covers phone entry, OTP continuation, and repository calls with a fake auth repository. | Complete a real OTP send and sign-in against Firebase Auth. | Physical iOS/Android device or Firebase Auth emulator; use a Firebase test phone number for repeatability. |
| Push permission and token registration | App-shell integration verifies authenticated shell invokes FCM initialization; routing tests cover FCM chat route handling; backend notification producers are covered separately. | Grant/deny notification permission, save a real FCM token to `users/{uid}.fcmToken`, receive a push, and tap it into the intended route. | iOS/Android device or simulator with push support and Firebase Messaging configured for the target app id. |
| Image picker and Storage upload | App-shell integration covers picking a club cover through the full routed UI and passing uploaded URL into create-club submission with a fake upload repository. | Pick media through the native picker and upload to Firebase Storage under enforced Storage/App Check rules. | iOS/Android simulator/device with photo-library permission and Firebase Storage in dev/staging. |
| Real map rendering | Create-event integration opens the map picker and selects a map coordinate through the `GoogleMap` widget callback. TestFlight iOS Maps behavior is verified through App Store Connect/Xcode Cloud TestFlight proof as of 2026-05-21. | Repeat real map tile/marker proof when Maps key injection, bundle IDs, or store distribution settings change; verify Android separately before Play release. | iOS/Android simulator/device with configured Google Maps/Places keys and network access. |
| Razorpay checkout UI | App-shell integration covers paid booking handoff and confirmation with a fake payment repository; payment repository tests cover typed Razorpay success/error callbacks and callable verification contract. | Open the native Razorpay checkout sheet, complete/cancel a test payment, and verify post-payment booking state. | iOS/Android device or simulator supported by `razorpay_flutter`, with Razorpay test keys and callable Functions. |
| Analytics DebugView | App-shell integration verifies route screen views reach `AppAnalytics`; unit tests cover event sanitization and collection gating. Dev/staging/prod Firebase projects are linked to GA4 properties under Analytics account `365970973`. Prod GA4 BigQuery export is linked to `catch-dating-app-64e51` in `asia-south1` with expected dataset `analytics_526484083`. | See expected auth/routing/booking/review events in Firebase Analytics DebugView for a real build, then record first BigQuery `events_YYYYMMDD` table proof once the daily export lands. | Debug or release-like app build connected to Firebase Analytics DebugView for the target app id. |
| Crashlytics visibility | App-shell integration verifies the authenticated uid is attached to the crash reporter on cold launch; unit tests cover fatal/error reporting paths. | Trigger a non-production test crash/non-fatal error and confirm it appears with expected custom keys and symbolication. | Release-like iOS/Android build with Crashlytics collection enabled for dev/staging and dSYM/mapping upload configured. |

Do not make these live-service tests block every PR until they have stable
fixtures, reset/cleanup steps, and documented credentials. Prefer a separate
manual or scheduled workflow that records release evidence.

For observability smoke proof, use a profile or release-like non-production
build with collection explicitly enabled:

```bash
ENABLE_OBSERVABILITY_COLLECTION=true \
EMIT_OBSERVABILITY_SMOKE_EVENT=true \
./tool/flutter_with_env.sh staging run --profile -d <device-id>
```

The smoke define emits one nonfatal Crashlytics event with reason
`Observability smoke event` and one Analytics event named
`observability_smoke`. Use it only for dev/staging evidence or a deliberate
prod release smoke. After the dashboard rows appear, run the manual
`Observability Evidence` workflow and record the app build, Crashlytics proof,
Analytics proof, and GA4 BigQuery export status.

## Mobile Internal Release Ownership

Decision updated 2026-08-13: GitHub Actions remains the canonical internal
mobile release owner for both Consumer and Host, but package production and
store mutation are separate authorities:

- `Mobile Internal Release` is a signed-package `workflow_run` consumer. It
  accepts a successful same-repository `main` CI authority, builds only exact
  role/platform targets, and publishes verified 90-day packages plus a strict
  aggregate build authority, then automatically hands authorized iOS targets to
  the separate promoter. It has no manual dispatch and no store mutation.
- `Mobile Internal Exact Promotion` receives an automatic dispatch for every
  authorized iOS target. It accepts one exact target and current producer
  attempt, derives the package id/digest from the verified aggregate authority,
  then uploads those already-signed bytes to TestFlight without rebuilding or
  resigning. Manual exact dispatch remains available for iOS or Play recovery.

`tool/app_targets.json` therefore declares
`successful-main-ci-exact-artifact-authority`,
`automatic-ios-exact-artifact-internal-promotion`, and
`separate-promotion-workflow` for both platforms. CI impact routing produces
exact `consumer-ios`,
`consumer-android`, `host-ios`, and `host-android` intersections; it never turns
one role into a two-platform matrix. The promoter serializes only the selected
target with a bounded non-cancelling queue and rejects ref, rerun-attempt,
producer-attempt, authority, package, or target substitution before credentials.
An unrelated `main` commit may land after dispatch: the promoter permits that
only when its dispatch SHA remains an ancestor of `main` and none of the exact
promotion workflow, manifest, package verifier, or store-operation sources
changed. Relevant release-code drift fails closed and waits for a fresh dispatch.
Public App Store or Play production promotion is never automatic in either
workflow; only internal TestFlight distribution is automatic.

After a verified store result and credential cleanup, the promoter writes one
`mobile-promotion-claim-v1-<target>-<package-artifact-id>-<signed-sha256>`
artifact containing only `mobile-promotion-receipt.json` and retains it for 90
days. For iOS this claim is persisted before group distribution, so a transient
group API failure can retry without creating a fresh build. A later dispatch may
reuse that claim only when the successful promotion
attempt, source CI and producer attempts, authority/package ids and digests,
signed-byte SHA-256, store target/version/build, and remote result all match.
The prior run may have succeeded, failed, or been cancelled after publishing the
claim; the claim is reusable because its exact upload postcondition was already
verified and persisted before the separate distribution operation began.
The separate `testflight-distribution-v1-...` artifact binds the remote build id,
exact package artifact id and signed-byte digest, selected internal group ids and
names, tester counts, relationship readback, and promotion attempt. For Apple,
an existing App Store Connect version/build identity is not proof of
which IPA bytes were uploaded. If `altool` succeeds but the exact claim cannot
be persisted, automatic exact recovery fails closed and a new build is
required; any operator reconciliation must remain explicitly non-exact and
cannot satisfy this claim contract. Google Play can retry an ambiguous first
result without a second upload only after its completed `qa` readback proves
the exact version code and remote SHA-256.

The producer resolves scheme, configuration, bundle id, and entrypoint from the
six-target manifest, then runs the package and platform gates before publishing
authority:

Every GitHub Actions `flutter build ios` entrypoint routes through
`tool/flutter_with_env.sh`. On CI only, that wrapper retries at most three times
when the failed output contains the exact GitHub HTTPS CocoaPods signature
`SSL certificate problem: self signed certificate`. It does not retry Dart,
Xcode, signing, configuration, or any other dependency error, and it never
disables TLS verification. Local builds remain single-attempt unless they are
running under the CI environment contract.

The same wrapper applies a separate CI-only retry to Android `apk` and
`appbundle` builds when the output contains both a transient Java socket
failure and the Gradle wrapper download stack. The ordinary wrapper default is
three attempts; the protected mobile producer allows five attempts with a
20-second delay because one failed matrix runner invalidates the aggregate
release authority. Consumer and Host use the same smaller binary-only Gradle
distribution from Gradle's immutable GitHub release and pin its published
SHA-256. The wrapper does not retry Gradle compilation, signing, Android
configuration, or unrelated network-looking errors. This keeps signed-package
production resilient to an interrupted distribution download without masking
deterministic product failures.

```sh
node tool/run.mjs check \
  ci:mobile-release-package \
  ci:mobile-release-workflow \
  ci:mobile-promotion-core \
  ci:mobile-promotion-workflow \
  platform:app-targets \
  platform:mobile-build-number \
  platform:verify-ios-release-identity \
  platform:verify-app-store-build \
  platform:verify-android-release-identity \
  platform:upload-google-play-bundle
```

It also checks `tool/firebase/client_callable_dependencies.json` immediately
after resolving the target. A disabled production feature reports `disabled`
and skips the live probe. An enabled Host callable dependency must return an
expected Firebase callable JSON rejection to an unauthenticated probe; 404,
redirect, HTML/GFE, IAM denial, unexpected success, and 5xx all block package
production.

`verify_ios_release_identity.mjs` checks both the archive and exported app for
the target marker, compiled Flutter entrypoint, bundle/display identity,
version/build, embedded Firebase bundle/app/project identity, Firebase OAuth URL
scheme, and role-specific signed entitlements. Consumer requires HealthKit and
Associated Domains. Host intentionally has neither; both roles require their
Push/App Attest contract. Xcode automatic signing may produce a development-signed
archive before distribution export, so the archive receipt verifies role and app
identity without treating it as store-ready proof. The exported IPA receipt is
strict: production entitlement values and an explicit `get-task-allow=false`
are required. The workflow separately validates the built prod Maps key, writes
stage-labelled JSON identity receipts, and records the IPA SHA-256. The separate
promoter cryptographically rebinds that receipt to the exact package bytes and
uploads the same verified IPA with `altool`; a second export after verification
is rejected by the app-target scanner.

Before archive, the workflow checks the proposed Apple build against the latest
200 App Store Connect builds for that app. Canonical GitHub iOS releases use an
18-digit `<UTC YYYYMMDD><8-digit GitHub run><2-digit attempt>` number, which is
above the legacy date/build namespace and unique to the source CI attempt. The
producer does not upload. Its post-authority handoff automatically dispatches
every authorized iOS target, and the exact promoter records the producer attempt,
store response, and internal group relationship readback. App Store processing
and TestFlight distribution are machine-verifiable; install and launch remain
physical-device evidence.

Android uses `100000 + workflow run number * 100 + attempt`; two reserved retry
digits prevent adjacent-run collisions. The verifier uses checksum-pinned
bundletool `1.18.3`, verifies JAR integrity and the checked upload-certificate
SHA-256, and reads compiled package, target/role, Firebase app/project, Maps,
debuggable, version-name, and version-code identity before any Play edit.

## TestFlight Status

Both roles have checked local/native composition, Firebase identity, distinct
store identity, App Store Connect records, and manifest-resolved GitHub archive
and exact-promotion paths. The producer deliberately stops at signed package
authority, then automatically dispatches the exact promoter for authorized iOS
targets. The promoter owns upload and existing-internal-group assignment;
installation and launch remain physical-device evidence.
`APP-TARGET-IOS-GITHUB-CUTOVER-001` remains open until current distribution
receipts plus installation and launch proof are recorded in GitHub issue `#218`.
`tool/app_target_external_gates.json` owns that stable external gate and the
matching Play gate without carrying run receipts. Update live evidence here and
in the owning Issues; an evidence-only update must never authorize new signed
mobile packages.

The current analyzer-clean split release is proven for both roles from the same
immutable producer authority. Producer run `31435724862` selected source
`9c3633095464778a1d5734d742ab3036e5f7cde7` and published authority artifact
`9081276899`. Consumer promotion run `31436879851` reused exact iOS package
artifact `9081248527`, uploaded version `1.0.2`, build
`202608100000030201`, to App Store Connect app `6765646860`, remote build
`13f755b5-508c-4acc-9a85-cea069e3425d`, and persisted exact claim artifact
`9081579386`. Host promotion run `31436882152` reused exact iOS package artifact
`9081211960`, uploaded version `1.0.1`, the same source-bound build number, to
app `6778927317`, remote build `0e37ff07-3f88-40fc-be88-fd23e36de60a`, and
persisted exact claim artifact `9081563645`.
Both postconditions reached `VALID`; neither promotion rebuilt, re-exported, or
re-signed its producer package. These historical claims prove upload and
processing, not TestFlight group assignment or installed-device behavior.
Promotions after the 2026-08-13 automation change also persist the separate
distribution receipt.

Consumer `1.0.2` is the first live proof of the split architecture. Main CI run
`31266032614` authorized source `c7be024a4e272d4a21759127a4fdd19e5752e30a`;
producer run `31266556052` created and verified only the Consumer iOS and
Android packages; promotion run `31267129848` reused iOS package artifact
`9024464806` and uploaded TestFlight build `202608080000018401` without any
Flutter build, Xcode archive/export, or signing command. Exact claim artifact
`9024637372` binds that package and signed-IPA digest to App Store Connect app
`6765646860`, version `1.0.2`, the remote build id, and all three workflow
attempts. It does not prove TestFlight group assignment or installed-device
behavior.

Consumer manual recovery run `30523657375` uploaded commit
`1cf9739e858e3e458cf1bf70e10d0d496938defe` after PR `#133`; build
`202607300000005101` reached App Store Connect `VALID`. That is historical
processing proof, not authority for automatic future uploads, tester-group
assignment, or installation. The 2026-08-13 policy automatically dispatches
exact iOS promotions from the verified producer while retaining a separate
manual recovery dispatch.

The pre-cutover Consumer dispatch `29161431098` successfully signed and archived
`com.catchdates.app`, then stopped before export because Xcode's archive
`Info.plist` contains a root `CreationDate` that cannot be converted wholesale
to JSON. The verifier now extracts `ApplicationProperties` and has a regression
test for that real plist shape. The failed dispatch is diagnostic evidence, not
TestFlight upload proof.

The first unified main run `29165188541` proved the credential and build-number
preflight, then exposed that the verifier incorrectly treated a development-signed
archive as a distributable app (`aps-environment=development`,
`get-task-allow=true`). Run `29166191690` then proved why forcing
`Apple Distribution` is not the fix: both iOS jobs failed because that manual
identity conflicts with automatic signing, while both Consumer and Host Android
jobs built, verified, and uploaded their signed AAB artifacts successfully. The
corrected contract leaves archive signing automatic, lets `xcodebuild
-exportArchive` re-sign with `ios/ExportOptions.prod.plist`, and reserves strict
distribution-entitlement enforcement for the exported IPA. The checked IPA is
then uploaded directly instead of asking Xcode to export a different binary for
upload.

Run `29168074271` on main SHA
`05a3a5811a9c20ec82d14a4b04114c4538acfdd2` closed the upload and processing
proof on 2026-07-12. Both role jobs archived, verified, exported, uploaded the
same checksum-verified IPA, and reached App Store Connect `VALID` as build
`202607110000000301`. Its Consumer and Host processing receipts are bound to
that exact GitHub run. Retirement dispatch `29168662623` downloaded those
receipts, re-verified both live builds, and disabled both app-scoped `Default`
workflows. Independent App Store Connect reads confirmed both remain disabled.

Run `29388936845` on main SHA
`6d042bc77ef943b1278013906c3dec3714586771` failed both iOS archive jobs on
2026-07-15 after Xcode reported the Apple Development certificate limit and no
matching iOS App Development profile for either production bundle id. Android
completed successfully. Live inventory proved that 17 API-created development
certificates had no surviving private key or live profile relationship; two
additional human-named development certificates also had no private key or live
profile relationship. All 19 were revoked by exact id. The remaining live set
was reduced to the working human Apple Development, Apple Distribution, and
Developer ID identities, then dedicated reusable CI development certificate
`7P698XNLRP` was added. Do not rerun `29388936845`: its old workflow does not
import the reusable private key and would recreate the leak.

Historical pre-split cutover status (completed on 2026-07-12):

1. Complete: both GitHub role jobs archive, verify, export, and upload.
2. Complete: both exact builds finish processing in App Store Connect.
3. Complete: the Consumer workflow
   `93EC2EEF-494E-492D-8574-570AA8BF690E` and Host workflow
   `1F97B043-9337-427B-854C-6F88F2110020` are disabled. GitHub/App Store status
   surfaces may prefix them as `Catch | Default` and `Runner | Default`; the
   app-scoped API name is `Default` for each app.
4. Superseded by automation: the exact promoter now records and assigns every
   existing internal TestFlight group that already contains testers.
5. Pending: install and launch both GitHub-owned builds with App Check, Maps,
   phone auth, push, and role-specific entrypoint proof.

Items 1-3 describe the earlier combined workflow and remain historical evidence
only. The current split producer and exact promoter are now exercised for both
iOS roles: producer run `31435724862` created the exact packages, Consumer
promotion `31436879851` and Host promotion `31436882152` uploaded those packages
without rebuilding, both App Store Connect builds reached `VALID`, and exact
claim artifacts `9081579386` and `9081563645` bind the remote results. Only live
distribution receipt evidence, installation, and device smoke proof remain open
in issue `#218`. Google Play remains externally blocked by
developer-account verification and missing app records in issue `#199`; the
exact Consumer and Host Android packages are retained for promotion after that
account gate clears.

Current host icon status: host builds use generated `AppIcon-host-dev`,
`AppIcon-host-staging`, and `AppIcon-host-prod` catalogs on iOS/macOS, plus
Android `hostDev`, `hostStaging`, and `hostProd` launcher resources. The
two-line icon and centered light/dark splash read `Catch Host` in the same
explicit Archivo `wght: 600` / `wdth: 78` voice as Consumer; there is no system
font fallback and no plural `Hosts` product mark. Regenerate the Swift masters
and then run `dart run tool/branding/generate_native_brand_assets.dart` after
native brand-token, icon, or splash changes.

## Legacy Xcode Cloud State

The old 12 a.m. scheduled Consumer Xcode Cloud build was retired live in App
Store Connect on 2026-05-21. The later Consumer and Host app-scoped `Default`
workflows were disabled on 2026-07-12 after the exact GitHub builds reached
`VALID`. They may appear in status contexts as `Catch | Default` and
`Runner | Default`, but the App Store Connect API returns the exact workflow
name `Default` for each distinct app. GitHub Actions is the sole routine release
owner; do not reactivate these workflows except for an explicit rollback.
The former `retire_xcode_cloud` operation was a bounded cutover tool: it required
exact processed Consumer and Host GitHub build numbers and matching processing
receipts before disabling the two named workflows. That input no longer exists.
Neither the package producer nor the exact promoter can mutate Xcode Cloud.

The unused prototype App Store Connect record `catch_dating_app` (app id
`6738610809`, bundle id `com.example.catchDatingApp`) was removed on 2026-07-12
after API inventory proved it had no builds, prerelease versions, beta groups,
or commercial products. Its disabled Xcode Cloud product
`26D4F6B6-7D4F-4FC8-8B34-6B5D9FB9C692` had zero build runs and was deleted; the
active `Catch Dating` and `Catch Host` records were re-listed afterward.

Current App Store Connect file/folder rules:

- Any file from `/lib`
- Any file from `/ios`
- Any file from `/assets`
- Any file from `/contracts`
- File name `pubspec.yaml` from any folder
- File name `pubspec.lock` from any folder
- Any file from `/tool`
- Any file from `/firebase/prod`

These historical rules live in App Store Connect, not repository YAML. They are
retained only for audit traceability; do not reactivate them as routine upload
triggers.

If a backend change intentionally requires a compatible app binary, land the
corresponding mobile source/config change so CI selects the exact affected
role/platform target after the backend contract is ready. `Mobile Internal
Release` has no manual dispatch; do not manufacture an unplanned package by
rerunning or bypassing its CI authority.

GitHub Actions iOS jobs write `ios/Flutter/GoogleMapsKeys.xcconfig` through
`tool/write_ios_maps_key_xcconfig.sh <env>`. The simulator build matrix uses
`dev`; TestFlight release builds use `prod`. If a legacy Xcode Cloud workflow is
deliberately re-enabled for rollback, its scripts must use the same helper and
prod key. Keep Maps-key validation there instead of duplicating secret preflight
logic in each CI surface.

## Legacy Xcode Cloud Build Scripts

The checked Xcode Cloud scripts remain as rollback and audit support while
`APP-TARGET-IOS-GITHUB-CUTOVER-001` is active. They are not the routine release
owner.

Two CI scripts drive it:

- `ios/ci_scripts/ci_post_clone.sh` reads the Flutter SDK version from
  `tool/ci/toolchain.env`, installs Flutter and Node, applies the prod Firebase
  environment for `consumer` or `host`, writes the prod iOS Google Maps key, and
  runs `pod install`. It uses `CATCH_APP_ROLE=host` or a `host-*` Xcode scheme to
  prepare the manifest-resolved `lib/main_host_prod.dart` composition.
- `ios/ci_scripts/ci_post_xcodebuild.sh` runs the release-identity verifier
  against the archive, writes `build/ios/release-evidence/<role>-xcode-cloud-archive.json`, and verifies the archived
  `GoogleMapsApiKey` before the build can reach TestFlight.

GitHub Actions read the same `tool/ci/toolchain.env` file through local actions
under `.github/actions`. Update that file instead of editing workflow YAML or
Xcode Cloud scripts when changing public tool versions such as Flutter, Node,
Java, or Firebase CLI.

`ios/Flutter/GoogleMapsKeys.xcconfig` is gitignored, so it is never present in a
fresh clone. The Xcode Cloud workflow must define `GOOGLE_MAPS_IOS_API_KEY_PROD`
as a secret environment variable; `ci_post_clone.sh` calls
`tool/write_ios_maps_key_xcconfig.sh prod` to write the xcconfig and fail the
build if the key is missing or malformed. Without the key the archived
`GoogleMapsApiKey` is empty, `GMSServices.provideAPIKey` is skipped in
`AppDelegate`, and every map screen crashes at runtime.

If a legacy Xcode Cloud build is deliberately re-enabled for recovery, it must
inject and verify the environment-specific Maps key. The GitHub candidate-floor
check will reject any later build number that is not above the resulting build.

## GitHub-Only Migration Status

The repository migration is implemented as two Actions authorities: the
CI-triggered producer owns exact role/platform signed iOS/Android packages and
automatically dispatches authorized iOS targets, while the exact promoter owns
one verified TestFlight or Play `qa` mutation without rebuilding. Consumer and
Host iOS both upload automatically from an affected successful `main` push;
Android Play remains a manual recovery dispatch while its external account gate
is open.

Consumer and Host exact upload and processing plus legacy-owner retirement are
complete. `APP-TARGET-IOS-GITHUB-CUTOVER-001` remains open only for current
automatic distribution receipt and install/launch proof in issue `#218`.
`APP-TARGET-ANDROID-PLAY-001` remains blocked in issue `#199` on Play developer
account verification, app-record creation, App Signing, publisher access,
processing, testers, and device proof.

Cutover checklist:

1. Complete historical evidence: Consumer and Host GitHub uploads and App Store
   processing from the pre-split workflow.
2. Complete: both legacy Xcode Cloud workflows disabled.
3. Complete: current analyzer-clean Consumer and Host exact promotions processed
   in runs `31436879851` and `31436882152` with 90-day exact claims.
4. Record both automatic TestFlight distribution receipts and install/launch
   proofs in issue `#218`.
5. Complete the Play owner-verification, app-record, App Signing, tester, and
   publisher-access steps in issue `#199`, then rerun the exact promoter.
6. Record both Play internal
   processing/install/launch proofs and signing
   fingerprints.

The repository can verify that the GitHub `prod-mobile` environment has the
required App Store Connect secret names and that the local/Xcode Cloud scripts fail
loudly when required release secrets are missing. The exact promoter can prove
TestFlight group membership and build access through App Store Connect API
readback. It cannot prove installed-device behavior, export-compliance prompts,
privacy, or review metadata state without direct account or device evidence.

## Human Release Evidence

Already confirmed outside repository checks:

- TestFlight upload, install, launch, and iOS Maps behavior through the App
  Store Connect/Xcode Cloud build process before the nightly schedule was
  retired.
- Consumer and Host GitHub build `202607110000000301` reached App Store Connect
  `VALID` from run `29168074271`; receipt-gated run `29168662623` then disabled
  both legacy Xcode Cloud workflows.
- Consumer GitHub build `202607300000005101` from commit `1cf9739e` reached App
  Store Connect `VALID` in recovery run `30523657375`.

These still require human confirmation outside repository checks:

- Install and launch through the GitHub-owned Consumer and Host pipeline; group
  assignment itself is now API-verified by the automatic distribution receipt.
- Consumer and Host Play internal-testing evidence.
- Crashlytics visibility and symbolication evidence.
- Analytics DebugView event evidence.
- Store metadata, screenshots, privacy forms, support URL, privacy policy, and
  terms URL.

Run `Release Readiness` before store submission and `Observability Evidence`
after generating Crashlytics/Analytics proof.

## Store Product Backlog

The old production-release checklist was consolidated into this section on
2026-05-21. Keep store/account/product release tasks here instead of creating
another Codex audit checklist.

| Area | Remaining decision or proof |
|---|---|
| In-app reviews | Add `in_app_review`, choose high-satisfaction trigger moments, throttle prompts, and add a settings fallback after store IDs exist. |
| Legal and support links | Confirm public privacy, terms, support/contact, and account-deletion URLs; expose them from the settings surface and store metadata. |
| Accessibility | Run a large-text, VoiceOver/TalkBack, contrast, hit-target, and semantics pass across auth, onboarding, dashboard, clubs, events, catches, chat, and profile/settings. |
| Store metadata | Finalize listing name, screenshots, privacy forms, export-compliance answers, support URL, privacy policy, terms URL, and review notes. |
| Play internal testing | Produce Android internal-testing install/launch/maps evidence before Play release. |
| Observability | Capture Crashlytics visibility/symbolication and Analytics DebugView proof with a release-like dev/staging build. |
| Feature toggles and A/B testing | Defer until there is a concrete rollout problem; do not introduce a toggle framework as release ceremony. |
| Shorebird/code push | Defer for first release. Reconsider only after app-store release operations are stable and rollback policy is explicit. |
