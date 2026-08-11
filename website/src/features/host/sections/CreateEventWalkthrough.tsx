import {hostPageCopy} from "@content/host";
import {SectionHeader} from "../../../shared/site";
import {useState} from "react";
import {
  ActionGroup,
  HostCreateFieldGrid,
  HostCreateMockBar,
  HostFeatureGrid,
  HostFeatureRail,
  HostFeatureSection,
  ProductShell,
} from "../../../shared/ui/primitives";
import {hostCreateSteps} from "@content/marketing";
import type {HostCaptureMap} from "./CaptureFrames";

export function CreateEventWalkthrough({captures: _captures}: {captures: HostCaptureMap}) {
  const [activeStep, setActiveStep] = useState(0);
  const step = hostCreateSteps[activeStep];

  return (
    <HostFeatureSection variant="create-flow" aria-labelledby="host-create-flow-title">
      <SectionHeader
        eyebrow={hostPageCopy.workflow.railLabel}
        id="host-create-flow-title"
        title={hostPageCopy.workflow.title}
        body={hostPageCopy.workflow.body} />
      <HostFeatureGrid variant="create-flow">
        <HostFeatureRail
          activeId={step.id}
          items={hostCreateSteps.map((item) => ({
            id: item.id,
            label: item.title,
            body: item.sub,
          }))}
          label={hostPageCopy.workflow.railLabel}
          onSelect={(id) => setActiveStep(hostCreateSteps.findIndex((item) => item.id === id))}
          reveal
          variant="create-flow"
        />
        <ProductShell variant="host-create-mock" reveal>
          <HostCreateMockBar activeIndex={activeStep} items={hostCreateSteps}>
            <span>
              {hostPageCopy.workflow.mockLabel} {activeStep + 1}/{hostCreateSteps.length} · {step.title}
            </span>
          </HostCreateMockBar>
          <HostCreateFieldGrid fields={step.fields} />
          <ActionGroup variant="host-create-flow">
            <span>{step.outcome}</span>
            <strong>
              {activeStep === hostCreateSteps.length - 1
                ? hostPageCopy.workflow.readyLabel
                : hostPageCopy.workflow.nextLabel}
            </strong>
          </ActionGroup>
        </ProductShell>
      </HostFeatureGrid>
    </HostFeatureSection>
  );
}
