// Assignment-level work-shell resolution. Each WorkAssignment is one
// explicit context (one program or one event); the switcher changes that
// context rather than unioning duties across assignments.

import {
  resolveScopeDestinations,
  type WorkDestination,
  type WorkDutyLike,
  type WorkScope,
  type WorkShellMode,
} from "./workDestinations";

export interface WorkAssignment {
  scope: WorkScope;
  title: string;
  subtitle?: string;
  organizerName: string;
  duties: WorkDutyLike[];
  expiresAtMillis?: number;
}

export interface ResolvedWorkAssignment extends WorkAssignment {
  destinations: WorkDestination[];
  overflow: WorkDestination[];
  shellMode: WorkShellMode;
}

export type ShellEntryKind = "managerShell" | "workShell" | "none";

export interface ShellEntry {
  kind: ShellEntryKind;
  activeAssignments: ResolvedWorkAssignment[];
}

// Drops expired assignments, orders the rest deterministically by scope
// (kind, then id), and resolves each assignment's own destinations. Duties
// are never combined across assignments: a dispatcher grant on program B
// does not unlock Dispatch inside the greeter context of program A.
export function resolveWorkAssignments(
  assignments: ReadonlyArray<WorkAssignment>,
  now: number,
): ResolvedWorkAssignment[] {
  requireMillis(now);
  const live = assignments.filter((assignment) => {
    if (assignment.expiresAtMillis === undefined) return true;
    requireMillis(assignment.expiresAtMillis);
    // Same expiry convention as program staff grants: an assignment is
    // live until the moment expiresAtMillis is reached.
    return assignment.expiresAtMillis > now;
  });
  const sorted = [...live].sort((a, b) => {
    const kind = a.scope.kind.localeCompare(b.scope.kind);
    return kind !== 0 ? kind : a.scope.id.localeCompare(b.scope.id);
  });
  return sorted.map((assignment) => ({
    ...assignment,
    ...resolveScopeDestinations(assignment.scope, assignment.duties),
  }));
}

// Entry decision for the app shell boundary. Managers always land in the
// manager shell even when they also hold staff assignments; staff land in
// the work shell only while at least one assignment is live.
export function deriveShellEntry(
  assignments: ReadonlyArray<WorkAssignment>,
  now: number,
  isManager: boolean,
): ShellEntry {
  const activeAssignments = resolveWorkAssignments(assignments, now);
  if (isManager) {
    return {kind: "managerShell", activeAssignments};
  }
  return {
    kind: activeAssignments.length > 0 ? "workShell" : "none",
    activeAssignments,
  };
}

function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Work assignment timing must be non-negative safe milliseconds.");
  }
}
