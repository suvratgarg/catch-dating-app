/**
 * Pure per-function attendance report projection for program
 * reconciliation. Rows are the programFunctionGuests join documents:
 * invited/RSVP state plus the door journal's attendanceStatus and
 * partySize. The report separates RSVP truth (who promised what) from
 * door truth (who actually arrived) and lists the exception guest ids a
 * reconciliationViewer or programCoordinator reconciles by hand.
 *
 * No PII is loaded or emitted here — rows are identified by guestId only.
 */

export interface AttendanceGuestRow {
  functionId: string;
  guestId: string;
  invited: boolean;
  rsvpStatus: "pending" | "attending" | "declined" | "maybe";
  attendanceStatus: "expected" | "checkedIn" | "noShow";
  /** Attending party size including children; null reads as 1. */
  partySize?: number | null;
}

export interface FunctionAttendanceExceptions {
  /** Invited guests who never responded — organisers chase these. */
  invitedNoResponseGuestIds: string[];
  /** Declined guests who checked in anyway — capacity reconciliation. */
  declinedCheckedInGuestIds: string[];
  /** Guests marked noShow at the door journal. */
  noShowGuestIds: string[];
  /** Checked-in guests with no invite row — walk-in reconciliation. */
  walkInGuestIds: string[];
}

export interface FunctionAttendanceReport {
  functionId: string;
  invitedGuests: number;
  respondedGuests: number;
  attendingGuests: number;
  attendingHeads: number;
  maybeGuests: number;
  declinedGuests: number;
  noResponseGuests: number;
  checkedInGuests: number;
  checkedInHeads: number;
  noShowGuests: number;
  expectedGuests: number;
  walkInGuests: number;
  walkInHeads: number;
  exceptions: FunctionAttendanceExceptions;
}

export interface ProgramAttendanceReport {
  functions: FunctionAttendanceReport[];
  programGuests: number;
  programInvitedGuests: number;
  programAttendingGuests: number;
  programCheckedInGuests: number;
  programNoShowGuests: number;
}

const heads = (row: AttendanceGuestRow): number => row.partySize ?? 1;

const sorted = (ids: Iterable<string>): string[] =>
  [...new Set(ids)].sort();

function reportFunction(
  functionId: string,
  rows: AttendanceGuestRow[],
): FunctionAttendanceReport {
  const invited = rows.filter((row) => row.invited);
  const attending = invited.filter((row) => row.rsvpStatus === "attending");
  const checkedIn = rows.filter(
    (row) => row.attendanceStatus === "checkedIn");
  const walkIns = checkedIn.filter((row) => !row.invited);
  return {
    functionId,
    invitedGuests: invited.length,
    respondedGuests: invited.filter(
      (row) => row.rsvpStatus !== "pending").length,
    attendingGuests: attending.length,
    attendingHeads: attending.reduce((sum, row) => sum + heads(row), 0),
    maybeGuests: invited.filter((row) => row.rsvpStatus === "maybe").length,
    declinedGuests:
      invited.filter((row) => row.rsvpStatus === "declined").length,
    noResponseGuests: invited.filter(
      (row) => row.rsvpStatus === "pending").length,
    checkedInGuests: checkedIn.length,
    checkedInHeads: checkedIn.reduce((sum, row) => sum + heads(row), 0),
    noShowGuests:
      rows.filter((row) => row.attendanceStatus === "noShow").length,
    expectedGuests:
      rows.filter((row) => row.attendanceStatus === "expected").length,
    walkInGuests: walkIns.length,
    walkInHeads: walkIns.reduce((sum, row) => sum + heads(row), 0),
    exceptions: {
      invitedNoResponseGuestIds: sorted(invited
        .filter((row) => row.rsvpStatus === "pending")
        .map((row) => row.guestId)),
      declinedCheckedInGuestIds: sorted(checkedIn
        .filter((row) => row.invited && row.rsvpStatus === "declined")
        .map((row) => row.guestId)),
      noShowGuestIds: sorted(rows
        .filter((row) => row.attendanceStatus === "noShow")
        .map((row) => row.guestId)),
      walkInGuestIds: sorted(walkIns.map((row) => row.guestId)),
    },
  };
}

/**
 * Build the report for the given function ids, in the order supplied.
 * Rows for unlisted functions are ignored; a listed function with no
 * rows reports zeroes with empty exceptions.
 */
export function buildAttendanceReport(
  functionIds: readonly string[],
  rows: readonly AttendanceGuestRow[],
): ProgramAttendanceReport {
  const byFunction = new Map<string, AttendanceGuestRow[]>();
  for (const row of rows) {
    const list = byFunction.get(row.functionId) ?? [];
    list.push(row);
    byFunction.set(row.functionId, list);
  }
  const functions = functionIds.map((functionId) =>
    reportFunction(functionId, byFunction.get(functionId) ?? []));
  // Program-level uniqueness counts a guest once across functions.
  const guests = new Set<string>();
  const invitedGuests = new Set<string>();
  const attendingGuests = new Set<string>();
  const checkedInGuests = new Set<string>();
  const noShowGuests = new Set<string>();
  for (const row of rows) {
    guests.add(row.guestId);
    if (row.invited) invitedGuests.add(row.guestId);
    if (row.invited && row.rsvpStatus === "attending") {
      attendingGuests.add(row.guestId);
    }
    if (row.attendanceStatus === "checkedIn") checkedInGuests.add(row.guestId);
    if (row.attendanceStatus === "noShow") noShowGuests.add(row.guestId);
  }
  return {
    functions,
    programGuests: guests.size,
    programInvitedGuests: invitedGuests.size,
    programAttendingGuests: attendingGuests.size,
    programCheckedInGuests: checkedInGuests.size,
    programNoShowGuests: noShowGuests.size,
  };
}
