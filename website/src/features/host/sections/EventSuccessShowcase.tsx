import {useState} from "react";
import {NumberedRail} from "../../../shared/ui/primitives";
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
    <section className="event-success-showcase" aria-labelledby="event-success-showcase-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-showcase-title">Optional modules, one live guide.</h2>
        <p>
          Social runs can stay lightweight. Mixers and dinners can carry full
          facilitation. Every module below maps to the live product catalog and
          keeps private catch targets out of host reporting.
        </p>
      </div>
      <NumberedRail
        activeId={stage}
        bodyVisibility="always"
        className="event-success-stage-rail"
        items={eventSuccessStages.map((item) => ({
          id: item.id,
          label: item.label,
          body: item.sub,
        }))}
        label="Event Success stages"
        onSelect={setStage}
        reveal
      />
      <div className="event-success-showcase__grid">
        <div className="event-success-module-grid" data-reveal>
          {modules.map((module) => (
            <article key={module.title}>
              <span className="ui-label">{module.stage}</span>
              <h3>{module.title}</h3>
              <p><strong>For attendees:</strong> {module.attendee}</p>
              <p><strong>For hosts:</strong> {module.host}</p>
            </article>
          ))}
        </div>
        <CaptureCard id={captureId} fallbackStep="Event Success" captures={captures} />
      </div>
      <div className="privacy-guardrail" data-reveal>
        <strong>Guardrails are part of the product.</strong>
        Hosts see aggregate coaching, never who caught whom. Attendees can opt
        out of live modules, and blocked pairs are never assigned together.
      </div>
    </section>
  );
}
