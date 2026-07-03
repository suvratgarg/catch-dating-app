import {
  ActionGroup,
  AppDownloadCtaGroup,
  ButtonLink,
  CaptureGrid,
  HostPreviewApplyShell,
  HostPreviewChipRow,
  HostPreviewConsole,
  HostPreviewFaqList,
  HostPreviewFormatRail,
  HostPreviewHeroCopy,
  HostPreviewHeroInner,
  HostPreviewHeroMedia,
  HostPreviewHeroProduct,
  HostPreviewHeroShell,
  HostPreviewHeroStores,
  HostPreviewLiveGrid,
  HostPreviewLiveModules,
  HostPreviewLoopGrid,
  HostPreviewOfferCard,
  HostPreviewOfferShell,
  HostPreviewOfferSteps,
  HostPreviewPaymentFlow,
  HostPreviewProductSplitCopy,
  HostPreviewRoster,
  HostPreviewSection,
  HostPreviewSectionHead,
  HostPreviewTrustGrid,
} from "../../../shared/ui/primitives";
import {
  hostPreviewFaqs,
  hostPreviewFormats,
  hostPreviewLoop,
  hostPreviewPaymentStates,
  hostPreviewRosterStates,
  hostPreviewTrustItems,
} from "../../marketing/content";
import {trackCtaClick} from "../../marketing/tracking";
import {useAppDownloadCtas} from "../../marketing/useAppDownloadCtas";
import {HostApplicationFlow} from "../application/HostApplicationFlow";
import {CaptureCard, PhoneCaptureFrame, type HostCaptureMap} from "./CaptureFrames";
import {CreateEventWalkthrough} from "./CreateEventWalkthrough";

const hostPreviewConsoleItems = [
  {
    key: "admission",
    label: "Admission",
    value: "Balanced request-to-join",
  },
  {
    key: "roster",
    label: "Roster",
    value: "Paid · waitlist · checked in",
  },
  {
    key: "after",
    label: "After",
    value: "Reviews · catches · report",
  },
];

const hostPreviewOfferSteps = ["Apply", "Get approved", "Publish first event", "Lock begins"];

const hostPreviewRosterItems = [
  {key: "maya", name: "Maya", status: "Approved", note: "Paid"},
  {key: "rohan", name: "Rohan", status: "Requested", note: "Balanced wait"},
  {key: "ira", name: "Ira", status: "Checked in", note: "Review eligible"},
  {key: "kabir", name: "Kabir", status: "Offer sent", note: "Expires 18:00"},
  {key: "naina", name: "Naina", status: "Refunded", note: "Cancelled"},
];

const hostPreviewLiveModules = [
  "Check-in",
  "Welcome script",
  "Prompt",
  "Rotation",
  "Override",
  "Safety",
];

export function HostPreviewHeroSection({captures}: {captures: HostCaptureMap}) {
  const appDownloadCtas = useAppDownloadCtas({placement: "host_preview_hero"});

  return (
    <HostPreviewHeroShell aria-labelledby="host-preview-title">
      <HostPreviewHeroMedia aria-hidden="true">
        <img
          src="/assets/marketing/catch-hero-event-1280.jpg"
          srcSet="/assets/marketing/catch-hero-event-960.jpg 960w, /assets/marketing/catch-hero-event-1280.jpg 1280w, /assets/marketing/catch-hero-event-1680.jpg 1680w"
          sizes="100vw"
          width="1681"
          height="936"
          fetchPriority="high"
          decoding="async"
          alt=""
        />
      </HostPreviewHeroMedia>
      <HostPreviewHeroInner>
        <HostPreviewHeroCopy>
          <h1 id="host-preview-title" data-reveal>
            Host social events people actually want to join.
          </h1>
          <p data-reveal>
            Catch gives hosts one place to publish events, manage admission,
            take payment, run the room, and turn attendance into private
            follow-up.
          </p>
          <ActionGroup variant="hero" reveal>
            <ButtonLink
              href="#founding-hosts"
              onClick={() => trackCtaClick("host_preview_apply", "#founding-hosts")}
            >
              Apply for founding host access
            </ButtonLink>
            <ButtonLink
              variant="ghost"
              href="#operating-loop"
              onClick={() => trackCtaClick("host_preview_workflow", "#operating-loop")}
            >
              See how Catch works
            </ButtonLink>
          </ActionGroup>
          <HostPreviewHeroStores>
            <AppDownloadCtaGroup
              {...appDownloadCtas}
              variant="compact"
              initialStatus="Download Catch on iOS or Android at launch."
            />
          </HostPreviewHeroStores>
        </HostPreviewHeroCopy>

        <HostPreviewHeroProduct reveal>
          <HostPreviewConsole
            label="Host console"
            title="Sunday Table Club"
            items={hostPreviewConsoleItems}
          />
          <PhoneCaptureFrame
            id="host-live-console"
            fallbackStep="Live console"
            captures={captures}
          />
        </HostPreviewHeroProduct>
      </HostPreviewHeroInner>
    </HostPreviewHeroShell>
  );
}

export function HostPreviewOfferSection() {
  return (
    <HostPreviewOfferShell id="offer" aria-labelledby="host-preview-offer-title">
      <HostPreviewOfferCard
        badgeAriaLabel="Founding Host badge preview"
        badgeLabel="Founding"
        badgeValue="Host"
        body={
          <>
            Apply for manual approval. Your 24-month lock starts when your
            first Catch event goes live. Standard payment processor fees
            still apply, e.g. Stripe, Razorpay, etc.
          </>
        }
        reveal
        title="Founding hosts pay 0% Catch platform fee for 24 months."
        titleId="host-preview-offer-title"
      />
      <HostPreviewOfferSteps items={hostPreviewOfferSteps} reveal />
    </HostPreviewOfferShell>
  );
}

