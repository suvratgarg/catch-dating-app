import {HttpsError} from "firebase-functions/v2/https";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import {prepareEventSuccessRotationDraft} from
  "./generateEventSuccessRotations";

const GUIDED_ROTATIONS_MODULE_ID = "guided_rotations";
const DEFAULT_PREPARATION_ATTEMPTS = 3;

/**
 * Prepares round N+1 after the guide enters live mode or round N publishes.
 * The retry ceiling is deployment-configurable because this work is
 * asynchronous ceremony preparation, never part of the beat transition.
 */
export const onEventSuccessPlanLiveControlUpdated = onDocumentUpdated(
  "eventSuccessPlans/{eventId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    const eventId = event.params.eventId;
    if (before === undefined || after === undefined) return;
    if (!shouldPrepareNextRound(before, after)) return;

    const maxAttempts = configuredPreparationAttempts(
      process.env.EVENT_SUCCESS_DRAFT_PREPARATION_ATTEMPTS
    );
    let lastError: unknown;
    for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
      const currentSnap = await admin.firestore()
        .collection("eventSuccessPlans")
        .doc(eventId)
        .get();
      const current = currentSnap.data();
      if (
        current === undefined ||
        current.status === "complete" ||
        !moduleSelected(current.selectedModuleIds)
      ) {
        return;
      }
      try {
        await prepareEventSuccessRotationDraft({
          eventId,
          expectedRevision: nonNegativeInteger(current.liveControlRevision),
        });
        return;
      } catch (error) {
        lastError = error;
        if (!(error instanceof HttpsError) || error.code !== "aborted") {
          throw error;
        }
      }
    }
    throw lastError;
  }
);

export function configuredPreparationAttempts(
  value: string | undefined
): number {
  if (value === undefined) return DEFAULT_PREPARATION_ATTEMPTS;
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed >= 1 && parsed <= 10 ?
    parsed : DEFAULT_PREPARATION_ATTEMPTS;
}

function shouldPrepareNextRound(
  before: FirebaseFirestore.DocumentData,
  after: FirebaseFirestore.DocumentData
): boolean {
  if (after.status === "complete" || !moduleSelected(after.selectedModuleIds)) {
    return false;
  }
  return (
    before.status !== "live" && after.status === "live"
  ) || integerOr(before.publishedRotationRoundIndex, -1) !==
    integerOr(after.publishedRotationRoundIndex, -1);
}

function moduleSelected(value: unknown): boolean {
  return Array.isArray(value) && value.includes(GUIDED_ROTATIONS_MODULE_ID);
}

function nonNegativeInteger(value: unknown): number {
  return Number.isInteger(value) && (value as number) >= 0 ?
    value as number : 0;
}

function integerOr(value: unknown, fallback: number): number {
  return Number.isInteger(value) ? value as number : fallback;
}
