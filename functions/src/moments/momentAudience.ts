export interface AudienceGuest {
  guestId: string;
  householdId: string | null;
  phoneE164: string | null;
  rsvp: "pending" | "attending" | "declined" | "maybe";
  invitedToFunction: boolean;
}

export interface FunctionGuestsAudience {
  kind: "functionGuests";
  functionId: string;
  rsvp: ReadonlyArray<"attending" | "maybe">;
  householdDedupe: boolean;
}

export interface AudienceRecipient {
  recipientKey: string;
  guestIds: string[];
  phoneE164: string;
}

export interface AudienceResolution {
  recipients: AudienceRecipient[];
  excluded: {
    notInvited: number;
    rsvpFiltered: number;
    noPhone: number;
  };
}

export function resolveFunctionGuestRecipients(
  audience: FunctionGuestsAudience,
  guests: ReadonlyArray<AudienceGuest>,
): AudienceResolution {
  const invited = guests.filter((guest) => guest.invitedToFunction);
  const notInvited = guests.length - invited.length;
  const eligible = invited.filter((guest) =>
    (audience.rsvp as ReadonlyArray<string>).includes(guest.rsvp));
  const rsvpFiltered = invited.length - eligible.length;
  const sorted = [...eligible].sort((a, b) =>
    a.guestId.localeCompare(b.guestId));
  const recipients: AudienceRecipient[] = [];
  let noPhone = 0;
  if (audience.householdDedupe) {
    const groups = new Map<string, AudienceGuest[]>();
    for (const guest of sorted) {
      const key = guest.householdId === null ?
        `guest:${guest.guestId}` : `household:${guest.householdId}`;
      const group = groups.get(key);
      if (group) group.push(guest); else groups.set(key, [guest]);
    }
    for (const [key, members] of groups) {
      const phone = members.map((member) => member.phoneE164)
        .find((value) => value !== null);
      if (phone === undefined) {
        noPhone += 1;
        continue;
      }
      recipients.push({
        recipientKey: key,
        guestIds: members.map((member) => member.guestId),
        phoneE164: phone,
      });
    }
  } else {
    for (const guest of sorted) {
      if (guest.phoneE164 === null) {
        noPhone += 1;
        continue;
      }
      recipients.push({
        recipientKey: `guest:${guest.guestId}`,
        guestIds: [guest.guestId],
        phoneE164: guest.phoneE164,
      });
    }
  }
  recipients.sort((a, b) => a.recipientKey.localeCompare(b.recipientKey));
  return {
    recipients,
    excluded: {notInvited, rsvpFiltered, noPhone},
  };
}
