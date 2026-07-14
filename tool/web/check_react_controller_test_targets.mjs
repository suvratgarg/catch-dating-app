#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = new Set(process.argv.slice(2));
if (args.has("--self-test")) {
  runSelfTest();
  process.exit(0);
}

const manifestPath = fromRepo("tool/web/react_controller_test_targets.json");
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const discovered = discoverControllerSources();
const findings = validateManifest(manifest, discovered, (relativePath) => {
  const absolutePath = fromRepo(relativePath);
  return fs.existsSync(absolutePath) ? fs.readFileSync(absolutePath, "utf8") : null;
});

if (findings.length > 0) {
  console.error(`React controller test-target check failed (${findings.length} finding(s)):`);
  findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}

const counts = Object.groupBy(manifest.targets, (target) => target.status);
console.log(
  `React controller test-target check passed: ${manifest.targets.length} classified hooks ` +
  `(${Object.entries(counts).map(([status, targets]) => `${status}=${targets.length}`).join(", ")}).`
);

function discoverControllerSources() {
  const roots = ["admin/src/features", "website/src/features"];
  const sources = new Set();
  for (const relativeRoot of roots) {
    walk(fromRepo(relativeRoot), (absolutePath) => {
      const relativePath = path.relative(fromRepo("."), absolutePath).split(path.sep).join("/");
      if (/\/use[A-Z][A-Za-z0-9]*(?:Controller|Mutation)\.tsx?$/u.test(relativePath)) {
        sources.add(relativePath);
      }
    });
  }
  return sources;
}

function walk(root, visit) {
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const absolutePath = path.join(root, entry.name);
    if (entry.isDirectory()) walk(absolutePath, visit);
    else if (entry.isFile()) visit(absolutePath);
  }
}

function validateManifest(document, discovered, readSource) {
  const findings = [];
  if (document.schemaVersion !== 1) findings.push("schemaVersion must be 1");
  if (!Array.isArray(document.targets)) return [...findings, "targets must be an array"];
  const allowedStatuses = new Set(["required", "planned", "exempt"]);
  const seen = new Set();

  for (const target of document.targets) {
    if (!target.source) {
      findings.push("every target needs a source path");
      continue;
    }
    if (seen.has(target.source)) findings.push(`${target.source}: duplicate target`);
    seen.add(target.source);
    if (!allowedStatuses.has(target.status)) {
      findings.push(`${target.source}: unsupported status ${target.status}`);
    }
    if (!discovered.has(target.source)) {
      findings.push(`${target.source}: target is missing or no longer a controller/mutation hook`);
    }
    if (target.status === "exempt" && !target.reason) {
      findings.push(`${target.source}: exempt targets need a reason`);
    }
    if (target.status !== "required") continue;
    if (!target.test) {
      findings.push(`${target.source}: required target needs a test path`);
      continue;
    }
    const testSource = readSource(target.test);
    if (testSource === null) {
      findings.push(`${target.source}: missing required test ${target.test}`);
      continue;
    }
    const moduleName = path.basename(target.source).replace(/\.tsx?$/u, "");
    if (!testSource.includes(moduleName)) {
      findings.push(`${target.test}: does not import or exercise ${moduleName}`);
    }
    if (!/\b(?:it|test)\s*\(/u.test(testSource)) {
      findings.push(`${target.test}: has no executable test case`);
    }
  }

  for (const source of [...discovered].sort()) {
    if (!seen.has(source)) findings.push(`${source}: unclassified controller/mutation hook`);
  }
  return findings;
}

function runSelfTest() {
  const discovered = new Set(["website/src/features/example/useExampleController.ts"]);
  const missingClassification = validateManifest(
    {schemaVersion: 1, targets: []},
    discovered,
    () => null
  );
  if (!missingClassification.some((finding) => finding.includes("unclassified"))) {
    throw new Error("self-test failed to reject an unclassified controller");
  }
  const missingTest = validateManifest(
    {
      schemaVersion: 1,
      targets: [{
        source: "website/src/features/example/useExampleController.ts",
        test: "website/src/features/example/useExampleController.test.tsx",
        status: "required",
      }],
    },
    discovered,
    () => null
  );
  if (!missingTest.some((finding) => finding.includes("missing required test"))) {
    throw new Error("self-test failed to reject a missing required test");
  }
  console.log("React controller test-target self-test passed.");
}
