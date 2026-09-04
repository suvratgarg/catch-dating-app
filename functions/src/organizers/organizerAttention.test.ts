import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import type {
  EventDocument,
  EventParticipationDocument,
  HostPaymentAccountDocument,
  OrganizerApplicationDocument,
  OrganizerAttentionItemDocument,
  OrganizerDocument,
  OrganizerFormAutomationRuleDocument,
  OrganizerFormAutomationRunDocument,
  ProviderSyncRunDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  buildOrganizerAttentionProjectionPlan,
  listOrganizerAttentionItemsHandler,
  maxAttentionSourceRows,
} from "./organizerAttention";
import {
  AttentionSourceRow,
  deriveOrganizerAttentionItems,
  DesiredHostAttentionItem,
  hostAttentionCoverage,
  OrganizerAttentionSources,
} from "./organizerAttentionPolicy";

const nowMillis = Date.parse("2026-09-01T10:00:00.000Z");
const hourMillis = 60 * 60 * 1000;

test("derives independent source-ready server attention kinds", () => {
  const sources = sourceFixture();
  const items = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources,
  });

  assert.deepEqual(new Set(items.map((item) => item.kind)), new Set([
    "eventLiveOperations",
    "eventWaitlistReview",
    "applicationReview",
    "providerSyncFailure",
    "formAutomationFailure",
    "payoutSetup",
  ]));
  assert.equal(items.find((item) =>
    item.kind === "eventLiveOperations")?.blocking, true);
  assert.equal(items.find((item) =>
    item.kind === "eventWaitlistReview")?.context.count, 4);
  assert.equal(items.find((item) =>
    item.kind === "applicationReview")?.assignedHostUid, "reviewer-1");
  assert.equal(items.find((item) =>
    item.kind === "payoutSetup")?.context.provider, "razorpay");
  assert.deepEqual(
    [...items].sort(compareExpected).map((item) => item.attentionId),
    items.map((item) => item.attentionId)
  );
});

test("latest terminal outcomes resolve failures without weak proxies", () => {
  const base = sourceFixture();
  base.events[0].data = event({manualApprovalRequired: true});
  base.eventParticipations = [row(
    "event-1_requester-1",
    eventParticipation(),
    nowMillis - 25 * hourMillis
  )];
  base.paymentAccounts.razorpay = row(
    "owner-1_razorpay",
    paymentAccount({ready: true}),
    nowMillis
  );
  base.providerSyncRuns.push(
    row("provider-running", providerRun({
      status: "running",
      startedAtMillis: nowMillis - hourMillis,
    }), nowMillis - hourMillis)
  );

  let items = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources: base,
  });
  assert.equal(items.some((item) =>
    item.kind === "eventWaitlistReview"), false);
  assert.equal(items.find((item) =>
    item.kind === "eventJoinRequestReview")?.context.count, 1);
  assert.equal(items.some((item) =>
    item.kind === "providerSyncFailure"), true,
  "a running retry must not hide the latest failed terminal run");
  assert.equal(items.some((item) => item.kind === "payoutSetup"), false);

  base.providerSyncRuns.push(
    row("provider-success", providerRun({
      status: "completed",
      startedAtMillis: nowMillis,
    }), nowMillis)
  );
  base.automationRuns.push(
    row("automation-success", automationRun({
      status: "succeeded",
      updatedAtMillis: nowMillis,
    }), nowMillis)
  );
  items = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources: base,
  });
  assert.equal(items.some((item) =>
    item.kind === "providerSyncFailure"), false);
  assert.equal(items.some((item) =>
    item.kind === "formAutomationFailure"), false);

  base.automationRuns.pop();
  base.automationRules[0].data = automationRule({enabled: false});
  items = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources: base,
  });
  assert.equal(items.some((item) =>
    item.kind === "formAutomationFailure"), false);
});

test("applies the seven-day horizon and exposes all policy gaps", () => {
  const sources = emptySources();
  sources.events = [row("later-event", event({
    startMillis: nowMillis + 8 * 24 * hourMillis,
    endMillis: nowMillis + 8 * 24 * hourMillis + 2 * hourMillis,
    waitlistedCount: 8,
    priceInPaise: 0,
  }), nowMillis)];
  const items = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources,
  });
  assert.deepEqual(items, []);

  const coverage = hostAttentionCoverage();
  assert.equal(coverage.length, 15);
  assert.equal(new Set(coverage.map((entry) => entry.kind)).size, 15);
  assert.equal(coverage.find((entry) =>
    entry.kind === "attendanceSync")?.state, "clientMergeRequired");
  assert.equal(coverage.find((entry) =>
    entry.kind === "dressRehearsal")?.state, "shortcutOnly");
  for (const kind of [
    "eventSuccessPreparation",
    "roomLayoutSetup",
    "eventStaffing",
    "formResponseReview",
    "inboxReply",
    "postEventReconciliation",
  ]) {
    assert.equal(coverage.find((entry) =>
      entry.kind === kind)?.state, "blockedMissingTruth");
  }
});

