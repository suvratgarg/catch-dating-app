import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {validateSalesAction, validateSalesRead} from "./schemas";
import {newSalesAccount} from "./account";
import {assertQualifiedByRuntimePolicy} from "./qualificationPolicy";
import {
  applySalesImport,
  previewSalesImport,
  type ImportApply,
  type ImportPacket,
} from "./imports";
import {
  linkSalesInboundIntent,
  listSalesInboundIntents,
  type LinkInput,
} from "./intents";
import {
  addSalesEvidence,
  listSalesContacts,
  listSalesEvidence,
  upsertSalesContact,
  type ContactInput,
  type EvidenceInput,
} from "./records";
import type {
  SalesAccount,
  SalesActionReceipt,
  SalesActivity,
  SalesCustomField,
  SalesMutationAction,
  SalesOpportunity,
  SalesOpportunityStage,
  SalesPrincipal,
  SalesReadAction,
  SalesTask,
} from "./types";

const accountCollection = "organizerSalesAccounts";
const taskCollection = "salesTasks";
const opportunityCollection = "salesOpportunities";
const activityCollection = "salesActivities";
const fieldCollection = "salesCustomFields";
const receiptCollection = "salesActionReceipts";
const outboundTaskKinds = new Set(["follow_up", "demo"]);
const terminalOpportunityStages = new Set(["closed_won", "closed_lost"]);
const maxScopedOrganizers = 30;

export interface SalesServiceDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => Date;
  authorizeInTransaction?: (
    tx: FirebaseFirestore.Transaction,
    db: FirebaseFirestore.Firestore,
    principal: SalesPrincipal,
    action: string,
    organizerId: string | null,
    fieldId: string | null,
  ) => Promise<void>;
  authorizeRead?: (
    db: FirebaseFirestore.Firestore,
    principal: SalesPrincipal,
    action: string,
    organizerId: string | null,
    fieldId: string | null,
  ) => Promise<void>;
}

const defaultDeps: SalesServiceDeps = {
  firestore: () => admin.firestore(),
  now: () => new Date(),
};

interface CreateHostPayload {
  organizerId: string;
  requestId: string;
}
interface UpdateHostPayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  patch: Partial<
    Pick<
      SalesAccount,
      "researchStatus" | "assignedOwnerUid" | "summary" | "nextAction"
    >
  >;
}
interface UpsertTaskPayload {
  organizerId: string;
  requestId: string;
  taskId?: string;
  expectedRevision: number;
  task: Pick<SalesTask, "kind" | "title" | "dueAt" | "ownerUid" | "status">;
}
interface UpsertOpportunityPayload {
  organizerId: string;
  requestId: string;
  opportunityId?: string;
  expectedRevision: number;
  fields: Pick<
    SalesOpportunity,
    "motion" | "stage" | "ownerUid" | "nextStep" | "nextStepAt"
  >;
}
interface LogActivityPayload {
  organizerId: string;
  requestId: string;
  opportunityId?: string;
  type: SalesActivity["type"];
  occurredAt: string;
  note: string;
}
interface CreateFieldPayload {
  requestId: string;
  field: Pick<SalesCustomField, "fieldId" | "label" | "type" | "recordType"> & {
    helpText?: string | null;
    enumOptions?: string[];
  };
}
interface SetFieldValuePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  fieldId: string;
  value: string | number | boolean | null;
}
type MutationPayload =
  | CreateHostPayload
  | UpdateHostPayload
  | UpsertTaskPayload
  | UpsertOpportunityPayload
  | LogActivityPayload
  | CreateFieldPayload
  | SetFieldValuePayload
  | ImportApply
  | LinkInput
  | ContactInput
  | EvidenceInput;

