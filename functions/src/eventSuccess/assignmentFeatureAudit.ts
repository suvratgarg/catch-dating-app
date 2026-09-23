import {createHash} from "node:crypto";
import {EventAssignmentFeatureSnapshot} from "./assignmentFeatureScoring";

export const ASSIGNMENT_FEATURE_ALGORITHM_VERSION =
  "typed-soft-features-v1";

export interface AssignmentFeatureAudit {
  algorithmVersion: string;
  configHash: string;
  inputSnapshotId: string;
}

/** Public-safe identity for the exact private inputs used in a generation.
 * Source/subject IDs remain inside a digest; answer values are never included.
 */
export function buildAssignmentFeatureAudit(params: {
  eventId: string;
  organizerId: string;
  configHash: string;
  snapshots: EventAssignmentFeatureSnapshot[];
}): AssignmentFeatureAudit {
  const {eventId, organizerId, configHash, snapshots} = params;
  if (!eventId || !organizerId || !configHash) {
    throw new Error("Incomplete assignment feature audit identity.");
  }
  const sourceIds = snapshots.map((snapshot) => [
    snapshot.eventId, snapshot.organizerId, snapshot.uid,
    snapshot.featureId, snapshot.formId, snapshot.versionId,
    snapshot.questionId, snapshot.transformVersion,
    snapshot.responseId, snapshot.consentReceiptId,
  ]);
  sourceIds.sort((a, b) => JSON.stringify(a).localeCompare(
    JSON.stringify(b)));
  const inputSnapshotId = createHash("sha256").update(JSON.stringify({
    algorithmVersion: ASSIGNMENT_FEATURE_ALGORITHM_VERSION,
    eventId, organizerId, configHash, sourceIds,
  })).digest("hex");
  return {algorithmVersion: ASSIGNMENT_FEATURE_ALGORITHM_VERSION,
    configHash, inputSnapshotId};
}
