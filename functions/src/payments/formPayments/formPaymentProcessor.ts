import {Timestamp, FieldValue} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerFormPaymentDocument as Payment,
  OrganizerPaymentConnectionDocument as Connection,
  OrganizerFormDocument as Form} from
  "../../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../../shared/validation";
import type {RazorpayCredentialVault} from "./razorpayCredentialVault";
import type {FormPaymentCredentials} from "./formPaymentCredentials";
import {FormPaymentProviderError, type FormProviderPayment,
  type RazorpayFormProvider} from "./razorpayFormProvider";
import {requireReadyFormPaymentConnection} from "./formPaymentConnectionPolicy";
import {decideFormPaymentObservation} from "./formPaymentState";
import {expireFormPaymentReservation, finalizeCapturedFormPayment} from
  "./formPaymentSubmission";

interface ProcessorDeps {
  db: FirebaseFirestore.Firestore;
  provider: Pick<RazorpayFormProvider, "createOrder" | "findOrderByReceipt" |
    "fetchOrder" | "fetchOrderPayments" | "fetchPayment" | "capturePayment" |
    "refundPayment" | "fetchRefund" | "verifyCheckout">;
  vault: Pick<RazorpayCredentialVault, "access">;
  credentials?: Pick<FormPaymentCredentials, "access">;
  now?: () => number;
}

/** Provider work occurs outside transactions; durable state fences retries. */
export class FormPaymentProcessor {
  private readonly now: () => number;
  constructor(private readonly deps: ProcessorDeps) {
    this.now = deps.now ?? Date.now;
  }

  async ensureOrder(paymentId: string): Promise<Payment> {
    const initial = await this.read(paymentId);
    if (initial.providerOrderId || initial.responseId) return initial;
    const {credential} = await this.merchant(initial);
    const ref = this.ref(paymentId);
    const leaseUntil = Timestamp.fromMillis(this.now() + 60_000);
    const claim = await this.deps.db.runTransaction(async (tx) => {
      const current = requireDoc<Payment>(await tx.get(ref),
        "OrganizerFormPaymentDocument");
      if (current.providerOrderId || current.responseId ||
          current.leaseUntil && current.leaseUntil.toMillis() > this.now()) {
        return null;
      }
      if (!["creatingOrder", "orderUnknown",
        "expired"].includes(current.status)) {
        return null;
      }
      const create = current.status === "creatingOrder" &&
        current.checkoutExpiresAt.toMillis() > this.now() &&
        !current.reservationReleased;
      if (create) {
        const connectionSnap = await tx.get(this.deps.db
          .collection("organizerPaymentConnections").doc(current.connectionId));
        const connection = requireDoc<Connection>(connectionSnap,
          "OrganizerPaymentConnectionDocument");
        requireReadyFormPaymentConnection(connection, current.organizerId,
          this.now());
        if (connection.accountId !== credential.accountId ||
            connection.mode !== credential.mode ||
            connection.publicToken !== credential.token.publicToken) {
          throw new HttpsError("unavailable", "Merchant connection changed.");
        }
      }
      // Before the POST, write uncertainty durably. Every later owner recovers
      // by receipt, even if this process dies before it can save the order id.
      tx.update(ref, {leaseUntil,
        status: current.status === "expired" ? "expired" : "orderUnknown",
        updatedAt: Timestamp.fromMillis(this.now())});
      return {payment: current, create};
    });
    if (!claim) return this.read(paymentId);
    try {
      const order = claim.create ? await this.deps.provider.createOrder(
        credential.token.accessToken, {amount: claim.payment.amountPaise,
          receipt: claim.payment.receipt}) :
        await this.deps.provider.findOrderByReceipt(
          credential.token.accessToken,
          claim.payment.receipt);
      if (order && (order.amount !== claim.payment.amountPaise ||
          order.currency !== claim.payment.currency ||
          order.receipt !== claim.payment.receipt)) {
        throw new Error("Recovered order does not match the frozen fee.");
      }
      await this.deps.db.runTransaction(async (tx) => {
        const current = requireDoc<Payment>(await tx.get(ref),
          "OrganizerFormPaymentDocument");
        if (current.leaseUntil?.toMillis() !== leaseUntil.toMillis()) return;
        if (current.providerOrderId && current.providerOrderId !== order?.id) {
          throw new Error("Form order identity changed.");
        }
        tx.update(ref, {providerOrderId: order?.id ?? null, leaseUntil: null,
          status: current.status === "expired" ? "expired" :
            order ? "checkoutReady" : "orderUnknown",
          updatedAt: Timestamp.fromMillis(this.now()), lastErrorCode: null});
      });
    } catch (error) {
      await this.deps.db.runTransaction(async (tx) => {
        const current = requireDoc<Payment>(await tx.get(ref),
          "OrganizerFormPaymentDocument");
        if (current.leaseUntil?.toMillis() !== leaseUntil.toMillis()) return;
        const rejected = claim.create &&
          error instanceof FormPaymentProviderError &&
          error.disposition !== "outcomeUnknown";
        tx.update(ref, {leaseUntil: null,
          status: current.status === "expired" ? "expired" :
            rejected ? "failed" : "orderUnknown",
          lastErrorCode: rejected ? "orderRejected" : "orderOutcomeUnknown",
          updatedAt: Timestamp.fromMillis(this.now())});
      });
      throw new HttpsError("unavailable",
        "Payment setup is being checked. Please do not start another payment.");
    }
    return this.read(paymentId);
  }

