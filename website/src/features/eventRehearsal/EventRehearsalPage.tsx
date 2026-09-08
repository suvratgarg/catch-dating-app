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
import {availableEventRehearsalGuestActions, canReplyToRehearsal,
  type RehearsalReply, type RehearsalReplyState} from "./eventRehearsalModel";
import {useEventRehearsalController} from "./useEventRehearsalController";

export function EventRehearsalPage() {
  const {publicRehearsalId = ""} = useParams<{
    publicRehearsalId: string;
  }>();
  return <EventRehearsalGuest key={publicRehearsalId}
    publicRehearsalId={publicRehearsalId} />;
}

function EventRehearsalGuest({publicRehearsalId}: {publicRehearsalId: string}) {
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
      onReply={controller.reply}
      onRefresh={controller.refresh}
      replyState={controller.replyState}
      pending={controller.pending}
      status={controller.status}
    />
  );
}

export function EventRehearsalPreview({
  bootstrap,
  onAction,
  onReply,
  onRefresh,
  replyState = {fresh: true, pendingChoice: null, retryChoice: null, notice: ""},
  pending,
  status,
}: {
  bootstrap: EventRehearsalGuestBootstrap;
  onAction: (action: EventRehearsalGuestAction) => void;
  onReply: (reply: RehearsalReply) => void;
  onRefresh: () => void;
  replyState?: RehearsalReplyState;
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

        {bootstrap.actor.assistanceMessage ? (
          <EventRehearsalJoiningInstruction bootstrap={bootstrap}
            pending={pending} state={replyState} onReply={onReply}
            onRefresh={onRefresh} />
        ) : null}

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
                  disabled={pending || !replyState.fresh || replyState.retryChoice !== null}
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
            {!replyState.fresh && !bootstrap.actor.assistanceMessage ? (
              <Button type="button" variant="ghost" disabled={pending} onClick={onRefresh}>
                {eventRehearsalCopy.refresh}
              </Button>
            ) : null}
          </EventRuntimeModule>
        )}

        <EventRuntimeNoticeStack>
          {(bootstrap.actor.connectionState ??
            (bootstrap.actor.status === "disconnected" ? "disconnected" : "connected")) === "disconnected"
            ? <p>{eventRehearsalCopy.disconnectedNotice}</p>
            : null}
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

function EventRehearsalJoiningInstruction({bootstrap, pending, state, onReply, onRefresh}: {
  bootstrap: EventRehearsalGuestBootstrap;
  pending: boolean;
  state: RehearsalReplyState;
  onReply: (reply: RehearsalReply) => void;
  onRefresh: () => void;
}) {
  const message = bootstrap.actor.assistanceMessage!;
  const saved = message.choices.find((choice) => choice.choiceId === message.responseChoiceId);
  const canRespond = canReplyToRehearsal(bootstrap);
  return (
    <EventRuntimeModule title={eventRehearsalCopy.joiningTitle} accent="coral">
      <p>{message.text}</p>
      {saved ? <p role="status">{eventRehearsalCopy.replySaved(saved.label)}</p> :
        canRespond ? <>
          <p>{eventRehearsalCopy.joiningBody}</p>
          <EventRuntimeActionGrid>
            {message.choices.map((choice) => (
              <Button key={choice.choiceId} type="button" variant="ghost"
                disabled={pending || !state.fresh ||
                  (state.retryChoice !== null && state.retryChoice !== choice.choiceId)}
                loading={state.pendingChoice === choice.choiceId}
                loadingLabel={eventRehearsalCopy.replyPending}
                onClick={() => onReply({messageId: message.messageId,
                  intentRevision: message.intentRevision, choiceId: choice.choiceId})}>
                {choice.label}
              </Button>
            ))}
          </EventRuntimeActionGrid>
        </> : <p role="status">{eventRehearsalCopy.replyClosed}</p>}
      {!state.fresh ? <p role="status">{eventRehearsalCopy.replyStale}</p> : null}
      {state.notice ? <FormStatus status={{message: state.notice, tone: "is-error"}} /> : null}
      {!state.fresh || state.notice || (!canRespond && !saved) ? (
        <Button type="button" variant="ghost" disabled={pending} onClick={onRefresh}>
          {eventRehearsalCopy.refresh}
        </Button>
      ) : null}
    </EventRuntimeModule>
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
