import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {readLateJoinSource, LateJoinSourceScope, completeLateJoinInput} from
  "./lateJoinSourceReader";
import {readLateJoinMessageHistory} from "./lateJoinMessageHistory";
import {EventMessageRouteSelection, readEventMessageContactability} from
  "./messageContactability";
import {evaluateLateJoin} from "./lateJoin";
import type {MessageRecord} from "./messageOutbox";
import type {LateJoinMessageOptions} from "./messageProtocol";
import {RuntimeBinding, RuntimeConfiguration, readRuntimeConfigAuthority} from
  "./runtimeConfigRecords";

/** Runtime choices; sender eligibility still comes from authoritative facts. */
export interface LateJoinEvaluationOptions {
  routes: readonly EventMessageRouteSelection[];
  responseDeadline: number | null;
  runtimeBinding?: RuntimeBinding;
  deliveryPolicy?: LateJoinMessageOptions["deliveryPolicy"];
  laterChoices?: LateJoinMessageOptions["laterChoices"];
}

/**
 * Current live facts feed the same evaluator as rehearsal. This transaction is
 * read-only; publication and dispatch must revalidate at their own commit.
 */
export async function readLiveLateJoinEvaluation(db: Firestore, tx: Transaction,
  scope: LateJoinSourceScope, options: LateJoinEvaluationOptions, now: number,
  currentIntent?: MessageRecord["intent"]) {
  let runtimeConfiguration: RuntimeConfiguration | null = null;
  if (options.runtimeBinding) {
    const authority = await readRuntimeConfigAuthority(db, tx, scope.context,
      options.runtimeBinding, now);
    if (authority.kind === "unavailable") {
      return {kind: "runtimeUnavailable" as const, reason: authority.reason};
    }
    runtimeConfiguration = authority.configuration;
    // Final dispatch uses an immutable already-published intent. Its runtime
    // revision binds the custom choice configuration; publication compares
    // those choices to the reviewed configuration before creating the intent.
    const laterChoices = currentIntent ?
      runtimeConfiguration.options.laterChoices : options.laterChoices;
    if (!options.deliveryPolicy || operationContentHash({
      routes: options.routes, responseDeadline: options.responseDeadline,
      deliveryPolicy: options.deliveryPolicy,
      ...(laterChoices ? {laterChoices} : {}),
    }) !== operationContentHash(runtimeConfiguration.options)) {
      return {kind: "runtimeUnavailable" as const,
        reason: "configurationChanged" as const};
    }
  }
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
    routes, runtimeConfiguration,
    sourceHash: operationContentHash([source.sourceHash,
      history.evidenceHash, routes, options.responseDeadline,
      options.runtimeBinding ?? null])};
}
