/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type AdminRecordActionExecutionCallablePayload = {
  [k: string]: unknown;
} & {
  executionId: string;
  actionId: string;
  callable: string;
  status: "started" | "succeeded" | "failed" | "indeterminate";
  requestHash: string;
  responseHash?: string | null;
  target?: string | null;
  errorCode?: string | null;
  errorMessage?: string | null;
  cliVersion?: string | null;
};
