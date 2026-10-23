import {CatchGap} from "@catch/web-ui";
import type {ReactNode} from "react";
import {EventMessageWithdrawalPanel} from "../eventMessaging/EventMessageWithdrawalPanel";
import {eventAssistanceCopy as copy} from "../../content/eventAssistance";
import {
  Button, EventRuntimeFrame, EventRuntimeLoading,
  EventRuntimeModule, EventRuntimeNoticeStack, EventRuntimePanel, FormStatus,
} from "../../shared/ui/primitives";
import type {AssistanceScreen, Credential} from "./eventAssistanceModel";
import {useEventAssistanceController} from "./useEventAssistanceController";

export function EventAssistancePage({credential}: {credential: Credential | null}) {
  const controller = useEventAssistanceController(credential);
  return <EventAssistanceView {...controller}
    textPreferences={<>
      <EventMessageWithdrawalPanel credential={credential} channel="sms" />
      <EventMessageWithdrawalPanel credential={credential} channel="whatsapp" />
      <EventMessageWithdrawalPanel credential={credential} channel="rcs" />
    </>} />;
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
          <CatchGap size="section">
            <EventRuntimeLoading label={copy.loading} />
            {textPreferences}
          </CatchGap>
        </EventRuntimePanel>
      ) : screen.kind === "unavailable" ? (
        <EventRuntimePanel kicker={copy.kicker}
          title={screen.reason === "network" ? copy.networkTitle : copy.unavailableTitle}
          body={screen.reason === "network" ? copy.networkBody :
            screen.reason === "invalid" ? copy.unavailableBody : copy.closed[screen.reason]}>
          <CatchGap size="section">
            {textPreferences}
            <Button type="button" onClick={refresh} loading={refreshing}
              loadingLabel={copy.refreshing}>{copy.refresh}</Button>
          </CatchGap>
        </EventRuntimePanel>
      ) : (
        <EventRuntimePanel kicker={copy.kicker} title={screen.view.title}
          body={screen.view.text}>
          <CatchGap size="section">
            {screen.view.response ? (
              <EventRuntimeModule title={copy.saved}>
                <p role="status">{screen.view.response.label}</p>
              </EventRuntimeModule>
            ) : (
              <EventRuntimeModule title={copy.replyHeading}>
                <CatchGap direction="horizontal" size="related" wrap>
                  {screen.view.choices.map((choice) => (
                    <Button key={choice.choiceId} type="button" variant="ghost"
                      disabled={!screen.fresh || screen.pending ||
                        (screen.retryChoice !== null && screen.retryChoice !== choice.choiceId)}
                      loading={screen.pendingChoice === choice.choiceId}
                      loadingLabel={copy.sending} onClick={() => submit(choice.choiceId)}>
                      {choice.label}
                    </Button>
                  ))}
                </CatchGap>
              </EventRuntimeModule>
            )}
            {textPreferences}
            <CatchGap direction="horizontal" size="related" wrap>
              {!screen.fresh || screen.notice ? (
                <EventRuntimeNoticeStack>
                  {!screen.fresh ? <p role="status">{screen.view.response ? copy.refreshRecorded : copy.stale}</p> : null}
                  {screen.notice ? <FormStatus status={{message: screen.notice, tone: ""}} /> : null}
                </EventRuntimeNoticeStack>
              ) : null}
              <Button type="button" variant="ghost" onClick={refresh}
                disabled={screen.pending} loading={refreshing}
                loadingLabel={copy.refreshing}>{copy.refresh}</Button>
            </CatchGap>
          </CatchGap>
        </EventRuntimePanel>
      )}
    </EventRuntimeFrame>
  );
}
