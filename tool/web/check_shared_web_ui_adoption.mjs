#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = new Set(process.argv.slice(2));
if (args.has("--self-test")) {
  runSelfTest();
  process.exit(0);
}

const trackerPath = fromRepo("docs/audit_registry/web_shared_primitive_adoption.json");
const tracker = readJson(trackerPath);
const findings = validateTracker(tracker);

if (findings.length > 0) {
  console.error(`Shared web UI adoption check failed (${findings.length} finding(s)):`);
  findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}

const statusCounts = countBy(tracker.candidates, (candidate) => candidate.status);
const improvementCounts = countBy(tracker.improvements, (item) => item.status);
console.log(
  `Shared web UI adoption check passed: ${tracker.candidates.length} candidate families ` +
  `(${formatCounts(statusCounts)}); ${tracker.improvements.length} improvement items ` +
  `(${formatCounts(improvementCounts)}).`
);

function validateTracker(document) {
  const errors = [];
  if (document.schemaVersion !== 1) errors.push("schemaVersion must be 1");
  if (!Array.isArray(document.candidates) || document.candidates.length === 0) {
    errors.push("candidates must be a non-empty array");
    return errors;
  }
  if (!Array.isArray(document.improvements)) errors.push("improvements must be an array");

  const ids = new Set();
  for (const item of [...document.candidates, ...(document.improvements ?? [])]) {
    if (!item.id) errors.push("every tracker item needs an id");
    else if (ids.has(item.id)) errors.push(`${item.id}: duplicate tracker id`);
    else ids.add(item.id);
  }

  const websiteExports = runtimeExportsUnder("website/src/shared/ui/primitives");
  const adminExports = runtimeExportsUnder("admin/src/shared/ui/AdminPrimitives");
  const packageExports = runtimeExportsFromIndex("packages/web-ui/src/index.ts");

  errors.push(...validateExactOverlaps({document, websiteExports, adminExports}));
  errors.push(...validatePackageExports({document, packageExports}));
  errors.push(...validateRequiredSourceContracts());

  const allowedStatuses = new Set([
    "adopted",
    "in_progress",
    "keep_surface_specific",
    "needs_decision",
    "planned",
  ]);
  for (const candidate of document.candidates) {
    if (!allowedStatuses.has(candidate.status)) {
      errors.push(`${candidate.id}: unsupported candidate status ${candidate.status}`);
    }
    for (const surface of ["website", "admin"]) {
      const record = candidate[surface];
      if (!record) continue;
      const sourcePath = fromRepo(record.source);
      if (!fs.existsSync(sourcePath)) {
        errors.push(`${candidate.id}: missing ${surface} source ${record.source}`);
        continue;
      }
      const source = fs.readFileSync(sourcePath, "utf8");
      for (const symbol of record.symbols ?? []) {
        if (!new RegExp(`\\b${escapeRegex(symbol)}\\b`, "u").test(source)) {
          errors.push(`${candidate.id}: ${surface} symbol ${symbol} is absent from ${record.source}`);
        }
      }
    }
    if (candidate.status === "adopted") {
      for (const symbol of candidate.packageSymbols ?? []) {
        if (!packageExports.has(symbol)) {
          errors.push(`${candidate.id}: adopted package symbol ${symbol} is not exported from @catch/web-ui`);
        }
      }
      if ((candidate.packageSymbols ?? []).length === 0) {
        errors.push(`${candidate.id}: adopted candidates need at least one package symbol`);
      }
      for (const surface of ["website", "admin"]) {
        const record = candidate[surface];
        if (!record) continue;
        errors.push(...validateAdoptedSurfaceImport({candidate, record, surface}));
      }
    }
  }
  return errors;
}

function validateRequiredSourceContracts() {
  const contracts = [
    {
      path: "packages/web-config/styles/catch-web.css",
      includes: ["--catch-focus-ring-color", ":focus-visible"],
    },
    {
      path: "packages/web-ui/src/primitives.tsx",
      includes: ["role=\"region\"", "ariaLabel", "aria-busy", "aria-invalid"],
    },
    {
      path: "website/src/styles/organizer-public.css",
      includes: [".public-search__input:focus-within"],
    },
    {
      path: "admin/src/styles.css",
      includes: [".search-control:focus-within", ".marketing-title-input:focus-visible"],
    },
  ];
  const findings = [];
  for (const contract of contracts) {
    const source = fs.readFileSync(fromRepo(contract.path), "utf8");
    for (const expected of contract.includes) {
      if (!source.includes(expected)) {
        findings.push(`${contract.path}: missing shared web contract marker ${expected}`);
      }
    }
  }
  findings.push(...validateWorkflowContracts());
  return findings;
}

function validateWorkflowContracts(readSource = readRepoSource) {
  const reusableWorkflow = ".github/workflows/react-surface-validation.yml";
  const contracts = [
    {
      path: reusableWorkflow,
      includes: [
        "workflow_call:",
        "npm run web:shared-ui-adoption:check",
        "npm run web:ui:test && npm run web:ui:typecheck",
      ],
    },
    {
      path: ".github/workflows/marketing-website.yml",
      includes: [
        "packages/web-ui/**",
        reusableWorkflow,
        `uses: ./${reusableWorkflow}`,
        "surface: marketing",
      ],
    },
    {
      path: ".github/workflows/admin-website.yml",
      includes: [
        "packages/web-ui/**",
        reusableWorkflow,
        `uses: ./${reusableWorkflow}`,
        "surface: admin",
      ],
    },
  ];
  const findings = [];
  for (const contract of contracts) {
    const source = readSource(contract.path);
    for (const expected of contract.includes) {
      if (!source.includes(expected)) {
        findings.push(`${contract.path}: missing shared web contract marker ${expected}`);
      }
    }
  }
  return findings;
}