/** Shared domain boundary for Admin and delegated assistant adapters. */
export async function executeSalesAction(
  principal: SalesPrincipal,
  action: SalesMutationAction,
  payload: unknown,
  deps: SalesServiceDeps = defaultDeps,
): Promise<Record<string, unknown>> {
  validateSalesAction(action, payload);
  const input = payload as MutationPayload;
  const organizerId = "organizerId" in input ? input.organizerId : null;
  authorize(principal, action, organizerId);
  requireDelegationHooks(principal, deps);
  const fieldId =
    "fieldId" in input ?
      input.fieldId :
      "field" in input ?
        input.field.fieldId :
        null;
  if (action === "fields.setValue") {
    assertFieldScope(principal, (input as SetFieldValuePayload).fieldId);
  }
  const db = deps.firestore();
  const requestHash = sha(canonicalJson({action, payload: input}));
  const receiptRef = db
    .collection(receiptCollection)
    .doc(sha(`${principal.uid}\u0000${input.requestId}`));
  const timestamp = deps.now().toISOString();
  return db.runTransaction(async (tx) => {
    await deps.authorizeInTransaction?.(
      tx,
      db,
      principal,
      action,
      organizerId,
      fieldId,
    );
    const receiptSnapshot = await tx.get(receiptRef);
    if (receiptSnapshot.exists) {
      const existing = receiptSnapshot.data() as SalesActionReceipt;
      if (
        existing.actorUid !== principal.uid ||
        existing.action !== action ||
        existing.requestHash !== requestHash
      ) {
        throw new HttpsError(
          "already-exists",
          "Request id belongs to different sales action material.",
        );
      }
      authorize(principal, action, existing.organizerId);
      assertReceiptScope(principal, existing);
      return existing.result as Record<string, unknown>;
    }
    let result: Record<string, unknown>;
    switch (action) {
    case "hosts.create":
      result = await createHost(
        tx,
        db,
        principal,
          input as CreateHostPayload,
          timestamp,
      );
      break;
    case "hosts.update":
      result = await updateHost(
        tx,
        db,
        principal,
          input as UpdateHostPayload,
          timestamp,
      );
      break;
    case "tasks.upsert":
      result = await upsertTask(
        tx,
        db,
        principal,
          input as UpsertTaskPayload,
          timestamp,
      );
      break;
    case "opportunities.upsert":
      result = await upsertOpportunity(
        tx,
        db,
        principal,
          input as UpsertOpportunityPayload,
          timestamp,
      );
      break;
    case "activities.log":
      result = await logActivity(
        tx,
        db,
        principal,
          input as LogActivityPayload,
          timestamp,
      );
      break;
    case "fields.create":
      result = await createField(
        tx,
        db,
        principal,
          input as CreateFieldPayload,
          timestamp,
      );
      break;
    case "fields.setValue":
      result = await setFieldValue(
        tx,
        db,
        principal,
          input as SetFieldValuePayload,
          timestamp,
      );
      break;
    case "intents.link":
      result = await linkSalesInboundIntent(
        tx,
        db,
        principal,
          input as LinkInput,
          timestamp,
      );
      break;
    case "imports.apply":
      result = await applySalesImport(
        tx,
        db,
        principal,
          input as ImportApply,
          timestamp,
      );
      break;
    case "contacts.upsert":
      result = await upsertSalesContact(
        tx,
        db,
        principal,
          input as ContactInput,
          timestamp,
      );
      break;
    case "evidence.add":
      result = await addSalesEvidence(
        tx,
        db,
        principal,
          input as EvidenceInput,
          timestamp,
      );
      break;
    default:
      throw new HttpsError(
        "unimplemented",
        "Sales action is not implemented.",
      );
    }
    const receipt = {
      requestId: input.requestId,
      revision: revisionOfResult(result),
    };
    const response = {...result, receipt};
    tx.create(receiptRef, {
      schemaVersion: 1,
      classification: "sales_private",
      requestId: input.requestId,
      requestHash,
      action,
      actorUid: principal.uid,
      organizerId,
      clientId: principal.clientId ?? null,
      clientAuthUid: principal.clientAuthUid ?? null,
      delegationId: principal.delegationId ?? null,
      createdAt: timestamp,
      result: response,
    } satisfies SalesActionReceipt);
    tx.create(db.collection("adminAuditLogs").doc(), {
      actorUid: principal.uid,
      roles: [...principal.roles],
      action,
      targetPath: organizerId ?
        `${accountCollection}/${organizerId}` :
        fieldCollection,
      createdAt: timestamp,
      requestId: input.requestId,
      ...(principal.delegationId ?
        {delegationId: principal.delegationId} :
        {}),
    });
    return response;
  });
}

