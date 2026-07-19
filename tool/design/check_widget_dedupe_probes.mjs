#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";
import {
  collisionKeyFor,
  conceptMetrics,
  conceptTopologyProblems,
} from "./component_concepts.mjs";

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

Runs seeded structural probes for the widget dedupe extractor and clustering tool,
plus concept-primary, member-parent, composition-identity, and collision probes.
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
runConceptGovernanceProbes();

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

function runConceptGovernanceProbes() {
  const valid = [{
    id: "catch.probe",
    dart: {symbol: "CatchProbe"},
    governance: {
      conceptRole: "concept",
      conceptId: "catch.probe",
    },
    contract: {
      members: [{
        id: "catch.probe.compact",
        symbol: "CatchProbeCompact",
        governance: {
          conceptRole: "member",
          conceptId: "catch.probe",
          parentConceptId: "catch.probe",
          qualifier: "variant",
        },
      }],
    },
  }];
  expect(
    conceptTopologyProblems(valid).length === 0,
    "valid concept/member topology must pass",
  );
  const metrics = conceptMetrics(valid);
  expect(
    metrics.conceptCount === 1 && metrics.memberCount === 1,
    "valid concept/member fixture must count one concept and one member",
  );
  expect(
    metrics.collisionCount === 1 && metrics.collisions[0]?.key === "catch.probe",
    "concept and member must deterministically collide in their concept namespace",
  );
  expect(
    collisionKeyFor({
      conceptRole: "concept",
      conceptId: "catch.probe",
      symbol: "CatchProbe",
    }) === collisionKeyFor({
      conceptRole: "member",
      conceptId: "catch.probe",
      symbol: "CatchProbeCompact",
    }),
    "concept and member collision keys must be identical",
  );

  const duplicatePrimaryProblems = conceptTopologyProblems([
    valid[0],
    {...valid[0], contract: {members: []}},
  ]);
  expect(
    duplicatePrimaryProblems.some((problem) => problem.includes("duplicate concept primary")),
    "known-bad duplicate concept primary must fail",
  );

  const missingParentProblems = conceptTopologyProblems([{
    id: "catch.probe_recipe",
    dart: {symbol: "CatchProbeRecipe"},
    governance: {conceptRole: "composition"},
    contract: {
      members: [{
        id: "catch.probe_recipe.orphan",
        symbol: "CatchProbeOrphan",
        governance: {
          conceptRole: "member",
          conceptId: "catch.missing",
          parentConceptId: "catch.missing",
          qualifier: "recipe",
        },
      }],
    },
  }]);
  expect(
    missingParentProblems.some((problem) => problem.includes("missing concept primary")),
    "known-bad member without a concept primary must fail",
  );

  const compositionIdentityProblems = conceptTopologyProblems([{
    id: "catch.probe_recipe",
    dart: {symbol: "CatchProbeRecipe"},
    governance: {
      conceptRole: "composition",
      conceptId: "catch.probe",
    },
    contract: {members: []},
  }]);
  expect(
    compositionIdentityProblems.some((problem) => problem.includes("claims concept identity")),
    "known-bad composition claiming concept identity must fail",
  );
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
