import {describe, expect, it} from "vitest";

import type {
  AdminActionExecutionRecord,
  AdminListActionExecutionsResponse,
} from "../../../shared/types/adminTypes";
import {
  filterAdminActionExecutions,
  mergeAdminActionExecutionPages,
} from "./useAdminActionExecutionsController";

const execution = (
  executionId: string,
  actionId: string,
  status: AdminActionExecutionRecord["status"]
): AdminActionExecutionRecord => ({
  schemaVersion: 1,
  executionId,
  actionId,
  callable: "adminGetOverview",
  actorUid: "agent-a",
  actorRoles: ["admin"],
  status,
  requestHash: "a".repeat(64),
  responseHash: status === "succeeded" ? "b".repeat(64) : null,
  target: actionId === "events.update" ? "event-1" : null,
  errorCode: status === "failed" ? "aborted" : null,
  errorMessage: status === "failed" ? "State changed" : null,
  cliVersion: "1.0.0",
  startedAt: "2026-07-23T10:00:00.000Z",
  finishedAt: status === "started" ? null : "2026-07-23T10:00:01.000Z",
  updatedAt: "2026-07-23T10:00:01.000Z",
});

describe("admin action execution controller helpers", () => {
  it("filters by action, status, and searchable evidence", () => {
    const rows = [
      execution("11111111-1111-4111-8111-111111111111", "events.update", "failed"),
      execution("22222222-2222-4222-8222-222222222222", "overview.get", "succeeded"),
    ];
    expect(filterAdminActionExecutions(rows, {
      actionFilter: "events.update",
      query: "state changed",
      statusFilter: "failed",
    })).toEqual([rows[0]]);
  });

  it("merges pages without duplicating execution ids", () => {
    const shared = execution(
      "11111111-1111-4111-8111-111111111111",
      "events.update",
      "started"
    );
    const current: AdminListActionExecutionsResponse = {
      schemaVersion: 1,
      generatedAt: "2026-07-23T10:00:00.000Z",
      rows: [shared],
      nextCursor: "page-2",
    };
    const page: AdminListActionExecutionsResponse = {
      schemaVersion: 1,
      generatedAt: "2026-07-23T10:01:00.000Z",
      rows: [
        {...shared, status: "succeeded", responseHash: "b".repeat(64)},
        execution(
          "22222222-2222-4222-8222-222222222222",
          "overview.get",
          "succeeded"
        ),
      ],
      nextCursor: null,
    };
    const merged = mergeAdminActionExecutionPages(current, page);
    expect(merged.rows).toHaveLength(2);
    expect(merged.rows[0]?.status).toBe("succeeded");
    expect(merged.nextCursor).toBeNull();
  });
});
