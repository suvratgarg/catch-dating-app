import {websiteCopy} from "@content/generated";
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
import {hostCreateSteps} from "@content/marketing";
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
        eyebrow={websiteCopy["createeventwalkthrough_0279"]}
        id="host-create-flow-title"
        title={websiteCopy["createeventwalkthrough_0276"]}
        body={websiteCopy["createeventwalkthrough_0281"]} />
      <HostFeatureGrid variant="create-flow">
        <HostFeatureRail
          activeId={step.id}
          items={hostCreateSteps.map((item) => ({
            id: item.id,
            label: item.title,
            body: item.sub,
          }))}
          label={websiteCopy["createeventwalkthrough_0278"]}
          onSelect={(id) => setActiveStep(hostCreateSteps.findIndex((item) => item.id === id))}
          reveal
          variant="create-flow"
        />
        <ProductShell variant="host-create-mock" reveal>
          <HostCreateMockBar activeIndex={activeStep} items={hostCreateSteps}>
            <span>{websiteCopy["createeventwalkthrough_0277"]}{activeStep + 1}/5 · {step.title}</span>
          </HostCreateMockBar>
          <HostCreateFieldGrid fields={step.fields} />
          <ActionGroup variant="host-create-flow">
            <span>{websiteCopy["createeventwalkthrough_0280"]}</span>
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
