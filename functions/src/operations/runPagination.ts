import {OperationDomainError} from "./errors";
import {OperationRun} from "./models";

export interface RunCursorValue {
  updatedAt: string;
  runId: string;
}

export function compareRunsNewestFirst(
  left: RunCursorValue,
  right: RunCursorValue
): number {
  return right.updatedAt.localeCompare(left.updatedAt) ||
    right.runId.localeCompare(left.runId);
}

export function encodeRunCursor(run: OperationRun): string {
  return Buffer.from(JSON.stringify({
    updatedAt: run.updatedAt,
    runId: run.runId,
  })).toString("base64url");
}

export function decodeRunCursor(cursor: string): RunCursorValue {
  try {
    const parsed = JSON.parse(
      Buffer.from(cursor, "base64url").toString("utf8")
    ) as Record<string, unknown>;
    if (typeof parsed.updatedAt !== "string" ||
        typeof parsed.runId !== "string" ||
        !Number.isFinite(Date.parse(parsed.updatedAt))) {
      throw new Error("invalid run cursor");
    }
    return {updatedAt: parsed.updatedAt, runId: parsed.runId};
  } catch (error) {
    throw new OperationDomainError(
      "invalid_run_cursor",
      `Run cursor is invalid: ${error instanceof Error ?
        error.message : String(error)}`
    );
  }
}
