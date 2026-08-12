import {render, screen, waitFor} from "@testing-library/react";
import {MemoryRouter, Route, Routes} from "react-router";
import {beforeEach, describe, expect, it, vi} from "vitest";

const resolveEventInviteLanding = vi.hoisted(() => vi.fn());

vi.mock("../../firebase", () => ({
  resolveEventInviteLanding,
}));

vi.mock("./PublicEventRegistration", () => ({
  PublicEventRegistration: ({eventId, inviteToken}: {
    eventId: string;
    inviteToken?: string | null;
  }) => <div data-testid="registration">{eventId}:{inviteToken}</div>,
}));

import {EventInvitePage} from "./EventInvitePage";

const landing = {
  eventId: "event-1",
  title: "Courtyard Social",
  startTimeMillis: Date.parse("2026-08-15T18:00:00.000Z"),
  endTimeMillis: Date.parse("2026-08-15T20:00:00.000Z"),
  locationName: "The Courtyard",
  destinationKind: "catchEvent" as const,
  destinationUrl: null,
  sourceLabel: "Catch",
};

function renderInvite(path = "/invite/v2_link_token") {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route path="/invite/:inviteToken" element={<EventInvitePage />} />
      </Routes>
    </MemoryRouter>
  );
}

describe("EventInvitePage", () => {
  beforeEach(() => {
    resolveEventInviteLanding.mockResolvedValue(landing);
  });

  it("resolves an opaque token and forwards it into Catch registration", async () => {
    renderInvite();
    await waitFor(() => expect(resolveEventInviteLanding).toHaveBeenCalledWith({
      inviteToken: "v2_link_token",
      sessionId: expect.any(String),
    }));
    expect((await screen.findAllByText("Courtyard Social")).length).toBe(2);
    expect(screen.getByTestId("registration").textContent)
      .toBe("event-1:v2_link_token");
  });

  it("hands external invitations to the provider-labelled destination", () => {
    render(
      <MemoryRouter initialEntries={["/invite/v2_link_token"]}>
        <Routes>
          <Route path="/invite/:inviteToken" element={<EventInvitePage
            initialLanding={{
              ...landing,
              destinationKind: "externalBooking",
              destinationUrl: "https://lu.ma/event?catch_ref=link-1",
              sourceLabel: "Luma",
            }} />} />
        </Routes>
      </MemoryRouter>
    );
    const link = screen.getByRole("link", {name: /Luma/iu});
    expect(link.getAttribute("href"))
      .toBe("https://lu.ma/event?catch_ref=link-1");
  });

  it("fails closed for an invalid or expired token", async () => {
    resolveEventInviteLanding.mockRejectedValueOnce(new Error("not found"));
    renderInvite();
    expect(await screen.findByText(/invitation.*unavailable/iu)).toBeTruthy();
  });
});
