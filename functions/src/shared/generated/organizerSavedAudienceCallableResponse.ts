/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized reusable organizer CRM audience definition.
 */
export interface OrganizerSavedAudienceCallableResponse {
  organizerId: string;
  audienceId: string;
  scope: "organizerCrm";
  name: string;
  status: "active" | "archived";
  definition: {
    join: "all" | "any";
    /**
     * @minItems 1
     * @maxItems 8
     */
    predicates: (
      | {
          kind: "computedSegment";
          segmentId:
            | "new_to_organizer"
            | "past_attendee"
            | "first_time_attendee"
            | "repeat_attendee"
            | "regular"
            | "lapsed_regular"
            | "reliable_attendee"
            | "needs_confirmation"
            | "advocate"
            | "high_impact_advocate"
            | "whatsapp_reachable"
            | "sms_reachable";
        }
      | {
          kind: "manualTag";
          manualTagId: string;
        }
      | {
          kind: "attendanceCount";
          operator: "atLeast" | "atMost";
          eventCount: number;
        }
      | {
          kind: "lastSeenWithinDays";
          days: number;
        }
      | {
          kind: "reachableForIntent";
          intent: "organizerWhatsappCampaign";
        }
    )[];
  };
  definitionHash: string;
  definitionVersion: number;
  revision: number;
  lastPreviewMatchCount: number | null;
  lastPreviewReachSummary: null | {
    inCatch: number;
    automatic: number;
    byHand: number;
    unavailable: number;
  };
  lastPreviewAtMillis: number | null;
  createdAtMillis: number;
  updatedAtMillis: number;
}
