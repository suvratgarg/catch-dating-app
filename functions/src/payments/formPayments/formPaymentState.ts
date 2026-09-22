import type {OrganizerFormPaymentDocument} from
  "../../shared/generated/firestoreAdminTypes";
import type {FormProviderPayment} from "./razorpayFormProvider";

type Ledger = OrganizerFormPaymentDocument;
type State = Pick<Ledger, "status" | "providerOrderId" | "providerPaymentId" |
  "amountPaise" | "currency" | "refundedAmountPaise" | "responseId" |
  "reservationReleased" | "capturedAt">;

export interface FormPaymentDecision {
  action: "none" | "finalize" | "refund" | "review";
  status: Ledger["status"];
  providerPaymentId: string | null;
  refundedAmountPaise: number;
}

/** Callers atomically persist this decision and its pending effect. */
export function decideFormPaymentObservation(state: State,
  payment: FormProviderPayment): FormPaymentDecision {
  if (!state.providerOrderId || payment.orderId !== state.providerOrderId ||
      payment.currency !== state.currency ||
      payment.amount !== state.amountPaise ||
      !Number.isSafeInteger(payment.amountRefunded) ||
      payment.amountRefunded < 0 ||
      payment.amountRefunded > state.amountPaise) {
    throw new Error("Payment does not match the frozen form fee.");
  }
  const unchanged: FormPaymentDecision = {
    action: "none", status: state.status,
    providerPaymentId: state.providerPaymentId,
    refundedAmountPaise: state.refundedAmountPaise,
  };
  const settled = state.capturedAt !== null || state.responseId !== null ||
    state.refundedAmountPaise > 0 ||
    ["captured", "submitted", "refundPending", "refunded"]
      .includes(state.status);
  if (settled && state.providerPaymentId !== payment.id) {
    // An order must have only one accepted capture. Keep the original identity.
    return payment.captured || payment.status === "refunded" ?
      {...unchanged, status: "reviewRequired", action: "review"} : unchanged;
  }
  const refunded = Math.max(state.refundedAmountPaise, payment.amountRefunded);
  if (refunded > 0) {
    return {action: state.responseId ? "none" : "review",
      status: refunded === state.amountPaise ? "refunded" : "reviewRequired",
      providerPaymentId: payment.id, refundedAmountPaise: refunded};
  }
  if (payment.status === "captured" && payment.captured) {
    if (state.responseId) return {...unchanged, status: "submitted"};
    if (state.reservationReleased || state.status === "expired" ||
        state.status === "refundPending") {
      return {action: "refund", status: "refundPending",
        providerPaymentId: payment.id, refundedAmountPaise: 0};
    }
    if (state.status === "reviewRequired") return unchanged;
    return {action: "finalize", status: "captured",
      providerPaymentId: payment.id, refundedAmountPaise: 0};
  }
  // Delayed authorized/failed deliveries cannot regress a captured submission.
  if (settled || ["expired", "reviewRequired"].includes(state.status)) {
    return unchanged;
  }
  return {...unchanged,
    status: payment.status === "failed" ? "failed" : "verifying"};
}
