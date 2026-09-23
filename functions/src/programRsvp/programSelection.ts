import {
  functionsById,
  resolveEffectiveInviteSet,
  type FunctionGuestRowLike,
  type FunctionLike,
  type FunctionLookup,
  type ProgramInvitationStatus,
  type ProgramRsvpStatus,
} from "./functionInvitation";

// Campaign recipient resolution for recipientSource.programSelection:
// pick the program guests invited to any selected function whose
// per-function RSVP sits inside the requested status set, then emit one
// recipient per guest or per household. Field names mirror the
// organizerCampaigns.recipientSource contract; callers translate
// Firestore documents into these shapes.

export interface SelectionGuest {
  guestId: string;
  householdId: string | null;
  phoneE164: string | null;
  invitationStatus: ProgramInvitationStatus;
}

export interface ProgramSelectionFilter {
  // Function ids to draw recipients from; null selects every live
  // function in the program.
  functionIds: ReadonlyArray<string> | null;
  // A guest qualifies when its effective per-function RSVP is one of
  // these statuses on at least one selected function.
  rsvpStatuses: ReadonlyArray<ProgramRsvpStatus>;
  // When true, guests sharing a household collapse into one recipient.
  householdDedupe: boolean;
}

export interface SelectionRecipient {
  // `household:{id}` or `guest:{id}`; stable and sortable.
  recipientKey: string;
  guestIds: string[];
  phoneE164: string;
}

export interface ProgramSelectionResolution {
  recipients: SelectionRecipient[];
  excluded: {
    // Guests qualifying on no selected function.
    notSelected: number;
    // (Function, invitee) pairs filtered out by rsvpStatuses.
    rsvpFiltered: number;
    // Dedupe groups or guests with no phone to send to.
    noPhone: number;
  };
}

export function resolveProgramSelection(
  filter: ProgramSelectionFilter,
  functions: FunctionLookup,
  guests: ReadonlyArray<SelectionGuest>,
  rows: ReadonlyArray<FunctionGuestRowLike>,
): ProgramSelectionResolution {
  const statuses = new Set<string>(filter.rsvpStatuses);
  const index = functionsById(functions);
  const selectedFunctions = pickFunctions(filter.functionIds, index);
  const guestIndex = new Map<string, SelectionGuest>(
    guests.map((guest) => [guest.guestId, guest]));
  const rowByKey = new Map<string, FunctionGuestRowLike>();
  for (const row of rows) {
    rowByKey.set(`${row.functionId}_${row.guestId}`, row);
  }
  // resolveEffectiveInviteSet only reads guestId + invitationStatus; the
  // rollup field is irrelevant here, so a fixed stub keeps the shape.
  const inviteGuests = guests.map((guest) => ({
    guestId: guest.guestId,
    invitationStatus: guest.invitationStatus,
    rsvpStatus: "pending" as ProgramRsvpStatus,
  }));
  // A guest qualifies when any selected function both invites them and
  // carries an effective RSVP inside the requested statuses.
  const qualified = new Set<string>();
  let rsvpFiltered = 0;
  for (const fn of selectedFunctions) {
    const invitees = resolveEffectiveInviteSet(fn, inviteGuests, rows);
    for (const guestId of [...invitees].sort()) {
      const row = rowByKey.get(`${fn.functionId}_${guestId}`);
      const effective = row?.rsvpStatus ?? "pending";
      if (statuses.has(effective)) {
        qualified.add(guestId);
      } else {
        rsvpFiltered += 1;
      }
    }
  }
  const eligible = [...qualified]
    .map((guestId) => guestIndex.get(guestId))
    .filter((guest): guest is SelectionGuest => guest !== undefined)
    .sort((a, b) => a.guestId.localeCompare(b.guestId));
  const {recipients, noPhone} = filter.householdDedupe ?
    dedupeByHousehold(eligible) : perGuest(eligible);
  recipients.sort((a, b) => a.recipientKey.localeCompare(b.recipientKey));
  return {
    recipients,
    excluded: {
      notSelected: guests.length - qualified.size,
      rsvpFiltered,
      noPhone,
    },
  };
}

function pickFunctions(
  functionIds: ReadonlyArray<string> | null,
  index: ReadonlyMap<string, FunctionLike>,
): FunctionLike[] {
  const all = [...index.values()].filter((fn) => fn.status !== "cancelled");
  if (functionIds === null) {
    return all.sort((a, b) => a.functionId.localeCompare(b.functionId));
  }
  const wanted = new Set(functionIds);
  return all
    .filter((fn) => wanted.has(fn.functionId))
    .sort((a, b) => a.functionId.localeCompare(b.functionId));
}

function perGuest(guests: ReadonlyArray<SelectionGuest>): {
  recipients: SelectionRecipient[];
  noPhone: number;
} {
  const recipients: SelectionRecipient[] = [];
  let noPhone = 0;
  for (const guest of guests) {
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
  return {recipients, noPhone};
}

function dedupeByHousehold(guests: ReadonlyArray<SelectionGuest>): {
  recipients: SelectionRecipient[];
  noPhone: number;
} {
  const groups = new Map<string, SelectionGuest[]>();
  for (const guest of guests) {
    const key = guest.householdId === null ?
      `guest:${guest.guestId}` : `household:${guest.householdId}`;
    const group = groups.get(key);
    if (group) group.push(guest); else groups.set(key, [guest]);
  }
  const recipients: SelectionRecipient[] = [];
  let noPhone = 0;
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
  return {recipients, noPhone};
}
