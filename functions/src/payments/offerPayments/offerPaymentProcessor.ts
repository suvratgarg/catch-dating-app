import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerEventOfferPaymentDocument as Payment} from
  "../../shared/generated/firestoreAdminTypes";
import type {LoadRecipientAuth} from
  "../../organizerEventOfferRecipients/recipientGrant";
import {paymentRoutingSnapshotsMatch, type PaymentRoutingSnapshot} from
  "../paymentRouting";
import type {FormPaymentMerchant} from
  "../formPayments/formPaymentProcessor";
import {FormPaymentProviderError, type FormProviderPayment,
  type RazorpayPaymentProvider} from "../formPayments/razorpayPaymentProvider";
import {decideFormPaymentObservation} from "../formPayments/formPaymentState";
import {OFFER_PAYMENT_COLLECTION, parseOfferPayment} from
  "./offerPaymentReservation";
import {releaseOfferPaymentHold} from "./offerPaymentExpiry";
import {finalizeCapturedOfferPayment} from "./offerPaymentAdmission";
import {cancelPaidOfferForCancelledEvent} from "./offerPaymentCancellation";

export interface OfferPaymentAuthority {
  resolve(): Promise<FormPaymentMerchant>;
  assertReady(tx: FirebaseFirestore.Transaction): Promise<void>;
}
export interface OfferPaymentProcessorDeps {
  db: FirebaseFirestore.Firestore;
  paymentId: string;
  routing: PaymentRoutingSnapshot;
  authority: OfferPaymentAuthority;
  provider: Pick<RazorpayPaymentProvider, "createOrder" | "findOrderByReceipt" |
    "fetchOrder" | "fetchOrderPayments" | "fetchPayment" | "capturePayment" |
    "refundPayment" | "fetchRefund" | "verifyCheckout">;
  now?: () => number;
  loadCurrentAuthUser?: LoadRecipientAuth;
}

/** Shared financial rules; offer fulfillment owns its seat and receipt. */
function observeDecision(ledger: Payment, observation: FormProviderPayment) {
  const decision = decideFormPaymentObservation({...ledger,
    responseId: ledger.cancellation?.refundAmountPaise ?
      null : ledger.admissionReceiptId,
    status: (ledger.status === "admitted" || ledger.status === "cancelled") ?
      "submitted" : ledger.status},
  observation);
  // A provider-side refund after a confirmed no-refund cancellation is an
  // anomaly; retain the guest decision and route the financial fact to review.
  if (ledger.cancellation?.refundAmountPaise === 0 &&
      decision.refundedAmountPaise > 0) {
    return {...decision, action: "review" as const,
      status: "reviewRequired" as const};
  }
  return {...decision,
    status: decision.status === "submitted" ?
      ledger.cancellation?.refundAmountPaise === 0 ? "cancelled" : "admitted" :
      decision.status};
}

/** One runtime is pinned to one immutable payment and merchant snapshot. */
export class OfferPaymentProcessor {
  private readonly now: () => number;
  constructor(private readonly deps: OfferPaymentProcessorDeps) {
    this.now = deps.now ?? Date.now;
  }

  async read(): Promise<Payment> {
    return this.deps.db.runTransaction(async (tx) =>
      this.bound((await tx.get(this.ref())).data()));
  }

