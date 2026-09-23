import {createHash} from "node:crypto";

/** Keep hashing compatible with existing program operation receipts. */
export function hashRequest(payload: Record<string, unknown>): string {
  const stable = Object.keys(payload).sort().reduce<Record<string, unknown>>(
    (acc, key) => {
      acc[key] = payload[key];
      return acc;
    }, {});
  return createHash("sha256").update(JSON.stringify(stable)).digest("hex");
}
