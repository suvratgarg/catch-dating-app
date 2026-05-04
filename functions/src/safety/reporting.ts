import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";

const ReportUserSchema = z.object({
  targetUserId: z.string(),
  source: z.string().optional(),
  reasonCode: z.string().max(64).optional(),
  contextId: z.string().max(128).optional(),
  notes: z.string().max(2000).optional(),
});

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
  request: CallableRequest<unknown>,
  deps: ReportingDeps = defaultDeps
): Promise<{reported: boolean}> {
  const reporterUserId = requireAuth(request);
  const data = validateCallable(request, ReportUserSchema);

  if (data.targetUserId === reporterUserId) {
    throw new HttpsError("invalid-argument", "targetUserId is invalid.");
  }

  await deps.firestore().collection("reports").add({
    reporterUserId,
    targetUserId: data.targetUserId,
    createdAt: deps.serverTimestamp(),
    source: data.source ?? "profile",
    status: "open",
    ...(data.reasonCode && {reasonCode: data.reasonCode}),
    ...(data.contextId && {contextId: data.contextId}),
    ...(data.notes && {notes: data.notes}),
  });

  return {reported: true};
}

export const reportUser = onCall(appCheckCallableOptions, async (request) => {
  if (request.auth) {
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "reportUser"
    );
  }
  return reportUserHandler(request);
});
