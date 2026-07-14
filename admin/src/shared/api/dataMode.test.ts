import {afterEach, describe, expect, it, vi} from "vitest";
import {dataMode} from "./dataMode";

describe("admin data mode", () => {
  afterEach(() => vi.unstubAllEnvs());

  it("defaults unknown values to sample mode", () => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "preview");
    expect(dataMode()).toBe("sample");
  });

  it("enables live mode only explicitly", () => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "live");
    expect(dataMode()).toBe("live");
  });
});
