import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {
  appCheckCallableOptionsWithLimits,
  appCheckCallableOptionsWithSecrets,
} from "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {requireAuth} from "../shared/auth";
import {ConvertOrganizerFormResponseCallablePayload} from
  "../shared/generated/convertOrganizerFormResponseCallablePayload";
import {ConvertOrganizerFormResponseCallableResponse} from
  "../shared/generated/convertOrganizerFormResponseCallableResponse";
import {
  OrganizerApplicationDocument,
  OrganizerApplicationResponseDocument,
  OrganizerContactDocument,
  OrganizerFormConversionReceiptDocument,
  OrganizerFormDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {PreviewOrganizerFormConversionCallablePayload} from
  "../shared/generated/previewOrganizerFormConversionCallablePayload";
import {PreviewOrganizerFormConversionCallableResponse} from
  "../shared/generated/previewOrganizerFormConversionCallableResponse";
import {
  validateConvertOrganizerFormResponseCallablePayload,
  validatePreviewOrganizerFormConversionCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireOrganizerManager} from
  "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {organizerContactIdentityKey} from "./organizerAudienceSecrets";
import {createOrganizerContactRecord} from "./organizerContacts";
import {
  eventAttendeeId,
  importEventAttendeesForHost,
  normalizeRosterPhone,
} from "../events/eventAttendees";

type ConversionKind = PreviewOrganizerFormConversionCallablePayload["kind"];
type ConversionFields =
  PreviewOrganizerFormConversionCallableResponse["fields"];
type ConversionField = ConversionFields[number];
type FormSections = OrganizerFormVersionDocument["definition"]["sections"];
type FormSection = FormSections[number];
type FormQuestionKind = FormSection["questions"][number]["kind"];
type ApplicationAnswers = OrganizerApplicationResponseDocument["answers"];
type ApplicationAnswerValue = ApplicationAnswers[number]["value"];

export const organizerFormFollowUpUnavailableMessage =
  "Follow-up handoff needs an approved messaging template and recipient " +
  "permission. Open the customer in Sends to review and approve the message.";

interface FormConversionDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  timestamp: () => FirebaseFirestore.Timestamp;
  identitySecret: () => string;
  requireManagerAuthority?: boolean;
}

const defaultDeps: FormConversionDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  timestamp: () => admin.firestore.Timestamp.now(),
  identitySecret: () => organizerContactIdentityKey.value(),
};

interface ConversionContext {
  response: OrganizerFormResponseDocument;
  version: OrganizerFormVersionDocument;
  form: OrganizerFormDocument;
  fields: ConversionField[];
  warnings: string[];
  allowed: boolean;
  existingResultId: string | null;
}

/** Produces an exact, read-only downstream conversion review. */
export async function previewOrganizerFormConversionHandler(
  request: CallableRequest<unknown>,
  deps: FormConversionDeps = defaultDeps
): Promise<PreviewOrganizerFormConversionCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    PreviewOrganizerFormConversionCallablePayload
  >(
    request,
    validatePreviewOrganizerFormConversionCallablePayload,
    normalizeConversionPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "previewOrganizerFormConversion");
  await requireOrganizerManager({db, organizerId: data.organizerId, actorUid});
  const context = await conversionContext(db, data);
  return {
    organizerId: data.organizerId,
    formId: context.response.formId,
    responseId: data.responseId,
    kind: data.kind,
    eventId: data.eventId,
    allowed: context.allowed,
    fields: context.fields,
    warnings: context.warnings,
    existingResultId: context.existingResultId,
  };
}

