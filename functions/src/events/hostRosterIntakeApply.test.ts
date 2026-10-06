import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import type {Transaction} from "firebase-admin/firestore";
import type {EventAttendeeDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  applyHostRosterIntake,
  currentRow,
  HostRosterIntakeApplyDeps,
} from "./hostRosterIntakeApply";
import {
  createHostRosterIntakeDraft,
  previewHostRosterIntake,
} from "./hostRosterIntakeCore";
import type {HostRosterAppliedReview} from
  "./hostRosterIntakeSessionStore";

function fixture() {
  return createHostRosterIntakeDraft({hostUid: "host-1",
    organizerId: "organizer-1", eventId: "event-1",
    fileFingerprint: "d".repeat(64), fileName: "guests.csv",
    format: "csv", headers: ["Name", "Attendee ID"],
    mapping: {displayName: 0, externalReference: 1}, rows: [{
      value: {rowId: "2", displayName: "Asha Shah",
        externalReference: "ticket-7", status: "registered"},
      sourceRowNumber: 2,
      fields: {displayName: {column: 0, header: "Name", origin: "upload",
        confidence: null}, externalReference: {column: 1,
        header: "Attendee ID", origin: "upload", confidence: null}},
      rawCells: ["Asha Shah", "ticket-7"],
    }]});
}

test("one approval applies once and a lost response replays its receipt",
  async () => {
    let draft = fixture();
    const preview = previewHostRosterIntake({draft, currentRows: new Map()});
    let receipt: HostRosterAppliedReview | null = null;
    let writes = 0;
    const tx = {} as Transaction;
    const deps: HostRosterIntakeApplyDeps = {
      store: {
        get: async () => draft,
        getAppliedReview: async () => receipt,
        prepareCompletion: async (input) => {
          assert.equal(input.expectedReviewHash, preview.reviewHash);
          assert.deepEqual(await input.loadCurrentRows(tx, draft), new Map());
          if (input.replayed) {
            assert.equal(input.importId, "imp-1");
            assert.equal(draft.state, "applied");
            return () => {};
          }
          return () => {
            writes += 1;
            const appliedAtMillis = 10;
            receipt = {importId: input.importId, appliedAtMillis, preview,
              payload: input.committedPayload};
            draft = {...draft, state: "applied",
              appliedImportId: input.importId};
          };
        },
      },
      authorize: async () => undefined,
      loadInitialCurrentRows: async () => new Map(),
      loadTransactionCurrentRows: async () => new Map(),
      importCanonical: async (input) => {
        if (draft.state === "applied") {
          await input.authorizeSource(tx, true, "imp-1");
          return {importId: "imp-1", status: "completed", rowCount: 1,
            createdCount: 1, updatedCount: 0, skippedCount: 0,
            errors: [], replayed: true};
        }
        await input.authorizeSource(tx, false, "imp-1");
        await input.commitSource(tx, "imp-1", input.payload,
          "e".repeat(64));
        return {importId: "imp-1", status: "completed", rowCount: 1,
          createdCount: 1, updatedCount: 0, skippedCount: 0,
          errors: [], replayed: false};
      },
    };
    const first = await applyHostRosterIntake({hostUid: "host-1",
      sessionId: draft.sessionId, reviewHash: preview.reviewHash}, deps);
    assert.equal(first.replayed, false);
    assert.equal(writes, 1);
    const replay = await applyHostRosterIntake({hostUid: "host-1",
      sessionId: draft.sessionId, reviewHash: preview.reviewHash}, deps);
    assert.equal(replay.replayed, true);
    assert.equal(writes, 1);
    const savedReceipt = receipt as unknown as HostRosterAppliedReview;
    assert.equal(savedReceipt.payload.rows[0].displayName, "Asha Shah");
  });

test("roster document conversion retains authority and reported revenue",
  () => {
    const now = admin.firestore.Timestamp.fromMillis(1234);
    const source = {eventId: "event-1", clubId: "organizer-1",
      organizerId: "organizer-1", displayName: "Asha Shah",
      searchName: "asha shah", source: "catchBooking" as const,
      status: "registered" as const, linkedUid: null, phoneE164: null,
      email: null, externalReference: "booking-1", arrivalGroup: null,
      ticketType: "General", revenueAmountMinor: 5000,
      revenueCurrency: "INR", revenueSource: "providerOrder" as const,
      importId: null, sourceRowId: null, createdAt: now, updatedAt: now,
      registeredAt: now, waitlistedAt: null, checkedInAt: null,
      cancelledAt: null, checkedInBy: null, linkedAt: null,
      inviteLinkId: null, inviteCapturedAt: null, attendanceRevision: 0,
      preCheckInStatus: null} satisfies EventAttendeeDocument;
    const converted = currentRow("attendee-1", source);
    assert.equal(converted.source, "catchBooking");
    assert.equal(converted.phoneE164, null);
    assert.equal(converted.revenueSource, "providerOrder");
    assert.equal(converted.updatedAtMillis, 1234);
  });
