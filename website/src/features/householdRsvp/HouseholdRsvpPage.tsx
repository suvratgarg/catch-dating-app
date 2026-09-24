import {useMemo} from "react";
import {
  Button,
  ButtonLink,
  ChoiceChip,
  ChoiceChipGrid,
  EventRuntimeActionGrid,
  EventRuntimeConsent,
  EventRuntimeFrame,
  EventRuntimeLoading,
  EventRuntimeModule,
  EventRuntimeNoticeStack,
  EventRuntimePanel,
  EventRuntimeSectionStack,
  Field,
  FormStatus,
  TextField,
} from "../../shared/ui/primitives";
import {programHouseholdItineraryIcsUrl} from "../../firebase";
import {householdRsvpCopy as copy} from "../../content/householdRsvp";
import {
  draftFor,
  type Credential,
  type HouseholdRsvpScreen,
  type MemberFunctionView,
  type MemberView,
  type ResponseDraft,
  type RsvpStatus,
} from "./householdRsvpModel";
import {useHouseholdRsvpController} from "./useHouseholdRsvpController";

export function HouseholdRsvpPage({credential}: {credential: Credential | null}) {
  const controller = useHouseholdRsvpController(credential);
  return <HouseholdRsvpView credential={credential} {...controller} />;
}

const STATUS_CHOICES: {status: RsvpStatus; label: string}[] = [
  {status: "attending", label: copy.attending},
  {status: "maybe", label: copy.maybe},
  {status: "declined", label: copy.declined},
];

function formatFunctionWindow(
  fn: MemberFunctionView,
  timezone: string,
): string {
  const date = new Intl.DateTimeFormat("en-IN", {
    timeZone: timezone, weekday: "short", day: "numeric", month: "short",
  }).format(new Date(fn.startsAtMillis));
  const time = new Intl.DateTimeFormat("en-IN", {
    timeZone: timezone, hour: "numeric", minute: "2-digit",
  }).format(new Date(fn.startsAtMillis));
  return `${date} · ${time}`;
}

function MemberFunctionCard({
  member,
  fn,
  timezone,
  draft,
  pending,
  onChange,
}: {
  member: MemberView;
  fn: MemberFunctionView;
  timezone: string;
  draft: ResponseDraft | undefined;
  pending: boolean;
  onChange: (patch: Partial<ResponseDraft>) => void;
}) {
  const status = draft?.rsvpStatus ?? fn.rsvpStatus;
  const partySize = draft?.partySize ?? fn.partySize ?? null;
  const responseNote = draft?.responseNote ?? fn.responseNote ?? "";
  const attending = status === "attending" || status === "maybe";
  const inputId = `${member.guestId}-${fn.functionId}`;
  return (
    <EventRuntimeModule title={fn.name}>
      <p>{formatFunctionWindow(fn, timezone)}</p>
      {fn.venueName ? <p>{fn.venueName}</p> : null}
      {fn.dressCode ? <p>{copy.dressCodeLabel} {fn.dressCode}</p> : null}
      {fn.instructions ? <p>{fn.instructions}</p> : null}
      <Field label={<span id={`${inputId}-label`}>{member.displayName}</span>}>
        <ChoiceChipGrid aria-labelledby={`${inputId}-label`}>
          {STATUS_CHOICES.map((choice) => (
            <ChoiceChip key={choice.status}
              selected={status === choice.status}
              disabled={pending}
              onClick={() => onChange({rsvpStatus: choice.status})}>
              {choice.label}
            </ChoiceChip>
          ))}
        </ChoiceChipGrid>
      </Field>
      {attending ? (
        <TextField
          id={`${inputId}-party`}
          label={copy.partySize}
          type="number" min={1} max={50} inputMode="numeric"
          placeholder={copy.partySizePlaceholder}
          disabled={pending}
          value={partySize === null ? "" : String(partySize)}
          onChange={(event) => {
            const value = event.target.value;
            onChange({
              partySize: value === "" ? null :
                Math.max(1, Math.min(50, Number.parseInt(value, 10) || 1)),
            });
          }}
        />
      ) : null}
      <TextField
        id={`${inputId}-note`}
        label={copy.note}
        placeholder={copy.notePlaceholder}
        disabled={pending}
        value={responseNote}
        onChange={(event) =>
          onChange({responseNote: event.target.value || null})}
      />
    </EventRuntimeModule>
  );
}

