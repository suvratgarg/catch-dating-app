import {createHash} from "node:crypto";

export function commercialQuoteId(opportunityId: string): string {
  const digest = createHash("sha256").update(opportunityId).digest("hex");
  return `quote-${digest.slice(0, 24)}`;
}
