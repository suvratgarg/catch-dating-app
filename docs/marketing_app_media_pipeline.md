---
doc_id: marketing_app_media_pipeline
version: 1.6.0
updated: 2026-10-06
owner: marketing_website
status: active
---

# Marketing App Media Pipeline

The website should not hand-author app screenshots. Marketing pages consume
records generated from `tool/marketing/capture_manifest.json`, and the sync
tool verifies whether the checked-in website assets still match the app capture
source.

## Capture Lifecycle

Each capture has one of three statuses:

| Status | Meaning |
|---|---|
| `pending-fixture` | The website uses a checked-in placeholder until the synthetic demo fixture and screenshot harness are ready. |
| `active` | `sourcePath` must exist, is copied to `website/public/assets/app-screenshots/`, and CI compares source and website image bytes. |
| `paused` | The capture is excluded from the generated website manifest. |

When the synthetic host/member fixture is ready, flip the relevant capture from
`pending-fixture` to `active`, generate the app screenshot into its `sourcePath`,
then run:

```sh
node tool/marketing/sync_website_media.mjs --update
node tool/marketing/sync_website_media.mjs --check
```

## Website Contract

Website pages render React `CaptureCard` components keyed by
`data-capture-slot="<capture-id>"`. `website/src/App.tsx` loads
`/assets/app-screenshots/manifest.json` and swaps in the active asset path,
caption, alt text, walkthrough step, and status label.

The capture cards on `/explore/` consume these slots through
`useMarketingCaptures()`. Capture selection and copy belong to the manifest.
The homepage hero and `/host/` currently use authored React illustrations;
regenerating app captures does not update those illustrations. Replacing them
requires a separate content decision.

Marketing styling imports the shared React web token layer from
`packages/web-config/styles/catch-web.css`; the generated token CSS itself is
owned by `dart run tool/design_tokens.dart`.

## CI Behavior

`tool/tools_manifest.json` registers `marketing:app-media-sync`, so
`node tool/run.mjs check` runs the marketing media check with the rest of tool
CI. Pending captures pass only if their placeholders exist and the generated
website manifest is current. Active captures fail if the source image is missing, is not a framed
1020×1964 iPhone 17 Pro PNG, lacks canonical render provenance, has changed
image bytes or capture inputs, or differs from its website copy. The generated
website manifest must also be current. Both sync commands run the exporter
check before copying or accepting any active image.

The exporter embeds one `caPt` ancillary chunk in each framed PNG. It records
the catalog id, fixture key, native iOS recipe/font hash, source revision, PNG
byte hash, and capture input hash. Inputs include the capture runner/catalog,
local transitive Dart imports/exports/parts (including production widgets and
fixtures), canonical scenario/persona JSON, declared assets/fonts, package
manifests/lock, framing/export tools,
and pinned toolchain configuration. The catalog is shared, so an input change
can conservatively invalidate multiple slots. Adding an asset to a declared
directory also invalidates captures. No machine-specific font path or font
bytes are distributed.

This check proves the recorded render still matches its inputs and rejects
stale committed copies; it does not perform a fresh render in Linux CI or
automatically approve a visual change. Native-font rendering can use the manual hosted exporter below; review remains
an explicit operation. The Marketing Website workflow also triggers on app
source, test/capture support, local package source/assets, dependency manifests,
synthetic scenario/persona inputs, and framed source PNGs. Its existing media
check rejects stale inputs before packaging; it does not silently regenerate or
accept golden baselines. The revision identifies the capture source commit;
input hashes also cover edits made before capture and survive unrelated
commits. Do not manually stamp old PNGs. Regenerate and inspect affected
captures, then sync. Raw selected outputs are cleared before rendering to
prevent accidentally reusing an earlier run.

## Fixture Boundary

Host slots use the named `host-marketing-india.json` scenario through the existing
`SalesDemoHostScenarioFixture` reader and synthetic builders. The shared
`host-demo.json` NYC seed world and persona projection remain independent.
The named scenario has no `seedWorld` configuration and is display-only capture
input: fictional Evening Club in Mumbai, Saturday Trivia Social at Harbour
Room, free INR 0 registration with open capacity 30, and one event id across
setup, Today, live, and recap. Planning is 0 booked/0 checked in; Today is 24/0;
live and follow-up are 24/18, with no waitlist. Recap has no fabricated scorecard
or reviews. The existing Host Today catalog entry has its own canonical slot.

