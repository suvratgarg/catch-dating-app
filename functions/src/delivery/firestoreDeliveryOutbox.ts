import type {
  DocumentReference, Firestore, Transaction,
} from "firebase-admin/firestore";
import {operationContentHash} from "../operations/durableActions";
import {
  canClaimCoreAttempt,
  DeliveryCoreAttempt,
  DeliveryCoreFacts,
  DeliveryCoreIntent,
  DeliveryCoreRecord,
  DeliveryDecision,
  DeliverySourceAdapter,
  evaluateDelivery,
  LiveCoreAttempt,
  LiveDeliveryBinding,
  mergeCoreDeliveryReceipt,
  prepareCoreDeliveryAttempt,
  VerifiedCoreReceipt,
} from "./deliveryCore";

/**
 * Transactional reads inside the shared claim. The reader sees only
 * domain/permission documents — no writes, provider I/O, or user-supplied
 * authority.
 */
export type ReadDeliveryFacts<I, B> = (
  transaction: Transaction,
  intent: I,
  now: number
) => Promise<DeliveryCoreFacts<B>>;

/** Trusted transaction preparation; commit stages writes without reads. */
export type PrepareDispatchResource<T, R, A> = (
  tx: Transaction, record: R, attempt: LiveCoreAttempt<A>, now: number
) => Promise<{kind: "ready"; value: T; validUntil: number;
  commit: () => void} | {kind: "withheld"}>;

export type DeliveryPermit<I, A> = {
  messageId: string;
  intent: I;
  attempt: LiveCoreAttempt<A>;
  validUntil: number;
};

export type DeliveryClaimResult<T, R, A> =
  | {kind: "claimed"; record: R; resource: T;
    permit: DeliveryPermit<DeliveryCoreIntent, A>}
  | {kind: "withheld"; record: R; reason: "notReserved" | "rehearsal" |
    "authorityChanged" | "authorizationExpired" | "deliveryConflict" |
    "resourceUnavailable"};

/**
 * Firestore's SDK retries ABORTED and expired transactions, but does not
 * recognize the emulator's exact closed-transaction INVALID_ARGUMENT reply.
 * Normalize that callback failure into the bounded SDK retry loop. Commit
 * failures stay outside this catch — their outcome is uncertain and resolved
 * by the caller's immutable request receipt.
 */
export function runDeliveryTransaction<T>(db: Firestore,
  update: (tx: Transaction) => Promise<T>): Promise<T> {
  return db.runTransaction(async (tx) => {
    try {
      return await update(tx);
    } catch (error) {
      if (error instanceof Error && "code" in error && error.code === 3 &&
          "details" in error &&
          error.details === "Transaction is invalid or closed.") {
        throw Object.assign(new Error("Delivery transaction closed",
          {cause: error}), {code: 10}); // Firestore ABORTED; SDK owns backoff.
      }
      throw error;
    }
  });
}

/**
 * Private delivery persistence shared by every messaging producer. CAS on
 * one bounded record owns reservation/dispatch contention; no provider runs
 * inside a transaction. A completed workflow cannot prevent a delayed
 * delivery receipt from being reconciled here.
 *
 * The lifecycle is the same one Event Assistance ships today; the adapter
 * keeps each producer's intent validation, identity, and record contract.
 */
export class FirestoreDeliveryOutbox<
  C,
  B extends LiveDeliveryBinding,
  I extends DeliveryCoreIntent<C>,
  A extends DeliveryCoreAttempt<C, B>,
  R extends DeliveryCoreRecord<I, A>,
