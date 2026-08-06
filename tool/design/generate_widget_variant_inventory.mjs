#!/usr/bin/env node
import path from "node:path";
import {fileURLToPath} from "node:url";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";

const widgetbookPrefix = "widgetbook/lib/";
const generatedDirectoryFile = `${widgetbookPrefix}main.directories.g.dart`;

export function buildWidgetVariantInventory(
  repositorySnapshot = createRepositorySnapshot(),
) {
  const dartPaths = repositorySnapshot
    .listFiles({prefix: widgetbookPrefix})
    .filter(
      (relativePath) =>
        relativePath.endsWith(".dart") &&
        relativePath !== generatedDirectoryFile,
    );
  const sources = repositorySnapshot.readTexts(dartPaths, {required: true});
  const useCases = [];

  for (const relativePath of dartPaths) {
    useCases.push(...collectUseCases(sources.get(relativePath), relativePath));
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
  const inventory = {
    sourceOfTruth: {
      scope:
        "Live inventory of Widgetbook use-case state cards. This does not replace component contracts; it finds variant matrices that need pruning.",
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
  validateWidgetVariantInventory(inventory);
  return inventory;
}

export function validateWidgetVariantInventory(inventory) {
  const {summary, components, reviewCandidates} = inventory;
  if (summary.useCases === 0 || summary.components === 0) {
    throw new Error(
      "Widget variant inventory is empty; verify the logical repository snapshot.",
    );
  }
  const componentUseCases = components.reduce(
    (sum, component) => sum + component.useCaseCount,
    0,
  );
  const componentStateCards = components.reduce(
    (sum, component) => sum + component.stateCardCount,
    0,
  );
  if (
    summary.components !== components.length ||
    summary.useCases !== componentUseCases ||
    summary.stateCards !== componentStateCards ||
    summary.reviewCandidates !== reviewCandidates.length
  ) {
    throw new Error("Widget variant inventory summary is internally inconsistent.");
  }
}

export function runWidgetVariantInventoryCli(
  args = process.argv.slice(2),
  {
    repositorySnapshot = createRepositorySnapshot(),
    stdout = (value) => console.log(value),
    stderr = (value) => console.error(value),
  } = {},
) {
  if (args.includes("--help") || args.includes("-h")) {
    stdout(`Usage:
  node tool/design/generate_widget_variant_inventory.mjs [--check] [--json]

Scans the logical repository snapshot for Widgetbook use cases and reports
variant/state-card labels by component. Default and --check are read-only;
--json emits the complete ephemeral inventory to stdout.
`);
    return 0;
  }

  const allowedArgs = new Set(["--check", "--json"]);
  const unknownArgs = args.filter((arg) => !allowedArgs.has(arg));
  if (unknownArgs.length > 0) {
    stderr(`Unknown option(s): ${unknownArgs.join(", ")}`);
    return 64;
  }

  const inventory = buildWidgetVariantInventory(repositorySnapshot);
  if (args.includes("--json")) {
    stdout(JSON.stringify(inventory, null, 2));
  } else {
    stdout(
      `Widget variant inventory: ${inventory.summary.useCases} use cases, ` +
        `${inventory.summary.stateCards} state cards, ` +
        `${inventory.summary.reviewCandidates} review candidates.`,
    );
  }
  return 0;
}

function collectUseCases(source, relativePath) {
  const rows = [];
  const regex =
    /@widgetbook\.UseCase\(([\s\S]*?)\)\s*Widget\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*BuildContext\s+context\s*\)\s*\{/gu;

  for (const match of source.matchAll(regex)) {
    const annotation = match[1];
    const bodyStart = match.index + match[0].length - 1;
    const bodyEnd = findMatchingBrace(source, bodyStart);
    const body = bodyEnd === -1 ? "" : source.slice(bodyStart, bodyEnd + 1);
    rows.push({
      component: readAnnotationValue(annotation, "type") ?? "Unknown",
      name: readAnnotationValue(annotation, "name") ?? "Unnamed",
      path: readAnnotationValue(annotation, "path") ?? "",
      functionName: match[2],
      file: relativePath,
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
    tooManyStates ||
    duplicateLabels.length > 0 ||
    (splitCatalog && stateCards.length >= 6);

  return {
    needsReview,
    reasons: [
      ...(tooManyStates ? ["large-state-matrix"] : []),
      ...(canonicalContractOnly && stateCards.length >= 8 && !tooManyStates
        ? ["canonical-contract-matrix"]
        : []),
      ...(duplicateLabels.length > 0 ? ["duplicate-state-labels"] : []),
      ...(splitCatalog && stateCards.length >= 6
        ? ["split-across-use-cases"]
        : []),
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

if (
  process.argv[1] &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)
) {
  process.exitCode = runWidgetVariantInventoryCli();
}
