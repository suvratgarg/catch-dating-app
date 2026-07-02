#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const outputPath = fromRepo("docs/audit_registry/widget_classification.json");
const contractsPath = fromRepo("design/components/catch.components.json");
const widgetbookPath = fromRepo("widgetbook/lib/main.directories.g.dart");
const today = new Date().toISOString().slice(0, 10);

const contracts = readJson(contractsPath).components ?? [];
const contractsBySymbol = buildContractSymbolMap(contracts);
const widgetbookNames = readWidgetbookNames();
const dartFiles = listDartFiles(fromRepo("lib"));
const widgets = [];

for (const filePath of dartFiles) {
  const relativeFile = path.relative(fromRepo("."), filePath);
  const source = fs.readFileSync(filePath, "utf8");
  const imports = collectImports(source);
  for (const declaration of collectWidgetDeclarations(source)) {
    widgets.push(classifyDeclaration({
      ...declaration,
      file: relativeFile,
      imports,
      source,
    }));
  }
}

widgets.sort((a, b) => a.file.localeCompare(b.file) || a.name.localeCompare(b.name));

const registry = {
  $schema: "./widget_classification.schema.json",
  version: 1,
  updated: today,
  sourceOfTruth: {
    scope:
      "Generated inventory for production Flutter widget and widget-state classes under lib/**. Widgetbook/test scaffolds are intentionally out of scope.",
    canonicalContracts:
      "design/components/catch.components.json owns canonical global component contracts and governance metadata.",
    catalog:
      "widgetbook/lib/main.directories.g.dart is the generated review-surface inventory used to determine catalog coverage.",
    privateHelperPolicy:
      "Private helper widgets are not an allowed destination. Private widget classes must be promoted, merged into a canonical public widget, or inlined/deleted.",
    generator: "tool/design/generate_widget_classification.mjs",
  },
  summary: summarize(widgets),
  widgets,
};

fs.writeFileSync(outputPath, JSON.stringify(registry, null, 2) + "\n");
console.log(`Wrote ${path.relative(fromRepo("."), outputPath)} (${widgets.length} entries).`);

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
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

function readWidgetbookNames() {
  if (!fs.existsSync(widgetbookPath)) return new Set();
  const source = fs.readFileSync(widgetbookPath, "utf8");
  return new Set(
    [...source.matchAll(/WidgetbookComponent\(\s*name: '([^']+)'/gu)].map(
      (match) => match[1],
    ),
  );
}

function buildContractSymbolMap(components) {
  const map = new Map();
  for (const component of components) {
    if (component.dart?.symbol) {
      map.set(component.dart.symbol, {
        id: component.id,
        parentId: component.id,
        symbol: component.dart.symbol,
        component,
        member: null,
      });
    }
    for (const member of component.contract?.members ?? []) {
      map.set(member.symbol, {
        id: member.id,
        parentId: component.id,
        symbol: member.symbol,
        component,
        member,
      });
    }
  }
  return map;
}

function collectImports(source) {
  return [...source.matchAll(/^import\s+['"]([^'"]+)['"]/gmu)].map(
    (match) => match[1],
  );
}

function collectWidgetDeclarations(source) {
  const declarations = [];
  const regex =
    /class\s+([A-Za-z_][A-Za-z0-9_]*)(?:<[^>{}]+>)?\s+extends\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?((?:StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget|HookWidget|HookConsumerWidget)|(?:State|ConsumerState)<[^>{}]+>)/gu;
  for (const match of source.matchAll(regex)) {
    const baseClass = match[2];
    declarations.push({
      name: match[1],
      baseClass,
      classKind: baseClass.includes("<") ? "widget-state" : "widget",
    });
  }
  return declarations;
}

