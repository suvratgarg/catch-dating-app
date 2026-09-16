import {HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import type {
  EventRehearsalActorDocument as Actor,
  EventRehearsalDocument as Session,
} from "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {SubmitEventRehearsalGuestActionCallablePayload as GuestAction} from
  "../shared/generated/submitEventRehearsalGuestActionCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";
import {operationContentHash as hash} from "../operations/durableActions";
import {practiceContext} from "./assistanceIdentity";

type State = NonNullable<Actor["requiredData"]>;
type HostCommand = NonNullable<Control["requiredData"]>;
type GuestSubmission = NonNullable<GuestAction["requiredData"]>;
export type RequiredDataReview = NonNullable<
  Bootstrap["actors"][number]["requiredData"]>;
type FieldId = RequiredDataReview["availableFieldIds"][number];

export const practiceRuntimeFieldIds = [
  "displayName",
  "gender",
  "interestedInGenders",
  "relationshipGoal",
  "dateOfBirth",
  "paceBand",
  "skillBand",
  "dietaryAndSeatingNotes",
  "questionnaireAnswerIds",
  "teamName",
] as const satisfies readonly FieldId[];

/** New synthetic actors begin with only the display name supplied. */
export function initialPracticeRequiredData(): State {
  return {profileRevision: 0, completedFieldIds: ["displayName"],
    requestRevision: 0, request: null};
}

/** Projects the synthetic profile and prompt without exposing values. */
export function practiceRequiredDataReview(
  session: Session,
  actor: Actor
): RequiredDataReview {
  const state = practiceRequiredDataState(actor);
  const now = session.virtualNow.toMillis();
  const request = state.request;
  return {
    sourceHash: practiceRequiredDataSourceHash(session, actor, state),
    profileRevision: state.profileRevision,
    requestRevision: state.requestRevision,
    availableFieldIds: [...practiceRuntimeFieldIds],
    completedFieldIds: canonicalFields(state.completedFieldIds),
    request: request ? {
      revision: request.revision,
      fieldIds: canonicalFields(request.fieldIds),
      completedFieldIds: canonicalFields(request.completedFieldIds),
      status: request.status === "pending" &&
        request.expiresAt.toMillis() <= now ? "expired" : request.status,
      requestedAt: request.requestedAt.toMillis(),
      expiresAt: request.expiresAt.toMillis(),
      completedAt: request.completedAt?.toMillis() ?? null,
    } : null,
  };
}

/** Applies a Host request only to current, missing synthetic fields. */
export function preparePracticeRequiredDataRequest(
  session: Session,
  actor: Actor,
  command: HostCommand
): Actor {
  if (!["running", "paused"].includes(session.status)) {
    throw closed();
  }
  if (command.attendeeId !== actor.actorId) {
    throw new HttpsError("not-found", "Practice guest not found.");
  }
  const state = practiceRequiredDataState(actor);
  const review = practiceRequiredDataReview(session, actor);
  if (command.expectedProfileRevision !== state.profileRevision ||
      command.expectedRequestRevision !== state.requestRevision ||
      command.expectedSourceHash !== review.sourceHash) {
    throw conflict();
  }
  const now = session.virtualNow.toMillis();
  const eventEnd = session.virtualStartedAt.toMillis() +
    session.setup.durationMinutes * 60_000;
  if (command.expiresAt <= now || command.expiresAt > eventEnd) {
    throw new HttpsError("failed-precondition",
      "The practice request deadline is outside the event window.");
  }
  const fields = canonicalFields(command.fieldIds);
  if (fields.length !== command.fieldIds.length || fields.some((field) =>
    state.completedFieldIds.includes(field))) {
    throw new HttpsError("failed-precondition",
      "Only current missing practice fields can be requested.");
  }
  const revision = state.requestRevision + 1;
  const virtualNow = Timestamp.fromMillis(now);
  return {...actor, requiredData: {...state, requestRevision: revision,
    request: {revision, sourceHash: review.sourceHash, fieldIds: fields,
      completedFieldIds: [], status: "pending", requestedAt: virtualNow,
      expiresAt: Timestamp.fromMillis(command.expiresAt), completedAt: null}}};
}

/** Completes some or all requested fields using synthetic practice answers. */
export function applyPracticeRequiredDataSubmission(
  session: Session,
  actor: Actor,
  submission: GuestSubmission
): Actor {
  const state = practiceRequiredDataState(actor);
  const review = practiceRequiredDataReview(session, actor);
  const request = state.request;
  if (submission.expectedProfileRevision !== state.profileRevision ||
      submission.expectedRequestRevision !== state.requestRevision ||
      submission.expectedSourceHash !== review.sourceHash) {
    throw conflict();
  }
  if (!request || request.status !== "pending" ||
      request.expiresAt.toMillis() <= session.virtualNow.toMillis()) {
    throw new HttpsError("failed-precondition",
      "There is no current practice data request.");
  }
  const fields = canonicalFields(submission.fieldIds);
  if (fields.length !== submission.fieldIds.length || fields.some((field) =>
    !request.fieldIds.includes(field) ||
    state.completedFieldIds.includes(field))) {
    throw new HttpsError("failed-precondition",
      "Submit only fields from the current practice request.");
  }
  const completedFieldIds = canonicalFields([
    ...state.completedFieldIds,
    ...fields,
  ]);
  const requestCompletedFieldIds = canonicalFields([
    ...request.completedFieldIds,
    ...fields,
  ]);
  const complete = request.fieldIds.every((field) =>
    requestCompletedFieldIds.includes(field));
  return {...actor, requiredData: {...state,
    profileRevision: state.profileRevision + 1,
    completedFieldIds,
    request: {...request, completedFieldIds: requestCompletedFieldIds,
      status: complete ? "completed" : "pending",
      completedAt: complete ? Timestamp.fromMillis(
        session.virtualNow.toMillis()) : null}}};
}

function practiceRequiredDataState(actor: Actor): State {
  return actor.requiredData ?? initialPracticeRequiredData();
}

function practiceRequiredDataSourceHash(
  session: Session,
  actor: Actor,
  state: State
): string {
  return hash([practiceContext(session, actor), actor.actorId,
    session.setup.moduleIds, state.profileRevision,
    canonicalFields(state.completedFieldIds)]);
}

function canonicalFields(values: readonly FieldId[]): FieldId[] {
  const selected = new Set(values);
  return practiceRuntimeFieldIds.filter((field) => selected.has(field));
}

function conflict(): HttpsError {
  return new HttpsError("aborted",
    "Practice profile changed. Review it again.");
}

function closed(): HttpsError {
  return new HttpsError("failed-precondition",
    "Practice data requests are available only while rehearsal is running.");
}
