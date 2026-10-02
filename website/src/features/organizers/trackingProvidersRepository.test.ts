import {describe, expect, it, vi} from "vitest";
const read = vi.hoisted(() => vi.fn());
vi.mock("../../firebase", () => ({readPublicOrganizerTrackingSettings: read}));
import {readOrganizerProviderSettings} from "./trackingProvidersRepository";

describe("generated public provider publication boundary", () => {
  const payload = {organizerId: "organizer-a", eventId: "public-event"};
  const denied = {...payload, enabled: false, metaPixelId: null, googleMeasurementId: null, policyReason: "policyReviewRequired"};
  it("reads and validates the current denied public contract without exposing owner IDs", async () => {
    read.mockResolvedValue(denied);
    expect(await readOrganizerProviderSettings(payload)).toEqual(denied);
    expect(read).toHaveBeenCalledWith(payload);
  });
  it.each([
    {...denied, organizerId: "other-tenant"}, {...denied, eventId: "other-event"},
    {...denied, enabled: true}, {...denied, metaPixelId: "1234567890"},
    {...denied, googleMeasurementId: "G-TEST123456"}, {...denied, policyReason: "unreviewed"},
  ])("fails closed on mismatched or unreviewed publication %#", async (response) => {
    read.mockResolvedValue(response);
    await expect(readOrganizerProviderSettings(payload)).rejects.toThrow("Invalid public tracking policy response");
  });
});
