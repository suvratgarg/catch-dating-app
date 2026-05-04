/**
 * Tests for the text moderation filter.
 */
import {describe, it} from "node:test";
import assert from "node:assert/strict";
import {moderateText, isBlocked} from "./textFilter";

describe("moderateText", () => {
  it("allows clean text", () => {
    const result = moderateText("Hello, how are you?");
    assert.equal(result.action, "allow");
    assert.deepEqual(result.matches, []);
  });

  it("allows empty and whitespace-only input", () => {
    assert.equal(moderateText("").action, "allow");
    assert.equal(moderateText(null).action, "allow");
    assert.equal(moderateText(undefined).action, "allow");
    assert.equal(moderateText("   ").action, "allow");
  });

  it("blocks text containing hate-speech slurs", () => {
    const result = moderateText("you are a chink");
    assert.equal(result.action, "block");
    assert.ok(result.matches.includes("chink"));
  });

  it("blocks text containing explicit terms", () => {
    const result = moderateText("this is pedophile content");
    assert.equal(result.action, "block");
    assert.ok(result.matches.includes("pedo"));
  });

  it("blocks text with self-harm encouragement", () => {
    const result = moderateText("just kill yourself please");
    assert.equal(result.action, "block");
    assert.ok(result.matches.includes("kill yourself"));
  });

  it("flags text with profanity but no block-list terms", () => {
    const result = moderateText("that was a shit show");
    assert.equal(result.action, "flag");
    assert.ok(result.matches.includes("shit"));
  });

  it("flags text with off-platform solicitation", () => {
    const result = moderateText("hey whatsapp me at 9876543210");
    assert.equal(result.action, "flag");
    assert.ok(result.matches.includes("whatsapp me"));
  });

  it("blocks when both block and flag terms are present", () => {
    // "nigger" is block-list, "shit" is flag-list
    const result = moderateText("you nigger, that is shit");
    assert.equal(result.action, "block");
  });

  it("is case-insensitive", () => {
    const result = moderateText("YOU ARE A FAGGOT");
    assert.equal(result.action, "block");
    assert.ok(result.matches.includes("faggot"));
  });

  it("detects substring matches within words", () => {
    // "pedo" is in the block list, should match within "pedophile"
    const result = moderateText("pedophile content warning");
    assert.equal(result.action, "block");
  });
});

describe("isBlocked", () => {
  it("returns true for block-list content", () => {
    assert.equal(isBlocked("you are a nigger"), true);
  });

  it("returns false for flag-only content", () => {
    assert.equal(isBlocked("holy shit"), false);
  });

  it("returns false for clean content", () => {
    assert.equal(isBlocked("hello world"), false);
  });
});
