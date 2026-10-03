import type {LodgingGroup, MembershipDecision, MembershipSuggestion}
  from "./programLodgingTypes";

/** Validate the entire graph, including currently empty social groups. */
export function groupAncestors(groups: readonly LodgingGroup[]):
    Map<string, Set<string>> {
  const rows = new Map(groups.map((group) => [group.id, group]));
  if (rows.size !== groups.length) {
    throw new Error("Duplicate social group ID.");
  }
  const result = new Map<string, Set<string>>();
  const visiting = new Set<string>();
  const visit = (id: string): Set<string> => {
    if (visiting.has(id)) throw new Error("Social groups contain a cycle.");
    if (result.has(id)) return result.get(id)!;
    const group = rows.get(id);
    if (!group) throw new Error("Unknown parent social group.");
    visiting.add(id);
    const ancestors = new Set([id]);
    for (const parent of group.parentIds) {
      for (const ancestor of visit(parent)) ancestors.add(ancestor);
    }
    visiting.delete(id);
    result.set(id, ancestors);
    return ancestors;
  };
  for (const group of groups) visit(group.id);
  return result;
}

/** Re-import replaces only this contributor's suggestions. Decisions are a
 * separate ledger and are deliberately not rewritten by this operation. */
export function replaceMembershipSuggestions(
  existing: readonly MembershipSuggestion[], sourceId: string,
  incoming: readonly MembershipSuggestion[],
): MembershipSuggestion[] {
  if (incoming.some((row) => row.sourceId !== sourceId)) {
    throw new Error("A contributor can replace only their own suggestions.");
  }
  const rows = new Map<string, MembershipSuggestion>();
  for (const row of [...existing.filter((r) => r.sourceId !== sourceId),
    ...incoming]) {
    const key = JSON.stringify([row.sourceId, row.guestId, row.groupId]);
    rows.set(key, {...row});
  }
  return [...rows.values()];
}

/** An explicit exclusion of an ancestor also blocks inherited membership.
 * Overlap produces sets of affinity, never additional lodging demand. */
export function effectiveMemberships(groups: readonly LodgingGroup[],
  decisions: readonly MembershipDecision[]): Map<string, Set<string>> {
  const ancestors = groupAncestors(groups);
  const byGuest = new Map<string, Map<string, MembershipDecision>>();
  for (const row of decisions) {
    if (!ancestors.has(row.groupId)) throw new Error("Unknown social group.");
    const values = byGuest.get(row.guestId) ?? new Map();
    const prior = values.get(row.groupId);
    if (prior?.authority === row.authority) {
      throw new Error("Ambiguous membership decisions.");
    }
    if (!prior || row.authority === "manual") values.set(row.groupId, row);
    byGuest.set(row.guestId, values);
  }
  const result = new Map<string, Set<string>>();
  for (const [guestId, values] of byGuest) {
    const membership = new Set<string>();
    for (const decision of values.values()) {
      if (!decision.included) continue;
      for (const id of ancestors.get(decision.groupId)!) {
        if (values.get(id)?.included !== false) membership.add(id);
      }
    }
    result.set(guestId, membership);
  }
  return result;
}
