/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Function-scoped program read shared by the door roster view and other per-function staff surfaces.
 */
export interface ProgramFunctionScopeCallablePayload {
  programId: string;
  /**
   * Requested function. Staff are still intersected with their granted function scope; managers may read any function.
   */
  functionId: string;
}
