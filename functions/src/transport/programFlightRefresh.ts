import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithSecrets} from
  "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireProgramAccess} from "../shared/programAuthority";
import {validateCallableWithAjv} from "../shared/validation";
import type {RefreshProgramTravelLegCallablePayload} from
  "../shared/generated/refreshProgramTravelLegCallablePayload";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import {
  validateRefreshProgramTravelLegCallablePayload,
} from "../shared/generated/validators/refreshProgramTravelLegInput";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  aeroDataBoxApiKey,
  fetchFlightStatus,
} from "./aeroDataBox";
import {
  refreshDueFlightLegs,
  refreshTravelLegForRequest,
  FlightRefreshDeps,
} from "./flightRefresh";

export interface RefreshDeps extends FlightRefreshDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
}

const defaultRefreshDeps: RefreshDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => new Date(),
  apiKey: () => aeroDataBoxApiKey.value(),
  fetchStatus: fetchFlightStatus,
};

export async function refreshProgramTravelLegHandler(
  request: CallableRequest<unknown>,
  deps: RefreshDeps = defaultRefreshDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<RefreshProgramTravelLegCallablePayload>(
      request,
      validateRefreshProgramTravelLegCallablePayload,
    );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "refreshProgramTravelLeg");
  await requireProgramAccess({
    db, programId: data.programId, actorUid,
    now: admin.firestore.Timestamp.fromDate(deps.now()),
  });
  const outcome = await refreshTravelLegForRequest(
    db, data.programId, data.legId, deps);
  const legSnap =
    await db.collection("programTravelLegs").doc(data.legId).get();
  const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
  logger.info("Manual flight refresh completed", {
    legId: data.legId, programId: data.programId, outcome,
  });
  return {
    entityId: data.legId,
    revision: leg?.revision ?? 0,
    alreadyApplied: false,
  };
}

export const refreshProgramTravelLeg = onCall(
  appCheckCallableOptionsWithSecrets([aeroDataBoxApiKey],
    {timeoutSeconds: 30}),
  async (request) => refreshProgramTravelLegHandler(request),
);

export const refreshProgramFlightStatuses = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Asia/Kolkata",
    secrets: [aeroDataBoxApiKey],
  },
  async () => {
    const summary = await refreshDueFlightLegs(
      admin.firestore(), defaultRefreshDeps);
    if (summary.updated + summary.failed > 0) {
      logger.info("Program flight refresh sweep completed", summary);
    }
  },
);
