// stakeholderViewer counts projection (rollout spec decision: headcounts +
// per-hotel occupancy, names never). Pure resolver over row-like inputs —
// callers translate Firestore documents into these shapes; the module never
// touches the database and never emits PII (no names, phones, or notes).

export type ProgramRsvpStatus = "pending" | "attending" | "declined" | "maybe";
export type ProgramInvitationStatus =
  "notInvited" | "invited" | "delivered" | "responded";
export type FunctionAttendanceStatus = "expected" | "checkedIn" | "noShow";
export type FunctionInvitationMode = "allGuests" | "selectedGuests";
export type FunctionStatus = "scheduled" | "completed" | "cancelled";
export type LegReadiness =
  "expected" | "ready" | "dispatched" | "arrived" | "disrupted" | "noShow";

export interface StakeholderGuestRow {
  guestId: string;
  householdId: string | null;
  invitationStatus: ProgramInvitationStatus;
}

export interface StakeholderFunctionRow {
  functionId: string;
  // Absent on functions written before per-function invitations existed;
  // reads as "allGuests".
  invitationMode: FunctionInvitationMode | null;
  status: FunctionStatus;
}

export interface StakeholderFunctionGuestRow {
  functionId: string;
  guestId: string;
  invited: boolean;
  rsvpStatus: ProgramRsvpStatus;
  attendanceStatus: FunctionAttendanceStatus;
  // Attending party size including children; null reads as 1.
  partySize: number | null;
}

export interface StakeholderLegRow {
  legId: string;
  guestId: string;
  // Only legs routed at a programHotels doc count toward occupancy.
  destinationHotelId: string | null;
  passengers: number;
  readiness: LegReadiness;
}

export interface StakeholderHouseholdRow {
  householdId: string;
}

export interface FunctionAttendanceCounts {
  functionId: string;
  status: FunctionStatus;
  // Invited guests: every program guest for allGuests functions, else the
  // functionGuests rows marked invited.
  invitedCount: number;
  // RSVP histogram over invited guests. Guests without a functionGuests row
  // (possible on allGuests functions) count as pending.
  rsvpPending: number;
  rsvpAttending: number;
  rsvpDeclined: number;
  rsvpMaybe: number;
  // Heads = sum of partySize (null→1) over attending guests.
  expectedHeads: number;
  // Heads checked in at the door (attendanceStatus=checkedIn).
  checkedInHeads: number;
  // Guests marked noShow after the function ended.
  noShowCount: number;
}

export interface HotelOccupancyCounts {
  hotelId: string;
  // Distinct guests with at least one leg routed to this hotel — a guest
  // with an inbound flight plus a ground transfer counts once.
  routedGuestCount: number;
  // Distinct routed guests with at least one hotel-bound leg already
  // arrived.
  arrivedGuestCount: number;
  legCount: number;
}

export interface StakeholderCounts {
  guestCount: number;
  householdCount: number;
  functions: FunctionAttendanceCounts[];
  hotels: HotelOccupancyCounts[];
}

export function computeStakeholderCounts(params: {
  guests: ReadonlyArray<StakeholderGuestRow>;
  households: ReadonlyArray<StakeholderHouseholdRow>;
  functions: ReadonlyArray<StakeholderFunctionRow>;
  functionGuests: ReadonlyArray<StakeholderFunctionGuestRow>;
  legs: ReadonlyArray<StakeholderLegRow>;
}): StakeholderCounts {
  const functionRowsByFunction = new Map<
    string, StakeholderFunctionGuestRow[]>();
  for (const row of params.functionGuests) {
    const list = functionRowsByFunction.get(row.functionId) ?? [];
    list.push(row);
    functionRowsByFunction.set(row.functionId, list);
  }

  const functions = params.functions.map((fn) => {
    const rows = functionRowsByFunction.get(fn.functionId) ?? [];
    const allGuests = (fn.invitationMode ?? "allGuests") === "allGuests";
    const invitedGuests = allGuests ?
      params.guests :
      params.guests.filter((guest) => rows.some(
        (row) => row.guestId === guest.guestId && row.invited));
    const counts: FunctionAttendanceCounts = {
      functionId: fn.functionId,
      status: fn.status,
      invitedCount: invitedGuests.length,
      rsvpPending: 0,
      rsvpAttending: 0,
      rsvpDeclined: 0,
      rsvpMaybe: 0,
      expectedHeads: 0,
      checkedInHeads: 0,
      noShowCount: 0,
    };
    for (const guest of invitedGuests) {
      const row = rows.find((r) => r.guestId === guest.guestId);
      // allGuests guests may have no row until they respond; they read as
      // pending. A selectedGuests row with invited=false still carries its
      // response state for reconciliation.
      const rsvp = row?.rsvpStatus ?? "pending";
      if (rsvp === "attending") counts.rsvpAttending += 1;
      else if (rsvp === "declined") counts.rsvpDeclined += 1;
      else if (rsvp === "maybe") counts.rsvpMaybe += 1;
      else counts.rsvpPending += 1;
      if (rsvp === "attending") counts.expectedHeads += row?.partySize ?? 1;
      if (row?.attendanceStatus === "checkedIn") {
        counts.checkedInHeads += row.partySize ?? 1;
      }
      if (row?.attendanceStatus === "noShow") counts.noShowCount += 1;
    }
    return counts;
  });

  const hotelLegs = new Map<string, StakeholderLegRow[]>();
  for (const leg of params.legs) {
    if (leg.destinationHotelId === null) continue;
    const list = hotelLegs.get(leg.destinationHotelId) ?? [];
    list.push(leg);
    hotelLegs.set(leg.destinationHotelId, list);
  }
  const hotels = [...hotelLegs.entries()].map(([hotelId, legs]) => {
    const routed = new Set<string>();
    const arrived = new Set<string>();
    for (const leg of legs) {
      routed.add(leg.guestId);
      if (leg.readiness === "arrived") arrived.add(leg.guestId);
    }
    return {
      hotelId,
      routedGuestCount: routed.size,
      arrivedGuestCount: arrived.size,
      legCount: legs.length,
    };
  }).sort((a, b) => a.hotelId.localeCompare(b.hotelId));

  return {
    guestCount: params.guests.length,
    householdCount: params.households.length,
    functions,
    hotels,
  };
}
