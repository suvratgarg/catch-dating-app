import {createHash} from "node:crypto";
import {OperationDomainError} from "./errors";
import {OperationActionReceipt, OperationWorkItem} from "./models";

export interface OperationLeaseProof {
  leaseId: string;
  ownerId: string;
  fencingToken: number;
}

export interface CommitWorkItemAction {
  workItem: OperationWorkItem;
  receipt: OperationActionReceipt;
  lease: OperationLeaseProof;
}

export interface CommittedWorkItemAction {
  /** On replay this is the latest item, which may have advanced again. */
  workItem: OperationWorkItem;
  receipt: OperationActionReceipt;
  replayed: boolean;
}

/** Length-delimited JSON fields avoid collisions between colon-bearing ids. */
export function operationActionId(
  runId: string,
  workItemId: string,
  idempotencyKey: string
): string {
  return "action:" + operationContentHash([runId, workItemId, idempotencyKey]);
}

/** Reject non-JSON values instead of silently hashing a lossy serialization. */
export function operationContentHash(value: unknown): string {
  return createHash("sha256").update(canonicalJson(value)).digest("hex");
}

function canonicalJson(value: unknown): string {
  if (value === null || typeof value === "string" ||
      typeof value === "boolean" ||
      (typeof value === "number" && Number.isFinite(value))) {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return "[" + Array.from(value, canonicalJson).join(",") + "]";
  }
  if (typeof value === "object" && value !== null &&
      Object.getPrototypeOf(value) === Object.prototype) {
    const object = value as Record<string, unknown>;
    return "{" + Object.keys(object).sort().map((key) =>
      JSON.stringify(key) + ":" + canonicalJson(object[key])
    ).join(",") + "}";
  }
  throw new OperationDomainError(
    "invalid_json_value", "Operation evidence must contain only JSON values"
  );
}
