import {featureWidgetNamingIssues, roleNouns} from "./lib/component_naming.mjs";

export const conceptRoles = new Set(["concept", "member", "composition", "screen"]);
export const conceptQualifiers = new Set([
  "variant",
  "anatomy",
  "adapter",
  "recipe",
  "layout",
]);

export function normalizeSymbol(value) {
  return String(value ?? "")
    .replace(/^_+/u, "")
    .replace(/^Catch(?=[A-Z0-9])/u, "")
    .replace(/(?:Widget|View)$/u, "")
    .replace(/([a-z0-9])([A-Z])/gu, "$1_$2")
    .replace(/[^A-Za-z0-9]+/gu, "_")
    .replace(/^_+|_+$/gu, "")
    .toLowerCase();
}

export function collisionKeyFor({conceptRole, conceptId, symbol}) {
  if (conceptRole === "concept" || conceptRole === "member") return conceptId;
  return normalizeSymbol(symbol);
}

export function newWidgetPolicyIssues(
  entry,
  {widgetbookCovered, componentContracted, registeredOwner = null},
) {
  if (entry.visibility === "private") return ["private-widget-class"];

  const issues = featureWidgetNamingIssues(entry);
  if (!widgetbookCovered) issues.push("missing-widgetbook");
  // Design-system homes require the reserved prefix; app-coupled
  // lib/core/widgets follow feature naming but stay registered.
  if (["lib/core/riverpod_ui/", "packages/catch_ui/lib/"]
    .some((home) => entry.file.startsWith(home))) {
    if (!/^Catch[A-Z0-9]/u.test(entry.name)) {
      issues.push("noncanonical-core-widget-name");
    }
  }
  const contractHome = ["lib/core/widgets/", "lib/core/riverpod_ui/", "packages/catch_ui/lib/"]
    .some((home) => entry.file.startsWith(home));
  if (contractHome && !componentContracted) issues.push("missing-component-contract");
  // The same symbol at a moved path is a stale registry row, reported above.
  const staleRegistryPath = contractHome && registeredOwner?.symbol === entry.name;
  if (registeredOwner && !staleRegistryPath &&
      registeredOwner.identity !== `${entry.file}::${entry.name}`) {
    issues.push("duplicate-of-registered-component");
  }
  return issues;
}

/**
 * Every registered name and alias, normalized, mapped to its owning
 * component. A new widget that lands on one of these keys is a second
 * implementation of an existing responsibility.
 */
export function componentAliasIndex(components) {
  const index = new Map();
  const add = (name, owner) => {
    const key = normalizeSymbol(name);
    if (key && !index.has(key)) index.set(key, owner);
  };
  for (const component of components) {
    const file = component.dart?.file;
    const owner = {
      id: component.id,
      symbol: component.dart?.symbol,
      identity: `${file}::${component.dart?.symbol}`,
    };
    add(component.dart?.symbol, owner);
    for (const alias of component.aliases ?? []) add(alias, owner);
    for (const member of component.contract?.members ?? []) {
      const memberOwner = {
        id: member.id,
        symbol: member.symbol,
        identity: `${member.file ?? file}::${member.symbol}`,
      };
      add(member.symbol, memberOwner);
      for (const alias of member.aliases ?? []) add(alias, memberOwner);
    }
  }
  return index;
}

/** Aliases must point at exactly one component and never shadow a real symbol. */
export function componentAliasProblems(components) {
  const problems = [];
  const symbols = new Map();
  const entries = [];
  for (const component of components) {
    entries.push({id: component.id, symbol: component.dart?.symbol, aliases: component.aliases ?? []});
    for (const member of component.contract?.members ?? []) {
      entries.push({id: member.id, symbol: member.symbol, aliases: member.aliases ?? []});
    }
  }
  for (const entry of entries) symbols.set(normalizeSymbol(entry.symbol), entry.id);
  const seen = new Map();
  for (const entry of entries) {
    for (const alias of entry.aliases) {
      const key = normalizeSymbol(alias);
      if (roleNouns.includes(alias)) {
        problems.push(`${entry.id}: alias ${alias} is a bare role noun`);
      }
      if (key === normalizeSymbol(entry.symbol)) {
        problems.push(`${entry.id}: alias ${alias} repeats its own symbol`);
        continue;
      }
      if (symbols.has(key)) {
        problems.push(`${entry.id}: alias ${alias} names registered symbol of ${symbols.get(key)}`);
      }
      if (seen.has(key) && seen.get(key) !== entry.id) {
        problems.push(`${entry.id}: alias ${alias} is also an alias of ${seen.get(key)}`);
      }
      seen.set(key, entry.id);
    }
  }
  return [...new Set(problems)].sort();
}

