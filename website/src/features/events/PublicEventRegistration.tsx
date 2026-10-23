import {CatchField} from "@catch/web-ui";
import {useWebsiteAccountController} from "../account/useWebsiteAccountController";
import {renderAccountForm} from "../account/accountForm";
import {useFreeEventRegistrationController} from "./useFreeEventRegistrationController";
import {PublicPaidEventRegistration} from "./PublicPaidEventRegistration";
import {EventWhatsappPreferencesPanel} from "../eventMessaging/EventWhatsappPreferencesPanel";
import {EventRcsPreferencesPanel} from "../eventMessaging/EventRcsPreferencesPanel";
import {EventSmsPreferencePanel} from "../eventMessaging/EventSmsPreferencePanel";
import {eventDetailCopy} from "../../content/events";

import {
  Button,
  ButtonLink,
  EventRegistrationConsent,
  EventRegistrationConsents,
  EventRegistrationForm,
  EventRegistrationPrivacy,
  FormStatus,
} from "../../shared/ui/primitives";
import {eventInviteTokenFromLocation} from "../../shared/eventInviteAttribution";

export function PublicEventRegistration({eventId, inviteToken, mode = "free", allowNewBookings = true}: {eventId: string; inviteToken?: string | null; mode?: "free" | "paid"; allowNewBookings?: boolean}) {
  if (!allowNewBookings && mode === "paid") return <PublicPaidEventRegistration key={eventId} eventId={eventId} allowNewBookings={false} inviteToken={inviteToken ?? null} />;
  return <AccountEventRegistration key={eventId} eventId={eventId} inviteToken={inviteToken} mode={mode} />;
}
function AccountEventRegistration({eventId, inviteToken, mode}: {eventId: string; inviteToken?: string | null; mode: "free" | "paid"}) {
  const account = useWebsiteAccountController({eventId});
  if (!account.ready) return renderAccountForm(account);
  return mode === "paid" ? <PublicPaidEventRegistration key={account.uid} eventId={eventId} initialDisplayName={account.account?.displayName} inviteToken={inviteToken ?? eventInviteTokenFromLocation()} /> :
    <FreeEventRegistration key={account.uid} eventId={eventId} initialDisplayName={account.account?.displayName} inviteToken={inviteToken} />;
}

function FreeEventRegistration({
  eventId,
  inviteToken: inviteTokenOverride,
  initialDisplayName,
}: {
  eventId: string;
  inviteToken?: string | null;
  initialDisplayName?: string;
}) {
  const {reactId, recaptchaContainerId, displayName, setDisplayName,
    phoneNumber, setPhoneNumber, code, setCode, whatsappUpdates, setWhatsappUpdates,
    smsUpdates, setSmsUpdates, stage, registeredScope, pending, status,
    verified, handleSubmit} = useFreeEventRegistrationController(eventId, inviteTokenOverride, initialDisplayName);
  const copy = eventDetailCopy.hero.webRegistration;

  return (
    <EventRegistrationForm onSubmit={handleSubmit}>
      <CatchField
        recipe="input"
        autoComplete="name"
        inputMode={pending || stage !== "details" ? "inactive" : "editable"}
        id={`${reactId}-event-registration-name`}
        title={copy.nameLabel}
        maxLength={120}
        onChanged={(value) => setDisplayName(value)}
        inputHint={copy.namePlaceholder}
        value={displayName}
      />
      <CatchField
        recipe="input"
        autoComplete="tel"
        inputMode={verified || pending || stage !== "details" ? "inactive" : "editable"}
        id={`${reactId}-event-registration-phone`}
        title={copy.phoneLabel}
        onChanged={(value) => setPhoneNumber(value)}
        inputHint={copy.phonePlaceholder}
        value={phoneNumber}
        keyboardType="phone"
      />
      <EventRegistrationConsents>
        <EventRegistrationConsent
          checked={whatsappUpdates}
          disabled={pending || stage !== "details"}
          onChange={(event) => setWhatsappUpdates(event.target.checked)}
        >
          {copy.whatsappConsent}
        </EventRegistrationConsent>
        <EventRegistrationConsent
          checked={smsUpdates}
          disabled={pending || stage !== "details"}
          onChange={(event) => setSmsUpdates(event.target.checked)}
        >
          {copy.smsConsent}
        </EventRegistrationConsent>
        <EventRegistrationPrivacy>{copy.consentDetail}</EventRegistrationPrivacy>
      </EventRegistrationConsents>
      {stage === "code" ? (
        <CatchField
          recipe="input"
          autoComplete="one-time-code"
          inputMode={pending ? "inactive" : "editable"}
          id={`${reactId}-event-registration-code`}
          title={copy.codeLabel}
          maxLength={6}
          onChanged={(value) => setCode(value.replace(/\D/gu, ""))}
          inputHint={copy.codePlaceholder}
          value={code}
          keyboardType="number"
        />
      ) : null}
      <div id={recaptchaContainerId} />
      {stage !== "success" ? (
        <Button
          disabled={pending}
          loading={pending}
          loadingLabel={stage === "details" ?
            copy.sendingCodeAction : copy.registeringAction}
          type="submit"
        >
          {stage === "details" ? verified ? copy.registerAction : copy.sendCodeAction : copy.confirmAction}
        </Button>
      ) : null}
      <FormStatus status={status} />
      {stage === "success" && registeredScope?.eventId === eventId ?
        <>
          <ButtonLink href={`/booking/${encodeURIComponent(eventId)}/`}>{eventDetailCopy.hero.guestAction}</ButtonLink>
          <EventSmsPreferencePanel {...registeredScope} />
          <EventRcsPreferencesPanel {...registeredScope} />
          <EventWhatsappPreferencesPanel {...registeredScope} />
        </> : null}
      <EventRegistrationPrivacy>{copy.privacy}</EventRegistrationPrivacy>
    </EventRegistrationForm>
  );
}