/** Bounded private projections; every delegated read is scoped before query. */
export async function executeSalesRead(
  principal: SalesPrincipal,
  action: SalesReadAction,
  payload: unknown,
  deps: SalesServiceDeps = defaultDeps,
): Promise<Record<string, unknown>> {
  validateSalesRead(action, payload);
  const input = payload as Record<string, unknown>;
  authorize(
    principal,
    action,
    typeof input.organizerId === "string" ? input.organizerId : null,
  );
  requireDelegationHooks(principal, deps);
  const db = deps.firestore();
  const organizerId =
    typeof input.organizerId === "string" ? input.organizerId : null;
  const checkCurrent = async (
    name: string,
    id: string | null,
    fieldId: string | null = null,
  ) => {
    await deps.authorizeRead?.(db, principal, name, id, fieldId);
  };
  await checkCurrent(action, organizerId);
  let response: Record<string, unknown>;
  switch (action) {
  case "hosts.search":
    response = await searchHosts(db, principal, input);
    break;
  case "hosts.get":
    response = await getHost(db, principal, input.organizerId as string);
    break;
  case "tasks.list":
    response = await listRecords<SalesTask>(
      db,
      principal,
      taskCollection,
      input,
      ["ownerUid", "status"],
    );
    break;
  case "opportunities.list":
    response = await listRecords<SalesOpportunity>(
      db,
      principal,
      opportunityCollection,
      input,
      ["ownerUid", "stage"],
    );
    break;
  case "intents.list":
    response = await listSalesInboundIntents(db, principal, input);
    break;
  case "imports.preview":
    response = await previewSalesImport(
      db,
      principal,
        input as unknown as ImportPacket,
    );
    break;
  case "contacts.list":
    response = await listSalesContacts(db, principal, input);
    break;
  case "evidence.list":
    response = await listSalesEvidence(db, input);
    break;
  case "fields.list": {
    const snapshot = await db
      .collection(fieldCollection)
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(51)
      .get();
    if (snapshot.size > 50) {
      throw new HttpsError(
        "resource-exhausted",
        "Custom field catalog exceeds the reviewed limit.",
      );
    }
    const rows = snapshot.docs
      .map((doc) => doc.data() as SalesCustomField)
      .filter(
        (field) =>
          !principal.clientId || principal.fieldIds?.includes(field.fieldId),
      );
    response = {rows};
    break;
  }
  case "receipts.get": {
    const ref = db
      .collection(receiptCollection)
      .doc(sha(`${principal.uid}\u0000${input.requestId}`));
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Sales receipt not found.");
    }
    const receipt = snap.data() as SalesActionReceipt;
    assertReceiptScope(principal, receipt);
    authorize(principal, receipt.action, receipt.organizerId);
    const receiptField =
        (receipt.result as { field?: { fieldId?: string }; fieldId?: string })
          .field?.fieldId ??
        (receipt.result as { fieldId?: string }).fieldId ??
        null;
    await deps.authorizeRead?.(
      db,
      principal,
      receipt.action,
      receipt.organizerId,
      receiptField,
    );
    if (receipt.action === "fields.setValue") {
      const result = receipt.result as { fieldId?: string };
      if (result.fieldId) assertFieldScope(principal, result.fieldId);
    }
    response = {receipt: receipt.result};
    break;
  }
  default:
    throw new HttpsError("unimplemented", "Sales read is not implemented.");
  }
  await checkCurrent(action, organizerId);
  return response;
}

async function createHost(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: CreateHostPayload,
  now: string,
): Promise<{ account: SalesAccount }> {
  const organizerRef = db.collection("organizers").doc(input.organizerId);
  const accountRef = db.collection(accountCollection).doc(input.organizerId);
  const [organizerSnap, accountSnap] = await Promise.all([
    tx.get(organizerRef),
    tx.get(accountRef),
  ]);
  if (!organizerSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Canonical organizer must be reviewed before a sales account is created.",
    );
  }
  if (accountSnap.exists) {
    throw new HttpsError(
      "already-exists",
      "Sales account already exists for this organizer.",
    );
  }
  const organizer = organizerSnap.data() ?? {};
  const account = newSalesAccount(
    input.organizerId,
    organizer,
    principal.uid,
    now,
  );
  tx.create(accountRef, account);
  return {account};
}

async function updateHost(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: UpdateHostPayload,
  now: string,
): Promise<{ account: SalesAccount }> {
  const ref = db.collection(accountCollection).doc(input.organizerId);
  const snap = await tx.get(ref);
  const current = requiredAccount(snap);
  expectRevision(current.revision, input.expectedRevision);
  const qualificationPolicy =
    input.patch.researchStatus === "qualified" ?
      await assertQualifiedByRuntimePolicy(tx, db, input.organizerId, now) :
      (current.qualificationPolicy ?? null);
  if (
    input.patch.researchStatus === "no_fit" &&
    !(input.patch.summary ?? current.summary)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "No-fit review requires a recorded reason in the account summary.",
    );
  }
  const next: SalesAccount = {
    ...current,
    ...input.patch,
    qualificationPolicy,
    revision: current.revision + 1,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  tx.set(ref, next);
  return {account: next};
}

