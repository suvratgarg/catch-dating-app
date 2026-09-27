import {createHash} from "crypto";
import {assertReadySeatState, CanonicalSeatIdentity, CHECKOUT_HOLD_MILLIS,
  checkoutHeldCount, SeatAuthorityError, SeatCommand, SeatLedger,
  SeatReceipt, SeatReservation, SeatTransaction} from "./seatAuthority";

export type CheckoutHoldOperation = "checkoutHold" |
  "confirmCheckoutHold" | "releaseCheckoutHold";
export interface CheckoutHoldCommand<Subject> extends
  Omit<SeatCommand<Subject>, "operation"> {
  operation: CheckoutHoldOperation;
  /** Server-created immutable payment attempt ID, never a provider order ID. */
  paymentId: string;
}
const brand = Symbol("prepared-checkout-seat-hold");
const applied = new WeakSet<PreparedCheckoutHold>();
export interface PreparedCheckoutHold {
  readonly [brand]: true;
  readonly transaction: SeatTransaction;
  readonly ledger: Readonly<SeatLedger> | null;
  readonly reservation: Readonly<SeatReservation> | null;
  readonly receipt: Readonly<SeatReceipt>;
  readonly replayed: boolean;
}
const ID = /^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$/u;
const validId = (value: unknown): value is string =>
  typeof value === "string" && ID.test(value);
const safe = (value: unknown): value is number =>
  Number.isSafeInteger(value) && Number(value) >= 0;
function fail(code: SeatAuthorityError["code"], message: string): never {
  throw new SeatAuthorityError(code, message);
}

/**
 * Read-only plan. The caller must read and authorize the immutable payment,
 * offer, event policy and recipient in this SAME transaction. Confirmation
 * requires verified captured payment, and the caller must atomically write
 * admission/roster/ownership with this plan. Expiry never implies payment
 * cancellation: late captures must be reconciled/refunded by the caller.
 */
