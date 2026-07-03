#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const dart = findDart();
const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "widget-dedupe-probes-"));
const fingerprintsPath = path.join(tmpDir, "fingerprints.json");
const similarityPath = path.join(tmpDir, "similarity.json");
const fixtures = [
  "tool/widget_dedupe/fixtures/probe_dupe_a.dart",
  "tool/widget_dedupe/fixtures/probe_dupe_b.dart",
  "tool/widget_dedupe/fixtures/probe_near_c.dart",
  "tool/widget_dedupe/fixtures/probe_distinct.dart",
  "tool/widget_dedupe/fixtures/probe_alpha_status_pill.dart",
  "tool/widget_dedupe/fixtures/probe_beta_status_pill.dart",
];

if (process.argv.includes("--help") || process.argv.includes("-h")) {
  console.log(`Usage:
  node tool/design/check_widget_dedupe_probes.mjs

Runs seeded structural probes for the widget dedupe extractor and clustering tool.
`);
  process.exit(0);
}

run(dart, [
  "run",
  "tool/widget_dedupe/bin/extract_fingerprints.dart",
  "--files",
  fixtures.join(","),
  "--out",
  relativeToRepo(fingerprintsPath),
]);
run(process.execPath, [
  "tool/design/build_widget_similarity.mjs",
  "--fingerprints",
  relativeToRepo(fingerprintsPath),
  "--out",
  relativeToRepo(similarityPath),
]);

const fingerprints = readJson(fingerprintsPath);
const similarity = readJson(similarityPath);
const byName = new Map(fingerprints.widgets.map((widget) => [widget.name, widget]));
const failures = [];

expect(byName.get("ProbeDupeA")?.shapeHash === byName.get("ProbeDupeB")?.shapeHash,
  "ProbeDupeA and ProbeDupeB must produce identical shapeHash");
expect(
  byName.get("ProbeAlphaStatusPill")?.shapeHash !==
    byName.get("ProbeBetaStatusPill")?.shapeHash,
  "small-widget probes must differ in fine shapeHash",
);
expect(
  byName.get("ProbeAlphaStatusPill")?.coarseShapeHash ===
    byName.get("ProbeBetaStatusPill")?.coarseShapeHash,
  "small-widget probes must match in coarseShapeHash",
);
expect(hasStructuralSignal(similarity, "ProbeDupeA", "ProbeNearC"),
  "ProbeNearC must produce a structural signal with ProbeDupeA");
expect(hasStructuralSignal(similarity, "ProbeAlphaStatusPill", "ProbeBetaStatusPill", "small-widget"),
  "small-widget probes must produce a small-widget structural signal");
expect(hasNameFamily(similarity, "StatusPill", ["ProbeAlphaStatusPill", "ProbeBetaStatusPill"]),
  "small-widget probes must produce a StatusPill name family");
expect(!hasStructuralSignal(similarity, "ProbeDupeA", "ProbeDistinct"),
  "ProbeDistinct must not structurally edge with ProbeDupeA");
expect(!hasStructuralSignal(similarity, "ProbeDupeB", "ProbeDistinct"),
  "ProbeDistinct must not structurally edge with ProbeDupeB");

if (failures.length > 0) {
  console.error("Widget dedupe probes failed:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log("Widget dedupe probes passed.");

function hasStructuralSignal(registry, a, b, signal = null) {
  return [...(registry.relatedEdges ?? []), ...(registry.rankedPairs ?? []), ...(registry.clusters ?? []).flatMap(cluster => {
    const members = cluster.members ?? [];
    return members.includes(a) && members.includes(b)
      ? [{a, b, signals: cluster.structuralSignals ?? []}]
      : [];
  })].some((edge) =>
    ((edge.a === a && edge.b === b) || (edge.a === b && edge.b === a)) &&
      (edge.detectors ?? ["structural"]).includes("structural") &&
      (signal === null || (edge.signals ?? []).includes(signal)),
  );
}

function hasNameFamily(registry, stem, members) {
  return (registry.nameFamilies ?? []).some((family) =>
    family.stem === stem && members.every((member) => family.members.includes(member)),
  );
}

function expect(condition, message) {
  if (!condition) failures.push(message);
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: fromRepo(),
    encoding: "utf8",
    stdio: "pipe",
  });
  if (result.status !== 0) {
    console.error(result.stdout);
    console.error(result.stderr);
    process.exit(result.status ?? 1);
  }
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function findDart() {
  const candidates = [
    process.env.DART,
    path.join(os.homedir(), "development/flutter/bin/dart"),
    path.join(os.homedir(), "Development/flutter/bin/dart"),
    "dart",
  ].filter(Boolean);
  for (const candidate of candidates) {
    const result = spawnSync(candidate, ["--version"], {encoding: "utf8"});
    if (result.status === 0) return candidate;
  }
  console.error("Could not find Dart. Set DART=/path/to/dart.");
  process.exit(69);
}
