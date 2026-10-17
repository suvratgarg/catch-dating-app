import {findRecipientAdmission} from "./recipientAdmission";
import assert from "node:assert/strict";
import test from "node:test";
import {setup, uid, now} from
  "../payments/offerPayments/offerPaymentTestFixture";
import {commitOrganizerFormAdmission as commit,
  previewOrganizerFormAdmission as preview} from
  "../organizerFormAdmission/admissionService";
import {org, eventId, offerId, responseId, contactId} from
  "../organizerFormAdmission/admissionTestFixture";

async function fixture() {
  const h = await setup();
  const offer = h.store.get(`organizerEventOffers/${offerId}`)!;
  Object.assign(offer.paymentSnapshot as object,
    {expectedAmountMinor: 0, collectionMode: null});
  const params = {db: h.store.db(), actorUid: uid,
    recipientGrantId: h.invitation.grantId,
    nowMillis: () => now + 20, loadCurrentAuthUser: h.auth};
  const scope = {organizerId: org, eventId, responseId, contactId, offerId};
  const review = await preview({...params, payload: scope});
  const payload = {...scope, requestId: "accept_free_request",
    expectedOfferGeneration: review.expectedOfferGeneration!,
    expectedOfferRevision: review.expectedOfferRevision!,
    expectedLedgerRevision: review.expectedLedgerRevision!};
  return {...h, params, payload};
}

test("free recipient acceptance reuses one canonical seat without a profile",
  async () => {
    const h = await fixture();
    assert.equal(h.store.get(`users/${uid}`), undefined);
    const first = await commit({...h.params, payload: h.payload});
    const attendee = h.store.get(`eventAttendees/${first.attendeeId}`)!;
    assert.equal(attendee.linkedUid, uid);
    assert.equal(attendee.status, "registered");
    const count = h.store.get(`eventSeatLedgers/${eventId}`)!.occupied;
    const replay = await commit({...h.params, payload: h.payload});
    assert.equal(replay.replayed, true);
    assert.equal(replay.attendeeId, first.attendeeId);
    assert.equal(h.store.get(`eventSeatLedgers/${eventId}`)!.occupied, count);
    await assert.rejects(commit({...h.params,
      payload: {...h.payload, requestId: "another_accept_request"}}));
    assert.deepEqual(await findRecipientAdmission(h.store.db(), uid,
      h.invitation.grantId), {eventId, attendeeId: first.attendeeId});
    assert.equal(await findRecipientAdmission(h.store.db(), "other",
      h.invitation.grantId), undefined);
    attendee.status = "cancelled";
    assert.equal(await findRecipientAdmission(h.store.db(), uid,
      h.invitation.grantId), undefined);
  });

test("recipient authority cannot impersonate a manager or accept paid offers",
  async () => {
    const h = await fixture();
    const writes = h.store.writes.length;
    await assert.rejects(commit({...h.params, actorUid: "other",
      payload: h.payload}));
    await assert.rejects(commit({...h.params, recipientGrantId: undefined,
      payload: h.payload}));
    await assert.rejects(commit({...h.params,
      payload: {...h.payload, eventId: "other_event"}}));
    const offer = h.store.get(`organizerEventOffers/${offerId}`)!;
    Object.assign(offer.paymentSnapshot as object,
      {expectedAmountMinor: 10000, collectionMode: "catchCheckout"});
    await assert.rejects(commit({...h.params, payload: h.payload}));
    assert.equal(h.store.writes.length, writes);
  });

test("free acceptance rechecks withdrawal, expiry and reviewed seat revision",
  async () => {
    for (const change of ["withdrawal", "expiry", "revision"] as const) {
      const h = await fixture();
      const writes = h.store.writes.length;
      if (change === "withdrawal") {
        h.store.get(`organizerFormResponses/${responseId}`)!.status =
          "withdrawn";
      } else if (change === "expiry") {
        h.params.nowMillis = () => 9_000_000_000_000;
      } else h.payload.expectedLedgerRevision++;
      await assert.rejects(commit({...h.params, payload: h.payload}));
      assert.equal(h.store.writes.length, writes);
    }
  });
