import {beforeEach, describe, expect, it, vi} from "vitest";

const callable = vi.hoisted(() => vi.fn());
const httpsCallable = vi.hoisted(() => vi.fn(() => callable));
const functions = vi.hoisted(() => ({kind: "test-functions"}));

vi.mock("firebase/functions", () => ({httpsCallable}));
vi.mock("./firebaseFunctions", () => ({functions}));

import {loadHostAnalytics, loadOverview} from "./adminApi";
import {sampleHostAnalytics} from "./sampleData";

describe("adminApi live callable boundary", () => {
  beforeEach(() => {
    vi.stubEnv("VITE_ADMIN_DATA_MODE", "live");
  });

  it("maps overview reads to the expected callable and payload", async () => {
    callable.mockResolvedValue({data: {generatedAt: "2026-07-12", metrics: []}});

    await expect(loadOverview()).resolves.toEqual({
      generatedAt: "2026-07-12",
      metrics: [],
    });
    expect(httpsCallable).toHaveBeenCalledWith(functions, "adminGetOverview");
    expect(callable).toHaveBeenCalledWith({});
  });

  it("passes host analytics payloads through unchanged", async () => {
    const payload = {rangePreset: "30d" as const, granularity: "week" as const};
    callable.mockResolvedValue({data: sampleHostAnalytics});

    await loadHostAnalytics(payload);

    expect(httpsCallable).toHaveBeenCalledWith(functions, "adminGetHostAnalytics");
    expect(callable).toHaveBeenCalledWith(payload);
  });

  it("rejects invalid schema-backed payloads before invoking Firebase", async () => {
    const payload = {
      rangePreset: "30d",
      granularity: "week",
      unexpected: true,
    };

    await expect(loadHostAnalytics(payload as never)).rejects.toMatchObject({
      name: "AdminCallableValidationError",
      callable: "adminGetHostAnalytics",
      direction: "request",
    });
    expect(callable).not.toHaveBeenCalled();
  });

  it("rejects invalid development responses with callable and JSON-path context", async () => {
    vi.stubEnv("VITE_ADMIN_VALIDATE_RESPONSES", "true");
    callable.mockResolvedValue({data: {generatedAt: "2026-07-12"}});

    await expect(loadHostAnalytics({
      rangePreset: "30d",
      granularity: "week",
    })).rejects.toMatchObject({
      name: "AdminCallableValidationError",
      callable: "adminGetHostAnalytics",
      direction: "response",
    });
  });

  it("preserves Firebase auth and App Check errors for the feedback layer", async () => {
    const error = Object.assign(new Error("App Check token rejected"), {
      code: "functions/unauthenticated",
    });
    callable.mockRejectedValue(error);

    await expect(loadOverview()).rejects.toBe(error);
  });
});
