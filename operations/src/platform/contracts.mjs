import {invariant} from "./errors.mjs";

export const RUN_STATUSES = Object.freeze([
  "planned",
  "running",
  "paused",
  "completed",
  "failed",
  "cancelled",
]);

export const PRIMARY_STAGES = Object.freeze([
  "incoming",
  "verify",
  "resolve",
  "ready",
]);

export const LIFECYCLE_STATUSES = Object.freeze([
  "active",
  "published",
  "rejected",
  "expired",
  "cancelled",
  "taken_down",
]);

const ALLOWED_TRANSITIONS = Object.freeze({
  incoming: new Set(["verify", "resolve", "ready"]),
  verify: new Set(["resolve", "ready"]),
  resolve: new Set(["verify", "ready"]),
  ready: new Set(["resolve"]),
});

export function assertRun(run) {
  invariant(run && typeof run === "object", "INVALID_RUN", "Run must be an object.");
  invariant(validId(run.runId), "INVALID_RUN", "Run has an invalid runId.", {runId: run.runId});
  invariant(RUN_STATUSES.includes(run.status), "INVALID_RUN", "Run has an invalid status.", {status: run.status});
  invariant(run.mode === "shadow", "UNSAFE_MODE", "Only shadow execution is implemented.", {mode: run.mode});
  return run;
}

export function assertWorkItem(item) {
  invariant(item && typeof item === "object", "INVALID_WORK_ITEM", "Work item must be an object.");
  invariant(validId(item.workItemId), "INVALID_WORK_ITEM", "Work item has an invalid id.", {workItemId: item.workItemId});
  invariant(validId(item.runId), "INVALID_WORK_ITEM", "Work item has an invalid run id.", {runId: item.runId});
  invariant(PRIMARY_STAGES.includes(item.primaryStage), "INVALID_WORK_ITEM", "Work item has an invalid primary stage.", {
    stage: item.primaryStage,
  });
  invariant(Array.isArray(item.taskFlags), "INVALID_WORK_ITEM", "Work item taskFlags must be an array.");
  invariant(Array.isArray(item.blockers), "INVALID_WORK_ITEM", "Work item blockers must be an array.");
  invariant(LIFECYCLE_STATUSES.includes(item.lifecycleStatus), "INVALID_WORK_ITEM", "Work item has an invalid lifecycle status.", {
    lifecycleStatus: item.lifecycleStatus,
  });
  invariant(["event", "organizer", "source_result", "source_profile"].includes(item.entityKind), "INVALID_WORK_ITEM", "Work item has an invalid entity kind.", {
    entityKind: item.entityKind,
  });
  invariant(typeof item.sourceEntity?.id === "string", "INVALID_WORK_ITEM", "Work item source entity id is required.");
  invariant(typeof item.sourceEntity?.title === "string", "INVALID_WORK_ITEM", "Work item source entity title is required.");
  invariant(item.decisionProvenance && typeof item.decisionProvenance === "object", "INVALID_WORK_ITEM", "Decision provenance is required.");
  invariant(item.confidence && typeof item.confidence === "object", "INVALID_WORK_ITEM", "Confidence is required.");
  invariant(item.evidence && typeof item.evidence === "object", "INVALID_WORK_ITEM", "Work item evidence is required.");
  return item;
}

export function transitionWorkItem(item, nextStage, {at, reason, taskFlags, blockers} = {}) {
  assertWorkItem(item);
  invariant(PRIMARY_STAGES.includes(nextStage), "INVALID_TRANSITION", "Unknown work-item stage.", {nextStage});
  if (item.primaryStage !== nextStage) {
    invariant(
      ALLOWED_TRANSITIONS[item.primaryStage].has(nextStage),
      "INVALID_TRANSITION",
      `Cannot transition work item from ${item.primaryStage} to ${nextStage}.`,
      {workItemId: item.workItemId, from: item.primaryStage, to: nextStage}
    );
  }
  return {
    ...item,
    primaryStage: nextStage,
    taskFlags: uniqueSorted(taskFlags ?? item.taskFlags),
    blockers: uniqueSorted(blockers ?? item.blockers),
    updatedAt: at,
    stageHistory: [
      ...(item.stageHistory ?? []),
      ...(item.primaryStage === nextStage ? [] : [{from: item.primaryStage, to: nextStage, at, reason}]),
    ],
  };
}

export function validId(value) {
  return typeof value === "string" && /^[a-zA-Z0-9][a-zA-Z0-9._:-]{0,199}$/.test(value);
}

export function safeId(value) {
  const normalized = String(value ?? "")
    .normalize("NFKD")
    .toLowerCase()
    .replace(/[^a-z0-9._:-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 180);
  invariant(validId(normalized), "INVALID_ID", "Value cannot be converted to a safe id.", {value});
  return normalized;
}

export function uniqueSorted(values) {
  return [...new Set((values ?? []).filter(Boolean).map(String))].sort();
}
