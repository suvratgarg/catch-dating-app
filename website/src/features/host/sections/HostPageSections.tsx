import {websiteCopy} from "@content/generated";
import {SectionHeader} from "../../../shared/site";
import {activeMarket} from "@content/markets";
import {
  ActionGroup,
  ButtonLink,
  CaptureGrid,
  EvidenceStrip,
  HostConsoleGrid,
  HostConsoleHeader,
  HostConsoleTimeline,
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
  ProductShell,
  ProofLedgerRows,
  WaitlistSection,
} from "../../../shared/ui/primitives";
import {
  hostEvidenceMetrics,
  hostFillRoomModules,
  hostLoop,
  hostModules,
  hostProofRows,
  hostSurfaceCards,
} from "@content/marketing";
import {trackCtaClick} from "../../marketing/tracking";
import {HostApplicationFlow} from "../application/HostApplicationFlow";
import {CaptureCard, type HostCaptureMap} from "./CaptureFrames";

const hostConsoleSummaryItems = [
  {key: "admission", label: websiteCopy["hostpagesections_0293"], value: "Requests + invite links"},
  {key: "live", label: websiteCopy["hostpagesections_0310"], value: "Balanced rotations"},
  {key: "after", label: websiteCopy["hostpagesections_0294"], value: "18 mutual matches"},
];

export function HostHeroSection() {
  return (
    <HostHeroShell>
      <HostHeroInner>
        <HostHeroCopy>
          <h1 data-reveal>{websiteCopy["hostpagesections_0314"]}</h1>
          <p data-reveal>{websiteCopy["hostpagesections_0300"]}</p>
          <ActionGroup variant="hero" reveal>
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

        <ProductShell variant="host-console" aria-label={websiteCopy["hostpagesections_0306"]} reveal>
          <HostConsoleHeader label={websiteCopy["hostpagesections_0306"]} title={activeMarket.exampleEvent.name} />
          <HostConsoleGrid items={hostConsoleSummaryItems} />
          <HostConsoleTimeline items={hostEvidenceMetrics} />
        </ProductShell>
      </HostHeroInner>
    </HostHeroShell>
  );
}

export function HostEvidenceSection() {
  return (
    <HostPageSection variant="evidence" aria-labelledby="host-evidence-title">
      <SectionHeader
        eyebrow={websiteCopy["hostpagesections_0323"]}
        id="host-evidence-title"
        title={websiteCopy["hostpagesections_0301"]}
        body={<>{websiteCopy["hostpagesections_0298"]}</>}
      />
      <EvidenceStrip items={hostEvidenceMetrics} reveal />
    </HostPageSection>
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
