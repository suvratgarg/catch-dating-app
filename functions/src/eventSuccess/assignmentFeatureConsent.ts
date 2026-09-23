import type {OrganizerFormResponseDocument as Response,
  OrganizerFormVersionDocument as Version,
  EventAssignmentFeatureConsentDocument as ConsentDoc} from
  "../shared/generated/firestoreAdminTypes";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {requireDoc} from "../shared/validation";
import {validateEventAssignmentFeatureConsentDocument} from
  "../shared/generated/validators/eventAssignmentFeatureConsentDocument";
import type {AssignmentFeatureRule, AssignmentFeatureValue,
  EventAssignmentFeatureSnapshot} from "./assignmentFeatureScoring";
import {validateAssignmentFeatureRules} from "./assignmentFeatureScoring";

/** A participant decision is bound to one event and one immutable answer. */
export interface AssignmentFeatureConsentDecision {
  eventId: string;
  organizerId: string;
  uid: string;
  responseId: string;
  featureId: string;
  formId: string;
  versionId: string;
  questionId: string;
  transformVersion: number;
  purpose: "eventAssignmentMatching";
  status: "granted" | "withdrawn";
  receiptId: string;
}

/** Stable event/subject/feature key; no answer material appears in paths. */
export function assignmentFeatureConsentId(
  eventId: string, uid: string, featureId: string
): string {
  return "afc_" + createHash("sha256").update(
    [eventId, uid, featureId].join("|"))
    .digest("hex").slice(0, 48);
}

/** Host mappings must name an exact published custom-answer source. */
export function assignmentFeatureRuleMatchesVersion(
  rule: AssignmentFeatureRule,
  versionId: string,
  version: Version,
  organizerId: string
): boolean {
  if (versionId !== rule.versionId || version.formId !== rule.formId ||
      version.organizerId !== organizerId) return false;
  const question = version.definition.sections.flatMap((section) =>
    section.questions).find((item) => item.questionId === rule.questionId);
  if (!question || question.privacyClass !== "organizerCustom") return false;
  if (rule.kind === "number") return question.kind === "number";
  if (rule.kind === "set" ? question.kind !== "multiChoice" :
    question.kind !== "singleChoice") return false;
  const expected = question.options.map((option) => option.optionId).sort();
  const configured = [...(rule.optionIds ?? [])].sort();
  return expected.length > 0 && expected.length === configured.length &&
    expected.every((id, index) => id === configured[index]);
}

