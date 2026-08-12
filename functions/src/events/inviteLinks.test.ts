import assert from "node:assert/strict";
import test from "node:test";
import {
  attendeeInviteLinkId,
  eventInviteToken,
  inviteLinkTokenHash,
} from "./inviteLinks";

test("attendee referral links are stable and event scoped", () => {
  const first = attendeeInviteLinkId("event-1", "user-1");
  assert.equal(first, attendeeInviteLinkId("event-1", "user-1"));
  assert.notEqual(first, attendeeInviteLinkId("event-2", "user-1"));
  assert.notEqual(first, attendeeInviteLinkId("event-1", "user-2"));
  assert.match(first, /^eal_[a-f0-9]{48}$/u);
});

test("versioned invite bearer tokens are random and hashable", () => {
  const first = eventInviteToken("invite-1");
  const second = eventInviteToken("invite-1");
  assert.notEqual(first, second);
  assert.match(first, /^v2_invite-1_[A-Za-z0-9_-]{43}$/u);
  assert.match(inviteLinkTokenHash(first), /^[a-f0-9]{64}$/u);
  assert.notEqual(inviteLinkTokenHash(first), inviteLinkTokenHash(second));
});
