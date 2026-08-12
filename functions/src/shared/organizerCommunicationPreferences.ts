import {createHash} from "crypto";

/** Returns the deterministic organizer-and-user preference document id. */
export function organizerCommunicationPreferenceId(
  organizerId: string,
  uid: string
): string {
  return `orgpref_${sha256(`${organizerId}|${uid}`).slice(0, 48)}`;
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
