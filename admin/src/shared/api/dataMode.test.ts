import {afterEach, describe, expect, it, vi} from "vitest";
import {dataMode, resolveDataMode} from "./dataMode";

describe("admin data mode", () => {
  afterEach(() => vi.unstubAllEnvs());

  it("defaults unknown values to live mode", () => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "preview");
    expect(dataMode()).toBe("live");
  });

  it("keeps explicit live mode live", () => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "live");
    expect(dataMode()).toBe("live");
  });

  it("allows sample data only in an explicit development build", () => {
    expect(resolveDataMode("sample", true)).toBe("sample");
    expect(resolveDataMode("sample", false)).toBe("live");
    expect(resolveDataMode(undefined, true)).toBe("live");
  });
});
