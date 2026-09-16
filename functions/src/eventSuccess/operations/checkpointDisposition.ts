import {operationContentHash} from "../../operations/durableActions";
import {validateEventAttendeeDocument} from
  "../../shared/generated/validators/eventAttendeeDocument";
import {currentAccountabilityResolution} from "../accountability";
import {timestampEvidence} from "./groupProgressSource";
import type {Response, Roster, Visit} from "./checkpointRecords";

type Member = Extract<Response["view"]["availability"],
  {kind: "ready"}>["members"][number];
export type CheckpointDisposition = NonNullable<Member["disposition"]>;

/** Explains non-arrival without adding a checkpoint observation. */
export function checkpointDisposition(roster: Roster,
  member: Roster["members"][number], visit: Visit, value: unknown,
  now: number): CheckpointDisposition {
  if (visit.kind === "unavailable") return visit;
  const unavailable = (reason: "invalidSource" | "beforeDeparture") =>
    ({kind: "unavailable" as const, reason});
  if (!Number.isSafeInteger(now) || now < roster.confirmedAt ||
      !validateEventAttendeeDocument(value)) {
    return unavailable("invalidSource");
  }
  const disposition = currentAccountabilityResolution(value);
  if (!disposition) return {kind: "unresolved"};
  const revision = value.accountabilityRevision ?? 0;
  if (!value.accountabilityResolvedAt || !value.accountabilityResolvedBy ||
      !Number.isSafeInteger(revision) || revision < 1) {
    return unavailable("invalidSource");
  }
  try {
    const at = timestampEvidence(value.accountabilityResolvedAt);
    const millis = at._seconds * 1000 + at._nanoseconds / 1_000_000;
    if (millis > now || millis < 0) return unavailable("invalidSource");
    if (millis < roster.confirmedAt) return unavailable("beforeDeparture");
    return {kind: "resolved", disposition, revision,
      resolvedAt: Math.floor(millis),
      resolvedBy: value.accountabilityResolvedBy,
      sourceHash: operationContentHash([roster.rosterId, member, disposition,
        revision, at, value.accountabilityResolvedBy,
        timestampEvidence(value.accountabilityResolvedForCheckInAt)])};
  } catch {
    // Only malformed timestamp evidence is caught, never a database read.
    return unavailable("invalidSource");
  }
}