async function upsertTask(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: UpsertTaskPayload,
  now: string,
): Promise<{ task: SalesTask }> {
  const taskId =
    input.taskId ??
    `task-${sha(`${principal.uid}\u0000${input.requestId}`).slice(0, 24)}`;
  const accountRef = db.collection(accountCollection).doc(input.organizerId);
  const taskRef = db.collection(taskCollection).doc(taskId);
  const [accountSnap, taskSnap] = await Promise.all([
    tx.get(accountRef),
    tx.get(taskRef),
  ]);
  const account = requiredAccount(accountSnap);
  const current = taskSnap.exists ? (taskSnap.data() as SalesTask) : null;
  if (current && current.organizerId !== input.organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "Task belongs to another organizer.",
    );
  }
  expectRevision(current?.revision ?? 0, input.expectedRevision);
  if (current && current.status !== "open" && input.task.status === "open") {
    throw new HttpsError(
      "failed-precondition",
      "Completed tasks cannot reopen.",
    );
  }
  if (
    input.task.status === "open" &&
    outboundTaskKinds.has(input.task.kind) &&
    (account.suppressionStatus !== "clear" || account.duplicateReviewRequired)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Outbound task is blocked by suppression or identity review.",
    );
  }
  const task: SalesTask = {
    schemaVersion: 1,
    classification: "sales_private",
    taskId,
    organizerId: input.organizerId,
    revision: (current?.revision ?? 0) + 1,
    ...input.task,
    createdAt: current?.createdAt ?? now,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  if (current) tx.set(taskRef, task);
  else tx.create(taskRef, task);
  return {task};
}

async function upsertOpportunity(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: UpsertOpportunityPayload,
  now: string,
): Promise<{ opportunity: SalesOpportunity }> {
  const opportunityKey = `${principal.uid}\u0000${input.requestId}`;
  const opportunityId =
    input.opportunityId ?? `opportunity-${sha(opportunityKey).slice(0, 24)}`;
  const accountRef = db.collection(accountCollection).doc(input.organizerId);
  const ref = db.collection(opportunityCollection).doc(opportunityId);
  const [accountSnap, opportunitySnap] = await Promise.all([
    tx.get(accountRef),
    tx.get(ref),
  ]);
  requiredAccount(accountSnap);
  const current = opportunitySnap.exists ?
    (opportunitySnap.data() as SalesOpportunity) :
    null;
  if (current && current.organizerId !== input.organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "Opportunity belongs to another organizer.",
    );
  }
  expectRevision(current?.revision ?? 0, input.expectedRevision);
  assertOpportunityTransition(
    current?.stage ?? null,
    input.fields.stage,
    input.fields.nextStep,
    input.fields.nextStepAt,
  );
  const opportunity: SalesOpportunity = {
    schemaVersion: 1,
    classification: "sales_private",
    opportunityId,
    organizerId: input.organizerId,
    revision: (current?.revision ?? 0) + 1,
    ...input.fields,
    stageEnteredAt:
      current?.stage === input.fields.stage ? current.stageEnteredAt : now,
    createdAt: current?.createdAt ?? now,
    updatedAt: now,
    updatedBy: principal.uid,
  };
  if (current) tx.set(ref, opportunity);
  else tx.create(ref, opportunity);
  return {opportunity};
}

async function logActivity(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: LogActivityPayload,
  now: string,
): Promise<{ activity: SalesActivity }> {
  const accountRef = db.collection(accountCollection).doc(input.organizerId);
  const activityKey = `${principal.uid}\u0000${input.requestId}`;
  const activityId = `activity-${sha(activityKey).slice(0, 24)}`;
  const activityRef = db.collection(activityCollection).doc(activityId);
  const accountSnap = await tx.get(accountRef);
  requiredAccount(accountSnap);
  if (input.opportunityId) {
    const opportunitySnap = await tx.get(
      db.collection(opportunityCollection).doc(input.opportunityId),
    );
    if (
      !opportunitySnap.exists ||
      opportunitySnap.data()?.organizerId !== input.organizerId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Activity opportunity does not belong to this organizer.",
      );
    }
  }
  const activity: SalesActivity = {
    schemaVersion: 1,
    classification: "sales_private",
    activityId,
    organizerId: input.organizerId,
    opportunityId: input.opportunityId ?? null,
    type: input.type,
    occurredAt: input.occurredAt,
    recordedAt: now,
    note: input.note,
    actorUid: principal.uid,
  };
  tx.create(activityRef, activity);
  return {activity};
}

