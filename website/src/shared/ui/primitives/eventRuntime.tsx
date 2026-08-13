import type {FormHTMLAttributes, ReactNode} from "react";
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

export function EventRuntimeLive({children}: {children: ReactNode}) {
  return <main className="event-runtime__live">{children}</main>;
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