/** Applies one reviewed conversion under a deterministic receipt. */
export async function convertOrganizerFormResponseHandler(
  request: CallableRequest<unknown>,
  deps: FormConversionDeps = defaultDeps
): Promise<ConvertOrganizerFormResponseCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<
    ConvertOrganizerFormResponseCallablePayload
  >(
    request,
    validateConvertOrganizerFormResponseCallablePayload,
    normalizeConversionPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "convertOrganizerFormResponse");
  if (deps.requireManagerAuthority !== false) {
    await requireOrganizerManager({
      db,
      organizerId: data.organizerId,
      actorUid,
    });
  }
  const context = await conversionContext(db, data);
  if (!context.allowed) {
    throw new HttpsError(
      "failed-precondition",
      context.warnings[0] ?? "This response cannot be converted."
    );
  }
  const receiptId = conversionReceiptId(data.responseId, data.kind);
  const receiptRef = db.collection("organizerFormConversionReceipts")
    .doc(receiptId);
  let receipt = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(receiptRef);
    if (snapshot.exists) {
      const existing = requireDoc<OrganizerFormConversionReceiptDocument>(
        snapshot,
        "OrganizerFormConversionReceiptDocument"
      );
      if (existing.organizerId !== data.organizerId ||
          existing.responseId !== data.responseId ||
          existing.kind !== data.kind) {
        throw new HttpsError("already-exists", "Conversion receipt conflict.");
      }
      if (existing.status === "failed") {
        const retried: OrganizerFormConversionReceiptDocument = {
          ...existing,
          requestId: data.requestId,
          actorUid,
          status: "pending",
          fields: context.fields,
          updatedAt: deps.timestamp(),
          completedAt: null,
        };
        tx.set(receiptRef, retried);
        return retried;
      }
      return existing;
    }
    const now = deps.timestamp();
    const created: OrganizerFormConversionReceiptDocument = {
      organizerId: data.organizerId,
      formId: context.response.formId,
      responseId: data.responseId,
      kind: data.kind,
      requestId: data.requestId,
      actorUid,
      status: "pending",
      fields: context.fields,
      resultId: null,
      undoStatus: "notAvailable",
      createdAt: now,
      updatedAt: now,
      completedAt: null,
    };
    tx.create(receiptRef, created);
    return created;
  });
  if (receipt.status === "pending") {
    try {
      const resultId = await applyConversion({
        db,
        data,
        actorUid,
        context,
        identitySecret: deps.identitySecret(),
        now: deps.timestamp(),
      });
      const now = deps.timestamp();
      await receiptRef.update({
        status: "completed",
        resultId,
        undoStatus: "notAvailable",
        updatedAt: now,
        completedAt: now,
      });
      receipt = {
        ...receipt,
        status: "completed",
        resultId,
        undoStatus: "notAvailable",
        updatedAt: now,
        completedAt: now,
      };
    } catch (error) {
      await receiptRef.update({
        status: "failed",
        updatedAt: deps.timestamp(),
      });
      throw error;
    }
  }
  return conversionProjection(receiptId, receipt);
}