async function createField(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: CreateFieldPayload,
  now: string,
): Promise<{ field: SalesCustomField }> {
  if (!input.field.fieldId.startsWith("sales.")) {
    throw new HttpsError(
      "invalid-argument",
      "Private custom field id must use the sales. namespace.",
    );
  }
  assertFieldScope(principal, input.field.fieldId);
  const catalogRef = db.collection("salesSettings").doc("customFields");
  const fieldRef = db.collection(fieldCollection).doc(input.field.fieldId);
  const [catalogSnap, fieldSnap] = await Promise.all([
    tx.get(catalogRef),
    tx.get(fieldRef),
  ]);
  if (fieldSnap.exists) {
    throw new HttpsError("already-exists", "Custom field id exists.");
  }
  const currentCatalog = catalogSnap.exists ? (catalogSnap.data() ?? {}) : {};
  const labelKeys = Array.isArray(currentCatalog.normalizedLabels) ?
    (currentCatalog.normalizedLabels as string[]) :
    [];
  if (labelKeys.length >= 50) {
    throw new HttpsError(
      "resource-exhausted",
      "Private custom field limit reached.",
    );
  }
  const normalizedLabel = input.field.label
    .trim()
    .toLowerCase()
    .replace(/\s+/g, " ");
  if (labelKeys.includes(normalizedLabel)) {
    throw new HttpsError(
      "already-exists",
      "A similar private field already exists.",
    );
  }
  const enumOptions = input.field.enumOptions ?? [];
  if ((input.field.type === "enum") !== enumOptions.length > 0) {
    throw new HttpsError(
      "invalid-argument",
      "Enum fields require options; other types cannot have them.",
    );
  }
  const field: SalesCustomField = {
    schemaVersion: 1,
    classification: "sales_private",
    fieldId: input.field.fieldId,
    label: input.field.label,
    normalizedLabel,
    type: input.field.type,
    recordType: "account",
    helpText: input.field.helpText ?? null,
    enumOptions,
    revision: 1,
    createdAt: now,
    createdBy: principal.uid,
  };
  tx.create(fieldRef, field);
  tx.set(catalogRef, {
    schemaVersion: 1,
    classification: "sales_private",
    normalizedLabels: [...labelKeys, normalizedLabel],
    updatedAt: now,
  });
  return {field};
}

async function setFieldValue(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: SetFieldValuePayload,
  now: string,
): Promise<{
  fieldId: string;
  organizerId: string;
  value: SetFieldValuePayload["value"];
  revision: number;
}> {
  const accountRef = db.collection(accountCollection).doc(input.organizerId);
  const fieldRef = db.collection(fieldCollection).doc(input.fieldId);
  const valueRef = accountRef.collection("customValues").doc(input.fieldId);
  const [accountSnap, fieldSnap, valueSnap] = await Promise.all([
    tx.get(accountRef),
    tx.get(fieldRef),
    tx.get(valueRef),
  ]);
  requiredAccount(accountSnap);
  if (!fieldSnap.exists) {
    throw new HttpsError("not-found", "Custom field not found.");
  }
  const field = fieldSnap.data() as SalesCustomField;
  assertFieldValue(field, input.value);
  const currentRevision = valueSnap.exists ?
    Number(valueSnap.data()?.revision) :
    0;
  expectRevision(currentRevision, input.expectedRevision);
  const revision = currentRevision + 1;
  tx.set(valueRef, {
    schemaVersion: 1,
    classification: "sales_private",
    organizerId: input.organizerId,
    fieldId: input.fieldId,
    value: input.value,
    revision,
    updatedAt: now,
    updatedBy: principal.uid,
  });
  return {
    fieldId: input.fieldId,
    organizerId: input.organizerId,
    value: input.value,
    revision,
  };
}

async function searchHosts(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  input: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const limit = Number(input.limit ?? 25);
  const queryText = typeof input.query === "string" ? input.query : null;
  const scope = scopeIds(principal);
  const cursorState = decodeCursor(
    input.cursor,
    principal,
    "hosts.search",
    input,
  );
  let query: FirebaseFirestore.Query = db.collection(accountCollection);
  if (scope) {
    query = query.where(admin.firestore.FieldPath.documentId(), "in", scope);
  }
  if (queryText) {
    query = query.where(
      "searchTokens",
      "array-contains",
      normalizedSearchToken(queryText),
    );
  }
  if (typeof input.ownerUid === "string") {
    query = query.where("assignedOwnerUid", "==", input.ownerUid);
  }
  if (typeof input.researchStatus === "string") {
    query = query.where("researchStatus", "==", input.researchStatus);
  }
  query = query.orderBy(admin.firestore.FieldPath.documentId());
  if (cursorState) query = query.startAfter(cursorState);
  const snapshot = await query.limit(limit + 1).get();
  const rows = snapshot.docs.slice(0, limit).map((doc) => {
    const account = doc.data() as SalesAccount;
    return {
      organizerId: account.organizerId,
      name: account.name,
      city: account.city,
      market: account.market,
      eventTypes: account.eventTypes,
      researchStatus: account.researchStatus,
      fitLabel: null,
      stage: null,
      assignedOwnerUid: account.assignedOwnerUid,
      nextAction: account.nextAction,
    };
  });
  return {
    rows,
    nextCursor:
      snapshot.size > limit ?
        encodeCursor(
          snapshot.docs[limit - 1].id,
          principal,
          "hosts.search",
          input,
        ) :
        null,
  };
}

