import * as admin from "firebase-admin";
import {harness, departure, Command} from "./movementTestFixtures";
import {practiceAccountabilityView, resolvePracticeAccountability} from
  "./accountability";
import type {Review} from "./movementSource";
type Harness = ReturnType<typeof harness>;
export function reassign(r: Review, owner = "host-1"): Command {
  const c = r.checkpoint!;
  return {kind: "reassignCheckpointReporter",
    expectedSourceHash: c.assignment!.sourceHash,
    payload: {groupId: r.groupId, checkpointId: c.checkpointId,
      expectedProgressRevision: c.progressRevision,
      expectedAssignmentRevision: c.assignment!.revision,
      responsibleOperatorId: owner, reason: "  Taking over the report.  "}};
}
export function closeout(r: Review,
  decision: "close" | "reopen" = "close"): Command {
  const c = r.checkpoint!;
  return {kind: "setCheckpointCloseout",
    expectedSourceHash: c.closeout!.sourceHash,
    payload: {groupId: r.groupId, checkpointId: c.checkpointId,
      expectedProgressRevision: c.progressRevision,
      expectedCloseoutRevision: c.closeout!.revision,
      decision, reason: "  Reviewed every outstanding guest.  "}};
}
export function resolve(h: Harness, i = 1,
  disposition: "returned" | "departed" | "unresolved" = "departed") {
  const row = practiceAccountabilityView(h.session, h.actors[i]);
  h.actors[i] = resolvePracticeAccountability(h.session, h.actors[i], {
    kind: "resolveAccountability", actorId: row.attendeeId,
    expectedSourceHash: row.sourceHash, payload: {attendeeId: row.attendeeId,
      episodeId: row.episodeId!, disposition}}, h.authority);
}
export async function ready(group = false) {
  const h = harness(0, "session-1");
  h.session.virtualNow = admin.firestore.Timestamp.fromMillis(1000);
  h.session.setup.moduleIds.push("accountability");
  h.arrive(); h.arrive(1);
  if (group) {
    h.group(); h.place(); h.place(1);
  }
  const scope = {groupId: group ? "easy" : "event:whole"};
  await h.execute(departure(await h.read(scope),
    h.actors.map((a) => a.actorId), true), "departure_0001");
  return {...h, scope, current: () => h.read(scope)};
}
