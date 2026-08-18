import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {appCheckCallableOptionsWithLimits} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {createActivityForActiveUserIfAbsent} from
  "../shared/notifications";
import {CreateOrganizerFormAutomationCallablePayload} from
  "../shared/generated/createOrganizerFormAutomationCallablePayload";
import {CreateOrganizerFormAutomationCallableResponse} from
  "../shared/generated/createOrganizerFormAutomationCallableResponse";
import {
  ClubDocument,
  OrganizerContactDocument,
  OrganizerContactTagVocabularyDocument,
  OrganizerDocument,
  OrganizerFormAutomationRuleDocument,
  OrganizerFormAutomationRunDocument,
  OrganizerFormDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {ListOrganizerFormAutomationRunsCallablePayload} from
  "../shared/generated/listOrganizerFormAutomationRunsCallablePayload";
import {ListOrganizerFormAutomationRunsCallableResponse} from
  "../shared/generated/listOrganizerFormAutomationRunsCallableResponse";
import {SetOrganizerFormAutomationStateCallablePayload} from
  "../shared/generated/setOrganizerFormAutomationStateCallablePayload";
import {SetOrganizerFormAutomationStateCallableResponse} from
  "../shared/generated/setOrganizerFormAutomationStateCallableResponse";
import {
  validateCreateOrganizerFormAutomationCallablePayload,
  validateListOrganizerFormAutomationRunsCallablePayload,
  validateSetOrganizerFormAutomationStateCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {organizerContactIdentityKey} from "./organizerAudienceSecrets";
import {convertOrganizerFormResponseHandler} from
  "./organizerFormConversions";

type RuleProjection = CreateOrganizerFormAutomationCallableResponse;
type AutomationAction = OrganizerFormAutomationRuleDocument["actions"][number];
type AutomationCondition = NonNullable<
  OrganizerFormAutomationRuleDocument["condition"]>;
type AnswerValue = OrganizerFormResponseDocument["answers"][string];
type ActionResult = OrganizerFormAutomationRunDocument["actionResults"][number];
export type FormAutomationEventKind = "submitted" | "withdrawn";

interface AutomationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
  identitySecret: () => string;
}

const defaultDeps: AutomationDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
  identitySecret: () => organizerContactIdentityKey.value(),
};

const maxAutomationAttempts = 5;

interface RunCursor {
  version: 1;
  organizerId: string;
  formId: string;
  ruleId: string | null;
  createdAtMillis: number;
  runId: string;
}

/** Creates or replaces a revisioned rule and never returns webhook secrets. */
export async function createOrganizerFormAutomationHandler(
  request: CallableRequest<unknown>,
  deps: AutomationDeps = defaultDeps
): Promise<CreateOrganizerFormAutomationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    CreateOrganizerFormAutomationCallablePayload
  >(
    request,
    validateCreateOrganizerFormAutomationCallablePayload,
    normalizeCreateAutomationPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "createOrganizerFormAutomation");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const formSnap = await db.collection("organizerForms").doc(data.formId).get();
  if (!formSnap.exists) throw new HttpsError("not-found", "Form not found.");
  const form = requireDoc<OrganizerFormDocument>(
    formSnap,
    "OrganizerFormDocument"
  );
  if (form.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Form not found.");
  }
  const versionId = form.activeVersionId;
  if (!versionId) {
    throw new HttpsError(
      "failed-precondition",
      "Create or publish the form before adding automations."
    );
  }
  const versionSnap = await db.collection("organizerFormVersions")
    .doc(versionId).get();
  const version = requireDoc<OrganizerFormVersionDocument>(
    versionSnap,
    "OrganizerFormVersionDocument"
  );
  await validateAutomationInput(data, version, db);
  const ruleId = data.ruleId ?? deterministicId(
    "formrule",
    data.organizerId,
    data.formId,
    data.requestId
  );
  const ruleRef = db.collection("organizerFormAutomationRules").doc(ruleId);
  const rule = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ruleRef);
    const existing = snapshot.exists ?
      requireDoc<OrganizerFormAutomationRuleDocument>(
        snapshot,
        "OrganizerFormAutomationRuleDocument"
      ) : null;
    if (!existing && data.expectedRevision !== null) throw revisionConflict();
    if (existing && (existing.organizerId !== data.organizerId ||
        existing.formId !== data.formId)) {
      throw new HttpsError("not-found", "Automation not found.");
    }
    if (existing && data.ruleId === null && sameAutomation(existing, data)) {
      return existing;
    }
    if (existing && existing.revision !== data.expectedRevision) {
      throw revisionConflict();
    }
    const now = deps.timestamp();
    const actions = data.actions.map((action) => {
      const prior = existing?.actions.find((candidate) =>
        candidate.actionId === action.actionId);
      return action.kind === "signedWebhook" && !action.webhookSecret && prior ?
        {...action, webhookSecret: prior.webhookSecret} : action;
    });
    const updated: OrganizerFormAutomationRuleDocument = {
      organizerId: data.organizerId,
      formId: data.formId,
      name: data.name,
      enabled: data.enabled,
      revision: (existing?.revision ?? 0) + 1,
      trigger: data.trigger,
      condition: data.condition,
      actions,
      createdByUid: existing?.createdByUid ?? actorUid,
      updatedByUid: actorUid,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    };
    tx.set(ruleRef, updated);
    return updated;
  });
  return ruleProjection(ruleId, rule);
}

