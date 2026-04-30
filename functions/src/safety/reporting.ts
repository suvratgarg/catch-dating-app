import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {ReportDoc} from "../shared/firestore";

type ReportSource = ReportDoc["source"];

interface ReportUserData {
  targetUserId: string;
  source?: ReportSource;
  reasonCode?: string;
  contextId?: string;
  notes?: string;
}

interface ReportingDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
}

const defaultDeps: ReportingDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
};

/**
 * Normalizes optional report text so reports stay bounded and reviewable.
 * @param {string | undefined} value Raw text value.
 * @param {number} maxLength Maximum retained characters.
 * @return {string | undefined} Trimmed text or undefined.
 */
export function normalizeReportText(
  value: string | undefined,
  maxLength: number
): string | undefined {
  const trimmed = value?.trim();
  if (!trimmed) return undefined;
  return trimmed.length > maxLength ? trimmed.slice(0, maxLength) : trimmed;
}

/**
 * Callable implementation for filing a safety report.
 * @param {CallableRequest<Partial<ReportUserData> | null>} request Callable.
 * @param {ReportingDeps} deps Injectable service dependencies.
 * @return {Promise<{reported: boolean}>} Operation result.
 */
export async function reportUserHandler(
  request: CallableRequest<Partial<ReportUserData> | null>,
  deps: ReportingDeps = defaultDeps
): Promise<{reported: boolean}> {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to report.");
  }

  const reporterUserId = request.auth.uid;
  const targetUserId = request.data?.targetUserId;
  if (!targetUserId || targetUserId === reporterUserId) {
    throw new HttpsError("invalid-argument", "targetUserId is invalid.");
  }

  const reasonCode = normalizeReportText(request.data?.reasonCode, 64);
  const contextId = normalizeReportText(request.data?.contextId, 128);
  const notes = normalizeReportText(request.data?.notes, 2000);

  await deps.firestore().collection("reports").add({
    reporterUserId,
    targetUserId,
    createdAt: deps.serverTimestamp(),
    source: request.data?.source ?? "profile",
    status: "open",
    ...(reasonCode && {reasonCode}),
    ...(contextId && {contextId}),
    ...(notes && {notes}),
  });

  return {reported: true};
}

export const reportUser = onCall({enforceAppCheck: true}, (request) =>
  reportUserHandler(request)
);
