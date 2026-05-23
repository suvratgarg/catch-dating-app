/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.
 */
export interface PhotoPromptAnswer {
  photoIndex: number;
  promptId: string;
  prompt: string;
  /**
   * @deprecated
   * Legacy user-entered caption retained for compatibility with older documents.
   */
  caption?: string;
}
