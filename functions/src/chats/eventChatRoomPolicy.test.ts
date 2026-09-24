import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {canPostEventChatMode, canReadEventChatMode,
  effectiveEventChatRoomMode} from "./eventChatRoomPolicy";

describe("event room schedule and posting policy", () => {
  it("does not infer a live room or production schedule", () => {
    assert.equal(effectiveEventChatRoomMode(null, 100), "notCreated");
    assert.equal(effectiveEventChatRoomMode({status: "closed"}, 100), "closed");
  });

  it("opens and closes only at configured boundaries", () => {
    const room = {status: "open" as const,
      opensAtMillis: 100, closesAtMillis: 200};
    assert.equal(effectiveEventChatRoomMode(room, 99), "scheduled");
    assert.equal(effectiveEventChatRoomMode(room, 100), "open");
    assert.equal(effectiveEventChatRoomMode(room, 199), "open");
    assert.equal(effectiveEventChatRoomMode(room, 200), "closed");
    assert.equal(effectiveEventChatRoomMode({...room,
      status: "archived"}, 150), "archived");
  });

  it("allows reading through pause and manager-only announcements", () => {
    for (const mode of ["open", "paused", "announcementsOnly"] as const) {
      assert.equal(canReadEventChatMode(mode), true);
    }
    assert.equal(canPostEventChatMode("open", false), true);
    assert.equal(canPostEventChatMode("paused", true), false);
    assert.equal(canPostEventChatMode("announcementsOnly", false), false);
    assert.equal(canPostEventChatMode("announcementsOnly", true), true);
    for (const mode of ["closed", "archived", "scheduled"] as const) {
      assert.equal(canReadEventChatMode(mode), false);
      assert.equal(canPostEventChatMode(mode, true), false);
    }
  });
});
