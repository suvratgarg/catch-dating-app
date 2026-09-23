import assert from "node:assert/strict";
import test from "node:test";
import {deleteApp, initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from "./formPaymentTestStore";
import {reserveFormPayment, finalizeCapturedFormPayment,
  expireFormPaymentReservation} from "./formPaymentSubmission";

import {claimParticipantFormProfileHandler} from
  "../../profiles/claimFormProfile";
import {listOrganizerFormPaymentsHandler} from "./formPaymentLedger";

const emulator = process.env.FIRESTORE_EMULATOR_HOST;

test("Firestore serializes payment reservations, finalization and late capture",
  {skip: !emulator}, async () => {
    assert.match(emulator!, /^(127\.0\.0\.1|localhost):[0-9]+$/u);
    const app = initializeApp({projectId: "demo-catch-form-payments"},
      `form-payments-${Date.now()}`);
    const db = getFirestore(app);
    const fixture = createFormPaymentFixture();
    const collections = ["organizerForms", "organizerFormVersions",
      "organizerFormResponseDrafts", "organizerPaymentConnections",
      "organizerFormPayments", "organizerFormResponses",
      "participantFormProfileProposals", "participantOrganizerCards",
      "participantProfileClaimReceipts", "users", "participantIntakeProfiles",
      "organizerCommunicationPreferences",
      "organizerCommunicationPermissionReceipts",
      "catchCommunicationPreferences", "catchCommunicationPermissionReceipts"];
    fixture.version.definition.sections[0].questions[0].answerDestination =
      "catchProfile";
    fixture.version.definition.messagingConsent = {
      organizerWhatsapp: true, catchWhatsapp: true,
    };
    fixture.store.records.set("organizerFormResponseDrafts/draft", {
      ...fixture.draft, messagingDecision: {
        termsVersion: "form-whatsapp-v1", organizerWhatsapp: true,
        catchWhatsapp: true, organizerDecidedAt: Timestamp.fromMillis(500),
        catchDecidedAt: Timestamp.fromMillis(500),
      },
    });
    try {
      for (const name of collections) {
        await db.recursiveDelete(db.collection(name));
      }
      const seed = db.batch();
      for (const [path, value] of fixture.store.records) {
        seed.set(db.doc(path), value);
      }
      await seed.commit();
      const now = Timestamp.fromMillis(1000);
      const reserve = () => reserveFormPayment({db, request: fixture.request,
        data: fixture.data, now});
      const [first, replay] = await Promise.all([reserve(), reserve()]);
      assert.equal(first.paymentId, replay.paymentId);
      assert.equal((await db.doc("organizerForms/form").get())
        .get("pendingPaymentCount"), 1);
      await db.doc("organizerFormResponseDrafts/other").set({
        ...fixture.draft, respondentUid: "other"});
      await assert.rejects(reserveFormPayment({db, now,
        data: {...fixture.data, draftId: "other"},
        request: {auth: {uid: "other",
          token: {phone_number: "+919000000002"}}} as
          unknown as CallableRequest<unknown>,
      }));
      const paymentRef = db.doc(`organizerFormPayments/${first.paymentId}`);
      await paymentRef.update({status: "captured", capturedAt: now,
        providerOrderId: "order_one", providerPaymentId: "pay_one"});
      await Promise.all([
        finalizeCapturedFormPayment({db, now, paymentId: first.paymentId}),
        finalizeCapturedFormPayment({db, now, paymentId: first.paymentId}),
      ]);
      const form = await db.doc("organizerForms/form").get();
      assert.equal(form.get("pendingPaymentCount"), 0);
      assert.equal(form.get("submittedResponseCount"), 1);
      assert.equal(
        (await db.collection("organizerFormResponses").get()).size, 1);
      assert.equal((await paymentRef.get()).get("reservationReleased"), true);
      for (const collection of ["organizerCommunicationPermissionReceipts",
        "catchCommunicationPermissionReceipts"]) {
        const receipts = await db.collection(collection).get();
        assert.equal(receipts.size, 1);
        assert.equal(receipts.docs[0].get("uid"), "person");
        assert.equal(receipts.docs[0].get("grantedAt").toMillis(), 500);
      }

      const proposals = await db.collection("participantFormProfileProposals")
        .get();
      assert.equal(proposals.size, 1);
      assert.equal(proposals.docs[0].get("uid"), "person");
      assert.equal(proposals.docs[0].get("fields")[0].destination,
        "catchProfile");

      // Real Firestore retries race the claim, but write one identity/receipt.
      const claimRequest = {...fixture.request, data: {
        responseId: proposals.docs[0].id, expectedProfileRevision: 0,
        expectedIntakeRevision: 0, requestId: "claim-emulator-00000001",
        termsVersion: "form-profile-claim-v1", selectedQuestionIds: ["name"],
        profile: {displayName: "Sara Demo", dateOfBirth: "1994-06-15",
          gender: "woman"},
      }};
      const claimDeps = {db: () => db,
        now: () => Timestamp.fromDate(new Date("2026-09-23T12:00:00Z")),
        rateLimit: async () => undefined,
        copyPhoto: async (): Promise<never> => {
          throw new Error("No photo");
        }};
      const claims = await Promise.all([
        claimParticipantFormProfileHandler(claimRequest, claimDeps),
        claimParticipantFormProfileHandler(claimRequest, claimDeps),
      ]);
      assert.deepEqual(claims.map((claim) => claim.replayed).sort(),
        [false, true]);
      assert.equal((await db.doc("users/person").get())
        .get("profileRevision"), 1);
      assert.equal((await db.collection("participantProfileClaimReceipts")
        .get()).size, 1);
      await assert.rejects(claimParticipantFormProfileHandler({
        ...claimRequest, data: {...claimRequest.data,
          requestId: "claim-emulator-00000002"},
      }, claimDeps), /profile changed/u);

      // A separate frozen checkout expires. Later captured funds must not
      // create another response, even if two recovery workers race.
      await db.doc("organizerForms/form").update({submittedResponseCount: 0});
      const late = await reserveFormPayment({db, now,
        data: {...fixture.data, draftId: "other"},
        request: {auth: {uid: "other",
          token: {phone_number: "+919000000002"}}} as
          unknown as CallableRequest<unknown>});
      await expireFormPaymentReservation({db, paymentId: late.paymentId,
        now: late.payment.checkoutExpiresAt});
      const lateRef = db.doc(`organizerFormPayments/${late.paymentId}`);
      await lateRef.update({status: "captured", capturedAt: now,
        providerOrderId: "order_late", providerPaymentId: "pay_late"});
      await Promise.all([
        finalizeCapturedFormPayment({db, now, paymentId: late.paymentId}),
        finalizeCapturedFormPayment({db, now, paymentId: late.paymentId}),
      ]);
      assert.equal((await lateRef.get()).get("status"), "refundPending");
      assert.equal(
        (await db.collection("organizerFormResponses").get()).size, 1);
      assert.equal((await db.doc("organizerForms/form").get())
        .get("pendingPaymentCount"), 0);

      // Equal timestamps still paginate exactly once by document id. Neither
      // foreign financial records nor unsubmitted answers enter this ledger.
      const foreignId = `fp_${"f".repeat(32)}`;
      await db.doc(`organizerFormPayments/${foreignId}`).set({
        ...(await paymentRef.get()).data(), organizerId: "foreign-org"});
      const deps = {db: () => db, rateLimit: async () => undefined,
        requireManager: async () => undefined};
      const ledger = (cursor: string | null, statuses: string[] = []) =>
        listOrganizerFormPaymentsHandler({auth: {uid: "host"}, data: {
          organizerId: "org", formId: "form", statuses, cursor, limit: 1,
        }} as CallableRequest<unknown>, deps);
      const page1 = await ledger(null);
      assert.equal(page1.items.length, 1);
      assert.ok(page1.nextCursor);
      const page2 = await ledger(page1.nextCursor);
      assert.equal(page2.nextCursor, null);
      assert.deepEqual(new Set([...page1.items, ...page2.items]
        .map((row) => row.paymentId)),
      new Set([first.paymentId, late.paymentId]));
      const filtered = await ledger(null, ["refundPending"]);
      assert.equal(filtered.items[0].paymentId, late.paymentId);
      assert.equal(filtered.nextCursor, null);
      await assert.rejects(ledger(page1.nextCursor, ["submitted"]),
        /cursor is invalid/u);
      for (const row of [...page1.items, ...page2.items]) {
        assert.equal("identity" in row, false);
        assert.equal("respondentUid" in row, false);
        assert.equal("draftId" in row, false);
      }
    } finally {
      for (const name of collections) {
        await db.recursiveDelete(db.collection(name));
      }
      await deleteApp(app);
    }
  });