async function getHost(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  organizerId: string,
): Promise<Record<string, unknown>> {
  const accountRef = db.collection(accountCollection).doc(organizerId);
  const [
    accountSnap,
    organizerSnap,
    tasksSnap,
    opportunitiesSnap,
    activitiesSnap,
    valuesSnap,
  ] = await Promise.all([
    accountRef.get(),
    db.collection("organizers").doc(organizerId).get(),
    db
      .collection(taskCollection)
      .where("organizerId", "==", organizerId)
      .orderBy("updatedAt", "desc")
      .limit(25)
      .get(),
    db
      .collection(opportunityCollection)
      .where("organizerId", "==", organizerId)
      .orderBy("updatedAt", "desc")
      .limit(25)
      .get(),
    db
      .collection(activityCollection)
      .where("organizerId", "==", organizerId)
      .orderBy("occurredAt", "desc")
      .limit(25)
      .get(),
    accountRef.collection("customValues").limit(50).get(),
  ]);
  const account = requiredAccount(accountSnap);
  if (!organizerSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Canonical organizer for sales account is missing.",
    );
  }
  const organizer = organizerSnap.data() ?? {};
  return {
    account: publicAccountShape(account),
    organizerSummary: {
      name: safeString(organizer.name, 160) ?? account.name,
      city: safeString(organizer.cityName, 160),
      market: safeString(organizer.locationMarketId, 96),
      eventTypes: safeStringArray(organizer.entitySubtypes, 12),
      appVisibility: safeString(organizer.appVisibility, 40),
      claimStatus: safeString(
        (organizer.claim as Record<string, unknown> | undefined)?.state,
        40,
      ),
    },
    tasks: tasksSnap.docs
      .map((doc) => doc.data() as SalesTask)
      .filter((task) => visibleTask(account, task)),
    opportunities: opportunitiesSnap.docs.map(
      (doc) => doc.data() as SalesOpportunity,
    ),
    activities: activitiesSnap.docs.map((doc) => doc.data() as SalesActivity),
    customValues: valuesSnap.docs
      .map((doc) => doc.data())
      .filter(
        (value) =>
          !principal.clientId || principal.fieldIds?.includes(value.fieldId),
      ),
  };
}

async function listRecords<T extends { organizerId: string }>(
  db: FirebaseFirestore.Firestore,
  principal: SalesPrincipal,
  collection: string,
  input: Record<string, unknown>,
  filterFields: string[],
): Promise<Record<string, unknown>> {
  const limit = Number(input.limit ?? 25);
  const scope = scopeIds(principal);
  const cursorState = decodeCursor(input.cursor, principal, collection, input);
  const sortField = collection === taskCollection ? "dueAt" : "nextStepAt";
  let query: FirebaseFirestore.Query = db.collection(collection);
  if (scope) query = query.where("organizerId", "in", scope);
  for (const field of filterFields) {
    if (typeof input[field] === "string") {
      query = query.where(field, "==", input[field]);
    }
  }
  query = query
    .orderBy(sortField)
    .orderBy(admin.firestore.FieldPath.documentId());
  if (cursorState) {
    try {
      const [lastSort, lastId] = JSON.parse(cursorState) as [
        string | null,
        string,
      ];
      if (
        !(lastSort === null || typeof lastSort === "string") ||
        typeof lastId !== "string"
      ) {
        throw new Error();
      }
      query = query.startAfter(lastSort, lastId);
    } catch {
      throw new HttpsError("invalid-argument", "Sales page cursor is invalid.");
    }
  }
  const snapshot = await query.limit(limit + 1).get();
  let rows = snapshot.docs.slice(0, limit).map((doc) => doc.data() as T);
  if (collection === taskCollection) {
    const accountIds = [...new Set(rows.map((row) => row.organizerId))];
    const accounts = await Promise.all(
      accountIds.map(async (id) => {
        const snap = await db.collection(accountCollection).doc(id).get();
        return [id, snap.exists ? requiredAccount(snap) : null] as const;
      }),
    );
    const byId = new Map(accounts);
    rows = rows.filter((row) => {
      const account = byId.get(row.organizerId);
      return account && visibleTask(account, row as unknown as SalesTask);
    });
  }
  return {
    rows,
    nextCursor:
      snapshot.size > limit ?
        encodeCursor(
          JSON.stringify([
            snapshot.docs[limit - 1].get(sortField) ?? null,
            snapshot.docs[limit - 1].id,
          ]),
          principal,
          collection,
          input,
        ) :
        null,
  };
}

