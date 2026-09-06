import type {ReactNode} from "react";
import {EventSmsWithdrawalPanel} from "../eventMessaging/EventSmsWithdrawalPanel";
import {eventAssistanceCopy as copy} from "../../content/eventAssistance";
import {
  Button, EventRuntimeActionGrid, EventRuntimeFrame, EventRuntimeLoading,
  EventRuntimeModule, EventRuntimeNoticeStack, EventRuntimeSectionStack, EventRuntimePanel, FormStatus,
} from "../../shared/ui/primitives";
import type {AssistanceScreen, Credential} from "./eventAssistanceModel";
import {useEventAssistanceController} from "./useEventAssistanceController";

export function EventAssistancePage({credential}: {credential: Credential | null}) {
  const controller = useEventAssistanceController(credential);
  return <EventAssistanceView {...controller}
    textPreferences={<EventSmsWithdrawalPanel credential={credential} />} />;
}

export function EventAssistanceView({screen, submit, refresh, refreshing, textPreferences}: {
  textPreferences?: ReactNode;
  screen: AssistanceScreen;
  submit: (choiceId: string) => void;
  refresh: () => void;
  refreshing: boolean;
}) {
  return (
    <EventRuntimeFrame brandLabel={copy.brand} brandWord={copy.brandWord}
      eventTitle={screen.kind === "ready" ? screen.view.eventTitle : null}>
      {screen.kind === "loading" ? (
        <EventRuntimePanel kicker={copy.kicker} title={copy.loadingTitle} body="">
          <EventRuntimeSectionStack>
            <EventRuntimeLoading label={copy.loading} />
            {textPreferences}
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      ) : screen.kind === "unavailable" ? (
        <EventRuntimePanel kicker={copy.kicker}
          title={screen.reason === "network" ? copy.networkTitle : copy.unavailableTitle}
          body={screen.reason === "network" ? copy.networkBody :
            screen.reason === "invalid" ? copy.unavailableBody : copy.closed[screen.reason]}>
          <EventRuntimeSectionStack>
            {textPreferences}
            <Button type="button" onClick={refresh} loading={refreshing}
              loadingLabel={copy.refreshing}>{copy.refresh}</Button>
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      ) : (
        <EventRuntimePanel kicker={copy.kicker} title={screen.view.title}
          body={screen.view.text}>
          <EventRuntimeSectionStack>
            {screen.view.response ? (
              <EventRuntimeModule title={copy.saved}>
                <p role="status">{screen.view.response.label}</p>
              </EventRuntimeModule>
            ) : (
              <EventRuntimeModule title={copy.replyHeading}>
                <EventRuntimeActionGrid>
                  {screen.view.choices.map((choice) => (
                    <Button key={choice.choiceId} type="button" variant="ghost"
                      disabled={!screen.fresh || screen.pending ||
                        (screen.retryChoice !== null && screen.retryChoice !== choice.choiceId)}
                      loading={screen.pendingChoice === choice.choiceId}
                      loadingLabel={copy.sending} onClick={() => submit(choice.choiceId)}>
                      {choice.label}
                    </Button>
                  ))}
                </EventRuntimeActionGrid>
              </EventRuntimeModule>
            )}
            {textPreferences}
            <EventRuntimeActionGrid>
              {!screen.fresh || screen.notice ? (
                <EventRuntimeNoticeStack>
                  {!screen.fresh ? <p role="status">{screen.view.response ? copy.refreshRecorded : copy.stale}</p> : null}
                  {screen.notice ? <FormStatus status={{message: screen.notice, tone: ""}} /> : null}
                </EventRuntimeNoticeStack>
              ) : null}
              <Button type="button" variant="ghost" onClick={refresh}
                disabled={screen.pending} loading={refreshing}
                loadingLabel={copy.refreshing}>{copy.refresh}</Button>
            </EventRuntimeActionGrid>
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      )}
    </EventRuntimeFrame>
  );
}
