import {HttpsError} from "firebase-functions/v2/https";
import {moderateText} from "../moderation/textFilter";

/**
 * Applies the same fail-closed text policy to every Catch-managed outbound
 * route before content is persisted or handed to a delivery provider.
 *
 * Personal-device handoffs are intentionally outside this boundary: Catch
 * pre-fills editable copy, but the Host owns the final message in WhatsApp.
 */
export function assertOutboundContentAllowed(
  values: Iterable<string>,
  failureMessage: string,
): void {
  for (const value of values) {
    if (moderateText(value).action !== "allow") {
      throw new HttpsError("invalid-argument", failureMessage);
    }
  }
}
