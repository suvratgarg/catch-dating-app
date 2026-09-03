import {createHash} from "crypto";
import {HttpsError} from "firebase-functions/v2/https";

/**
 * A page is valid only while the definition and full membership still match.
 */
export function savedAudienceMemberPage<T extends {contactId: string}>(params: {
  organizerId: string;
  audienceId: string;
  revision: number;
  rows: T[];
  cursor?: string | null;
  limit: number;
}): {rows: T[]; nextCursor: string | null} {
  const fingerprint = createHash("sha256").update(JSON.stringify([
    params.organizerId, params.audienceId, params.revision,
    params.rows.map((row) => row.contactId),
  ])).digest("hex");
  let offset = 0;
  if (params.cursor) {
    let decoded: {fingerprint: string; offset: number};
    try {
      decoded = JSON.parse(Buffer.from(params.cursor, "base64url")
        .toString("utf8"));
      if (!Number.isSafeInteger(decoded.offset) || decoded.offset < 1 ||
          typeof decoded.fingerprint !== "string") throw new Error("invalid");
    } catch {
      throw new HttpsError("invalid-argument",
        "Invalid audience member cursor.");
    }
    if (decoded.fingerprint !== fingerprint ||
        decoded.offset >= params.rows.length) {
      throw new HttpsError("aborted",
        "Audience membership changed. Refresh the member list.");
    }
    offset = decoded.offset;
  }
  const rows = params.rows.slice(offset, offset + params.limit);
  const nextOffset = offset + rows.length;
  return {rows, nextCursor: nextOffset < params.rows.length ?
    Buffer.from(JSON.stringify({fingerprint, offset: nextOffset}))
      .toString("base64url") : null};
}
