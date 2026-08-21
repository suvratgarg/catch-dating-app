import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  refreshOrganizerNextEvent,
  syncOrganizerNextEventHandler,
} from "./syncOrganizerNextEvent";

test("refreshOrganizerNextEvent stores the earliest upcoming active event",
  async () => {
    const now = timestamp("2026-05-12T10:00:00.000Z");
    const soon = timestamp("2026-05-13T10:00:00.000Z");
    const later = timestamp("2026-05-14T10:00:00.000Z");
    const past = timestamp("2026-05-11T10:00:00.000Z");
    const firestore = fakeFirestore({
      "organizers/organizer-1": {nextEventAt: null, nextEventLabel: null},
      "events/past": event("organizer-1", past, "Past gate"),
      "events/later": event("organizer-1", later, "Later gate"),
      "events/soon": event("organizer-1", soon, "Soon gate"),
      "events/cancelled": event("organizer-1", soon, "Cancelled gate", "cancelled"),
      "events/other-organizer": event("organizer-2", soon, "Other gate"),
    });

    await refreshOrganizerNextEvent("organizer-1", {
      firestore: () => firestore as never,
      nowTimestamp: () => now,
    });

    const expectedProjection = {
      nextEventAt: soon,
      nextEventLabel: "Soon gate",
    };
    assert.deepEqual(firestore.get("organizers/organizer-1"), expectedProjection);
  }
);

test("refreshOrganizerNextEvent clears projection when no future event exists",
  async () => {
    const now = timestamp("2026-05-12T10:00:00.000Z");
    const firestore = fakeFirestore({
      "organizers/organizer-1": {
        nextEventAt: timestamp("2026-05-13T10:00:00.000Z"),
        nextEventLabel: "Old gate",
      },
      "events/past": event("organizer-1", timestamp("2026-05-11T10:00:00.000Z"),
        "Past gate"),
      "events/cancelled": event("organizer-1", timestamp("2026-05-13T10:00:00.000Z"),
        "Cancelled gate", "cancelled"),
    });

    await refreshOrganizerNextEvent("organizer-1", {
      firestore: () => firestore as never,
      nowTimestamp: () => now,
    });

    const expectedProjection = {
      nextEventAt: null,
      nextEventLabel: null,
    };
    assert.deepEqual(firestore.get("organizers/organizer-1"), expectedProjection);
  }
);

test("syncOrganizerNextEventHandler refreshes moved organizers", async () => {
  const refreshed: string[] = [];
  const now = timestamp("2026-05-12T10:00:00.000Z");
  const firestore = fakeFirestore({
    "organizers/organizer-1": {},
    "organizers/organizer-2": {},
  });

  const deps = {
    nowTimestamp: () => now,
    firestore: () => ({
      ...firestore,
      collection: (path: string) => {
        if (path === "organizers") {
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

  await syncOrganizerNextEventHandler(
    {organizerId: "organizer-1"} as never,
    {organizerId: "organizer-2"} as never,
    deps
  );

  assert.deepEqual(refreshed.sort(), ["organizer-1", "organizer-2"]);
});

function event(
  organizerId: string,
  startTime: FirebaseFirestore.Timestamp,
  meetingPoint: string,
  status = "active"
) {
  return {organizerId, startTime, meetingPoint, status};
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
    batch: () => {
      const writes: Array<{
        ref: ReturnType<typeof docRef>;
        patch: Record<string, unknown>;
        options: {merge: boolean};
      }> = [];
      return {
        set: (
          ref: ReturnType<typeof docRef>,
          patch: Record<string, unknown>,
          options: {merge: boolean}
        ) => writes.push({ref, patch, options}),
        commit: async () => {
          await Promise.all(
            writes.map(({ref, patch, options}) => ref.set(patch, options))
          );
        },
      };
    },
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
