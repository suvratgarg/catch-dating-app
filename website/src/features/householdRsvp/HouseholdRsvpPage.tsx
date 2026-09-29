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
  SelectField,
  TextField,
} from "../../shared/ui/primitives";
import {programHouseholdItineraryIcsUrl} from "../../firebase";
import {householdRsvpCopy as copy} from "../../content/householdRsvp";
import {
  draftFor,
  travelDraftFor,
  travelDraftIncomplete,
  type Credential,
  type HouseholdRsvpScreen,
  type MemberFunctionView,
  type MemberView,
  type ResponseDraft,
  type RsvpStatus,
  type TravelDraft,
  type TravelKind,
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

const OTHER_DESTINATION = "__other";

function toLocalInput(millis: number | null | undefined): string {
  if (millis == null) return "";
  const date = new Date(millis);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-` +
    `${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function TravelBlockCard({
  member,
  kind,
  hotels,
  draft,
  pending,
  onChange,
}: {
  member: MemberView;
  kind: TravelKind;
  hotels: {hotelId: string; name: string}[];
  draft: TravelDraft | undefined;
  pending: boolean;
  onChange: (patch: Partial<TravelDraft>) => void;
}) {
  const title = kind === "outbound" ? copy.travelDeparture : copy.travelArrival;
  const inputId = `${member.guestId}-${kind}`;
  const destination = draft?.destinationHotelId ??
    (draft?.destinationLabel ? OTHER_DESTINATION : "");
  return (
    <EventRuntimeModule
      title={copy.travelBlockTitle(member.displayName, title)}>
      <TextField
        id={`${inputId}-flight`}
        label={copy.travelFlight}
        placeholder={copy.travelFlightPlaceholder}
        disabled={pending}
        value={draft?.flightNumber ?? ""}
        onChange={(event) =>
          onChange({flightNumber: event.target.value || null})}
      />
      <TextField
        id={`${inputId}-from`}
        label={copy.travelFrom}
        placeholder={copy.travelFromPlaceholder}
        maxLength={3}
        disabled={pending}
        value={draft?.originIata ?? ""}
        onChange={(event) =>
          onChange({originIata: event.target.value.toUpperCase() || null})}
      />
      <TextField
        id={`${inputId}-to`}
        label={copy.travelTo}
        placeholder={copy.travelToPlaceholder}
        maxLength={3}
        disabled={pending}
        value={draft?.destinationIata ?? ""}
        onChange={(event) =>
          onChange({destinationIata: event.target.value.toUpperCase() || null})}
      />
      <TextField
        id={`${inputId}-when`}
        label={kind === "outbound" ? copy.travelWhenDeparture :
          copy.travelWhen}
        type="datetime-local"
        disabled={pending}
        value={toLocalInput(draft?.scheduledArrivalAtMillis)}
        onChange={(event) => {
          const value = event.target.value;
          onChange({scheduledArrivalAtMillis:
            value === "" ? null : new Date(value).getTime()});
        }}
      />
      <SelectField
        id={`${inputId}-hotel`}
        label={copy.travelHotel}
        disabled={pending}
        value={destination}
        onChange={(event) => {
          const value = event.target.value;
          onChange({
            destinationHotelId: value === "" || value === OTHER_DESTINATION ?
              null : value,
            destinationLabel: value === OTHER_DESTINATION ?
              draft?.destinationLabel ?? null : null,
          });
        }}>
        <option value="">{copy.travelHotelChoose}</option>
        {hotels.map((hotel) => (
          <option key={hotel.hotelId} value={hotel.hotelId}>
            {hotel.name}
          </option>
        ))}
        <option value={OTHER_DESTINATION}>{copy.travelHotelOther}</option>
      </SelectField>
      {destination === OTHER_DESTINATION ? (
        <TextField
          id={`${inputId}-destination`}
          label={copy.travelDestinationLabel}
          placeholder={copy.travelDestinationPlaceholder}
          disabled={pending}
          value={draft?.destinationLabel ?? ""}
          onChange={(event) =>
            onChange({destinationLabel: event.target.value || null})}
        />
      ) : null}
      <TextField
        id={`${inputId}-passengers`}
        label={copy.travelPassengers}
        type="number" min={1} max={200} inputMode="numeric"
        disabled={pending}
        value={draft?.passengers == null ? "" : String(draft.passengers)}
        onChange={(event) => {
          const value = event.target.value;
          onChange({passengers: value === "" ? null :
            Math.max(1, Math.min(200, Number.parseInt(value, 10) || 1))});
        }}
      />
      <TextField
        id={`${inputId}-luggage`}
        label={copy.travelLuggage}
        type="number" min={0} max={500} inputMode="numeric"
        disabled={pending}
        value={draft?.luggageUnits == null ? "" : String(draft.luggageUnits)}
        onChange={(event) => {
          const value = event.target.value;
          onChange({luggageUnits: value === "" ? null :
            Math.max(0, Math.min(500, Number.parseInt(value, 10) || 0))});
        }}
      />
      {draft && travelDraftIncomplete(draft) ? (
        <p>{copy.travelIncomplete}</p>
      ) : null}
    </EventRuntimeModule>
  );
}

export function HouseholdRsvpView({
  credential,
  screen,
  setResponse,
  setConsent,
  setTravel,
  submit,
  refresh,
  refreshing,
}: {
  credential: Credential | null;
  screen: HouseholdRsvpScreen;
  setResponse: (guestId: string, functionId: string,
    patch: Partial<ResponseDraft>) => void;
  setConsent: (value: boolean) => void;
  setTravel: (guestId: string, kind: TravelKind,
    patch: Partial<TravelDraft>) => void;
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
                  {(["inbound", "outbound"] as const).map((kind) => (
                    <TravelBlockCard
                      key={kind}
                      member={member}
                      kind={kind}
                      hotels={screen.view.hotels}
                      draft={travelDraftFor(
                        screen.travelDrafts, member.guestId, kind)}
                      pending={screen.pending}
                      onChange={(patch) =>
                        setTravel(member.guestId, kind, patch)}
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
