import {describe, expect, it} from "vitest";
import preview from "../../.storybook/preview";

describe("Admin Storybook accessibility gate", () => {
  it("fails the browser suite on accessibility violations", () => {
    expect(preview.parameters?.a11y?.test).toBe("error");
    expect(preview.parameters?.a11y?.disable).not.toBe(true);
  });
});
