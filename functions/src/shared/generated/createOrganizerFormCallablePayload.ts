/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates one organizer-owned generic form draft from a versioned template.
 */
export interface CreateOrganizerFormCallablePayload {
  organizerId: string;
  templateId: string;
  requestId: string;
  title: string | null;
  defaultTargetKind: "organizer" | "event" | "campaign";
  defaultTargetId: string | null;
}
