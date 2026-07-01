import {useState} from "react";
import {NumberedRail} from "../../../shared/ui/primitives";
import {hostCreateSteps} from "../../marketing/content";
import {
  PhoneCaptureFrame,
  type HostCaptureMap,
} from "./CaptureFrames";

export function CreateEventWalkthrough({captures}: {captures: HostCaptureMap}) {
  const [activeStep, setActiveStep] = useState(3);
  const step = hostCreateSteps[activeStep];
  const captureId = step.captureId ?? "host-event-setup";

  return (
    <section className="host-create-flow" aria-labelledby="host-create-flow-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">From the host app · Create flow</span>
        <h2 id="host-create-flow-title">An event goes live in five steps</h2>
        <p>
          This is the actual flow, not a brochure: details, location, schedule,
          then the two steps no ticketing tool has — a full admission policy and
          a live run-of-show guide.
        </p>
      </div>
      <div className="host-create-flow__grid">
        <NumberedRail
          activeId={step.id}
          className="host-create-flow__rail"
          items={hostCreateSteps.map((item) => ({
            id: item.id,
            label: item.title,
            body: item.sub,
          }))}
          label="Create event steps"
          onSelect={(id) => setActiveStep(hostCreateSteps.findIndex((item) => item.id === id))}
          reveal
        />
        <div className="host-create-flow__mock" data-reveal>
          <div className="mock-window__bar">
            <span>Create event · step {activeStep + 1}/5 · {step.title}</span>
            <div className="host-create-flow__progress" aria-hidden="true">
              {hostCreateSteps.map((item, index) => (
                <span
                  className={index <= activeStep ? "is-complete" : ""}
                  key={item.id}
                />
              ))}
            </div>
          </div>
          <div className="host-create-flow__fields">
            {step.fields.map((field) => (
              <div className={field.wide ? "is-wide" : ""} key={field.label}>
                <span className="ui-label">{field.label}</span>
                {field.options ? (
                  <div className="host-create-flow__chips" aria-label={`${field.label}: ${field.value}`}>
                    {field.options.map((option) => (
                      <b
                        className={option === field.activeOption ? "is-active" : ""}
                        key={option}
                      >
                        {option}
                      </b>
                    ))}
                  </div>
                ) : (
                  <strong>{field.value}</strong>
                )}
                {field.note ? <p>{field.note}</p> : null}
              </div>
            ))}
          </div>
          <div className="host-create-flow__actions">
            <span>Save draft</span>
            <strong>{activeStep === hostCreateSteps.length - 1 ? "Publish event" : "Next"}</strong>
          </div>
        </div>
        <div className="host-create-flow__capture" data-reveal>
          <PhoneCaptureFrame
            key={captureId}
            id={captureId}
            fallbackStep={step.title}
            captures={captures}
          />
        </div>
      </div>
    </section>
  );
}
