import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerPaymentConnectionDocument} from
  "../../shared/generated/firestoreAdminTypes";

export function requireReadyFormPaymentConnection(
  connection: OrganizerPaymentConnectionDocument | null,
  organizerId: string,
  nowMillis: number,
): OrganizerPaymentConnectionDocument {
  if (!Number.isSafeInteger(nowMillis) || nowMillis < 0 ||
      !connection || connection.organizerId !== organizerId ||
      connection.provider !== "razorpay" || connection.status !== "ready" ||
      !connection.accountId || !connection.publicToken ||
      !connection.publicToken.startsWith(`rzp_${connection.mode}_oauth_`) ||
      !connection.secretVersionResource || !connection.webhookId ||
      !connection.webhookUrl || !connection.webhookVerifiedAt ||
      !connection.tokenExpiresAt ||
      connection.tokenExpiresAt.toMillis() <= nowMillis ||
      connection.disconnectedAt !== null || connection.lastErrorCode !== null) {
    throw new HttpsError("failed-precondition",
      "Connect Razorpay and verify its payment webhook before enabling fees.");
  }
  return connection;
}