test(
  "keeps schedule-derived deadlines stable after they become overdue",
  () => {
    const sources = sourceFixture();
    const first = deriveOrganizerAttentionItems({
      organizerId: "organizer-1",
      nowMillis,
      sources,
    });
    const later = deriveOrganizerAttentionItems({
      organizerId: "organizer-1",
      nowMillis: nowMillis + 2 * hourMillis,
      sources,
    });

    for (const kind of ["eventWaitlistReview", "payoutSetup"] as const) {
      const firstItem = first.find((item) => item.kind === kind);
      const laterItem = later.find((item) => item.kind === kind);
      assert.ok(firstItem);
      assert.ok(laterItem);
      assert.equal(laterItem.dueAtMillis, firstItem.dueAtMillis);
      assert.equal(laterItem.sourceRevision, firstItem.sourceRevision);
    }
  }
);

test("projection planning avoids no-op writes and resolves stale opens", () => {
  const desired = deriveOrganizerAttentionItems({
    organizerId: "organizer-1",
    nowMillis,
    sources: sourceFixture(),
  }).slice(0, 1);
  const first = buildOrganizerAttentionProjectionPlan({
    organizerId: "organizer-1",
    now: timestamp(nowMillis),
    desired,
    existing: new Map(),
    openIds: [],
  });
  assert.equal(first.sets.length, 1);
  assert.equal(first.sets[0].document.purgeAt, null);

  const existing = new Map<string, OrganizerAttentionItemDocument>([[
    desired[0].attentionId,
    first.sets[0].document,
  ]]);
  const noChange = buildOrganizerAttentionProjectionPlan({
    organizerId: "organizer-1",
    now: timestamp(nowMillis + hourMillis),
    desired,
    existing,
    openIds: [desired[0].attentionId],
  });
  assert.equal(noChange.sets.length, 0);
  assert.equal(noChange.resolutions.length, 0);
  assert.equal(noChange.response[0].openedAtMillis, nowMillis);

  const resolved = buildOrganizerAttentionProjectionPlan({
    organizerId: "organizer-1",
    now: timestamp(nowMillis + 2 * hourMillis),
    desired: [],
    existing,
    openIds: [desired[0].attentionId],
  });
  assert.equal(resolved.resolutions.length, 1);
  assert.equal(resolved.resolutions[0].patch.status, "resolved");
  assert.equal(resolved.resolutions[0].patch.resolutionVersion, 2);
  assert.equal(
    (resolved.resolutions[0].patch.purgeAt as
      FirebaseFirestore.Timestamp).toMillis(),
    nowMillis + 2 * hourMillis + 30 * 24 * hourMillis
  );

  const priorResolved = {
    ...first.sets[0].document,
    status: "resolved" as const,
    resolutionVersion: 2,
    resolvedAt: timestamp(nowMillis + hourMillis),
    purgeAt: timestamp(nowMillis + 31 * 24 * hourMillis),
  };
  const reopened = buildOrganizerAttentionProjectionPlan({
    organizerId: "organizer-1",
    now: timestamp(nowMillis + 3 * hourMillis),
    desired,
    existing: new Map([[desired[0].attentionId, priorResolved]]),
    openIds: [],
  });
  assert.equal(reopened.sets[0].document.resolutionVersion, 3);
  assert.equal(
    reopened.sets[0].document.openedAt.toMillis(),
    nowMillis + 3 * hourMillis
  );
});

