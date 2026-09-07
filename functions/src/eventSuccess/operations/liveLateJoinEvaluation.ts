import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {readLateJoinSource, LateJoinSourceScope, completeLateJoinInput} from
  "./lateJoinSourceReader";
import {readLateJoinMessageHistory} from "./lateJoinMessageHistory";
import {EventMessageRouteSelection, readEventMessageContactability} from
  "./messageContactability";
import {evaluateLateJoin} from "./lateJoin";
import type {MessageRecord} from "./messageOutbox";

/** Runtime choices; never accept channel or deadline authority from clients. */
export interface LateJoinEvaluationOptions {
  routes: readonly EventMessageRouteSelection[];
  responseDeadline: number | null;
}

/**
 * Current live facts feed the same evaluator as rehearsal. This transaction is
 * read-only; publication and dispatch must revalidate at their own commit.
 */
export async function readLiveLateJoinEvaluation(db: Firestore, tx: Transaction,
  scope: LateJoinSourceScope, options: LateJoinEvaluationOptions, now: number,
  currentIntent?: MessageRecord["intent"]) {
  const source = await readLateJoinSource(db, tx, scope, now);
  if (source.kind === "notReady") {
    return {kind: "sourceNotReady" as const, source};
  }
  const history = await readLateJoinMessageHistory(db, tx,
    {...scope, episodeId: source.facts.guest.episodeId}, now, currentIntent);
  if (history.kind === "unavailable") {
    return {kind: "historyUnavailable" as const, reason: history.reason};
  }
  if (source.facts.policy.unanswered === "hostReviewAtDeadline" &&
      options.responseDeadline === null) {
    return {kind: "responseDeadlineMissing" as const};
  }
  const routes = await readEventMessageContactability(db, tx, scope,
    options.routes, "joiningUpdate", now);
  const input = completeLateJoinInput(source, {...history.facts, scope,
    episodeId: source.facts.guest.episodeId, observedAt: now,
    deliveryEligibility: routes.some((r) => r.state.kind === "canPrepare") ?
      "eligible" : "unreachable", responseDeadline: options.responseDeadline});
  return {kind: "evaluated" as const, input, decision: evaluateLateJoin(input),
    binding: {groupId: source.groupId, settingId: source.settingId,
      settingRevision: source.settingRevision},
    routes, sourceHash: operationContentHash([source.sourceHash,
      history.evidenceHash, routes, options.responseDeadline])};
}