/** Enables or disables one rule under an optimistic revision guard. */
export async function setOrganizerFormAutomationStateHandler(
  request: CallableRequest<unknown>,
  deps: AutomationDeps = defaultDeps
): Promise<SetOrganizerFormAutomationStateCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    SetOrganizerFormAutomationStateCallablePayload
  >(
    request,
    validateSetOrganizerFormAutomationStateCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "ruleId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "setOrganizerFormAutomationState");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const ref = db.collection("organizerFormAutomationRules").doc(data.ruleId);
  const rule = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Automation not found.");
    }
    const current = requireDoc<OrganizerFormAutomationRuleDocument>(
      snapshot,
      "OrganizerFormAutomationRuleDocument"
    );
    if (current.organizerId !== data.organizerId) {
      throw new HttpsError("not-found", "Automation not found.");
    }
    if (current.revision !== data.expectedRevision) throw revisionConflict();
    const updated: OrganizerFormAutomationRuleDocument = {
      ...current,
      enabled: data.enabled,
      revision: current.revision + 1,
      updatedByUid: actorUid,
      updatedAt: deps.timestamp(),
    };
    tx.set(ref, updated);
    return updated;
  });
  return ruleProjection(data.ruleId, rule);
}

/** Lists bounded rule definitions and execution history. */
export async function listOrganizerFormAutomationRunsHandler(
  request: CallableRequest<unknown>,
  deps: AutomationDeps = defaultDeps
): Promise<ListOrganizerFormAutomationRunsCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    ListOrganizerFormAutomationRunsCallablePayload
  >(
    request,
    validateListOrganizerFormAutomationRunsCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["organizerId", "formId"],
      nullableStringFields: ["ruleId", "cursor"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "listOrganizerFormAutomationRuns");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const cursor = decodeRunCursor(data.cursor, data);
  let runQuery: FirebaseFirestore.Query = db
    .collection("organizerFormAutomationRuns")
    .where("organizerId", "==", data.organizerId)
    .where("formId", "==", data.formId)
    .orderBy("createdAt", "desc")
    .orderBy(admin.firestore.FieldPath.documentId(), "desc")
    .limit(data.limit + 1);
  if (data.ruleId) runQuery = runQuery.where("ruleId", "==", data.ruleId);
  if (cursor) {
    runQuery = runQuery.startAfter(
      admin.firestore.Timestamp.fromMillis(cursor.createdAtMillis),
      cursor.runId
    );
  }
  const [rules, runs] = await Promise.all([
    db.collection("organizerFormAutomationRules")
      .where("organizerId", "==", data.organizerId)
      .where("formId", "==", data.formId)
      .limit(100).get(),
    runQuery.get(),
  ]);
  const page = runs.docs.slice(0, data.limit);
  const last = page.at(-1);
  return {
    rules: rules.docs.map((doc) => ruleProjection(
      doc.id,
      doc.data() as OrganizerFormAutomationRuleDocument
    )),
    runs: page.map((doc) => runProjection(
      doc.id,
      doc.data() as OrganizerFormAutomationRunDocument
    )),
    nextCursor: runs.size > data.limit && last ? encodeRunCursor({
      version: 1,
      organizerId: data.organizerId,
      formId: data.formId,
      ruleId: data.ruleId,
      createdAtMillis: (last.data().createdAt as
        FirebaseFirestore.Timestamp).toMillis(),
      runId: last.id,
    }) : null,
  };
}

