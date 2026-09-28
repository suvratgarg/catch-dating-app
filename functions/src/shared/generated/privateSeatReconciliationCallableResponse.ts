/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {PrivateEventSetupMutationCallableResponse} from "./privateEventSetupMutationCallableResponse";

export type PrivateSeatReconciliationCallableResponse =
  | {
      kind: "progress";
      progress: {
        eventId: string;
        migrationRevision: number;
        phase: "scan" | "plan" | "apply" | "cleanup" | "discard";
        scannedRows: number;
        appliedRows: number;
        outputRows: number;
        occupied: null;
      };
    }
  | {
      kind: "complete";
      receipt: PrivateEventSetupMutationCallableResponse;
    }
  | {
      kind: "discarded";
      eventId: string;
      requestId: string;
    };
