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
    .replace(/^Catch/u, "")
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

function countBy(values, keyFor) {
  const result = {};
  for (const value of values) {
    const key = keyFor(value);
    result[key] = (result[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(result).sort(([a], [b]) => a.localeCompare(b)));
}
