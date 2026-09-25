import {
  isInvitedGuest,
  resolveFunctionRsvp,
  type FunctionRsvpLike,
  type ProgramGuestLike,
} from "./guestItinerary";

export interface FunctionHeadcount {
  invited: number;
  attending: number;
  declined: number;
  pending: number;
}

export function countFunctionHeads(
  functionId: string,
  guests: ReadonlyArray<ProgramGuestLike>,
  overrides: ReadonlyArray<FunctionRsvpLike>,
): FunctionHeadcount {
  const headcount: FunctionHeadcount = {
    invited: 0,
    attending: 0,
    declined: 0,
    pending: 0,
  };
  for (const guest of guests) {
    // The invitation enum is notInvited|invited|delivered|responded;
    // only invited guests count toward a function's headcount.
    if (!isInvitedGuest(guest)) continue;
    headcount.invited += 1;
    const rsvp = resolveFunctionRsvp(guest, functionId, overrides);
    if (rsvp === "attending") {
      headcount.attending += 1;
    } else if (rsvp === "declined") {
      headcount.declined += 1;
    } else {
      // "pending" and "maybe" both count as pending commitments.
      headcount.pending += 1;
    }
  }
  return headcount;
}