/** Reads only current, participant-granted answers for the eligible pool. */
export async function loadAuthorizedAssignmentFeatures(params: {
  db: FirebaseFirestore.Firestore;
  eventId: string;
  organizerId: string;
  eligibleUids: string[];
  rules: AssignmentFeatureRule[];
}): Promise<EventAssignmentFeatureSnapshot[]> {
  const {db, eventId, organizerId} = params;
  const rules = validateAssignmentFeatureRules(params.rules);
  if (rules.length === 0 || params.eligibleUids.length === 0) return [];
  const eligible = new Set(params.eligibleUids);
  if (eligible.size > 1000) {
    throw new Error("Assignment feature pool exceeds supported cohort.");
  }
  const byFeature = new Map(rules.map((rule) => [rule.featureId, rule]));
  const selected: Array<{decision: AssignmentFeatureConsentDecision;
    rule: AssignmentFeatureRule}> = [];
  const refs = [...eligible].flatMap((uid) => rules.map((rule) =>
    db.collection("eventAssignmentFeatureConsents").doc(
      assignmentFeatureConsentId(eventId, uid, rule.featureId))));
  for (let offset = 0; offset < refs.length; offset += 200) {
    const snaps = await db.getAll(...refs.slice(offset, offset + 200));
    for (const snap of snaps) {
      if (!snap.exists) continue;
      const decision = readAssignmentFeatureConsent(snap);
      const rule = byFeature.get(decision.featureId);
      if (!rule || !eligible.has(decision.uid) ||
          snap.id !== assignmentFeatureConsentId(
            eventId, decision.uid, decision.featureId)) {
        throw new Error("Assignment feature consent is inconsistent.");
      }
      if (decision.status === "granted") selected.push({decision, rule});
    }
  }
  const versionSnaps = await Promise.all([...new Set(rules.map((rule) =>
    rule.versionId))].map((id) => db.collection("organizerFormVersions")
    .doc(id).get()));
  const versions = new Map(versionSnaps.filter((snap) => snap.exists)
    .map((snap) => [snap.id, requireDoc<Version>(snap,
      "OrganizerFormVersionDocument")]));
  const responseIds = [...new Set(selected.map((entry) =>
    entry.decision.responseId))];
  const responses = new Map<string, Response>();
  for (let offset = 0; offset < responseIds.length; offset += 200) {
    const refs = responseIds.slice(offset, offset + 200).map((id) =>
      db.collection("organizerFormResponses").doc(id));
    const snaps = await db.getAll(...refs);
    for (const snap of snaps) {
      if (snap.exists) {
        responses.set(snap.id, requireDoc<Response>(snap,
          "OrganizerFormResponseDocument"));
      }
    }
  }
  return selected.flatMap(({decision, rule}) => {
    const snapshot = authorizedAssignmentFeatureSnapshot({eventId,
      organizerId, uid: decision.uid, rule, decision,
      responseId: decision.responseId,
      response: responses.get(decision.responseId) ?? null,
      versionId: rule.versionId,
      version: versions.get(rule.versionId) ?? null});
    return snapshot ? [snapshot] : [];
  });
}

/** Publication reads current decisions and source state in the write txn. */
export async function recheckAssignmentFeatureSnapshots(params: {
  tx: FirebaseFirestore.Transaction;
  db: FirebaseFirestore.Firestore;
  eventId: string;
  organizerId: string;
  rules: AssignmentFeatureRule[];
  snapshots: EventAssignmentFeatureSnapshot[];
}): Promise<void> {
  const {tx, db, eventId, organizerId, rules, snapshots} = params;
  if (snapshots.length === 0) return;
  const byFeature = new Map(rules.map((rule) => [rule.featureId, rule]));
  const source = await Promise.all(snapshots.map(async (snapshot) => {
    const consentSnap = await tx.get(db.collection(
      "eventAssignmentFeatureConsents").doc(assignmentFeatureConsentId(
      eventId, snapshot.uid, snapshot.featureId)));
    if (!consentSnap.exists) throw changed();
    const decision = readAssignmentFeatureConsent(consentSnap);
    return {snapshot, decision};
  }));
  const uniqueResponseIds = [...new Set(source.map((item) =>
    item.decision.responseId))];
  const uniqueVersionIds = [...new Set(source.map((item) =>
    item.decision.versionId))];
  const [responseSnaps, versionSnaps] = await Promise.all([
    Promise.all(uniqueResponseIds.map((id) =>
      tx.get(db.collection("organizerFormResponses").doc(id)))),
    Promise.all(uniqueVersionIds.map((id) =>
      tx.get(db.collection("organizerFormVersions").doc(id)))),
  ]);
  const responses = new Map(responseSnaps.filter((snap) => snap.exists)
    .map((snap) => [snap.id, requireDoc<Response>(snap,
      "OrganizerFormResponseDocument")]));
  const versions = new Map(versionSnaps.filter((snap) => snap.exists)
    .map((snap) => [snap.id, requireDoc<Version>(snap,
      "OrganizerFormVersionDocument")]));
  for (const {snapshot, decision} of source) {
    const rule = byFeature.get(snapshot.featureId);
    if (!rule || decision.receiptId !== snapshot.consentReceiptId) {
      throw changed();
    }
    const current = authorizedAssignmentFeatureSnapshot({eventId,
      organizerId, uid: snapshot.uid, rule, decision,
      responseId: decision.responseId,
      response: responses.get(decision.responseId) ?? null,
      versionId: rule.versionId,
      version: versions.get(rule.versionId) ?? null});
    if (!current || JSON.stringify(current) !== JSON.stringify(snapshot)) {
      throw changed();
    }
  }
}

