import {useParams} from "react-router";
import {eventRehearsalCopy} from "../../content/eventRehearsal";
import type {
  EventRehearsalGuestAction,
  EventRehearsalGuestBootstrap,
} from "../../firebase";
import {
  Button,
  EventRuntimeActionGrid,
  EventRuntimeAssignments,
  EventRuntimeFrame,
  EventRuntimeKicker,
  EventRuntimeLive,
  EventRuntimeLiveHeader,
  EventRuntimeLoading,
  EventRuntimeModule,
  EventRuntimeNoticeStack,
  EventRuntimePanel,
  EventRuntimePracticeBanner,
  EventRuntimeRouteMap,
  FormStatus,
} from "../../shared/ui/primitives";
import {availableEventRehearsalGuestActions} from "./eventRehearsalModel";
import {useEventRehearsalController} from "./useEventRehearsalController";

export function EventRehearsalPage() {
  const {publicRehearsalId = ""} = useParams<{
    publicRehearsalId: string;
  }>();
  const controller = useEventRehearsalController(publicRehearsalId);

  if (controller.isLoading) {
    return (
      <EventRuntimeFrame
        brandLabel={eventRehearsalCopy.brand}
        brandWord={eventRehearsalCopy.brandWord}
      >
        <EventRuntimePanel
          kicker={eventRehearsalCopy.loadingTitle}
          title={eventRehearsalCopy.loadingTitle}
          body={eventRehearsalCopy.practiceBanner}
        >
          <EventRuntimeLoading label={eventRehearsalCopy.loading} />
        </EventRuntimePanel>
      </EventRuntimeFrame>
    );
  }

  if (controller.isUnavailable || !controller.bootstrap) {
    return (
      <EventRuntimeFrame
        brandLabel={eventRehearsalCopy.brand}
        brandWord={eventRehearsalCopy.brandWord}
      >
        <EventRuntimePanel
          kicker={eventRehearsalCopy.unavailableKicker}
          title={eventRehearsalCopy.unavailableTitle}
          body={eventRehearsalCopy.unavailableBody}
        >
          <Button onClick={() => void controller.refresh()} type="button">
            {eventRehearsalCopy.retry}
          </Button>
        </EventRuntimePanel>
      </EventRuntimeFrame>
    );
  }

  return (
    <EventRehearsalPreview
      bootstrap={controller.bootstrap}
      onAction={controller.submit}
      pending={controller.pending}
      status={controller.status}
    />
  );
}

