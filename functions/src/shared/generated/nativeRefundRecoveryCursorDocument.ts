/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only, project-bound progress for the bounded native cancellation-refund due queue. Revision compare-and-set prevents stale concurrent invocations from moving discovery backward; a null cursor means wrap to the oldest due row.
 */
export interface NativeRefundRecoveryCursorDocument {
  stateId: "pendingRefunds" | "cancelledRazorpayPayments";
  projectId: string;
  schema: "1";
  revision: number;
  cursor: null | {
    nextAttemptOrderKey:
      | ("double:nan" | "double:negativeInfinity" | "double:positiveInfinity")
      | string;
    paymentId: string;
  };
  updatedAtMillis: number;
}
