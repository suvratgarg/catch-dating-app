import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session,
  EventRehearsalActorDocument as Actor, OrganizerDocument} from
  "../shared/generated/firestoreAdminTypes";
import type {EventRehearsalCaseDocument as Case} from
  "../shared/generated/eventRehearsalCaseDocument";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {validateEventRehearsalCaseDocument} from
  "../shared/generated/validators/eventRehearsalCaseDocument";
import {validateOrganizerDocument} from
  "../shared/generated/validators/organizerDocument";
import {operationContentHash as hash} from "../operations/durableActions";
import {isOrganizerManager} from "../shared/organizerHosts";
import {resolvePracticalCaseHandling, PracticalHandlingCommand} from
  "../eventSuccess/operations/practicalCaseHandling";
import {practiceContext} from "./assistanceRuntime";
import {REHEARSAL_MAX_ACTIONS} from "./engine";

export const rehearsalCases = "eventRehearsalCases";
export type PracticeCaseAuthority = {actorUid: string;
  organizer: OrganizerDocument};

function identity(session: Session, actor: Pick<Actor, "sessionId" | "actorId">,
  source: Case["source"]): string {
  return "practice-case:" + hash([practiceContext(session, actor),
    actor.actorId, source]);
}
function invalid(): HttpsError {
  return new HttpsError("failed-precondition",
    "Practice help request history needs review.");
}
export function readPracticeCase(value: unknown, id: string,
  session: Session, actor: Pick<Actor, "sessionId" | "actorId">): Case {
  if (!validateEventRehearsalCaseDocument(value) || value.caseId !== id ||
      value.sessionId !== actor.sessionId || value.actorId !== actor.actorId ||
      value.clockId !== practiceContext(session, actor).clockId ||
      value.caseId !== identity(session, actor, value.source) ||
      value.receivedAt < session.virtualStartedAt.toMillis() ||
      value.receivedAt > session.virtualNow.toMillis()) throw invalid();
  const h = value.handling;
  if (h.updatedAt < value.receivedAt ||
      h.updatedAt > session.virtualNow.toMillis() ||
      (h.revision === 0 && (h.assigneeUid !== null ||
        h.updatedAt !== value.receivedAt)) ||
      (h.resolution && h.resolution.at !== h.updatedAt)) throw invalid();
  return value;
}

/** Stage creation until all parent message and automation reads finish. */
export async function preparePracticeHelp(db: Firestore, tx: Transaction,
  session: Session, actor: Actor, source: Case["source"],
  category: Case["category"]) {
  const caseId = identity(session, actor, source);
  const ref = db.collection(rehearsalCases).doc(caseId);
  const snap = await tx.get(ref);
  if (snap.exists) {
    const prior = readPracticeCase(snap.data(), snap.id, session, actor);
    // An old reply cannot reopen its settled request.
    return {actor: prior.status === "open" ?
      {...actor, helpRequested: true} : actor, commit: () => {}};
  }
  const now = session.virtualNow.toMillis();
  const value = readPracticeCase({caseId, sessionId: actor.sessionId,
    actorId: actor.actorId, clockId: practiceContext(session, actor).clockId,
    source, category, receivedAt: now, status: "open",
    handling: {revision: 0, assigneeUid: null, updatedAt: now,
      resolution: null}}, caseId, session, actor);
  return {actor: {...actor, helpRequested: true,
    untrackedHelpRequested:
      actor.untrackedHelpRequested ?? actor.helpRequested},
  commit: () => tx.create(ref, value)};
}

export async function resolvePracticeHelp(db: Firestore, tx: Transaction,
  session: Session, actor: Actor, command: PracticalHandlingCommand,
  expectedSourceHash: string,
  authority: PracticeCaseAuthority): Promise<Actor> {
  const ref = db.collection(rehearsalCases).doc(command.caseId);
  const query = db.collection(rehearsalCases)
    .where("sessionId", "==", actor.sessionId)
    .where("clockId", "==", practiceContext(session, actor).clockId)
    .where("actorId", "==", actor.actorId).where("status", "==", "open")
    .limit(REHEARSAL_MAX_ACTIONS + 1);
  const [snap, open] = await Promise.all([tx.get(ref), tx.get(query)]);
  if (!snap.exists) {
    throw new HttpsError("not-found",
      "Practice help request not found.");
  }
  const value = readPracticeCase(snap.data(), snap.id, session, actor);
  if (hash(value) !== expectedSourceHash) {
    throw new HttpsError("aborted",
      "This help request changed. Review it again.");
  }
  if (open.size > REHEARSAL_MAX_ACTIONS) throw invalid();
  const current = open.docs.map((doc) =>
    readPracticeCase(doc.data(), doc.id, session, actor));
  if (value.status === "open" &&
      !current.some((c) => c.caseId === value.caseId)) throw invalid();
  const changed = resolvePracticalCaseHandling(value, command,
    authority.actorUid, session.virtualNow.toMillis(),
    (uid) => isOrganizerManager(authority.organizer, uid));
  const next = readPracticeCase({...value, ...changed}, value.caseId,
    session, actor);
  tx.set(ref, next);
  return {...actor, helpRequested:
    (actor.untrackedHelpRequested ?? actor.helpRequested) ||
    next.status === "open" || current.some((c) => c.caseId !== next.caseId)};
}

/** Complete within the existing 500-action session cap; no guest projection. */
export async function practiceHelpProjection(db: Firestore, sessionId: string,
  session: Session, actors: readonly Actor[], actorUid: string): Promise<
    NonNullable<Bootstrap["helpRequests"]>> {
  const clockId = practiceContext(session, {sessionId}).clockId;
  const [cases, org] = await Promise.all([
    db.collection(rehearsalCases).where("sessionId", "==", sessionId)
      .where("clockId", "==", clockId).limit(REHEARSAL_MAX_ACTIONS + 1).get(),
    db.collection("organizers").doc(session.organizerId).get(),
  ]);
  const raw = org.data();
  if (!validateOrganizerDocument(raw) ||
      !isOrganizerManager(raw as unknown as OrganizerDocument, actorUid)) {
    throw new HttpsError("permission-denied", "Host authority changed.");
  }
  const organizer = raw as unknown as OrganizerDocument;
  if (cases.size > REHEARSAL_MAX_ACTIONS) throw invalid();
  const rows = cases.docs.map((doc) => {
    const actor = actors.find((a) => a.actorId === doc.data().actorId);
    if (!actor) throw invalid();
    const value = readPracticeCase(doc.data(), doc.id, session, actor);
    const uid = value.handling.assigneeUid;
    const common = {caseId: value.caseId, revision: value.handling.revision,
      sourceHash: hash(value), availability: "current" as const,
      attendeeId: value.actorId, category: value.category,
      receivedAt: value.receivedAt, assignment: uid ?
        {kind: "assigned" as const, uid,
          authority: isOrganizerManager(organizer, uid) ?
            "current" as const : "revoked" as const} :
        {kind: "unassigned" as const}};
    return value.status === "open" ? {...common, status: "open" as const,
      resolution: null, canChange: true as const} :
      {...common, status: "resolved" as const,
        resolution: value.handling.resolution, canChange: false as const};
  }).sort((a, b) => a.caseId.localeCompare(b.caseId));
  return {clockId, coverage: "boundedSession", cases: rows,
    untrackedActorIds: actors.filter((a) =>
      a.untrackedHelpRequested ?? a.helpRequested)
      .map((a) => a.actorId).sort()};
}
