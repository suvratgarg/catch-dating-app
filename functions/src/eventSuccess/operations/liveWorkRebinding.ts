import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {OperationConflictError} from "../../operations/errors";
import {currentGuest, guestCollections, guestIdentity, parseGuest,
  readGuestSourceFacts} from "./guestRecords";
import {LiveWork, parseLiveWork} from "./liveWorkRecords";
import {readRuntimeConfigAuthority, RuntimeBinding} from
  "./runtimeConfigRecords";

/** Reads the new authority in the same transaction as the leased checkpoint. */
export async function prepareLiveWorkRebind(db: Firestore, tx: Transaction,
  payload: LiveWork, binding: RuntimeBinding, now: number):
  Promise<LiveWork | null> {
  // Delayed cleanup must not make an expired episode restartable.
  if (now >= payload.expiresAt) return null;
  const {context, attendeeId, episodeId} = payload.scope;
  const authority = await readRuntimeConfigAuthority(db, tx, context,
    binding, now);
  if (authority.kind !== "ready") throw conflict();
  const source = await readGuestSourceFacts(db, tx, context, attendeeId);
  const guest = parseGuest((await tx.get(db.collection(guestCollections.guests)
    .doc(guestIdentity(context, attendeeId)))).data());
  if (!currentGuest(guest, source) || guest.updatedAt > now ||
      guest.episodeId !== episodeId) throw conflict();
  const configuration = authority.configuration;
  const currentConfiguration = {options: payload.options,
    expiresAt: payload.expiresAt, maxEvaluations: payload.maxEvaluations};
  if (operationContentHash(payload.runtimeBinding ?? null) ===
      operationContentHash(binding)) {
    if (operationContentHash(currentConfiguration) !==
        operationContentHash(configuration)) throw conflict();
    return null;
  }
  if (payload.runtimeBinding &&
      payload.runtimeBinding.revision >= binding.revision) throw conflict();
  // Counters, responses, messages and participation stay on the same episode.
  // A lower limit may already be exhausted; raising it adds only the delta.
  return parseLiveWork({...payload, ...configuration,
    runtimeBinding: binding, checkpoint: {...payload.checkpoint,
      dueAt: payload.checkpoint.observation?.kind === "evaluationLimit" &&
        payload.checkpoint.evaluations >= configuration.maxEvaluations ?
        configuration.expiresAt : now}}, now);
}

function conflict() {
  return new OperationConflictError("work_configuration_conflict",
    "Current event configuration and participation are required");
}
