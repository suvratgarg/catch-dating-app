import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {EventRuntimeRoomMap} from "./eventRuntime";

afterEach(cleanup);

const units = [
  {id: "round", label: "1", shape: "round" as const},
  {id: "rect", label: "2", shape: "rect" as const},
  {id: "row", label: "3", shape: "row" as const},
  {id: "court", label: "4", shape: "court" as const},
  {id: "zone", label: "5", shape: "zone" as const},
];
const positions = units.map((unit, index) => ({
  id: unit.id,
  left: index / units.length,
  top: 0,
  width: 1 / units.length,
  height: 1,
}));

describe("EventRuntimeRoomMap", () => {
  it("renders all shapes while distinguishing assigned from Host-confirmed", () => {
    const {container} = render(
      <EventRuntimeRoomMap
        assignedLabel="Assigned"
        assignedUnitId="rect"
        confirmedLabel="Host confirmed"
        confirmedUnitId="rect"
        positions={positions}
        selfLabel="You"
        subtitle="Read-only position"
        title="Where to go"
        units={units}
      />
    );

    expect(screen.getByRole("region", {name: "Where to go"})).toBeTruthy();
    for (const unit of units) {
      expect(container.querySelector(`.event-runtime__room-map-unit--${unit.shape}`))
        .toBeTruthy();
    }
    const assigned = container.querySelector(".event-runtime__room-map-unit.is-assigned");
    expect(assigned?.classList.contains("is-confirmed")).toBe(true);
    expect(screen.queryByRole("button")).toBeNull();
  });

  it("does not render an assigned position as confirmed", () => {
    const {container} = render(
      <EventRuntimeRoomMap
        assignedLabel="Assigned"
        assignedUnitId="round"
        confirmedLabel="Host confirmed"
        positions={positions}
        selfLabel="You"
        subtitle="Read-only position"
        title="Where to go"
        units={units}
      />
    );

    expect(container.querySelector(".event-runtime__room-map-unit.is-assigned"))
      .toBeTruthy();
    expect(container.querySelector(".event-runtime__room-map-unit.is-confirmed"))
      .toBeNull();
  });
});
