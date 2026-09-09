import type {EventRehearsalActorDocument as Actor} from
  "../shared/generated/firestoreAdminTypes";

type Participation = NonNullable<Actor["participation"]>;
export function initialPracticeParticipation(): Participation {
  return {revision: 0, episodeRevision: 0, state: "active"};
}
function participationStatus(status: Actor["status"]) {
  if (status === "disconnected") return null;
  if (["walkIn", "ambiguousClaim"].includes(status)) return "pending";
  return ["departed", "noShow"].includes(status) ? "departed" : "active";
}
export function validPracticeParticipation(actor: Actor) {
  const p = actor.participation;
  return !!p && Number.isSafeInteger(p.revision) && p.revision >= 0 &&
    Number.isSafeInteger(p.episodeRevision) && p.episodeRevision >= 0 &&
    p.episodeRevision <= p.revision &&
    p.state === participationStatus(actor.status);
}
/** Arrival, connectivity, social opt-out and seating do not imply re-entry. */
export function advancePracticeParticipation(before: Actor, after: Actor):
  Actor {
  const p = before.participation;
  // Legacy participation stays unknown until the session is reset.
  if (!p || before.status === after.status) return after;
  if (!validPracticeParticipation(before)) {
    throw new Error("Invalid synthetic participation source.");
  }
  const state = participationStatus(after.status);
  if (state === null || state === p.state) return after;
  if (p.revision >= Number.MAX_SAFE_INTEGER) {
    throw new Error("Synthetic participation revision exhausted.");
  }
  return {...after, participation: {state, revision: p.revision + 1,
    episodeRevision: p.episodeRevision + (state === "active" ? 1 : 0)}};
}
