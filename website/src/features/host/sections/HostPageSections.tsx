import type {CSSProperties} from "react";
import {
  hostComingSoonItems,
  hostCurrentLayers,
  hostHeroCopy,
  hostLiveTools,
  hostPageCopy,
  hostSetupProof,
  hostWorkflowSteps,
} from "@content/host";
import {SectionHeader} from "../../../shared/site";
import {
  ActionGroup,
  ButtonLink,
  CaptureGrid,
  HomeHeroStage,
  HostBridgeDemo,
  HostCompatibilityLine,
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
  WaitlistSection,
} from "../../../shared/ui/primitives";
import {trackCtaClick} from "../../marketing/tracking";
import {HostApplicationFlow} from "../application/HostApplicationFlow";
import {CaptureCard, type HostCaptureMap} from "./CaptureFrames";

export function HostHeroSection({captures: _captures}: {captures: HostCaptureMap}) {
  return (
    <HostHeroShell>
      <HostHeroInner>
        <HostHeroCopy>
          <h1 data-reveal style={{"--reveal-delay": "70ms"} as CSSProperties}>
            {hostPageCopy.hero.title}
          </h1>
          <p data-reveal style={{"--reveal-delay": "150ms"} as CSSProperties}>
            {hostPageCopy.hero.body}
          </p>
          <ActionGroup
            reveal
            style={{"--reveal-delay": "230ms"} as CSSProperties}
            variant="hero"
          >
            <ButtonLink
              href="#founding-hosts"
              onClick={() => trackCtaClick("host_hero_apply", "#founding-hosts")}
            >
              {hostPageCopy.hero.primaryAction}
            </ButtonLink>
            <ButtonLink
              variant="ghost"
              href="#workflow"
              onClick={() => trackCtaClick("host_hero_workflow", "#workflow")}
            >
              {hostPageCopy.hero.secondaryAction}
            </ButtonLink>
          </ActionGroup>
        </HostHeroCopy>

        <HomeHeroStage>
          <HostBridgeDemo {...hostHeroCopy.demo} />
        </HomeHeroStage>
      </HostHeroInner>
      <HostCompatibilityLine>{hostPageCopy.hero.compatibility}</HostCompatibilityLine>
    </HostHeroShell>
  );
}

export function HostWorkflowSection() {
  return (
    <MarketingSection variant="story" id="workflow" aria-labelledby="workflow-title">
      <SectionHeader
        id="workflow-title"
        title={hostPageCopy.workflow.title}
        body={hostPageCopy.workflow.body}
      />
      <MarketingLoopList items={[...hostWorkflowSteps]} variant="host" />
    </MarketingSection>
  );
}

export function HostSurfaceSection() {
  return (
    <HostPageSection variant="surface" id="works-now" aria-labelledby="surface-title">
      <SectionHeader
        eyebrow={hostPageCopy.comparison.label}
        id="surface-title"
        title={hostPageCopy.live.title}
        body={hostPageCopy.live.body}
        wide
      />
      <MarketingInfoCardGrid items={[...hostCurrentLayers]} variant="surface" />
    </HostPageSection>
  );
}

export function HostFillRoomSection() {
  return (
    <HostPageSection variant="fill-room" aria-labelledby="host-setup-proof-title">
      <SectionHeader
        eyebrow={hostPageCopy.workflow.railLabel}
        id="host-setup-proof-title"
        title={hostPageCopy.workflow.title}
        body={hostPageCopy.workflow.body}
        wide
      />
      <ProductModuleGrid modules={[...hostSetupProof]} />
    </HostPageSection>
  );
}

export function HostLiveModulesSection() {
  return (
    <MarketingSection variant="proof-host" id="live">
      <MarketingSectionCopy
        body={hostPageCopy.live.body}
        eyebrow={hostPageCopy.live.label}
        title={hostPageCopy.live.title}
        variant="proof"
      />
      <ModuleStack items={[...hostLiveTools]} reveal />
    </MarketingSection>
  );
}

export function HostProofLedgerSection() {
  return (
    <HostPageSection
      variant="proof-ledger"
      id="coming-soon"
      aria-labelledby="coming-soon-title"
    >
      <SectionHeader
        eyebrow={hostPageCopy.comingSoon.label}
        id="coming-soon-title"
        title={hostPageCopy.comingSoon.title}
        body={hostPageCopy.comingSoon.body}
      />
      <ProofLedgerRows items={[...hostComingSoonItems]} reveal />
    </HostPageSection>
  );
}

export function HostCapturesSection({captures}: {captures: HostCaptureMap}) {
  return (
    <MarketingSection variant="captures" id="screens" aria-labelledby="screens-title">
      <SectionHeader
        eyebrow={hostPageCopy.captures.label}
        id="screens-title"
        title={hostPageCopy.captures.title}
        body={hostPageCopy.captures.body}
      />

      <CaptureGrid variant="host">
        <CaptureCard id="host-event-setup" fallbackStep={hostPageCopy.captures.setup} captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep={hostPageCopy.captures.live} captures={captures} />
        <CaptureCard id="host-post-event-report" fallbackStep={hostPageCopy.captures.report} captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HostApplySection() {
  return (
    <WaitlistSection
      id="founding-hosts"
      titleId="host-apply-title"
      title={hostPageCopy.apply.title}
      body={hostPageCopy.apply.body}
    >
      <HostApplicationFlow />
    </WaitlistSection>
  );
}
