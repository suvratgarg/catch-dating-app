import {beforeEach, expect, it, vi} from "vitest";
const mocks = vi.hoisted(() => ({catalog: vi.fn(), route: vi.fn()}));
vi.mock("./publicCatalog", () => ({readPublicCatalog: mocks.catalog}));
vi.mock("./publicRoute", () => ({resolvePublicRoute: mocks.route}));
import {publicCatalogResponse as GET} from "./publicCatalogResponse";
beforeEach(() => {
  mocks.catalog.mockResolvedValue({listings: [], readAt: 1});
  mocks.route.mockResolvedValue({catalog: {listings: [{reviews: [{comment: "Published"}]}], readAt: 2}});
});
it("refreshes resolved detail data with the same server publication and review gates", async () => {
  const response = await GET(new Request("http://localhost/api/public-catalog?path=%2Fevents%2Fdinner%2F"));
  expect(mocks.route).toHaveBeenCalledWith("/events/dinner/");
  expect(response.headers.get("cache-control")).toBe("private, no-store");
  expect((await response.json()).listings[0].reviews[0].comment).toBe("Published");
});
it.each(["/private/account", "/events/../../users", "/organizers/", "/explore/"])("does not use arbitrary paths as detail reads: %s", async path => {
  await GET(new Request(`http://localhost/api/public-catalog?path=${encodeURIComponent(path)}`));
  expect(mocks.route).not.toHaveBeenCalled();
  expect(mocks.catalog).toHaveBeenCalledOnce();
});
it("fails unavailable without a stale catalogue when the live read fails", async () => {
  mocks.route.mockRejectedValue(new Error("unavailable"));
  const response = await GET(new Request("http://localhost/api/public-catalog?path=%2Fevents%2Fdinner%2F"));
  expect(response.status).toBe(503);
  expect(await response.json()).toEqual({listings: [], unavailable: true});
});