/** Dispatches matching rule revisions for one response state transition. */
export async function dispatchOrganizerFormAutomations(
  responseId: string,
  before: OrganizerFormResponseDocument | undefined,
  after: OrganizerFormResponseDocument | undefined,
  deps: AutomationDeps = defaultDeps
): Promise<void> {
  const response = after ?? before;
  const eventKind = formAutomationEventKind(before, after);
  if (!response || !eventKind) return;
  const rules = await deps.firestore()
    .collection("organizerFormAutomationRules")
    .where("organizerId", "==", response.organizerId)
    .where("formId", "==", response.formId)
    .where("enabled", "==", true)
    .limit(100).get();
  const executions = rules.docs.flatMap((doc) => {
    const rule = doc.data() as OrganizerFormAutomationRuleDocument;
    return automationMatches(rule, response, eventKind) ?
      [executeRule(responseId, response, eventKind, doc.id, rule, deps)] : [];
  });
  const settled = await Promise.allSettled(executions);
  const failure = settled.find((result) => result.status === "rejected");
  if (failure?.status === "rejected") throw failure.reason;
}

/** Returns only meaningful response lifecycle edges; drafts never execute. */
export function formAutomationEventKind(
  before: OrganizerFormResponseDocument | undefined,
  after: OrganizerFormResponseDocument | undefined
): FormAutomationEventKind | null {
  if (after?.status === "submitted" && before?.status !== "submitted") {
    return "submitted";
  }
  if (after?.status === "withdrawn" && before?.status === "submitted") {
    return "withdrawn";
  }
  return null;
}

/**
 * Keeps application-purpose forms compatible with the established Host
 * application queue without requiring every organizer to configure a rule.
 */
export async function projectApplicationPurposeResponse(
  responseId: string,
  before: OrganizerFormResponseDocument | undefined,
  after: OrganizerFormResponseDocument | undefined,
  deps: AutomationDeps = defaultDeps
): Promise<void> {
  const eventKind = formAutomationEventKind(before, after);
  if (!after || !eventKind) return;
  const versionSnap = await deps.firestore()
    .collection("organizerFormVersions")
    .doc(after.versionId)
    .get();
  if (!versionSnap.exists) return;
  const version = requireDoc<OrganizerFormVersionDocument>(
    versionSnap,
    "OrganizerFormVersionDocument"
  );
  if (version.formId !== after.formId ||
      version.organizerId !== after.organizerId ||
      version.definition.purpose !== "application") {
    return;
  }
  if (eventKind === "withdrawn") {
    const applicationId = deterministicId("formapplication", responseId);
    const ref = deps.firestore().collection("organizerApplications")
      .doc(applicationId);
    await deps.firestore().runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      if (!snapshot.exists) return;
      const application = snapshot.data() as {reviewStatus?: string};
      if (application.reviewStatus === "withdrawn") return;
      tx.update(ref, {
        reviewStatus: "withdrawn",
        updatedAt: deps.timestamp(),
      });
    });
    return;
  }
  const request = {
    data: {
      organizerId: after.organizerId,
      responseId,
      kind: "application",
      eventId: null,
      overrides: {},
      requestId: `application_projection_${responseId}`,
    },
    auth: {uid: "system_form_application_projection", token: {}},
  } as unknown as CallableRequest<unknown>;
  const result = await convertOrganizerFormResponseHandler(request, {
    firestore: deps.firestore,
    checkRateLimit: async () => undefined,
    timestamp: deps.timestamp,
    identitySecret: deps.identitySecret,
    requireManagerAuthority: false,
  });
  if (result.status !== "completed") {
    throw new Error("Application response projection did not complete.");
  }
}

