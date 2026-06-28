#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const writeIndex = args.indexOf("--write");
const outputPath =
  writeIndex === -1
    ? "docs/audit_registry/widget_variant_inventory.json"
    : args[writeIndex + 1];
const shouldCheck = args.includes("--check");
const shouldJson = args.includes("--json");

if (args.includes("--help") || args.includes("-h")) {
  console.log(`Usage:
  node tool/design/generate_widget_variant_inventory.mjs [--write <path>] [--check] [--json]

Scans Widgetbook use cases and records variant/state-card labels by component.
Use this to find oversized state matrices and redundant variant vocabularies.
`);
  process.exit(0);
}

if (writeIndex !== -1 && !outputPath) {
  console.error("--write requires a path");
  process.exit(64);
}

const inventory = buildInventory();
const absoluteOutputPath = fromRepo(outputPath);

if (shouldCheck) {
  const current = fs.existsSync(absoluteOutputPath)
    ? JSON.parse(fs.readFileSync(absoluteOutputPath, "utf8"))
    : null;
  const comparableCurrent = current == null
    ? null
    : {...current, generatedAt: inventory.generatedAt};
  if (
    JSON.stringify(comparableCurrent, null, 2) !==
    JSON.stringify(inventory, null, 2)
  ) {
    console.error(
      `${relativeToRepo(absoluteOutputPath)} is stale. Run npm run design:widgets:variants.`,
    );
    process.exit(1);
  }
} else {
  fs.writeFileSync(absoluteOutputPath, JSON.stringify(inventory, null, 2) + "\n");
}

if (shouldJson) {
  console.log(JSON.stringify(inventory, null, 2));
} else {
  console.log(
    `Widget variant inventory: ${inventory.summary.useCases} use cases, ` +
      `${inventory.summary.stateCards} state cards, ` +
      `${inventory.summary.reviewCandidates} review candidates.`,
  );
}

function buildInventory() {
  const useCases = [];
  for (const filePath of listDartFiles(fromRepo("widgetbook/lib"))) {
    if (filePath.endsWith("main.directories.g.dart")) continue;
    const source = fs.readFileSync(filePath, "utf8");
    useCases.push(...collectUseCases(source, filePath));
  }

  useCases.sort(
    (a, b) =>
      a.component.localeCompare(b.component) ||
      a.path.localeCompare(b.path) ||
      a.functionName.localeCompare(b.functionName),
  );

  const componentGroups = groupBy(useCases, (useCase) => useCase.component);
  const components = [...componentGroups.entries()]
    .map(([component, rows]) => {
      const stateCards = rows.flatMap((row) => row.stateCards);
      return {
        component,
        useCaseCount: rows.length,
        stateCardCount: stateCards.length,
        paths: [...new Set(rows.map((row) => row.path))].sort(),
        labels: [...new Set(stateCards.map((state) => state.label))].sort(),
        review: reviewForComponent(rows, stateCards),
        useCases: rows.map((row) => ({
          name: row.name,
          functionName: row.functionName,
          file: row.file,
          path: row.path,
          stateCardCount: row.stateCards.length,
          stateCards: row.stateCards,
        })),
      };
    })
    .sort(
      (a, b) =>
        Number(b.review.needsReview) - Number(a.review.needsReview) ||
        b.stateCardCount - a.stateCardCount ||
        b.useCaseCount - a.useCaseCount ||
        a.component.localeCompare(b.component),
    );

  const reviewCandidates = components.filter((row) => row.review.needsReview);

  return {
    generatedAt: new Date().toISOString(),
    sourceOfTruth: {
      scope:
        "Generated inventory of Widgetbook use-case state cards. This does not replace component contracts; it finds variant matrices that need pruning.",
      generator: "tool/design/generate_widget_variant_inventory.mjs",
    },
    summary: {
      useCases: useCases.length,
      components: components.length,
      stateCards: useCases.reduce((sum, row) => sum + row.stateCards.length, 0),
      reviewCandidates: reviewCandidates.length,
      oversizedUseCases: useCases.filter((row) => row.stateCards.length >= 8)
        .length,
      multiUseCaseComponents: components.filter((row) => row.useCaseCount > 1)
        .length,
    },
    reviewCandidates,
    components,
  };
}

