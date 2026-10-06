import assert from "node:assert/strict";
import test from "node:test";
import {eventAttendeeId} from "./eventAttendees";
import {
  approveHostRosterIntakeApply,
  createHostRosterIntakeDraft,
  HostRosterIntakeRow,
  previewHostRosterIntake,
  proposeHostRosterMapping,
  reviseHostRosterIntakeDraft,
} from "./hostRosterIntakeCore";

const source: HostRosterIntakeRow = {
  value: {rowId: "2", displayName: "Asha Shah",
    phone: "+919876543210", email: "asha@example.com",
    externalReference: "ticket-7", arrivalGroup: "order-7",
    ticketType: "General", status: "registered"},
  sourceRowNumber: 2,
  fields: {displayName: {column: 0, header: "Name", origin: "upload",
    confidence: null}, phone: {column: 1, header: "Phone",
    origin: "upload", confidence: null},
  email: {column: 2, header: "Email", origin: "upload",
    confidence: null}, externalReference: {column: 3,
    header: "Attendee ID", origin: "upload", confidence: null},
  arrivalGroup: {column: 4, header: "Order ID", origin: "upload",
    confidence: null}, ticketType: {column: 5, header: "Ticket Type",
    origin: "upload", confidence: null}},
};

function draft() {
  return createHostRosterIntakeDraft({hostUid: "host-1",
    organizerId: "organizer-1", eventId: "event-1",
    fileFingerprint: "a".repeat(64), fileName: "guests.csv",
    format: "csv", headers: ["Name", "Phone", "Email", "Attendee ID",
      "Order ID", "Ticket Type"],
    mapping: {displayName: 0, phone: 1, email: 2,
      externalReference: 3, arrivalGroup: 4, ticketType: 5},
    rows: [source]});
}

test("private draft has event/actor scoped stable identity and row evidence",
  () => {
    const first = draft();
    assert.equal(first.sessionId, draft().sessionId);
    assert.equal(first.sessionId, createHostRosterIntakeDraft({...first,
      fileName: "renamed.csv"}).sessionId);
    assert.notEqual(first.sessionId,
      createHostRosterIntakeDraft({...first, eventId: "event-2"}).sessionId);
    assert.equal(first.state, "review");
    assert.equal(first.rows[0].fields.externalReference?.header,
      "Attendee ID");
    const mutable = structuredClone(source);
    const isolated = createHostRosterIntakeDraft({...first,
      rows: [mutable]});
    mutable.value.displayName = "changed outside";
    assert.equal(isolated.rows[0].value.displayName, "Asha Shah");
    assert.throws(() => createHostRosterIntakeDraft({...first,
      rows: Array(251).fill(source)}), /bounds/u);
  });

test("persistence bound covers duplicated immutable source evidence", () => {
  const header = "H".repeat(120);
  const rows = Array.from({length: 250}, (_, index) => ({
    value: {rowId: String(index + 2), displayName: "N".repeat(120),
      email: `${index}@${"e".repeat(300)}.io`,
      externalReference: `${index}-${"r".repeat(170)}`,
      arrivalGroup: `${index}-${"a".repeat(170)}`,
      ticketType: "T".repeat(120), status: "registered" as const},
    sourceRowNumber: index + 2,
    fields: {
      displayName: {column: 0, header, origin: "upload" as const,
        confidence: null},
      email: {column: 1, header, origin: "upload" as const,
        confidence: null},
      externalReference: {column: 2, header, origin: "upload" as const,
        confidence: null},
      arrivalGroup: {column: 3, header, origin: "upload" as const,
        confidence: null},
      ticketType: {column: 4, header, origin: "upload" as const,
        confidence: null},
    },
  }));
  assert.ok(Buffer.byteLength(JSON.stringify(rows), "utf8") < 700000);
  assert.throws(() => createHostRosterIntakeDraft({hostUid: "host-1",
    organizerId: "organizer-1", eventId: "event-1",
    fileFingerprint: "f".repeat(64), fileName: "large.csv",
    format: "csv", headers: Array.from({length: 5}, (_, i) => `${i}${header}`
      .slice(0, 120)), mapping: {displayName: 0, email: 1,
      externalReference: 2, arrivalGroup: 3, ticketType: 4}, rows}),
  /evidence exceeds bounds/u);
});

