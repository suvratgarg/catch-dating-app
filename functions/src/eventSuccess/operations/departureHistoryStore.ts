import type {Firestore} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash} from "../../operations/durableActions";
import type {EventAssistanceDepartureRostersCallableResponse as Response} from
  "../../shared/generated/eventAssistanceDepartureRostersCallableResponse";
import {validateListEventAssistanceDepartureRostersCallablePayload} from
  "../../shared/generated/validators/listEventAssistanceDepartureRostersInput";
import {validateEventAssistanceDepartureRostersCallableResponse} from
  "../../shared/generated/validators/eventAssistanceDepartureRostersOutput";
import {validateEventAssistanceDepartureRosterDocument} from
  "../../shared/generated/validators/eventAssistanceDepartureRosterDocument";
import {requireGroupPermission, denied} from "./groupStaffAuthority";
import {readGroupProgressState} from "./groupProgressReader";
import {invalidSource, progressIdentity} from "./groupProgressSource";
import {DEPARTURE_ROSTERS} from "./departureRosterSource";
import {CHECKPOINTS, checkpointIdentity, parseDepartureRoster,
  parseCheckpointReport, Roster, Scope} from "./checkpointRecords";

const pageSize = 10;

/**
 * Discovery of recorded rosters, not an inferred log of all group movement.
 * Current obligations and guest eligibility require the scoped checkpoint read.
 */
export class EventDepartureHistoryStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async list(actorUid: string, value: unknown): Promise<Response> {
    if (!validateListEventAssistanceDepartureRostersCallablePayload(value)) {
      throw new HttpsError("invalid-argument",
        "Invalid departure history scope.");
    }
    const input = structuredClone(value);
    return this.db.runTransaction(async (tx) => {
      const startedAt = this.now();
      const access = await requireGroupPermission(this.db, tx, input.context,
        input.groupId, actorUid, "readProgress", this.clock);
      const state = await readGroupProgressState(this.db, tx, input.context,
        input.groupId, this.clock);
      if (state.now < startedAt) throw invalidSource();
      const progressId = progressIdentity(input.context, input.groupId);
      let query = this.db.collection(DEPARTURE_ROSTERS)
        .where("progressId", "==", progressId)
        .orderBy("progressRevision", "desc").limit(pageSize + 1);
      if (input.beforeRevision !== undefined) {
        query = query.startAfter(input.beforeRevision);
      }
      const rows = await tx.get(query);
      const readAt = this.now(state.now);
      // Validate the overflow witness too. Corruption must not hide behind a
      // cursor or silently remove a historical roster from the denominator.
      let previousRevision = input.beforeRevision ?? Number.POSITIVE_INFINITY;
      let previousTime = state.progress?.confirmedAt ?? 0;
      const rosters = rows.docs.map((doc) => {
        const raw = doc.data();
        if (!validateEventAssistanceDepartureRosterDocument(raw)) {
          throw invalidSource();
        }
        const scope = rosterScope(input, raw);
        const roster = parseDepartureRoster(raw, scope, readAt)!;
        if (roster.destination?.kind === "groupCheckpoint" &&
            roster.destination.groupId !== input.groupId) throw invalidSource();
        if (doc.id !== roster.rosterId ||
            roster.progressRevision >= previousRevision ||
            roster.progressRevision > (state.progress?.revision ?? 0) ||
            roster.confirmedAt > previousTime) throw invalidSource();
        if (roster.progressRevision === state.progress?.revision &&
            (state.progress.departureRosterId !== roster.rosterId ||
              state.progress.sourceHash !== roster.sourceHash ||
              state.progress.confirmedBy !== roster.confirmedBy ||
              state.progress.confirmedAt !== roster.confirmedAt ||
              (roster.destination &&
                operationContentHash(roster.destination) !==
                operationContentHash(state.progress.destination)))) {
          throw invalidSource();
        }
        previousRevision = roster.progressRevision;
        previousTime = roster.confirmedAt;
        return roster;
      });
      const page = rosters.slice(0, pageSize);
      const summaries = await Promise.all(page.map(async (roster) => {
        const checkpointId = rosterCheckpoint(roster);
        const scope = rosterScope(input, roster);
        const snap = checkpointId ? await tx.get(this.db.collection(CHECKPOINTS)
          .doc(checkpointIdentity(scope))) : null;
        const report = parseCheckpointReport(snap?.data(), scope, roster,
          readAt);
        const target = roster.destination ?? null;
        const destination = state.source.destinations.find((d) =>
          operationContentHash(d.target) === operationContentHash(target));
        const sourceState = roster.sourceHash !== state.source.sourceHash ?
          "setupChanged" : !target ? "destinationNotRecorded" :
            destination ? "current" : "setupChanged";
        const checkpoint = checkpointId ? {
          checkpointId, reportStatus: !report ? "unreported" as const :
            report.accountedFor.length === roster.members.length ?
              "complete" as const : "partial" as const,
          reportRevision: report?.revision ?? 0,
          accountedForCount: report?.accountedFor.length ?? 0,
          originalRequestedDueAt: roster.checkpointRequest?.dueAt ?? null,
        } : null;
        return {progressRevision: roster.progressRevision,
          confirmedAt: roster.confirmedAt, destination: target,
          label: sourceState === "current" ? destination!.label : null,
          sourceState, rosterSize: roster.members.length, checkpoint};
      }));
      const now = this.now(readAt);
      if (now >= access.validUntil) throw denied();
      const result = {context: input.context, groupId: input.groupId, actorUid,
        validUntil: access.validUntil, serverTime: now,
        progressRevision: state.progress?.revision ?? 0, coverage: "page",
        rosters: summaries, nextBeforeRevision: rosters.length > pageSize ?
          page.at(-1)!.progressRevision : null};
      if (!validateEventAssistanceDepartureRostersCallableResponse(result)) {
        throw invalidSource();
      }
      return result;
    }, {readOnly: true});
  }

  private now(minimum = 0) {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < minimum) throw invalidSource();
    return now;
  }
}

function rosterCheckpoint(roster: Roster): string | null {
  const target = roster.destination;
  return target?.kind === "itineraryStop" ? target.stopId :
    target?.kind === "groupCheckpoint" ? target.checkpointId : null;
}

function rosterScope(input: Pick<Scope, "context" | "groupId">,
  roster: Roster): Scope {
  return {context: input.context, groupId: input.groupId,
    progressRevision: roster.progressRevision,
    // Parsing a legacy/fixed-place roster still validates its canonical scope.
    // This sentinel never becomes a checkpoint link or triggers a report read.
    checkpointId: rosterCheckpoint(roster) ?? "not-a-checkpoint"};
}