function readRepoSource(relativePath) {
  return fs.readFileSync(fromRepo(relativePath), "utf8");
}

function validateAdoptedSurfaceImport({candidate, record, surface}) {
  const source = fs.readFileSync(fromRepo(record.source), "utf8");
  const findings = [];
  if (!source.includes("@catch/web-ui")) {
    findings.push(`${candidate.id}: ${surface} adapter does not import @catch/web-ui`);
  }
  if (!(candidate.packageSymbols ?? []).some((symbol) =>
    new RegExp(`\\b${escapeRegex(symbol)}\\b`, "u").test(source))) {
    findings.push(
      `${candidate.id}: ${surface} adapter does not use any classified package symbol`
    );
  }
  return findings;
}

function validateExactOverlaps({document, websiteExports, adminExports}) {
  const classifiedPairs = new Set();
  for (const candidate of document.candidates ?? []) {
    const website = new Set(candidate.website?.symbols ?? []);
    const admin = new Set(candidate.admin?.symbols ?? []);
    for (const symbol of website) {
      if (admin.has(symbol)) classifiedPairs.add(symbol);
    }
  }
  return [...websiteExports]
    .filter((symbol) => adminExports.has(symbol) && !classifiedPairs.has(symbol))
    .sort()
    .map((symbol) => `unclassified exact-name primitive overlap: ${symbol}`);
}

function validatePackageExports({document, packageExports}) {
  const classified = new Set(
    (document.candidates ?? []).flatMap((candidate) => candidate.packageSymbols ?? [])
  );
  return [...packageExports]
    .filter((symbol) => !classified.has(symbol))
    .sort()
    .map((symbol) => `unclassified @catch/web-ui export: ${symbol}`);
}

function runtimeExportsUnder(relativeRoot) {
  const root = fromRepo(relativeRoot);
  const exports = new Set();
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    if (!entry.isFile() || !/\.(?:ts|tsx)$/u.test(entry.name) || entry.name === "index.ts") continue;
    const source = fs.readFileSync(path.join(root, entry.name), "utf8");
    for (const match of source.matchAll(
      /^export\s+(?:async\s+)?(?:function|const|class)\s+([A-Za-z][A-Za-z0-9_]*)/gmu
    )) {
      exports.add(match[1]);
    }
  }
  return exports;
}

function runtimeExportsFromIndex(relativePath) {
  const source = fs.readFileSync(fromRepo(relativePath), "utf8");
  const exports = new Set();
  for (const match of source.matchAll(/^export\s*\{([^}]+)\}\s*from/gmu)) {
    for (const rawName of match[1].split(",")) {
      const name = rawName.trim().split(/\s+as\s+/u).at(-1);
      if (name) exports.add(name);
    }
  }
  return exports;
}

function runSelfTest() {
  const overlapFindings = validateExactOverlaps({
    document: {candidates: []},
    websiteExports: new Set(["TextField"]),
    adminExports: new Set(["TextField"]),
  });
  if (!overlapFindings.some((finding) => finding.includes("TextField"))) {
    throw new Error("self-test failed to reject an unclassified exact-name overlap");
  }
  const packageFindings = validatePackageExports({
    document: {candidates: []},
    packageExports: new Set(["UnknownControl"]),
  });
  if (!packageFindings.some((finding) => finding.includes("UnknownControl"))) {
    throw new Error("self-test failed to reject an unclassified package export");
  }
  const workflowSources = new Map([
    [
      ".github/workflows/react-surface-validation.yml",
      "workflow_call:\nrun: npm run web:shared-ui-adoption:check\n",
    ],
    [
      ".github/workflows/marketing-website.yml",
      "packages/web-ui/**\n.github/workflows/react-surface-validation.yml\nuses: ./.github/workflows/react-surface-validation.yml\nsurface: marketing\n",
    ],
    [
      ".github/workflows/admin-website.yml",
      "packages/web-ui/**\n.github/workflows/react-surface-validation.yml\nuses: ./.github/workflows/react-surface-validation.yml\nsurface: admin\n",
    ],
  ]);
  const workflowFindings = validateWorkflowContracts(
    (relativePath) => workflowSources.get(relativePath) ?? "",
  );
  if (
    !workflowFindings.some((finding) =>
      finding.includes("npm run web:ui:test && npm run web:ui:typecheck"),
    )
  ) {
    throw new Error("self-test failed to reject a reusable workflow missing shared UI validation");
  }
  const tempRoot = fs.mkdtempSync(path.join(process.cwd(), ".shared-web-ui-self-test-"));
  const tempSource = path.join(tempRoot, "adapter.tsx");
  try {
    fs.writeFileSync(tempSource, "export function Button() { return null; }\n");
    const adoptionFindings = validateAdoptedSurfaceImport({
      candidate: {id: "TEST", packageSymbols: ["ButtonControl"]},
      record: {source: path.relative(fromRepo(), tempSource)},
      surface: "website",
    });
    if (!adoptionFindings.some((finding) => finding.includes("does not import"))) {
      throw new Error("self-test failed to reject an adopted adapter without package import");
    }
  } finally {
    fs.rmSync(tempRoot, {recursive: true, force: true});
  }
  console.log("Shared web UI adoption scanner self-test passed.");
}

function countBy(items, keyFor) {
  const counts = new Map();
  for (const item of items ?? []) {
    const key = keyFor(item);
    counts.set(key, (counts.get(key) ?? 0) + 1);
  }
  return counts;
}

function formatCounts(counts) {
  return [...counts.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([status, count]) => `${status}=${count}`)
    .join(", ");
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}
