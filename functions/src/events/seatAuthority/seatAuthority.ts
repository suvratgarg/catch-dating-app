import {createHash} from "crypto";

/** Private server-owned records. No endpoint or path is registered here. */
export interface SeatLedger {
  eventId: string;
  capacity: number;
  occupied: number;
  revision: number;
  capacityRevision: number;
  migrationRevision: number;
  state: "ready" | "unreconciled" | "revoked";
}

export interface SeatReservation {
  eventId: string;
  canonicalKey: string;
  identityRevision: number;
  active: boolean;
  revision: number;
  reservedAtMillis: number;
  releasedAtMillis: number | null;
}

export interface SeatReceipt {
  eventId: string;
  requestId: string;
  requestHash: string;
  operation: "reserve" | "release";
  canonicalKey: string;
  appliedLedgerRevision: number;
  appliedReservationRevision: number;
}

/** Resolver must prove all known phone/UID/import aliases in the SAME tx. */
export interface CanonicalSeatIdentity {
  key: string;
  revision: number;
}

/** Use one real Firestore transaction, never pre-read/batch writes. */
export interface SeatTransaction {
  ledger(eventId: string): Promise<SeatLedger | null>;
  reservation(eventId: string, canonicalKey: string):
    Promise<SeatReservation | null>;
  receipt(eventId: string, requestId: string): Promise<SeatReceipt | null>;
  putLedger(value: SeatLedger): void;
  putReservation(value: SeatReservation): void;
  createReceipt(value: SeatReceipt): void;
}

export type SeatOperation = "reserve" | "release";
export interface SeatCommand<Subject> {
  eventId: string;
  subject: Subject;
  operation: SeatOperation;
  requestId: string;
  expectedLedgerRevision: number;
  expectedCapacityRevision: number;
  expectedMigrationRevision: number;
  expectedReservationRevision: number;
  nowMillis: number;
}

export interface SeatResult {
  receipt: SeatReceipt;
  active: boolean;
  replayed: boolean;
}

export class SeatAuthorityError extends Error {
  constructor(readonly code: "invalid" | "conflict" | "unavailable",
    message: string) {
    super(message);
  }
}

const idPattern = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/u;
function validId(value: unknown): value is string {
  return typeof value === "string" && idPattern.test(value);
}
function nonnegative(value: unknown): value is number {
  return Number.isSafeInteger(value) && Number(value) >= 0;
}
function fail(code: SeatAuthorityError["code"], message: string): never {
  throw new SeatAuthorityError(code, message);
}
function hash(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

/**
 * Composable read-plan/write helper. Caller owns actor, event, admission and
 * payment authorization in the same transaction before invoking this helper.
 * Identity resolution may read more documents but must not write. The adapter
 * must map each ledger/reservation/receipt key to a deterministic document.
 */
export async function applySeatCommand<Subject>(params: {
  tx: SeatTransaction;
  command: SeatCommand<Subject>;
  resolveIdentity: (subject: Subject) => Promise<CanonicalSeatIdentity>;
}): Promise<SeatResult> {
  const {tx, command} = params;
  if (!validId(command.eventId) || !validId(command.requestId) ||
      !["reserve", "release"].includes(command.operation) ||
      !nonnegative(command.expectedLedgerRevision) ||
      !nonnegative(command.expectedCapacityRevision) ||
      !nonnegative(command.expectedMigrationRevision) ||
      !nonnegative(command.expectedReservationRevision) ||
      !nonnegative(command.nowMillis)) {
    fail("invalid", "Invalid seat command or revision.");
  }
  const identity = await params.resolveIdentity(command.subject);
  if (!validId(identity.key) || !nonnegative(identity.revision)) {
    fail("invalid", "A current canonical identity is required.");
  }
  const [ledger, reservation, prior] = await Promise.all([
    tx.ledger(command.eventId),
    tx.reservation(command.eventId, identity.key),
    tx.receipt(command.eventId, command.requestId),
  ]);
  if (!ledger || ledger.eventId !== command.eventId ||
      ledger.state !== "ready" || !Number.isSafeInteger(ledger.capacity) ||
      ledger.capacity < 1 || !nonnegative(ledger.occupied) ||
      ledger.occupied > ledger.capacity || !nonnegative(ledger.revision) ||
      !nonnegative(ledger.capacityRevision) ||
      ledger.capacityRevision === 0 ||
      !nonnegative(ledger.migrationRevision) ||
      ledger.migrationRevision === 0) {
    fail("unavailable", "Seat authority is not reconciled and ready.");
  }
  if (reservation && (reservation.eventId !== command.eventId ||
      reservation.canonicalKey !== identity.key ||
      !nonnegative(reservation.revision) ||
      !nonnegative(reservation.identityRevision) ||
      typeof reservation.active !== "boolean")) {
    fail("unavailable", "Seat reservation is malformed.");
  }
  const requestHash = hash([command.eventId, command.operation,
    command.requestId, identity.key, identity.revision,
    command.expectedLedgerRevision, command.expectedCapacityRevision,
    command.expectedMigrationRevision,
    command.expectedReservationRevision]);
  if (prior) {
    if (prior.eventId !== command.eventId ||
        prior.requestId !== command.requestId ||
        prior.requestHash !== requestHash ||
        prior.operation !== command.operation ||
        prior.canonicalKey !== identity.key) {
      fail("conflict", "Seat request ID was reused for different work.");
    }
    // A released reserve replays historically; it never reactivates.
    return {receipt: prior, active: reservation?.active === true,
      replayed: true};
  }
  if (ledger.revision !== command.expectedLedgerRevision ||
      ledger.capacityRevision !== command.expectedCapacityRevision ||
      ledger.migrationRevision !== command.expectedMigrationRevision ||
      (reservation?.revision ?? 0) !==
        command.expectedReservationRevision) {
    fail("conflict", "Seat capacity or reservation changed; review again.");
  }
  if (reservation && reservation.identityRevision !== identity.revision) {
    fail("conflict", "Canonical identity changed; reconcile it first.");
  }
  if (command.operation === "reserve" && reservation?.active) {
    fail("conflict", "This identity already has a confirmed seat.");
  }
  if (command.operation === "release" && !reservation?.active) {
    fail("conflict", "There is no active seat to release.");
  }
  if (command.operation === "reserve" && ledger.occupied >= ledger.capacity) {
    fail("conflict", "This event is full.");
  }
  const active = command.operation === "reserve";
  const nextReservation: SeatReservation = {
    eventId: command.eventId, canonicalKey: identity.key,
    identityRevision: identity.revision, active,
    revision: (reservation?.revision ?? 0) + 1,
    reservedAtMillis: active ? command.nowMillis :
      reservation!.reservedAtMillis,
    releasedAtMillis: active ? null : command.nowMillis,
  };
  const nextLedger: SeatLedger = {...ledger,
    occupied: ledger.occupied + (active ? 1 : -1),
    revision: ledger.revision + 1};
  const receipt: SeatReceipt = {eventId: command.eventId,
    requestId: command.requestId, requestHash,
    operation: command.operation, canonicalKey: identity.key,
    appliedLedgerRevision: nextLedger.revision,
    appliedReservationRevision: nextReservation.revision};
  tx.putLedger(nextLedger);
  tx.putReservation(nextReservation);
  tx.createReceipt(receipt);
  return {receipt, active, replayed: false};
}
