import assert from "node:assert/strict";
import test from "node:test";
import type {
  FunctionGuestRowLike,
  FunctionLike,
  ProgramGuestLike,
} from "./functionInvitation";
import {
  buildConversionPlan,
  type ConversionContext,
  type ReviewedResponseLike,
} from "./conversionPlan";

const functions: FunctionLike[] = [
  {functionId: "sangeet", status: "scheduled"},
  {
    functionId: "haldi",
    status: "scheduled",
    invitationMode: "selectedGuests",
  },
  {functionId: "bidaai", status: "cancelled"},
];

const guests: ProgramGuestLike[] = [
  {guestId: "a", invitationStatus: "invited", rsvpStatus: "pending"},
];

function ctx(partial?: Partial<ConversionContext>): ConversionContext {
  return {functions, guests, rows: [], ...partial};
}

function response(
  partial?: Partial<ReviewedResponseLike>,
): ReviewedResponseLike {
  return {
    guestId: "a",
    functionId: "sangeet",
    rsvpStatus: "attending",
    respondedAt: 1_700_000_000_000,
    ...partial,
  };
}

function invitedRow(
  guestId: string,
  functionId: string,
  partial?: Partial<FunctionGuestRowLike>,
): FunctionGuestRowLike {
  return {
    functionId,
    guestId,
    invited: true,
    rsvpStatus: "pending",
    attendanceStatus: "expected",
    ...partial,
  };
}

test("buildConversionPlan upserts at the deterministic join key", () => {
  const plan = buildConversionPlan(
    response({partySize: 3, responseNote: "vegan"}), ctx());
  assert.equal(plan.rejected, undefined);
  assert.deepEqual(plan.functionGuestUpserts, [{
    joinKey: "sangeet_a",
    fields: {
      functionId: "sangeet",
      guestId: "a",
      invited: true,
      rsvpStatus: "attending",
      attendanceStatus: "expected",
      partySize: 3,
      responseNote: "vegan",
      respondedAt: 1_700_000_000_000,
    },
  }]);
  assert.deepEqual(
    plan.guestRollup, {guestId: "a", rsvpStatus: "attending"});
});

test("buildConversionPlan defaults optional response fields to null", () => {
  const plan = buildConversionPlan(response(), ctx());
  const fields = plan.functionGuestUpserts[0].fields;
  assert.equal(fields.partySize, null);
  assert.equal(fields.responseNote, null);
});

test("buildConversionPlan preserves door state on re-response", () => {
  const existing = invitedRow("a", "sangeet", {
    rsvpStatus: "attending",
    attendanceStatus: "checkedIn",
  });
  const plan = buildConversionPlan(
    response({rsvpStatus: "declined"}), ctx({rows: [existing]}));
  assert.equal(plan.rejected, undefined);
  assert.equal(
    plan.functionGuestUpserts[0].fields.attendanceStatus, "checkedIn");
  // Declining the only function leaves the guest declined overall.
  assert.deepEqual(
    plan.guestRollup, {guestId: "a", rsvpStatus: "declined"});
});

test("buildConversionPlan recomputes the rollup across functions", () => {
  const rows = [
    invitedRow("a", "sangeet", {rsvpStatus: "attending"}),
    invitedRow("a", "haldi"),
  ];
  const plan = buildConversionPlan(
    response({functionId: "haldi", rsvpStatus: "maybe"}), ctx({rows}));
  // Attending sangeet still outranks the new maybe on haldi.
  assert.equal(plan.functionGuestUpserts[0].joinKey, "haldi_a");
  assert.deepEqual(
    plan.guestRollup, {guestId: "a", rsvpStatus: "attending"});
});

test("cancelled-function rows never feed the resulting rollup", () => {
  const rows = [invitedRow("a", "bidaai", {rsvpStatus: "attending"})];
  const plan = buildConversionPlan(
    response({rsvpStatus: "declined"}), ctx({rows}));
  // The attending row sits on a cancelled function; after this decline
  // the guest has no live affirmative response and rolls up declined.
  assert.deepEqual(
    plan.guestRollup, {guestId: "a", rsvpStatus: "declined"});
});

test("buildConversionPlan rejects unknown guests and functions", () => {
  const unknownGuest = buildConversionPlan(
    response({guestId: "ghost"}), ctx());
  assert.deepEqual(unknownGuest, {
    functionGuestUpserts: [],
    guestRollup: {guestId: "ghost", rsvpStatus: "declined"},
    rejected: {reason: "unknownGuest"},
  });
  const unknownFunction = buildConversionPlan(
    response({functionId: "ghost"}), ctx());
  assert.equal(unknownFunction.rejected?.reason, "unknownFunction");
  assert.equal(unknownFunction.functionGuestUpserts.length, 0);
});

test("buildConversionPlan rejects cancelled functions", () => {
  const plan = buildConversionPlan(
    response({functionId: "bidaai"}), ctx());
  assert.equal(plan.rejected?.reason, "functionCancelled");
  assert.equal(plan.functionGuestUpserts.length, 0);
});

test("buildConversionPlan rejects the uninvited on selectedGuests", () => {
  const rows = [invitedRow("b", "haldi")];
  const plan = buildConversionPlan(
    response({functionId: "haldi"}), ctx({rows}));
  assert.equal(plan.rejected?.reason, "notInvited");
  // A revoked row is still uninvited.
  const revoked = buildConversionPlan(response({functionId: "haldi"}),
    ctx({rows: [invitedRow("a", "haldi", {invited: false})]}));
  assert.equal(revoked.rejected?.reason, "notInvited");
  // The invited row converts normally.
  const invited = buildConversionPlan(response({functionId: "haldi"}),
    ctx({rows: [invitedRow("a", "haldi")]}));
  assert.equal(invited.rejected, undefined);
  assert.equal(invited.functionGuestUpserts[0].joinKey, "haldi_a");
});

test("allowUninvited converts responses outside the invite list", () => {
  const plan = buildConversionPlan(
    response({functionId: "haldi"}), ctx(), {allowUninvited: true});
  assert.equal(plan.rejected, undefined);
  assert.equal(plan.functionGuestUpserts[0].fields.invited, true);
});
