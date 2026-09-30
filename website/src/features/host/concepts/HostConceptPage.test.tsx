import {act, cleanup, fireEvent, render, screen} from "@testing-library/react";
import {afterEach, beforeEach, describe, expect, it, vi} from "vitest";
import {HostConceptPage} from "./HostConceptPage";
import {hostConceptContentPages} from "@content/hostConceptContent";
import {hostConceptCopy} from "@content/hostConceptNavigation";
// Source provenance and the former rendered-content projection stay test-only.
import prototypeParity from "./__fixtures__/prototypeParity.json";
afterEach(() => {cleanup(); vi.unstubAllGlobals(); vi.useRealTimers();});
beforeEach(() => vi.stubGlobal("matchMedia",vi.fn(() => ({matches:true,addEventListener:vi.fn(),removeEventListener:vi.fn()}))));
describe("canonical concept migration", () => {
  it("matches the preserved nine-page source and presentation parity fixture", () => {
    const canonicalContent = hostConceptContentPages.map(({slug, title, description, conceptNotice, sections}) => ({
      slug, title, description, conceptNotice, sections,
    }));
    expect(canonicalContent).toEqual(prototypeParity.contentPages);

    const presentationBySlug = new Map(prototypeParity.presentationPages.map((page) => [page.slug, page]));
    expect(hostConceptContentPages).toHaveLength(9);
    expect(presentationBySlug.size).toBe(9);

    let sectionCount = 0;
    for (const page of hostConceptContentPages) {
      const presentation = presentationBySlug.get(page.slug);
      expect(presentation).toBeDefined();
      expect(page.title).toBe(prototypeParity.sourcePages.find((source) => source.slug === page.slug)?.title);
      expect(page.sections.map(({id, body, links, layout}) => ({
        id,
        body,
        links: [...links, ...(page.sectionAction ? [page.sectionAction] : [])],
        stackVisible: layout.includes("stack"),
        consoleCardsSuppressed: layout.includes("console"),
      }))).toEqual(presentation?.sections.map(({id, body, links, stackVisible, consoleCardsSuppressed}) => ({
        id,
        body,
        links,
        stackVisible,
        consoleCardsSuppressed,
      })));
      sectionCount += page.sections.length;
    }
    expect(sectionCount).toBe(49);
  });

  it.each(hostConceptContentPages)("retains every section of $sourceFile with an explicit concept boundary", (page) => {
    const {container}=render(<HostConceptPage slug={page.slug} />);
    expect(screen.getByText(page.conceptNotice)).toBeTruthy();
    for (const section of page.sections) expect(container.querySelector(`#${section.id}`)).toBeTruthy();
    if (page.slug === "directory") expect(container.querySelector("form")?.getAttribute("action")).toBe("/organizers/");
    else expect(container.querySelector("form")).toBeNull();
    for (const link of container.querySelectorAll('a[href^="#"]')) expect(container.querySelector(link.getAttribute("href")!)).toBeTruthy();
  });
  it("preserves all selectable tier details and the separate Programs information", () => {
    render(<HostConceptPage slug="host" />);
    const page=hostConceptContentPages.find((entry) => entry.slug==="host")!;
    const section=page.sections.find((entry) => entry.id==="tiers")!;
    const cards=section.items.filter((item) => item.role === "tier-detail");
    for (const [index,name] of ["Works alongside", "Catch booking", "Catch network"].entries()) {
      fireEvent.click(screen.getByRole("button",{name:new RegExp(`^${name}`)}));
      expect(screen.getByText(cards[index].body)).toBeTruthy();
      for (const bullet of cards[index].bullets ?? []) expect(screen.getByText(bullet)).toBeTruthy();
    }
    const programs=section.items.find((item) => item.label==="Programs")!;
    expect(screen.getByText(programs.body)).toBeTruthy();
  });
  it("starts normal-motion replay empty and reveals the first fictional activity on the first tick", () => {
    vi.useFakeTimers();
    vi.stubGlobal("matchMedia",vi.fn(() => ({matches:false,addEventListener:vi.fn(),removeEventListener:vi.fn()})));
    const {container}=render(<HostConceptPage slug="index" />);
    const rows=container.querySelectorAll('ol[aria-label="Example event activity"] li');
    expect([...rows].every((row) => row.hasAttribute("hidden"))).toBe(true);
    act(() => vi.advanceTimersByTime(1600));
    expect(rows[0].hasAttribute("hidden")).toBe(false); expect(rows[1].hasAttribute("hidden")).toBe(true);
    vi.useRealTimers();
  });
  it("retains tool selection through filtering, reveals details and performs no remote action", () => {
    const fetch=vi.fn(); vi.stubGlobal("fetch",fetch);
    render(<HostConceptPage slug="stack" />);
    fireEvent.click(screen.getByRole("button",{name:/^Luma/}));
    expect(screen.getByText(/1 selected/)).toBeTruthy();
    fireEvent.change(screen.getByLabelText("Filter tools"),{target:{value:"nonexistent"}});
    expect(screen.getByText(hostConceptCopy.noResults)).toBeTruthy();
    expect(screen.getByText(/1 selected/)).toBeTruthy();
    fireEvent.click(screen.getByRole("button",{name:hostConceptCopy.details}));
    expect(screen.getByRole("button",{name:hostConceptCopy.hideDetails}).getAttribute("aria-expanded")).toBe("true");
    expect(fetch).not.toHaveBeenCalled();
  });
  it.each([["claim","/claim/",hostConceptCopy.claim],["apply","/host/#founding-hosts",hostConceptCopy.apply],["directory","/organizers/",hostConceptCopy.directory]])("hands %s to an existing authoritative route", (slug,href,label) => {
    render(<HostConceptPage slug={slug} />);
    expect(screen.getAllByRole("link",{name:label}).some((link) => link.getAttribute("href")===href)).toBe(true);
  });
});