The scenario explicitly records 17 October 2026, 18:30–20:30 Asia/Kolkata and
civil phase clocks: planning 16 October 12:00, Today 17 October 16:00,
live 17 October 19:00 and follow-up 18 October 10:00, all Asia/Kolkata. Production draft restore consumes local civil fields,
so the fixture constructs those fields in the capture process's local
representation instead of converting a UTC epoch. The focused restore test is
run under UTC, America/Los_Angeles and Asia/Kolkata. These values are never
submitted to a backend. The production fixed Pub quiz activity selects a team playbook, so this host-led
story uses the existing custom activity control labelled Trivia social with
`hostLedProgram`. The Guide selects the existing welcome and safety
modules, alongside mandatory platform modules (including attendance, guest
help, feedback and analytics); compatibility, reveal and
automated assignments are not selected. Production price/capacity/admission
controls remain visible without retouching.

These are draft synthetic render assets. Source support for free/open mode and
passing source tests does not establish the exact target build's route, flags,
backend configuration or public/store availability. Publication remains an
owner decision after target-build verification. `active` describes the local
media pipeline, not approval of a product availability claim.

## Rendering And Review

The implemented exporter maps manifest fixture keys to production screen builders
in `test/ui_captures/catalog/screen_capture_catalog.dart`. The export-only
`capture_runner_test.dart` renders those widgets using synthetic fixtures; it
does not compare or update golden baselines.

```sh
node tool/marketing/export_app_screenshots.mjs --list
node tool/marketing/export_app_screenshots.mjs --update --ids member-event-discovery
node tool/marketing/sync_website_media.mjs --update
node tool/marketing/sync_website_media.mjs --check
```

Select ids from `--list`. Review the generated source PNGs before sync. Rendering
and syncing local assets does not publish the website.

The iPhone export renders at the final frame's 2x pixel ratio with explicit iOS
widget behavior. It loads the local macOS system font by default; another host
must provide `--sf-font <path>` to an available native iOS font. Font files stay
local and are never copied into website assets. Generic review captures can
choose `--platform ios --sf-font <path>` via `tool/ui_capture/run_captures.mjs`;
without those options they retain the deterministic test platform/font setup.
An iPhone device geometry alone does not establish iOS typography.

Design rules govern the implementation. Fresh rendered review validates the
result; a reviewed golden baseline then records it for regression detection.
An existing golden is not authority for spacing, typography, or an invalid
configuration. Product exports reuse production widgets and fixtures, without
requiring the UI to match an old image. Keep export, review, baseline updates,
and website sync as distinct explicit operations.

The six create-event slots are views of the current three-step production
wizard: Basics, schedule and meeting-location views within When & where, booking
policy and expanded guide views within Booking & live guide, plus the final
review summary.
They are not six wizard steps. Location scrolls to `WhereStep`; Guide opens the
production customization disclosure. Catalog ids and website slot ids remain
stable so existing consumers keep their coverage.

## Manual Hosted Export (CAT159 Enabling Slice)

`.github/workflows/marketing-captures.yml` runs the existing canonical exporter
on a standard GitHub-hosted `macos-26` runner, with repository-pinned Flutter
and Node and the runner's local SFNS font. It accepts only a full lowercase
40-character source commit SHA from this repository, and checks it out
separately from the immutable workflow/exporter commit. Source and exporter
toolchain pins must match; dependency resolution enforces the source lockfile.
A clean source checkout and all 12 active canonical slots are required.

Execution prerequisite: GitHub requires the workflow file on the default
branch before `workflow_dispatch` can run it. Admit and integrate this enabling
PR through the existing owner-controlled queue first. A draft PR does not
establish hosted rendering success. After registration:

```sh
gh workflow run marketing-captures.yml --ref main -f source_sha=<full-source-sha>
```

Use the currently published exact head of each product PR; short SHAs and local
unpublished Programs commits cannot be dispatched. The job runs at most 12
canonical catalog entries through the real iOS/SF Flutter capture path, frames
the 12 light marketing exports, regenerates design context, syncs website
copies, then runs the existing provenance, input freshness, framing and
copy-byte checks. All old final outputs are removed first. Any render/check
failure prevents artifact upload; there is no stale image fallback.

The seven-day immutable artifact is named
`canonical-marketing-<source-sha>-<run-id>-<attempt>`. It contains exactly the
12 framed source PNGs, their 12 website copies, authored capture manifest,
website manifest, design context, and `capture-receipt.json`. The receipt
records per-file hashes/sizes, embedded PNG provenance, exact source SHA/tree,
workflow SHA, helper hash, toolchain/runner identity and run/attempt URL.
The job summary records the upload's artifact ID, digest and download URL;
retain that identity together with the receipt when reviewing or handing off.
SF font bytes, dependency caches and arbitrary checkout files are excluded.

Tracked changes outside the declared media/design outputs fail packaging,
including source and golden baseline changes. Existing CI freshness and real
regression golden obligations remain independent and unchanged. This workflow
only exports reviewable synthetic media: it does not commit it, import it into
another branch, publish a website, or prove product/backend availability.
Automatic producer/consumer wiring, screenshot promotion and generated widget
or route inventory ownership remain the wider CAT159 follow-on.
