import {fireEvent, render, screen} from "@testing-library/react";
import {describe, expect, it, vi} from "vitest";
import {StepRail} from "./forms2";

describe("shared step control adapter", () => {
  it("selects a step without submitting its parent and preserves disabled policy", () => {
    const select=vi.fn(); const submit=vi.fn((event) => event.preventDefault());
    render(<form onSubmit={submit}><StepRail currentIndex={1} label="Review steps"
      items={[{id:"first",label:"First"},{id:"current",label:"Current"},{id:"blocked",label:"Blocked"}]}
      getDisabled={(item) => item.id === "blocked"} onSelect={select} /></form>);
    expect(screen.getByRole("button",{name:/Current/}).getAttribute("aria-current")).toBe("step");
    fireEvent.click(screen.getByRole("button",{name:/First/}));
    expect(select).toHaveBeenCalledWith("first"); expect(submit).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button",{name:/Blocked/}));
    expect(select).toHaveBeenCalledTimes(1);
  });
});
