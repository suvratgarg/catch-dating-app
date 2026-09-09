/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reviewed event and UTC sender-day spending ceilings. Conservative debits are reserved costs, not provider billing receipts.
 */
export interface EventWhatsappBudgetDocument {
  schemaVersion: 1;
  budgetId: string;
  revision: number;
  senderId: string;
  scope:
    | {
        kind: "event";
        context: {
          mode: "live";
          organizerId: string;
          eventId: string;
        };
      }
    | {
        kind: "senderDay";
        day: string;
      };
  status: "active" | "paused";
  approvalId: string;
  currency: string;
  limitMicros: number;
  chargedMicros: number;
  startsAt: number;
  endsAt: number;
  updatedAt: number;
}
