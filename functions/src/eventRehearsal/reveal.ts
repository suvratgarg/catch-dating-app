import {HttpsError} from "firebase-functions/v2/https";
import type {EventRehearsalDocument as Session} from
  "../shared/generated/firestoreAdminTypes";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {EventRehearsalBootstrapCallableResponse as Bootstrap} from
  "../shared/generated/eventRehearsalBootstrapCallableResponse";

type State = NonNullable<Session["revealControl"]>;
type Command = NonNullable<Control["reveal"]>;
export type PracticeRevealReview = NonNullable<Bootstrap["revealReview"]>;

export interface PracticeRevealResult {
  state: State;
  replayed: boolean;
  publishedNow: boolean;
}

const defaultCountdownSeconds = 10;

/** Projects reveal state after applying elapsed virtual countdown time. */
export function practiceRevealReview(session: Session): PracticeRevealReview {
  const state = settlePracticeReveal(session);
  return {
    revision: state.revision,
    status: state.status,
    publishedRound: state.publishedRound,
    pendingRound: state.pendingRound,
    startedAt: state.startedAt?.toMillis() ?? null,
    countdownSeconds: state.countdownSeconds,
  };
}

/** Applies one manager-authored reveal decision in virtual rehearsal time. */
export function preparePracticeReveal(
  session: Session,
  command: Command
): PracticeRevealResult {
  if (!["running", "paused"].includes(session.status)) {
    throw new HttpsError("failed-precondition",
      "Practice reveals are available only while rehearsal is active.");
  }
  const raw = session.revealControl ?? initialPracticeReveal();
  const state = settlePracticeReveal(session);
  if (command.expectedLiveRevision !== state.revision) {
    throw new HttpsError("aborted",
      "Practice reveal state changed. Review it again.");
  }
  if (state.lastDecisionId === command.decisionId) {
    if (state.lastAction !== command.action) {
      throw new HttpsError("aborted",
        "This reveal decision id already belongs to another action.");
    }
    return {state, replayed: true, publishedNow: false};
  }
  const autoPublished = raw.status === "countingDown" &&
    state.status === "revealed" &&
    state.publishedRound > raw.publishedRound;
  if (command.action === "publish" && autoPublished) {
    return {state, replayed: true, publishedNow: true};
  }
  if (state.revision >= 2147483647) {
    throw new HttpsError("resource-exhausted",
      "The practice reveal revision limit has been reached.");
  }
  const common = {revision: state.revision + 1,
    lastDecisionId: command.decisionId, lastAction: command.action};
  switch (command.action) {
  case "startCountdown": {
    if (state.status === "countingDown") {
      throw new HttpsError("failed-precondition",
        "A practice reveal countdown is already active.");
    }
    const pendingRound = nextRound(state);
    return {replayed: false, publishedNow: false, state: {...state, ...common,
      status: "countingDown", pendingRound,
      startedAt: session.virtualNow}};
  }
  case "cancelPending":
    if (state.status !== "countingDown" || state.pendingRound === null) {
      throw new HttpsError("failed-precondition",
        "There is no pending practice reveal to cancel.");
    }
    return {replayed: false, publishedNow: false, state: {...state, ...common,
      status: state.publishedRound >= 0 ? "revealed" : "idle",
      pendingRound: null, startedAt: null}};
  case "publish": {
    const publishedRound = state.status === "countingDown" &&
      state.pendingRound !== null ? state.pendingRound : nextRound(state);
    return {replayed: false, publishedNow: true, state: {...state, ...common,
      status: "revealed", publishedRound, pendingRound: null,
      startedAt: null}};
  }
  }
}

/** Resolves an elapsed virtual countdown without advancing its revision. */
export function settlePracticeReveal(session: Session): State {
  const state = session.revealControl ?? initialPracticeReveal();
  if (state.status !== "countingDown" || state.pendingRound === null ||
      state.startedAt === null ||
      state.startedAt.toMillis() + state.countdownSeconds * 1000 >
        session.virtualNow.toMillis()) {
    return state;
  }
  return {...state, status: "revealed",
    publishedRound: state.pendingRound, pendingRound: null, startedAt: null};
}

function initialPracticeReveal(): State {
  return {revision: 0, status: "idle", publishedRound: -1,
    pendingRound: null, startedAt: null,
    countdownSeconds: defaultCountdownSeconds,
    lastDecisionId: null, lastAction: null};
}

function nextRound(state: State): number {
  if (state.publishedRound >= 100) {
    throw new HttpsError("resource-exhausted",
      "This rehearsal reached its reveal-round limit.");
  }
  return state.publishedRound + 1;
}
