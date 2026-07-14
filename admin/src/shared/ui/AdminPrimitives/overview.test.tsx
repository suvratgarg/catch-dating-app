import {cleanup, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";

import {
  AdminOverviewBarChart,
  AdminOverviewLineChart,
  AdminSignalBars,
} from "./overview";

afterEach(() => cleanup());

describe("admin analytics primitives", () => {
  it("exposes line chart labels and values as readable content", () => {
    render(
      <AdminOverviewLineChart
        ariaLabel="Attendance trend"
        emptyLabel="No trend data"
        points={[
          {label: "Mon", value: 42},
          {label: "Tue", value: 68},
        ]}
      />
    );

    const chart = screen.getByLabelText("Attendance trend");
    expect(within(chart).getByText("Mon")).toBeTruthy();
    expect(within(chart).getByText("42")).toBeTruthy();
  });

  it("renders zero-value bars as zero height while keeping the value visible", () => {
    const {container} = render(
      <AdminOverviewBarChart
        ariaLabel="Booking demand"
        emptyLabel="No demand"
        points={[
          {label: "Open", value: 8},
          {label: "Blocked", value: 0},
        ]}
      />
    );

    expect(screen.getByLabelText("Booking demand").textContent)
      .toContain("Blocked0");
    const bars = container.querySelectorAll<HTMLElement>(".bar");
    expect(bars[1]?.style.height).toBe("0%");
  });

  it("labels signal groups and preserves neutral zero-value signals", () => {
    const {container} = render(
      <AdminSignalBars
        ariaLabel="Open cases by queue"
        signals={[
          {label: "User reports", tone: "neutral", value: 12},
          {label: "Event reports", tone: "neutral", value: 0},
        ]}
      />
    );

    const list = screen.getByRole("list", {name: "Open cases by queue"});
    expect(within(list).getAllByRole("listitem")).toHaveLength(2);
    expect(list.textContent).toContain("Event reports0");
    const fills = container.querySelectorAll<HTMLElement>(".signal-fill");
    expect(fills[1]?.classList.contains("neutral")).toBe(true);
    expect(fills[1]?.style.width).toBe("0%");
  });
});
