import {Firestore} from "firebase-admin/firestore";
import {operationCollections} from "./collections";
import {operationContentHash, OperationLeaseProof} from "./durableActions";
import {
  OperationConflictError,
  OperationDomainError,
  OperationNotFoundError,
} from "./errors";
import {OperationLease} from "./models";
import {
  AcquireLeaseInput,
  HeartbeatLeaseInput,
  OperationLeaseRepository,
  ReleaseLeaseInput,
} from "./repositories";
import {validateOperationLease} from "./validation";

export const MAX_OPERATION_LEASE_MS = 120_000;
const MAX_REQUEST_AGE_MS = 30_000;

/** One retained document per resource keeps the fence monotonic. No TTL. */
export function operationResourceLeaseId(
  resourceType: OperationLease["resourceType"],
  resourceId: string
): string {
  return "lease:" + operationContentHash([resourceType, resourceId]);
}

export function validatedLease(value: unknown): OperationLease {
  const result = validateOperationLease(value);
  if (!result.ok || !Number.isSafeInteger(result.value.fencingToken)) {
    throw new OperationDomainError("invalid_entity", "Invalid stored lease");
  }
  const lease = result.value;
  if (lease.leaseId !== operationResourceLeaseId(
    lease.resourceType, lease.resourceId
  )) {
    throw new OperationDomainError(
      "lease_resource_mismatch", "Lease id must bind its resource"
    );
  }
  return lease;
}

export function assertCurrentOperationLease(
  lease: OperationLease,
  proof: OperationLeaseProof,
  now: number
): void {
  if (lease.leaseId !== proof.leaseId || lease.ownerId !== proof.ownerId ||
      lease.fencingToken !== proof.fencingToken) {
    throw new OperationConflictError("lease_owner_mismatch",
      "Lease belongs to another worker or fencing generation");
  }
  if (lease.status !== "active" || Date.parse(lease.expiresAt) <= now) {
    throw new OperationConflictError("lease_expired", "Lease is not active");
  }
}

/** Trusted server adapter. The clock is live time, never a rehearsal clock. */
export class FirestoreOperationLeaseRepository implements
  OperationLeaseRepository {
  constructor(
    protected readonly db: Firestore,
    protected readonly leaseClock: () => number = Date.now
  ) {}

  async acquireLease(input: AcquireLeaseInput): Promise<OperationLease> {
    const candidate: OperationLease = validatedLease({
      schemaVersion: 1,
      ...input,
      fencingToken: 1,
      status: "active",
      heartbeatAt: input.acquiredAt,
      releasedAt: null,
    });
    const reference = this.db.collection(operationCollections.leases)
      .doc(candidate.leaseId);
    return this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      const now = this.leaseClock();
      this.assertLeaseWindow(input.acquiredAt, input.expiresAt, now);
      const previous = snapshot.exists ? validatedLease(snapshot.data()) : null;
      if (previous && previous.leaseId !== candidate.leaseId) {
        throw new OperationDomainError("lease_resource_mismatch",
          "Stored lease does not match its resource document");
      }
      if (previous?.idempotencyKey === candidate.idempotencyKey) {
        if (previous.ownerId !== candidate.ownerId) {
          throw new OperationConflictError("idempotency_conflict",
            "Lease acquisition key belongs to another worker");
        }
        assertCurrentOperationLease(previous, previous, now);
        return previous;
      }
      if (previous?.status === "active" &&
          Date.parse(previous.expiresAt) > now) {
        throw new OperationConflictError("lease_conflict",
          "Resource already has an active lease");
      }
      const lease = validatedLease({
        ...candidate,
        fencingToken: (previous?.fencingToken ?? 0) + 1,
      });
      transaction.set(reference, lease);
      return lease;
    });
  }

  async heartbeatLease(input: HeartbeatLeaseInput): Promise<OperationLease> {
    const reference = this.db.collection(operationCollections.leases)
      .doc(input.leaseId);
    return this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw new OperationNotFoundError("lease", input.leaseId);
      }
      const lease = validatedLease(snapshot.data());
      const now = this.leaseClock();
      assertCurrentOperationLease(lease, input, now);
      this.assertLeaseWindow(input.heartbeatAt, input.expiresAt, now);
      if (Date.parse(input.heartbeatAt) < Date.parse(lease.heartbeatAt) ||
          Date.parse(input.expiresAt) < Date.parse(lease.expiresAt)) {
        throw new OperationConflictError("lease_time_regression",
          "A heartbeat cannot move lease time backwards");
      }
      const next = validatedLease({...lease,
        heartbeatAt: input.heartbeatAt, expiresAt: input.expiresAt});
      transaction.set(reference, next);
      return next;
    });
  }

  async releaseLease(input: ReleaseLeaseInput): Promise<OperationLease> {
    const reference = this.db.collection(operationCollections.leases)
      .doc(input.leaseId);
    return this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw new OperationNotFoundError("lease", input.leaseId);
      }
      const lease = validatedLease(snapshot.data());
      const now = this.leaseClock();
      if (lease.status === "released" && lease.ownerId === input.ownerId &&
          lease.fencingToken === input.fencingToken &&
          lease.releasedAt === input.releasedAt) return lease;
      assertCurrentOperationLease(lease, input, now);
      this.assertRequestTime(input.releasedAt, now);
      if (Date.parse(input.releasedAt) < Date.parse(lease.heartbeatAt)) {
        throw new OperationConflictError("lease_time_regression",
          "Release cannot precede the latest heartbeat");
      }
      const next = validatedLease({...lease,
        status: "released", releasedAt: input.releasedAt});
      transaction.set(reference, next);
      return next;
    });
  }

  async getLease(leaseId: string): Promise<OperationLease | null> {
    const snapshot = await this.db.collection(operationCollections.leases)
      .doc(leaseId).get();
    if (!snapshot.exists) return null;
    const lease = validatedLease(snapshot.data());
    if (lease.leaseId !== leaseId) {
      throw new OperationDomainError("lease_identity_mismatch",
        "Stored lease does not match its document id");
    }
    return lease;
  }

  private assertRequestTime(at: string, now: number): void {
    const elapsed = now - Date.parse(at);
    if (!Number.isFinite(elapsed) || elapsed < 0 ||
        elapsed > MAX_REQUEST_AGE_MS) {
      throw new OperationDomainError("invalid_lease_time",
        "Lease requests must use the current server clock");
    }
  }

  private assertLeaseWindow(at: string, expiresAt: string, now: number): void {
    this.assertRequestTime(at, now);
    const duration = Date.parse(expiresAt) - Date.parse(at);
    if (!Number.isFinite(duration) || duration <= 0 ||
        duration > MAX_OPERATION_LEASE_MS || Date.parse(expiresAt) <= now) {
      throw new OperationDomainError("invalid_lease_duration",
        "Lease duration must be positive and at most two minutes");
    }
  }
}
