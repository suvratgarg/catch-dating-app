/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer form summary after a lifecycle transition.
 */
export type SetOrganizerFormLifecycleCallableResponse = {
  organizerId: string;
  formId: string;
  title: string;
  description: string | null;
  purpose:
    | "application"
    | "registration"
    | "intake"
    | "waiver"
    | "feedback"
    | "survey";
  status: "draft" | "published" | "paused" | "archived";
  templateId: string | null;
  publicFormId: string;
  defaultTargetKind: "organizer" | "event" | "campaign";
  defaultTargetId: string | null;
  activeVersionId: string | null;
  draftRevision: number;
  publishedVersion: number;
  submittedResponseCount: number;
  consequences: {
    coverage: "exact" | "identityOnly" | "unavailable";
    identityPolicy:
      | (
          | "anonymous"
          | "emailVerified"
          | "phoneVerified"
          | "emailOrPhoneVerified"
          | "catchAccount"
        )
      | null;
    /**
     * @maxItems 7
     */
    enabledAutomationActionKinds: (
      | "notifyTeam"
      | "addOrganizerTag"
      | "createCrmContact"
      | "addApplicationQueue"
      | "proposeEventAttendee"
      | "signedWebhook"
      | "campaignHandoff"
    )[];
  };
  updatedAtMillis: number;
  publishedAtMillis: number | null;
  lastResponseAtMillis: number | null;
};
