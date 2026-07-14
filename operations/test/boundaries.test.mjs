import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";
import test from "node:test";
import {checkBoundaries} from "../scripts/check-boundaries.mjs";
import {temporaryDirectory} from "./helpers.mjs";

const baseline = {
  schemaVersion: 1,
  policyId: "test-policy",
  legacyRoots: [{path: "tool/organizer_intake", codeFileCeiling: 0}],
  allowedLegacyPathReaders: ["operations/src/workflows/supply-intake/adapters/legacy-artifacts.mjs"],
  codeExtensions: [".mjs"],
  forbiddenLegacyImports: ["@catch/operations", "operations/src/platform"],
};

test("boundary checker rejects new orchestration code in a legacy tool root", async () => {
  const repoRoot = await temporaryDirectory("catch-ops-boundary-legacy-");
  const file = path.join(repoRoot, "tool/organizer_intake/new_orchestrator.mjs");
  await fs.mkdir(path.dirname(file), {recursive: true});
  await fs.writeFile(file, "export const workflow = true;\n");
  const result = await checkBoundaries({repoRoot, baseline});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) => finding.id === "legacy-code-ceiling-exceeded"));
});

test("boundary checker rejects legacy path knowledge outside the declared adapter", async () => {
  const repoRoot = await temporaryDirectory("catch-ops-boundary-adapter-");
  const file = path.join(repoRoot, "operations/src/workflows/supply-intake/workflow.mjs");
  await fs.mkdir(path.dirname(file), {recursive: true});
  await fs.writeFile(file, 'export const path = "tool/organizer_intake/generated/value.json";\n');
  const result = await checkBoundaries({repoRoot, baseline});
  assert.equal(result.ok, false);
  assert.ok(result.findings.some((finding) => finding.id === "legacy-path-outside-adapter"));
});
