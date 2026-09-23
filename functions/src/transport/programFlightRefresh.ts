import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";

import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from
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
  fetchFlightStatus,
} from "./aeroDataBox";
import {
  createFlightSubscription,
  deleteFlightSubscription,
  syncLegAlertSubscription,
  listFlightSubscriptions,
} from "./flightSubscriptions";
import {defaultAlertBaseUrl, loadFlightProviderConfig,
  flightProviderUnavailable, type FlightProviderConfig} from
  "./flightProviderConfig";
import {
  refreshDueFlightLegs,
  refreshTravelLegForRequest,
  FlightRefreshDeps,
} from "./flightRefresh";

export interface RefreshDeps extends FlightRefreshDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
}

function configuredRefreshDeps(config: FlightProviderConfig): RefreshDeps {
  return {
    firestore: () => admin.firestore(),
    checkRateLimit,
    now: () => new Date(),
    apiKey: () => config.apiKey,
    fetchStatus: fetchFlightStatus,
    syncAlert: (legRef) => syncLegAlertSubscription(legRef, {
      now: () => new Date(),
      listSubscriptions: listFlightSubscriptions,
      apiKey: () => config.apiKey,
      secret: () => config.webhookSecret,
      baseUrl: defaultAlertBaseUrl,
      createSubscription: createFlightSubscription,
      deleteSubscription: deleteFlightSubscription,
    }),
  };
}

export async function refreshProgramTravelLegHandler(
  request: CallableRequest<unknown>,
  deps?: RefreshDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  if (!deps) {
    const config = await loadFlightProviderConfig();
    if (!config) return flightProviderUnavailable();
    deps = configuredRefreshDeps(config);
  }
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
    db, data.programId, data.legId, {...deps, syncAlert: undefined});
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
  appCheckCallableOptionsWithLimits({timeoutSeconds: 30}),
  async (request) => refreshProgramTravelLegHandler(request),
);

export const refreshProgramFlightStatuses = onSchedule(
  {
    schedule: "every 15 minutes",
    timeoutSeconds: 540,
    maxInstances: 1,
    timeZone: "Asia/Kolkata",
  },
  async () => {
    const config = await loadFlightProviderConfig();
    if (!config) return;
    const summary = await refreshDueFlightLegs(
      admin.firestore(), configuredRefreshDeps(config));
    if (summary.updated + summary.failed > 0) {
      logger.info("Program flight refresh sweep completed", summary);
    }
  },
);