  async ensureOrder(): Promise<Payment> {
    const initial = await this.read();
    if (initial.providerOrderId || initial.admissionReceiptId) return initial;
    const merchant = await this.deps.authority.resolve();
    const claim = await this.deps.db.runTransaction(async (tx) => {
      const current = this.bound((await tx.get(this.ref())).data());
      const now = this.now();
      if (current.providerOrderId || current.admissionReceiptId ||
          current.leaseUntil && current.leaseUntil.toMillis() > now ||
          !["creatingOrder", "orderUnknown", "expired"]
            .includes(current.status)) return null;
      const create = current.status === "creatingOrder" &&
        !current.reservationReleased && current.checkoutExpiresAt.toMillis() >
          now;
      if (create) await this.deps.authority.assertReady(tx);
      const leaseUntil = Timestamp.fromMillis(now + 60_000);
      // Persist uncertainty BEFORE POST. A crashed owner never posts again.
      tx.update(this.ref(), {leaseUntil, updatedAt: Timestamp.fromMillis(now),
        status: current.status === "expired" ? "expired" : "orderUnknown"});
      return {payment: current, create, leaseUntil};
    });
    if (!claim) return this.read();
    try {
      const token = merchant.authorizationHandle;
      const order = claim.create ? await this.deps.provider.createOrder(token,
        {amount: claim.payment.amountPaise, receipt: claim.payment.receipt}) :
        await this.deps.provider.findOrderByReceipt(token,
          claim.payment.receipt);
      if (order && (order.receipt !== claim.payment.receipt ||
          order.amount !== claim.payment.amountPaise ||
          order.currency !== claim.payment.currency)) {
        throw new Error("Recovered order differs from the frozen offer.");
      }
      await this.deps.db.runTransaction(async (tx) => {
        const current = this.bound((await tx.get(this.ref())).data());
        if (current.leaseUntil?.toMillis() !== claim.leaseUntil.toMillis()) {
          return;
        }
        if (current.providerOrderId && current.providerOrderId !== order?.id) {
          throw new Error("Offer order identity changed.");
        }
        // Expiry may commit while the provider request is in flight.
        const expired = current.reservationReleased ||
          current.checkoutExpiresAt.toMillis() <= this.now();
        tx.update(this.ref(), {providerOrderId: order?.id ?? null,
          leaseUntil: null, status: expired ? "expired" :
            order ? "checkoutReady" : "orderUnknown",
          updatedAt: Timestamp.fromMillis(this.now()), lastErrorCode: null});
      });
    } catch (error) {
      await this.deps.db.runTransaction(async (tx) => {
        const current = this.bound((await tx.get(this.ref())).data());
        if (current.leaseUntil?.toMillis() !== claim.leaseUntil.toMillis()) {
          return;
        }
        const rejected = claim.create &&
          error instanceof FormPaymentProviderError &&
          error.disposition !== "outcomeUnknown";
        tx.update(this.ref(), {leaseUntil: null,
          status: current.reservationReleased ? "expired" :
            rejected ? "failed" : "orderUnknown",
          lastErrorCode: rejected ? "orderRejected" : "orderOutcomeUnknown",
          updatedAt: Timestamp.fromMillis(this.now())});
      });
      throw new HttpsError("unavailable", "Payment setup is being checked.");
    }
    return this.read();
  }

  async verifyClientCallback(input: {
    uid: string; providerPaymentId: string; signature: string;
  }): Promise<Payment> {
    const payment = await this.read();
    if (payment.recipientUid !== input.uid || !payment.providerOrderId ||
        !this.deps.provider.verifyCheckout({
          serverOrderId: payment.providerOrderId,
          paymentId: input.providerPaymentId, signature: input.signature})) {
      throw new HttpsError("permission-denied", "Payment unavailable.");
    }
    return this.reconcile(input.providerPaymentId);
  }

  async reconcile(providerPaymentId?: string): Promise<Payment> {
    // Inventory expiry must not depend on provider availability.
    await this.expire();
    let ledger = await this.ensureOrder();
    if (ledger.status === "admitted" || ledger.status === "cancelled") {
      await cancelPaidOfferForCancelledEvent({db: this.deps.db,
        paymentId: this.deps.paymentId, nowMillis: this.now()});
      ledger = await this.read();
    }
    if (!ledger.providerOrderId) return ledger;
    const {authorizationHandle: token} = await this.deps.authority.resolve();
    const order = await this.deps.provider.fetchOrder(token,
      ledger.providerOrderId);
    if (order.receipt !== ledger.receipt ||
        order.amount !== ledger.amountPaise ||
        order.currency !== ledger.currency) {
      throw new Error("Provider order differs from the frozen offer.");
    }
    const observations = providerPaymentId ?
      [await this.deps.provider.fetchPayment(token, providerPaymentId)] :
      await this.deps.provider.fetchOrderPayments(token,
        ledger.providerOrderId);
    for (let observation of observations) {
      observeDecision(ledger, observation);
      if (observation.status === "authorized" && !ledger.admissionReceiptId &&
          !ledger.capturedAt && !ledger.reservationReleased &&
          ["checkoutReady", "failed", "verifying"].includes(ledger.status) &&
          ledger.checkoutExpiresAt.toMillis() > this.now()) {
        try {
          observation = await this.deps.provider.capturePayment(token,
            observation.id, ledger.amountPaise);
        } catch {
          observation = await this.deps.provider.fetchPayment(token,
            observation.id);
        }
      }
      await this.observe(observation);
      ledger = await this.read();
    }
    if (ledger.status === "captured") {
      await finalizeCapturedOfferPayment({db: this.deps.db,
        paymentId: this.deps.paymentId, nowMillis: this.now(),
        loadCurrentAuthUser: this.deps.loadCurrentAuthUser});
    }
    await this.expire();
    ledger = await this.read();
    if (ledger.status === "refundPending") await this.refund();
    return this.read();
  }

