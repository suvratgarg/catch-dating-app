import {HttpsError} from "firebase-functions/v2/https";
import type {EventSuccessPlanDocument} from
  "../shared/generated/eventSuccessPlanDocument";
import type {OrganizerEventSuccessLayoutDocument} from
  "../shared/generated/firestoreAdminTypes";
import {assignmentConstraintPairKey} from "./assignmentConstraints";

export type SpatialDestinationReason =
  "capacity" | "safetyKeepApart" | "declaredConstraint";
export type SpatialConstraintScope = "thisRound" | "pinned";

export interface SpatialDestinationResolution {
  unitId: string;
  valid: boolean;
  reason: SpatialDestinationReason | null;
  recommendedScope: SpatialConstraintScope | null;
}

export interface SpatialAssignmentPosition {
  uid: string;
  layoutUnitId?: string;
}

/** Resolves all units before the second tap with exhaustive invalid reasons. */
export function resolveSpatialDestinations(params: {
  layout: OrganizerEventSuccessLayoutDocument;
  assignments: SpatialAssignmentPosition[];
  selectedUid: string;
  blockedPairs?: Set<string>;
  affinityConstraints?: EventSuccessPlanDocument["affinityConstraints"];
}): SpatialDestinationResolution[] {
  const selected = params.assignments.find(
    (assignment) => assignment.uid === params.selectedUid
  );
  const occupantsByUnit = new Map<string, string[]>();
  for (const assignment of params.assignments) {
    if (!assignment.layoutUnitId || assignment.uid === params.selectedUid) {
      continue;
    }
    const occupants = occupantsByUnit.get(assignment.layoutUnitId) ?? [];
    occupants.push(assignment.uid);
    occupantsByUnit.set(assignment.layoutUnitId, occupants);
  }
  const declaredApartPairs = new Set(
    (params.affinityConstraints ?? [])
      .filter((constraint) => constraint.value === "mustSplit")
      .map((constraint) => assignmentConstraintPairKey(
        constraint.aUid,
        constraint.bUid
      ))
  );
  return [...params.layout.units]
    .sort((a, b) => a.order - b.order || a.id.localeCompare(b.id))
    .map((unit) => {
      if (selected?.layoutUnitId === unit.id) {
        return invalidDestination(unit.id, "declaredConstraint");
      }
      const occupants = (occupantsByUnit.get(unit.id) ?? []).sort();
      if (occupants.length >= unit.capacity) {
        return invalidDestination(unit.id, "capacity");
      }
      // A pairwise affinity constraint cannot honestly represent placement
      // into a completely empty unit, so the operation remains unavailable.
      if (occupants.length === 0) {
        return invalidDestination(unit.id, "declaredConstraint");
      }
      if (occupants.some((uid) => params.blockedPairs?.has(
        assignmentConstraintPairKey(params.selectedUid, uid)
      ))) {
        return invalidDestination(unit.id, "safetyKeepApart");
      }
      if (occupants.some((uid) => declaredApartPairs.has(
        assignmentConstraintPairKey(params.selectedUid, uid)
      ))) {
        return invalidDestination(unit.id, "declaredConstraint");
      }
      return {
        unitId: unit.id,
        valid: true,
        reason: null,
        // Every valid destination is anchored to a named attendee so the
        // default is the durable consequence. Host can still explicitly pick
        // `thisRound` when filling a temporary capacity gap.
        recommendedScope: "pinned" as const,
      };
    });
}

/** Returns the stable named peer used by the persisted pairwise constraint. */
export function destinationPeerUid(params: {
  assignments: SpatialAssignmentPosition[];
  selectedUid: string;
  destinationUnitId: string;
}): string | null {
  return params.assignments
    .filter((assignment) =>
      assignment.uid !== params.selectedUid &&
      assignment.layoutUnitId === params.destinationUnitId
    )
    .map((assignment) => assignment.uid)
    .sort()[0] ?? null;
}

/** Applies one reassignment as both a spatial projection and T2 constraint. */
export function spatialReassignmentPlanFields(params: {
  plan: SpatialPlanFields;
  uid: string;
  targetPeerUid: string;
  layoutUnitId: string;
  scope: SpatialConstraintScope;
}): SpatialPlanFields {
  const pairKey = assignmentConstraintPairKey(
    params.uid,
    params.targetPeerUid
  );
  const affinityConstraints = (params.plan.affinityConstraints ?? [])
    .filter((constraint) => assignmentConstraintPairKey(
      constraint.aUid,
      constraint.bUid
    ) !== pairKey);
  affinityConstraints.push({
    aUid: params.uid,
    bUid: params.targetPeerUid,
    value: "mustPair",
    scope: params.scope,
  });
  const spatialOverrides = (params.plan.spatialOverrides ?? [])
    .filter((override) => override.uid !== params.uid);
  spatialOverrides.push({
    uid: params.uid,
    targetPeerUid: params.targetPeerUid,
    layoutUnitId: params.layoutUnitId,
    scope: params.scope,
  });
  return {affinityConstraints, spatialOverrides};
}

/** Releases one pinned placement and its matching pair constraint. */
export function releasedSpatialPlanFields(params: {
  plan: SpatialPlanFields;
  uid: string;
}): SpatialPlanFields {
  const released = (params.plan.spatialOverrides ?? [])
    .filter((override) => override.uid === params.uid &&
      override.scope === "pinned");
  const releasedPairs = new Set(released.map((override) =>
    assignmentConstraintPairKey(override.uid, override.targetPeerUid)
  ));
  return {
    spatialOverrides: (params.plan.spatialOverrides ?? [])
      .filter((override) => !(override.uid === params.uid &&
        override.scope === "pinned")),
    affinityConstraints: (params.plan.affinityConstraints ?? [])
      .filter((constraint) => !(
        constraint.scope === "pinned" &&
        releasedPairs.has(assignmentConstraintPairKey(
          constraint.aUid,
          constraint.bUid
        ))
      )),
  };
}

type SpatialPlanFields = Pick<
  EventSuccessPlanDocument,
  "affinityConstraints" | "spatialOverrides"
>;

/** Applies the same revision fence used by T4 live controls. */
export function requireSpatialRevision(
  currentRevision: unknown,
  expectedRevision: number
): number {
  const current = Number.isInteger(currentRevision) &&
      (currentRevision as number) >= 0 ? currentRevision as number : 0;
  if (current !== expectedRevision) {
    throw new HttpsError(
      "aborted",
      "The live event guide changed on another device. Refresh and retry."
    );
  }
  if (current >= 2147483647) {
    throw new HttpsError(
      "resource-exhausted",
      "The live-control revision limit has been reached."
    );
  }
  return current + 1;
}

/** Confirms only the attendee's current assigned position. */
export function confirmedSpatialUnitId(
  assignment: SpatialAssignmentPosition
): string {
  if (!assignment.layoutUnitId) {
    throw new HttpsError(
      "failed-precondition",
      "Assign this attendee to a room unit before confirming."
    );
  }
  return assignment.layoutUnitId;
}

function invalidDestination(
  unitId: string,
  reason: SpatialDestinationReason
): SpatialDestinationResolution {
  return {unitId, valid: false, reason, recommendedScope: null};
}
