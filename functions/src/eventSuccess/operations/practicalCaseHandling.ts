import {HttpsError} from "firebase-functions/v2/https";
import type {EventAssistanceCaseDocument as Case} from
  "../../shared/generated/eventAssistanceCaseDocument";
import type {EventAssistanceCommand} from
  "../../shared/generated/eventAssistanceCommand";

type Managed = Extract<Case, {owner: "eventLead"; handling: unknown}>;
export type PracticalHandlingCommand = Extract<EventAssistanceCommand,
  {kind: "resolveAssistance"}>["payload"];

/** Shared decision; each adapter owns fresh identity and authority. */
export function resolvePracticalCaseHandling(
  request: Pick<Managed, "caseId" | "status" | "handling">,
  command: PracticalHandlingCommand, actorUid: string, now: number,
  isCurrentManager: (uid: string) => boolean
) {
  if (request.status !== "open" || request.handling.resolution !== null) {
    throw new HttpsError("failed-precondition", "This help request is closed.");
  }
  if (command.caseId !== request.caseId ||
      command.expectedRevision !== request.handling.revision) {
    throw new HttpsError("aborted",
      "This help request changed. Review it again.");
  }
  if (!Number.isSafeInteger(now) || now < request.handling.updatedAt ||
      !Number.isSafeInteger(request.handling.revision + 1)) {
    throw new HttpsError("failed-precondition", "Invalid help request state.");
  }
  if (!isCurrentManager(actorUid)) {
    throw new HttpsError("permission-denied", "Host authority changed.");
  }
  const base = {revision: request.handling.revision + 1, updatedAt: now};
  if (command.outcome === "transferred") {
    if (!isCurrentManager(command.owner)) {
      throw new HttpsError("failed-precondition",
        "Choose a current organizer manager for this handoff.");
    }
    return {status: "open" as const, handling: {...base,
      assigneeUid: command.owner, resolution: null}};
  }
  if (command.owner !== actorUid) {
    throw new HttpsError("permission-denied",
      "Record this resolution under your own host identity.");
  }
  return {status: "resolved" as const, handling: {...base,
    assigneeUid: request.handling.assigneeUid,
    resolution: {outcome: command.outcome, actorUid, at: now}}};
}
