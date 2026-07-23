import {describe, expect, it} from "vitest";
import {
  isJoinWaitlistHttpRequest,
  parseJoinWaitlistHttpResponse,
} from "./joinWaitlistContract";

describe("joinWaitlistContract", () => {
  it("accepts current member, Host, and legacy runner requests", () => {
    expect(isJoinWaitlistHttpRequest({
      fullName: "Member Name",
      email: "member@example.com",
      city: "Delhi",
      role: "member",
    })).toBe(true);
    expect(isJoinWaitlistHttpRequest({
      fullName: "Host Name",
      email: "host@example.com",
      city: "Mumbai",
      role: "host",
      hostApplication: {
        organizationName: "Sunday Table",
        formats: ["Dinner"],
      },
    })).toBe(true);
    expect(isJoinWaitlistHttpRequest({
      fullName: "Legacy Runner",
      email: "runner@example.com",
      city: "Bengaluru",
      role: "runner",
    })).toBe(true);
  });

  it("rejects incomplete requests and malformed responses", () => {
    expect(isJoinWaitlistHttpRequest({
      fullName: "Member Name",
      email: "member@example.com",
      role: "member",
    })).toBe(false);
    expect(() => parseJoinWaitlistHttpResponse({
      alreadyJoined: false,
    })).toThrow("unexpected waitlist response");
  });

  it("parses success and response-error variants", () => {
    expect(parseJoinWaitlistHttpResponse({
      ok: true,
      alreadyJoined: false,
    })).toEqual({ok: true, alreadyJoined: false});
    expect(parseJoinWaitlistHttpResponse({
      error: "Please enter a valid email.",
    })).toEqual({error: "Please enter a valid email."});
  });
});
