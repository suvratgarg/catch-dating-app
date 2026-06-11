import assert from "node:assert/strict";
import test from "node:test";
import {
  refreshClubMemberStats,
  syncClubMemberStatsHandler,
} from "./syncClubMemberStats";

test("refreshClubMemberStats recomputes active membership count",
  async () => {
    const firestore = fakeFirestore({
      "clubs/club-1": {memberCount: 99},
      "clubMemberships/club-1_host-1": {
        clubId: "club-1",
        uid: "host-1",
        status: "active",
      },
      "clubMemberships/club-1_runner-1": {
        clubId: "club-1",
        uid: "runner-1",
        status: "active",
      },
      "clubMemberships/club-1_runner-2": {
        clubId: "club-1",
        uid: "runner-2",
        status: "left",
      },
      "clubMemberships/club-2_runner-3": {
        clubId: "club-2",
        uid: "runner-3",
        status: "active",
      },
    });

    await refreshClubMemberStats("club-1", {
      firestore: () => firestore as never,
    });

    assert.equal(firestore.get("clubs/club-1")?.memberCount, 2);
  }
);

test("refreshClubMemberStats resets missing memberships to zero",
  async () => {
    const firestore = fakeFirestore({
      "clubs/club-1": {memberCount: 4},
    });

    await refreshClubMemberStats("club-1", {
      firestore: () => firestore as never,
    });

    assert.equal(firestore.get("clubs/club-1")?.memberCount, 0);
  }
);

test("syncClubMemberStatsHandler refreshes moved membership clubs",
  async () => {
    const refreshed: string[] = [];
    const firestore = fakeFirestore({
      "clubs/club-1": {memberCount: 0},
      "clubs/club-2": {memberCount: 0},
    });

    const deps = {
      firestore: () => ({
        ...firestore,
        collection: (path: string) => {
          if (path === "clubs") {
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

    await syncClubMemberStatsHandler(
      {clubId: "club-1"} as never,
      {clubId: "club-2"} as never,
      deps
    );

    assert.deepEqual(refreshed.sort(), ["club-1", "club-2"]);
  }
);

function fakeFirestore(initialDocs: Record<string, Record<string, unknown>>) {
  const docs = structuredClone(initialDocs);
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
    filters: Array<{field: string; value: unknown}>
  ) {
    return {
      doc: (docId: string) => docRef(`${collectionPath}/${docId}`),
      where: (field: string, operator: string, value: unknown) => {
        assert.equal(operator, "==");
        return queryRef(collectionPath, [...filters, {field, value}]);
      },
      get: async () => ({
        docs: Object.entries(docs)
          .filter(([path]) => path.startsWith(`${collectionPath}/`))
          .filter(([, data]) =>
            filters.every((filter) => data[filter.field] === filter.value)
          )
          .map(([, data]) => ({data: () => ({...data})})),
      }),
    };
  }
}
