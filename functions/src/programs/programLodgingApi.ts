import {HttpsError, onCall} from "firebase-functions/v2/https";
import type {CallableRequest} from "firebase-functions/v2/https";
import {localStartMillis} from "../events/progressiveSetup/basics";
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
import {readCanonicalLodgingRecords} from "./programLodgingSource";
import {consumesRoom} from "./programRoomOccupancy";
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
    // All native guests are offered, including guests without travel rows.
    // This is a live-only allowlist, not a copied CRM or a sharing inference.
    const records = await readCanonicalLodgingRecords(tx, db, access,
      programId);
    const label = (value: string) => value.slice(0, 200);
    const dateFormatter = new Intl.DateTimeFormat("en-US", {
      timeZone: access.program.timezone, calendar: "gregory",
      year: "numeric", month: "2-digit", day: "2-digit"});
    const millis = [...(configuration?.demand ?? []).flatMap((d) =>
      [d.startsAtMillis, d.endsAtMillis]),
    ...records.blocks.flatMap(({data}) =>
      [data.startsAt.toMillis(), data.endsAt.toMillis()]),
    ...records.stays.filter(({data}) => consumesRoom(data))
      .flatMap(({data}) => [data.startsAt?.toMillis(), data.endsAt?.toMillis()])
      .filter((n): n is number => n !== undefined)];
    const calendarDates = Object.fromEntries([...new Set(millis)].map((n) => {
      const parts = dateFormatter.formatToParts(n);
      const part = (key: string) => parts.find((p) => p.type === key)!.value;
      return [String(n), `${part("year")}-${part("month")}-${part("day")}`];
    }));
    const catalog = {calendarDates, programId,
      organizerId: access.program.organizerId,
      timezone: access.program.timezone,
      guests: records.guests.map(({id, data}) => ({id,
        label: label(data.displayName), householdId: data.householdId,
        groupIds: data.groupIds ?? []})),
      groups: records.groups.map(({id, data}) => ({id,
        label: label(data.label)})),
      hotels: records.hotels.map(({id, data}) => ({id, label: label(data.name),
        active: data.active})),
      contracts: records.blocks.map(({id, data}) => ({id, hotelId: data.hotelId,
        label: label(data.label), roomType: data.roomType,
        totalRooms: data.totalRooms,
        maxOccupantsPerRoom: data.maxOccupantsPerRoom ?? 1,
        startsAtMillis: data.startsAt.toMillis(),
        endsAtMillis: data.endsAt.toMillis()})),
      activeStays: records.stays.filter(({data}) => consumesRoom(data))
        .map(({id, data}) => ({id, guestId: data.guestId, hotelId: data.hotelId,
          roomBlockId: data.roomBlockId, roomLabel: data.roomLabel,
          roomOccupancyId: data.roomOccupancyId ?? null,
          lodgingPartyId: data.lodgingPartyId ?? null,
          lodgingInventoryId: data.lodgingInventoryId ?? null,
          startsAtMillis: data.startsAt?.toMillis() ?? null,
          endsAtMillis: data.endsAt?.toMillis() ?? null,
          status: data.status, revision: data.revision}))};
    const active = dutyAssignments(access, "programCoordinator")
      .filter((d) => d.expiresAtMillis > deps.now().toMillis());
    const expiry = programProjectionExpiresAt(access, active);
    if (expiry !== null && expiry <= deps.now().toMillis()) {
      throw new HttpsError("permission-denied", "Lodging duty expired.");
    }
    return {kind: "readSetup", configuration: configuration ?? null, catalog,
      accessExpiresAtMillis: expiry};
  });
}

/** Date-only lodging choices use a civil noon anchor in the program zone,
 * not device-local or UTC midnight. Allocation consumes calendar nights;
 * these anchors do not promise hotel check-in hours. Existing stay timestamps
 * are retained verbatim by the editor/adoption boundary. */
async function resolveDates(deps: ProgramDataDeps, programId: string,
  actorUid: string, arrival: string, departure: string) {
  const db = deps.firestore();
  return db.runTransaction(async (tx) => {
    const access = await requireProgramAccess({db, transaction: tx, programId,
      actorUid, now: deps.now()});
    requireProgramDuty(access, "programCoordinator");
    const timezone = access.program.timezone;
    const startsAtMillis = localStartMillis(arrival, "12:00", timezone);
    const endsAtMillis = localStartMillis(departure, "12:00", timezone);
    if (arrival >= departure || startsAtMillis >= endsAtMillis) {
      throw new HttpsError("invalid-argument", "Checkout must follow arrival.");
    }
    const active = dutyAssignments(access, "programCoordinator")
      .filter((d) => d.expiresAtMillis > deps.now().toMillis());
    const expiry = programProjectionExpiresAt(access, active);
    if (expiry !== null && expiry <= deps.now().toMillis()) {
      throw new HttpsError("permission-denied", "Lodging duty expired.");
    }
    return {kind: "resolvedDates", timezone, arrival, departure,
      startsAtMillis, endsAtMillis, accessExpiresAtMillis: expiry};
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
    case "resolveDates":
      result = await resolveDates(deps, data.programId, actorUid,
        data.arrival, data.departure);
      break;
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
