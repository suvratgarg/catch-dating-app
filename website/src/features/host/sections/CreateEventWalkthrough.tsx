import {SectionHeader} from "../../../shared/site";
import {useState} from "react";
import {
  ActionGroup,
  HostCreateFlowCapture,
  HostCreateFieldGrid,
  HostCreateMockBar,
  HostFeatureGrid,
  HostFeatureRail,
  HostFeatureSection,
  ProductShell,
} from "../../../shared/ui/primitives";
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
    <HostFeatureSection variant="create-flow" aria-labelledby="host-create-flow-title">
      <SectionHeader
        eyebrow="From the host app · Create flow"
        id="host-create-flow-title"
        title="An event goes live in five steps"
        body="This is the actual flow, not a brochure: details, location, schedule, then the two steps no ticketing tool has — a full admission policy and a live run-of-show guide." />
      <HostFeatureGrid variant="create-flow">
        <HostFeatureRail
          activeId={step.id}
          items={hostCreateSteps.map((item) => ({
            id: item.id,
            label: item.title,
            body: item.sub,
          }))}
          label="Create event steps"
          onSelect={(id) => setActiveStep(hostCreateSteps.findIndex((item) => item.id === id))}
          reveal
          variant="create-flow"
        />
        <ProductShell variant="host-create-mock" reveal>
          <HostCreateMockBar activeIndex={activeStep} items={hostCreateSteps}>
            <span>Create event · step {activeStep + 1}/5 · {step.title}</span>
          </HostCreateMockBar>
          <HostCreateFieldGrid fields={step.fields} />
          <ActionGroup variant="host-create-flow">
            <span>Save draft</span>
            <strong>{activeStep === hostCreateSteps.length - 1 ? "Publish event" : "Next"}</strong>
          </ActionGroup>
        </ProductShell>
        <HostCreateFlowCapture>
          <PhoneCaptureFrame
            key={captureId}
            id={captureId}
            fallbackStep={step.title}
            captures={captures}
          />
        </HostCreateFlowCapture>
      </HostFeatureGrid>
    </HostFeatureSection>
  );
}
