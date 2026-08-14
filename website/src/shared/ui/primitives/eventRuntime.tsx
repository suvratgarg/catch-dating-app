import {LottieAnimationControl} from "@catch/web-ui";
import type {CSSProperties, FormHTMLAttributes, ReactNode} from "react";
import {CheckboxField, Form} from "./forms";
import {PlainLink} from "./actions";
import {classNames} from "./foundation";

export function EventRuntimeFrame({
  brandLabel,
  brandWord,
  children,
  eventTitle,
}: {
  brandLabel: string;
  brandWord: string;
  children: ReactNode;
  eventTitle?: string | null;
}) {
  return (
    <div className="event-runtime">
      <header className="event-runtime__brand">
        <PlainLink aria-label={brandLabel} href="/">{brandWord}<span>●</span></PlainLink>
        {eventTitle ? <span>{eventTitle}</span> : null}
      </header>
      {children}
    </div>
  );
}

export function EventRuntimeLoading({label}: {label: ReactNode}) {
  return (
    <div className="event-runtime__loading" role="status">
      <span className="event-runtime__pulse" />
      <p>{label}</p>
    </div>
  );
}

export function EventRuntimePanel({
  body,
  children,
  kicker,
  title,
}: {
  body: ReactNode;
  children: ReactNode;
  kicker: ReactNode;
  title: ReactNode;
}) {
  return (
    <main className="event-runtime__panel">
      <div className="event-runtime__intro">
        <EventRuntimeKicker>{kicker}</EventRuntimeKicker>
        <h1>{title}</h1>
        <p>{body}</p>
      </div>
      {children}
    </main>
  );
}

export function EventRuntimeForm(
  props: FormHTMLAttributes<HTMLFormElement> & {pending?: boolean}
) {
  return <Form {...props} className="event-runtime__form" />;
}

export function EventRuntimeProfileQuestions({children}: {children: ReactNode}) {
  return <div className="event-runtime__profile-questions">{children}</div>;
}

export function EventRuntimeFieldset({children}: {children: ReactNode}) {
  return <fieldset className="event-runtime__fieldset">{children}</fieldset>;
}

export function EventRuntimeConsent({
  children,
  required = false,
  ...props
}: Parameters<typeof CheckboxField>[0] & {required?: boolean}) {
  return (
    <CheckboxField
      {...props}
      className={classNames(
        "event-runtime__consent",
        required && "event-runtime__consent--required"
      )}
    >
      {children}
    </CheckboxField>
  );
}

export function EventRuntimeLive({
  activityId,
  background,
  children,
}: {
  activityId?: string | null;
  background?: ReactNode;
  children: ReactNode;
}) {
  return (
    <main className="event-runtime__live" data-activity={activityId ?? undefined}>
      {background}
      <div className="event-runtime__live-content">{children}</div>
    </main>
  );
}

export function EventRuntimeLiveHeader({
  badge,
  children,
}: {
  badge: ReactNode;
  children: ReactNode;
}) {
  return (
    <header className="event-runtime__live-header">
      <div>{children}</div>
      <span className="event-runtime__checked-in">{badge}</span>
    </header>
  );
}

export function EventRuntimeKicker({children}: {children: ReactNode}) {
  return <p className="event-runtime__kicker">{children}</p>;
}

export interface EventRuntimeMarqueeParticleVisual {
  angleTurns: number;
  burstTurns: number;
  distance: number;
  driftTurns: number;
  sizeScale: number;
}

