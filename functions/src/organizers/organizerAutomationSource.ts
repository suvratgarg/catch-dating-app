import {HttpsError} from "firebase-functions/v2/https";
import {
  EventDocument,
  OrganizerApplicationDocument,
  OrganizerCampaignDocument,
  OrganizerContactEventEdgeDocument,
  OrganizerContactOriginDocument,
  OrganizerFormAutomationRuleDocument,
  OrganizerFormResponseDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";
import {
  organizerApplicationAccess,
  organizerApplicationContactId,
} from "./organizerApplicationAccess";
import {staticAudienceMembers} from "./organizerSavedAudienceMembership";

export type OrganizerAutomationEventKind =
  | "submitted"
  | "withdrawn"
  | "applicationAccepted"
  | "eventAttended";
export interface OrganizerAutomationEvent {
  sourceId: string;
  kind: OrganizerAutomationEventKind;
  organizerId: string;
  formId: string | null;
  eventId: string | null;
  contactId: string | null;
  occurredAt: FirebaseFirestore.Timestamp;
  eventEndAt: FirebaseFirestore.Timestamp | null;
  response: OrganizerFormResponseDocument | null;
}

/** Reads the current authority, never a trigger's possibly stale snapshot. */
export async function readOrganizerAutomationEvent(
  db: FirebaseFirestore.Firestore,
  kind: OrganizerAutomationEventKind,
  sourceId: string,
): Promise<OrganizerAutomationEvent | null> {
  let result: OrganizerAutomationEvent;
  if (kind === "applicationAccepted") {
    const application = (
      await db.collection("organizerApplications").doc(sourceId).get()
    ).data() as OrganizerApplicationDocument | undefined;
    if (!application || application.reviewStatus !== "approved") return null;
    const access = await organizerApplicationAccess({
      db,
      applicationId: sourceId,
      application,
    });
    if (access.accessState === "revokedParticipantGrant") return null;
    const contactId = await organizerApplicationContactId({
      db,
      applicationId: sourceId,
      application,
    });
    if (!contactId) return null;
    result = {
      sourceId,
      kind,
      organizerId: application.organizerId,
      formId: application.formId,
      eventId: null,
      contactId,
      occurredAt: application.reviewedAt ?? application.updatedAt,
      eventEndAt: null,
      response: null,
    };
  } else if (kind === "eventAttended") {
    const edge = (
      await db.collection("organizerContactEventEdges").doc(sourceId).get()
    ).data() as OrganizerContactEventEdgeDocument | undefined;
    if (!edge?.checkedIn || edge.cancelled || !edge.checkedInAt) return null;
    const event = (
      await db.collection("events").doc(edge.eventId).get()
    ).data() as EventDocument | undefined;
    if (
      !event ||
      (event.organizerId ?? event.clubId) !== edge.organizerId ||
      event.status === "cancelled"
    ) {
      return null;
    }
    result = {
      sourceId,
      kind,
      organizerId: edge.organizerId,
      formId: null,
      eventId: edge.eventId,
      contactId: edge.contactId,
      occurredAt: edge.checkedInAt,
      eventEndAt: event.endTime,
      response: null,
    };
  } else {
    const response = (
      await db.collection("organizerFormResponses").doc(sourceId).get()
    ).data() as OrganizerFormResponseDocument | undefined;
    if (!response || response.status !== kind) return null;
    const form = (
      await db.collection("organizerForms").doc(response.formId).get()
    ).data();
    if (!form || form.organizerId !== response.organizerId) return null;
    const origin = (
      await db
        .collection("organizerContactOrigins")
        .doc(
          organizerContactOriginId({
            organizerId: response.organizerId,
            sourceKind: "hostForm",
            sourceEntityKind: "hostFormResponse",
            sourceEntityId: sourceId,
          }),
        )
        .get()
    ).data() as OrganizerContactOriginDocument | undefined;
    result = {
      sourceId,
      kind,
      organizerId: response.organizerId,
      formId: response.formId,
      eventId: null,
      contactId:
        origin?.organizerId === response.organizerId ?
          origin.currentContactId :
          null,
      occurredAt:
        kind === "withdrawn" ?
          (response.withdrawnAt ?? response.submittedAt) :
          response.submittedAt,
      eventEndAt: null,
      response,
    };
  }
  if (result.contactId) {
    const members = await staticAudienceMembers(
      db,
      result.organizerId,
      [result.contactId],
      false,
    );
    result.contactId = [...members][0] ?? null;
  }
  if (
    !result.contactId &&
    (kind === "eventAttended" || kind === "applicationAccepted")
  ) {
    return null;
  }
  return result;
}

export function organizerAutomationDueMillis(
  event: OrganizerAutomationEvent,
  rule: OrganizerFormAutomationRuleDocument,
): number {
  return (
    Math.max(event.occurredAt.toMillis(), event.eventEndAt?.toMillis() ?? 0) +
    (rule.delayMinutes ?? 0) * 60000
  );
}

/** Existing campaign delivery calls this again immediately before sending. */
export async function requireAutomationCampaignAuthority(
  db: FirebaseFirestore.Firestore,
  campaign: OrganizerCampaignDocument,
  nowMillis = Date.now(),
): Promise<void> {
  const origin = campaign.automationOrigin;
  if (!origin) return;
  const rule = (
    await db
      .collection("organizerFormAutomationRules")
      .doc(origin.ruleId)
      .get()
  ).data() as OrganizerFormAutomationRuleDocument | undefined;
  const action = rule?.actions.find(
    (item) => item.actionId === origin.actionId,
  );
  if (
    !rule?.enabled ||
    rule.organizerId !== campaign.organizerId ||
    rule.revision !== origin.ruleRevision ||
    action?.kind !== "campaignHandoff" ||
    !action.campaignId
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Automation was changed or paused.",
    );
  }
  await requireOrganizerManager({
    db,
    organizerId: rule.organizerId,
    actorUid: rule.updatedByUid,
  });
  const recipe = (
    await db.collection("organizerCampaigns").doc(action.campaignId).get()
  ).data() as OrganizerCampaignDocument | undefined;
  if (
    !recipe ||
    recipe.organizerId !== campaign.organizerId ||
    recipe.revision !== action.campaignRevision ||
    !["draft", "previewed"].includes(recipe.status)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Automation message changed.",
    );
  }
  const event = await readOrganizerAutomationEvent(
    db,
    origin.eventKind,
    origin.sourceId,
  );
  if (
    !event ||
    event.organizerId !== campaign.organizerId ||
    event.contactId !== origin.contactId ||
    organizerAutomationDueMillis(event, rule) > nowMillis
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Automation source is unavailable.",
    );
  }
}
