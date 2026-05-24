/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by reportUser.
 */
export interface ReportUserCallablePayload {
  targetUserId: string;
  source?: string;
  reasonCode?: string;
  contextId?: string;
  notes?: string;
}
