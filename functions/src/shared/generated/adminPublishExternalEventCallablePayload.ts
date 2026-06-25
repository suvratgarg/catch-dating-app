/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminPublishExternalEvent. This publishes one preflight-approved read-only externalEvents/{eventId} document from eventSupplyReadiness/current.
 */
export interface AdminPublishExternalEventCallablePayload {
  sourceActionId: string;
  targetPath: string;
  reviewNote: string;
  checklist: {
    preflightActionReviewed: boolean;
    outboundLinksReviewed: boolean;
    noCatchBookingPaymentsWaitlist: boolean;
    ownerSafeCopyReviewed: boolean;
  };
}
