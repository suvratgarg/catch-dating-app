import crypto from "node:crypto";

const organizerDraftPrefix = "create-draft-";

/**
 * Returns the stable curation receipt id for one normalized candidate identity.
 * Duplicate candidate records with the same identity converge on one receipt.
 */
export function organizerDraftOperationId(
  sourceNormalizedKey: string
): string {
  const digest = crypto.createHash("sha256")
    .update(sourceNormalizedKey.trim().toLowerCase())
    .digest("hex");
  return `${organizerDraftPrefix}${digest}`;
}
