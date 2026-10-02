import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import type {
  ProgramGuestDocument,
  ProgramHouseholdDocument,
} from "../shared/generated/firestoreAdminTypes";

export type WorkspaceRef =
  | {kind: "program"; id: string}
  | {kind: "community"; id: string};
export type WorkspaceFieldKey = "displayName" | "phoneE164" | "email";
export type WorkspaceFieldSelections = Partial<
  Record<WorkspaceFieldKey, string>
>;
export type WorkspaceFieldConflicts = Partial<
  Record<WorkspaceFieldKey, string[]>
>;
export interface WorkspaceFieldContext {
  workspaceRef: WorkspaceRef;
  organizerId: string;
  relationshipRef: {
    kind: "programGuest" | "programHousehold" | "communityContact";
    id: string;
  };
}

/** Domain evidence shape, persisted through the authored schema. */
export interface WorkspaceFieldAssertion extends WorkspaceFieldContext {
  schemaVersion: 1;
  programId: string | null;
  fieldKey: WorkspaceFieldKey;
  value: string | null;
  sourceKind: "manualEntry" | "manifestRow";
  sourceId: string;
  sourceVersion: number;
  actorUid: string;
  observedAtMillis: number;
  disclosureBasis: "workspaceHostAcquisition";
  identityEvidenceRef: null;
}
export type WorkspaceFieldProjection = Record<
  WorkspaceFieldKey,
  string | null
> & {
  fieldSelections?: WorkspaceFieldSelections;
  fieldConflicts?: WorkspaceFieldConflicts;
};
export type ScopedProgramGuest = ProgramGuestDocument & {
  fieldSelections?: WorkspaceFieldSelections;
  fieldConflicts?: WorkspaceFieldConflicts;
};
export type ScopedProgramHousehold = ProgramHouseholdDocument & {
  fieldSelections?: WorkspaceFieldSelections;
  fieldConflicts?: WorkspaceFieldConflicts;
};
export interface WorkspaceFieldDecision extends WorkspaceFieldContext {
  schemaVersion: 1;
  programId: string | null;
  fieldKey: WorkspaceFieldKey;
  selectedAssertionId: string;
  previousAssertionId: string | null;
  relationshipRevision: number;
  actorUid: string;
  observedAtMillis: number;
}
export interface WorkspaceFieldState {
  state: "available" | "cleared" | "unknown" | "restricted";
  assertionId: string | null;
  sourceKind: WorkspaceFieldAssertion["sourceKind"] | null;
  alternativeAssertionIds: string[];
  alternatives: Array<
    Pick<
      WorkspaceFieldAssertion,
      | "value"
      | "sourceKind"
      | "sourceId"
      | "sourceVersion"
      | "observedAtMillis"
    > & {assertionId: string}
  >;
}
export const workspaceFieldKeys: WorkspaceFieldKey[] = [
  "displayName",
  "phoneE164",
  "email",
];
const assertionIdPattern = /^wfa_[a-f0-9]{64}$/u;

function validContext(context: WorkspaceFieldContext): boolean {
  return (
    [
      context.organizerId,
      context.workspaceRef.id,
      context.relationshipRef.id,
    ].every(
      (id) => typeof id === "string" && id.length > 0 && id.length <= 180,
    ) &&
    ((context.workspaceRef.kind === "program" &&
      ["programGuest", "programHousehold"].includes(
        context.relationshipRef.kind,
      )) ||
      (context.workspaceRef.kind === "community" &&
        context.relationshipRef.kind === "communityContact" &&
        context.workspaceRef.id === context.organizerId))
  );
}

/** Stable source-version identity, not an endpoint/UID deduplication key. */
export function workspaceFieldAssertionId(
  assertion: WorkspaceFieldAssertion,
): string {
  return (
    "wfa_" +
    createHash("sha256")
      .update(
        JSON.stringify([
          assertion.workspaceRef.kind,
          assertion.workspaceRef.id,
          assertion.organizerId,
          assertion.relationshipRef.kind,
          assertion.relationshipRef.id,
          assertion.fieldKey,
          assertion.sourceKind,
          assertion.sourceId,
          assertion.sourceVersion,
        ]),
      )
      .digest("hex")
  );
}