export function EventRuntimeStageMarquee({
  participantCount,
  particles,
  phase,
  phaseProgress,
  seedAngleTurns,
  stageSource,
  sunriseSource,
  tickProgress,
}: {
  participantCount: number;
  particles: readonly EventRuntimeMarqueeParticleVisual[];
  phase: "idle" | "anticipation" | "climax" | "settle";
  phaseProgress: number;
  seedAngleTurns: number;
  stageSource: string;
  sunriseSource: string;
  tickProgress: number;
}) {
  const reducedMotion = typeof window !== "undefined" &&
    window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
  const frameStyle = {
    "--marquee-phase-progress": `${phaseProgress}`,
    "--marquee-seed-angle": `${seedAngleTurns}turn`,
    "--marquee-tick-progress": `${tickProgress}`,
  } as CSSProperties;
  return (
    <div className="event-runtime__marquee" aria-hidden="true">
      <LottieAnimationControl
        className="event-runtime__stage-motion"
        reducedMotion={reducedMotion}
        source={stageSource}
      />
      {phase !== "idle" ? (
        <div
          className="event-runtime__reveal-cinematic"
          data-phase={phase}
          style={frameStyle}
        >
          <LottieAnimationControl
            autoplay={phase === "anticipation"}
            className="event-runtime__reveal-motion"
            loop={phase === "anticipation"}
            progress={phase === "anticipation" ? null : phaseProgress}
            reducedMotion={reducedMotion}
            source={phase === "anticipation" ? stageSource : sunriseSource}
          />
          <div className="event-runtime__reveal-spokes">
            {Array.from({length: 14}, (_, index) => (
              <span key={index} style={{"--marquee-index": index} as CSSProperties} />
            ))}
          </div>
          <div className="event-runtime__reveal-presence">
            {Array.from(
              {length: Math.min(Math.max(0, participantCount), 28)},
              (_, index) => (
                <span key={index} style={{"--marquee-index": index} as CSSProperties} />
              )
            )}
          </div>
          <div className="event-runtime__reveal-particles">
            {particles.map((particle, index) => (
              <span
                key={index}
                style={{
                  "--marquee-angle": `${particle.angleTurns}turn`,
                  "--marquee-burst-angle": `${particle.burstTurns}turn`,
                  "--marquee-distance": `${particle.distance}`,
                  "--marquee-drift": `${particle.driftTurns}turn`,
                  "--marquee-size": `${particle.sizeScale}`,
                } as CSSProperties}
              />
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

export function EventRuntimeArrivalRing({
  ariaLabel,
  count,
  label,
  source,
}: {
  ariaLabel: string;
  count: number;
  label: string;
  source: string;
}) {
  const reducedMotion = typeof window !== "undefined" &&
    window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
  return (
    <span className="event-runtime__arrival-ring" aria-label={ariaLabel}>
      <LottieAnimationControl
        className="event-runtime__arrival-ring-motion"
        reducedMotion={reducedMotion}
        source={source}
      />
      <strong>{count}</strong>
      <small>{label}</small>
    </span>
  );
}

export function EventRuntimeModule({
  accent,
  children,
  title,
}: {
  accent?: "coral";
  children: ReactNode;
  title: ReactNode;
}) {
  return (
    <section className={classNames(
      "event-runtime__module",
      accent === "coral" && "event-runtime__module--coral"
    )}>
      <h2>{title}</h2>
      {children}
    </section>
  );
}

export function EventRuntimeAssignments({children}: {children: ReactNode}) {
  return <div className="event-runtime__assignments">{children}</div>;
}

export interface EventRuntimeRoomMapUnit {
  id: string;
  label: string;
  shape: "round" | "rect" | "row" | "court" | "zone";
}

export interface EventRuntimeRoomMapPosition {
  id: string;
  left: number;
  top: number;
  width: number;
  height: number;
}

export function EventRuntimeRoomMap({
  assignedLabel,
  assignedUnitId,
  confirmedLabel,
  confirmedUnitId,
  positions,
  selfLabel,
  subtitle,
  title,
  units,
}: {
  assignedLabel: string;
  assignedUnitId: string;
  confirmedLabel: string;
  confirmedUnitId?: string | null;
  positions: readonly EventRuntimeRoomMapPosition[];
  selfLabel: string;
  subtitle: string;
  title: string;
  units: readonly EventRuntimeRoomMapUnit[];
}) {
  const unitById = new Map(units.map((unit) => [unit.id, unit]));
  return (
    <section className="event-runtime__room-map" aria-label={title}>
      <header>
        <div>
          <h4>{title}</h4>
          <p>{subtitle}</p>
        </div>
        <div className="event-runtime__room-map-legend">
          <span className="is-assigned">{assignedLabel}</span>
          <span className="is-confirmed">{confirmedLabel}</span>
        </div>
      </header>
      <div className="event-runtime__room-map-canvas">
        {positions.map((position) => {
          const unit = unitById.get(position.id);
          if (!unit) return null;
          const assigned = assignedUnitId === unit.id;
          const confirmed = confirmedUnitId === unit.id;
          return (
            <div
              className={classNames(
                "event-runtime__room-map-unit",
                `event-runtime__room-map-unit--${unit.shape}`,
                assigned && "is-assigned",
                confirmed && "is-confirmed"
              )}
              key={unit.id}
              style={{
                height: `${position.height * 100}%`,
                left: `${position.left * 100}%`,
                top: `${position.top * 100}%`,
                width: `${position.width * 100}%`,
              }}
            >
              <span>{unit.label}</span>
              {assigned ? (
                <strong aria-label={confirmed ? confirmedLabel : assignedLabel}>
                  {selfLabel}
                </strong>
              ) : null}
            </div>
          );
        })}
      </div>
    </section>
  );
}

export function EventRuntimeMission({children}: {children: ReactNode}) {
  return <div className="event-runtime__mission">{children}</div>;
}

export function EventRuntimeQuestionnaire({children}: {children: ReactNode}) {
  return <div className="event-runtime__questionnaire">{children}</div>;
}

export function EventRuntimePrivacy({children}: {children: ReactNode}) {
  return <aside className="event-runtime__privacy">{children}</aside>;
}