async function conversionContext(
  db: FirebaseFirestore.Firestore,
  data: Pick<PreviewOrganizerFormConversionCallablePayload,
    "organizerId" | "responseId" | "kind" | "eventId" | "overrides">
): Promise<ConversionContext> {
  const responseSnap = await db.collection("organizerFormResponses")
    .doc(data.responseId).get();
  if (!responseSnap.exists) {
    throw new HttpsError("not-found", "Form response not found.");
  }
  const response = requireDoc<OrganizerFormResponseDocument>(
    responseSnap,
    "OrganizerFormResponseDocument"
  );
  if (response.organizerId !== data.organizerId) {
    throw new HttpsError("not-found", "Form response not found.");
  }
  const [formSnap, versionSnap, receiptSnap] = await Promise.all([
    db.collection("organizerForms").doc(response.formId).get(),
    db.collection("organizerFormVersions").doc(response.versionId).get(),
    db.collection("organizerFormConversionReceipts")
      .doc(conversionReceiptId(data.responseId, data.kind)).get(),
  ]);
  const form = requireDoc<OrganizerFormDocument>(
    formSnap,
    "OrganizerFormDocument"
  );
  const version = requireDoc<OrganizerFormVersionDocument>(
    versionSnap,
    "OrganizerFormVersionDocument"
  );
  if (form.organizerId !== data.organizerId ||
      version.organizerId !== data.organizerId ||
      version.formId !== response.formId) {
    throw new HttpsError("not-found", "Form response not found.");
  }
  const fields = conversionFields(response, version, data.overrides);
  const warnings: string[] = [];
  let allowed = response.status === "submitted";
  if (!allowed) warnings.push("Withdrawn responses cannot be converted.");
  if (data.kind === "followUp") {
    warnings.push(organizerFormFollowUpUnavailableMessage);
    allowed = false;
  }
  if ((data.kind === "crmContact" || data.kind === "followUp") &&
      !response.identity.email && !response.identity.phoneE164) {
    warnings.push("A verified or submitted email or phone number is required.");
    allowed = false;
  }
  if (data.kind === "crmContact" && !response.identity.displayName &&
      !data.overrides.displayName) {
    warnings.push("Add a display name before creating a CRM contact.");
    allowed = false;
  }
  if (data.kind === "application" &&
      version.definition.purpose !== "application") {
    warnings.push("Only application forms can enter the application queue.");
    allowed = false;
  }
  if (data.kind === "eventAttendeeProposal") {
    if (!data.eventId) {
      warnings.push("Choose an event for this attendee proposal.");
      allowed = false;
    } else {
      const eventSnap = await db.collection("events").doc(data.eventId).get();
      if (!eventSnap.exists ||
          eventSnap.data()?.organizerId !== data.organizerId &&
          eventSnap.data()?.clubId !== data.organizerId) {
        warnings.push("The selected event is not managed by this organizer.");
        allowed = false;
      }
    }
  }
  let existingResultId = receiptSnap.exists ?
    (receiptSnap.data() as OrganizerFormConversionReceiptDocument).resultId :
    null;
  if (!existingResultId && data.kind === "crmContact") {
    existingResultId = await findExistingContact(db, response);
    if (existingResultId) {
      warnings.push("An existing CRM contact matches this response.");
    }
  }
  return {
    response,
    version,
    form,
    fields,
    warnings,
    allowed,
    existingResultId,
  };
}

async function applyConversion(params: {
  db: FirebaseFirestore.Firestore;
  data: ConvertOrganizerFormResponseCallablePayload;
  actorUid: string;
  context: ConversionContext;
  identitySecret: string;
  now: FirebaseFirestore.Timestamp;
}): Promise<string> {
  if (params.context.existingResultId && params.data.kind !== "crmContact") {
    return params.context.existingResultId;
  }
  switch (params.data.kind) {
  case "crmContact": {
    const target = crmContactConversionTarget({
      existingResultId: params.context.existingResultId,
      responseId: params.data.responseId,
      formId: params.context.response.formId,
      submittedAt: params.context.response.submittedAt,
    });
    const displayName = fieldValue(params.context.fields, "displayName") ??
      params.context.response.identity.displayName ?? "Form respondent";
    const result = await createOrganizerContactRecord({
      db: params.db,
      organizerId: params.data.organizerId,
      actorUid: params.actorUid,
      displayName: String(displayName).slice(0, 120),
      phoneE164: stringField(params.context.fields, "phoneNumber") ??
        params.context.response.identity.phoneE164,
      email: stringField(params.context.fields, "email") ??
        params.context.response.identity.email,
      initialNote: `Created from form response ${params.data.responseId}.`,
      identitySecret: params.identitySecret,
      contactId: target.contactId,
      origin: target.origin,
      now: params.now,
    });
    return result.contactId;
  }
  case "application":
    return applyApplicationConversion(params);
  case "eventAttendeeProposal":
    return applyEventAttendeeConversion(params);
  case "followUp":
    throw new HttpsError(
      "failed-precondition",
      organizerFormFollowUpUnavailableMessage
    );
  }
}

