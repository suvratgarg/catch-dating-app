/* eslint-disable require-jsdoc */
import assert from "node:assert/strict";
import test from "node:test";
import {onSwipeCreatedHandler} from "./onSwipeCreated";
import {SwipeDoc} from "../shared/firestore";

test(
  "onSwipeCreatedHandler creates a deterministic reciprocal match",
  async () => {
    const created: Record<string, unknown> = {};

    await onSwipeCreatedHandler(
      {
        swiperId: "user-b",
        targetId: "user-a",
        swipeData: swipe("user-b", "user-a", "run-2", "like"),
      },
      deps({
        docs: {
          "swipes/user-a/outgoing/user-b": swipe(
            "user-a",
            "user-b",
            "run-1",
            "like"
          ),
        },
        created,
      })
    );

    assert.deepEqual(created["matches/user-a_user-b"], {
      user1Id: "user-a",
      user2Id: "user-b",
      participantIds: ["user-a", "user-b"],
      runId: "run-2",
      createdAt: "SERVER_TIMESTAMP",
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {"user-a": 0, "user-b": 0},
      status: "active",
    });
  }
);

test(
  "onSwipeCreatedHandler ignores non-reciprocal and blocked likes",
  async () => {
    const nonReciprocal: Record<string, unknown> = {};
    await onSwipeCreatedHandler(
      {
        swiperId: "user-a",
        targetId: "user-b",
        swipeData: swipe("user-a", "user-b", "run-1", "like"),
      },
      deps({created: nonReciprocal})
    );
    assert.deepEqual(nonReciprocal, {});

    const blocked: Record<string, unknown> = {};
    await onSwipeCreatedHandler(
      {
        swiperId: "user-a",
        targetId: "user-b",
        swipeData: swipe("user-a", "user-b", "run-1", "like"),
      },
      deps({
        docs: {
          "swipes/user-b/outgoing/user-a": swipe(
            "user-b",
            "user-a",
            "run-1",
            "like"
          ),
        },
        created: blocked,
        blocked: true,
      })
    );
    assert.deepEqual(blocked, {});
  }
);

function swipe(
  swiperId: string,
  targetId: string,
  runId: string,
  direction: "like" | "pass"
): SwipeDoc {
  return {
    swiperId,
    targetId,
    runId,
    direction,
    createdAt: "created-at" as unknown as FirebaseFirestore.Timestamp,
  };
}

function deps({
  docs = {},
  created = {},
  blocked = false,
}: {
  docs?: Record<string, unknown>;
  created?: Record<string, unknown>;
  blocked?: boolean;
}) {
  return {
    firestore: () => firestore(docs, created),
    hasBlockingRelationship: async () => blocked,
    serverTimestamp: () => "SERVER_TIMESTAMP",
  } as never;
}

function firestore(
  docs: Record<string, unknown>,
  created: Record<string, unknown>
) {
  return {
    collection: (collectionPath: string) => ({
      doc: (docId: string) => docRef(`${collectionPath}/${docId}`),
    }),
  };

  function docRef(path: string): unknown {
    return {
      collection: (collectionPath: string) => ({
        doc: (docId: string) => docRef(`${path}/${collectionPath}/${docId}`),
      }),
      get: async () => {
        const data = docs[path];
        return {
          exists: data !== undefined,
          data: () => data,
        };
      },
      create: async (data: unknown) => {
        if (created[path] !== undefined) {
          const error = new Error("Already exists") as Error & {code: number};
          error.code = 6;
          throw error;
        }
        created[path] = data;
      },
    };
  }
}
