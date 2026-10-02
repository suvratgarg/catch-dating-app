import assert from "node:assert/strict";
import test from "node:test";
import {
  planWorkspaceFieldWrite,
  programGuestFieldContext,
  resolveWorkspaceFields,
  workspaceFieldAssertionId,
  workspaceFieldAssertionMatches,
  type WorkspaceFieldAssertion,
  type WorkspaceFieldContext,
  type WorkspaceFieldKey,
  type WorkspaceFieldProjection,
} from "./workspaceFieldAuthority";
import {seedWorkspaceFieldAssertions} from "./workspaceFieldFixture";

// These named synthetic facts are deliberate acquisition evidence for tests.
// They are not a recipe for recovering provenance from flattened live rows.
function guestContext(programId: string, guestId: string):
  WorkspaceFieldContext {
  return programGuestFieldContext(programId, "synthetic-org", guestId,
    {programId, organizerId: "synthetic-org"});
}

function assertion(context: WorkspaceFieldContext,
  fieldKey: WorkspaceFieldKey, value: string | null,
  overrides: Partial<WorkspaceFieldAssertion> = {}) {
  const data: WorkspaceFieldAssertion = {
    ...context,
    schemaVersion: 1,
    programId: context.workspaceRef.kind === "program" ?
      context.workspaceRef.id : null,
    fieldKey,
    value,
    sourceKind: "manualEntry",
    sourceId: "synthetic-entry-1",
    sourceVersion: 1,
    actorUid: "synthetic-planner",
    observedAtMillis: 1000,
    disclosureBasis: "workspaceHostAcquisition",
    identityEvidenceRef: null,
    ...overrides,
  };
  return {id: workspaceFieldAssertionId(data), data};
}

function source(sourceKind: "manualEntry" | "manifestRow",
  sourceVersion = 1) {
  return {sourceKind, sourceId: "synthetic-source-1", sourceVersion,
    actorUid: "synthetic-planner", observedAtMillis: 1000 + sourceVersion};
}

function projection(overrides: Partial<WorkspaceFieldProjection> = {}):
  WorkspaceFieldProjection {
  return {displayName: "Synthetic Guest", phoneE164: null, email: null,
    ...overrides};
}

function loader(facts: Array<{id: string; data: WorkspaceFieldAssertion}>) {
  const byId = new Map(facts.map((fact) => [fact.id, fact.data]));
  return async (id: string) => byId.get(id);
}

test("shared contact pointer stays scoped to each wedding", async () => {
  const first = guestContext("synthetic-wedding-a", "guest-a");
  const second = guestContext("synthetic-wedding-b", "guest-b");
  const sharedContactId = "synthetic-same-person-contact";
  const firstPhone = assertion(first, "phoneE164", "+11111111111",
    {sourceId: sharedContactId});
  const secondPhone = assertion(second, "phoneE164", "+12222222222",
    {sourceId: sharedContactId});
  assert.notEqual(firstPhone.id, secondPhone.id);
  const load = loader([firstPhone, secondPhone]);
  const a = await resolveWorkspaceFields({context: first, load,
    projection: projection({phoneE164: firstPhone.data.value,
      fieldSelections: {phoneE164: firstPhone.id}})});
  const b = await resolveWorkspaceFields({context: second, load,
    projection: projection({phoneE164: secondPhone.data.value,
      fieldSelections: {phoneE164: secondPhone.id}})});
  assert.equal(a.values.phoneE164, "+11111111111");
  assert.equal(b.values.phoneE164, "+12222222222");
  const crossed = await resolveWorkspaceFields({context: second, load,
    projection: projection({phoneE164: firstPhone.data.value,
      fieldSelections: {phoneE164: firstPhone.id}})});
  assert.equal(crossed.values.phoneE164, null);
  assert.equal(crossed.authority.phoneE164.state, "restricted");
});

test("review choices reject another workspace, relationship, or field", () => {
  const here = guestContext("synthetic-wedding-a", "guest-a");
  const foreignProgram = assertion(guestContext("synthetic-wedding-b",
    "guest-a"), "phoneE164", "+12222222222");
  const foreignGuest = assertion(guestContext("synthetic-wedding-a",
    "guest-b"), "phoneE164", "+12222222222");
  const wrongField = assertion(here, "email", "other@example.test");
  for (const choice of [foreignProgram, foreignGuest, wrongField]) {
    assert.throws(() => planWorkspaceFieldWrite({context: here,
      previous: projection(), supplied: {}, source: source("manualEntry"),
      choices: {phoneE164: {id: choice.id, assertion: choice.data}}}),
    /Field choice must match/);
  }
});