  private async observe(observation: FormProviderPayment): Promise<void> {
    await this.deps.db.runTransaction(async (tx) => {
      const ledger = this.bound((await tx.get(this.ref())).data());
      const {action, ...decision} = observeDecision(ledger, observation);
      const now = Timestamp.fromMillis(this.now());
      tx.update(this.ref(), {...decision, updatedAt: now,
        ...(ledger.cancellation && ledger.settlement &&
          decision.status === "refunded" ? {settlement: {...ledger.settlement,
            state: "reversed"}} : {}),
        capturedAt: ledger.capturedAt ?? (observation.captured ? now : null),
        lastErrorCode: action === "review" ? "paymentNeedsReview" :
          ledger.lastErrorCode});
    });
  }

  private async refund(): Promise<void> {
    const {authorizationHandle: token} = await this.deps.authority.resolve();
    const eligible = (payment: Payment) => payment.status === "refundPending" &&
      payment.providerPaymentId && payment.reservationReleased &&
      (!payment.admissionReceiptId || payment.cancellation) &&
      payment.refundedAmountPaise === 0;
    const claim = await this.deps.db.runTransaction(async (tx) => {
      const payment = this.bound((await tx.get(this.ref())).data());
      const now = this.now();
      if (!eligible(payment) ||
          payment.leaseUntil && payment.leaseUntil.toMillis() > now ||
          (payment.settlement?.leaseUntilMillis ?? 0) > now) return null;
      const leaseUntil = Timestamp.fromMillis(now + 180_000);
      tx.update(this.ref(), {leaseUntil});
      return {payment, leaseUntil};
    });
    if (!claim) return;
    try {
      const ledger = claim.payment;
      const refund = ledger.providerRefundId ?
        await this.deps.provider.fetchRefund(token, ledger.providerRefundId) :
        await this.deps.provider.refundPayment(token, {
          paymentId: ledger.providerPaymentId!, amount: ledger.amountPaise,
          idempotencyKey: `offer_refund_${this.deps.paymentId}`});
      if (refund.paymentId !== ledger.providerPaymentId ||
          refund.amount !== ledger.amountPaise) {
        throw new Error("Refund differs from the offer payment.");
      }
      await this.deps.db.runTransaction(async (tx) => {
        const current = this.bound((await tx.get(this.ref())).data());
        if (current.leaseUntil?.toMillis() !== claim.leaseUntil.toMillis()) {
          return;
        }
        if (!eligible(current)) {
          tx.update(this.ref(), {leaseUntil: null});
          return;
        }
        tx.update(this.ref(), {providerRefundId: refund.id, leaseUntil: null,
          ...(current.cancellation && current.settlement &&
            refund.status === "processed" ? {
              settlement: {...current.settlement, state: "reversed"},
            } : {}),
          status: refund.status === "processed" ? "refunded" :
            refund.status === "failed" ? "reviewRequired" : "refundPending",
          refundedAmountPaise: refund.status === "processed" ?
            current.amountPaise : current.refundedAmountPaise,
          lastErrorCode: refund.status === "failed" ? "refundFailed" : null,
          updatedAt: Timestamp.fromMillis(this.now())});
      });
    } catch (error) {
      await this.deps.db.runTransaction(async (tx) => {
        const current = this.bound((await tx.get(this.ref())).data());
        if (current.leaseUntil?.toMillis() === claim.leaseUntil.toMillis()) {
          tx.update(this.ref(), {leaseUntil: null,
            updatedAt: Timestamp.fromMillis(this.now())});
        }
      });
      throw error;
    }
  }

  private bound(raw: unknown): Payment {
    const payment = parseOfferPayment(raw, this.deps.paymentId);
    if (!paymentRoutingSnapshotsMatch(payment.routing, this.deps.routing)) {
      throw new HttpsError("failed-precondition",
        "Payment routing changed.");
    }
    return payment;
  }
  private ref() {
    return this.deps.db.collection(OFFER_PAYMENT_COLLECTION)
      .doc(this.deps.paymentId);
  }
  private expire() {
    return releaseOfferPaymentHold({db: this.deps.db,
      paymentId: this.deps.paymentId,
      nowMillis: this.now(), reason: "expired"});
  }
}
