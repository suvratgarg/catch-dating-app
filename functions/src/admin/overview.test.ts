import assert from "node:assert/strict";
import test from "node:test";
import {
  countAuthUsersCreatedSince,
  normalizeQueueItem,
  startOfSevenDayWindow,
  startOfUtcDay,
} from "./overview";

test("startOfUtcDay returns midnight UTC", () => {
  assert.equal(
    startOfUtcDay(new Date("2026-06-01T18:30:00.000Z")).toISOString(),
    "2026-06-01T00:00:00.000Z"
  );
});

test("startOfSevenDayWindow includes today and six prior days", () => {
  assert.equal(
    startOfSevenDayWindow(new Date("2026-06-01T18:30:00.000Z"))
      .toISOString(),
    "2026-05-26T00:00:00.000Z"
  );
});

test("countAuthUsersCreatedSince scans paged Auth users", async () => {
  const pages = [
    {
      users: [
        {metadata: {creationTime: "2026-06-01T01:00:00.000Z"}},
        {metadata: {creationTime: "2026-05-30T01:00:00.000Z"}},
      ],
      pageToken: "next",
    },
    {
      users: [
        {metadata: {creationTime: "2026-06-01T12:00:00.000Z"}},
        {metadata: {creationTime: "not-a-date"}},
      ],
    },
  ];
  let callIndex = 0;

  const result = await countAuthUsersCreatedSince({
    async listUsers() {
      return pages[callIndex++];
    },
  }, new Date("2026-06-01T00:00:00.000Z"));

  assert.deepEqual(result, {count: 2, scanned: 4});
});

test("normalizeQueueItem builds readable safety report rows", () => {
  assert.deepEqual(
    normalizeQueueItem("safetyReport", "reports/report-1", {
      targetUserId: "user-2",
      reasonCode: "harassment",
      source: "chat",
      status: "open",
      createdAt: new Date("2026-06-01T10:00:00.000Z"),
    }),
    {
      id: "reports/report-1",
      title: "harassment",
      detail: "target user-2 - chat",
      status: "open",
      createdAt: "2026-06-01T10:00:00.000Z",
      targetPath: "reports/report-1",
    }
  );
});