function visibleTask(account: SalesAccount, task: SalesTask): boolean {
  return (
    task.status !== "open" ||
    !outboundTaskKinds.has(task.kind) ||
    (account.suppressionStatus === "clear" && !account.duplicateReviewRequired)
  );
}

function publicAccountShape(
  account: SalesAccount,
): Pick<
  SalesAccount,
  | "organizerId"
  | "revision"
  | "researchStatus"
  | "assignedOwnerUid"
  | "summary"
  | "nextAction"
> {
  return {
    organizerId: account.organizerId,
    revision: account.revision,
    researchStatus: account.researchStatus,
    assignedOwnerUid: account.assignedOwnerUid,
    summary: account.summary,
    nextAction: account.nextAction,
  };
}

function requiredAccount(
  snap: FirebaseFirestore.DocumentSnapshot,
): SalesAccount {
  if (!snap.exists) {
    throw new HttpsError("not-found", "Sales account not found.");
  }
  const account = snap.data() as SalesAccount;
  if (
    account.schemaVersion !== 1 ||
    account.classification !== "sales_private"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Sales account contract is invalid.",
    );
  }
  return account;
}

function expectRevision(actual: number, expected: number): void {
  if (actual !== expected) {
    throw new HttpsError(
      "aborted",
      `Record changed since review; current revision is ${actual}.`,
    );
  }
}

function assertOpportunityTransition(
  previous: SalesOpportunityStage | null,
  next: SalesOpportunityStage,
  nextStep: string | null,
  nextStepAt: string | null,
): void {
  if (
    previous &&
    terminalOpportunityStages.has(previous) &&
    previous !== next
  ) {
    throw new HttpsError(
      "failed-precondition",
      "A closed opportunity requires a separate reopen decision.",
    );
  }
  if (
    [
      "contacted",
      "in_conversation",
      "demo_arranged",
      "pilot_agreed",
      "pilot_running",
      "commercial_discussion",
    ].includes(next) &&
    (!nextStep || !nextStepAt)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Active opportunity stage requires a dated next step.",
    );
  }
  if (next === "closed_won") {
    throw new HttpsError(
      "failed-precondition",
      "Commercial evidence must be recorded by the later offer owner.",
    );
  }
}

function assertFieldValue(field: SalesCustomField, value: unknown): void {
  if (value === null) return;
  const valid =
    field.type === "string" ?
      typeof value === "string" && value.length <= 500 :
      field.type === "number" ?
        typeof value === "number" && Number.isFinite(value) :
        field.type === "boolean" ?
          typeof value === "boolean" :
          field.type === "date" ?
            isCalendarDate(value) :
            typeof value === "string" && field.enumOptions.includes(value);
  if (!valid) {
    throw new HttpsError(
      "invalid-argument",
      "Custom field value does not match its private field definition.",
    );
  }
}

function isCalendarDate(value: unknown): boolean {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return (
    !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value
  );
}

function authorize(
  principal: SalesPrincipal,
  action: string,
  organizerId: string | null,
): void {
  const employee =
    principal.roles.includes("admin") || principal.roles.includes("adminOwner");
  if (!employee || !principal.uid) {
    throw new HttpsError(
      "permission-denied",
      "Current employee authority is required for Sales.",
    );
  }
  if (principal.allowedActions && !principal.allowedActions.includes(action)) {
    throw new HttpsError(
      "permission-denied",
      "Sales action is outside delegation.",
    );
  }
  if (principal.clientId) {
    if (
      !principal.delegationId ||
      !principal.allowedActions ||
      !Array.isArray(principal.organizerIds) ||
      principal.organizerIds.length > maxScopedOrganizers
    ) {
      throw new HttpsError(
        "permission-denied",
        "Sales delegation scope is incomplete.",
      );
    }
  }
  if (
    principal.organizerIds &&
    organizerId &&
    !principal.organizerIds.includes(organizerId)
  ) {
    throw new HttpsError(
      "permission-denied",
      "Organizer is outside Sales scope.",
    );
  }
}

