import {
  workspaceFieldAssertionId,
  workspaceFieldAssertionMatches,
  type WorkspaceFieldAssertion,
  type WorkspaceFieldKey,
  type WorkspaceFieldSelections,
} from "./workspaceFieldAuthority";

type SyntheticSeed = Record<string, Record<string, unknown>>;

/**
 * Deliberately stamps named synthetic program fixture values as acquired
 * evidence. This must never be used to infer provenance from production or
 * legacy flattened records.
 */
export function seedWorkspaceFieldAssertions<T extends SyntheticSeed>(
  seed: T,
  options: {actorUid?: string; observedAtMillis?: number} = {}
): T {
  const augmented: SyntheticSeed = Object.fromEntries(
    Object.entries(seed).map(([path, document]) => [path, {...document}])
  );
  const actorUid = options.actorUid ?? "synthetic-fixture-planner";
  const observedAtMillis = options.observedAtMillis ?? 1000;
  for (const [path, original] of Object.entries(seed)) {
    const guest = /^programGuests\/([^/]+)$/u.exec(path);
    const household = /^programHouseholds\/([^/]+)$/u.exec(path);
    const id = guest?.[1] ?? household?.[1];
    if (!id) continue;
    const programId = original.programId;
    const organizerId = original.organizerId;
    if (typeof programId !== "string" || programId.length === 0 ||
        programId.length > 180 || typeof organizerId !== "string" ||
        organizerId.length === 0 || organizerId.length > 180 ||
        id.length > 180) continue;
    const program = seed[`organizerPrograms/${programId}`];
    if (!program || program.organizerId !== organizerId) continue;
    const fields: Array<[WorkspaceFieldKey, unknown]> = guest ? [
      ["displayName", original.displayName],
      ["phoneE164", original.phoneE164],
      ["email", original.email],
    ] : [
      ["displayName", original.primaryContactName],
      ["phoneE164", original.primaryPhoneE164],
      ["email", original.primaryEmail],
    ];
    const selections: WorkspaceFieldSelections = {
      ...(original.fieldSelections as WorkspaceFieldSelections | undefined),
    };
    for (const [fieldKey, value] of fields) {
      if (value === undefined || value !== null && typeof value !== "string" ||
          fieldKey === "displayName" && guest &&
            (typeof value !== "string" || value.length === 0) ||
          fieldKey === "displayName" && household && value === "") {
        continue;
      }
      const assertion: WorkspaceFieldAssertion = {
        schemaVersion: 1,
        workspaceRef: {kind: "program", id: programId},
        programId,
        organizerId,
        relationshipRef: {kind: guest ? "programGuest" : "programHousehold",
          id},
        fieldKey,
        value: value as string | null,
        sourceKind: "manualEntry",
        sourceId: `synthetic-fixture:${path}`,
        sourceVersion: 1,
        actorUid,
        observedAtMillis,
        disclosureBasis: "workspaceHostAcquisition",
        identityEvidenceRef: null,
      };
      const assertionId = workspaceFieldAssertionId(assertion);
      if (!workspaceFieldAssertionMatches(assertion, assertionId, assertion,
        fieldKey)) continue;
      augmented[`workspaceFieldAssertions/${assertionId}`] = assertion as
        unknown as Record<string, unknown>;
      selections[fieldKey] = assertionId;
    }
    augmented[path] = {...augmented[path], fieldSelections: selections};
  }
  return augmented as T;
}
