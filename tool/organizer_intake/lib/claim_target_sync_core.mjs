const publicRefreshFields = [
  "name",
  "description",
  "location",
  "area",
  "imageUrl",
  "profileImageUrl",
  "tags",
  "instagramHandle",
  "phoneNumber",
  "email",
  "status",
  "archived",
  "archivedAt",
  "archiveReason",
  "hostDefaults",
  "entityKind",
  "entitySubtypes",
  "displayCategory",
  "cityName",
  "regionName",
  "countryCode",
  "countryName",
  "appVisibility",
  "publicPage",
  "provenance",
  "publicProfile",
  "publicSources",
];

export function buildClaimTargetSyncActions(targets, existingDocs) {
  return targets.map((target) => {
    const existing = existingDocs.get(target.path) ?? null;
    if (!existing) {
      return {
        entityId: target.entityId,
        path: target.path,
        status: "create",
        merge: false,
        reason: "missing_claim_target",
        writeData: target.clubDocument,
      };
    }
    if (isOwnerBoundClubDoc(existing)) {
      return {
        entityId: target.entityId,
        path: target.path,
        status: "skip_owner_bound",
        merge: false,
        reason: "existing_owner_bound_club",
        writeData: null,
      };
    }
    const patch = publicRefreshPatch(target.clubDocument);
    const changedPatch = changedPublicRefreshPatch(patch, existing);
    if (Object.keys(changedPatch).length === 0) {
      return {
        entityId: target.entityId,
        path: target.path,
        status: "in_sync",
        merge: false,
        reason: "public_fields_current",
        writeData: null,
      };
    }
    return {
      entityId: target.entityId,
      path: target.path,
      status: "refresh",
      merge: true,
      reason: "refresh_unclaimed_public_fields",
      writeData: changedPatch,
    };
  });
}

export function buildClaimTargetSyncPreview({
  claimTargetPlan,
  existingDocs = new Map(),
  existingDocsSource = "empty_fixture",
} = {}) {
  const targets = claimTargetPlan?.targets ?? [];
  const actions = buildClaimTargetSyncActions(targets, existingDocs);
  const summary = summarizeActions(actions);
  return {
    schemaVersion: 1,
    generatedFrom: {
      claimTargetPlan:
        "tool/organizer_intake/generated/organizer_claim_targets.json",
      existingDocsSource,
    },
    summary,
    mode: {
      previewOnly: true,
      existingDocsSource,
      remoteReads: 0,
      remoteWrites: 0,
      assumesMissingWhenNotInFixture: true,
    },
    guardrails: [
      "This preview never reads or writes Firestore.",
      "Before any remote write, run sync_claim_targets_to_firestore.mjs without --write against the target Firebase project.",
      "Owner-bound club documents must be skipped, never overwritten.",
      "Refresh actions may update public fields only; ownership, claim, and aggregate fields stay server-owned.",
    ],
    commands: {
      localFixturePreview:
        "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs " +
        "--fixture tool/organizer_intake/fixtures/existing_club_docs.empty.json",
      firestoreDryRun:
        "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs " +
        "--env dev",
      firestoreWrite:
        "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs " +
        "--env dev --write",
    },
    actions: actions.map(previewAction),
  };
}

export function isOwnerBoundClubDoc(doc) {
  return typeof doc.ownerUserId === "string" ||
    typeof doc.hostUserId === "string" ||
    doc.ownership?.state === "claimed" ||
    doc.ownership?.state === "transferred" ||
    doc.claim?.state === "claimed" ||
    doc.claim?.state === "verified";
}

export function publicRefreshPatch(clubDocument) {
  return Object.fromEntries(
    publicRefreshFields
      .filter((field) => Object.hasOwn(clubDocument, field))
      .map((field) => [field, clubDocument[field]])
  );
}

export function changedPublicRefreshPatch(patch, existingDoc) {
  return Object.fromEntries(
    Object.entries(patch).filter(([field, value]) =>
      !deepEquivalentFirestoreValue(existingDoc?.[field], value)
    )
  );
}

export function summarizeActions(actions) {
  return {
    targets: actions.length,
    creates: actions.filter((action) => action.status === "create").length,
    refreshes: actions.filter((action) => action.status === "refresh").length,
    inSync: actions.filter((action) => action.status === "in_sync").length,
    skippedOwnerBound: actions.filter((action) =>
      action.status === "skip_owner_bound"
    ).length,
    writesNeeded: actions.filter((action) =>
      action.status === "create" || action.status === "refresh"
    ).length,
  };
}

export function actionSummary(action) {
  return {
    entityId: action.entityId,
    path: action.path,
    status: action.status,
    merge: action.merge,
    reason: action.reason,
  };
}

function previewAction(action) {
  const writeFields = action.writeData ?
    Object.keys(action.writeData).sort() :
    [];
  return {
    ...actionSummary(action),
    writeFields,
    writeFieldCount: writeFields.length,
    writesRemoteData: action.status === "create" || action.status === "refresh",
    requiresFirestoreDryRun:
      action.status === "create" || action.status === "refresh",
  };
}

function deepEquivalentFirestoreValue(left, right) {
  return JSON.stringify(normalizeFirestoreValue(left)) ===
    JSON.stringify(normalizeFirestoreValue(right));
}

function normalizeFirestoreValue(value) {
  if (Array.isArray(value)) return value.map(normalizeFirestoreValue);
  if (!value || typeof value !== "object") return value;
  const timestamp = normalizeTimestampValue(value);
  if (timestamp) return timestamp;
  return Object.fromEntries(
    Object.keys(value)
      .sort()
      .map((key) => [key, normalizeFirestoreValue(value[key])])
  );
}

function normalizeTimestampValue(value) {
  if (
    Number.isInteger(value._seconds) &&
    Number.isInteger(value._nanoseconds)
  ) {
    return {
      _nanoseconds: value._nanoseconds,
      _seconds: value._seconds,
    };
  }
  if (
    typeof value.toMillis === "function" &&
    Number.isFinite(value.toMillis())
  ) {
    const millis = value.toMillis();
    return {
      _nanoseconds: (millis % 1000) * 1000000,
      _seconds: Math.floor(millis / 1000),
    };
  }
  return null;
}
