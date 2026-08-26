/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * One independently loadable organizer contact section. Overview is the primary route payload; history is optional enrichment.
 */
export type GetOrganizerContactSectionCallableResponse =
  | {
      section: "overview";
      organizerId: string;
      contactId: string;
      displayName: string;
      sourceDisplayName: string;
      displayNameOverride: string | null;
      phoneE164: string | null;
      email: string | null;
      linkedAccount: boolean;
      identityState: "unlinked" | "verified" | "ambiguous";
      identityConfidence: "eventOnly" | "proposed" | "verified";
      contactDetailsEditable: boolean;
      /**
       * @maxItems 20
       */
      ambiguousCandidateContactIds: string[];
      whatsappAdminSuppressed: boolean;
      traits: {
        expectedEventCount: number;
        attendedEventCount: number;
        cancelledEventCount: number;
        noShowCount: number;
        importedEventCount: number;
        attendanceRate: number | null;
        /**
         * @maxItems 16
         */
        segmentIds: (
          | "new_to_organizer"
          | "first_time_attendee"
          | "repeat_attendee"
          | "regular"
          | "lapsed_regular"
          | "reliable_attendee"
          | "needs_confirmation"
          | "advocate"
          | "high_impact_advocate"
          | "whatsapp_reachable"
          | "sms_reachable"
        )[];
        whatsappStatus: "unknown" | "optedIn" | "optedOut";
        smsStatus: "unknown" | "optedIn" | "optedOut";
        sourceCoverage: "exact" | "partial" | "insufficientData";
      };
      /**
       * @maxItems 5
       */
      manualTags: {
        tagId: string;
        label: string;
      }[];
      /**
       * @maxItems 20
       */
      manualTagVocabulary: {
        tagId: string;
        label: string;
      }[];
      /**
       * @maxItems 100
       */
      notes: {
        noteId: string;
        body: string;
        authorUid: string;
        createdAtMillis: number;
        updatedAtMillis: number;
        revision: number;
      }[];
      notesTruncated: boolean;
      notesCoverage: "exact" | "unavailable";
      revision: number;
    }
  | {
      section: "history";
      organizerId: string;
      contactId: string;
      revenue: {
        coverage: "exact" | "partial" | "unavailable";
        /**
         * @maxItems 8
         */
        amounts: {
          currency: string;
          amountMinor: number;
          factCount: number;
          /**
           * @maxItems 4
           */
          sources: {
            source:
              | "catchPayment"
              | "hostImport"
              | "hostEstimate"
              | "providerOrder";
            amountMinor: number;
            factCount: number;
          }[];
        }[];
      };
      /**
       * @maxItems 100
       */
      events: {
        eventId: string;
        attendeeId: string;
        displayName: string;
        eventOriginMode: "catchNative" | "externalCompanion" | "unknown";
        eventProvider:
          | "catch"
          | "generic"
          | "luma"
          | "eventbrite"
          | "partiful"
          | "posh"
          | "bookmyshow"
          | "district"
          | "sortmyscene"
          | "airbnb"
          | null;
        source:
          | "catchBooking"
          | "hostImport"
          | "hostManual"
          | "webOtp"
          | "providerSync";
        status:
          | "invited"
          | "registered"
          | "waitlisted"
          | "checkedIn"
          | "cancelled";
        expected: boolean;
        registered: boolean;
        cancelled: boolean;
        checkedIn: boolean;
        eventStartAtMillis: number | null;
        eventEndAtMillis: number | null;
        registeredAtMillis: number | null;
        cancelledAtMillis: number | null;
        checkedInAtMillis: number | null;
        /**
         * @maxItems 8
         */
        revenues: {
          currency: string;
          amountMinor: number;
          source:
            | "catchPayment"
            | "hostImport"
            | "hostEstimate"
            | "providerOrder";
          factCount: number;
          allocation: "perAttendee" | "sharedOrder";
        }[];
      }[];
      eventsTruncated: boolean;
      /**
       * @maxItems 100
       */
      sends: (
        | {
            kind: "campaign";
            campaignId: string;
            name: string;
            messageClass:
              | "eventFollowUp"
              | "organizerUpdate"
              | "organizerPromotion";
            deliveryStatus:
              | "pending"
              | "sending"
              | "suppressed"
              | "accepted"
              | "sent"
              | "delivered"
              | "read"
              | "failed"
              | "replied"
              | "optedOut";
            createdAtMillis: number;
            sentAtMillis: number | null;
            updatedAtMillis: number;
          }
        | {
            kind: "announcement";
            broadcastId: string;
            eventId: string;
            eventName: string;
            audience: "booked" | "prospective" | "everyone";
            deliveryStatus: "available" | "failed";
            sentAtMillis: number;
            partialFailure: boolean;
          }
      )[];
      sendsTruncated: boolean;
      sendsCoverage: "exact" | "unavailable";
      /**
       * @maxItems 50
       */
      activeMerges: {
        mergeReceiptId: string;
        sourceContactId: string;
        sourceDisplayName: string;
        /**
         * @maxItems 20
         */
        evidence: (
          | "sameVerifiedUid"
          | "sameVerifiedPhone"
          | "sameImportedPhone"
          | "sameEmail"
          | "managerConfirmed"
        )[];
        /**
         * @maxItems 20
         */
        conflicts: string[];
        movedFactCount: number;
        mergedAtMillis: number;
      }[];
      revision: number;
    };
