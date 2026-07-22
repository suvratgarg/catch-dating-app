#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {relativeToRepo, repoRoot} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const command = args[0] ?? "--check";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--check" || command === "check") {
  runGate();
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function runGate() {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-design-parity-"));
  const fingerprintsPath = path.join(tmpDir, "fingerprints.json");
  const cleanup = () => fs.rmSync(tmpDir, {recursive: true, force: true});
  process.once("exit", cleanup);
  const fingerprintsArg = JSON.stringify(relativeToRepo(fingerprintsPath));
  const blocking = [
    `dart run tool/widget_dedupe/bin/extract_fingerprints.dart --out ${fingerprintsArg}`,
    "node --test tool/design/component_concepts.test.mjs",
    "node tool/design/check_component_contracts.mjs",
    "node tool/design/check_widget_classification.mjs",
    `node tool/design/build_widget_similarity.mjs --fingerprints ${fingerprintsArg} --fingerprints-label artifacts/widget_dedupe/fingerprints.json --check`,
    "node tool/design/check_widget_pattern_families.mjs --check",
    "node tool/design/import_figma_library_snapshot.mjs --check",
    "node tool/design/build_design_sync_manifest.mjs --check",
    "node tool/design/build_widget_concept_report.mjs --check",
    "node tool/ui_capture/check_route_inventory.mjs --check",
    "node tool/ui_capture/check_capture_coverage.mjs --check --summary",
    "node tool/design/check_design_parity_matrix.mjs --check",
    "node tool/design/check_comprehensive_todo_summary.mjs --check",
    "node tool/design/check_screen_coverage.mjs --check --summary",
    "node tool/design/check_screen_contracts.mjs --check --summary",
    "node tool/design/check_feature_coverage.mjs --check",
    "node tool/design/build_feature_contracts.mjs --check",
    "node tool/design/check_screen_top_bar_contracts.mjs --check",
    "node tool/design/check_widgetbook_contract_refs.mjs --check",
    "node tool/design/check_widgetbook_coverage.mjs --check",
    "node tool/design/check_widget_dedupe_probes.mjs",
    "node tool/design/check_reference_screens.mjs --check --summary",
  ];
  const advisory = [
    "node tool/design/check_screen_coverage.mjs --advisory",
    "node tool/design/check_screen_contract_hygiene.mjs --summary",
    "node tool/design/check_screen_gutters.mjs --summary",
    "node tool/design/check_section_dividers.mjs --summary",
  ];

  for (const commandLine of blocking) {
    run(commandLine, {required: true});
  }
  for (const commandLine of advisory) {
    run(commandLine, {required: false});
  }

  process.removeListener("exit", cleanup);
  cleanup();

  console.log("Design parity checks passed.");
}

function run(commandLine, {required}) {
  console.log(`==> ${commandLine}`);
  const result = spawnSync(commandLine, {
    cwd: repoRoot,
    shell: true,
    stdio: "inherit",
  });
  if (result.status !== 0 && required) {
    process.exit(result.status ?? 1);
  }
  if (result.status !== 0) {
    console.warn(`Advisory command failed: ${commandLine}`);
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/design/check_design_parity.mjs --check

Runs the standard local design parity gate. Blocking checks validate component
concept topology, contracts, classification, normalized-member-set decision
coverage, pattern-family decisions, Figma/Claude sync drift, quantitative
report drift, role-derived Widgetbook obligations, seeded dedupe probes, route
inventory, capture coverage, screen coverage, screen
contracts, screen-chrome ownership, state matrix, comprehensive todo summaries,
exhaustive cross-surface feature coverage, feature orchestration contracts, and
Widgetbook references. Advisory checks print known screen-contract migration
debt without failing the gate.`);
}