test("preview classifies adds, updates, conflicts and exact stale review",
  () => {
    const current = draft();
    const added = previewHostRosterIntake({draft: current,
      currentRows: new Map()});
    assert.equal(added.counts.add, 1);
    assert.equal(added.eligibleForApply, true);
    const id = added.rows[0].attendeeId!;
    const existing = {eventId: "event-1", attendeeId: id,
      source: "hostImport" as const,
      displayName: "Old name", status: "registered" as const,
      linkedUid: null, phoneE164: "+919876543210",
      email: "asha@example.com", externalReference: "ticket-7",
      cityMarketId: null, arrivalGroup: "order-7",
      ticketType: "General", revenueAmountMinor: null,
      revenueCurrency: null, revenueSource: null,
      updatedAtMillis: 100};
    const updated = previewHostRosterIntake({draft: current,
      currentRows: new Map([[id, existing]])});
    assert.equal(updated.counts.update, 1);
    assert.ok(updated.rows[0].changedFields.includes("displayName"));
    assert.deepEqual(updated.rows[0].fieldChanges[0], {
      field: "displayName", currentValue: "Old name",
      proposedValue: "Asha Shah", origin: "upload",
    });
    assert.deepEqual(updated.rows[0].changedFields, ["displayName"]);
    assert.notEqual(updated.reviewHash, added.reviewHash);
    const booking = previewHostRosterIntake({draft: current,
      currentRows: new Map([[id, {...existing, source: "catchBooking"}]])});
    assert.equal(booking.counts.identityConflict, 1);
    assert.equal(booking.eligibleForApply, false);
    const newer = previewHostRosterIntake({draft: current,
      currentRows: new Map([[id, {...existing,
        updatedAtMillis: 101}]])});
    assert.notEqual(newer.reviewHash, updated.reviewHash);
    const approved = approveHostRosterIntakeApply({draft: current,
      currentRows: new Map([[id, existing]]),
      reviewHash: updated.reviewHash});
    assert.equal(approved.payload.rows.length, 1);
    assert.equal(approved.payload.rows[0].displayName, "Asha Shah");
    assert.throws(() => approveHostRosterIntakeApply({draft: current,
      currentRows: new Map([[id, {...existing, updatedAtMillis: 101}]]),
      reviewHash: updated.reviewHash}), /stale/u);
  });

test("email alone cannot update an existing ticket identity", () => {
  const initial = draft();
  const emailOnly = createHostRosterIntakeDraft({...initial, rows: [{
    ...initial.rows[0],
    value: {...initial.rows[0].value, phone: null,
      externalReference: null, email: "buyer@example.com"},
    fields: {displayName: initial.rows[0].fields.displayName,
      email: initial.rows[0].fields.email,
      arrivalGroup: initial.rows[0].fields.arrivalGroup,
      ticketType: initial.rows[0].fields.ticketType},
  }]});
  const added = previewHostRosterIntake({draft: emailOnly,
    currentRows: new Map()});
  const id = added.rows[0].attendeeId!;
  const existing = {eventId: "event-1", attendeeId: id,
    source: "hostImport" as const, displayName: "Earlier Guest",
    status: "registered" as const, linkedUid: null, phoneE164: null,
    email: "buyer@example.com", cityMarketId: null,
    externalReference: null, arrivalGroup: null, ticketType: null,
    revenueAmountMinor: null, revenueCurrency: null, revenueSource: null,
    updatedAtMillis: 1};
  const conflict = previewHostRosterIntake({draft: emailOnly,
    currentRows: new Map([[id, existing]])});
  assert.equal(conflict.rows[0].kind, "identityConflict");
  assert.equal(conflict.rows[0].issueCode, "email-only-identity");
  assert.equal(conflict.eligibleForApply, false);
});

