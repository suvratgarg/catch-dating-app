import {createHash} from "crypto";
import {eventPolicyFromEvent} from "../events/eventPolicy";
import type {
  EventDocument,
  EventParticipationDocument,
  HostPaymentAccountDocument,
  OrganizerApplicationDocument,
  OrganizerDocument,
  OrganizerFormAutomationRuleDocument,
  OrganizerFormAutomationRunDocument,
  ProviderSyncRunDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {ListOrganizerAttentionItemsCallableResponse} from
  "../shared/generated/listOrganizerAttentionItemsCallableResponse";
import {
  hostAttentionPolicyCatalog,
} from "../shared/generated/catalogs/hostAttentionPolicyCatalog";

export type HostAttentionItem =
  ListOrganizerAttentionItemsCallableResponse["items"][number];
export type HostAttentionCoverage =
  ListOrganizerAttentionItemsCallableResponse["coverage"][number];
export type HostPaymentProvider = "razorpay" | "stripe";

export interface AttentionSourceRow<T> {
  id: string;
  data: T;
  sourceUpdatedAtMillis: number;
}

export interface OrganizerAttentionSources {
  organizer: AttentionSourceRow<OrganizerDocument>;
  events: Array<AttentionSourceRow<EventDocument>>;
  eventParticipations: Array<AttentionSourceRow<EventParticipationDocument>>;
  applications: Array<AttentionSourceRow<OrganizerApplicationDocument>>;
  providerSyncRuns: Array<AttentionSourceRow<ProviderSyncRunDocument>>;
  automationRules: Array<
    AttentionSourceRow<OrganizerFormAutomationRuleDocument>
  >;
  automationRuns: Array<
    AttentionSourceRow<OrganizerFormAutomationRunDocument>
  >;
  paymentAccounts: Partial<Record<
    HostPaymentProvider,
    AttentionSourceRow<HostPaymentAccountDocument>
  >>;
}

export type DesiredHostAttentionItem = HostAttentionItem & {
  sourceUpdatedAtMillis: number;
};

const hourMillis = 60 * 60 * 1000;
const immediateMillis = hostAttentionPolicyCatalog.immediateHours * hourMillis;
const soonMillis = hostAttentionPolicyCatalog.soonHours * hourMillis;
export const hostAttentionHorizonMillis =
  hostAttentionPolicyCatalog.horizonHours * hourMillis;

/**
 * Derives every source-backed server item from one complete bounded snapshot.
 */
export function deriveOrganizerAttentionItems(params: {
  organizerId: string;
  nowMillis: number;
  sources: OrganizerAttentionSources;
}): DesiredHostAttentionItem[] {
  const horizonEndsAtMillis = params.nowMillis + hostAttentionHorizonMillis;
  const activeEvents = params.sources.events.filter((row) =>
    row.data.status === "active" &&
    row.data.endTime.toMillis() > params.nowMillis &&
    row.data.startTime.toMillis() <= horizonEndsAtMillis
  );
  const items: DesiredHostAttentionItem[] = [];

  for (const row of activeEvents) {
    const event = row.data;
    const startMillis = event.startTime.toMillis();
    const endMillis = event.endTime.toMillis();
    const eventName = displayEventName(event);
    if (startMillis <= params.nowMillis && params.nowMillis < endMillis) {
      items.push(buildItem({
        kind: "eventLiveOperations",
        scope: "event",
        sourceOwner: "events",
        sourceId: row.id,
        sourceRevision: revisionOf({
          eventId: row.id,
          status: event.status,
          startMillis,
          endMillis,
        }),
        eventId: row.id,
        consequence: "blocksLiveOperation",
        blocking: true,
        dueAtMillis: startMillis,
        expiresAtMillis: endMillis,
        destination: destination({
          route: "hostEventManage",
          section: "live",
          eventId: row.id,
        }),
        context: context({eventName}),
        dedupeKey: `eventLiveOperations:${row.id}`,
        assignedHostUid: null,
        sourceUpdatedAtMillis: row.sourceUpdatedAtMillis,
        nowMillis: params.nowMillis,
      }));
    }

    const policy = eventPolicyFromEvent(event);
    const waitlistedCount = event.waitlistedCount ?? 0;
    if (waitlistedCount > 0 &&
        policy.admission.manualApprovalRequired !== true) {
      items.push(buildItem({
        kind: "eventWaitlistReview",
        scope: "event",
        sourceOwner: "events",
        sourceId: row.id,
        sourceRevision: revisionOf({
          eventId: row.id,
          waitlistedCount,
          capacityLimit: event.capacityLimit,
          admissionFormat: policy.admission.format,
          waitlistMode: policy.admission.waitlistPolicy?.mode ?? null,
          manualApprovalRequired: false,
          startMillis,
          endMillis,
        }),
        eventId: row.id,
        consequence: "risksGuestExperience",
        blocking: false,
        dueAtMillis:
          startMillis - hostAttentionPolicyCatalog.immediateHours * hourMillis,
        expiresAtMillis: endMillis,
        destination: destination({
          route: "hostEventManage",
          section: "guests",
          eventId: row.id,
        }),
        context: context({eventName, count: waitlistedCount}),
        dedupeKey: `eventWaitlistReview:${row.id}`,
        assignedHostUid: null,
        sourceUpdatedAtMillis: row.sourceUpdatedAtMillis,
        nowMillis: params.nowMillis,
      }));
    }
  }

  const activeEventsById = new Map(activeEvents.map((row) => [row.id, row]));
  const pendingRequestsByEvent = new Map<
    string,
    Array<AttentionSourceRow<EventParticipationDocument>>
  >();
  for (const row of params.sources.eventParticipations) {
    if (row.data.status !== "waitlisted" ||
        row.data.hostApprovalStatus !== "pending") continue;
    const event = activeEventsById.get(row.data.eventId);
    if (!event ||
        eventPolicyFromEvent(event.data).admission.manualApprovalRequired !==
          true) continue;
    const requests = pendingRequestsByEvent.get(row.data.eventId) ?? [];
    requests.push(row);
    pendingRequestsByEvent.set(row.data.eventId, requests);
  }
  for (const [eventId, requests] of pendingRequestsByEvent) {
    const event = activeEventsById.get(eventId)!;
    const ordered = [...requests].sort((left, right) =>
      requestOpenedAtMillis(left) - requestOpenedAtMillis(right) ||
      left.id.localeCompare(right.id));
    items.push(buildItem({
      kind: "eventJoinRequestReview",
      scope: "event",
      sourceOwner: "eventParticipations",
      sourceId: eventId,
      sourceRevision: revisionOf({
        eventId,
        startMillis: event.data.startTime.toMillis(),
        endMillis: event.data.endTime.toMillis(),
        requests: ordered.map((row) => ({
          id: row.id,
          requestOpenedAtMillis: requestOpenedAtMillis(row),
          sourceUpdatedAtMillis: row.sourceUpdatedAtMillis,
        })),
      }),
      eventId,
      consequence: "delaysResponse",
      blocking: false,
      dueAtMillis: requestOpenedAtMillis(ordered[0]) + 24 * hourMillis,
      expiresAtMillis: event.data.endTime.toMillis(),
      destination: destination({
        route: "hostEventManage",
        section: "guests",
        eventId,
      }),
      context: context({
        eventName: displayEventName(event.data),
        count: ordered.length,
      }),
      dedupeKey: `eventJoinRequestReview:${eventId}`,
      assignedHostUid: null,
      sourceUpdatedAtMillis: Math.max(
        event.sourceUpdatedAtMillis,
        ...ordered.map((row) => row.sourceUpdatedAtMillis)
      ),
      nowMillis: params.nowMillis,
    }));
  }

  for (const row of params.sources.applications) {
    const application = row.data;
    if (application.reviewStatus !== "submitted" &&
        application.reviewStatus !== "inReview") continue;
    const eventId = application.targetKind === "event" ?
      application.targetId : null;
    items.push(buildItem({
      kind: "applicationReview",
      scope: "application",
      sourceOwner: "organizerApplications",
      sourceId: row.id,
      sourceRevision: String(application.revision),
      eventId,
      consequence: "delaysResponse",
      blocking: false,
      dueAtMillis: application.submittedAt.toMillis() + 24 * hourMillis,
      expiresAtMillis: null,
      destination: destination({
        route: "hostApplications",
        applicationId: row.id,
        eventId,
      }),
      context: context({subjectLabel: application.applicantDisplayName}),
      dedupeKey: `applicationReview:${row.id}`,
      assignedHostUid: application.assignedReviewerUid,
      sourceUpdatedAtMillis: row.sourceUpdatedAtMillis,
      nowMillis: params.nowMillis,
    }));
  }

  const latestProviderRuns = latestRows(
    params.sources.providerSyncRuns.filter((row) =>
      row.data.status !== "running" &&
      row.data.expiresAt.toMillis() > params.nowMillis &&
      activeEventsById.has(row.data.eventId)
    ),
    (row) => row.data.eventId,
    providerRunTime
  );
  for (const row of latestProviderRuns.values()) {
    const run = row.data;
    if (run.status !== "partial" && run.status !== "failed") continue;
    const event = activeEvents.find((candidate) =>
      candidate.id === run.eventId);
    items.push(buildItem({
      kind: "providerSyncFailure",
      scope: "event",
      sourceOwner: "providerSyncRuns",
      sourceId: row.id,
      sourceRevision: revisionOf({
        runId: row.id,
        inputHash: run.inputHash,
        status: run.status,
        completedAtMillis: run.completedAt?.toMillis() ?? null,
      }),
      eventId: run.eventId,
      consequence: "requiresReconciliation",
      blocking: false,
      dueAtMillis: providerRunTime(row),
      expiresAtMillis: run.expiresAt.toMillis(),
      destination: destination({
        route: "hostEventManage",
        section: "guests",
        eventId: run.eventId,
      }),
      context: context({
        eventName: event ? displayEventName(event.data) : null,
        provider: run.provider,
        errorCode: run.errorCode,
      }),
      dedupeKey: `providerSyncFailure:${run.eventId}`,
      assignedHostUid: null,
      sourceUpdatedAtMillis: row.sourceUpdatedAtMillis,
      nowMillis: params.nowMillis,
    }));
  }

  const enabledRules = new Map(params.sources.automationRules
    .filter((row) => row.data.enabled)
    .map((row) => [automationRuleKey(
      row.data.formId,
      row.id,
      row.data.revision
    ), row]));
  const latestAutomationRuns = latestRows(
    params.sources.automationRuns.filter((row) =>
      row.data.status !== "pending" && row.data.status !== "running" &&
      enabledRules.has(automationRuleKey(
        row.data.formId,
        row.data.ruleId,
        row.data.ruleRevision
      ))
    ),
    (row) => automationRuleKey(
      row.data.formId,
      row.data.ruleId,
      row.data.ruleRevision
    ),
    (row) => row.data.updatedAt.toMillis()
  );
  for (const [key, row] of latestAutomationRuns) {
    const run = row.data;
    if (run.status !== "partiallyFailed" && run.status !== "failed") {
      continue;
    }
    const rule = enabledRules.get(key);
    if (!rule) continue;
    items.push(buildItem({
      kind: "formAutomationFailure",
      scope: run.formId ? "form" : "organizer",
      sourceOwner: "organizerFormAutomationRuns",
      sourceId: row.id,
      sourceRevision: revisionOf({
        runId: row.id,
        ruleRevision: run.ruleRevision,
        status: run.status,
        updatedAtMillis: run.updatedAt.toMillis(),
      }),
      eventId: null,
      consequence: "degradesAutomation",
      blocking: false,
      dueAtMillis: run.updatedAt.toMillis(),
      expiresAtMillis: null,
      destination: destination({
        route: "hostAudienceForms",
        section: "automations",
        formId: run.formId,
      }),
      context: context({
        subjectLabel: rule.data.name,
        errorCode: run.errorCode,
      }),
      dedupeKey: `formAutomationFailure:${run.formId}:${run.ruleId}`,
      assignedHostUid: null,
      sourceUpdatedAtMillis: Math.max(
        row.sourceUpdatedAtMillis,
        rule.sourceUpdatedAtMillis
      ),
      nowMillis: params.nowMillis,
    }));
  }

  items.push(...derivePayoutItems({
    organizerId: params.organizerId,
    nowMillis: params.nowMillis,
    organizer: params.sources.organizer,
    activeEvents,
    paymentAccounts: params.sources.paymentAccounts,
  }));

  return items.sort(compareAttentionItems);
}

/** Returns a stable coverage row for every catalog kind, including gaps. */
export function hostAttentionCoverage(): HostAttentionCoverage[] {
  return hostAttentionPolicyCatalog.definitions.map((definition) => ({
    kind: definition.kind,
    state: coverageState(definition.deliveryMode),
    reason: definition.readinessReason,
  }));
}

function derivePayoutItems(params: {
  organizerId: string;
  nowMillis: number;
  organizer: AttentionSourceRow<OrganizerDocument>;
  activeEvents: Array<AttentionSourceRow<EventDocument>>;
  paymentAccounts: OrganizerAttentionSources["paymentAccounts"];
}): DesiredHostAttentionItem[] {
  const paidByProvider = new Map<
    HostPaymentProvider,
    Array<AttentionSourceRow<EventDocument>>
  >();
  for (const row of params.activeEvents) {
    if (row.data.priceInPaise <= 0) continue;
    const provider = paymentProviderForCurrency(row.data.currency);
    const rows = paidByProvider.get(provider) ?? [];
    rows.push(row);
    paidByProvider.set(provider, rows);
  }
  const organizer = params.organizer.data;
  const ownerUid = organizer.ownership?.ownerUserId ??
    organizer.ownerUserId ?? organizer.hostUserId ?? null;
  const items: DesiredHostAttentionItem[] = [];
  for (const [provider, events] of paidByProvider) {
    const account = params.paymentAccounts[provider];
    if (account && paymentAccountReady(account.data)) continue;
    const ordered = [...events].sort((left, right) =>
      left.data.startTime.toMillis() - right.data.startTime.toMillis());
    const earliest = ordered[0];
    const earliestStartMillis = earliest.data.startTime.toMillis();
    const affectedEndMillis = Math.max(...ordered.map((row) =>
      row.data.endTime.toMillis()));
    items.push(buildItem({
      kind: "payoutSetup",
      scope: "account",
      sourceOwner: "hostPaymentAccounts",
      sourceId: `${ownerUid ?? params.organizerId}:${provider}`,
      sourceRevision: revisionOf({
        ownerUid,
        provider,
        account: account ? {
          id: account.id,
          chargesEnabled: account.data.chargesEnabled,
          payoutsEnabled: account.data.payoutsEnabled,
          detailsSubmitted: account.data.detailsSubmitted,
          onboardingStatus: account.data.onboardingStatus,
          requirementsCurrentlyDue: account.data.requirementsCurrentlyDue,
          requirementsPastDue: account.data.requirementsPastDue,
          updatedAtMillis: account.data.updatedAt.toMillis(),
        } : null,
        events: ordered.map((row) => ({
          id: row.id,
          startMillis: row.data.startTime.toMillis(),
          endMillis: row.data.endTime.toMillis(),
          priceInPaise: row.data.priceInPaise,
          currency: row.data.currency ?? "INR",
        })),
      }),
      eventId: earliest.id,
      consequence: "risksRevenue",
      blocking: true,
      dueAtMillis:
        earliestStartMillis - hostAttentionPolicyCatalog.soonHours * hourMillis,
      expiresAtMillis: affectedEndMillis,
      destination: destination({route: "hostOrganizerPayments"}),
      context: context({
        eventName: displayEventName(earliest.data),
        count: ordered.length,
        provider,
      }),
      dedupeKey: `payoutSetup:${params.organizerId}:${provider}`,
      assignedHostUid: ownerUid,
      sourceUpdatedAtMillis: Math.max(
        params.organizer.sourceUpdatedAtMillis,
        account?.sourceUpdatedAtMillis ?? 0,
        ...ordered.map((row) => row.sourceUpdatedAtMillis)
      ),
      nowMillis: params.nowMillis,
    }));
  }
  return items;
}

function buildItem(params: Omit<
  DesiredHostAttentionItem,
  | "attentionId"
  | "status"
  | "urgency"
  | "policyVersion"
  | "resolutionVersion"
  | "openedAtMillis"
> & {nowMillis: number}): DesiredHostAttentionItem {
  return {
    attentionId: attentionId(params.dedupeKey),
    kind: params.kind,
    scope: params.scope,
    sourceOwner: params.sourceOwner,
    sourceId: params.sourceId,
    sourceRevision: params.sourceRevision,
    eventId: params.eventId,
    status: "open",
    consequence: params.consequence,
    blocking: params.blocking,
    urgency: urgencyFor(params.dueAtMillis, params.nowMillis),
    destination: params.destination,
    context: params.context,
    dedupeKey: params.dedupeKey,
    policyVersion: hostAttentionPolicyCatalog.policyVersion,
    resolutionVersion: 1,
    assignedHostUid: params.assignedHostUid,
    openedAtMillis: params.nowMillis,
    dueAtMillis: params.dueAtMillis,
    expiresAtMillis: params.expiresAtMillis,
    sourceUpdatedAtMillis: params.sourceUpdatedAtMillis,
  };
}

function destination(values: Partial<HostAttentionItem["destination"]> & {
  route: HostAttentionItem["destination"]["route"];
}): HostAttentionItem["destination"] {
  return {
    route: values.route,
    section: values.section ?? null,
    eventId: values.eventId ?? null,
    applicationId: values.applicationId ?? null,
    formId: values.formId ?? null,
    threadId: values.threadId ?? null,
  };
}

function context(
  values: Partial<HostAttentionItem["context"]>
): HostAttentionItem["context"] {
  return {
    eventName: values.eventName ?? null,
    subjectLabel: values.subjectLabel ?? null,
    count: values.count ?? null,
    provider: values.provider ?? null,
    errorCode: values.errorCode ?? null,
  };
}

function latestRows<T>(
  rows: Array<AttentionSourceRow<T>>,
  keyOf: (row: AttentionSourceRow<T>) => string,
  timeOf: (row: AttentionSourceRow<T>) => number
): Map<string, AttentionSourceRow<T>> {
  const latest = new Map<string, AttentionSourceRow<T>>();
  for (const row of rows) {
    const key = keyOf(row);
    const existing = latest.get(key);
    if (!existing || timeOf(row) > timeOf(existing) ||
        timeOf(row) === timeOf(existing) && row.id > existing.id) {
      latest.set(key, row);
    }
  }
  return latest;
}

function providerRunTime(
  row: AttentionSourceRow<ProviderSyncRunDocument>
): number {
  return row.data.completedAt?.toMillis() ?? row.data.startedAt.toMillis();
}

function requestOpenedAtMillis(
  row: AttentionSourceRow<EventParticipationDocument>
): number {
  return row.data.waitlistedAt?.toMillis() ?? row.data.createdAt.toMillis();
}

function automationRuleKey(
  formId: string | null,
  ruleId: string,
  revision: number
): string {
  return `${formId}:${ruleId}:${revision}`;
}

function paymentProviderForCurrency(
  currency: string | undefined
): HostPaymentProvider {
  return (currency ?? "INR").toUpperCase() === "INR" ?
    "razorpay" : "stripe";
}

function paymentAccountReady(account: HostPaymentAccountDocument): boolean {
  return account.chargesEnabled && account.payoutsEnabled &&
    account.detailsSubmitted && account.onboardingStatus === "complete" &&
    account.requirementsCurrentlyDue.length === 0 &&
    account.requirementsPastDue.length === 0;
}

function displayEventName(event: EventDocument): string {
  return event.name?.trim() || event.meetingPoint;
}

function urgencyFor(
  dueAtMillis: number,
  nowMillis: number
): HostAttentionItem["urgency"] {
  const remaining = dueAtMillis - nowMillis;
  if (remaining <= immediateMillis) return "immediate";
  if (remaining <= soonMillis) return "soon";
  return "upcoming";
}

function compareAttentionItems(
  left: DesiredHostAttentionItem,
  right: DesiredHostAttentionItem
): number {
  const rank = {immediate: 0, soon: 1, upcoming: 2} as const;
  return rank[left.urgency] - rank[right.urgency] ||
    Number(right.blocking) - Number(left.blocking) ||
    left.dueAtMillis - right.dueAtMillis ||
    left.attentionId.localeCompare(right.attentionId);
}

function coverageState(
  mode: typeof hostAttentionPolicyCatalog.definitions[number]["deliveryMode"]
): HostAttentionCoverage["state"] {
  switch (mode) {
  case "serverProjected": return "complete";
  case "clientMerged": return "clientMergeRequired";
  case "shortcutOnly": return "shortcutOnly";
  case "blockedMissingTruth": return "blockedMissingTruth";
  }
}

function attentionId(dedupeKey: string): string {
  return `attention_${createHash("sha256").update(dedupeKey)
    .digest("hex").slice(0, 40)}`;
}

function revisionOf(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value))
    .digest("hex");
}
