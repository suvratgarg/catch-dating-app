import {HttpsError, onCall} from "firebase-functions/v2/https";
import type {CallableRequest} from "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {defaultProgramDataDeps} from "../shared/programDataDeps";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {dutyAssignments, programProjectionExpiresAt, requireProgramAccess,
  requireProgramDuty} from "../shared/programAuthority";
import {validateCallableWithAjv} from "../shared/validation";
import type {ManageProgramLodgingCallablePayload} from
  "../shared/generated/manageProgramLodgingCallablePayload";
import type {ManageProgramLodgingCallableResponse} from
  "../shared/generated/manageProgramLodgingCallableResponse";
import {validateManageProgramLodgingCallablePayload} from
  "../shared/generated/validators/manageProgramLodgingInput";
import {validateManageProgramLodgingCallableResponse} from
  "../shared/generated/validators/manageProgramLodgingOutput";
import type {ProgramLodgingConfigDocument} from
  "../shared/generated/programLodgingConfigDocument";
import {validateProgramLodgingConfigDocument} from
  "../shared/generated/validators/programLodgingConfigDocument";
import {canonicalLodgingSource, saveCanonicalLodgingConfig} from
  "./programLodgingConfig";
import {ProgramLodgingStore} from "./programLodgingStore";
import {assertLodgingProposalCurrent, immutableLodgingProposal,
  planLodging} from
  "./programLodgingPlanner";
import {prepareLodgingValidator, validateLodgingPlacements} from
  "./programLodgingValidation";

async function readSetup(deps: ProgramDataDeps, programId: string,
  actorUid: string) {
  const db = deps.firestore();
  return db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({db, transaction: tx, programId,
      actorUid, now: deps.now()});
    requireProgramDuty(access, "programCoordinator");
    const configuration = (await tx.get(db.collection("programLodgingConfigs")
      .doc(programId))).data() as ProgramLodgingConfigDocument | undefined;
    if (configuration &&
        (!validateProgramLodgingConfigDocument(configuration) ||
        configuration.programId !== programId ||
        configuration.organizerId !== access.program.organizerId)) {
      throw new HttpsError("failed-precondition", "Invalid lodging setup.");
    }
    const active = dutyAssignments(access, "programCoordinator")
      .filter((d) => d.expiresAtMillis > deps.now().toMillis());
    const expiry = programProjectionExpiresAt(access, active);
    if (expiry !== null && expiry <= deps.now().toMillis()) {
      throw new HttpsError("permission-denied", "Lodging duty expired.");
    }
    return {kind: "readSetup", configuration: configuration ?? null,
      accessExpiresAtMillis: expiry};
  });
}

/** One authenticated boundary; role-specific responses are schema-validated.
 * The desk never receives configuration, affinity or functional requirements.
 * Pure planner errors become reviewable constraint failures, never success. */
export async function manageProgramLodgingHandler(
  request: CallableRequest<unknown>,
  deps: ProgramDataDeps = defaultProgramDataDeps,
): Promise<ManageProgramLodgingCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ManageProgramLodgingCallablePayload>(
    request, validateManageProgramLodgingCallablePayload);
  await deps.checkRateLimit(deps.firestore(), actorUid, "manageProgramLodging");
  const store = new ProgramLodgingStore(deps, canonicalLodgingSource(deps));
  let result: unknown;
  try {
    switch (data.action) {
    case "readSetup":
      result = await readSetup(deps, data.programId, actorUid);
      break;
    case "setup":
      result = {kind: "setup", revision: await saveCanonicalLodgingConfig(deps,
        data.programId, actorUid, data.setup,
        data.expectedConfigurationRevision, data.adoptions)};
      break;
    case "preview": {
      const context = await store.review(data.programId, actorUid);
      result = {kind: "proposal", context,
        proposal: planLodging(context.snapshot)};
      break;
    }
    case "propose": {
      const context = await store.review(data.programId, actorUid);
      assertLodgingProposalCurrent({revisions: data.expectedRevisions},
        context.snapshot.revisions);
      const issues = validateLodgingPlacements(context.snapshot,
        data.placements);
      if (issues.length) {
        throw new HttpsError("failed-precondition", "Placement conflicts.",
          {issues});
      }
      result = {kind: "proposal", context,
        proposal: immutableLodgingProposal(context.snapshot, data.placements)};
      break;
    }
    case "destinations": {
      const context = await store.review(data.programId, actorUid);
      assertLodgingProposalCurrent({revisions: data.expectedRevisions},
        context.snapshot.revisions);
      if (!context.snapshot.parties.some((p) => p.id === data.partyId)) {
        throw new HttpsError("invalid-argument", "Unknown sharing party.");
      }
      const validate = prepareLodgingValidator(context.snapshot);
      result = {kind: "destinations", revisions: context.snapshot.revisions,
        destinations: context.snapshot.inventory.map((unit) => {
          const placements = data.placements.filter((p) =>
            p.partyId !== data.partyId).concat([{partyId: data.partyId,
            inventoryId: unit.id}]);
          const issues = validate(placements);
          return {inventoryId: unit.id, allowed: issues.length === 0,
            explanation: issues[0]?.detail ?? "Available for this party."};
        })};
      break;
    }
    case "save":
      result = {kind: "saved", proposal: await store.save(data.programId,
        actorUid, data.proposal)};
      break;
    case "transition":
      result = {kind: "transition", ...await store.transition(data.programId,
        actorUid, data.command)};
      break;
    case "hotelBoard":
      result = {kind: "hotelBoard", rows: await store.hotelBoard(data.programId,
        actorUid, data.hotelId)};
      break;
    }
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("failed-precondition",
      error instanceof Error ? error.message : "Lodging review failed.");
  }
  if (!validateManageProgramLodgingCallableResponse(result)) {
    throw new HttpsError("internal", "Invalid lodging response shape.");
  }
  return result;
}

export const manageProgramLodging = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 60, maxInstances: 10}),
  (request) => manageProgramLodgingHandler(request)
);