function requireDelegationHooks(
  principal: SalesPrincipal,
  deps: SalesServiceDeps,
): void {
  if (
    principal.clientId &&
    (!deps.authorizeInTransaction || !deps.authorizeRead)
  ) {
    throw new HttpsError(
      "permission-denied",
      "Delegated Sales authority needs a trusted fresh check.",
    );
  }
}

function scopeIds(principal: SalesPrincipal): string[] | null {
  if (!principal.organizerIds && !principal.clientId) return null;
  const scope = [...new Set(principal.organizerIds ?? [])];
  if (scope.length === 0 || scope.length > maxScopedOrganizers) {
    throw new HttpsError(
      "permission-denied",
      "No bounded organizer scope is available.",
    );
  }
  return scope;
}

function assertFieldScope(principal: SalesPrincipal, fieldId: string): void {
  if (principal.clientId && !principal.fieldIds?.includes(fieldId)) {
    throw new HttpsError("permission-denied", "Field is outside delegation.");
  }
}

function assertReceiptScope(
  principal: SalesPrincipal,
  receipt: SalesActionReceipt,
): void {
  if (
    receipt.actorUid !== principal.uid ||
    (receipt.clientId ?? null) !== (principal.clientId ?? null) ||
    (receipt.clientAuthUid ?? null) !== (principal.clientAuthUid ?? null) ||
    (receipt.delegationId ?? null) !== (principal.delegationId ?? null)
  ) {
    throw new HttpsError(
      "permission-denied",
      "Receipt belongs to another Sales scope.",
    );
  }
  if (
    receipt.action === "fields.create" ||
    receipt.action === "fields.setValue"
  ) {
    const result = receipt.result as {
      field?: { fieldId?: string };
      fieldId?: string;
    };
    const fieldId = result.field?.fieldId ?? result.fieldId;
    if (fieldId) assertFieldScope(principal, fieldId);
  }
}

function safeString(value: unknown, maxLength: number): string | null {
  return typeof value === "string" &&
    value.length > 0 &&
    value.length <= maxLength ?
    value :
    null;
}

function safeStringArray(value: unknown, limit: number): string[] {
  return Array.isArray(value) ?
    value
      .filter(
        (item) =>
          typeof item === "string" && item.length > 0 && item.length <= 96,
      )
      .slice(0, limit) :
    [];
}

function searchTokens(...values: Array<string | null>): string[] {
  const words = values
    .filter((value): value is string => !!value)
    .flatMap((value) =>
      value
        .normalize("NFKD")
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .filter((word) => word.length >= 2),
    );
  return [...new Set(words)].slice(0, 40);
}

function normalizedSearchToken(value: string): string {
  const token = searchTokens(value)[0];
  if (!token) {
    throw new HttpsError(
      "invalid-argument",
      "Search query has no usable token.",
    );
  }
  return token;
}

function sha(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, child]) => `${JSON.stringify(key)}:${canonicalJson(child)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

function revisionOfResult(result: Record<string, unknown>): number | null {
  for (const value of Object.values(result)) {
    if (
      value &&
      typeof value === "object" &&
      typeof (value as { revision?: unknown }).revision === "number"
    ) {
      return (value as { revision: number }).revision;
    }
  }
  return typeof result.revision === "number" ? result.revision : null;
}

function cursorHash(
  principal: SalesPrincipal,
  action: string,
  input: Record<string, unknown>,
): string {
  const filters = {...input};
  delete filters.cursor;
  return sha(
    canonicalJson({
      actorUid: principal.uid,
      clientId: principal.clientId ?? null,
      delegationId: principal.delegationId ?? null,
      organizerIds: principal.organizerIds ?? null,
      action,
      filters,
    }),
  );
}

function encodeCursor(
  lastId: string,
  principal: SalesPrincipal,
  action: string,
  input: Record<string, unknown>,
): string {
  return Buffer.from(
    JSON.stringify({
      v: 1,
      lastId,
      scopeHash: cursorHash(principal, action, input),
    }),
  ).toString("base64url");
}

function decodeCursor(
  value: unknown,
  principal: SalesPrincipal,
  action: string,
  input: Record<string, unknown>,
): string | null {
  if (value === undefined) return null;
  try {
    const decoded = JSON.parse(
      Buffer.from(value as string, "base64url").toString("utf8"),
    );
    if (
      decoded.v !== 1 ||
      typeof decoded.lastId !== "string" ||
      decoded.scopeHash !== cursorHash(principal, action, input)
    ) {
      throw new Error();
    }
    return decoded.lastId;
  } catch {
    throw new HttpsError(
      "invalid-argument",
      "Sales cursor does not match this query and scope.",
    );
  }
}