async function executeRule(
  responseId: string,
  response: OrganizerFormResponseDocument,
  eventKind: "submitted" | "withdrawn",
  ruleId: string,
  rule: OrganizerFormAutomationRuleDocument,
  deps: AutomationDeps
): Promise<void> {
  const db = deps.firestore();
  const runId = deterministicId(
    "formrun",
    ruleId,
    String(rule.revision),
    responseId,
    eventKind
  );
  const ref = db.collection("organizerFormAutomationRuns").doc(runId);
  const run = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    const current = snapshot.exists ?
      requireDoc<OrganizerFormAutomationRunDocument>(
        snapshot,
        "OrganizerFormAutomationRunDocument"
      ) : null;
    if (current?.status === "succeeded" ||
        (current?.attemptCount ?? 0) >= maxAutomationAttempts) return null;
    const now = deps.timestamp();
    const updated: OrganizerFormAutomationRunDocument = current ? {
      ...current,
      status: "running",
      attemptCount: current.attemptCount + 1,
      errorCode: null,
      errorMessage: null,
      updatedAt: now,
      completedAt: null,
    } : {
      organizerId: response.organizerId,
      formId: response.formId,
      ruleId,
      ruleRevision: rule.revision,
      responseId,
      eventKind,
      status: "running",
      attemptCount: 1,
      actionResults: [],
      errorCode: null,
      errorMessage: null,
      createdAt: now,
      updatedAt: now,
      completedAt: null,
    };
    tx.set(ref, updated);
    return updated;
  });
  if (!run) return;
  const results = [...run.actionResults];
  for (const action of rule.actions) {
    if (results.some((result) => result.actionId === action.actionId &&
        (result.status === "succeeded" || result.status === "skipped"))) {
      continue;
    }
    const result = await runAction({
      db,
      deps,
      runId,
      responseId,
      response,
      rule,
      action,
    });
    replaceActionResult(results, result);
    await ref.update({actionResults: results, updatedAt: deps.timestamp()});
  }
  const failed = results.filter((result) => result.status === "failed");
  const skipped = results.filter((result) => result.status === "skipped");
  const now = deps.timestamp();
  await ref.update({
    status: failed.length ?
      failed.length === results.length ? "failed" : "partiallyFailed" :
      skipped.length === results.length ? "skipped" : "succeeded",
    errorCode: failed.length ? "action_failed" : null,
    errorMessage: failed.length ?
      `${failed.length} automation action(s) need attention.` : null,
    updatedAt: now,
    completedAt: now,
  });
  if (failed.length && run.attemptCount < maxAutomationAttempts) {
    throw new Error("One or more form automation actions failed.");
  }
}

async function runAction(params: {
  db: FirebaseFirestore.Firestore;
  deps: AutomationDeps;
  runId: string;
  responseId: string;
  response: OrganizerFormResponseDocument;
  rule: OrganizerFormAutomationRuleDocument;
  action: AutomationAction;
}): Promise<ActionResult> {
  if (params.action.kind === "signedWebhook") {
    return actionResult(params.action, "skipped", null, "approval_required");
  }
  try {
    let resultId: string | null;
    switch (params.action.kind) {
    case "notifyTeam": resultId = await notifyTeam(params); break;
    case "createCrmContact":
      resultId = await convert(params, "crmContact", null); break;
    case "addApplicationQueue":
      resultId = await convert(params, "application", null); break;
    case "proposeEventAttendee":
      resultId = await convert(
        params,
        "eventAttendeeProposal",
        params.action.eventId
      );
      break;
    case "campaignHandoff":
      resultId = await convert(params, "followUp", null); break;
    case "addOrganizerTag": resultId = await addTag(params); break;
    default: resultId = null;
    }
    return actionResult(params.action, "succeeded", resultId, null);
  } catch (error) {
    return actionResult(params.action, "failed", null, errorCode(error));
  }
}

async function notifyTeam(params: {
  db: FirebaseFirestore.Firestore;
  runId: string;
  response: OrganizerFormResponseDocument;
}): Promise<string> {
  const [organizerSnap, clubSnap] = await Promise.all([
    params.db.collection("organizers").doc(params.response.organizerId).get(),
    params.db.collection("clubs").doc(params.response.organizerId).get(),
  ]);
  const organizer = organizerSnap.exists ?
    organizerSnap.data() as OrganizerDocument :
    clubSnap.data() as ClubDocument | undefined;
  const uids = [...new Set([
    ...(organizer?.hostUserIds ?? []),
    ...organizer?.ownerUserId ? [organizer.ownerUserId] : [],
  ])];
  await Promise.all(uids.map((uid) => createActivityForActiveUserIfAbsent(
    params.db,
    {
      id: `formResponse_${params.runId}_${uid}`,
      uid,
      type: "formResponse",
      title: "New form response",
      body: "A respondent submitted a form.",
      organizerId: params.response.organizerId,
      createdAt: admin.firestore.Timestamp.now(),
    }
  )));
  return `team_notification_${params.runId}`;
}