> {
  constructor(
    private readonly db: Firestore,
    private readonly adapter: DeliverySourceAdapter<C, B, I, A, R>,
    private readonly readFacts: ReadDeliveryFacts<I, B>,
    private readonly clock: () => number = Date.now
  ) {}

  async enqueue(value: unknown): Promise<R> {
    const intent = this.adapter.parseIntent(structuredClone(value));
    const reference = this.reference(this.adapter.messageId(intent));
    return runDeliveryTransaction(this.db, async (transaction) => {
      const snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        const existing = this.adapter.parseRecord(snapshot.data());
        if (operationContentHash(existing.intent) !==
            operationContentHash(intent)) {
          throw new Error("Message intent identity already has other content");
        }
        return existing;
      }
      const now = this.now(intent.createdAt);
      if (now >= intent.expiresAt) throw new Error("Message intent expired");
      const record = this.adapter.newRecord(intent, now);
      transaction.create(reference, record);
      return record;
    });
  }

  async get(messageId: string): Promise<R | null> {
    const snapshot = await this.reference(messageId).get();
    if (!snapshot.exists) return null;
    const record = this.adapter.parseRecord(snapshot.data());
    if (record.messageId !== messageId) throw new Error("Message id mismatch");
    return record;
  }

  async reserve(messageId: string): Promise<{
    record: R; decision: DeliveryDecision<B>;
  }> {
    return runDeliveryTransaction(this.db, async (transaction) => {
      const record = await this.read(transaction, messageId);
      const facts = await this.readFacts(transaction, record.intent,
        this.now(record.updatedAt));
      // Re-sample after fact reads: a slow/retried transaction cannot extend
      // the validity of an earlier permission snapshot.
      const now = this.now(record.updatedAt);
      let released = false;
      const attempts = record.attempts.map((attempt) => {
        if (attempt.state.kind !== "reserved" ||
            attempt.authorization.validUntil > now) return attempt;
        // Claim and release contend on this same document. A claim that won
        // already changed reserved to unknown and can never enter this path.
        released = true;
        return {...attempt, state: {kind: "notDispatched" as const, at: now,
          reason: "reservationExpired" as const}};
      });
      const current = released ?
        this.adapter.withAttempts(record, attempts) : record;
      const stopReason = this.adapter.recordStopReason(current);
      const decision: DeliveryDecision<B> = stopReason !== null ?
        {kind: "stop", reason: stopReason} :
        current.deliveryConflict ?
          {kind: "hostDecision", reason: "conflictingDeliveryEvidence"} :
          evaluateDelivery({...facts, intent: current.intent,
            lifecycle: current.lifecycle, attempts: current.attempts, now},
            this.adapter);
      if (decision.kind !== "dispatch") {
        return {record: released ?
          this.write(transaction, record, current, now) : record, decision};
      }
      const attempt = prepareCoreDeliveryAttempt({...facts,
        intent: current.intent, lifecycle: current.lifecycle,
        attempts: current.attempts, now}, this.adapter);
      if (!attempt) throw new Error("Message reservation decision drift");
      this.adapter.parseAttempt(attempt);
      return {record: this.write(transaction, record,
        this.adapter.withAttempts(current, [...current.attempts, attempt]),
        now), decision};
    });
  }

  async claimLiveDispatch<T = undefined>(
    messageId: string, attemptId: string,
    prepareResource?: PrepareDispatchResource<T, R, A>
  ): Promise<DeliveryClaimResult<T, R, A>> {
    return runDeliveryTransaction(this.db, async (transaction) => {
      const record = await this.read(transaction, messageId);
      const facts = await this.readFacts(transaction, record.intent,
        this.now(record.updatedAt));
      const now = this.now(record.updatedAt);
      const result = canClaimCoreAttempt(record, attemptId, facts, now,
        this.adapter);
      if (result.kind === "withheld") return {...result, record};
      const resource = prepareResource ? await prepareResource(transaction,
        record, result.attempt, now) : null;
      if (resource?.kind === "withheld") {
        return {kind: "withheld", record, reason: "resourceUnavailable"};
      }
      const committedAt = this.now(now);
      const validUntil = Math.min(result.validUntil,
        resource?.validUntil ?? result.validUntil);
      if (!Number.isSafeInteger(validUntil) || committedAt >= validUntil) {
        return {kind: "withheld", record, reason: "authorizationExpired"};
      }
      // Debit and payload evidence commit with the single-send claim.
      resource?.commit();
      const attempt = {...result.attempt, state: {
        kind: "unknown" as const, at: committedAt, providerMessageId: null,
        reason: "workerInterrupted" as const,
        reconcileAfter: committedAt + 120_000,
      }} as A;
      const next = this.write(transaction, record,
        this.adapter.withAttempts(record, record.attempts.map((a) =>
          a.attemptId === attemptId ? attempt : a)), committedAt);
      return {kind: "claimed", record: next,
        resource: resource?.value as T, permit: {
          messageId, intent: record.intent,
          attempt: attempt as LiveCoreAttempt<A>,
          validUntil,
        }};
    });
  }

  /** Only for a worker that proves permit expiry prevented all provider I/O. */
  async recordExpiredBeforeSend(
    permit: DeliveryPermit<I, A>
  ): Promise<R> {
    return runDeliveryTransaction(this.db, async (tx) => {
      const record = await this.read(tx, permit.messageId);
      const attempt = record.attempts.find((a) =>
        a.attemptId === permit.attempt.attemptId);
      const now = this.now(record.updatedAt);
      if (!Number.isSafeInteger(permit.validUntil) ||
          permit.validUntil <= permit.attempt.state.at ||
          permit.validUntil > permit.attempt.authorization.validUntil ||
          now < permit.validUntil ||
          operationContentHash(record.intent) !==
            operationContentHash(permit.intent) ||
          !attempt || attempt.mode !== "live") {
        throw new Error("Unsent evidence is outside the expired permit");
      }
      if (operationContentHash(attempt) !==
          operationContentHash(permit.attempt) ||
          attempt.state.kind !== "unknown" ||
          attempt.state.reason !== "workerInterrupted") return record;
      return this.write(tx, record, this.adapter.withAttempts(record,
        record.attempts.map((a) => a.attemptId !== attempt.attemptId ?
          a : {...a, state: {kind: "notDispatched" as const, at: now,
            reason: "permitExpired" as const}})), now);
    });
  }

  /** Authenticated/correlated normalized evidence; never a raw HTTP body. */
  async recordReceipt(
    messageId: string, receipt: VerifiedCoreReceipt<B>
  ) {
    return runDeliveryTransaction(this.db, async (transaction) => {
      const record = await this.read(transaction, messageId);
      const now = this.now(record.updatedAt);
      if (receipt.receivedAt > now) throw new Error("Future provider receipt");
      const attempt = record.attempts.find((a) =>
        a.attemptId === receipt.attemptId);
      if (!attempt || attempt.mode !== "live") {
        throw new Error("Receipt has no live message attempt");
      }
      const merged = mergeCoreDeliveryReceipt(attempt, receipt,
        (v) => this.adapter.parseAttempt(v));
      const conflict = record.deliveryConflict ||
        merged.disposition === "conflictingEvidence";
      if (operationContentHash(merged.attempt) ===
          operationContentHash(attempt) &&
          conflict === record.deliveryConflict) {
        return {record, disposition: merged.disposition};
      }
      const changed = this.adapter.withDeliveryConflict(
        this.adapter.withAttempts(record, record.attempts.map((a) =>
          a.attemptId === attempt.attemptId ? merged.attempt as A : a)),
        conflict);
      return {record: this.write(transaction, record, changed, now),
      disposition: merged.disposition};
    });
  }

  async close(
    messageId: string, expectedRevision: number,
    lifecycle: "cancelled" | "superseded"
  ): Promise<R> {
    if (lifecycle !== "cancelled" && lifecycle !== "superseded") {
      throw new Error("Invalid message closure");
    }
    return runDeliveryTransaction(this.db, async (transaction) => {
      const record = await this.read(transaction, messageId);
      if (record.lifecycle === lifecycle) return record;
      if (record.lifecycle !== "active" ||
          record.revision !== expectedRevision) {
        throw new Error("Message revision or lifecycle changed");
      }
      return this.write(transaction, record,
        this.adapter.withLifecycle(record, lifecycle),
        this.now(record.updatedAt));
    });
  }

  private reference(messageId: string): DocumentReference {
    if (!/^outbox:[a-f0-9]{64}$/.test(messageId)) {
      throw new Error("Invalid outbox id");
    }
    return this.db.collection(this.adapter.collection).doc(messageId);
  }

  private async read(transaction: Transaction, messageId: string) {
    const snapshot = await transaction.get(this.reference(messageId));
    if (!snapshot.exists) throw new Error("Message not found");
    const record = this.adapter.parseRecord(snapshot.data());
    if (record.messageId !== messageId) throw new Error("Message id mismatch");
    return record;
  }

  private write(
    transaction: Transaction, previous: R,
    changed: R, now: number
  ): R {
    const next = this.adapter.parseRecord({...changed,
      revision: previous.revision + 1, updatedAt: now});
    transaction.set(this.reference(previous.messageId), next);
    return next;
  }

  private now(previous: number): number {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < previous) {
      throw new Error("Message worker clock is invalid or moved backwards");
    }
    return now;
  }
}
