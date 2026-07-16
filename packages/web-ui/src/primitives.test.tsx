import {fireEvent, render, screen} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {
  BadgeControl,
  ButtonControl,
  DataTableControl,
  EmptyStateControl,
  SelectControl,
  TextareaControl,
  TextInputControl,
  ToggleButtonControl,
  ToggleGroupControl,
} from "./primitives";

describe("shared button control", () => {
  it("defaults to a non-submitting button", () => {
    render(<ButtonControl>Open</ButtonControl>);

    const button = screen.getByRole("button", {name: "Open"});
    expect(button.getAttribute("type")).toBe("button");
    expect(button.hasAttribute("aria-busy")).toBe(false);
    expect(button.hasAttribute("data-loading")).toBe(false);
    expect(button.hasAttribute("disabled")).toBe(false);
  });

  it("makes loading buttons busy and non-interactive", () => {
    const onClick = vi.fn();
    render(
      <ButtonControl loading onClick={onClick} type="submit">
        Saving
      </ButtonControl>
    );

    const button = screen.getByRole("button", {name: "Saving"});
    expect(button.getAttribute("type")).toBe("submit");
    expect(button.getAttribute("aria-busy")).toBe("true");
    expect(button.getAttribute("data-loading")).toBe("true");
    expect(button.hasAttribute("disabled")).toBe(true);
    fireEvent.click(button);
    expect(onClick).not.toHaveBeenCalled();
  });
});

describe("shared toggle controls", () => {
  it("exposes a named group and pressed state", () => {
    render(
      <ToggleGroupControl aria-label="View mode">
        <ToggleButtonControl selected>List</ToggleButtonControl>
        <ToggleButtonControl selected={false}>Grid</ToggleButtonControl>
      </ToggleGroupControl>
    );

    expect(screen.getByRole("group", {name: "View mode"})).toBeTruthy();
    expect(screen.getByRole("button", {name: "List"}).getAttribute("aria-pressed")).toBe("true");
    expect(screen.getByRole("button", {name: "List"}).getAttribute("data-selected")).toBe("true");
    expect(screen.getByRole("button", {name: "Grid"}).getAttribute("aria-pressed")).toBe("false");
    expect(screen.getByRole("button", {name: "Grid"}).hasAttribute("data-selected")).toBe(false);
  });

  it("uses non-submitting buttons and preserves native disabled behavior", () => {
    const onClick = vi.fn();
    render(
      <ToggleButtonControl disabled onClick={onClick} selected={false}>
        Disabled option
      </ToggleButtonControl>
    );

    const button = screen.getByRole("button", {name: "Disabled option"});
    expect(button.getAttribute("type")).toBe("button");
    fireEvent.click(button);
    expect(onClick).not.toHaveBeenCalled();
  });
});

describe("shared data table control", () => {
  it("names both the keyboard-scroll region and table", () => {
    render(
      <DataTableControl ariaLabel="Organizer queue">
        <tbody><tr><td>Catch Club</td></tr></tbody>
      </DataTableControl>
    );

    const region = screen.getByRole("region", {name: "Organizer queue"});
    expect(region.getAttribute("tabindex")).toBe("0");
    expect(screen.getByRole("table", {name: "Organizer queue"})).toBeTruthy();
  });
});

describe("shared field controls", () => {
  it("maps validation state to native accessibility attributes", () => {
    render(
      <>
        <TextInputControl aria-label="Name" descriptionId="name-error" invalid />
        <SelectControl aria-label="City" descriptionId="city-help">
          <option>Delhi</option>
        </SelectControl>
        <TextareaControl aria-label="Notes" />
      </>
    );

    const input = screen.getByRole("textbox", {name: "Name"});
    expect(input.getAttribute("aria-invalid")).toBe("true");
    expect(input.getAttribute("aria-describedby")).toBe("name-error");
    expect(screen.getByRole("combobox", {name: "City"}).getAttribute("aria-describedby")).toBe("city-help");
    expect(screen.getByRole("textbox", {name: "Notes"}).hasAttribute("aria-invalid")).toBe(false);
  });
});

describe("shared feedback controls", () => {
  it("keeps static empty states quiet and supports explicit announcements", () => {
    const {rerender} = render(<EmptyStateControl>No matches</EmptyStateControl>);
    expect(screen.getByText("No matches").getAttribute("role")).toBe(null);

    rerender(
      <EmptyStateControl announce="polite" contentElement="span">
        No matches
      </EmptyStateControl>
    );
    const status = screen.getByRole("status");
    expect(status.getAttribute("aria-live")).toBe("polite");
    expect(status.querySelector("span")?.textContent).toBe("No matches");
  });

  it("keeps badge content in a non-interactive inline element", () => {
    render(<BadgeControl>Ready</BadgeControl>);
    expect(screen.getByText("Ready").tagName).toBe("SPAN");
  });
});
