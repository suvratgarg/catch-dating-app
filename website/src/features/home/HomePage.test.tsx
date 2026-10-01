import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {HomePage} from "./HomePage";

vi.mock("../organizers/publicDiscoveryData", () => ({
  usePublicDiscoveryData: () => ({events: [], suggestions: []}),
}));

afterEach(cleanup);

describe("organiser homepage", () => {
  it("sends free start and claim sign-in to the real claim flow with its limits visible", () => {
    render(<HomePage captures={{}} />);
    for (const link of screen.getAllByRole("link", {name: "Get started free"})) {
      expect(link.getAttribute("href")).toBe("/claim/");
    }
    for (const link of screen.getAllByRole("link", {name: "Sign in for a claim"})) {
      expect(link.getAttribute("href")).toBe("/claim/");
    }
    expect(screen.getByText("Start with a claim request. Presence-management tools are being developed."))
      .toBeTruthy();
    expect(screen.getByText("Sign-in is for the existing claim flow. It does not open an organiser workspace."))
      .toBeTruthy();
    for (const link of screen.getAllByRole("link", {name: "Request a software walkthrough"})) {
      expect(link.getAttribute("href")).toBe("mailto:suvrat@catchdates.com");
    }
    expect(screen.queryByRole("link", {name: /open.*workspace|dashboard/i})).toBeNull();
  });

  it("connects the four groups and all product and event contexts to real destinations", () => {
    const {container} = render(<HomePage captures={{}} />);
    for (const group of ["Product", "Solutions", "Explore", "Resources"]) {
      for (const link of screen.getAllByRole("link", {name: group})) {
        const href = link.getAttribute("href");
        const destination = new URL(href!, "https://catchdates.com/");
        expect(destination.pathname).toBe("/");
        expect(destination.hash).toBe(`#${group.toLowerCase()}`);
        expect(container.querySelector(destination.hash)).toBeTruthy();
      }
    }
    for (const title of ["Presence and discovery", "Registration and guest management", "Live operations",
      "Programme and logistics", "Clubs and communities", "Social events", "Weddings", "Corporate events"]) {
      expect(screen.getByRole("heading", {name: title})).toBeTruthy();
    }
    expect(screen.getByRole("link", {name: "Preview guest workflows"}).getAttribute("href"))
      .toBe("/host/workflows/");
    expect(screen.getByRole("link", {name: "See the current pilot"}).getAttribute("href"))
      .toBe("/host/");
    expect(screen.getAllByRole("link", {name: "Explore events and the Catch app"})[0].getAttribute("href"))
      .toBe("/explore/");
    expect(screen.getAllByRole("link", {name: "Browse all organisers"})[0].getAttribute("href"))
      .toBe("/organizers/");
    expect(screen.getByLabelText("Search Catch")).toBeTruthy();
    expect(screen.getByText(/Preview pages describe concepts, not generally available software/)).toBeTruthy();
    expect(screen.queryByText("The public loop starts with real host pages.")).toBeNull();
  });
});
