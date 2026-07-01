import {SiteFooter, SiteHeader} from "../../shared/site";
import {ButtonLink} from "../../shared/ui/primitives";
import {AppDownloadCtas} from "../marketing/AppDownloadCtas";
import {
  hostPreviewFaqs,
  hostPreviewFormats,
  hostPreviewLoop,
  hostPreviewPaymentStates,
  hostPreviewRosterStates,
  hostPreviewTrustItems,
} from "../marketing/content";
import {trackCtaClick} from "../marketing/tracking";
import {HostApplicationFlow} from "./application/HostApplicationFlow";
import {
  CaptureCard,
  PhoneCaptureFrame,
  type HostCaptureMap,
} from "./sections/CaptureFrames";
import {CreateEventWalkthrough} from "./sections/CreateEventWalkthrough";
import {HostComparisonSection} from "./sections/HostComparisonSection";

export function HostPreviewPage({captures}: {captures: HostCaptureMap}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#offer", label: "Offer"},
          {href: "#formats", label: "Formats"},
          {href: "#operating-loop", label: "Workflow"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply for founding host access"
      />

      <main id="top" className="host-preview">
        <section className="host-preview-hero" aria-labelledby="host-preview-title">
          <div className="host-preview-hero__media" aria-hidden="true">
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
          </div>
          <div className="host-preview-hero__inner">
            <div className="host-preview-hero__copy">
              <h1 id="host-preview-title" data-reveal>
                Host social events people actually want to join.
              </h1>
              <p data-reveal>
                Catch gives hosts one place to publish events, manage admission,
                take payment, run the room, and turn attendance into private
                follow-up.
              </p>
              <div className="hero__actions" data-reveal>
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
              </div>
              <AppDownloadCtas
                placement="host_preview_hero"
                className="app-download-ctas--compact host-preview-hero__stores"
                initialStatus="Download Catch on iOS or Android at launch."
              />
            </div>

            <div className="host-preview-hero__product" data-reveal>
              <div className="host-preview-console">
                <div>
                  <span>Host console</span>
                  <strong>Sunday Table Club</strong>
                </div>
                <dl>
                  <div>
                    <dt>Admission</dt>
                    <dd>Balanced request-to-join</dd>
                  </div>
                  <div>
                    <dt>Roster</dt>
                    <dd>Paid · waitlist · checked in</dd>
                  </div>
                  <div>
                    <dt>After</dt>
                    <dd>Reviews · catches · report</dd>
                  </div>
                </dl>
              </div>
              <PhoneCaptureFrame
                id="host-live-console"
                fallbackStep="Live console"
                captures={captures}
              />
            </div>
          </div>
        </section>

        <section className="host-preview-offer" id="offer" aria-labelledby="host-preview-offer-title">
          <div className="host-preview-offer__card" data-reveal>
            <div>
              <h2 id="host-preview-offer-title">
                Founding hosts pay 0% Catch platform fee for 24 months.
              </h2>
              <p>
                Apply for manual approval. Your 24-month lock starts when your
                first Catch event goes live. Standard payment processor fees
                still apply, e.g. Stripe, Razorpay, etc.
              </p>
            </div>
            <div className="host-preview-badge" aria-label="Founding Host badge preview">
              <span>Founding</span>
              <strong>Host</strong>
            </div>
          </div>
          <div className="host-preview-offer__steps" data-reveal>
            {["Apply", "Get approved", "Publish first event", "Lock begins"].map((item, index) => (
              <div key={item}>
                <span>0{index + 1}</span>
                <strong>{item}</strong>
              </div>
            ))}
          </div>
        </section>

        <section className="host-preview-section" id="formats" aria-labelledby="host-preview-formats-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-formats-title">Built for hosted rooms, not one event type.</h2>
            <p>
              Catch is for the organizer who cares about the guest mix, the door,
              the flow of the night, and what happens after people meet.
            </p>
          </div>
          <div className="host-preview-format-rail" data-reveal>
            {hostPreviewFormats.map((format) => (
              <span key={format}>{format}</span>
            ))}
          </div>
        </section>

        <HostComparisonSection />

        <section
          className="host-preview-section host-preview-loop"
          id="operating-loop"
          aria-labelledby="host-preview-loop-title"
        >
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-loop-title">One event record, from interest to follow-up.</h2>
            <p>
              Ticketing, waitlist movement, check-in, live facilitation, reviews,
              catches, matches, and reports stay connected to the same event.
            </p>
          </div>
          <div className="host-preview-loop__grid">
            {hostPreviewLoop.map((item, index) => (
              <article data-reveal key={item.step}>
                <span>0{index + 1}</span>
                <div>
                  <strong>{item.step}</strong>
                  <h3>{item.title}</h3>
                  <p>{item.body}</p>
                </div>
              </article>
            ))}
          </div>
        </section>

        <div id="create-flow">
          <CreateEventWalkthrough captures={captures} />
        </div>

        <section className="host-preview-section host-preview-product-split" id="admission" aria-labelledby="host-preview-admission-title">
          <div className="host-preview-product-split__copy" data-reveal>
            <h2 id="host-preview-admission-title">Shape demand before the room fills.</h2>
            <p>
              Use open booking, invite-only access, request-to-join, balanced
              cohorts, capacity rules, and timed waitlist offers without moving
              between forms, DMs, and spreadsheets.
            </p>
            <div className="host-preview-chip-row" aria-label="Roster states">
              {hostPreviewRosterStates.map((state) => (
                <span key={state}>{state}</span>
              ))}
            </div>
          </div>
          <div className="host-preview-roster" data-reveal>
            {[
              ["Maya", "Approved", "Paid"],
              ["Rohan", "Requested", "Balanced wait"],
              ["Ira", "Checked in", "Review eligible"],
              ["Kabir", "Offer sent", "Expires 18:00"],
              ["Naina", "Refunded", "Cancelled"],
            ].map(([name, status, note]) => (
              <div key={name}>
                <strong>{name}</strong>
                <span>{status}</span>
                <small>{note}</small>
              </div>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-payments" aria-labelledby="host-preview-payments-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-payments-title">Ticketing, refunds, and check-in stay connected.</h2>
            <p>
              Catch keeps checkout, payment state, cancellation, refund status,
              and attendance on the same roster, so hosts are not reconciling
              guests across separate tools.
            </p>
          </div>
          <div className="host-preview-payment-flow" data-reveal>
            {hostPreviewPaymentStates.map((state) => (
              <span key={state}>{state}</span>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-live" id="live" aria-labelledby="host-preview-live-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-live-title">Run the event from the host screen.</h2>
            <p>
              Check guests in, follow prompts, manage rotations, make overrides,
              and keep safety controls close while the event is happening.
            </p>
          </div>
          <div className="host-preview-live__grid">
            <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
            <div className="host-preview-live__modules" data-reveal>
              {["Check-in", "Welcome script", "Prompt", "Rotation", "Override", "Safety"].map((module) => (
                <span key={module}>{module}</span>
              ))}
            </div>
          </div>
        </section>

        <section className="host-preview-section host-preview-after" aria-labelledby="host-preview-after-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-after-title">Follow-up starts after attendance.</h2>
            <p>
              Guests can privately catch people they actually met. Mutual catches
              become chats with shared event context. Hosts see aggregate signals,
              not private interest.
            </p>
          </div>
          <div className="capture-grid capture-grid--host">
            <CaptureCard id="post-run-catch-window" fallbackStep="Catch window" captures={captures} />
            <CaptureCard id="match-chat-context" fallbackStep="Match chat" captures={captures} />
            <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
          </div>
        </section>

        <section className="host-preview-section host-preview-trust" aria-labelledby="host-preview-trust-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-trust-title">Guardrails are part of the product.</h2>
            <p>
              The page should answer operational concerns before a host reaches
              the application form.
            </p>
          </div>
          <div className="host-preview-trust__grid">
            {hostPreviewTrustItems.map((item) => (
              <article data-reveal key={item.title}>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-faq" aria-labelledby="host-preview-faq-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-faq-title">Questions hosts ask before switching tools.</h2>
          </div>
          <div className="host-preview-faq__list">
            {hostPreviewFaqs.map((item) => (
              <details key={item.question} data-reveal>
                <summary>{item.question}</summary>
                <p>{item.answer}</p>
              </details>
            ))}
          </div>
        </section>

        <section
          className="waitlist-section host-preview-apply"
          id="founding-hosts"
          aria-labelledby="host-preview-apply-title"
        >
          <div className="waitlist__intro" data-reveal>
            <h2 id="host-preview-apply-title">Apply once. Publish when approved.</h2>
            <p>
              Approved founding hosts get the public badge, increased discovery
              visibility, and the 24-month platform-fee lock when their first
              Catch event goes live.
            </p>
          </div>
          <HostApplicationFlow />
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Host-led social events with admission, payments, live facilitation, matching, and insight."
        links={[
          {href: "/host/", label: "Current host page"},
          {href: "#offer", label: "Founding offer"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}
