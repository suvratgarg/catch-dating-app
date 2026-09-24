import {
  functionsById,
  type FunctionGuestRowLike,
  type FunctionLookup,
  type ProgramFunctionAttendanceStatus,
  type ProgramGuestLike,
  type ProgramRsvpStatus,
} from "./functionInvitation";
import {rollupGuestRsvpForFunctions} from "./rsvpRollup";

// A reviewed guest response (form reply, phone RSVP, organizer entry)
// being converted into per-function truth.
export interface ReviewedResponseLike {
  guestId: string;
  functionId: string;
  rsvpStatus: ProgramRsvpStatus;
  partySize?: number | null;
  responseNote?: string | null;
  // Epoch milliseconds when the response was recorded.
  respondedAt: number;
}

export type GuestLookup =
  ReadonlyArray<ProgramGuestLike> | ReadonlyMap<string, ProgramGuestLike>;

export interface ConversionContext {
  functions: FunctionLookup;
  // Current programFunctionGuests rows for the program; the plan
  // filters them down to the responding guest and to live functions.
  rows: ReadonlyArray<FunctionGuestRowLike>;
  guests: GuestLookup;
}

export interface ConversionOptions {
  // Convert responses for selectedGuests functions the guest was never
  // invited to; the resulting row still lands invited:true.
  allowUninvited?: boolean;
}

// Decision fields for one programFunctionGuests upsert. Callers add
// programId, organizerId, createdAt, updatedAt and revision around
// them; the joinKey is the deterministic document id.
export interface FunctionGuestUpsertFields {
  functionId: string;
  guestId: string;
  invited: true;
  rsvpStatus: ProgramRsvpStatus;
  attendanceStatus: ProgramFunctionAttendanceStatus;
  partySize: number | null;
  responseNote: string | null;
  // Epoch milliseconds; the caller wraps it in its timestamp type.
  respondedAt: number;
}

export interface FunctionGuestUpsert {
  joinKey: string;
  fields: FunctionGuestUpsertFields;
}

export type ConversionRejectionReason =
  "unknownGuest" | "unknownFunction" | "functionCancelled" | "notInvited";

export interface ConversionPlan {
  functionGuestUpserts: FunctionGuestUpsert[];
  // Program-level rollup after this response lands; computed from the
  // unchanged row set on rejection so callers can no-op compare.
  guestRollup: {guestId: string; rsvpStatus: ProgramRsvpStatus};
  rejected?: {reason: ConversionRejectionReason};
}

export function buildConversionPlan(
  response: ReviewedResponseLike,
  ctx: ConversionContext,
  opts?: ConversionOptions,
): ConversionPlan {
  const guests = guestsById(ctx.guests);
  const functions = functionsById(ctx.functions);
  const guestRows = ctx.rows.filter(
    (row) => row.guestId === response.guestId);
  const reject = (reason: ConversionRejectionReason): ConversionPlan => ({
    functionGuestUpserts: [],
    guestRollup: {
      guestId: response.guestId,
      rsvpStatus: rollupGuestRsvpForFunctions(guestRows, functions),
    },
    rejected: {reason},
  });
  if (!guests.has(response.guestId)) return reject("unknownGuest");
  const fn = functions.get(response.functionId);
  if (fn === undefined) return reject("unknownFunction");
  if (fn.status === "cancelled") return reject("functionCancelled");
  const existing = guestRows.find(
    (row) => row.functionId === response.functionId);
  if ((fn.invitationMode ?? "allGuests") === "selectedGuests" &&
      existing?.invited !== true && !opts?.allowUninvited) {
    return reject("notInvited");
  }
  const upsert: FunctionGuestUpsert = {
    joinKey: `${response.functionId}_${response.guestId}`,
    fields: {
      functionId: response.functionId,
      guestId: response.guestId,
      invited: true,
      rsvpStatus: response.rsvpStatus,
      // A re-response never clears door state; new rows start expected.
      // An omitted partySize or note keeps the prior answer — only an
      // explicit null clears it.
      attendanceStatus: existing?.attendanceStatus ?? "expected",
      partySize: response.partySize === undefined ?
        existing?.partySize ?? null : response.partySize,
      responseNote: response.responseNote === undefined ?
        existing?.responseNote ?? null : response.responseNote,
      respondedAt: response.respondedAt,
    },
  };
  // The post-response row set swaps this function's row for the new
  // answer so the rollup reflects the world after the upsert lands.
  const nextRows: FunctionGuestRowLike[] = [
    ...guestRows.filter(
      (row) => row.functionId !== response.functionId),
    {
      functionId: response.functionId,
      guestId: response.guestId,
      invited: true,
      rsvpStatus: response.rsvpStatus,
      attendanceStatus: upsert.fields.attendanceStatus,
      partySize: upsert.fields.partySize,
      responseNote: upsert.fields.responseNote,
      respondedAt: response.respondedAt,
    },
  ];
  return {
    functionGuestUpserts: [upsert],
    guestRollup: {
      guestId: response.guestId,
      rsvpStatus: rollupGuestRsvpForFunctions(nextRows, functions),
    },
  };
}

function guestsById(
  guests: GuestLookup,
): ReadonlyMap<string, ProgramGuestLike> {
  const index = new Map<string, ProgramGuestLike>();
  for (const guest of guests.values()) index.set(guest.guestId, guest);
  return index;
}
