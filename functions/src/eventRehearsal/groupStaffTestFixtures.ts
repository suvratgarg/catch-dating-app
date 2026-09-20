import {randomUUID} from "node:crypto";
import {harness, Command} from "./movementTestFixtures";
import {preparePracticeStaffChange, practiceStaffProjection,
  practiceRoleAuthority} from "./groupStaff";
import {preparePracticeMovementCommand, practiceMovementReview} from
  "./movement";
import type {ControlEventRehearsalCallablePayload as Control} from
  "../shared/generated/controlEventRehearsalCallablePayload";
import type {PracticeCaseAuthority} from "./assistanceCases";
import type {MovementScope} from "./movementRecords";
export type Harness = ReturnType<typeof harness>;
export const pacer = "practice-staff:pacer";
export const sweep = "practice-staff:sweep";
export const receiver = "practice-staff:receiver";

export function staffCommand(h: Harness, operatorId = pacer, groupId = "easy",
  duty: "lead" | "pacer" | "sweep" = "pacer",
  expiresAtMillis = h.session.virtualNow.toMillis() + 3600000):
  NonNullable<Control["staff"]> {
  const view = practiceStaffProjection(h.id, h.session, h.authority);
  return {operatorId, displayName: operatorId.split(":")[1], groupId,
    expectedRevision: view.revision, expectedSourceHash: view.sourceHash,
    decision: {kind: "assign", duty, expiresAtMillis}};
}
export function assign(h: Harness, operatorId = pacer, groupId = "easy",
  duty: "lead" | "pacer" | "sweep" = "pacer",
  expiresAtMillis?: number) {
  h.session.staff = preparePracticeStaffChange(h.id, h.session, h.authority,
    staffCommand(h, operatorId, groupId, duty, expiresAtMillis));
  h.session.runtimeRevision++; h.session.actionCount++;
}
export function role(h: Harness, operatorId = pacer) {
  return practiceRoleAuthority(h.id, h.session, h.authority, operatorId);
}
export function roleRead(h: Harness, authority = role(h),
  scope: MovementScope = {groupId: "easy"}) {
  return h.db.runTransaction((tx) => practiceMovementReview(h.db, tx, h.id,
    h.session, h.actors, scope, authority));
}
export async function roleMove(h: Harness, command: Command,
  authority: PracticeCaseAuthority = role(h),
  operationId: string = randomUUID()) {
  await h.db.runTransaction(async (tx) => {
    const change = await preparePracticeMovementCommand(h.db, tx, h.id,
      h.session, h.actors, command, authority, operationId);
    change.commit();
  });
  h.session.runtimeRevision++; h.session.actionCount++;
}
export function room() {
  const h = harness(1000, "practice-room"); h.group();
  h.session.setup.movementSimulation!.routePlan!.paceGroups!.push({id: "fast",
    label: "Fast pace", sortOrder: 1});
  h.session.setup.moduleIds.push("accountability");
  h.arrive(); h.arrive(1); h.place(); h.place(1);
  assign(h); assign(h, sweep, "easy", "sweep");
  assign(h, receiver, "fast");
  return h;
}
