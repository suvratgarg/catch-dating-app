import {cleanup, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {HomePage} from "./HomePage";
afterEach(cleanup);
describe("organiser homepage", () => {
  it("offers Host first and keeps attendance and claims as separate journeys", () => {
    render(<HomePage captures={{}} />);
    const main = within(screen.getByRole("main"));
    expect(main.getByRole("link", {name: "Explore Catch Host"}).getAttribute("href")).toBe("/host/");
    for (const link of main.getAllByRole("link", {name: "Find events"})) expect(link.getAttribute("href")).toBe("/explore/");
    expect(main.getByRole("link", {name: "Claim your organiser page"}).getAttribute("href")).toBe("/claim/");
    expect(main.getByText(/Submitting one does not open an organiser workspace/)).toBeTruthy();
    expect(screen.queryByRole("link", {name: "Get started free"})).toBeNull();
  });
  it("keeps a short introduction and hands product detail to the canonical Host page", () => {
    const {container} = render(<HomePage captures={{}} />);
    expect(container.querySelectorAll("main > section").length).toBeLessThanOrEqual(3);
    expect(screen.getByRole("link", {name: "See how Catch Host works"}).getAttribute("href")).toBe("/host/#how-it-works");
    expect(screen.getByRole("link", {name: "Explore use cases"}).getAttribute("href")).toBe("/host/#use-cases");
    expect(screen.queryByLabelText("Search Catch")).toBeNull();
  });
});