/**
 * Resolves both new and matched form respondents through the same provenance
 * writer. A matched contact is not a reason to discard the form origin.
 */
export function crmContactConversionTarget(params: {
  existingResultId: string | null;
  responseId: string;
  formId: string;
  submittedAt: FirebaseFirestore.Timestamp;
}): {
  contactId: string;
  origin: {
    kind: "hostFormResponse";
    formId: string;
    responseId: string;
    observedAt: FirebaseFirestore.Timestamp;
  };
} {
  return {
    contactId: params.existingResultId ?? deterministicResultId(
      "formcontact",
      params.responseId
    ),
    origin: {
      kind: "hostFormResponse",
      formId: params.formId,
      responseId: params.responseId,
      observedAt: params.submittedAt,
    },
  };
}

async function applyEventAttendeeConversion(params: {
  db: FirebaseFirestore.Firestore;
  data: ConvertOrganizerFormResponseCallablePayload;
  actorUid: string;
  context: ConversionContext;
  now: FirebaseFirestore.Timestamp;
}): Promise<string> {
  const eventId = params.data.eventId!;
  const displayName = String(
    fieldValue(params.context.fields, "displayName") ??
    params.context.response.identity.displayName ?? "Form respondent"
  ).slice(0, 120);
  const phone = stringField(params.context.fields, "phoneNumber") ??
    params.context.response.identity.phoneE164;
  const normalizedPhone = normalizeRosterPhone(phone).value;
  const email = (stringField(params.context.fields, "email") ??
    params.context.response.identity.email)?.toLocaleLowerCase("en") ?? null;
  const stableKey = normalizedPhone ? `phone:${normalizedPhone}` :
    email ? `email:${email}` : `external:${params.data.responseId}`;
  const result = await importEventAttendeesForHost({
    hostUid: params.actorUid,
    payload: {
      eventId,
      importKey: `form_${params.data.responseId}`.slice(0, 120),
      fileName: "Catch form response",
      format: "manual",
      rows: [{
        rowId: params.data.responseId.slice(0, 120),
        displayName,
        phone: normalizedPhone,
        email,
        externalReference: params.data.responseId,
        arrivalGroup: null,
        ticketType: null,
        status: "registered",
      }],
    },
  }, {
    firestore: () => params.db,
    checkRateLimit: async () => undefined,
    timestamp: () => params.now,
  });
  if (result.createdCount + result.updatedCount !== 1) {
    throw new HttpsError(
      "failed-precondition",
      result.errors[0]?.message ?? "The attendee could not be added."
    );
  }
  return eventAttendeeId(eventId, stableKey);
}

