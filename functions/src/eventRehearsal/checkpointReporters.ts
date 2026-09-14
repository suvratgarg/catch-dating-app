import {organizerHostProfiles, organizerManagerUserIds} from
  "../shared/organizerHosts";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import {practiceGroupPermission, practiceIsManager, practiceStaffState} from
  "./groupStaff";
import type {PracticeCaseAuthority} from "./assistanceCases";
import type {MovementSource, Review} from "./movementSource";

type Checkpoint = NonNullable<Review["checkpoint"]>;

/** Original-deadline choices; selecting a person never grants a new duty. */
export function practiceCheckpointReporters(session: Session,
  source: MovementSource, authority: PracticeCaseAuthority,
  availability: Checkpoint["availability"],
  assignment: Checkpoint["assignment"], request: Checkpoint["request"]
): Checkpoint["reporterOptions"] {
  if (!practiceIsManager(authority) || !request || !assignment ||
      availability.kind !== "ready" ||
      ["complete", "closedOut"].includes(request.state) ||
      assignment.revision >= Number.MAX_SAFE_INTEGER ||
      !["running", "paused", "complete"].includes(session.status) ||
      session.actionCount >= 500 || session.runtimeRevision >= 2147483647) {
    return null;
  }
  const managers = organizerManagerUserIds(authority.organizer);
  const profiles = organizerHostProfiles(authority.organizer);
  const operators = practiceStaffState(source.sessionId, session).operators;
  const candidates = [
    ...managers.filter((id) => !id.startsWith("practice-staff:"))
      .map((operatorId) => ({operatorId,
        displayName: profiles.find((p) => p.uid === operatorId)?.displayName ??
        null})),
    ...operators.map((o) => ({operatorId: o.operatorId,
      displayName: o.displayName})),
  ];
  const reporters = candidates.flatMap((candidate) => {
    const validUntil = practiceGroupPermission(source.sessionId, session,
      authority, source.groupId, "recordCheckpoint", candidate.operatorId);
    return validUntil !== null && validUntil > Math.max(source.now,
      request.dueAt) ? [{...candidate, validUntil}] : [];
  });
  reporters.sort((a, b) => a.operatorId.localeCompare(b.operatorId));
  return {actorUid: authority.actorUid, sourceHash: assignment.sourceHash,
    validUntil: Math.min(Number.MAX_SAFE_INTEGER, source.now + 1_800_000),
    reporters};
}
