import type {Firestore, Transaction, DocumentSnapshot} from
  "firebase-admin/firestore";
import {operationContentHash as hash} from "../operations/durableActions";
import type {EventRehearsalRouteDecisionDocument as RouteDecision} from
  "../shared/generated/eventRehearsalRouteDecisionDocument";
import {validateEventRehearsalRouteDecisionDocument} from
  "../shared/generated/validators/eventRehearsalRouteDecisionDocument";
import {routeAlternativeId, invalidSource} from
  "../eventSuccess/operations/groupProgressSource";
import type {MovementSource} from "./movementSource";

export const rehearsalRouteDecisions = "eventRehearsalRouteDecisions";
export type {RouteDecision};

export function practiceRouteDecisionId(source: MovementSource,
  revision: number) {
  return "route-decision:" + hash([source.context, source.groupId, revision]);
}

/** Reads the latest immutable route override for one synthetic group. */
export async function readPracticeRouteDecision(db: Firestore,
  tx: Transaction, source: MovementSource): Promise<RouteDecision | null> {
  const snaps = await tx.get(db.collection(rehearsalRouteDecisions)
    .where("sessionId", "==", source.sessionId)
    .where("clockId", "==", source.context.clockId)
    .where("groupId", "==", source.groupId)
    .orderBy("progressRevision", "desc").limit(1));
  if (snaps.empty) return null;
  return readDecisionSnapshot(snaps.docs[0], source);
}

export function parsePracticeRouteDecision(value: unknown,
  source: MovementSource, expectedRevision?: number): RouteDecision {
  if (!validateEventRehearsalRouteDecisionDocument(value) ||
      value.sessionId !== source.sessionId ||
      value.clockId !== source.context.clockId ||
      value.groupId !== source.groupId ||
      expectedRevision !== undefined &&
        value.progressRevision !== expectedRevision ||
      value.previousRevision !== value.progressRevision - 1 ||
      value.departureRevision > value.previousRevision ||
      value.alternativeId !== routeAlternativeId(value.destination) ||
      value.decidedAt < source.startAt || value.decidedAt > source.now) {
    throw invalidSource();
  }
  return value;
}

function readDecisionSnapshot(snap: DocumentSnapshot,
  source: MovementSource): RouteDecision {
  const value = parsePracticeRouteDecision(snap.data(), source);
  if (snap.id !== practiceRouteDecisionId(source, value.progressRevision)) {
    throw invalidSource();
  }
  return value;
}