test("excluded shared contact clears exception; other attendee stays separate",
  () => {
    const first = draft();
    const secondRow: HostRosterIntakeRow = {value: {...source.value,
      rowId: "3", displayName: "Mira Shah",
      externalReference: "ticket-8"}, sourceRowNumber: 3,
    fields: structuredClone(source.fields)};
    const both = createHostRosterIntakeDraft({...first,
      rows: [...first.rows, secondRow]});
    const blocked = previewHostRosterIntake({draft: both,
      currentRows: new Map()});
    assert.equal(blocked.counts.needsReview, 2);
    assert.equal(blocked.eligibleForApply, false);
    const excluded = reviseHostRosterIntakeDraft({draft: both,
      expectedRevision: 1, rows: both.rows, excludedRowIds: ["3"]});
    const preview = previewHostRosterIntake({draft: excluded,
      currentRows: new Map()});
    assert.equal(preview.counts.add, 1);
    assert.equal(preview.counts.excluded, 1);
    assert.equal(approveHostRosterIntakeApply({draft: excluded,
      currentRows: new Map(), reviewHash: preview.reviewHash})
      .payload.rows.length, 1);
  });

test("invalid source row survives review, exclusion and correction",
  () => {
    const first = draft();
    const missing: HostRosterIntakeRow = {value: {rowId: "3",
      displayName: "", externalReference: "ticket-8",
      status: "registered"}, sourceRowNumber: 3,
    fields: {externalReference: {column: 1, header: "Attendee ID",
      origin: "upload", confidence: null}},
    rawCells: ["", "ticket-8"], issues: ["missing-name"]};
    const unresolved = createHostRosterIntakeDraft({...first,
      rows: [...first.rows, missing]});
    const preview = previewHostRosterIntake({draft: unresolved,
      currentRows: new Map()});
    assert.equal(preview.counts.add, 1);
    assert.equal(preview.counts.needsReview, 1);
    assert.equal(preview.eligibleForApply, false);
    assert.deepEqual(unresolved.rows[1].rawCells, ["", "ticket-8"]);
    const excluded = reviseHostRosterIntakeDraft({draft: unresolved,
      expectedRevision: 1, rows: unresolved.rows,
      excludedRowIds: ["3"]});
    assert.equal(previewHostRosterIntake({draft: excluded,
      currentRows: new Map()}).counts.excluded, 1);
    const corrected: HostRosterIntakeRow = {...missing,
      value: {...missing.value, displayName: "Mira Shah"}, issues: [],
      fields: {...missing.fields, displayName: {column: 0,
        header: "Name", origin: "hostCorrection", confidence: null}}};
    const resolved = reviseHostRosterIntakeDraft({draft: unresolved,
      expectedRevision: 1, rows: [first.rows[0], corrected],
      excludedRowIds: []});
    assert.equal(previewHostRosterIntake({draft: resolved,
      currentRows: new Map()}).counts.add, 2);
    assert.deepEqual(resolved.rows[1].rawCells, ["", "ticket-8"]);
    assert.equal(resolved.sourceManifest[1].originalValue.displayName, "");
    assert.equal(resolved.sourceManifest[1].originalFields.externalReference
      ?.origin, "upload");
    assert.equal(resolved.rows[1].fields.displayName?.origin,
      "hostCorrection");
  });