/** Check exact scope and field before disclosing a stored value. */
export function workspaceFieldAssertionMatches(
  assertion: WorkspaceFieldAssertion | undefined,
  id: string,
  context: WorkspaceFieldContext,
  field: WorkspaceFieldKey,
): assertion is WorkspaceFieldAssertion {
  return Boolean(
    assertion &&
    validContext(context) &&
    assertion.schemaVersion === 1 &&
    assertion.fieldKey === field &&
    assertion.programId ===
      (context.workspaceRef.kind === "program" ?
        context.workspaceRef.id :
        null) &&
    assertion.workspaceRef?.kind === context.workspaceRef.kind &&
    assertion.workspaceRef.id === context.workspaceRef.id &&
    assertion.organizerId === context.organizerId &&
    assertion.relationshipRef?.kind === context.relationshipRef.kind &&
    assertion.relationshipRef.id === context.relationshipRef.id &&
    assertion.disclosureBasis === "workspaceHostAcquisition" &&
    assertion.identityEvidenceRef === null &&
    ["manualEntry", "manifestRow"].includes(assertion.sourceKind) &&
    typeof assertion.actorUid === "string" &&
    assertion.actorUid.length > 0 &&
    assertion.actorUid.length <= 180 &&
    typeof assertion.sourceId === "string" &&
    assertion.sourceId.length > 0 &&
    assertion.sourceId.length <= 240 &&
    Number.isSafeInteger(assertion.sourceVersion) &&
    assertion.sourceVersion > 0 &&
    Number.isSafeInteger(assertion.observedAtMillis) &&
    assertion.observedAtMillis > 0 &&
    (assertion.value === null ||
      (typeof assertion.value === "string" &&
        assertion.value.length <=
          (field === "displayName" ?
            140 :
            field === "phoneE164" ?
              20 :
              320))) &&
    (field !== "displayName" ||
      (assertion.value === null &&
        context.relationshipRef.kind === "programHousehold") ||
      (typeof assertion.value === "string" &&
        assertion.value.length > 0)) &&
    assertionIdPattern.test(id) &&
    workspaceFieldAssertionId(assertion) === id,
  );
}

/** No fallback to flattened legacy values or organizer-wide CRM pointers. */
export async function resolveWorkspaceFields(params: {
  context: WorkspaceFieldContext;
  projection: WorkspaceFieldProjection;
  load: (id: string) => Promise<WorkspaceFieldAssertion | undefined>;
  fields?: readonly WorkspaceFieldKey[];
  includeAlternatives?: boolean;
}): Promise<{
  values: Record<WorkspaceFieldKey, string | null>;
  authority: Record<WorkspaceFieldKey, WorkspaceFieldState>;
}> {
  if (!validContext(params.context)) {
    throw new HttpsError(
      "failed-precondition",
      "Workspace scope is invalid.",
    );
  }
  const rows = await Promise.all(
    workspaceFieldKeys.map(async (key) => {
      if (params.fields && !params.fields.includes(key)) {
        return {key, value: null, state: {state: "unknown" as const,
          assertionId: null, sourceKind: null, alternativeAssertionIds: [],
          alternatives: []}};
      }
      const id = params.projection.fieldSelections?.[key];
      const alternativeIds = params.includeAlternatives === false ? [] : [
        ...new Set(params.projection.fieldConflicts?.[key] ?? []),
      ].slice(0, 20);
      const alternatives = (
        await Promise.all(
          alternativeIds.map(async (id) => {
            const fact = assertionIdPattern.test(id) ?
              await params.load(id) :
              undefined;
            return workspaceFieldAssertionMatches(
              fact,
              id,
              params.context,
              key,
            ) ?
              {
                assertionId: id,
                value: fact.value,
                sourceKind: fact.sourceKind,
                sourceId: fact.sourceId,
                sourceVersion: fact.sourceVersion,
                observedAtMillis: fact.observedAtMillis,
              } :
              null;
          }),
        )
      ).filter((fact) => fact !== null);
      const alternativeAssertionIds = alternatives.map(
        (fact) => fact.assertionId,
      );
      if (!id) {
        return {
          key,
          value: null,
          state: {
            state: "unknown" as const,
            assertionId: null,
            sourceKind: null,
            alternativeAssertionIds,
            alternatives,
          },
        };
      }
      const assertion = assertionIdPattern.test(id) ?
        await params.load(id) :
        undefined;
      if (
        !workspaceFieldAssertionMatches(
          assertion,
          id,
          params.context,
          key,
        ) ||
        assertion.value !== params.projection[key]
      ) {
        return {
          key,
          value: null,
          state: {
            state: "restricted" as const,
            assertionId: null,
            sourceKind: null,
            alternativeAssertionIds: [],
            alternatives: [],
          },
        };
      }
      return {
        key,
        value: assertion.value,
        state: {
          state:
            assertion.value === null ?
              ("cleared" as const) :
              ("available" as const),
          assertionId: id,
          sourceKind: assertion.sourceKind,
          alternativeAssertionIds,
          alternatives,
        },
      };
    }),
  );
  return {
    values: Object.fromEntries(
      rows.map((row) => [row.key, row.value]),
    ) as Record<WorkspaceFieldKey, string | null>,
    authority: Object.fromEntries(
      rows.map((row) => [row.key, row.state]),
    ) as Record<WorkspaceFieldKey, WorkspaceFieldState>,
  };
}

