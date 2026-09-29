/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ProgramDeliveryMessageIntent {
  schemaVersion: 1;
  intentId: string;
  revision: number;
  context: {
    mode: "live";
    programId: string;
    organizerId: string;
  };
  programId: string;
  recipient: {
    kind: "guest" | "household" | "staff";
    /**
     * Stable recipient identity inside the program (guest id, household id, or staff uid). Endpoint resolution lives in the facts reader, never in the intent.
     */
    recipientKey: string;
  };
  workflow: {
    kind: "programMoment";
    momentId: string;
    /**
     * Moment-run occurrence identity. Phase 3 refines this into an explicit occurrence key once anchor revisions exist.
     */
    runId: string;
  };
  createdAt: number;
  expiresAt: number;
  /**
   * @minItems 1
   * @maxItems 3
   */
  permittedRoutes: ("organizerProgramWhatsapp" | "catchProgramActivity")[];
  deliveryPolicy: {
    maxAttempts: number;
    maxAttemptsPerRoute: number;
    minimumRetrySeconds: number;
  };
  kind: "programReminder";
  title: string;
  body: string;
  /**
   * The program/moment fact revision this intent was issued under. Reservation authority expires with it.
   */
  instructionRevision: number;
  /**
   * Approved WhatsApp template content for organizerProgramWhatsapp routes. Frozen at intent time; sender credentials never appear here.
   */
  whatsapp?: {
    connectionId: string;
    templateId: string;
    variables: {
      [k: string]: string;
    };
  };
}