function classifyDeclaration(entry) {
  const contract = contractsBySymbol.get(entry.name);
  const visibility = entry.name.startsWith("_") ? "private" : "public";
  const role = roleFor(entry, contract);
  const catalogStatus = catalogStatusFor(entry, contract, visibility);
  const flags = flagsFor(entry, role, contract, catalogStatus, visibility);
  const decision = decisionFor(entry, contract, catalogStatus, visibility, flags);
  const governance = governanceFor(entry, role);

  return {
    name: entry.name,
    file: entry.file,
    classKind: entry.classKind,
    baseClass: entry.baseClass,
    visibility,
    role,
    canonicalFamily: contract?.parentId ?? canonicalFamilyFor(entry, role),
    publicApi: entry.classKind === "widget" && visibility === "public",
    catalogStatus,
    contractId: contract?.id ?? null,
    allowedDependencyLevel: governance.allowedDependencyLevel,
    stateOwnership: governance.stateOwnership,
    asyncOwnership: governance.asyncOwnership,
    layoutOwnership: governance.layoutOwnership,
    actionOwnership: governance.actionOwnership,
    decision,
    remediationOptions: remediationOptionsFor(decision, entry, flags),
    flags,
  };
}

function roleFor(entry, contract) {
  if (entry.classKind === "widget-state") return "widget-state";
  if (contract?.component?.governance?.role === "atom") return "atom";
  if (contract?.component?.governance?.role === "composition") return "composition";
  if (contract?.component?.governance?.role === "pattern") return "pattern";
  if (isScreen(entry.name, entry.file)) return "screen";
  if (isAtom(entry.name, entry.file)) return "atom";
  if (isComposition(entry.name, entry.file)) return "composition";
  if (entry.file.includes("/presentation/widgets/") || entry.file.includes("/presentation/")) {
    return "feature-adapter";
  }
  return "feature-adapter";
}

function isScreen(name, file) {
  return (
    /(?:Screen|Page|Route|App)$/.test(name) ||
    file.includes("/presentation/") && !file.includes("/widgets/") && /screen\.dart$/.test(file)
  );
}

function isAtom(name, file) {
  return (
    file.includes("lib/core/widgets/") &&
    /(?:Badge|Button|Chip|Field|Avatar|Icon|Toggle|Slider|Pill|Dot|Input|Image|Label|Kicker|Ring)$/.test(name)
  );
}

function isComposition(name, file) {
  return (
    file.includes("lib/core/widgets/") ||
    /(?:Section|Rail|List|Grid|Dock|TopBar|BottomSheet|Sheet|Dialog|Card|Menu|Header|Footer|Stepper|TabBar|Scaffold|Body|Shell|Layout|Tile|Row|Panel)$/.test(name)
  );
}

function catalogStatusFor(entry, contract, visibility) {
  if (contract) return "contracted";
  if (entry.classKind === "widget-state") return "not-applicable";
  if (widgetbookNames.has(entry.name)) return "cataloged";
  if (visibility === "private") return "uncataloged";
  if (isScreen(entry.name, entry.file)) return widgetbookNames.has(entry.name) ? "cataloged" : "route-covered";
  return "uncataloged";
}

function flagsFor(entry, role, contract, catalogStatus, visibility) {
  const flags = [];
  const imports = entry.imports.join("\n");
  if (visibility === "private" && entry.classKind === "widget") {
    flags.push("private-widget-publicization-required");
  }
  if (entry.classKind === "widget" && visibility === "public" && catalogStatus === "uncataloged") {
    flags.push("public-widget-missing-widgetbook");
  }
  if (role === "atom" || role === "composition" || role === "pattern") {
    if (/flutter_riverpod|hooks_riverpod|riverpod/iu.test(imports)) {
      flags.push("primitive-imports-provider-layer");
    }
    if (/go_router/iu.test(imports)) {
      flags.push("primitive-imports-routing-layer");
    }
    if (/\/data\/|repository|Repository/iu.test(imports)) {
      flags.push("primitive-imports-data-layer");
    }
  }
  if (!contract && entry.file.includes("lib/core/widgets/") && entry.classKind === "widget") {
    flags.push("core-widget-without-contract");
  }
  return flags.sort();
}

function decisionFor(entry, contract, catalogStatus, visibility, flags) {
  if (entry.classKind === "widget-state") return "keep-widget-state";
  if (contract) return "keep-canonical-contract";
  if (visibility === "private") return "review-promote-or-inline";
  if (flags.includes("core-widget-without-contract")) return "review-promote-or-consolidate";
  if (catalogStatus === "cataloged" || catalogStatus === "route-covered") {
    return "keep-public-cataloged";
  }
  if (isScreen(entry.name, entry.file)) return "review-screen-boundary";
  return "review-catalog-coverage";
}

