import {describe, expect, it} from "vitest";
import {embedParentOrigin, resizePayload} from "./publicFormEmbed";

describe("public form embed protocol", () => {
  it("targets only a browser-referrer origin and rejects unsafe schemes", () => {
    expect(embedParentOrigin("https://client.example/apply?secret=value"))
      .toBe("https://client.example");
    expect(embedParentOrigin("javascript:alert(1)")).toBeNull();
    expect(embedParentOrigin("http://client.example/apply")).toBeNull();
  });

  it("sends only a bounded dimension and an opaque frame identifier", () => {
    expect(resizePayload("frame_1", 9000)).toEqual({
      type: "catch:form:resize", version: 1, embedId: "frame_1", height: 4000,
    });
    expect(resizePayload("?token=private", 500)).toBeNull();
    expect(resizePayload("frame_1", Infinity)).toBeNull();
  });
});
