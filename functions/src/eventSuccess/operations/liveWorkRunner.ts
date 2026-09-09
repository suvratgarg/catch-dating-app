import {randomUUID} from "node:crypto";
import {Firestore} from "firebase-admin/firestore";
import {operationResourceLeaseId} from
  "../../operations/firestoreLeaseRepository";
import type {OperationLease} from "../../operations/models";
import type {FirestoreOperationsRepository} from
  "../../operations/firestoreRepository";
import {LiveAssistanceWorkStore, LiveWorkAction} from "./liveWorkStore";
import {invalidWork} from "./liveWorkRecords";

export type {LiveWorkAction};
export type LiveWorkRunResult = {kind: "busy"} |
  {kind: "finished"; result: Awaited<ReturnType<
    LiveAssistanceWorkStore["evaluate"]>>};

/** One bounded work-item execution; independent of provider credentials. */
export class LiveAssistanceWorkRunner {
  readonly store: LiveAssistanceWorkStore;
  constructor(db: Firestore, private readonly clock: () => number = Date.now) {
    this.store = new LiveAssistanceWorkStore(db, clock);
  }

  async process(workItemId: string, action: LiveWorkAction):
    Promise<LiveWorkRunResult> {
    // Validate a real live record before creating any lease for its id.
    const initial = await this.store.get(workItemId);
    // Scheduled execution must carry the manager's saved runtime permission.
    // Trusted tests and imported old records do not grant that permission.
    if (action.kind === "evaluate" && !initial.payload.runtimeBinding &&
        initial.run.status !== "completed" &&
        this.clock() < initial.payload.expiresAt) {
      throw invalidWork();
    }
    if (initial.run.status === "completed" ||
        (action.kind === "evaluate" &&
          initial.payload.checkpoint.dueAt! > this.clock())) {
      return {kind: "finished", result: {...initial, kind: "idle"}};
    }
    const lease = await this.acquire(workItemId);
    if (!lease) return {kind: "busy"};
    try {
      const current = await this.store.get(workItemId);
      const result = action.kind === "evaluate" ?
        await this.store.evaluate(workItemId, current.item.revision, lease) :
        action.kind === "wake" ?
          await this.store.wake(workItemId, current.item.revision,
            action.signalId, lease) :
          await this.store.rebind(workItemId, current.item.revision,
            action.binding, lease);
      return {kind: "finished", result};
    } finally {
      await releaseAssistanceWorkLease(this.store.operations, lease,
        this.clock());
    }
  }

  private async acquire(workItemId: string): Promise<OperationLease | null> {
    const now = this.clock();
    try {
      return await this.store.operations.acquireLease({
        leaseId: operationResourceLeaseId("work_item", workItemId),
        resourceId: workItemId, resourceType: "work_item",
        ownerId: "assistance-worker:" + randomUUID(),
        idempotencyKey: randomUUID(),
        acquiredAt: new Date(now).toISOString(),
        expiresAt: new Date(now + 60_000).toISOString()});
    } catch (error) {
      if (errorCode(error) === "lease_conflict") return null;
      throw error;
    }
  }
}

export function errorCode(error: unknown): string | null {
  return error instanceof Error && "code" in error &&
    typeof error.code === "string" ? error.code : null;
}
export function leaseEnded(error: unknown): boolean {
  return ["lease_expired", "lease_owner_mismatch"].includes(
    errorCode(error) ?? "");
}

export async function releaseAssistanceWorkLease(
  operations: Pick<FirestoreOperationsRepository, "releaseLease">,
  lease: OperationLease, now: number) {
  try {
    await operations.releaseLease({...lease,
      releasedAt: new Date(now).toISOString()});
  } catch (error) {
    // A newer lease owner or an expired lease needs no release by us.
    if (!leaseEnded(error)) throw error;
  }
}
