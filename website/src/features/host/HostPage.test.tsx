import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {HostPage} from "./HostPage";
import {hostFormats, hostLandingCopy as copy} from "@content/hostLanding";

afterEach(cleanup);
describe("Host format explorer", () => {
  it("changes the whole before/during/after example together for each format", () => {
    render(<HostPage captures={{}} />);
    expect(screen.getAllByRole("tab")).toHaveLength(5);
    for (const format of hostFormats) {
      fireEvent.click(screen.getByRole("tab", {name: format.label}));
      const tab = screen.getByRole("tab", {name: format.label});
      expect(tab.getAttribute("aria-selected")).toBe("true");
      expect(screen.getAllByRole("tab").filter(t => t.getAttribute("aria-selected") === "true")).toHaveLength(1);
      const panel = screen.getByRole("tabpanel", {name: format.label});
      expect(panel.id).toBe(tab.getAttribute("aria-controls"));
      expect(within(panel).getByRole("heading", {name: format.title})).toBeTruthy();
      for (const [index, stage] of format.stages.entries()) {
        expect(within(panel).getByText(copy.explorer.stages[index])).toBeTruthy();
        expect(within(panel).getByRole("heading", {name: stage.title})).toBeTruthy();
        expect(within(panel).getByText(stage.body)).toBeTruthy();
        expect(within(panel).getByText(stage.mock.title)).toBeTruthy();
      }
      expect(within(panel).getByText(format.connection)).toBeTruthy();
    }
  });
  it("supports a single tab stop, arrow wraparound, Home and End with focus following selection", () => {
    render(<HostPage captures={{}} />);
    const tabs = screen.getAllByRole("tab");
    expect(tabs.filter(t => t.tabIndex === 0)).toEqual([tabs[0]]);
    fireEvent.keyDown(tabs[0], {key: "ArrowLeft"});
    expect(document.activeElement).toBe(tabs[4]);
    expect(screen.getByRole("tabpanel", {name: "Pub crawl"})).toBeTruthy();
    fireEvent.keyDown(tabs[4], {key: "ArrowRight"});
    expect(document.activeElement).toBe(tabs[0]);
    fireEvent.keyDown(tabs[0], {key: "End"});
    expect(document.activeElement).toBe(tabs[4]);
    fireEvent.keyDown(tabs[4], {key: "Home"});
    expect(document.activeElement).toBe(tabs[0]);
    expect(tabs.filter(t => t.tabIndex === 0)).toEqual([tabs[0]]);
  });
  it("keeps examples and the selected pilot offer separate from live customer proof or blanket pricing", () => {
    render(<HostPage captures={{}} />);
    expect(screen.getByText(copy.explorer.note)).toBeTruthy();
    expect(screen.getByText(copy.insights.note)).toBeTruthy();
    expect(screen.getByText(copy.close.priceTitle)).toBeTruthy();
    expect(screen.getByText(copy.close.priceBody)).toBeTruthy();
    expect(screen.getByRole("link", {name: copy.seeHow}).getAttribute("href")).toBe("#how-it-works");
    for (const link of screen.getAllByRole("link", {name: copy.apply})) expect(link.getAttribute("href")).toBe("/host/apply/");
    expect(screen.queryByText(/0%.*24 months/)).toBeNull();
    expect(screen.getByRole("table", {name: copy.insights.tableCaption})).toBeTruthy();
  });
});

describe("Host adoption layers", () => {
  it("selects each circle without disturbing the event-format choice", () => {
    render(<HostPage captures={{}} />);
    fireEvent.click(screen.getByRole("tab", {name: "Pickleball"}));
    const circles = screen.getByRole("group", {name: copy.adoption.circlesLabel});
    for (const layer of copy.adoption.layers) {
      const button = within(circles).getByRole("button", {name: layer.label});
      fireEvent.click(button);
      expect(button.getAttribute("aria-pressed")).toBe("true");
      expect(within(circles).getAllByRole("button").filter(item => item.getAttribute("aria-pressed") === "true")).toHaveLength(1);
      const panel = screen.getByRole("region", {name: layer.title});
      expect(button.getAttribute("aria-controls")).toBe(panel.id);
      expect(within(panel).getByText(layer.body)).toBeTruthy();
      expect(screen.getByRole("tab", {name: "Pickleball"}).getAttribute("aria-selected")).toBe("true");
    }
  });
  it("keeps business section links separate from stable global navigation", () => {
    render(<HostPage captures={{}} />);
    expect(within(screen.getByRole("navigation", {name: "Primary"})).getAllByRole("link").map(item => item.getAttribute("href"))).toEqual(["/explore/", "/organizers/", "/host/"]);
    const local = screen.getByRole("navigation", {name: copy.navLabel});
    for (const item of copy.nav) expect(within(local).getByRole("link", {name: item.label}).getAttribute("href")).toBe(item.href);
    expect(within(local).getByRole("link", {name: copy.apply}).getAttribute("href")).toBe("/host/apply/");
  });
});
