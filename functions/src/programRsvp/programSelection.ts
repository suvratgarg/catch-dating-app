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
  // The member whose phoneE164 the send targets; dispatch re-reads this
  // guest to catch an endpoint change between approval and send.
  endpointGuestId: string;
  // The household backing this recipient for consent checks, or null
  // when a dedupe-off guest has no household.
  householdId: string | null;
  phoneE164: string;
}

// A resolved-but-unreachable recipient identity: the dedupe group (or
// single guest) qualified on every filter yet had no phone to send to.
// Emitting the identity lets callers materialize suppressed recipient
// rows for audit parity with CRM exclusions instead of only a count.
export interface SelectionNoPhone {
  recipientKey: string;
  guestIds: string[];
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
  noPhoneRecipients: SelectionNoPhone[];
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
  const {recipients, noPhoneRecipients} = filter.householdDedupe ?
    dedupeByHousehold(eligible) : perGuest(eligible);
  recipients.sort((a, b) => a.recipientKey.localeCompare(b.recipientKey));
  noPhoneRecipients.sort((a, b) =>
    a.recipientKey.localeCompare(b.recipientKey));
  return {
    recipients,
    excluded: {
      notSelected: guests.length - qualified.size,
      rsvpFiltered,
      noPhone: noPhoneRecipients.length,
    },
    noPhoneRecipients,
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
  noPhoneRecipients: SelectionNoPhone[];
} {
  const recipients: SelectionRecipient[] = [];
  const noPhoneRecipients: SelectionNoPhone[] = [];
  for (const guest of guests) {
    const recipientKey = `guest:${guest.guestId}`;
    if (guest.phoneE164 === null) {
      noPhoneRecipients.push({recipientKey, guestIds: [guest.guestId]});
      continue;
    }
    recipients.push({
      recipientKey,
      guestIds: [guest.guestId],
      endpointGuestId: guest.guestId,
      householdId: guest.householdId,
      phoneE164: guest.phoneE164,
    });
  }
  return {recipients, noPhoneRecipients};
}

function dedupeByHousehold(guests: ReadonlyArray<SelectionGuest>): {
  recipients: SelectionRecipient[];
  noPhoneRecipients: SelectionNoPhone[];
} {
  const groups = new Map<string, SelectionGuest[]>();
  for (const guest of guests) {
    const key = guest.householdId === null ?
      `guest:${guest.guestId}` : `household:${guest.householdId}`;
    const group = groups.get(key);
    if (group) group.push(guest); else groups.set(key, [guest]);
  }
  const recipients: SelectionRecipient[] = [];
  const noPhoneRecipients: SelectionNoPhone[] = [];
  for (const [key, members] of groups) {
    const endpoint = members.find((member) => member.phoneE164 !== null);
    if (endpoint === undefined) {
      noPhoneRecipients.push({
        recipientKey: key,
        guestIds: members.map((member) => member.guestId),
      });
      continue;
    }
    recipients.push({
      recipientKey: key,
      guestIds: members.map((member) => member.guestId),
      endpointGuestId: endpoint.guestId,
      householdId: key.startsWith("household:") ?
        key.slice("household:".length) : null,
      phoneE164: endpoint.phoneE164!,
    });
  }
  return {recipients, noPhoneRecipients};
}