function listDartFiles(root) {
  const results = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      results.push(...listDartFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".dart")) {
      results.push(fullPath);
    }
  }
  return results;
}

function collectUseCases(source, filePath) {
  const rows = [];
  const regex =
    /@widgetbook\.UseCase\(([\s\S]*?)\)\s*Widget\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*BuildContext\s+context\s*\)\s*\{/gu;

  for (const match of source.matchAll(regex)) {
    const annotation = match[1];
    const bodyStart = match.index + match[0].length - 1;
    const bodyEnd = findMatchingBrace(source, bodyStart);
    const body = bodyEnd === -1 ? "" : source.slice(bodyStart, bodyEnd + 1);
    const component = readAnnotationValue(annotation, "type") ?? "Unknown";
    const name = readAnnotationValue(annotation, "name") ?? "Unnamed";
    const useCasePath = readAnnotationValue(annotation, "path") ?? "";
    rows.push({
      component,
      name,
      path: useCasePath,
      functionName: match[2],
      file: relativeToRepo(filePath),
      stateCards: collectStateCards(body),
    });
  }

  return rows;
}

function readAnnotationValue(annotation, key) {
  const quoted = annotation.match(
    new RegExp(`${key}:\\s*(['"])(.*?)\\1`, "u"),
  );
  if (quoted) return quoted[2];
  const symbol = annotation.match(
    new RegExp(`${key}:\\s*([A-Za-z_][A-Za-z0-9_\\.]*)`, "u"),
  );
  return symbol?.[1] ?? null;
}

function collectStateCards(body) {
  const rows = [];
  const regex =
    /_(?:StateCard|CatchFieldStatePreview)\(\s*label:\s*(['"])(.*?)\1/gu;
  for (const match of body.matchAll(regex)) {
    rows.push({
      label: match[2],
      normalizedLabel: normalizeLabel(match[2]),
    });
  }
  return rows;
}

function findMatchingBrace(source, openIndex) {
  let depth = 0;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (char === "{") depth += 1;
    if (char === "}") depth -= 1;
    if (depth === 0) return index;
  }
  return -1;
}

function reviewForComponent(useCases, stateCards) {
  const labelCounts = countBy(stateCards, (state) => state.normalizedLabel);
  const duplicateLabels = [...labelCounts.entries()]
    .filter(([, count]) => count > 1)
    .map(([label, count]) => ({label, count}));
  const oversizedUseCases = useCases
    .filter((row) => row.stateCards.length >= 8)
    .map((row) => row.functionName);
  const splitCatalog = useCases.length > 1;
  const canonicalContractOnly =
    useCases.length === 1 &&
    useCases[0].name === "Contract states" &&
    useCases[0].path.startsWith("[Core primitives]");
  const tooManyStates =
    stateCards.length >= 12 ||
    (!canonicalContractOnly && oversizedUseCases.length > 0);
  const needsReview =
    tooManyStates || duplicateLabels.length > 0 || (splitCatalog && stateCards.length >= 6);

  return {
    needsReview,
    reasons: [
      ...(tooManyStates ? ["large-state-matrix"] : []),
      ...(canonicalContractOnly && stateCards.length >= 8 && !tooManyStates
        ? ["canonical-contract-matrix"]
        : []),
      ...(duplicateLabels.length > 0 ? ["duplicate-state-labels"] : []),
      ...(splitCatalog && stateCards.length >= 6 ? ["split-across-use-cases"] : []),
    ],
    duplicateLabels,
    oversizedUseCases,
  };
}

function normalizeLabel(label) {
  return label
    .toLowerCase()
    .replace(/[^a-z0-9]+/gu, " ")
    .trim()
    .replace(/\s+/gu, " ");
}

function groupBy(rows, keyFor) {
  const map = new Map();
  for (const row of rows) {
    const key = keyFor(row);
    const bucket = map.get(key) ?? [];
    bucket.push(row);
    map.set(key, bucket);
  }
  return map;
}

function countBy(rows, keyFor) {
  const map = new Map();
  for (const row of rows) {
    const key = keyFor(row);
    map.set(key, (map.get(key) ?? 0) + 1);
  }
  return map;
}