async function applyApplicationConversion(params: {
  db: FirebaseFirestore.Firestore;
  data: ConvertOrganizerFormResponseCallablePayload;
  actorUid: string;
  context: ConversionContext;
  now: FirebaseFirestore.Timestamp;
}): Promise<string> {
  const applicationId = deterministicResultId(
    "formapplication",
    params.data.responseId
  );
  const applicationRef = params.db.collection("organizerApplications")
    .doc(applicationId);
  const compatibilityResponseRef = params.db
    .collection("organizerApplicationResponses")
    .doc(params.data.responseId);
  const displayName = String(
    fieldValue(params.context.fields, "displayName") ??
    params.context.response.identity.displayName ?? "Form respondent"
  ).slice(0, 160);
  await params.db.runTransaction(async (tx) => {
    const existing = await tx.get(applicationRef);
    if (existing.exists) return;
    const source = {
      kind: "native" as const,
      providerId: null,
      externalFormId: null,
      externalResponseId: params.data.responseId,
      importReceiptId: null,
    };
    const application: OrganizerApplicationDocument = {
      organizerId: params.data.organizerId,
      formId: params.context.response.formId,
      formVersionId: params.context.response.versionId,
      targetKind: params.context.version.definition.defaultTargetKind,
      targetId: params.context.version.definition.defaultTargetId,
      linkedUid: params.context.response.respondentUid,
      contactId: null,
      applicantDisplayName: displayName,
      applicantDisplayNameNormalized: displayName.toLowerCase(),
      reviewStatus: "submitted",
      latestResponseId: params.data.responseId,
      source,
      assignedReviewerUid: null,
      reviewNote: null,
      revision: Math.max(1, params.now.toMillis()),
      submittedAt: params.context.response.submittedAt,
      updatedAt: params.now,
      reviewedAt: null,
    };
    const questions = new Map(params.context.version.definition.sections
      .flatMap((section) => section.questions)
      .map((question) => [question.questionId, question]));
    const compatibility: OrganizerApplicationResponseDocument = {
      organizerId: params.data.organizerId,
      applicationId,
      formId: params.context.response.formId,
      formVersionId: params.context.response.versionId,
      linkedUid: params.context.response.respondentUid,
      answers: params.context.response.answerSnapshots.flatMap((answer) => {
        const question = questions.get(answer.questionId);
        return question ? [{
          questionId: answer.questionId,
          questionKey: answer.key,
          questionLabel: answer.label,
          questionKind: compatibilityQuestionKind(question.kind),
          canonicalFieldId: question.canonicalFieldId,
          privacyClass: question.privacyClass,
          hostPresentation: question.hostPresentation,
          value: compatibilityAnswer(question.kind, answer.answer),
        }] : [];
      }).slice(0, 100),
      source,
      consentVersion: params.context.response.consentVersion,
      grantId: null,
      submittedAt: params.context.response.submittedAt,
    };
    tx.create(applicationRef, application);
    tx.create(compatibilityResponseRef, compatibility);
  });
  return applicationId;
}

function conversionFields(
  response: OrganizerFormResponseDocument,
  version: OrganizerFormVersionDocument,
  overrides: Record<string, string | number | boolean | null>
): ConversionField[] {
  const fields = new Map<string, ConversionField>();
  const add = (
    destinationField: string,
    label: string,
    value: string | number | boolean | null,
    origin: ConversionField["origin"]
  ) => fields.set(destinationField, {
    destinationField,
    label,
    value,
    origin,
    conflict: null,
  });
  if (response.identity.displayName) {
    add("displayName", "Display name", response.identity.displayName,
      response.identity.origin === "respondentGranted" ?
        "verifiedIdentity" : "formAnswer");
  }
  if (response.identity.email) {
    add("email", "Email", response.identity.email,
      response.identity.origin === "respondentGranted" ?
        "verifiedIdentity" : "formAnswer");
  }
  if (response.identity.phoneE164) {
    add("phoneNumber", "Phone number", response.identity.phoneE164,
      response.identity.origin === "respondentGranted" ?
        "verifiedIdentity" : "formAnswer");
  }
  const answers = new Map(response.answerSnapshots.map((answer) =>
    [answer.questionId, answer.answer]));
  for (const question of version.definition.sections.flatMap((section) =>
    section.questions)) {
    if (!question.canonicalFieldId) continue;
    const answer = answers.get(question.questionId);
    if (answer === undefined || answer === null) continue;
    add(
      question.canonicalFieldId,
      question.label,
      Array.isArray(answer) ? answer.join(" | ") : answer,
      "formAnswer"
    );
  }
  for (const [destinationField, value] of Object.entries(overrides)) {
    add(destinationField, destinationField, value, "hostOverride");
  }
  return [...fields.values()].slice(0, 100);
}

async function findExistingContact(
  db: FirebaseFirestore.Firestore,
  response: OrganizerFormResponseDocument
): Promise<string | null> {
  const clauses: ["phoneE164" | "email", string][] = [];
  if (response.identity.phoneE164) {
    clauses.push(["phoneE164", response.identity.phoneE164]);
  }
  if (response.identity.email) clauses.push(["email", response.identity.email]);
  for (const [field, value] of clauses) {
    const snapshot = await db.collection("organizerContacts")
      .where("organizerId", "==", response.organizerId)
      .where(field, "==", value)
      .limit(2)
      .get();
    const candidate = snapshot.docs.find((doc) => {
      const contact = doc.data() as OrganizerContactDocument;
      return contact.deletedAt === null && contact.hiddenAt === null &&
        contact.mergedIntoContactId === null;
    });
    if (candidate) return candidate.id;
  }
  return null;
}

