import {createHash} from "node:crypto";
import {effectiveMemberships} from "./programLodgingGroups";
import {assertLodgingSnapshot, inventoryFacts, lodgingNights,
  prepareLodgingValidator, validateLodgingPlacements} from
  "./programLodgingValidation";
import type {LodgingPlacement, LodgingProposal, LodgingRevisions,
  LodgingSnapshot} from "./programLodgingTypes";

function compare(a: readonly number[], b: readonly number[]): number {
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return a[i] - b[i];
  return 0;
}
function placementKey(rows: readonly LodgingPlacement[]): string {
  return JSON.stringify([...rows].sort((a, b) =>
    a.partyId.localeCompare(b.partyId)).map((r) => [r.partyId, r.inventoryId]));
}

/** The first objectives conserve demand and priority. Changes to published
 * plans precede social preferences; isolation precedes raw distance. */
export function lodgingScore(snapshot: LodgingSnapshot,
  rows: readonly LodgingPlacement[]): number[] {
  const membership = effectiveMemberships(snapshot.groups,
    snapshot.memberships);
  const partyGroups = new Map(snapshot.parties.map((p) => [p.id,
    new Set(p.guestIds.flatMap((id) => [...membership.get(id) ?? []]))]));
  const partyNights = new Map(snapshot.parties.map((p) => [p.id,
    new Set(p.guestIds.flatMap((id) => lodgingNights(
      snapshot.guests.find((g) => g.id === id)!)))]));
  const units = new Map(snapshot.inventory.map((unit) =>
    [unit.id, inventoryFacts(snapshot, unit)]));
  const assigned = new Map(rows.map((r) => [r.partyId, r.inventoryId]));
  const unplaced = snapshot.parties.filter((p) => !assigned.has(p.id));
  let distance = 0;
  const hasFriend = new Set<string>();
  const hasNearbyFriend = new Set<string>();
  for (let i = 0; i < rows.length; i++) {
    for (let j = i + 1; j < rows.length; j++) {
      const a = rows[i];
      const b = rows[j];
      const shared = [...partyGroups.get(a.partyId)!].filter((id) =>
        partyGroups.get(b.partyId)!.has(id)).length;
      if (!shared || ![...partyNights.get(a.partyId)!].some((night) =>
        partyNights.get(b.partyId)!.has(night))) continue;
      hasFriend.add(a.partyId);
      hasFriend.add(b.partyId);
      const left = units.get(a.inventoryId)!;
      const right = units.get(b.inventoryId)!;
      const sameZone = left.hotelId === right.hotelId &&
        left.zoneId === right.zoneId;
      if (sameZone) {
        hasNearbyFriend.add(a.partyId);
        hasNearbyFriend.add(b.partyId);
      }
      const separation = left.hotelId !== right.hotelId ? 100 :
        left.building !== right.building ? 25 :
          left.floor !== right.floor ? 10 :
            left.wing !== right.wing ? 4 : sameZone ? 0 : 2;
      // Layout coordinates only break ties inside the same zone.
      const geometric = sameZone && left.position && right.position ?
        Math.min(1, Math.hypot(left.position.x - right.position.x,
          left.position.y - right.position.y) / 1000) : 0;
      distance += (separation + geometric) * Math.min(shared, 3);
    }
  }
  const changes = snapshot.published.filter((p) =>
    assigned.get(p.partyId) !== p.inventoryId).length;
  return [unplaced.reduce((sum, p) => sum + p.guestIds.length, 0),
    unplaced.reduce((sum, p) => sum + p.priority, 0), changes,
    [...hasFriend].filter((id) => !hasNearbyFriend.has(id)).length, distance];
}

/** A bounded deterministic search, followed by feasible moves and swaps.
 * Tiny cases retain every state; larger cases report the heuristic honestly.
 * Every accepted candidate passes the independent manual proposal validator. */