test("omitted endpoint preserves selection; null clears", async () => {
  const context = guestContext("synthetic-wedding-a", "guest-a");
  const original = assertion(context, "phoneE164", "+11111111111");
  const prior = projection({phoneE164: original.data.value,
    fieldSelections: {phoneE164: original.id}});
  const omitted = planWorkspaceFieldWrite({context, previous: prior,
    supplied: {}, source: source("manualEntry", 2)});
  assert.equal(omitted.values.phoneE164, "+11111111111");
  assert.equal(omitted.fieldSelections.phoneE164, original.id);
  assert.equal(omitted.assertions.length, 0);

  const cleared = planWorkspaceFieldWrite({context, previous: prior,
    supplied: {phoneE164: null}, source: source("manualEntry", 2)});
  assert.equal(cleared.values.phoneE164, null);
  assert.equal(cleared.assertions.length, 1);
  assert.notEqual(cleared.fieldSelections.phoneE164, original.id);
  const visible = await resolveWorkspaceFields({context,
    projection: projection({phoneE164: null,
      fieldSelections: cleared.fieldSelections}),
    load: loader(cleared.assertions)});
  assert.equal(visible.authority.phoneE164.state, "cleared");
});

test("import disagreement stays an alternative until explicit field choice",
  async () => {
    const context = guestContext("synthetic-wedding-a", "guest-a");
    const manual = planWorkspaceFieldWrite({context,
      previous: projection({phoneE164: null}),
      supplied: {phoneE164: "+11111111111"},
      source: source("manualEntry")});
    const manualFact = manual.assertions[0];
    const imported = planWorkspaceFieldWrite({context,
      previous: {...projection(), ...manual.values,
        fieldSelections: manual.fieldSelections},
      supplied: {phoneE164: "+12222222222"},
      source: source("manifestRow", 2)});
    assert.equal(imported.values.phoneE164, "+11111111111");
    assert.equal(imported.fieldSelections.phoneE164, manualFact.id);
    assert.deepEqual(imported.fieldConflicts.phoneE164,
      [imported.assertions[0].id]);
    const load = loader([manualFact, ...imported.assertions]);
    const before = await resolveWorkspaceFields({context, load,
      projection: {...projection(), ...imported.values,
        fieldSelections: imported.fieldSelections,
        fieldConflicts: imported.fieldConflicts}});
    assert.equal(before.authority.phoneE164.alternatives[0].value,
      "+12222222222");
    const chosen = planWorkspaceFieldWrite({context,
      previous: {...projection(), ...imported.values,
        fieldSelections: imported.fieldSelections,
        fieldConflicts: imported.fieldConflicts},
      supplied: {}, source: source("manualEntry", 3),
      choices: {phoneE164: {id: imported.assertions[0].id,
        assertion: imported.assertions[0].data}}});
    assert.equal(chosen.values.phoneE164, "+12222222222");
    assert.equal(chosen.fieldConflicts.phoneE164, undefined);
    assert.equal(chosen.assertions.length, 0);
    assert.equal(manualFact.data.value, "+11111111111");
  });

test("unproven flattened fields are hidden, including a linked contact",
  async () => {
    const resolved = await resolveWorkspaceFields({
      context: guestContext("synthetic-wedding-a", "guest-a"),
      projection: projection({displayName: "Legacy name",
        phoneE164: "+13333333333", email: "legacy@example.test"}),
      load: loader([]),
    });
    assert.deepEqual(resolved.values,
      {displayName: null, phoneE164: null, email: null});
    assert.deepEqual(Object.values(resolved.authority).map((field) =>
      field.state), ["unknown", "unknown", "unknown"]);
  });

test("corrupt or mismatched selection pointers fail closed", async () => {
  const context = guestContext("synthetic-wedding-a", "guest-a");
  const fact = assertion(context, "phoneE164", "+11111111111");
  const changed = {...fact.data, value: "+19999999999"};
  const invalidDigest = {...fact.data, sourceVersion: 2};
  for (const [selected, stored, value] of [
    [fact.id, fact.data, "+12222222222"],
    [fact.id, changed, "+11111111111"],
    [fact.id, invalidDigest, "+11111111111"],
    ["wfa_invalid", fact.data, "+11111111111"],
  ] as const) {
    const result = await resolveWorkspaceFields({context,
      projection: projection({phoneE164: value,
        fieldSelections: {phoneE164: selected}}),
      load: async () => stored});
    assert.equal(result.values.phoneE164, null);
    assert.equal(result.authority.phoneE164.state, "restricted");
  }
});

test("household and guest assertions have independent scope", async () => {
  const guest = guestContext("synthetic-wedding-a", "guest-a");
  const household: WorkspaceFieldContext = {
    ...guest, relationshipRef: {kind: "programHousehold", id: "household-a"},
  };
  const guestPhone = assertion(guest, "phoneE164", "+11111111111");
  const householdPhone = assertion(household, "phoneE164", "+12222222222");
  assert.notEqual(guestPhone.id, householdPhone.id);
  assert.equal(workspaceFieldAssertionMatches(guestPhone.data, guestPhone.id,
    household, "phoneE164"), false);
  const result = await resolveWorkspaceFields({context: household,
    projection: projection({phoneE164: guestPhone.data.value,
      fieldSelections: {phoneE164: guestPhone.id}}),
    load: loader([guestPhone, householdPhone])});
  assert.equal(result.values.phoneE164, null);
  assert.equal(result.authority.phoneE164.state, "restricted");
});