/** Redirect keys are off-vocabulary nouns; every target is a role noun. */
export function roleNounRedirectProblems(redirects) {
  const problems = [];
  for (const [noun, targets] of Object.entries(redirects ?? {})) {
    if (roleNouns.includes(noun)) problems.push(`roleNounRedirects.${noun}: already a role noun`);
    for (const target of targets) {
      if (!roleNouns.includes(target)) {
        problems.push(`roleNounRedirects.${noun}: target ${target} is not a role noun`);
      }
    }
  }
  return problems.sort();
}

export function publicWidgetNamingProblems(rows) {
  const problems = [];
  const publicWidgets = rows.filter(
    (row) => row.classKind === "widget" && row.visibility === "public",
  );
  const byName = groupBy(publicWidgets, (row) => row.name);
  for (const [name, declarations] of byName.entries()) {
    const files = [...new Set(declarations.map((row) => row.file))].sort();
    if (files.length > 1) {
      problems.push(`duplicate public widget class ${name}: ${files.join(", ")}`);
    }
  }

  const byCollisionKey = groupBy(publicWidgets, (row) => normalizeSymbol(row.name));
  for (const [key, declarations] of byCollisionKey.entries()) {
    const names = [...new Set(declarations.map((row) => row.name))].sort();
    if (names.length < 2) continue;
    const conceptIds = new Set(declarations.map((row) => row.conceptId));
    const governedFamily =
      conceptIds.size === 1 &&
      !conceptIds.has(null) &&
      declarations.every((row) =>
        row.conceptRole === "concept" || row.conceptRole === "member",
      );
    if (!governedFamily) {
      problems.push(`ungoverned normalized widget collision ${key}: ${names.join(", ")}`);
    }
  }
  return problems.sort();
}

export function contractEntries(components) {
  const entries = [];
  for (const component of components) {
    entries.push({
      contractId: component.id,
      parentContractId: component.id,
      symbol: component.dart?.symbol,
      primary: true,
      governance: component.governance,
    });
    for (const member of component.contract?.members ?? []) {
      entries.push({
        contractId: member.id,
        parentContractId: component.id,
        symbol: member.symbol,
        primary: false,
        governance: member.governance,
      });
    }
  }
  return entries;
}

export function conceptMetrics(components) {
  const entries = contractEntries(components);
  const byRole = countBy(entries, (entry) => entry.governance?.conceptRole ?? "unclassified");
  const conceptIds = new Set(
    entries
      .filter((entry) => entry.governance?.conceptRole === "concept")
      .map((entry) => entry.governance?.conceptId),
  );
  const members = entries.filter((entry) => entry.governance?.conceptRole === "member");
  const collisionGroups = new Map();
  for (const entry of entries) {
    if (!entry.symbol || entry.governance?.conceptRole === "screen") continue;
    const key = collisionKeyFor({
      conceptRole: entry.governance?.conceptRole,
      conceptId: entry.governance?.conceptId,
      symbol: entry.symbol,
    });
    const group = collisionGroups.get(key) ?? [];
    group.push(entry.symbol);
    collisionGroups.set(key, group);
  }
  const collisions = [...collisionGroups.entries()]
    .filter(([, symbols]) => symbols.length > 1)
    .map(([key, symbols]) => ({key, symbols: [...new Set(symbols)].sort()}))
    .filter((entry) => entry.symbols.length > 1)
    .sort((a, b) => a.key.localeCompare(b.key));
  return {
    contractCount: components.length,
    publicClassCount: entries.length,
    conceptCount: conceptIds.size,
    memberCount: members.length,
    membersPerConcept: conceptIds.size === 0 ? 0 : Number((members.length / conceptIds.size).toFixed(2)),
    unclassifiedCount: byRole.unclassified ?? 0,
    byConceptRole: byRole,
    collisionCount: collisions.length,
    collisions,
    naming: {
      canonicalConceptNames: entries.filter(
        (entry) => entry.governance?.conceptRole === "concept" && /^Catch[A-Z0-9]/u.test(entry.symbol ?? ""),
      ).length,
      documentedConceptNameExceptions: entries.filter(
        (entry) => entry.governance?.conceptRole === "concept" && !/^Catch[A-Z0-9]/u.test(entry.symbol ?? "") && Boolean(entry.governance?.decisionRef),
      ).length,
      undocumentedConceptNameExceptions: entries.filter(
        (entry) => entry.governance?.conceptRole === "concept" && !/^Catch[A-Z0-9]/u.test(entry.symbol ?? "") && !entry.governance?.decisionRef,
      ).length,
    },
  };
}

