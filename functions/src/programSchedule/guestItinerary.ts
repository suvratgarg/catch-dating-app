import {
  groupFunctionsByDay,
  isCancelledFunction,
  orderFunctions,
  type ProgramFunctionLike,
} from "./programTimeline";

export type ProgramInvitationStatus =
  "notInvited" | "invited" | "delivered" | "responded";

export type ProgramRsvpStatus =
  "pending" | "attending" | "declined" | "maybe";

export interface ProgramGuestLike {
  guestId: string;
  displayName: string;
  householdId?: string | null;
  invitationStatus: ProgramInvitationStatus;
  rsvpStatus: ProgramRsvpStatus;
}

// Forward-compatible per-function RSVP override record. The
// programFunctionGuests collection is planned but not yet in the schema.
export interface FunctionRsvpLike {
  functionId: string;
  guestId: string;
  rsvpStatus: ProgramRsvpStatus;
}

export type ItineraryEntryStatus =
  "invited" | "attending" | "declined" | "pending";

export interface GuestItineraryEntry {
  functionId: string;
  name: string;
  dayLabel: string;
  startsAt: number;
  endsAt: number;
  venueName: string | null;
  status: ItineraryEntryStatus;
}

export interface HouseholdItineraryEntry {
  functionId: string;
  name: string;
  dayLabel: string;
  startsAt: number;
  endsAt: number;
  venueName: string | null;
  guests: ReadonlyArray<{
    guestId: string;
    displayName: string;
    status: ItineraryEntryStatus;
  }>;
}

export function isInvitedGuest(guest: ProgramGuestLike): boolean {
  // Schema enum is notInvited|invited|delivered|responded; only
  // "notInvited" keeps a guest off every function list.
  return guest.invitationStatus !== "notInvited";
}

export function resolveFunctionRsvp(
  guest: ProgramGuestLike,
  functionId: string,
  overrides: ReadonlyArray<FunctionRsvpLike>,
): ProgramRsvpStatus {
  // A per-function override wins over the program-wide RSVP.
  for (const override of overrides) {
    if (override.functionId === functionId &&
        override.guestId === guest.guestId) {
      return override.rsvpStatus;
    }
  }
  return guest.rsvpStatus;
}

export function resolveItineraryStatus(
  rsvpStatus: ProgramRsvpStatus,
): ItineraryEntryStatus {
  // "pending" means invited but unanswered; "maybe" is a tentative
  // answer that still counts as a pending commitment.
  switch (rsvpStatus) {
  case "attending":
    return "attending";
  case "declined":
    return "declined";
  case "maybe":
    return "pending";
  case "pending":
    return "invited";
  }
}

export function buildGuestItinerary(
  guest: ProgramGuestLike,
  functions: ReadonlyArray<ProgramFunctionLike>,
  overrides: ReadonlyArray<FunctionRsvpLike>,
  timeZone: string,
): GuestItineraryEntry[] {
  if (!isInvitedGuest(guest)) return [];
  const active = orderFunctions(
    functions.filter((fn) => !isCancelledFunction(fn)));
  const dayLabels = dayLabelsByFunction(active, timeZone);
  return active.map((fn) => ({
    functionId: fn.functionId,
    name: fn.name,
    dayLabel: dayLabels.get(fn.functionId) ?? "",
    startsAt: fn.startsAt,
    endsAt: fn.endsAt,
    venueName: fn.venueName ?? null,
    status: resolveItineraryStatus(
      resolveFunctionRsvp(guest, fn.functionId, overrides)),
  }));
}

export function buildHouseholdItinerary(
  guests: ReadonlyArray<ProgramGuestLike>,
  functions: ReadonlyArray<ProgramFunctionLike>,
  overrides: ReadonlyArray<FunctionRsvpLike>,
  timeZone: string,
): HouseholdItineraryEntry[] {
  const members = guests.filter(isInvitedGuest);
  if (members.length === 0) return [];
  const active = orderFunctions(
    functions.filter((fn) => !isCancelledFunction(fn)));
  const dayLabels = dayLabelsByFunction(active, timeZone);
  return active.map((fn) => ({
    functionId: fn.functionId,
    name: fn.name,
    dayLabel: dayLabels.get(fn.functionId) ?? "",
    startsAt: fn.startsAt,
    endsAt: fn.endsAt,
    venueName: fn.venueName ?? null,
    guests: members.map((guest) => ({
      guestId: guest.guestId,
      displayName: guest.displayName,
      status: resolveItineraryStatus(
        resolveFunctionRsvp(guest, fn.functionId, overrides)),
    })),
  }));
}

function dayLabelsByFunction(
  functions: ReadonlyArray<ProgramFunctionLike>,
  timeZone: string,
): Map<string, string> {
  const labels = new Map<string, string>();
  for (const group of groupFunctionsByDay(functions, timeZone)) {
    for (const fn of group.functions) {
      labels.set(fn.functionId, group.label);
    }
  }
  return labels;
}
