import assert from "node:assert/strict";
import test from "node:test";
import type {CallableRequest} from "firebase-functions/v2/https";
import {listEventChatsHandler as list} from "./listEventChats";

const request = (uid: string | null, data: unknown) => ({
  auth: uid ? {uid, token: {}} : undefined, data,
}) as CallableRequest<unknown>;
const deps = {db: () => {
  throw new Error("Database must not be read");
},
rateLimit: async () => undefined};

test("event directory rejects unauthenticated reads and cross-account cursors",
  async () => {
    await assert.rejects(list(request(null, {cursor: null, limit: 10}), deps),
      {code: "unauthenticated"});
    await assert.rejects(list(request("current", {cursor: {
      source: "memberships", after: null, accountUid: "previous"}, limit: 10}),
    deps), {code: "permission-denied"});
  });

test("event directory validates scan bounds and rejects caller-selected owners",
  async () => {
    for (const data of [{cursor: null, limit: 0}, {cursor: null, limit: 11},
      {cursor: null, limit: 10, uid: "someone-else"},
      {cursor: {source: "users", after: null, accountUid: "current"}, limit: 1},
      {cursor: {source: "attendees", after: "wrong/path",
        accountUid: "current"},
      limit: 1}]) {
      await assert.rejects(list(request("current", data), deps),
        {code: "invalid-argument"});
    }
  });
