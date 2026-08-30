/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One reusable Customers-owned organizer CRM audience. Definitions use only the closed reviewed predicate vocabulary and never contain event-scoped or arbitrary Firestore queries.
 */
export interface OrganizerSavedAudienceDocument {
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
  createdByUid: string;
  updatedByUid: string;
  lastPreviewMatchCount: number | null;
  lastPreviewReachSummary?: null | {
    inCatch: number;
    automatic: number;
    byHand: number;
    unavailable: number;
  };
  lastPreviewAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
}
