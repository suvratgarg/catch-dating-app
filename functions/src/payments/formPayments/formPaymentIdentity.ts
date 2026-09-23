import {createHash} from "node:crypto";

/** One immutable checkout per frozen form draft, including recovery reads. */
export function formPaymentId(draftId: string): string {
  const hash = createHash("sha256").update(draftId).digest("hex");
  return `fp_${hash.slice(0, 32)}`;
}
