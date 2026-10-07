vi.mock("./PartnerDemoReviewWorkspace", () => ({PartnerDemoReviewWorkspace: () => null}));
import {act, cleanup, render, screen, waitFor} from "@testing-library/react";
import {afterEach, expect, it, vi} from "vitest";
import {createQueryHarness} from "../../../shared/test/queryHarness";
import {PartnerWorkspaceScreen} from "./PartnerWorkspaceScreen";
vi.mock("./PartnerOutreachWorkspace", () => ({PartnerOutreachWorkspace: () => null}));
const api = vi.hoisted(() => ({readPartnerWorkspace: vi.fn(), writePartner: vi.fn()}));
vi.mock("../api/partnerRepository", () => api);
afterEach(() => {cleanup(); vi.clearAllMocks();});
it("withdraws previously loaded private lead content after access denial", async () => {
  api.readPartnerWorkspace.mockResolvedValue({membership: {uid: "partner", displayName: "Partner", expiresAt: new Date(Date.now() + 3600_000).toISOString()}, submissions: [],
    nextCursor: null, leads: [{assignment: {organizerId: "one", revision: 1, status: "accepted",
      nextAction: "Private next step", reviewAt: "2026-10-05", expiresAt: new Date(Date.now() + 3600_000).toISOString(),
      relationshipContext: null, channel: "email"}, organizer: {organizerId: "one",
      name: "Private synthetic lead", city: "Mumbai", claimState: "unclaimed"}}]});
  const {wrapper, client} = createQueryHarness();
  render(<PartnerWorkspaceScreen actorUid="partner" isCurrentSession={() => true} onSignOut={() => {}} />, {wrapper});
  await screen.findByText("Private synthetic lead");
  api.readPartnerWorkspace.mockRejectedValue(Object.assign(new Error("Revoked"), {code: "functions/permission-denied"}));
  await act(async () => {await client.invalidateQueries({queryKey: ["partner-workspace"]});});
  await waitFor(() => expect(screen.queryByText("Private synthetic lead")).toBeNull());
  expect(screen.queryByText("Private next step")).toBeNull();
  expect(screen.queryByText("Submit for review")).toBeNull();
});