export function EventRehearsalPreview({
  bootstrap,
  onAction,
  pending,
  status,
}: {
  bootstrap: EventRehearsalGuestBootstrap;
  onAction: (action: EventRehearsalGuestAction) => void;
  pending: boolean;
  status: {message: string; tone: "" | "is-error"};
}) {
  const moment = bootstrap.actor.guestMoment;
  const complete = bootstrap.session.status === "complete" ||
    bootstrap.session.status === "expired";
  const actions = availableEventRehearsalGuestActions(bootstrap);
  const faultNotice = bootstrap.session.faultId === "none"
    ? null
    : eventRehearsalCopy.faultNotices[bootstrap.session.faultId];
  const clock = new Intl.DateTimeFormat(undefined, {
    hour: "numeric",
    minute: "2-digit",
  }).format(bootstrap.session.virtualNowMillis);

  return (
    <EventRuntimeFrame
      brandLabel={eventRehearsalCopy.brand}
      brandWord={eventRehearsalCopy.brandWord}
      eventTitle={bootstrap.session.title}
    >
      <EventRuntimePracticeBanner>
        {bootstrap.practiceBanner}
      </EventRuntimePracticeBanner>
      <EventRuntimeLive
        reducedMotion={bootstrap.session.faultId === "reducedMotion"}
      >
        <EventRuntimeLiveHeader
          badge={`${bootstrap.actor.displayName} · ${
            eventRehearsalCopy.statusLabels[bootstrap.actor.status]
          }`}
        >
          <EventRuntimeKicker>
            {complete
              ? eventRehearsalCopy.completeKicker
              : eventRehearsalCopy.liveKicker}
          </EventRuntimeKicker>
          <h1>{bootstrap.session.title}</h1>
          <p>
            {bootstrap.session.locationName}
            {eventRehearsalCopy.locationSeparator}
            {eventRehearsalCopy.virtualTimePrefix} {clock}
          </p>
        </EventRuntimeLiveHeader>

        <EventRuntimeModule title={eventRehearsalCopy.momentTitles[moment]}>
          <p>{eventRehearsalCopy.momentBodies[moment]}</p>
        </EventRuntimeModule>

        <EventRuntimeModule title={eventRehearsalCopy.promptTitle} accent="coral">
          <p>{bootstrap.session.attendeePrompt}</p>
        </EventRuntimeModule>

        {bootstrap.session.movementSimulation ? (
          <EventRehearsalMovementPreview
            movement={bootstrap.session.movementSimulation}
          />
        ) : null}

        {complete ? (
          <EventRuntimeModule title={eventRehearsalCopy.completeTitle}>
            <p>{eventRehearsalCopy.completeBody}</p>
          </EventRuntimeModule>
        ) : actions.length === 0 ? (
          <EventRuntimeModule title={eventRehearsalCopy.waitingTitle}>
            <p>{eventRehearsalCopy.waitingBody}</p>
          </EventRuntimeModule>
        ) : (
          <EventRuntimeModule title={eventRehearsalCopy.actionsTitle}>
            <p>{eventRehearsalCopy.actionsBody}</p>
            <EventRuntimeActionGrid>
              {actions.map((action) => (
                <Button
                  disabled={pending}
                  key={action}
                  loading={pending}
                  loadingLabel={eventRehearsalCopy.actionPending}
                  onClick={() => onAction(action)}
                  type="button"
                  variant={action === "optOut" ? "ghost" : "primary"}
                >
                  {eventRehearsalActionLabel(action)}
                </Button>
              ))}
            </EventRuntimeActionGrid>
            <FormStatus status={status} />
          </EventRuntimeModule>
        )}

        <EventRuntimeNoticeStack>
          {faultNotice ? <p>{faultNotice}</p> : null}
          {bootstrap.actor.optedOut
            ? <p>{eventRehearsalCopy.optedOutNotice}</p>
            : null}
          {bootstrap.actor.helpRequested
            ? <p>{eventRehearsalCopy.helpRequestedNotice}</p>
            : null}
          {bootstrap.actor.promptCompleted
            ? <p>{eventRehearsalCopy.promptCompletedNotice}</p>
            : null}
        </EventRuntimeNoticeStack>
      </EventRuntimeLive>
    </EventRuntimeFrame>
  );
}

function EventRehearsalMovementPreview({
  movement,
}: {
  movement: NonNullable<EventRehearsalGuestBootstrap["session"]["movementSimulation"]>;
}) {
  const routePath = movement.routePlan?.path ?? [];
  const position = [...movement.livePositions].sort((left, right) =>
    right.recordedOffsetMinutes - left.recordedOffsetMinutes
  )[0] ?? null;
  return (
    <>
      {movement.itinerary.length ? (
        <EventRuntimeModule title={eventRehearsalCopy.runOfShowTitle}>
          <EventRuntimeAssignments>
            {movement.itinerary.map((item) => (
              <article key={item.id}>
                <span>{eventRehearsalCopy.itineraryOffset(
                  item.offsetMinutes
                )}</span>
                <h3>{item.title}</h3>
                {item.description ? <p>{item.description}</p> : null}
                {item.location?.name ? <small>{item.location.name}</small> : null}
              </article>
            ))}
          </EventRuntimeAssignments>
        </EventRuntimeModule>
      ) : null}
      {movement.routePlan || position || movement.lateArrivalGuidance ? (
        <EventRuntimeModule title={eventRehearsalCopy.routeTitle} accent="coral">
          {routePath.length ? (
            <p>{eventRehearsalCopy.routePoints(routePath.length)}</p>
          ) : null}
          {position ? (
            <p>{eventRehearsalCopy.trackerRole(position.role)}</p>
          ) : null}
          <EventRuntimeRouteMap
            ariaLabel={eventRehearsalCopy.routeMapLabel}
            help={eventRehearsalCopy.routeMapHelp}
            marker={position}
            path={routePath}
          />
          {movement.lateArrivalGuidance ? (
            <p>{movement.lateArrivalGuidance}</p>
          ) : null}
        </EventRuntimeModule>
      ) : null}
    </>
  );
}

function eventRehearsalActionLabel(action: EventRehearsalGuestAction): string {
  switch (action) {
    case "checkIn":
      return eventRehearsalCopy.checkedIn;
    case "confirmArrival":
      return eventRehearsalCopy.confirmArrival;
    case "optOut":
      return eventRehearsalCopy.optOut;
    case "optIn":
      return eventRehearsalCopy.optIn;
    case "askForHelp":
      return eventRehearsalCopy.askForHelp;
    case "completePrompt":
      return eventRehearsalCopy.completePrompt;
  }
}
