import type {PaymentDocument} from "../shared/generated/firestoreAdminTypes";
import {assertLegacyRefundAuthority} from "./legacyRefunds/intent";

/** Cash retained so far, not gross revenue or the pending refund liability. */
export function retainedNativePaymentAmount(payment: PaymentDocument):
  number | null {
  if (payment.status !== "completed" || payment.signUpFailed) return 0;
  const amount = payment.amountMinor ?? payment.amount;
  if (!Number.isSafeInteger(amount) || amount < 0) return null;
  if (!payment.cancellationRefund) return amount;
  try {
    assertLegacyRefundAuthority(payment, payment.cancellationRefund);
    return amount - payment.cancellationRefund.confirmedAmountMinor;
  } catch {
    return null;
  }
}
