/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  refreshRunClubNextRun,
  syncRunClubNextRunHandler,
} from "./syncRunClubNextRun";

test("refreshRunClubNextRun stores the earliest upcoming active run",
  async () => {
    const now = timestamp("2026-05-12T10:00:00.000Z");
    const soon = timestamp("2026-05-13T10:00:00.000Z");
    const later = timestamp("2026-05-14T10:00:00.000Z");
    const past = timestamp("2026-05-11T10:00:00.000Z");
    const firestore = fakeFirestore({
      "runClubs/club-1": {nextRunAt: null, nextRunLabel: null},
      "runs/past": run("club-1", past, "Past gate"),
      "runs/later": run("club-1", later, "Later gate"),
      "runs/soon": run("club-1", soon, "Soon gate"),
      "runs/cancelled": run("club-1", soon, "Cancelled gate", "cancelled"),
      "runs/other-club": run("club-2", soon, "Other gate"),
    });

    await refreshRunClubNextRun("club-1", {
      firestore: () => firestore as never,
      nowTimestamp: () => now,
    });

    assert.deepEqual(firestore.get("runClubs/club-1"), {
      nextRunAt: soon,
      nextRunLabel: "Soon gate",
    });
  }
);

test("refreshRunClubNextRun clears projection when no future run exists",
  async () => {
    const now = timestamp("2026-05-12T10:00:00.000Z");
    const firestore = fakeFirestore({
      "runClubs/club-1": {
        nextRunAt: timestamp("2026-05-13T10:00:00.000Z"),
        nextRunLabel: "Old gate",
      },
      "runs/past": run("club-1", timestamp("2026-05-11T10:00:00.000Z"),
        "Past gate"),
      "runs/cancelled": run("club-1", timestamp("2026-05-13T10:00:00.000Z"),
        "Cancelled gate", "cancelled"),
    });

    await refreshRunClubNextRun("club-1", {
      firestore: () => firestore as never,
      nowTimestamp: () => now,
    });

    assert.deepEqual(firestore.get("runClubs/club-1"), {
      nextRunAt: null,
      nextRunLabel: null,
    });
  }
);

test("syncRunClubNextRunHandler refreshes moved run clubs", async () => {
  const refreshed: string[] = [];
  const now = timestamp("2026-05-12T10:00:00.000Z");
  const firestore = fakeFirestore({
    "runClubs/club-1": {},
    "runClubs/club-2": {},
  });

  const deps = {
    nowTimestamp: () => now,
    firestore: () => ({
      ...firestore,
      collection: (path: string) => {
        if (path === "runClubs") {
          return {
            doc: (id: string) => {
              refreshed.push(id);
              return firestore.collection(path).doc(id);
            },
          };
        }
        return firestore.collection(path);
      },
    }) as never,
  };

  await syncRunClubNextRunHandler(
    {runClubId: "club-1"} as never,
    {runClubId: "club-2"} as never,
    deps
  );

  assert.deepEqual(refreshed.sort(), ["club-1", "club-2"]);
});

function run(
  runClubId: string,
  startTime: FirebaseFirestore.Timestamp,
  meetingPoint: string,
  status = "active"
) {
  return {runClubId, startTime, meetingPoint, status};
}

function timestamp(iso: string): FirebaseFirestore.Timestamp {
  return admin.firestore.Timestamp.fromDate(new Date(iso));
}

function fakeFirestore(initialDocs: Record<string, Record<string, unknown>>) {
  const docs = Object.fromEntries(
    Object.entries(initialDocs).map(([path, data]) => [path, {...data}])
  );
  return {
    get: (path: string) => docs[path],
    collection: (collectionPath: string) =>
      queryRef(collectionPath, []),
  };

  function docRef(path: string) {
    return {
      get: async () => ({
        exists: docs[path] !== undefined,
        data: () => docs[path],
      }),
      set: async (
        patch: Record<string, unknown>,
        options: {merge: boolean}
      ) => {
        docs[path] = options.merge ? {...docs[path], ...patch} : patch;
      },
    };
  }

  function queryRef(
    collectionPath: string,
    filters: Array<{
      field: string;
      operator: string;
      value: unknown;
    }>,
    order?: {field: string; direction: "asc" | "desc"},
    count?: number
  ) {
    return {
      doc: (docId: string) => docRef(`${collectionPath}/${docId}`),
      where: (field: string, operator: string, value: unknown) =>
        queryRef(collectionPath, [
          ...filters,
          {field, operator, value},
        ], order, count),
      orderBy: (field: string, direction: "asc" | "desc") =>
        queryRef(collectionPath, filters, {field, direction}, count),
      limit: (limitCount: number) =>
        queryRef(collectionPath, filters, order, limitCount),
      get: async () => {
        let results = Object.entries(docs)
          .filter(([path]) => path.startsWith(`${collectionPath}/`))
          .filter(([, data]) =>
            filters.every((filter) => matchesFilter(data, filter))
          );
        if (order) {
          results = results.sort((a, b) =>
            compareValues(
              a[1][order.field],
              b[1][order.field],
              order.direction
            )
          );
        }
        const limited = count === undefined ? results : results.slice(0, count);
        return {
          docs: limited.map(([, data]) => ({data: () => ({...data})})),
        };
      },
    };
  }
}

function matchesFilter(
  data: Record<string, unknown>,
  filter: {field: string; operator: string; value: unknown}
): boolean {
  if (filter.operator === "==") {
    return data[filter.field] === filter.value;
  }
  if (filter.operator === ">=") {
    return millis(data[filter.field]) >= millis(filter.value);
  }
  throw new Error(`Unsupported fake query operator: ${filter.operator}`);
}

function compareValues(
  left: unknown,
  right: unknown,
  direction: "asc" | "desc"
) {
  const result = millis(left) - millis(right);
  return direction === "asc" ? result : -result;
}

function millis(value: unknown): number {
  if (
    typeof value === "object" &&
    value !== null &&
    "toMillis" in value &&
    typeof value.toMillis === "function"
  ) {
    return value.toMillis();
  }
  throw new Error("Expected timestamp-like value.");
}