function compatibilityQuestionKind(
  kind: FormQuestionKind
): OrganizerApplicationResponseDocument["answers"][number]["questionKind"] {
  if (kind === "acknowledgement") return "boolean";
  if (kind === "signature") return "file";
  return kind;
}

function compatibilityAnswer(
  kind: FormQuestionKind,
  answer: OrganizerFormResponseDocument["answers"][string]
): ApplicationAnswerValue {
  const empty = {
    textValue: null,
    numberValue: null,
    booleanValue: null,
    dateValue: null,
    optionValues: [] as string[],
    assetIds: [] as string[],
  };
  if (answer === null || answer === "" ||
      Array.isArray(answer) && answer.length === 0) {
    return {valueKind: "empty", ...empty};
  }
  if (kind === "file" || kind === "signature") {
    return {valueKind: "assets", ...empty, assetIds: Array.isArray(answer) ?
      answer : [String(answer)]};
  }
  if (kind === "singleChoice" || kind === "multiChoice") {
    return {valueKind: "options", ...empty, optionValues:
      Array.isArray(answer) ? answer : [String(answer)]};
  }
  if (kind === "date") {
    return {valueKind: "date", ...empty, dateValue: String(answer)};
  }
  if (typeof answer === "number") {
    return {valueKind: "number", ...empty, numberValue: answer};
  }
  if (typeof answer === "boolean") {
    return {valueKind: "boolean", ...empty, booleanValue: answer};
  }
  return {valueKind: "text", ...empty, textValue: String(answer)};
}

function fieldValue(
  fields: ConversionField[],
  destinationField: string
): ConversionField["value"] | null {
  return fields.find((field) =>
    field.destinationField === destinationField)?.value ?? null;
}

function stringField(
  fields: ConversionField[],
  destinationField: string
): string | null {
  const value = fieldValue(fields, destinationField);
  return typeof value === "string" && value ? value : null;
}

function conversionProjection(
  receiptId: string,
  receipt: OrganizerFormConversionReceiptDocument
): ConvertOrganizerFormResponseCallableResponse {
  return {
    receiptId,
    organizerId: receipt.organizerId,
    formId: receipt.formId,
    responseId: receipt.responseId,
    kind: receipt.kind,
    status: receipt.status,
    fields: receipt.fields,
    resultId: receipt.resultId,
    undoStatus: receipt.undoStatus,
    completedAtMillis: receipt.completedAt?.toMillis() ?? null,
  };
}

function normalizeConversionPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["organizerId", "responseId"],
    nullableStringFields: ["eventId"],
  });
}

function conversionReceiptId(responseId: string, kind: ConversionKind): string {
  return deterministicResultId("formconversion", responseId, kind);
}

function deterministicResultId(prefix: string, ...parts: string[]): string {
  const digest = createHash("sha256").update(parts.join("\u001f"))
    .digest("hex").slice(0, 32);
  return `${prefix}_${digest}`;
}

export const previewOrganizerFormConversion = onCall(
  appCheckCallableOptionsWithLimits({
    timeoutSeconds: 60,
    maxInstances: 20,
    concurrency: 20,
  }),
  (request) => previewOrganizerFormConversionHandler(request)
);

export const convertOrganizerFormResponse = onCall(
  appCheckCallableOptionsWithSecrets([organizerContactIdentityKey], {
    timeoutSeconds: 90,
    maxInstances: 20,
    concurrency: 10,
  }),
  (request) => convertOrganizerFormResponseHandler(request)
);