function governanceFor(entry, role) {
  if (role === "widget-state") {
    return {
      allowedDependencyLevel: "owning-widget-state",
      stateOwnership: "owning-widget-state",
      asyncOwnership: "owning-widget-state",
      layoutOwnership: "owning-widget-state",
      actionOwnership: "owning-widget-state",
    };
  }
  if (role === "screen") {
    return {
      allowedDependencyLevel: "route-boundary",
      stateOwnership: "screen-owned",
      asyncOwnership: "screen-owned",
      layoutOwnership: "page-safe-area-sliver",
      actionOwnership: "navigation-and-controller-calls",
    };
  }
  if (role === "atom") {
    return {
      allowedDependencyLevel: "tokens-and-primitives",
      stateOwnership: "local-ui-only",
      asyncOwnership: "none",
      layoutOwnership: "internal-only",
      actionOwnership: "callbacks-only",
    };
  }
  if (role === "composition" || role === "pattern") {
    return {
      allowedDependencyLevel: "primitives-and-slots",
      stateOwnership: "slot-state-only",
      asyncOwnership: "none",
      layoutOwnership: "slot-layout",
      actionOwnership: "callbacks-only",
    };
  }
  return {
    allowedDependencyLevel: "feature-display-models",
    stateOwnership: "feature-display-state",
    asyncOwnership: "display-state-only",
    layoutOwnership: "feature-section-layout",
    actionOwnership: "feature-callbacks",
  };
}

function remediationOptionsFor(decision, entry, flags) {
  if (entry.classKind === "widget-state") {
    return ["moveStateToController", "routeThroughScreenState"];
  }
  if (decision === "keep-canonical-contract") return ["keepPublicCataloged", "mergeIntoCanonical"];
  if (decision === "keep-public-cataloged") return ["keepPublicCataloged", "mergeIntoCanonical"];
  if (decision === "review-screen-boundary") {
    return ["keepPublicCataloged", "routeThroughScreenState", "mergeIntoCanonical"];
  }
  if (flags.includes("private-widget-publicization-required")) {
    return ["promoteToPublicCatalog", "mergeIntoCanonical", "inlineDelete"];
  }
  return ["promoteToCanonicalContract", "promoteToPublicCatalog", "mergeIntoCanonical", "inlineDelete"];
}

function canonicalFamilyFor(entry, role) {
  if (role === "widget-state") {
    return `state.${slug(targetWidgetName(entry.baseClass) ?? entry.name)}`;
  }
  if (role === "screen") return `screen.${slug(entry.name)}`;
  if (role === "atom" || role === "composition" || role === "pattern") {
    return `catch.${slug(entry.name.replace(/^Catch/u, ""))}`;
  }
  const feature = entry.file.split("/")[1] ?? "app";
  return `feature.${slug(feature)}.${slug(entry.name)}`;
}

function targetWidgetName(baseClass) {
  return baseClass.match(/<([^>]+)>/u)?.[1]?.replace(/^_+/, "") ?? null;
}

function slug(value) {
  return value
    .replace(/^_+/, "")
    .replace(/([a-z0-9])([A-Z])/gu, "$1_$2")
    .replace(/[^A-Za-z0-9]+/gu, "_")
    .replace(/^_+|_+$/gu, "")
    .toLowerCase();
}

function summarize(rows) {
  return {
    total: rows.length,
    widgetClasses: rows.filter((row) => row.classKind === "widget").length,
    stateClasses: rows.filter((row) => row.classKind === "widget-state").length,
    publicClasses: rows.filter((row) => row.visibility === "public").length,
    privateClasses: rows.filter((row) => row.visibility === "private").length,
    byRole: countBy(rows, "role"),
    byDecision: countBy(rows, "decision"),
    byCatalogStatus: countBy(rows, "catalogStatus"),
  };
}

function countBy(rows, field) {
  return Object.fromEntries(
    [...rows.reduce((map, row) => map.set(row[field], (map.get(row[field]) ?? 0) + 1), new Map())]
      .sort(([a], [b]) => a.localeCompare(b)),
  );
}