test(
  "callable enforces authority, rate limit, and complete coverage",
  async () => {
    const actions: string[] = [];
    const result = await listOrganizerAttentionItemsHandler(request(), {
      firestore: () => ({}) as FirebaseFirestore.Firestore,
      checkRateLimit: async (_db, uid, action) => {
        assert.equal(uid, "manager-1");
        actions.push(action);
      },
      requireManager: async ({organizerId, actorUid}) => {
        assert.equal(organizerId, "organizer-1");
        assert.equal(actorUid, "manager-1");
      },
      timestamp: () => timestamp(nowMillis),
      loadSources: async () => sourceFixture(),
      reconcile: async (_db, organizerId, _now, desired) => {
        assert.equal(organizerId, "organizer-1");
        return desired.map(withoutSourceTimestamp);
      },
    });
    assert.deepEqual(actions, ["listOrganizerAttentionItems"]);
    assert.equal(result.generatedAtMillis, nowMillis);
    assert.equal(result.coverage.length, 15);
    assert.equal(result.items.length, 6);
  }
);

test("callable fails closed instead of returning a partial queue", async () => {
  const sources = emptySources();
  sources.applications = Array.from(
    {length: maxAttentionSourceRows + 1},
    (_, index) => row(
      `application-${index}`,
      application({name: `Applicant ${index}`}),
      nowMillis
    )
  );
  await assert.rejects(
    listOrganizerAttentionItemsHandler(request(), {
      firestore: () => ({}) as FirebaseFirestore.Firestore,
      checkRateLimit: async () => undefined,
      requireManager: async () => undefined,
      timestamp: () => timestamp(nowMillis),
      loadSources: async () => sources,
      reconcile: async () => {
        assert.fail("reconciliation must not run after an over-cap derivation");
      },
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "resource-exhausted"
  );
});

function sourceFixture(): OrganizerAttentionSources {
  const sources = emptySources();
  sources.events = [row("event-1", event(), nowMillis - hourMillis)];
  sources.applications = [row(
    "application-1",
    application(),
    nowMillis - 2 * hourMillis
  )];
  sources.providerSyncRuns = [row(
    "provider-failed",
    providerRun(),
    nowMillis - 2 * hourMillis
  )];
  sources.automationRules = [row(
    "rule-1",
    automationRule(),
    nowMillis - 3 * hourMillis
  )];
  sources.automationRuns = [row(
    "automation-failed",
    automationRun(),
    nowMillis - 2 * hourMillis
  )];
  return sources;
}

function emptySources(): OrganizerAttentionSources {
  return {
    organizer: row("organizer-1", organizer(), nowMillis - 10 * hourMillis),
    events: [],
    eventParticipations: [],
    applications: [],
    providerSyncRuns: [],
    automationRules: [],
    automationRuns: [],
    paymentAccounts: {},
  };
}

function event(overrides: {
  startMillis?: number;
  endMillis?: number;
  waitlistedCount?: number;
  manualApprovalRequired?: boolean;
  priceInPaise?: number;
} = {}): EventDocument {
  const startMillis = overrides.startMillis ?? nowMillis - hourMillis;
  const endMillis = overrides.endMillis ?? nowMillis + 3 * hourMillis;
  return {
    name: "Sunday Social Run",
    clubId: "organizer-1",
    organizerId: "organizer-1",
    startTime: timestamp(startMillis),
    endTime: timestamp(endMillis),
    meetingPoint: "Bandra promenade",
    capacityLimit: 40,
    constraints: {},
    priceInPaise: overrides.priceInPaise ?? 120000,
    currency: "INR",
    waitlistedCount: overrides.waitlistedCount ?? 4,
    status: "active",
    eventPolicy: {
      version: 2,
      admission: {
        format: overrides.manualApprovalRequired ? "manualApproval" : "open",
        capacityLimit: 40,
        manualApprovalRequired:
          overrides.manualApprovalRequired ?? false,
      },
      pricing: {basePriceInPaise: overrides.priceInPaise ?? 120000},
      cancellation: {policyId: "standard"},
      settlement: {hostPayoutTiming: "afterEventCompletion"},
    },
  } as unknown as EventDocument;
}

function organizer(): OrganizerDocument {
  return {
    name: "Saket Run Club",
    hostUserId: "owner-1",
    ownerUserId: "owner-1",
    hostUserIds: ["owner-1", "manager-1"],
    hostProfiles: [],
  } as unknown as OrganizerDocument;
}

function eventParticipation(): EventParticipationDocument {
  return {
    eventId: "event-1",
    clubId: "organizer-1",
    organizerId: "organizer-1",
    uid: "requester-1",
    status: "waitlisted",
    hostApprovalStatus: "pending",
    createdAt: timestamp(nowMillis - 26 * hourMillis),
    updatedAt: timestamp(nowMillis - 25 * hourMillis),
    waitlistedAt: timestamp(nowMillis - 26 * hourMillis),
  } as unknown as EventParticipationDocument;
}

function application(
  overrides: {name?: string} = {}
): OrganizerApplicationDocument {
  return {
    organizerId: "organizer-1",
    formId: "form-1",
    formVersionId: "form-1-v1",
    targetKind: "event",
    targetId: "event-1",
    applicantDisplayName: overrides.name ?? "Asha Singh",
    applicantDisplayNameNormalized: "asha singh",
    reviewStatus: "submitted",
    latestResponseId: "response-1",
    assignedReviewerUid: "reviewer-1",
    revision: 3,
    submittedAt: timestamp(nowMillis - 30 * hourMillis),
    updatedAt: timestamp(nowMillis - 2 * hourMillis),
  } as unknown as OrganizerApplicationDocument;
}

function providerRun(overrides: {
  status?: ProviderSyncRunDocument["status"];
  startedAtMillis?: number;
} = {}): ProviderSyncRunDocument {
  const startedAtMillis = overrides.startedAtMillis ??
    nowMillis - 2 * hourMillis;
  const terminal = overrides.status !== "running";
  return {
    organizerId: "organizer-1",
    eventId: "event-1",
    provider: "luma",
    inputHash: "a".repeat(64),
    status: overrides.status ?? "failed",
    errorCode: terminal ? "provider_timeout" : null,
    startedAt: timestamp(startedAtMillis),
    completedAt: terminal ? timestamp(startedAtMillis) : null,
    expiresAt: timestamp(nowMillis + 10 * 24 * hourMillis),
  } as unknown as ProviderSyncRunDocument;
}

function automationRule(overrides: {
  enabled?: boolean;
} = {}): OrganizerFormAutomationRuleDocument {
  return {
    organizerId: "organizer-1",
    formId: "form-1",
    name: "Add approved response to CRM",
    enabled: overrides.enabled ?? true,
    revision: 2,
  } as unknown as OrganizerFormAutomationRuleDocument;
}

function automationRun(overrides: {
  status?: OrganizerFormAutomationRunDocument["status"];
  updatedAtMillis?: number;
} = {}): OrganizerFormAutomationRunDocument {
  const updatedAtMillis = overrides.updatedAtMillis ??
    nowMillis - 2 * hourMillis;
  return {
    organizerId: "organizer-1",
    formId: "form-1",
    ruleId: "rule-1",
    ruleRevision: 2,
    status: overrides.status ?? "partiallyFailed",
    errorCode: "action_failed",
    createdAt: timestamp(updatedAtMillis),
    updatedAt: timestamp(updatedAtMillis),
    completedAt: timestamp(updatedAtMillis),
  } as unknown as OrganizerFormAutomationRunDocument;
}

function paymentAccount(params: {ready: boolean}): HostPaymentAccountDocument {
  return {
    userId: "owner-1",
    provider: "razorpay",
    chargesEnabled: params.ready,
    payoutsEnabled: params.ready,
    detailsSubmitted: params.ready,
    onboardingStatus: params.ready ? "complete" : "restricted",
    requirementsCurrentlyDue: params.ready ? [] : ["bank_account"],
    requirementsPastDue: [],
    requirementsPendingVerification: [],
    updatedAt: timestamp(nowMillis),
  } as unknown as HostPaymentAccountDocument;
}

function row<T>(
  id: string,
  data: T,
  sourceUpdatedAtMillis: number
): AttentionSourceRow<T> {
  return {id, data, sourceUpdatedAtMillis};
}

function timestamp(millis: number): FirebaseFirestore.Timestamp {
  return admin.firestore.Timestamp.fromMillis(millis);
}

function request(): CallableRequest<unknown> {
  return {
    data: {organizerId: " organizer-1 "},
    auth: {uid: "manager-1", token: {}},
  } as CallableRequest<unknown>;
}

function withoutSourceTimestamp(
  desired: DesiredHostAttentionItem
): Omit<DesiredHostAttentionItem, "sourceUpdatedAtMillis"> {
  const {sourceUpdatedAtMillis, ...item} = desired;
  void sourceUpdatedAtMillis;
  return item;
}

function compareExpected(
  left: DesiredHostAttentionItem,
  right: DesiredHostAttentionItem
): number {
  const rank = {immediate: 0, soon: 1, upcoming: 2} as const;
  return rank[left.urgency] - rank[right.urgency] ||
    Number(right.blocking) - Number(left.blocking) ||
    left.dueAtMillis - right.dueAtMillis ||
    left.attentionId.localeCompare(right.attentionId);
}
