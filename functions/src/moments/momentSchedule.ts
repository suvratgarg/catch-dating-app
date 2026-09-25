import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import type {TravelLegEvent} from "./momentConditions";
import {ingestTravelLegEvent, runMomentSweep} from "./momentRunner";
import {buildMomentRunnerDeps} from "./momentWiring";

/**
 * Server entry points for the moments engine. The exported functions are
 * declared here and re-exported through index.ts in the shared
 * registration window; all behavior lives in the testable runner.
 */

/** Replans armed anchored/scheduled moments and fires due runs. */
export const organizerMomentSweep = onSchedule(
  {
    schedule: "every 5 minutes",
    timeoutSeconds: 540,
    maxInstances: 1,
    // Scheduler wall clock only — quiet hours use each scope's own tz.
    timeZone: "Asia/Kolkata",
  },
  async () => {
    try {
      const summary = await runMomentSweep(buildMomentRunnerDeps());
      if (summary.runsFired + summary.runsCreated +
          summary.runsSuperseded + summary.runsSkipped +
          summary.runsDeferred > 0) {
        logger.info("Moment sweep completed", {...summary});
      }
    } catch (error) {
      logger.error("Moment sweep failed", {error});
      throw error;
    }
  },
);

/** Turns a travel-leg write into readiness/flight-status facts. */
export function travelLegChangeEvents(
  legId: string,
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
  observedAtMillis: number,
): TravelLegEvent[] {
  if (!after || typeof after.programId !== "string") return [];
  const programId = after.programId;
  const events: TravelLegEvent[] = [];
  const readiness = typeof after.readiness === "string" ?
    after.readiness : "";
  const previousReadiness = typeof before?.readiness === "string" ?
    before.readiness : "";
  if (readiness !== previousReadiness) {
    events.push({
      kind: "travelLegReadinessChanged",
      legId, programId, previousReadiness, readiness, observedAtMillis,
    });
  }
  const flightStatus = typeof after.flightStatus === "string" ?
    after.flightStatus : "";
  const previousFlightStatus = typeof before?.flightStatus === "string" ?
    before.flightStatus : "";
  if (flightStatus !== previousFlightStatus) {
    events.push({
      kind: "travelLegFlightStatusChanged",
      legId, programId, previousFlightStatus, flightStatus,
      observedAtMillis,
    });
  }
  return events;
}

/** Feeds triggered moments from programTravelLegs writes. */
export const programTravelLegMoments = onDocumentWritten(
  "programTravelLegs/{legId}",
  async (event) => {
    const before = event.data?.before.data() as
      Record<string, unknown> | undefined;
    const after = event.data?.after.data() as
      Record<string, unknown> | undefined;
    const facts = travelLegChangeEvents(
      event.params.legId, before, after, Date.now());
    if (facts.length === 0) return;
    const deps = buildMomentRunnerDeps();
    for (const fact of facts) {
      try {
        await ingestTravelLegEvent(deps, fact);
      } catch (error) {
        // One leg's failure must not swallow the other fact; the send
        // records make a retry/replay safe.
        logger.error("Moment trigger ingestion failed", {
          error, legId: fact.legId, kind: fact.kind,
        });
      }
    }
  },
);
