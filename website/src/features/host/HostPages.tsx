import {useEffect, useRef, useState} from "react";
import type {CaptureRecord} from "../../app/usePageLifecycle";
import {
  CaptureCard as CanonicalCaptureCard,
  ProductModuleGrid,
  SectionHeader,
  SiteFooter,
  SiteHeader,
} from "../../components/site";
import {ButtonLink, NumberedRail, TextActionButton} from "../../shared/ui/primitives";
import {AppDownloadCtas} from "../marketing/AppDownloadCtas";
import {
  eventSuccessModules,
  eventSuccessStages,
  hostComparisonColumns,
  hostComparisonRows,
  hostCreateSteps,
  hostEvidenceMetrics,
  hostFillRoomModules,
  hostLoop,
  hostModules,
  hostPreviewFaqs,
  hostPreviewFormats,
  hostPreviewLoop,
  hostPreviewPaymentStates,
  hostPreviewRosterStates,
  hostPreviewTrustItems,
  hostProofRows,
  hostSurfaceCards,
} from "../marketing/content";
import {LoopList} from "../marketing/LoopList";
import {trackCtaClick} from "../marketing/tracking";
import {HostApplicationFlow} from "./HostApplicationFlow";

export function HostPreviewPage({captures}: {captures: Record<string, CaptureRecord>}) {
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

export function HostPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#workflow", label: "Workflow"},
          {href: "#fill-room", label: "Fill room"},
          {href: "#live", label: "Live mode"},
          {href: "#screens", label: "Screens"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
        <section className="host-hero">
          <div className="host-hero__inner">
            <div className="host-hero__copy">
              <h1 data-reveal>Run singles events people actually follow through on.</h1>
              <p data-reveal>
                Catch handles the loop around your event: booking logic,
                admission, waitlists, live facilitation, check-in, private
                catches, and the post-event report that shows what actually
                happened.
              </p>
              <div className="hero__actions" data-reveal>
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
              </div>
            </div>

            <div className="host-console" aria-label="Host console" data-reveal>
              <div className="host-console__top">
                <span>Host console</span>
                <strong>West Village mixer</strong>
              </div>
              <div className="host-console__grid">
                <div>
                  <span className="ui-label">Admission</span>
                  <strong>Requests + invite links</strong>
                </div>
                <div>
                  <span className="ui-label">Live moment</span>
                  <strong>Balanced rotations</strong>
                </div>
                <div>
                  <span className="ui-label">After event</span>
                  <strong>18 mutual matches</strong>
                </div>
              </div>
              <div className="host-console__timeline">
                {hostEvidenceMetrics.map((metric) => (
                  <span key={metric.label}>
                    <strong>{metric.value}</strong>
                    {metric.label}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section
          className="host-evidence"
          aria-labelledby="host-evidence-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">What a host can see</span>
            <h2 id="host-evidence-title">
              Catch shows the path from interest to attendance to follow-up.
            </h2>
            <p>
              Catch answers more than "who RSVP'd?" It shows where demand came
              from, where people dropped off, and whether the event created real
              connection afterward.
            </p>
          </div>
          <div className="evidence-strip" data-reveal>
            {hostEvidenceMetrics.map((metric) => (
              <div key={metric.label}>
                <strong>{metric.value}</strong>
                <span>{metric.label}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="story-section" id="workflow" aria-labelledby="workflow-title">
          <div className="section-heading" data-reveal>
            <h2 id="workflow-title">One loop, from booking to connection.</h2>
            <p>
              Replace forms, payment links, spreadsheets, group chats, manual
              intros, and safety notes with one flow built around the event.
            </p>
          </div>
          <LoopList items={hostLoop} modifier="loop-list--host" />
        </section>

        <CreateEventWalkthrough captures={captures} />

        <section
          className="surface-section"
          aria-labelledby="surface-title"
        >
          <div className="section-heading section-heading--wide" data-reveal>
            <span className="ui-label">What Catch handles</span>
            <h2 id="surface-title">
              The platform is not just ticketing, and it is not just matching.
            </h2>
          </div>
          <div className="surface-grid">
            {hostSurfaceCards.map((item) => (
              <article data-reveal key={item.label}>
                <span>{item.label}</span>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="host-fill-room" id="fill-room" aria-labelledby="fill-room-title">
          <SectionHeader
            eyebrow="Fill the room"
            id="fill-room-title"
            title="Checkout, waitlist, and cohort controls belong in the same roster."
            body="The mockup split these into concrete host promises. In production they should stay connected to the event record instead of becoming separate ticketing, spreadsheet, or DM workflows."
            wide
          />
          <ProductModuleGrid modules={hostFillRoomModules} />
        </section>

        <section className="proof-section proof-section--host" id="live">
          <div className="proof-section__copy" data-reveal>
            <span className="ui-label">Event Success</span>
            <h2>Live facilitation is built into the event flow.</h2>
            <p>
              The live catalog is explicit: booking balance preview, attendance
              and roster, welcome scripts, prompts, assignments, rotations,
              private catches, feedback, and aggregate host reports.
            </p>
          </div>

          <div className="module-stack" data-reveal>
            {hostModules.map((item) => (
              <article key={item.label}>
                <span>{item.label}</span>
                <strong>{item.title}</strong>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <EventSuccessShowcase captures={captures} />

        <section
          className="proof-ledger"
          aria-labelledby="proof-ledger-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host confidence</span>
            <h2 id="proof-ledger-title">Run the whole event loop from one place.</h2>
            <p>
              Catch gives hosts the controls to shape demand, guide the live
              experience, and understand what happened after people met.
            </p>
          </div>
          <div className="proof-ledger__rows">
            {hostProofRows.map((item) => (
              <article data-reveal key={item.label}>
                <strong>{item.label}</strong>
                <p>{item.proof}</p>
              </article>
            ))}
          </div>
        </section>

        <HostComparisonSection />

        <section className="captures-section" id="screens" aria-labelledby="screens-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host tools</span>
            <h2 id="screens-title">See the host workflow end to end.</h2>
            <p>
              Set up the event, manage the live moment, and review the signals
              that help the next event get better.
            </p>
          </div>

          <div className="capture-grid capture-grid--host">
            <CaptureCard id="host-event-setup" fallbackStep="Setup" captures={captures} />
            <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
            <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
          </div>
        </section>

        <section
          className="waitlist-section"
          id="founding-hosts"
          aria-labelledby="host-apply-title"
        >
          <div className="waitlist__intro" data-reveal>
            <h2 id="host-apply-title">
              Bring the format. Catch handles the loop around it.
            </h2>
            <p>
              Apply as a founding host if you run events, communities, venues, or
              formats where the right singles can meet with more context.
            </p>
          </div>
          <HostApplicationFlow />
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Host-led singles events with booking, facilitation, matching, and insight."
        links={[
          {href: "/", label: "Member site"},
          {href: "#workflow", label: "Workflow"},
          {href: "#live", label: "Live mode"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}

function CreateEventWalkthrough({captures}: {captures: Record<string, CaptureRecord>}) {
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

function EventSuccessShowcase({captures}: {captures: Record<string, CaptureRecord>}) {
  const [stage, setStage] = useState("activity");
  const modules = eventSuccessModules.filter((module) => module.stage === stage);
  const captureId = stage === "after"
    ? "post-run-catch-window"
    : stage === "debrief"
      ? "host-post-event-report"
      : "host-live-console";

  return (
    <section className="event-success-showcase" aria-labelledby="event-success-showcase-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-showcase-title">Optional modules, one live guide.</h2>
        <p>
          Social runs can stay lightweight. Mixers and dinners can carry full
          facilitation. Every module below maps to the live product catalog and
          keeps private catch targets out of host reporting.
        </p>
      </div>
      <NumberedRail
        activeId={stage}
        bodyVisibility="always"
        className="event-success-stage-rail"
        items={eventSuccessStages.map((item) => ({
          id: item.id,
          label: item.label,
          body: item.sub,
        }))}
        label="Event Success stages"
        onSelect={setStage}
        reveal
      />
      <div className="event-success-showcase__grid">
        <div className="event-success-module-grid" data-reveal>
          {modules.map((module) => (
            <article key={module.title}>
              <span className="ui-label">{module.stage}</span>
              <h3>{module.title}</h3>
              <p><strong>For attendees:</strong> {module.attendee}</p>
              <p><strong>For hosts:</strong> {module.host}</p>
            </article>
          ))}
        </div>
        <CaptureCard id={captureId} fallbackStep="Event Success" captures={captures} />
      </div>
      <div className="privacy-guardrail" data-reveal>
        <strong>Guardrails are part of the product.</strong>
        Hosts see aggregate coaching, never who caught whom. Attendees can opt
        out of live modules, and blocked pairs are never assigned together.
      </div>
    </section>
  );
}

function HostComparisonSection() {
  const [open, setOpen] = useState(false);
  const comparisonTableRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }
    const frameId = window.requestAnimationFrame(() => {
      comparisonTableRef.current?.scrollIntoView({behavior: "smooth", block: "start"});
    });
    return () => window.cancelAnimationFrame(frameId);
  }, [open]);

  return (
    <section className="host-comparison" aria-labelledby="host-comparison-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">The honest comparison</span>
        <h2 id="host-comparison-title">Announcing an event is solved. Running one is not.</h2>
      </div>
      <div className="host-comparison__split">
        <article data-reveal>
          <span className="ui-label">Luma · Eventbrite · District · BookMyShow · Instagram · WhatsApp · Forms</span>
          <h3>They help you publish, sell, or get discovered.</h3>
          <p>
            Useful reach, event pages, and payments. Then social hosts still
            assemble admissions, ratios, door proof, follow-up, and reputation
            signals across scattered tools.
          </p>
        </article>
        <article data-reveal>
          <span className="ui-label">Catch</span>
          <h3>Catch fills it, runs it, and proves it.</h3>
          <p>
            Admission rules, waitlists, check-in, live console, attendance proof,
            post-event matching, verified reviews, and host reports stay in one loop.
          </p>
        </article>
      </div>
      <TextActionButton
        aria-expanded={open}
        aria-controls="host-comparison-table"
        onClick={() => setOpen((current) => !current)}
      >
        {open ? "Hide full comparison" : "See full comparison"}
      </TextActionButton>
      {open ? (
        <>
          <div
            className="comparison-table-heading"
            id="host-comparison-table"
            ref={comparisonTableRef}
            data-reveal
            tabIndex={-1}
          >
            <span className="ui-label">Full table</span>
            <p>
              District and BookMyShow are strong Indian discovery and ticketing
              surfaces. Catch is positioned around the host operating loop after the
              listing goes live.
            </p>
          </div>
          <div className="comparison-table-wrap" data-reveal>
            <table className="comparison-table" aria-label="Host platform comparison">
              <thead>
                <tr>
                  <th>Capability</th>
                  {hostComparisonColumns.map((column) => (
                    <th key={column}>{column}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {hostComparisonRows.map((row) => (
                  <tr key={row[0]}>
                    <td>{row[0]}</td>
                    {row.slice(1).map((value, index) => (
                      <td key={`${row[0]}-${index}`} data-value={value}>
                        {value === "yes" ? "Yes" : value === "partial" ? "Partial" : "No"}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      ) : null}
    </section>
  );
}

function CaptureCard({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: Record<string, CaptureRecord>;
}) {
  return <CanonicalCaptureCard id={id} fallbackStep={fallbackStep} captures={captures} />;
}

function PhoneCaptureFrame({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: Record<string, CaptureRecord>;
}) {
  const capture = captures[id];
  const imagePath = capture?.webPath ?? `/assets/app-screenshots/placeholders/${id}.svg`;

  return (
    <figure className="phone-capture" data-capture-slot={id}>
      <div className="phone-capture__device">
        <span className="phone-capture__notch" aria-hidden="true" />
        <div className="phone-capture__screen">
          <img
            src={imagePath}
            alt={capture?.alt ?? `${fallbackStep} app screenshot`}
            loading="lazy"
          />
        </div>
      </div>
      <figcaption>{capture?.caption ?? `${fallbackStep} in the Catch app`}</figcaption>
    </figure>
  );
}