test("conflict list is bounded at twenty source alternatives", () => {
  const context = guestContext("synthetic-wedding-a", "guest-a");
  const chosen = assertion(context, "email", "chosen@example.test");
  const conflicts = Array.from({length: 20}, (_, index) =>
    assertion(context, "email", `alternative-${index}@example.test`,
      {sourceKind: "manifestRow", sourceVersion: index + 2}).id);
  assert.throws(() => planWorkspaceFieldWrite({context,
    previous: projection({email: chosen.data.value,
      fieldSelections: {email: chosen.id},
      fieldConflicts: {email: conflicts}}),
    supplied: {email: "overflow@example.test"},
    source: source("manifestRow", 30)}), /Review conflicting field values/);
});

test("assertion IDs are stable by source version, not endpoint identity",
  () => {
    const context = guestContext("synthetic-wedding-a", "guest-a");
    const first = assertion(context, "phoneE164", "+11111111111",
      {sourceKind: "manifestRow", sourceVersion: 7});
    const replay = assertion(context, "phoneE164", "+11111111111",
      {sourceKind: "manifestRow", sourceVersion: 7,
        observedAtMillis: 2000});
    const next = assertion(context, "phoneE164", "+11111111111",
      {sourceKind: "manifestRow", sourceVersion: 8});
    const otherField = assertion(context, "email", "same@example.test",
      {sourceKind: "manifestRow", sourceVersion: 7});
    assert.equal(first.id, replay.id);
    assert.notEqual(first.id, next.id);
    assert.notEqual(first.id, otherField.id);
  });

test("fixture stamping preserves explicit null and omits absent facts",
  async () => {
    const seed = {
      "organizerPrograms/synthetic-wedding-a": {organizerId: "synthetic-org"},
      "programGuests/guest-a": {programId: "synthetic-wedding-a",
        organizerId: "synthetic-org", displayName: "Named fixture guest",
        phoneE164: null},
      "programHouseholds/household-a": {programId: "synthetic-wedding-a",
        organizerId: "synthetic-org", primaryContactName: null,
        primaryPhoneE164: "+13333333333"},
      "programGuests/foreign": {programId: "synthetic-wedding-b",
        organizerId: "synthetic-org", displayName: "Unbound guest"},
    };
    const stamped: Record<string, Record<string, unknown>> =
      seedWorkspaceFieldAssertions(seed);
    assert.notEqual(stamped, seed);
    assert.equal("fieldSelections" in seed["programGuests/guest-a"], false);
    const guest = stamped["programGuests/guest-a"];
    const household = stamped["programHouseholds/household-a"];
    assert.equal((guest.fieldSelections as Record<string, string>).email,
      undefined);
    assert.equal((household.fieldSelections as Record<string, string>).email,
      undefined);
    assert.equal(stamped["programGuests/foreign"].fieldSelections,
      undefined);
    const facts = Object.entries(stamped).filter(([path]) =>
      path.startsWith("workspaceFieldAssertions/"));
    assert.equal(facts.length, 4);
    const guestPhone = facts.find(([, data]) =>
      (data.relationshipRef as {kind?: string} | undefined)?.kind ===
        "programGuest" &&
      data.fieldKey === "phoneE164");
    assert.equal(guestPhone?.[1].value, null);
    const resolved = await resolveWorkspaceFields({
      context: guestContext("synthetic-wedding-a", "guest-a"),
      projection: projection({displayName: guest.displayName as string,
        phoneE164: null,
        fieldSelections: guest.fieldSelections as Record<WorkspaceFieldKey,
          string>}),
      load: async (id) => stamped[`workspaceFieldAssertions/${id}`] as
        unknown as WorkspaceFieldAssertion | undefined,
    });
    assert.equal(resolved.authority.phoneE164.state, "cleared");
    assert.equal(resolved.authority.email.state, "unknown");
  });

test("delivery resolves only selected phone evidence, without alternatives",
  async () => {
    const context = guestContext("synthetic-wedding-a", "guest-a");
    const phone = assertion(context, "phoneE164", "+11111111111");
    const name = assertion(context, "displayName", "Private name");
    const email = assertion(context, "email", "private@example.test");
    const alternative = assertion(context, "phoneE164", "+12222222222",
      {sourceId: "different-import"});
    const reads: string[] = [];
    const load = loader([phone, name, email, alternative]);
    const result = await resolveWorkspaceFields({context,
      projection: projection({displayName: name.data.value,
        phoneE164: phone.data.value, email: email.data.value,
        fieldSelections: {displayName: name.id, phoneE164: phone.id,
          email: email.id}, fieldConflicts: {phoneE164: [alternative.id]}}),
      fields: ["phoneE164"], includeAlternatives: false,
      load: async (id) => {
        reads.push(id); return load(id);
      },
    });
    assert.deepEqual(reads, [phone.id]);
    assert.equal(result.values.phoneE164, phone.data.value);
    assert.equal(result.values.displayName, null);
    assert.equal(result.values.email, null);
    assert.deepEqual(result.authority.phoneE164.alternatives, []);
  });
