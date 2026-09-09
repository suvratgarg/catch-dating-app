import type {
  EventRehearsalActorDocument as Actor,
} from "../shared/generated/firestoreAdminTypes";

type Visit = NonNullable<Actor["visit"]>;
export function initialPracticeVisit(): Visit {
  return {
    attendanceRevision: 0,
    checkedInAtMillis: null,
    accountabilityRevision: 0,
    resolution: null,
  };
}
export function practiceAttendance(actor: Pick<Actor, "status">) {
  return actor.status === "disconnected" ?
    "unknown" :
    ["present", "late", "returned"].includes(actor.status) ?
      "checkedIn" :
      "notCheckedIn";
}

/** Only an observed physical transition creates a new synthetic visit. */
export function advancePracticeVisit(
  before: Actor,
  after: Actor,
  at: number,
  observesArrival: boolean
): Actor {
  const was = practiceAttendance(before);
  const next = practiceAttendance(after);
  const prior = before.visit;
  if (
    next === "unknown" ||
    (was === next &&
      !(
        observesArrival &&
        prior?.checkedInAtMillis == null &&
        next === "checkedIn"
      ))
  ) {
    return after;
  }
  if (
    !Number.isSafeInteger(at) ||
    at < 0 ||
    (prior && !validPracticeVisit(prior, 0, at))
  ) {
    throw new Error("Invalid synthetic visit transition.");
  }
  const visit = prior ?? initialPracticeVisit();
  if (visit.attendanceRevision >= Number.MAX_SAFE_INTEGER) {
    throw new Error("Synthetic attendance revision exhausted.");
  }
  return {
    ...after,
    visit: {
      ...visit,
      attendanceRevision: visit.attendanceRevision + 1,
      checkedInAtMillis: next === "checkedIn" ? at : null,
    },
  };
}

/** Stored resolutions may remain historical after another physical visit. */
export function validPracticeVisit(
  visit: Visit,
  start: number,
  now: number
) {
  const integer = (n: number) => Number.isSafeInteger(n) && n >= 0;
  if (
    !integer(visit.attendanceRevision) ||
    !integer(visit.accountabilityRevision) ||
    (visit.checkedInAtMillis !== null &&
      (!integer(visit.checkedInAtMillis) ||
        visit.attendanceRevision === 0 ||
        visit.checkedInAtMillis < start ||
        visit.checkedInAtMillis > now))
  ) {
    return false;
  }
  const r = visit.resolution;
  return (
    r === null ||
    (visit.accountabilityRevision > 0 &&
      integer(r.visitRevision) &&
      r.visitRevision > 0 &&
      r.visitRevision <= visit.attendanceRevision &&
      (r.visitRevision !== visit.attendanceRevision ||
        r.checkedInAtMillis === visit.checkedInAtMillis) &&
      integer(r.checkedInAtMillis) &&
      integer(r.resolvedAtMillis) &&
      r.checkedInAtMillis >= start &&
      r.resolvedAtMillis >= r.checkedInAtMillis &&
      r.resolvedAtMillis <= now &&
      ["returned", "departed"].includes(r.disposition) &&
      typeof r.resolvedBy === "string" &&
      r.resolvedBy.length > 0)
  );
}
