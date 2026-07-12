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
} from "../../marketing/content";
import {trackCtaClick} from "../../marketing/tracking";
import {HostApplicationFlow} from "../application/HostApplicationFlow";
import {CaptureCard, type HostCaptureMap} from "./CaptureFrames";

const hostConsoleSummaryItems = [
  {key: "admission", label: "Admission", value: "Requests + invite links"},
  {key: "live", label: "Live moment", value: "Balanced rotations"},
  {key: "after", label: "After event", value: "18 mutual matches"},
];

export function HostHeroSection() {
  return (
    <HostHeroShell>
      <HostHeroInner>
        <HostHeroCopy>
          <h1 data-reveal>Run singles events people actually follow through on.</h1>
          <p data-reveal>
            Catch handles the loop around your event: booking logic, admission,
            waitlists, live facilitation, check-in, private catches, and the
            post-event report that shows what actually happened.
          </p>
          <ActionGroup variant="hero" reveal>
            <ButtonLink
              href="#founding-hosts"
              onClick={() => trackCtaClick("host_hero_apply", "#founding-hosts")}
            >
              Apply as host
            </ButtonLink>
            <ButtonLink
              variant="ghost"
              href="#workflow"
              onClick={() => trackCtaClick("host_hero_workflow", "#workflow")}
            >
              See workflow
            </ButtonLink>
          </ActionGroup>
        </HostHeroCopy>

        <ProductShell variant="host-console" aria-label="Host console" reveal>
          <HostConsoleHeader label="Host console" title={activeMarket.exampleEvent.name} />
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
        eyebrow="What a host can see"
        id="host-evidence-title"
        title="Catch shows the path from interest to attendance to follow-up."
        body={<>Catch answers more than "who RSVP'd?" It shows where demand came from, where people dropped off, and whether the event created real connection afterward.</>}
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
        title="One loop, from booking to connection."
        body="Replace forms, payment links, spreadsheets, group chats, manual intros, and safety notes with one flow built around the event."
      />
      <MarketingLoopList items={hostLoop} variant="host" />
    </MarketingSection>
  );
}

export function HostSurfaceSection() {
  return (
    <HostPageSection variant="surface" aria-labelledby="surface-title">
      <SectionHeader
        eyebrow="What Catch handles"
        id="surface-title"
        title="The platform is not just ticketing, and it is not just matching."
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
        eyebrow="Fill the room"
        id="fill-room-title"
        title="Checkout, waitlist, and cohort controls belong in the same roster."
        body="The mockup split these into concrete host promises. In production they should stay connected to the event record instead of becoming separate ticketing, spreadsheet, or DM workflows."
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
        body="The live catalog is explicit: booking balance preview, attendance and roster, welcome scripts, prompts, assignments, rotations, private catches, feedback, and aggregate host reports."
        eyebrow="Event Success"
        title="Live facilitation is built into the event flow."
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
        eyebrow="Host confidence"
        id="proof-ledger-title"
        title="Run the whole event loop from one place."
        body="Catch gives hosts the controls to shape demand, guide the live experience, and understand what happened after people met."
      />
      <ProofLedgerRows items={hostProofRows} reveal />
    </HostPageSection>
  );
}

export function HostCapturesSection({captures}: {captures: HostCaptureMap}) {
  return (
    <MarketingSection variant="captures" id="screens" aria-labelledby="screens-title">
      <SectionHeader
        eyebrow="Host tools"
        id="screens-title"
        title="See the host workflow end to end."
        body="Set up the event, manage the live moment, and review the signals that help the next event get better."
      />

      <CaptureGrid variant="host">
        <CaptureCard id="host-event-setup" fallbackStep="Setup" captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
        <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HostApplySection() {
  return (
    <WaitlistSection
      id="founding-hosts"
      titleId="host-apply-title"
      title="Bring the format. Catch handles the loop around it."
      body="Apply as a founding host if you run events, communities, venues, or formats where the right singles can meet with more context."
    >
      <HostApplicationFlow />
    </WaitlistSection>
  );
}