export function HostPreviewFormatsSection() {
  return (
    <HostPreviewSection id="formats" aria-labelledby="host-preview-formats-title">
      <HostPreviewSectionHead
        body={
          <>
            Catch is for the organizer who cares about the guest mix, the door,
            the flow of the night, and what happens after people meet.
          </>
        }
        reveal
        title="Built for hosted rooms, not one event type."
        titleId="host-preview-formats-title"
      />
      <HostPreviewFormatRail
        items={hostPreviewFormats.map((format) => ({key: format, label: format}))}
      />
    </HostPreviewSection>
  );
}

export function HostPreviewOperatingLoopSection() {
  return (
    <HostPreviewSection
      variant="loop"
      id="operating-loop"
      aria-labelledby="host-preview-loop-title"
    >
      <HostPreviewSectionHead
        body={
          <>
            Ticketing, waitlist movement, check-in, live facilitation, reviews,
            catches, matches, and reports stay connected to the same event.
          </>
        }
        reveal
        title="One event record, from interest to follow-up."
        titleId="host-preview-loop-title"
      />
      <HostPreviewLoopGrid items={hostPreviewLoop} reveal />
    </HostPreviewSection>
  );
}

export function HostPreviewCreateFlowSection({captures}: {captures: HostCaptureMap}) {
  return (
    <div id="create-flow">
      <CreateEventWalkthrough captures={captures} />
    </div>
  );
}

export function HostPreviewAdmissionSection() {
  return (
    <HostPreviewSection
      variant="product-split"
      id="admission"
      aria-labelledby="host-preview-admission-title"
    >
      <HostPreviewProductSplitCopy
        body={
          <>
            Use open booking, invite-only access, request-to-join, balanced
            cohorts, capacity rules, and timed waitlist offers without moving
            between forms, DMs, and spreadsheets.
          </>
        }
        reveal
        title="Shape demand before the room fills."
        titleId="host-preview-admission-title"
      >
        <HostPreviewChipRow
          aria-label="Roster states"
          items={hostPreviewRosterStates.map((state) => ({key: state, label: state}))}
        />
      </HostPreviewProductSplitCopy>
      <HostPreviewRoster items={hostPreviewRosterItems} reveal />
    </HostPreviewSection>
  );
}

export function HostPreviewPaymentsSection() {
  return (
    <HostPreviewSection variant="payments" aria-labelledby="host-preview-payments-title">
      <HostPreviewSectionHead
        body={
          <>
            Catch keeps checkout, payment state, cancellation, refund status,
            and attendance on the same roster, so hosts are not reconciling
            guests across separate tools.
          </>
        }
        reveal
        title="Ticketing, refunds, and check-in stay connected."
        titleId="host-preview-payments-title"
      />
      <HostPreviewPaymentFlow items={hostPreviewPaymentStates} reveal />
    </HostPreviewSection>
  );
}

export function HostPreviewLiveSection({captures}: {captures: HostCaptureMap}) {
  return (
    <HostPreviewSection variant="live" id="live" aria-labelledby="host-preview-live-title">
      <HostPreviewSectionHead
        body={
          <>
            Check guests in, follow prompts, manage rotations, make overrides,
            and keep safety controls close while the event is happening.
          </>
        }
        reveal
        title="Run the event from the host screen."
        titleId="host-preview-live-title"
      />
      <HostPreviewLiveGrid>
        <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
        <HostPreviewLiveModules items={hostPreviewLiveModules} reveal />
      </HostPreviewLiveGrid>
    </HostPreviewSection>
  );
}

export function HostPreviewAfterSection({captures}: {captures: HostCaptureMap}) {
  return (
    <HostPreviewSection variant="after" aria-labelledby="host-preview-after-title">
      <HostPreviewSectionHead
        body={
          <>
            Guests can privately catch people they actually met. Mutual catches
            become chats with shared event context. Hosts see aggregate signals,
            not private interest.
          </>
        }
        reveal
        title="Follow-up starts after attendance."
        titleId="host-preview-after-title"
      />
      <CaptureGrid variant="host">
        <CaptureCard id="post-run-catch-window" fallbackStep="Catch window" captures={captures} />
        <CaptureCard id="match-chat-context" fallbackStep="Match chat" captures={captures} />
        <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
      </CaptureGrid>
    </HostPreviewSection>
  );
}

export function HostPreviewTrustSection() {
  return (
    <HostPreviewSection variant="trust" aria-labelledby="host-preview-trust-title">
      <HostPreviewSectionHead
        body={
          <>
            The page should answer operational concerns before a host reaches
            the application form.
          </>
        }
        reveal
        title="Guardrails are part of the product."
        titleId="host-preview-trust-title"
      />
      <HostPreviewTrustGrid items={hostPreviewTrustItems} reveal />
    </HostPreviewSection>
  );
}

export function HostPreviewFaqSection() {
  return (
    <HostPreviewSection variant="faq" aria-labelledby="host-preview-faq-title">
      <HostPreviewSectionHead
        reveal
        title="Questions hosts ask before switching tools."
        titleId="host-preview-faq-title"
      />
      <HostPreviewFaqList items={hostPreviewFaqs} reveal />
    </HostPreviewSection>
  );
}

export function HostPreviewApplySection() {
  return (
    <HostPreviewApplyShell
      id="founding-hosts"
      titleId="host-preview-apply-title"
      title="Apply once. Publish when approved."
      body="Approved founding hosts get the public badge, increased discovery visibility, and the 24-month platform-fee lock when their first Catch event goes live."
    >
      <HostApplicationFlow />
    </HostPreviewApplyShell>
  );
}