/** Existing program identity is explicit; contactId is never an access join. */
export function programGuestFieldContext(
  programId: string,
  organizerId: string,
  guestId: string,
  guest: Pick<ProgramGuestDocument, "programId" | "organizerId">,
): WorkspaceFieldContext {
  if (guest.programId !== programId || guest.organizerId !== organizerId) {
    throw new HttpsError(
      "failed-precondition",
      "Guest ownership needs reconciliation.",
    );
  }
  return {
    workspaceRef: {kind: "program", id: programId},
    organizerId,
    relationshipRef: {kind: "programGuest", id: guestId},
  };
}

export async function readProgramGuestFields(params: {
  db: FirebaseFirestore.Firestore;
  tx?: FirebaseFirestore.Transaction;
  programId: string;
  organizerId: string;
  guestId: string;
  guest: ScopedProgramGuest;
  fields?: readonly WorkspaceFieldKey[];
  includeAlternatives?: boolean;
}) {
  const context = programGuestFieldContext(
    params.programId,
    params.organizerId,
    params.guestId,
    params.guest,
  );
  return resolveWorkspaceFields({
    context,
    projection: params.guest,
    fields: params.fields, includeAlternatives: params.includeAlternatives,
    load: async (id) => {
      const ref = params.db.collection("workspaceFieldAssertions").doc(id);
      const snap = params.tx ? await params.tx.get(ref) : await ref.get();
      return snap.data() as WorkspaceFieldAssertion | undefined;
    },
  });
}

/**
 * Captures only fields actually supplied by the authorized source. Manual
 * edits/choices select explicitly. Imports retain a permitted current value
 * and record different incoming evidence for host review.
 */
export function planWorkspaceFieldWrite(params: {
  context: WorkspaceFieldContext;
  previous: WorkspaceFieldProjection;
  supplied: Partial<Record<WorkspaceFieldKey, string | null>>;
  source: Pick<
    WorkspaceFieldAssertion,
    | "sourceKind"
    | "sourceId"
    | "sourceVersion"
    | "actorUid"
    | "observedAtMillis"
  >;
  choices?: Partial<
    Record<
      WorkspaceFieldKey,
      {id: string; assertion: WorkspaceFieldAssertion}
    >
  >;
}) {
  if (!validContext(params.context)) {
    throw new HttpsError(
      "failed-precondition",
      "Workspace scope is invalid.",
    );
  }
  const sourceProof: WorkspaceFieldAssertion = {...params.context,
    ...params.source, schemaVersion: 1,
    programId: params.context.workspaceRef.kind === "program" ?
      params.context.workspaceRef.id : null,
    fieldKey: "phoneE164", value: null,
    disclosureBasis: "workspaceHostAcquisition", identityEvidenceRef: null};
  if (!workspaceFieldAssertionMatches(sourceProof,
    workspaceFieldAssertionId(sourceProof), params.context, "phoneE164")) {
    throw new HttpsError("invalid-argument", "Field source is invalid.");
  }
  const fieldSelections = {...params.previous.fieldSelections};
  const fieldConflicts = {...params.previous.fieldConflicts};
  const values = {
    displayName: params.previous.displayName,
    phoneE164: params.previous.phoneE164,
    email: params.previous.email,
  };
  const assertions: Array<{id: string; data: WorkspaceFieldAssertion}> = [];
  const decisions: Array<{id: string; data: WorkspaceFieldDecision}> = [];
  for (const key of workspaceFieldKeys) {
    const choice = params.choices?.[key];
    const supplied = Object.prototype.hasOwnProperty.call(
      params.supplied,
      key,
    );
    if (choice) {
      if (
        !workspaceFieldAssertionMatches(
          choice.assertion,
          choice.id,
          params.context,
          key,
        ) ||
        (supplied &&
          (key !== "displayName" ||
            params.supplied[key] !== choice.assertion.value))
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Field choice must match this workspace, guest and field.",
        );
      }
      const data: WorkspaceFieldDecision = {
        ...params.context,
        schemaVersion: 1,
        programId:
          params.context.workspaceRef.kind === "program" ?
            params.context.workspaceRef.id :
            null,
        fieldKey: key,
        selectedAssertionId: choice.id,
        previousAssertionId: fieldSelections[key] ?? null,
        relationshipRevision: params.source.sourceVersion,
        actorUid: params.source.actorUid,
        observedAtMillis: params.source.observedAtMillis,
      };
      const id =
        "wfd_" +
        createHash("sha256")
          .update(
            JSON.stringify([
              params.context,
              key,
              data.relationshipRevision,
            ]),
          )
          .digest("hex");
      decisions.push({id, data});
      fieldSelections[key] = choice.id;
      values[key] = choice.assertion.value;
      delete fieldConflicts[key];
      continue;
    }
    if (!supplied || params.supplied[key] === undefined) continue;
    const value = params.supplied[key]!;
    if (
      (value !== null && typeof value !== "string") ||
      (key === "displayName" &&
        ((!value &&
          params.context.relationshipRef.kind !== "programHousehold") ||
          (value !== null && value.length > 140)))
    ) {
      throw new HttpsError("invalid-argument", "Invalid field value.");
    }
    if (
      params.source.sourceKind === "manualEntry" &&
      fieldSelections[key] &&
      values[key] === value &&
      !fieldConflicts[key]?.length
    ) {
      continue;
    }
    const data: WorkspaceFieldAssertion = {
      ...params.context,
      ...params.source,
      schemaVersion: 1,
      programId:
        params.context.workspaceRef.kind === "program" ?
          params.context.workspaceRef.id :
          null,
      fieldKey: key,
      value,
      disclosureBasis: "workspaceHostAcquisition",
      identityEvidenceRef: null,
    };
    const id = workspaceFieldAssertionId(data);
    if (!workspaceFieldAssertionMatches(data, id, params.context, key)) {
      throw new HttpsError("invalid-argument", "Field source is invalid.");
    }
    assertions.push({id, data});
    if (
      params.source.sourceKind === "manifestRow" &&
      fieldSelections[key] &&
      values[key] !== value
    ) {
      const conflicts = [...new Set([...(fieldConflicts[key] ?? []), id])];
      if (conflicts.length > 20) {
        throw new HttpsError(
          "resource-exhausted",
          "Review conflicting field values before importing more.",
        );
      }
      fieldConflicts[key] = conflicts;
    } else {
      fieldSelections[key] = id;
      values[key] = value;
      delete fieldConflicts[key];
    }
  }
  return {values, fieldSelections, fieldConflicts, assertions, decisions};
}

