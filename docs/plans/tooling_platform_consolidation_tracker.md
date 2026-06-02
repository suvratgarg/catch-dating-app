---
doc_id: tooling-platform-consolidation-tracker
version: 1.2
updated: 2026-06-01
owner: engineering
dri: TBD
status: remaining_work
priority: P0
---

# Tooling Platform Consolidation - Remaining Work

This tracker was reconciled against the live worktree on 2026-06-01. It now keeps
only the work that is not implemented, not landed, or not verified.

## Implemented / Closed

- `tool/run.mjs` manifest validation exists and `node tool/run.mjs check --manifest-only`
  passes.
- Live manifest size is **70 tools across 15 categories**.
- Scanner/lint/root-wrapper tooling is registered in `tool/tools_manifest.json`.
- `tool/README.md` documents the tool layout, scanner family, analyzer plugin lints,
  remote ops manifest, and synthetic persona projection.
- `tool/check_remote_ops_manifest.mjs --check` validates the remote-ops index.
- UI capture route inventory, capture coverage, and capture runner exist.
- Marketing screenshot export, website sync, and checked design JSON artifact exist.
- Design context pack builder exists and is manifest-registered.
- Persona profile projection exists and the planned-asset artifact check passes.
- Persona profile projection now requires explicit `--asset-statuses` and rejects empty
  projections unless `--allow-empty` is passed.
- UI capture fixtures read the checked planned persona projection artifact.
- Route inventory, capture coverage, and design context pack checks pass.
- Contract generator check-mode work is implemented.
- Design-token shell scanners `tool/check_design_tokens.sh` and
  `tool/check_raw_color_sweep.sh` are gone in the current worktree.
- `check_ui_local_constant_wrappers.sh --summary` and
  `check_ui_allow_debt.sh --summary` both return `0`.
- Legacy design preview tools no longer reference the retired Electric Sunset/Nitron
  exploration names.
- `seed-world` now consumes the checked sales demo persona profile projection for
  synthetic seed identities while keeping event/club/payment generation in the seed tool.
- `test/goldens/profile_view_test.dart` renders profile identity/copy from the shared
  projection and updates deterministically.
- Manual remote-op entries now require `owner`, `ticket`, and `guardrail` metadata, and
  `tool/check_remote_ops_manifest.mjs --check` enforces that contract.
- Historical one-time migrations under `tool/migrations/` are explicitly labeled as
  audit-only and require `--owner-ticket` before `--apply`.
- Stale UI modernization backlog references were reconciled against the current club
  artwork and UI elevation state.

## Remaining Work

### A. Land / Split Safely

The worktree is still very dirty and includes broad UI, docs, tooling, generated, and
test changes. The old PR A-E decomposition is still useful as a publish strategy, but
the exact slices should be recalculated from current `git status`.

Acceptance:

- tooling/lint/capture/design-pack changes are not buried in an unrelated UI PR;
- each PR is independently green;
- `node tool/run.mjs check --manifest-only` passes in each slice;
- broader checks are run only for the slice they protect.

### B. Persona Photo Upload Gate

1. **Promote/upload persona photos before live seed writes depend on them.**
   - Planned photos exist; uploaded projection currently has zero photos.
   - Capture/golden fixtures intentionally avoid loading planned remote photo URLs until
     the projection advertises uploaded assets.
   - Acceptance: uploaded projection is non-empty before any live seed path requires
     uploaded assets.

### C. Cleanup / Retirement Candidates

These require owner confirmation before deletion.

- Legacy data retirement tools should be removed only after prod confirmation and remote
  manifest cleanup.

## Definition Of Done

This initiative is complete when:

1. The tooling PR(s) are landed independently from unrelated UI work.
2. `node tool/run.mjs check --manifest-only` passes.
3. Seed-world and at least one golden consume the shared persona projection.
4. Uploaded persona photos are available before live seed writes require them.
5. Remote write/manual ops have enforceable guardrails or explicit owned tickets.
6. Remaining cleanup candidates are deleted, archived, or explicitly kept.

## Verification Commands

```bash
node tool/run.mjs check --manifest-only
node tool/ui_capture/check_route_inventory.mjs --check
node tool/ui_capture/check_capture_coverage.mjs --check
node tool/demo/demo_ops.mjs persona-profile-projection --asset-statuses planned --output tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json --check
node tool/marketing/export_app_screenshots.mjs --check
node tool/marketing/export_app_screenshots.mjs --design-json
node tool/marketing/export_app_screenshots.mjs --check-design-json
node tool/marketing/sync_website_media.mjs --check
node tool/check_remote_ops_manifest.mjs --check
node tool/design/build_context_pack.mjs --check
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_allow_debt.sh --summary
```
