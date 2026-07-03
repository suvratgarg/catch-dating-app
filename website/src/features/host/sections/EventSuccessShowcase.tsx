import {SectionHeader} from "../../../shared/site";
import {useState} from "react";
import {
  EventSuccessModuleGrid,
  HostFeatureGrid,
  HostFeatureRail,
  HostFeatureSection,
  PrivacyGuardrail,
} from "../../../shared/ui/primitives";
import {
  eventSuccessModules,
  eventSuccessStages,
} from "../../marketing/content";
import {
  CaptureCard,
  type HostCaptureMap,
} from "./CaptureFrames";

export function EventSuccessShowcase({captures}: {captures: HostCaptureMap}) {
  const [stage, setStage] = useState("activity");
  const modules = eventSuccessModules.filter((module) => module.stage === stage);
  const captureId = stage === "after"
    ? "post-run-catch-window"
    : stage === "debrief"
      ? "host-post-event-report"
      : "host-live-console";

  return (
    <HostFeatureSection variant="event-success" aria-labelledby="event-success-showcase-title">
      <SectionHeader
        eyebrow="Event Success"
        id="event-success-showcase-title"
        title="Optional modules, one live guide."
        body="Social runs can stay lightweight. Mixers and dinners can carry full facilitation. Every module below maps to the live product catalog and keeps private catch targets out of host reporting." />
      <HostFeatureRail
        activeId={stage}
        bodyVisibility="always"
        items={eventSuccessStages.map((item) => ({
          id: item.id,
          label: item.label,
          body: item.sub,
        }))}
        label="Event Success stages"
        onSelect={setStage}
        reveal
        variant="event-success"
      />
      <HostFeatureGrid variant="event-success">
        <EventSuccessModuleGrid items={modules} />
        <CaptureCard id={captureId} fallbackStep="Event Success" captures={captures} />
      </HostFeatureGrid>
      <PrivacyGuardrail>
        <strong>Guardrails are part of the product.</strong>
        Hosts see aggregate coaching, never who caught whom. Attendees can opt
        out of live modules, and blocked pairs are never assigned together.
      </PrivacyGuardrail>
    </HostFeatureSection>
  );
}