test("existing contact and default status require scoped review",
  () => {
    const first = draft();
    const added = previewHostRosterIntake({draft: first,
      currentRows: new Map()});
    const otherId = "a_different_attendee";
    const current = {eventId: "event-1", attendeeId: otherId,
      source: "catchBooking" as const,
      displayName: "Booked guest", status: "registered" as const,
      linkedUid: null, phoneE164: "+919876543210",
      email: null, cityMarketId: null, externalReference: null,
      arrivalGroup: null, ticketType: null, revenueAmountMinor: null,
      revenueCurrency: null, revenueSource: null, updatedAtMillis: 1};
    const conflict = previewHostRosterIntake({draft: first,
      currentRows: new Map([[otherId, current]])});
    assert.equal(conflict.counts.identityConflict, 1);
    assert.equal(conflict.eligibleForApply, false);
    const phoneKeyId = eventAttendeeId("event-1", "phone:+919876543210");
    const privateBooking = previewHostRosterIntake({draft: first,
      currentRows: new Map([[phoneKeyId, {...current,
        attendeeId: phoneKeyId, phoneE164: null}]])});
    assert.equal(privateBooking.counts.identityConflict, 1);
    assert.equal(privateBooking.rows[0].issueCode,
      "catch-booking-authority");
    const selectedId = added.rows[0].attendeeId!;
    const cancelled = previewHostRosterIntake({draft: first,
      currentRows: new Map([[selectedId, {...current,
        attendeeId: selectedId, source: "hostImport" as const,
        status: "cancelled" as const}]])});
    assert.equal(cancelled.rows[0].issueCode,
      "cancelled-status-needs-explicit-review");
    assert.throws(() => previewHostRosterIntake({draft: first,
      currentRows: new Map([[otherId, {...current,
        eventId: "event-2"}]])}), /outside the intake scope/u);
  });

test("revision fences edits and excludes without losing source evidence",
  () => {
    const first = draft();
    const second = reviseHostRosterIntakeDraft({draft: first,
      expectedRevision: 1, rows: first.rows,
      excludedRowIds: ["2"]});
    assert.equal(second.revision, 2);
    assert.equal(second.rows[0].fields.displayName?.header, "Name");
    const preview = previewHostRosterIntake({draft: second,
      currentRows: new Map()});
    assert.equal(preview.counts.excluded, 1);
    assert.equal(preview.eligibleForApply, false);
    assert.throws(() => reviseHostRosterIntakeDraft({draft: second,
      expectedRevision: 1, rows: second.rows,
      excludedRowIds: []}), /Stale/u);
    const expanded = createHostRosterIntakeDraft({...first,
      rows: [first.rows[0], {
        ...structuredClone(first.rows[0]),
        value: {...first.rows[0].value, rowId: "3"}, sourceRowNumber: 3,
      }]});
    assert.equal(expanded.rows.length, 2);
    assert.throws(() => reviseHostRosterIntakeDraft({draft: expanded,
      expectedRevision: 1, rows: [expanded.rows[0]],
      excludedRowIds: []}), /Stale/u);
    assert.throws(() => reviseHostRosterIntakeDraft({draft: expanded,
      expectedRevision: 1, rows: [expanded.rows[0], {
        ...expanded.rows[1], rawCells: ["different source evidence"],
      }], excludedRowIds: []}), /Stale/u);
  });

test("private extraction seam prefers deterministic and validates fake model",
  async () => {
    let called = 0;
    const provider = {propose: async () => {
      called += 1;
      return {mapping: {displayName: 0}, confidence: 0.7};
    }};
    const known = await proposeHostRosterMapping({headers: ["Name"],
      sampleRows: [["Asha"]], deterministicMapping: {displayName: 0},
      provider});
    assert.equal(known.source, "deterministic");
    assert.equal(called, 0);
    const messy = await proposeHostRosterMapping({headers: ["Person"],
      sampleRows: [["Asha"]], deterministicMapping: {}, provider});
    assert.equal(messy.source, "modelProposal");
    assert.equal(called, 1);
    await assert.rejects(proposeHostRosterMapping({headers: ["Person"],
      sampleRows: [["Asha"]], deterministicMapping: {},
      provider: {propose: async () => ({mapping: {displayName: 1},
        confidence: 2})}}), /invalid/u);
    await assert.rejects(proposeHostRosterMapping({headers: ["Person"],
      sampleRows: [["Asha"]], deterministicMapping: {},
      provider: {propose: async () => ({mapping: {badField: 0,
        displayName: 0}, confidence: 0.7})}}), /invalid/u);
    await assert.rejects(proposeHostRosterMapping({headers: ["Person"],
      sampleRows: [["Asha"]], deterministicMapping: {}}),
    /human review/u);
  });
