import {cleanup, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {HostContentReview} from "./HostContentReview";
import {hostOrganizationCopy, hostWorkflowExamples} from "@content/hostOrganization";
import {ownerGatedSiteDestinations} from "@content/site";

afterEach(cleanup);
describe("Host content organisation", () => {
  it("offers a concrete workflow before capabilities and gives every entry a real in-page destination", () => {
    const {container} = render(<HostContentReview />);
    for (const example of hostWorkflowExamples) {
      expect(container.querySelector(`#${example.id}`)).toBeTruthy();
    }
    const sections = [...container.querySelectorAll("main > section")].map((section) => section.id);
    expect(sections.indexOf("workflows")).toBeLessThan(sections.indexOf("application-booking"));
    expect(sections.indexOf("multi-day")).toBeLessThan(sections.indexOf("capabilities"));
  });
  it("keeps application, membership, eligibility, payment and admission independent in the fictional example", () => {
    render(<HostContentReview />);
    const application = within(screen.getByRole("region", {name: hostWorkflowExamples[0].title}));
    for (const label of ["Application", "Membership", "Event eligibility", "Payment", "Event admission"]) {
      expect(application.getByText(label, {exact: true})).toBeTruthy();
    }
    expect(application.getByText("Separate decision; not automatically changed")).toBeTruthy();
    expect(screen.getAllByText(hostOrganizationCopy.exampleLabel)).toHaveLength(3);
  });
  it("uses the existing contact boundary and keeps beta intake separate without simulating submissions", () => {
    const {container} = render(<HostContentReview />);
    const links = screen.getAllByRole("link", {name: hostOrganizationCopy.hero.primaryAction});
    for (const link of links) expect(link.getAttribute("href")).toBe(ownerGatedSiteDestinations.contactHref);
    expect(screen.getByRole("link", {name: hostOrganizationCopy.pilot.betaAction}).getAttribute("href"))
      .toBe("/host/#founding-hosts");
    expect(container.querySelector("form, input, textarea")).toBeNull();
  });
  it("gives weddings a household coordination path, not the community admission funnel", () => {
    render(<HostContentReview />);
    const wedding = within(screen.getByRole("region", {name: hostWorkflowExamples[2].title}));
    expect(wedding.getByText("Response per invited function")).toBeTruthy();
    expect(wedding.getByText("Membership screening or ticket checkout")).toBeTruthy();
    expect(wedding.queryByText("Offer gated payment")).toBeNull();
  });
});