export async function prepareCheckoutHold<Subject>(params: {
  tx: SeatTransaction;
  command: CheckoutHoldCommand<Subject>;
  resolveIdentity: (subject: Subject) => Promise<CanonicalSeatIdentity>;
}): Promise<PreparedCheckoutHold> {
  const {tx, command} = params;
  if (!validId(command.eventId) || !validId(command.requestId) ||
      !validId(command.paymentId) ||
      !["checkoutHold", "confirmCheckoutHold", "releaseCheckoutHold"]
        .includes(command.operation) ||
      !safe(command.expectedLedgerRevision) ||
      !safe(command.expectedCapacityRevision) ||
      !safe(command.expectedMigrationRevision) ||
      !safe(command.expectedReservationRevision) ||
      !safe(command.nowMillis) ||
      !safe(command.nowMillis + CHECKOUT_HOLD_MILLIS)) {
    fail("invalid", "Invalid checkout hold command.");
  }
  const identity = await params.resolveIdentity(command.subject);
  if (!identity || !validId(identity.key) || !safe(identity.revision)) {
    fail("invalid", "A current canonical identity is required.");
  }
  const [ledger, reservation, prior] = await Promise.all([
    tx.ledger(command.eventId),
    tx.reservation(command.eventId, identity.key),
    tx.receipt(command.eventId, command.requestId),
  ]);
  assertReadySeatState(command.eventId, identity, ledger, reservation);
  const requestHash = createHash("sha256").update(JSON.stringify([
    "checkout-hold-v1", command.eventId, command.requestId,
    command.operation, command.paymentId, identity.key, identity.revision,
    command.expectedLedgerRevision, command.expectedCapacityRevision,
    command.expectedMigrationRevision, command.expectedReservationRevision,
  ])).digest("hex");
  if (prior) {
    if (!safe(prior.appliedLedgerRevision) ||
        prior.appliedLedgerRevision < 1 ||
        !safe(prior.appliedReservationRevision) ||
        prior.appliedReservationRevision < 1) {
      fail("unavailable", "Checkout hold receipt is malformed.");
    }
    if (prior.eventId !== command.eventId ||
        prior.requestId !== command.requestId ||
        prior.requestHash !== requestHash ||
        prior.operation !== command.operation ||
        prior.canonicalKey !== identity.key) {
      fail("conflict", "Checkout request ID was reused for different work.");
    }
    // Historical replay never renews a hold or re-admits a released seat.
    return freeze(tx, null, null, prior, true);
  }
  if (ledger.revision !== command.expectedLedgerRevision ||
      ledger.capacityRevision !== command.expectedCapacityRevision ||
      ledger.migrationRevision !== command.expectedMigrationRevision ||
      (reservation?.revision ?? 0) !== command.expectedReservationRevision ||
      reservation && reservation.identityRevision !== identity.revision) {
    fail("conflict", "Checkout inventory or identity changed.");
  }
  const held = checkoutHeldCount(ledger);
  const starting = command.operation === "checkoutHold";
  const confirming = command.operation === "confirmCheckoutHold";
  if (starting) {
    if (reservation?.active || reservation?.checkoutHold) {
      fail("conflict", "This identity already has a seat or checkout hold.");
    }
    if (ledger.occupied + held >= ledger.capacity) {
      fail("conflict", "This event is full.");
    }
  } else {
    if (!reservation?.checkoutHold ||
        reservation.checkoutHold.paymentId !== command.paymentId) {
      fail("conflict", "This payment does not own the checkout hold.");
    }
    if (command.nowMillis < reservation.reservedAtMillis) {
      fail("invalid", "Checkout reconciliation predates its hold.");
    }
    if (confirming && command.nowMillis >=
        reservation.checkoutHold.expiresAtMillis) {
      fail("conflict", "Checkout hold expired; reconcile the payment.");
    }
  }
  const nextLedger = {...ledger, checkoutHeld: held + (starting ? 1 : -1),
    occupied: ledger.occupied + (confirming ? 1 : 0),
    revision: ledger.revision + 1};
  const nextReservation: SeatReservation = {
    eventId: command.eventId, canonicalKey: identity.key,
    identityRevision: identity.revision, active: confirming,
    revision: (reservation?.revision ?? 0) + 1,
    reservedAtMillis: starting || confirming ? command.nowMillis :
      reservation!.reservedAtMillis,
    releasedAtMillis: starting || confirming ? null : command.nowMillis,
    ...(starting ? {checkoutHold: {paymentId: command.paymentId,
      expiresAtMillis: command.nowMillis + CHECKOUT_HOLD_MILLIS}} : {}),
  };
  const receipt: SeatReceipt = {eventId: command.eventId,
    requestId: command.requestId, requestHash, operation: command.operation,
    canonicalKey: identity.key, appliedLedgerRevision: nextLedger.revision,
    appliedReservationRevision: nextReservation.revision};
  return freeze(tx, nextLedger, nextReservation, receipt, false);
}

function freeze(transaction: SeatTransaction, ledger: SeatLedger | null,
  reservation: SeatReservation | null, receipt: SeatReceipt,
  replayed: boolean): PreparedCheckoutHold {
  return Object.freeze({[brand]: true as const, transaction, replayed,
    ledger: ledger ? Object.freeze({...ledger}) : null,
    reservation: reservation ? Object.freeze({...reservation,
      ...(reservation.checkoutHold ? {checkoutHold:
        Object.freeze({...reservation.checkoutHold})} : {})}) : null,
    receipt: Object.freeze({...receipt})});
}

/** Call after all business reads, within the preparing transaction only. */
export function applyCheckoutHold(tx: SeatTransaction,
  plan: PreparedCheckoutHold): void {
  if (plan[brand] !== true || !Object.isFrozen(plan) ||
      plan.transaction !== tx || applied.has(plan)) {
    fail("invalid", "Checkout hold was not prepared in this transaction.");
  }
  applied.add(plan);
  if (plan.ledger && plan.reservation) {
    tx.putLedger(plan.ledger as SeatLedger);
    tx.putReservation(plan.reservation as SeatReservation);
    tx.createReceipt(plan.receipt as SeatReceipt);
  }
}