  async verifyClientCallback(input: {
    paymentId: string; respondentUid: string;
    providerPaymentId: string; signature: string;
  }): Promise<Payment> {
    const payment = await this.read(input.paymentId);
    if (payment.respondentUid !== input.respondentUid) {
      throw new HttpsError("permission-denied", "Payment unavailable.");
    }
    if (!payment.providerOrderId || !this.deps.provider.verifyCheckout({
      serverOrderId: payment.providerOrderId,
      paymentId: input.providerPaymentId,
      signature: input.signature})) {
      throw new HttpsError("permission-denied",
        "Payment signature is invalid.");
    }
    // Signature is only a trigger. The provider's captured state is authority.
    return this.reconcile(input.paymentId, input.providerPaymentId);
  }

  async reconcile(paymentId: string, providerPaymentId?: string):
    Promise<Payment> {
    let ledger = await this.ensureOrder(paymentId);
    if (!ledger.providerOrderId) {
      await expireFormPaymentReservation({db: this.deps.db, paymentId,
        now: Timestamp.fromMillis(this.now())});
      return this.read(paymentId);
    }
    const {credential} = await this.merchant(ledger);
    const token = credential.token.accessToken;
    const order = await this.deps.provider.fetchOrder(token,
      ledger.providerOrderId);
    if (order.receipt !== ledger.receipt ||
        order.amount !== ledger.amountPaise ||
        order.currency !== ledger.currency) {
      throw new Error("Provider order does not match the frozen form fee.");
    }
    const observations = providerPaymentId ?
      [await this.deps.provider.fetchPayment(token, providerPaymentId)] :
      await this.deps.provider.fetchOrderPayments(token,
        ledger.providerOrderId);
    for (let payment of observations) {
      // Validate before attempting capture. No unrelated payment is mutated.
      decideFormPaymentObservation(ledger, payment);
      if (payment.status === "authorized" && !ledger.responseId &&
          !ledger.capturedAt && !ledger.reservationReleased &&
          ["checkoutReady", "failed", "verifying"].includes(ledger.status) &&
          ledger.checkoutExpiresAt.toMillis() > this.now()) {
        try {
          payment = await this.deps.provider.capturePayment(token, payment.id,
            ledger.amountPaise);
        } catch {
          payment = await this.deps.provider.fetchPayment(token, payment.id);
        }
      }
      await this.observe(paymentId, payment);
      ledger = await this.read(paymentId);
    }
    if (ledger.status === "captured") {
      await finalizeCapturedFormPayment({db: this.deps.db, paymentId,
        now: Timestamp.fromMillis(this.now())});
    }
    await expireFormPaymentReservation({db: this.deps.db, paymentId,
      now: Timestamp.fromMillis(this.now())});
    ledger = await this.read(paymentId);
    if (ledger.status === "refundPending") await this.refund(paymentId);
    return this.read(paymentId);
  }

