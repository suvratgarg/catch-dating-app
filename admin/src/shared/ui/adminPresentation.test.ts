import {describe, expect, it} from "vitest";

import {displayAdminQueueTitle} from "./adminPresentation";

describe("displayAdminQueueTitle", () => {
  it("uses human operational labels for known queue codes", () => {
    expect(displayAdminQueueTitle("harassment")).toBe("Harassment in chat");
    expect(displayAdminQueueTitle("fake_profile")).toBe("Possible fake profile");
    expect(displayAdminQueueTitle("banned_text")).toBe("Banned language");
    expect(displayAdminQueueTitle("explicit_photo")).toBe("Explicit profile photo");
  });

  it("humanizes unknown machine identifiers without changing natural titles", () => {
    expect(displayAdminQueueTitle("source_review_pending"))
      .toBe("Source review pending");
    expect(displayAdminQueueTitle("Maya Shah")).toBe("Maya Shah");
  });
});