export function planLodging(snapshot: LodgingSnapshot,
  options: {maxStates?: number; beamWidth?: number} = {}): LodgingProposal {
  assertLodgingSnapshot(snapshot);
  const validate = prepareLodgingValidator(snapshot);
  const maxStates = options.maxStates ?? 40_000;
  const beamWidth = options.beamWidth ?? 24;
  if (!Number.isSafeInteger(maxStates) || maxStates < 1 ||
      maxStates > 200_000 ||
      !Number.isSafeInteger(beamWidth) || beamWidth < 1 || beamWidth > 100) {
    throw new Error("Invalid search budget.");
  }
  const locked = snapshot.published.filter((p) => p.locked || p.checkedIn)
    .map(({partyId, inventoryId}) => ({partyId, inventoryId}));
  const lockIssues = validate(locked);
  if (lockIssues.length) {
    throw new Error("Locked placements need correction: " +
      lockIssues.map((issue) => issue.code).join(", "));
  }
  const inventory = [...snapshot.inventory].sort((a, b) =>
    a.id.localeCompare(b.id));
  const candidates = new Map<string, string[]>();
  const rejected = new Map<string, Set<string>>();
  const pending = snapshot.parties.filter((p) =>
    !locked.some((r) => r.partyId === p.id));
  for (const party of pending) {
    const failures = new Set<string>();
    const ids = inventory.filter((unit) => {
      const issues = validate(
        [...locked, {partyId: party.id, inventoryId: unit.id}]);
      for (const issue of issues) failures.add(issue.code);
      return issues.length === 0;
    }).map((unit) => unit.id);
    candidates.set(party.id, ids);
    rejected.set(party.id, failures);
  }
  pending.sort((a, b) => candidates.get(a.id)!.length -
    candidates.get(b.id)!.length || b.priority - a.priority ||
    a.id.localeCompare(b.id));
  const exact = pending.length <= 6 && inventory.length <= 8;
  type State = {rows: LodgingPlacement[]; score: number[]; key: string};
  const state = (rows: LodgingPlacement[]): State => ({rows,
    score: lodgingScore(snapshot, rows), key: placementKey(rows)});
  const order = (a: State, b: State) => compare(a.score, b.score) ||
    a.key.localeCompare(b.key);
  let states = [state(locked)];
  let explored = 0;
  let complete = exact;
  for (const party of pending) {
    const next: State[] = [];
    for (const current of states) {
      next.push(current); // Unplaced demand remains explicit.
      for (const inventoryId of candidates.get(party.id)!) {
        if (explored >= maxStates) {
          complete = false; break;
        }
        explored++;
        const rows = [...current.rows, {partyId: party.id, inventoryId}];
        if (!validate(rows).length) {
          next.push(state(rows));
        }
      }
    }
    next.sort(order);
    states = exact ? next : next.slice(0, beamWidth);
    if (explored >= maxStates) break;
  }
  states.sort(order);
  let best = states[0];
  // Single moves solve coherent overflow (20+1 ->19+2). Swaps let a scarce
  // accessible/suite unit change hands without temporarily breaking capacity.
  for (let pass = 0; pass < 6 && explored < maxStates; pass++) {
    let improved = best;
    const consider = (rows: LodgingPlacement[]) => {
      if (explored >= maxStates) {
        complete = false; return;
      }
      explored++;
      if (validate(rows).length) return;
      const candidate = state(rows);
      if (order(candidate, improved) < 0) improved = candidate;
    };
    for (const party of pending) {
      for (const inventoryId of candidates.get(party.id)!) {
        consider([...best.rows.filter((r) => r.partyId !== party.id),
          {partyId: party.id, inventoryId}]);
      }
    }
    for (let i = 0; i < best.rows.length; i++) {
      for (let j = i + 1; j < best.rows.length; j++) {
        const a = best.rows[i];
        const b = best.rows[j];
        if (!candidates.has(a.partyId) || !candidates.has(b.partyId)) continue;
        consider(best.rows.map((r) => r === a ?
          {...a, inventoryId: b.inventoryId} : r === b ?
            {...b, inventoryId: a.inventoryId} : r));
      }
    }
    if (improved === best) break;
    best = improved;
  }
  const missing = snapshot.parties.filter((p) =>
    !best.rows.some((r) => r.partyId === p.id)).map((p) => p.id).sort();
  const explanations = missing.map((id) => `${id}: unplaced; ` +
    (candidates.get(id)?.length ? "feasible units compete with other parties" :
      [...rejected.get(id) ?? []].sort().join(", ") ||
        "no contracted inventory"));
  explanations.push(`${best.score[3]} socially isolated parties; ` +
    `${best.score[2]} changes to published placements.`);
  explanations.push(complete ? "Exhaustive search completed." :
    "Bounded search; a better feasible allocation may exist.");
  return immutableLodgingProposal(snapshot, best.rows, explanations,
    {complete, explored});
}

/** Manual moves create a new immutable proposal through this same boundary. */
export function immutableLodgingProposal(snapshot: LodgingSnapshot,
  placements: readonly LodgingPlacement[], explanations: readonly string[] = [],
  search = {complete: false, explored: 0}): LodgingProposal {
  assertLodgingSnapshot(snapshot);
  const issues = validateLodgingPlacements(snapshot, placements);
  if (issues.length) throw new Error(issues.map((i) => i.code).join(", "));
  const rows = [...placements].sort((a, b) =>
    a.partyId.localeCompare(b.partyId))
    .map((row) => Object.freeze({...row}));
  const revisions = Object.freeze({...snapshot.revisions});
  const scope = Object.freeze({...snapshot.scope});
  const id = createHash("sha256")
    .update(JSON.stringify({scope, revisions, rows}))
    .digest("hex");
  return Object.freeze({id, scope, revisions, placements: Object.freeze(rows),
    unplacedPartyIds: Object.freeze(snapshot.parties.filter((p) =>
      !rows.some((r) => r.partyId === p.id)).map((p) => p.id).sort()),
    explanations: Object.freeze([...explanations]),
    score: Object.freeze(lodgingScore(snapshot, rows)),
    search: Object.freeze({...search})});
}

/** Publication must perform this comparison inside its authoritative write
 * transaction, alongside current access, lock and receipt checks. */
export function assertLodgingProposalCurrent(proposal: LodgingProposal,
  current: LodgingRevisions): void {
  if ((["source", "inventory", "layout", "published"] as const).some((key) =>
    proposal.revisions[key] !== current[key])) {
    throw new Error("Stale lodging proposal; regenerate against current data.");
  }
}