  async read(paymentId: string): Promise<Payment> {
    if (!/^fp_[a-f0-9]{32}$/u.test(paymentId)) {
      throw new HttpsError("invalid-argument", "Invalid form payment id.");
    }
    const snap = await this.ref(paymentId).get();
    if (!snap.exists) throw new HttpsError("not-found", "Payment not found.");
    return requireDoc<Payment>(snap, "OrganizerFormPaymentDocument");
  }

  private async observe(paymentId: string, observation: FormProviderPayment):
    Promise<void> {
    await this.deps.db.runTransaction(async (tx) => {
      const ref = this.ref(paymentId);
      const ledger = requireDoc<Payment>(await tx.get(ref),
        "OrganizerFormPaymentDocument");
      const {action, ...decision} = decideFormPaymentObservation(ledger,
        observation);
      const now = Timestamp.fromMillis(this.now());
      tx.update(ref, {...decision, updatedAt: now,
        capturedAt: ledger.capturedAt ??
          (observation.captured ? now : null),
        lastErrorCode: action === "review" ? "paymentNeedsReview" :
          ledger.lastErrorCode});
    });
  }

  private async refund(paymentId: string): Promise<void> {
    const ledger = await this.read(paymentId);
    if (ledger.status !== "refundPending" || !ledger.providerPaymentId ||
        ledger.responseId || ledger.refundedAmountPaise > 0) return;
    const {credential} = await this.merchant(ledger);
    const refund = ledger.providerRefundId ?
      await this.deps.provider.fetchRefund(credential.token.accessToken,
        ledger.providerRefundId) :
      await this.deps.provider.refundPayment(credential.token.accessToken, {
        paymentId: ledger.providerPaymentId, amount: ledger.amountPaise,
        idempotencyKey: `form_refund_${paymentId}`,
      });
    if (refund.paymentId !== ledger.providerPaymentId ||
        refund.amount !== ledger.amountPaise) {
      throw new Error("Refund does not match the form payment.");
    }
    await this.deps.db.runTransaction(async (tx) => {
      const ref = this.ref(paymentId);
      const current = requireDoc<Payment>(await tx.get(ref),
        "OrganizerFormPaymentDocument");
      if (current.responseId || current.status !== "refundPending") return;
      const formRef = this.deps.db.collection("organizerForms")
        .doc(current.formId);
      const formSnap = await tx.get(formRef);
      const form = formSnap.exists ? requireDoc<Form>(formSnap,
        "OrganizerFormDocument") : null;
      if (!current.reservationReleased && form &&
          form.organizerId === current.organizerId &&
          (form.pendingPaymentCount ?? 0) > 0) {
        tx.update(formRef, {pendingPaymentCount: FieldValue.increment(-1)});
      }
      tx.update(ref, {providerRefundId: refund.id, reservationReleased: true,
        status: refund.status === "processed" ? "refunded" :
          refund.status === "failed" ? "reviewRequired" : "refundPending",
        refundedAmountPaise: refund.status === "processed" ?
          ledger.amountPaise : current.refundedAmountPaise,
        lastErrorCode: refund.status === "failed" ? "refundFailed" : null,
        updatedAt: Timestamp.fromMillis(this.now())});
    });
  }

  private async merchant(payment: Payment) {
    const snap = await this.deps.db.collection("organizerPaymentConnections")
      .doc(payment.connectionId).get();
    const connection = requireDoc<Connection>(snap,
      "OrganizerPaymentConnectionDocument");
    if (connection.organizerId !== payment.organizerId ||
        connection.accountId !== payment.accountId ||
        connection.mode !== payment.mode || !connection.secretVersionResource) {
      throw new Error("Merchant does not match the form payment.");
    }
    const binding = {organizerId: payment.organizerId,
      connectionId: payment.connectionId, accountId: payment.accountId,
      mode: payment.mode};
    const credential = this.deps.credentials ?
      await this.deps.credentials.access(binding) :
      await this.deps.vault.access(connection.secretVersionResource, binding);
    if (credential.token.expiresAt <= this.now()) {
      throw new HttpsError("unavailable",
        "Merchant connection needs refreshing.");
    }
    return {connection, credential};
  }

  private ref(paymentId: string): FirebaseFirestore.DocumentReference {
    return this.deps.db.collection("organizerFormPayments").doc(paymentId);
  }
}
