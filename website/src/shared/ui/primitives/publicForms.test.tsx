import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {PublicFormFrame, PublicFormPrivacy} from "./publicForms";
const publicFormsCopy = {
  brand: "Catch Forms", brandWord: "catch", poweredBy: "Powered by",
  privacyNote: "Answers are sent only to the organizer named above.",
};

afterEach(cleanup);

function Branding({logoUrl, name = "Saket Run Club", embed = false}: {
  logoUrl?: string | null;
  name?: string;
  embed?: boolean;
}) {
  return (
    <PublicFormFrame embed={embed} logoUrl={logoUrl} organizerName={name}>
      <main>Application received</main>
      <PublicFormPrivacy
        brandLabel={publicFormsCopy.brand}
        brandWord={publicFormsCopy.brandWord}
        poweredByLabel={publicFormsCopy.poweredBy}
      >
        {publicFormsCopy.privacyNote}
      </PublicFormPrivacy>
    </PublicFormFrame>
  );
}

describe("public form organizer branding", () => {
  it("puts the organizer logo in the header and Catch attribution only in the footer", () => {
    render(<Branding logoUrl="https://example.com/organizer-logo.png" />);
    const header = within(screen.getByRole("banner"));
    expect(header.getByRole("img", {name: "Saket Run Club"}).getAttribute("src"))
      .toBe("https://example.com/organizer-logo.png");
    expect(header.queryByRole("link")).toBeNull();
    const footer = within(screen.getByRole("contentinfo"));
    expect(footer.getByText("Powered by")).toBeTruthy();
    expect(footer.getByRole("link", {name: "Catch Forms"}).getAttribute("href"))
      .toBe("/");
    expect(footer.getByRole("img", {name: "catch"}).getAttribute("src"))
      .toBe("/assets/branding/catch_splash_mark_light.png");
    expect(footer.queryByText("●")).toBeNull();
    expect(footer.getByText(publicFormsCopy.privacyNote)).toBeTruthy();
  });

  it.each([null, "", "   "])("uses the organizer name when the logo is %j", (logoUrl) => {
    render(<Branding logoUrl={logoUrl} />);
    const header = within(screen.getByRole("banner"));
    expect(header.getByText("Saket Run Club")).toBeTruthy();
    expect(header.queryByRole("img")).toBeNull();
  });

  it("falls back after a failed logo and can display a replacement profile logo", () => {
    const {rerender} = render(<Branding logoUrl="https://example.com/missing.png" />);
    fireEvent.error(screen.getByRole("img", {name: "Saket Run Club"}));
    expect(within(screen.getByRole("banner")).getByText("Saket Run Club")).toBeTruthy();
    expect(within(screen.getByRole("banner")).queryByRole("img")).toBeNull();
    rerender(<Branding logoUrl="https://example.com/new.png" />);
    expect(screen.getByRole("img", {name: "Saket Run Club"}).getAttribute("src"))
      .toBe("https://example.com/new.png");
  });

  it("keeps organizer identity and Catch attribution in embedded forms", () => {
    render(<Branding embed />);
    expect(within(screen.getByRole("banner")).getByText("Saket Run Club")).toBeTruthy();
    expect(within(screen.getByRole("contentinfo")).getByRole("link", {name: "Catch Forms"}))
      .toBeTruthy();
  });

  it("does not invent an organizer identity before the form has loaded", () => {
    render(<PublicFormFrame embed={false}><main>Opening form</main></PublicFormFrame>);
    expect(screen.queryByRole("banner")).toBeNull();
  });
});