async function convert(
  params: {
    deps: AutomationDeps;
    runId: string;
    responseId: string;
    response: OrganizerFormResponseDocument;
    rule: OrganizerFormAutomationRuleDocument;
  },
  kind: "crmContact" | "application" | "eventAttendeeProposal" | "followUp",
  eventId: string | null
): Promise<string | null> {
  const request = {
    data: {
      organizerId: params.response.organizerId,
      responseId: params.responseId,
      kind,
      eventId,
      overrides: {},
      requestId: `autorun_${params.runId}`,
    },
    auth: {uid: params.rule.createdByUid, token: {}},
  } as unknown as CallableRequest<unknown>;
  const result = await convertOrganizerFormResponseHandler(request, {
    firestore: params.deps.firestore,
    checkRateLimit: async () => undefined,
    timestamp: params.deps.timestamp,
    identitySecret: params.deps.identitySecret,
  });
  if (result.status !== "completed") {
    throw new Error("The reviewed form conversion did not complete.");
  }
  return result.resultId;
}

async function addTag(params: {
  db: FirebaseFirestore.Firestore;
  deps: AutomationDeps;
  runId: string;
  responseId: string;
  response: OrganizerFormResponseDocument;
  rule: OrganizerFormAutomationRuleDocument;
  action: AutomationAction;
}): Promise<string> {
  if (!params.action.tagId) throw new Error("Automation tag is missing.");
  const contactId = await convert(params, "crmContact", null);
  if (!contactId) throw new Error("CRM contact was not created.");
  const contactRef = params.db.collection("organizerContacts").doc(contactId);
  const vocabularyRef = params.db.collection("organizerContactTagVocabularies")
    .doc(params.response.organizerId);
  await params.db.runTransaction(async (tx) => {
    const [contactSnap, vocabularySnap] = await Promise.all([
      tx.get(contactRef),
      tx.get(vocabularyRef),
    ]);
    const contact = requireDoc<OrganizerContactDocument>(
      contactSnap,
      "OrganizerContactDocument"
    );
    const vocabulary = requireDoc<OrganizerContactTagVocabularyDocument>(
      vocabularySnap,
      "OrganizerContactTagVocabularyDocument"
    );
    if (contact.organizerId !== params.response.organizerId ||
        !vocabulary.tags.some((tag) => tag.tagId === params.action.tagId)) {
      throw new Error("Automation tag is unavailable.");
    }
    const manualTagIds = [...new Set([
      ...(contact.manualTagIds ?? []),
      params.action.tagId!,
    ])];
    if (manualTagIds.length > 5) {
      throw new Error("This contact already has the maximum number of tags.");
    }
    const now = params.deps.timestamp();
    tx.update(contactRef, {
      manualTagIds,
      revision: Math.max(contact.revision + 1, now.toMillis()),
      updatedAt: now,
    });
  });
  return contactId;
}