export function conceptTopologyProblems(components) {
  const problems = [];
  const primaries = new Map();
  for (const component of components) {
    const governance = component.governance ?? {};
    if (!conceptRoles.has(governance.conceptRole)) {
      problems.push(`${component.id}: unclassified concept role`);
      continue;
    }
    if (governance.conceptRole === "concept") {
      if (governance.conceptId !== component.id) {
        problems.push(`${component.id}: primary concept id must equal contract id`);
      }
      if (primaries.has(governance.conceptId)) {
        problems.push(`${component.id}: duplicate concept primary ${governance.conceptId}`);
      }
      primaries.set(governance.conceptId, component.id);
      if (!/^Catch[A-Z0-9]/u.test(component.dart?.symbol ?? "") && !governance.decisionRef) {
        problems.push(`${component.id}: non-canonical concept name requires decisionRef`);
      }
    }
  }
  for (const entry of contractEntries(components)) {
    const governance = entry.governance ?? {};
    if (governance.conceptRole === "member") {
      if (!governance.parentConceptId || governance.conceptId !== governance.parentConceptId) {
        problems.push(`${entry.contractId}: invalid member parent`);
      } else if (!primaries.has(governance.parentConceptId)) {
        problems.push(`${entry.contractId}: missing concept primary ${governance.parentConceptId}`);
      }
    }
    if (
      (governance.conceptRole === "composition" || governance.conceptRole === "screen") &&
      (governance.conceptId || governance.parentConceptId)
    ) {
      problems.push(`${entry.contractId}: ${governance.conceptRole} claims concept identity`);
    }
  }
  return [...new Set(problems)].sort();
}

// Cross-framework parity tiers, ordered from most to least widely required.
export const parityTiers = Object.freeze(["T1", "T2", "T3", "T4"]);
const reactSurfaceKeys = Object.freeze(["website", "admin", "webui"]);

export function componentTierProblems(components) {
  const problems = [];
  const tierById = new Map(components.map((component) => [component.id, component.tier]));
  for (const component of components) {
    const tier = component.tier;
    if (!parityTiers.includes(tier)) {
      problems.push(`${component.id}: tier must be one of ${parityTiers.join(", ")}`);
      continue;
    }
    if (tier === "T3" || tier === "T4") {
      const react = reactSurfaceKeys.filter((key) => component.surfaces?.[key]);
      if (react.length > 0) {
        problems.push(`${component.id}: ${tier} entries are Flutter-only but declare ${react.join(", ")}; promote to T2 through registry review`);
      }
    }
    const governance = component.governance ?? {};
    if (governance.conceptRole === "member") {
      const parentTier = tierById.get(governance.parentConceptId);
      if (parityTiers.includes(parentTier) && parityTiers.indexOf(tier) < parityTiers.indexOf(parentTier)) {
        problems.push(`${component.id}: member tier ${tier} is wider than parent ${governance.parentConceptId} tier ${parentTier}`);
      }
    }
  }
  return problems.sort();
}

function countBy(values, keyFor) {
  const result = {};
  for (const value of values) {
    const key = keyFor(value);
    result[key] = (result[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(result).sort(([a], [b]) => a.localeCompare(b)));
}

function groupBy(values, keyFor) {
  const result = new Map();
  for (const value of values) {
    const key = keyFor(value);
    const rows = result.get(key) ?? [];
    rows.push(value);
    result.set(key, rows);
  }
  return result;
}
