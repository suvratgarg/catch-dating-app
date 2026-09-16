import {HttpsError} from "firebase-functions/v2/https";
import type {EventStaffGrantDocument} from
  "../../shared/generated/firestoreAdminTypes";

export type GroupDuty =
  NonNullable<EventStaffGrantDocument["groupDuties"]>[number];
export const GROUP_PERMISSIONS = ["readProgress", "confirmDeparture",
  "transferGroup", "recordCheckpoint", "resolveAccountability"] as const;
export type GroupPermission = typeof GROUP_PERMISSIONS[number];
export const GROUP_DUTY_PERMISSIONS = {
  lead: ["readProgress", "confirmDeparture", "transferGroup",
    "recordCheckpoint", "resolveAccountability"],
  pacer: ["readProgress", "confirmDeparture", "transferGroup",
    "recordCheckpoint", "resolveAccountability"],
  sweep: ["readProgress", "recordCheckpoint", "resolveAccountability"],
} as const satisfies Record<GroupDuty["duty"], readonly GroupPermission[]>;

export function availableGroupDuties(paceGroup: boolean): GroupDuty["duty"][] {
  return paceGroup ? ["lead", "pacer", "sweep"] : ["lead", "sweep"];
}

/** Adapters supply their own clock and lifecycle; the duty window is shared. */
export function assertGroupDutyAssignment(state: {canAssign: boolean;
  paceGroup: boolean; now: number; endAt: number},
decision: Pick<GroupDuty, "duty" | "expiresAtMillis">) {
  if (!state.canAssign ||
      !availableGroupDuties(state.paceGroup).includes(decision.duty) ||
      decision.expiresAtMillis <= state.now ||
      decision.expiresAtMillis > Math.min(state.now + 14 * 86400000,
        state.endAt + 14400000)) {
    throw new HttpsError("failed-precondition",
      "Choose a current group and access within the event staff window.");
  }
}
