import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {
  EventRuntimeArrivalRing,
  EventRuntimeRoomMap,
  EventRuntimeStageMarquee,
} from "./eventRuntime";

vi.mock("@catch/web-ui", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@catch/web-ui")>();
  return {
    ...actual,
    LottieAnimationControl: ({source, ...props}: {source: string}) => (
      <span {...props} data-lottie-source={source} />
    ),
  };
});

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

describe("Event Runtime portable motion", () => {
  it("renders the contracted reveal layers and caps anonymous presence dots", () => {
    const {container} = render(
      <EventRuntimeStageMarquee
        participantCount={40}
        particles={[{
          angleTurns: 0.25,
          burstTurns: 0.75,
          distance: 0.5,
          driftTurns: 0.1,
          sizeScale: 1.2,
        }]}
        phase="anticipation"
        phaseProgress={0.5}
        seedAngleTurns={0.3}
        stageSource="pulse.json"
        sunriseSource="sunrise.json"
        tickProgress={0.2}
      />
    );

    expect(container.querySelector("[data-phase='anticipation']")).toBeTruthy();
    expect(container.querySelectorAll(".event-runtime__reveal-spokes span"))
      .toHaveLength(14);
    expect(container.querySelectorAll(".event-runtime__reveal-presence span"))
      .toHaveLength(28);
    expect(container.querySelectorAll(".event-runtime__reveal-particles span"))
      .toHaveLength(1);
    expect(container.querySelector("[data-lottie-source='pulse.json']"))
      .toBeTruthy();
  });

  it("announces the arrival count without exposing attendee identity", () => {
    render(
      <EventRuntimeArrivalRing
        ariaLabel="18 people checked in"
        count={18}
        label="checked in"
        source="theatrical.json"
      />
    );

    expect(screen.getByLabelText("18 people checked in")).toBeTruthy();
    expect(screen.getByText("18")).toBeTruthy();
    expect(screen.getByText("checked in")).toBeTruthy();
  });
});
