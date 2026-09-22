import assert from "node:assert/strict";
import test from "node:test";
import {
  resolveFunctionGuestRecipients,
  type AudienceGuest,
  type FunctionGuestsAudience,
} from "./momentAudience";

const audience: FunctionGuestsAudience = {
  kind: "functionGuests",
  functionId: "sangeet",
  rsvp: ["attending", "maybe"],
  householdDedupe: true,
};

function guest(partial: Partial<AudienceGuest>): AudienceGuest {
  return {
    guestId: "g", householdId: null, phoneE164: null,
    rsvp: "attending", invitedToFunction: true, ...partial,
  };
}

const guests: AudienceGuest[] = [
  guest({guestId: "gSuresh", householdId: "hhMehta",
    phoneE164: "+911"}),
  guest({guestId: "gKavita", householdId: "hhMehta",
    phoneE164: "+912"}),
  guest({guestId: "gAarav", householdId: "hhMehta"}), // kid, no phone
  guest({guestId: "gPriya", householdId: "hhNair"}), // no phone at all
  guest({guestId: "gRhea", phoneE164: "+913"}), // no household
  guest({guestId: "gDeclined", phoneE164: "+914", rsvp: "declined"}),
  guest({guestId: "gPending", phoneE164: "+915", rsvp: "pending"}),
  guest({guestId: "gMaybe", phoneE164: "+916", rsvp: "maybe"}),
  guest({guestId: "gOut", phoneE164: "+917", invitedToFunction: false}),
];

test("household dedupe sends one message per household", () => {
  const result = resolveFunctionGuestRecipients(audience, guests);
  assert.deepEqual(result.excluded, {
    notInvited: 1, rsvpFiltered: 2, noPhone: 1,
  });
  assert.deepEqual(result.recipients, [
    {recipientKey: "guest:gMaybe", guestIds: ["gMaybe"],
      phoneE164: "+916"},
    {recipientKey: "guest:gRhea", guestIds: ["gRhea"],
      phoneE164: "+913"},
    {recipientKey: "household:hhMehta",
      guestIds: ["gAarav", "gKavita", "gSuresh"], phoneE164: "+912"},
  ]);
});

test("a household where nobody has a phone counts once", () => {
  const result = resolveFunctionGuestRecipients(audience, [
    guest({guestId: "g1", householdId: "hh"}),
    guest({guestId: "g2", householdId: "hh"}),
    guest({guestId: "g3", householdId: "hh2"}),
  ]);
  assert.equal(result.recipients.length, 0);
  assert.equal(result.excluded.noPhone, 2);
});

test("without dedupe every phoned guest is a recipient", () => {
  const result = resolveFunctionGuestRecipients(
    {...audience, householdDedupe: false}, guests);
  assert.equal(result.recipients.length, 4);
  assert.equal(result.excluded.noPhone, 2); // gAarav + gPriya
  assert.deepEqual(result.recipients.map((r) => r.recipientKey),
    ["guest:gKavita", "guest:gMaybe", "guest:gRhea", "guest:gSuresh"]);
});

test("rsvp filter is a strict subset of attending or maybe", () => {
  const attendingOnly = resolveFunctionGuestRecipients(
    {...audience, rsvp: ["attending"]}, guests);
  // gMaybe filtered: Mehta group + gRhea remain.
  assert.deepEqual(attendingOnly.recipients.map((r) => r.recipientKey),
    ["guest:gRhea", "household:hhMehta"]);
});

test("recipient order is deterministic regardless of input order", () => {
  const reversed = [...guests].reverse();
  assert.deepEqual(
    resolveFunctionGuestRecipients(audience, guests),
    resolveFunctionGuestRecipients(audience, reversed));
});