/** Household endpoints are independent acquisitions, never guest/CRM joins. */
export async function readProgramHouseholdFields(params: {
  db: FirebaseFirestore.Firestore;
  tx?: FirebaseFirestore.Transaction;
  programId: string;
  organizerId: string;
  householdId: string;
  household: ScopedProgramHousehold;
  fields?: readonly WorkspaceFieldKey[];
  includeAlternatives?: boolean;
}) {
  const context = programGuestFieldContext(
    params.programId,
    params.organizerId,
    params.householdId,
    params.household,
  );
  context.relationshipRef.kind = "programHousehold";
  return resolveWorkspaceFields({
    context,
    fields: params.fields, includeAlternatives: params.includeAlternatives,
    projection: {
      displayName: params.household.primaryContactName,
      phoneE164: params.household.primaryPhoneE164,
      email: params.household.primaryEmail,
      fieldSelections: params.household.fieldSelections,
      fieldConflicts: params.household.fieldConflicts,
    },
    load: async (id) => {
      const ref = params.db.collection("workspaceFieldAssertions").doc(id);
      const snap = params.tx ? await params.tx.get(ref) : await ref.get();
      return snap.data() as WorkspaceFieldAssertion | undefined;
    },
  });
}

/** Retain unknown facts while restricting corrupt disclosure pointers. */
export function permittedFieldPointers(
  projection: WorkspaceFieldProjection,
  resolved: Awaited<ReturnType<typeof resolveWorkspaceFields>>,
): Pick<WorkspaceFieldProjection, "fieldSelections" | "fieldConflicts"> {
  const fieldSelections: WorkspaceFieldSelections = {};
  const fieldConflicts: WorkspaceFieldConflicts = {};
  for (const key of workspaceFieldKeys) {
    const field = resolved.authority[key];
    if (field.assertionId) fieldSelections[key] = field.assertionId;
    if (field.alternativeAssertionIds.length) {
      fieldConflicts[key] = field.alternativeAssertionIds;
    }
  }
  return {fieldSelections, fieldConflicts};
}

/** Read the bounded selected evidence before any transaction starts writing. */
export async function readWorkspaceFieldChoices(params: {
  db: FirebaseFirestore.Firestore;
  tx: FirebaseFirestore.Transaction;
  choices?: WorkspaceFieldSelections;
}) {
  const rows = await Promise.all(
    workspaceFieldKeys.map(async (key) => {
      const id = params.choices?.[key];
      if (!id) return null;
      const snap = await params.tx.get(
        params.db.collection("workspaceFieldAssertions").doc(id),
      );
      const assertion = snap.data() as WorkspaceFieldAssertion | undefined;
      if (!assertion) {
        throw new HttpsError(
          "invalid-argument",
          "Selected field assertion does not exist.",
        );
      }
      return [key, {id, assertion}] as const;
    }),
  );
  return Object.fromEntries(rows.filter((row) => row !== null)) as Partial<
    Record<
      WorkspaceFieldKey,
      {id: string; assertion: WorkspaceFieldAssertion}
    >
  >;
}
