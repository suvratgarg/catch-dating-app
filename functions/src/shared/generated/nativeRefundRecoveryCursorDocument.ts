/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only, project-bound progress for bounded payment recovery queues. Revision compare-and-set prevents stale concurrent invocations from moving discovery backward; a null cursor means wrap to the oldest eligible row.
 */
export interface NativeRefundRecoveryCursorDocument {
  stateId:
    | "pendingRefunds"
    | "cancelledRazorpayPayments"
    | "pendingRazorpayOrders";
  projectId: string;
  schema: "1";
  revision: number;
  /**
   * Queue-specific exclusive discovery position. Refund queues use the next-attempt order key and payment document id. pendingRazorpayOrders uses integer epoch nanoseconds plus the complete pending-order document id.
   */
  cursor: null | {
    /**
     * Canonical tagged primary Firestore order value for the selected recovery queue.
     */
    nextAttemptOrderKey:
      | ("double:nan" | "double:negativeInfinity" | "double:positiveInfinity")
      | string;
    /**
     * Exclusive secondary key. pendingRazorpayOrders and refund queues store the complete Firestore document id.
     */
    paymentId: string;
  };
  updatedAtMillis: number;
}