async function validateAutomationInput(
  data: CreateOrganizerFormAutomationCallablePayload,
  version: OrganizerFormVersionDocument,
  db: FirebaseFirestore.Firestore
): Promise<void> {
  if (data.trigger === "answerMatches" && !data.condition) {
    throw new HttpsError(
      "invalid-argument",
      "Answer-matching automations need a condition."
    );
  }
  if (data.trigger !== "answerMatches" && data.condition) {
    throw new HttpsError(
      "invalid-argument",
      "Only answer-matching automations can include a condition."
    );
  }
  const questionIds = new Set(version.definition.sections.flatMap((section) =>
    section.questions.map((question) => question.questionId)));
  if (data.condition && !questionIds.has(data.condition.questionId)) {
    throw new HttpsError(
      "invalid-argument",
      "The automation condition references a missing question."
    );
  }
  for (const action of data.actions) {
    if (action.kind === "signedWebhook") {
      if (!action.webhookUrl || !isPublicHttpsSyntax(action.webhookUrl)) {
        throw new HttpsError(
          "invalid-argument",
          "Add a public HTTPS webhook URL on port 443."
        );
      }
      if (!action.webhookSecret && !data.ruleId) {
        throw new HttpsError(
          "invalid-argument",
          "New webhooks need a signing secret."
        );
      }
    } else if (action.webhookUrl || action.webhookSecret) {
      throw new HttpsError(
        "invalid-argument",
        "Webhook settings belong only to a signed webhook action."
      );
    }
    if (action.kind === "addOrganizerTag") {
      const vocabulary = (await db
        .collection("organizerContactTagVocabularies")
        .doc(data.organizerId).get()).data() as
        OrganizerContactTagVocabularyDocument | undefined;
      if (!action.tagId ||
          !vocabulary?.tags.some((tag) => tag.tagId === action.tagId)) {
        throw new HttpsError("invalid-argument", "Organizer tag not found.");
      }
    } else if (action.tagId) {
      throw new HttpsError(
        "invalid-argument",
        "Tag settings belong only to an organizer tag action."
      );
    }
    if (action.kind === "proposeEventAttendee") {
      const event = action.eventId ?
        (await db.collection("events").doc(action.eventId).get()).data() : null;
      if (!event || event.organizerId !== data.organizerId &&
          event.clubId !== data.organizerId) {
        throw new HttpsError("invalid-argument", "Event not found.");
      }
    } else if (action.eventId) {
      throw new HttpsError(
        "invalid-argument",
        "Event settings belong only to an attendee proposal action."
      );
    }
    if (action.kind === "campaignHandoff" && !action.channel) {
      throw new HttpsError("invalid-argument", "Choose email or WhatsApp.");
    }
  }
}

function isPublicHttpsSyntax(value: string): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "https:" && !url.username && !url.password &&
      (!url.port || url.port === "443") &&
      url.hostname !== "localhost" && url.hostname !== "127.0.0.1" &&
      url.hostname !== "::1";
  } catch {
    return false;
  }
}

function automationMatches(
  rule: OrganizerFormAutomationRuleDocument,
  response: OrganizerFormResponseDocument,
  eventKind: "submitted" | "withdrawn"
): boolean {
  if (rule.trigger === "responseSubmitted") return eventKind === "submitted";
  if (rule.trigger === "responseWithdrawn") return eventKind === "withdrawn";
  return eventKind === "submitted" && rule.condition !== null &&
    conditionMatches(rule.condition, response.answers);
}

function conditionMatches(
  condition: AutomationCondition,
  answers: OrganizerFormResponseDocument["answers"]
): boolean {
  const answer = answers[condition.questionId];
  const values = Array.isArray(answer) ? answer : [answer];
  const expected = condition.expectedValues;
  switch (condition.operator) {
  case "answered": return !isEmptyAnswer(answer);
  case "notAnswered": return isEmptyAnswer(answer);
  case "equals": return expected.some((value) => answer === value);
  case "notEquals": return expected.every((value) => answer !== value);
  case "contains": return expected.some((value) => values.includes(value));
  case "notContains":
    return expected.every((value) => !values.includes(value));
  case "greaterThan":
    return typeof answer === "number" && typeof expected[0] === "number" &&
      answer > expected[0];
  case "lessThan":
    return typeof answer === "number" && typeof expected[0] === "number" &&
      answer < expected[0];
  }
}

function isEmptyAnswer(value: AnswerValue | undefined): boolean {
  return value === undefined || value === null || value === "" ||
    Array.isArray(value) && value.length === 0;
}

function actionResult(
  action: AutomationAction,
  status: ActionResult["status"],
  resultId: string | null,
  code: string | null
): ActionResult {
  return {actionId: action.actionId, kind: action.kind, status, resultId,
    errorCode: code};
}

function replaceActionResult(
  results: OrganizerFormAutomationRunDocument["actionResults"],
  result: ActionResult
): void {
  const index = results.findIndex((candidate) =>
    candidate.actionId === result.actionId);
  if (index >= 0) results[index] = result;
  else results.push(result);
}

function ruleProjection(
  ruleId: string,
  rule: OrganizerFormAutomationRuleDocument
): RuleProjection {
  return {
    ruleId,
    organizerId: rule.organizerId,
    formId: rule.formId,
    name: rule.name,
    enabled: rule.enabled,
    revision: rule.revision,
    trigger: rule.trigger,
    condition: rule.condition,
    actions: rule.actions.map((action) => ({
      actionId: action.actionId,
      kind: action.kind,
      tagId: action.tagId,
      eventId: action.eventId,
      webhookUrl: action.webhookUrl,
      webhookSecretConfigured: Boolean(action.webhookSecret),
      channel: action.channel,
    })),
    updatedAtMillis: rule.updatedAt.toMillis(),
  };
}