export function HouseholdRsvpView({
  credential,
  screen,
  setResponse,
  setConsent,
  submit,
  refresh,
  refreshing,
}: {
  credential: Credential | null;
  screen: HouseholdRsvpScreen;
  setResponse: (guestId: string, functionId: string,
    patch: Partial<ResponseDraft>) => void;
  setConsent: (value: boolean) => void;
  submit: () => void;
  refresh: () => void;
  refreshing: boolean;
}) {
  const icsUrl = useMemo(
    () => credential ? programHouseholdItineraryIcsUrl(credential.token) : null,
    [credential],
  );
  return (
    <EventRuntimeFrame brandLabel={copy.brand} brandWord={copy.brandWord}
      eventTitle={screen.kind === "ready" ? screen.view.programTitle : null}>
      {screen.kind === "loading" ? (
        <EventRuntimePanel kicker={copy.kicker} title={copy.loadingTitle} body="">
          <EventRuntimeSectionStack>
            <EventRuntimeLoading label={copy.loading} />
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      ) : screen.kind === "unavailable" ? (
        <EventRuntimePanel kicker={copy.kicker}
          title={screen.reason === "network" ?
            copy.networkTitle : copy.unavailableTitle}
          body={screen.reason === "network" ?
            copy.networkBody : copy.unavailableBody}>
          <EventRuntimeSectionStack>
            <Button type="button" onClick={refresh} loading={refreshing}
              loadingLabel={copy.refreshing}>{copy.refresh}</Button>
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      ) : (
        <EventRuntimePanel kicker={copy.kicker}
          title={screen.view.householdLabel} body="">
          <EventRuntimeSectionStack>
            {screen.view.members.map((member) =>
              member.functions.length === 0 ? null : (
                <div key={member.guestId}>
                  {member.functions.map((fn) => (
                    <MemberFunctionCard
                      key={fn.functionId}
                      member={member}
                      fn={fn}
                      timezone={screen.view.timezone}
                      draft={draftFor(screen.drafts,
                        member.guestId, fn.functionId)}
                      pending={screen.pending}
                      onChange={(patch) =>
                        setResponse(member.guestId, fn.functionId, patch)}
                    />
                  ))}
                </div>
              ))}
            <EventRuntimeConsent
              checked={screen.messagingConsent}
              disabled={screen.pending}
              onChange={(event) => setConsent(event.target.checked)}>
              {copy.consentLabel}
            </EventRuntimeConsent>
            <EventRuntimeActionGrid>
              <Button type="button" onClick={submit}
                disabled={!screen.dirty || screen.pending}
                loading={screen.pending} loadingLabel={copy.sending}>
                {copy.submit}
              </Button>
              {icsUrl ? (
                <ButtonLink href={icsUrl} variant="ghost">
                  {copy.itinerary}
                </ButtonLink>
              ) : null}
              <Button type="button" variant="ghost" onClick={refresh}
                disabled={screen.pending} loading={refreshing}
                loadingLabel={copy.refreshing}>{copy.refresh}</Button>
            </EventRuntimeActionGrid>
            {screen.notice ? (
              <EventRuntimeNoticeStack>
                <FormStatus status={{message: screen.notice, tone: ""}} />
              </EventRuntimeNoticeStack>
            ) : null}
          </EventRuntimeSectionStack>
        </EventRuntimePanel>
      )}
    </EventRuntimeFrame>
  );
}
