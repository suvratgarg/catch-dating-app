import {useEffect, useState} from "react";
import {useParams} from "react-router";
import {eventInviteCopy as copy} from "../../content/eventInvite";
import {
  type EventInviteLanding,
  resolveEventInviteLanding,
} from "../../firebase";
import {eventInviteSessionId} from "../../shared/eventInviteAttribution";
import {
  ButtonLink,
  EventRuntimeFrame,
  EventRuntimeLoading,
  EventRuntimePanel,
  FormStatus,
} from "../../shared/ui/primitives";
import {PublicEventRegistration} from "./PublicEventRegistration";

export function EventInvitePage({
  initialLanding = null,
}: {
  initialLanding?: EventInviteLanding | null;
} = {}) {
  const {inviteToken = ""} = useParams<{inviteToken: string}>();
  const [landing, setLanding] = useState<EventInviteLanding | null>(initialLanding);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    if (initialLanding) return;
    let active = true;
    setLanding(null);
    setFailed(false);
    void resolveEventInviteLanding({
      inviteToken,
      sessionId: eventInviteSessionId(),
    }).then((value) => {
      if (active) setLanding(value);
    }).catch(() => {
      if (active) setFailed(true);
    });
    return () => {
      active = false;
    };
  }, [initialLanding, inviteToken]);

  if (!landing && !failed) {
    return (
      <EventRuntimeFrame brandLabel={copy.brand} brandWord={copy.brandWord}>
        <EventRuntimeLoading label={copy.loading} />
      </EventRuntimeFrame>
    );
  }
  if (!landing) {
    return (
      <EventRuntimeFrame brandLabel={copy.brand} brandWord={copy.brandWord}>
        <EventRuntimePanel
          body={copy.unavailableBody}
          kicker={copy.brand}
          title={copy.unavailableTitle}
        >
          <FormStatus status={{message: copy.unavailableBody, tone: "is-error"}} />
          <ButtonLink href="/help" variant="ghost">{copy.helpAction}</ButtonLink>
        </EventRuntimePanel>
      </EventRuntimeFrame>
    );
  }

  return (
    <EventRuntimeFrame
      brandLabel={copy.brand}
      brandWord={copy.brandWord}
      eventTitle={landing.title}
    >
      <EventRuntimePanel
        body={landingBody(landing)}
        kicker={copy.kicker}
        title={copy.title}
      >
        <p><strong>{landing.title}</strong></p>
        <p>{formatSchedule(landing.startTimeMillis)} · {landing.locationName}</p>
        {landing.destinationKind === "catchEvent" ? (
          <PublicEventRegistration
            eventId={landing.eventId}
            inviteToken={inviteToken}
          />
        ) : landing.destinationUrl ? (
          <ButtonLink href={landing.destinationUrl} variant="primary">
            {landingAction(landing)}
          </ButtonLink>
        ) : null}
      </EventRuntimePanel>
    </EventRuntimeFrame>
  );
}

function landingBody(landing: EventInviteLanding): string {
  if (landing.destinationKind === "externalBooking") {
    return copy.externalBody(landing.sourceLabel);
  }
  if (landing.destinationKind === "eventRuntime") return copy.runtimeBody;
  return copy.catchBody;
}

function landingAction(landing: EventInviteLanding): string {
  if (landing.destinationKind === "externalBooking") {
    return copy.externalAction(landing.sourceLabel);
  }
  if (landing.destinationKind === "eventRuntime") return copy.runtimeAction;
  return copy.catchAction;
}

function formatSchedule(startTimeMillis: number): string {
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(startTimeMillis));
}
