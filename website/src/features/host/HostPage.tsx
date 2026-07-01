import {
  ProductModuleGrid,
} from "../../components/site";
import {SectionHeader, SiteFooter, SiteHeader} from "../../shared/site";
import {ButtonLink} from "../../shared/ui/primitives";
import {
  hostEvidenceMetrics,
  hostFillRoomModules,
  hostLoop,
  hostModules,
  hostProofRows,
  hostSurfaceCards,
} from "../marketing/content";
import {LoopList} from "../marketing/LoopList";
import {trackCtaClick} from "../marketing/tracking";
import {HostApplicationFlow} from "./application/HostApplicationFlow";
import {
  CaptureCard,
  type HostCaptureMap,
} from "./sections/CaptureFrames";
import {CreateEventWalkthrough} from "./sections/CreateEventWalkthrough";
import {EventSuccessShowcase} from "./sections/EventSuccessShowcase";
import {HostComparisonSection} from "./sections/HostComparisonSection";

export function HostPage({captures}: {captures: HostCaptureMap}) {
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