function runProjection(
  runId: string,
  run: OrganizerFormAutomationRunDocument
): ListOrganizerFormAutomationRunsCallableResponse["runs"][number] {
  return {
    runId,
    ruleId: run.ruleId,
    ruleRevision: run.ruleRevision,
    responseId: run.responseId,
    eventKind: run.eventKind,
    status: run.status,
    attemptCount: run.attemptCount,
    actionResults: run.actionResults,
    errorMessage: run.errorMessage,
    createdAtMillis: run.createdAt.toMillis(),
    completedAtMillis: run.completedAt?.toMillis() ?? null,
  };
}

function sameAutomation(
  existing: OrganizerFormAutomationRuleDocument,
  data: CreateOrganizerFormAutomationCallablePayload
): boolean {
  return JSON.stringify({
    name: existing.name,
    enabled: existing.enabled,
    trigger: existing.trigger,
    condition: existing.condition,
    actions: existing.actions,
  }) === JSON.stringify({
    name: data.name,
    enabled: data.enabled,
    trigger: data.trigger,
    condition: data.condition,
    actions: data.actions,
  });
}

function normalizeCreateAutomationPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["organizerId", "formId", "requestId", "name"],
    nullableStringFields: ["ruleId"],
  });
}

function revisionConflict(): HttpsError {
  return new HttpsError(
    "aborted",
    "This automation changed on another device. Reload and try again."
  );
}

function errorCode(error: unknown): string {
  if (error instanceof HttpsError) return error.code.replaceAll("-", "_");
  return "action_failed";
}

function encodeRunCursor(cursor: RunCursor): string {
  return Buffer.from(JSON.stringify(cursor)).toString("base64url");
}

function decodeRunCursor(
  value: string | null,
  expected: Pick<RunCursor, "organizerId" | "formId" | "ruleId">
): RunCursor | null {
  if (!value) return null;
  try {
    const parsed = JSON.parse(Buffer.from(value, "base64url").toString()) as
      RunCursor;
    if (parsed.version !== 1 || parsed.organizerId !== expected.organizerId ||
        parsed.formId !== expected.formId ||
        parsed.ruleId !== expected.ruleId ||
        !Number.isInteger(parsed.createdAtMillis) || !parsed.runId) {
      throw new Error("invalid cursor");
    }
    return parsed;
  } catch {
    throw new HttpsError("invalid-argument", "Automation cursor is invalid.");
  }
}

function deterministicId(prefix: string, ...parts: string[]): string {
  const digest = createHash("sha256").update(parts.join("\u001f"))
    .digest("hex").slice(0, 32);
  return `${prefix}_${digest}`;
}

export const createOrganizerFormAutomation = onCall(
  appCheckCallableOptionsWithLimits({
    timeoutSeconds: 90,
    maxInstances: 20,
    concurrency: 10,
  }),
  (request) => createOrganizerFormAutomationHandler(request)
);

export const setOrganizerFormAutomationState = onCall(
  appCheckCallableOptionsWithLimits({
    timeoutSeconds: 60,
    maxInstances: 20,
    concurrency: 20,
  }),
  (request) => setOrganizerFormAutomationStateHandler(request)
);

export const listOrganizerFormAutomationRuns = onCall(
  appCheckCallableOptionsWithLimits({
    timeoutSeconds: 60,
    maxInstances: 20,
    concurrency: 20,
  }),
  (request) => listOrganizerFormAutomationRunsHandler(request)
);

export const onOrganizerFormResponseAutomated = onDocumentWritten(
  {
    document: "organizerFormResponses/{responseId}",
    retry: true,
    timeoutSeconds: 300,
    maxInstances: 20,
    secrets: [organizerContactIdentityKey],
  },
  async (event) => {
    const before = event.data?.before.data() as
      OrganizerFormResponseDocument | undefined;
    const after = event.data?.after.data() as
      OrganizerFormResponseDocument | undefined;
    await Promise.all([
      projectApplicationPurposeResponse(
        event.params.responseId,
        before,
        after
      ),
      dispatchOrganizerFormAutomations(
        event.params.responseId,
        before,
        after
      ),
    ]);
  }
);