function changed(): HttpsError {
  return new HttpsError("aborted",
    "Matching consent or source changed before assignment publication.");
}

/** Parse private consent with the generated contract before using pointers. */
export function readAssignmentFeatureConsent(
  snap: FirebaseFirestore.DocumentSnapshot
): ConsentDoc {
  const value = snap.data();
  if (!validateEventAssignmentFeatureConsentDocument(value)) {
    throw new HttpsError("failed-precondition",
      "Matching consent record is invalid.");
  }
  return value as unknown as ConsentDoc;
}

/** Host rules and responses alone never grant answer use. */
export function authorizedAssignmentFeatureSnapshot(params: {
  eventId: string;
  organizerId: string;
  uid: string;
  rule: AssignmentFeatureRule;
  decision: AssignmentFeatureConsentDecision | null;
  responseId: string;
  response: Response | null;
  versionId: string;
  version: Version | null;
}): EventAssignmentFeatureSnapshot | null {
  const {eventId, organizerId, uid, rule, decision, responseId,
    response, versionId, version} = params;
  if (!decision || decision.purpose !== "eventAssignmentMatching" ||
      decision.status !== "granted" || !decision.receiptId ||
      decision.eventId !== eventId || decision.organizerId !== organizerId ||
      decision.uid !== uid || decision.responseId !== responseId ||
      decision.featureId !== rule.featureId ||
      decision.formId !== rule.formId ||
      decision.versionId !== rule.versionId ||
      decision.questionId !== rule.questionId ||
      decision.transformVersion !== rule.transformVersion ||
      !response || !version || versionId !== rule.versionId ||
      response.status !== "submitted" ||
      response.withdrawnAt !== null || response.respondentUid !== uid ||
      response.identityKind !== "phoneVerified" ||
      response.organizerId !== organizerId ||
      response.formId !== rule.formId ||
      response.versionId !== rule.versionId ||
      version.organizerId !== organizerId ||
      version.formId !== rule.formId) return null;

  const question = version.definition.sections.flatMap((section) =>
    section.questions).find((item) => item.questionId === rule.questionId);
  if (!question || question.privacyClass !== "organizerCustom") return null;
  const answer = response.answers[rule.questionId];
  const value = answerFeatureValue(rule, question, answer);
  if (!value) return null;
  return {eventId, organizerId, uid, featureId: rule.featureId,
    formId: rule.formId, versionId: rule.versionId,
    questionId: rule.questionId, transformVersion: rule.transformVersion,
    consentReceiptId: decision.receiptId, value};
}

function answerFeatureValue(
  rule: AssignmentFeatureRule,
  question: Version["definition"]["sections"][number]["questions"][number],
  answer: Response["answers"][string] | undefined
): AssignmentFeatureValue | null {
  if (rule.kind === "number") {
    return question.kind === "number" && typeof answer === "number" &&
      Number.isFinite(answer) ? {kind: "number", value: answer} : null;
  }
  if (rule.kind === "set") {
    if (question.kind !== "multiChoice" || !Array.isArray(answer) ||
        answer.length === 0) return null;
    const optionIds = answer.map((value) =>
      question.options.find((option) => option.value === value)?.optionId);
    return optionIds.every((id): id is string => typeof id === "string") ?
      {kind: "set", optionIds: optionIds as string[]} : null;
  }
  if (question.kind !== "singleChoice" || typeof answer !== "string") {
    return null;
  }
  const optionId = question.options.find((option) =>
    option.value === answer)?.optionId;
  return optionId ? {kind: rule.kind, optionId} : null;
}
