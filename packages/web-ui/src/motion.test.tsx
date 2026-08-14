import {render, waitFor} from "@testing-library/react";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {LottieAnimationControl} from "./motion";

const lottieMocks = vi.hoisted(() => ({
  destroy: vi.fn(),
  getDuration: vi.fn(() => 120),
  goToAndStop: vi.fn(),
  loadAnimation: vi.fn(),
}));

vi.mock("lottie-web/build/player/lottie_light", () => ({
  default: {loadAnimation: lottieMocks.loadAnimation},
}));

describe("LottieAnimationControl", () => {
  beforeEach(() => {
    lottieMocks.loadAnimation.mockReturnValue({
      addEventListener: (_event: string, callback: () => void) => callback(),
      destroy: lottieMocks.destroy,
      getDuration: lottieMocks.getDuration,
      goToAndStop: lottieMocks.goToAndStop,
    });
  });

  it("loads lazily, seeks contracted progress, and destroys the player", async () => {
    const {rerender, unmount} = render(
      <LottieAnimationControl className="motion" progress={0.25} source="pulse.json" />
    );

    await waitFor(() => expect(lottieMocks.loadAnimation).toHaveBeenCalledTimes(1));
    expect(lottieMocks.loadAnimation).toHaveBeenCalledWith(expect.objectContaining({
      autoplay: false,
      loop: true,
      path: "pulse.json",
      renderer: "svg",
    }));
    expect(lottieMocks.goToAndStop).toHaveBeenLastCalledWith(30, true);

    rerender(
      <LottieAnimationControl className="motion" progress={0.75} source="pulse.json" />
    );
    expect(lottieMocks.goToAndStop).toHaveBeenLastCalledWith(90, true);

    unmount();
    expect(lottieMocks.destroy).toHaveBeenCalledTimes(1);
  });

  it("uses a stable frame when reduced motion is requested", async () => {
    render(
      <LottieAnimationControl
        autoplay
        reducedMotion
        reducedMotionProgress={0.4}
        source="sunrise.json"
      />
    );

    await waitFor(() => expect(lottieMocks.loadAnimation).toHaveBeenCalledTimes(1));
    expect(lottieMocks.loadAnimation).toHaveBeenCalledWith(expect.objectContaining({
      autoplay: false,
    }));
    expect(lottieMocks.goToAndStop).toHaveBeenLastCalledWith(48, true);
  });
});
