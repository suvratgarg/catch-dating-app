import type {CSSProperties} from "react";
import {websiteCopy} from "@content/generated";
import {SectionHeader} from "../../../shared/site";
import {
  ActionGroup,
  ButtonLink,
  CaptureGrid,
  HomeHeroStage,
  HostHeroCopy,
  HostHeroInner,
  HostHeroShell,
  HostPageSection,
  MarketingInfoCardGrid,
  MarketingLoopList,
  MarketingSection,
  MarketingSectionCopy,
  ModuleStack,
  ProductModuleGrid,
  ProofLedgerRows,
  UiLabel,
  WaitlistSection,
} from "../../../shared/ui/primitives";
import {
  hostFillRoomModules,
  hostLoop,
  hostModules,
  hostProofRows,
  hostSurfaceCards,
} from "@content/marketing";
import {hostHeroCopy} from "@content/host";
import {trackCtaClick} from "../../marketing/tracking";
import {HostApplicationFlow} from "../application/HostApplicationFlow";
import {CaptureCard, PhoneCaptureFrame, type HostCaptureMap} from "./CaptureFrames";

export function HostHeroSection({captures}: {captures: HostCaptureMap}) {
  return (
    <HostHeroShell>
      <HostHeroInner>
        <HostHeroCopy>
          <UiLabel>{hostHeroCopy.kicker}</UiLabel>
          <h1 data-reveal style={{"--reveal-delay": "70ms"} as CSSProperties}>{websiteCopy["hostpagesections_0314"]}</h1>
          <p data-reveal style={{"--reveal-delay": "150ms"} as CSSProperties}>{websiteCopy["hostpagesections_0300"]}</p>
          <ActionGroup
            reveal
            style={{"--reveal-delay": "230ms"} as CSSProperties}
            variant="hero"
          >
            <ButtonLink
              href="#founding-hosts"
              onClick={() => trackCtaClick("host_hero_apply", "#founding-hosts")}
            >{websiteCopy["hostpagesections_0296"]}</ButtonLink>
            <ButtonLink
              variant="ghost"
              href="#workflow"
              onClick={() => trackCtaClick("host_hero_workflow", "#workflow")}
            >{websiteCopy["hostpagesections_0317"]}</ButtonLink>
          </ActionGroup>
        </HostHeroCopy>

        <HomeHeroStage data-reveal="scale" style={{"--reveal-delay": "300ms"} as CSSProperties}>
          <PhoneCaptureFrame
            id="host-live-console"
            fallbackStep={hostHeroCopy.stageCaption}
            captures={captures}
          />
        </HomeHeroStage>
      </HostHeroInner>
    </HostHeroShell>
  );
}

export function HostWorkflowSection() {
  return (
    <MarketingSection variant="story" id="workflow" aria-labelledby="workflow-title">
      <SectionHeader
        id="workflow-title"
        title={websiteCopy["hostpagesections_0311"]}
        body={websiteCopy["hostpagesections_0312"]}
      />
      <MarketingLoopList items={hostLoop} variant="host" />
    </MarketingSection>
  );
}

export function HostSurfaceSection() {
  return (
    <HostPageSection variant="surface" aria-labelledby="surface-title">
      <SectionHeader
        eyebrow={websiteCopy["hostpagesections_0324"]}
        id="surface-title"
        title={websiteCopy["hostpagesections_0322"]}
        wide
      />
      <MarketingInfoCardGrid items={hostSurfaceCards} variant="surface" />
    </HostPageSection>
  );
}

export function HostFillRoomSection() {
  return (
    <HostPageSection variant="fill-room" id="fill-room" aria-labelledby="fill-room-title">
      <SectionHeader
        eyebrow={websiteCopy["hostpagesections_0304"]}
        id="fill-room-title"
        title={websiteCopy["hostpagesections_0302"]}
        body={websiteCopy["hostpagesections_0321"]}
        wide
      />
      <ProductModuleGrid modules={hostFillRoomModules} />
    </HostPageSection>
  );
}

export function HostLiveModulesSection() {
  return (
    <MarketingSection variant="proof-host" id="live">
      <MarketingSectionCopy
        body={websiteCopy["hostpagesections_0320"]}
        eyebrow={websiteCopy["hostpagesections_0303"]}
        title={websiteCopy["hostpagesections_0309"]}
        variant="proof"
      />

      <ModuleStack items={hostModules} reveal />
    </MarketingSection>
  );
}

export function HostProofLedgerSection() {
  return (
    <HostPageSection variant="proof-ledger" aria-labelledby="proof-ledger-title">
      <SectionHeader
        eyebrow={websiteCopy["hostpagesections_0305"]}
        id="proof-ledger-title"
        title={websiteCopy["hostpagesections_0315"]}
        body={websiteCopy["hostpagesections_0299"]}
      />
      <ProofLedgerRows items={hostProofRows} reveal />
    </HostPageSection>
  );
}

export function HostCapturesSection({captures}: {captures: HostCaptureMap}) {
  return (
    <MarketingSection variant="captures" id="screens" aria-labelledby="screens-title">
      <SectionHeader
        eyebrow={websiteCopy["hostpagesections_0307"]}
        id="screens-title"
        title={websiteCopy["hostpagesections_0316"]}
        body={websiteCopy["hostpagesections_0318"]}
      />

      <CaptureGrid variant="host">
        <CaptureCard id="host-event-setup" fallbackStep={websiteCopy["hostpagesections_0319"]} captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep={websiteCopy["hostpagesections_0308"]} captures={captures} />
        <CaptureCard id="host-post-event-report" fallbackStep={websiteCopy["hostpagesections_0313"]} captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HostApplySection() {
  return (
    <WaitlistSection
      id="founding-hosts"
      titleId="host-apply-title"
      title={websiteCopy["hostpagesections_0297"]}
      body={websiteCopy["hostpagesections_0295"]}
    >
      <HostApplicationFlow />
    </WaitlistSection>
  );
}
