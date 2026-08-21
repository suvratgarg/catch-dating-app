import assert from "node:assert/strict";
import test from "node:test";
import {
  refreshOrganizerFollowerStats,
} from "./syncOrganizerFollowerStats";

test("refreshOrganizerFollowerStats recomputes active follower count",
  async () => {
    const firestore = fakeFirestore({
      "organizers/organizer-1": {followerCount: 99},
      "organizerFollows/organizer-1_runner-1": {
        organizerId: "organizer-1",
        uid: "runner-1",
        status: "active",
      },
      "organizerFollows/organizer-1_runner-2": {
        organizerId: "organizer-1",
        uid: "runner-2",
        status: "inactive",
      },
    });

    await refreshOrganizerFollowerStats("organizer-1", {
      firestore: () => firestore as never,
    });

    assert.equal(firestore.get("organizers/organizer-1")?.followerCount, 1);
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
