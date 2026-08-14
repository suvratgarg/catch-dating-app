import {readFileSync} from "node:fs";
import {resolve} from "node:path";
import {describe, expect, it} from "vitest";
import {
  deriveEventSuccessMomentSeed,
  eventSuccessMomentPresentationFor,
  resolveEventSuccessCeremonyTimeline,
} from "../../firebase";
import {
  deriveEventRuntimeMarqueeParticles,
  eventRuntimeCeremonyTickMs,
  eventRuntimeVisualAssetForMotif,
  resolveEventRuntimeMarqueeFrame,
} from "./eventRuntimeMotion";

const manifest = JSON.parse(readFileSync(
  resolve(process.cwd(), "../assets/motion/event_success/manifest.json"),
  "utf8"
)) as {
  assets: Record<string, {path: string; roles: string[]}>;
  motifBindings: Record<string, string>;
  parityFixture: {
    activeRevealRoundIndex: number;
    atMillis: number;
    countdownMs: number;
    eventId: string;
    expected: {phase: string; progress: number; seed: number; visualAssetId: string};
    serverAnchorMillis: number;
  };
};

describe("event runtime marquee contract", () => {
  it("binds every generated motif to exactly one of the three portable assets", () => {
    expect(Object.keys(manifest.assets)).toEqual([
      "theatrical",
      "pulse",
      "sunrise",
    ]);
    for (const [motifId, expected] of Object.entries(manifest.motifBindings)) {
      expect(eventRuntimeVisualAssetForMotif(motifId)).toBe(expected);
    }
    expect(() => eventRuntimeVisualAssetForMotif("unknown")).toThrow(
      "Unsupported Event Success motif"
    );
  });

  it("resolves the cross-runtime fixture from the server timeline and seed", () => {
    const fixture = manifest.parityFixture;
    const presentation = eventSuccessMomentPresentationFor("liveReveal");
    const timeline = resolveEventSuccessCeremonyTimeline({
      presentation,
      revealCountdownMs: fixture.countdownMs,
      serverAnchorMillis: fixture.serverAnchorMillis,
    });
    const seed = deriveEventSuccessMomentSeed({
      activeRevealRoundIndex: fixture.activeRevealRoundIndex,
      eventId: fixture.eventId,
      presentation,
      serverAnchorMillis: fixture.serverAnchorMillis,
    });
    const frame = resolveEventRuntimeMarqueeFrame(
      {presentation, seed, timeline},
      "countingDown",
      fixture.atMillis
    );

    expect(seed).toBe(fixture.expected.seed);
    expect(eventRuntimeVisualAssetForMotif(presentation.motifId))
      .toBe(fixture.expected.visualAssetId);
    expect(frame.phase).toBe(fixture.expected.phase);
    expect(frame.phaseProgress).toBe(fixture.expected.progress);
    expect(frame.particles).toHaveLength(presentation.particleDensity);
  });

  it("enters and exits each server-clocked phase on its exact boundary", () => {
    const presentation = eventSuccessMomentPresentationFor("liveReveal");
    const timeline = resolveEventSuccessCeremonyTimeline({
      presentation,
      revealCountdownMs: 10_000,
      serverAnchorMillis: 1_000,
    });
    const ceremony = {presentation, seed: 7, timeline};
    const phaseAt = (atMillis: number) => resolveEventRuntimeMarqueeFrame(
      ceremony,
      "countingDown",
      atMillis
    ).phase;

    expect(eventRuntimeCeremonyTickMs).toBeLessThanOrEqual(250);
    expect(phaseAt(timeline.anticipationStartsAtMillis)).toBe("anticipation");
    expect(phaseAt(timeline.climaxStartsAtMillis)).toBe("climax");
    expect(phaseAt(timeline.settleStartsAtMillis)).toBe("settle");
    expect(phaseAt(timeline.completesAtMillis)).toBe("idle");
  });

  it("derives stable particle geometry shared with Flutter", () => {
    expect(deriveEventRuntimeMarqueeParticles(2_263_797_243, 1)[0])
      .toEqual({
        angleTurns: 0.8375414530368386,
        burstTurns: 0.548213584010539,
        distance: 0.8809090331385167,
        driftTurns: 0.5332150621184183,
        sizeScale: 1.074243195535206,
      });
  });
});
