import {type FormEvent, useEffect, useId, useRef, useState} from "react";
import {eventDetailCopy} from "../../content/events";
import {
  beginPublicEventPhoneVerification,
  registerPublicEvent,
  type PublicEventPhoneVerification,
} from "../../firebase";
import {
  Button,
  EventRegistrationConsent,
  EventRegistrationConsents,
  EventRegistrationForm,
  EventRegistrationPrivacy,
  FormStatus,
  TextField,
} from "../../shared/ui/primitives";
import type {FormStatus as FormStatusModel} from "../../shared/forms/types";
import {eventInviteTokenFromLocation} from "../../shared/eventInviteAttribution";

export function PublicEventRegistration({
  eventId,
  inviteToken: inviteTokenOverride,
}: {
  eventId: string;
  inviteToken?: string | null;
}) {
  const reactId = useId();
  const recaptchaContainerId = `event-registration-recaptcha-${reactId.replace(/:/gu, "")}`;
  const verificationRef = useRef<PublicEventPhoneVerification | null>(null);
  const [displayName, setDisplayName] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [code, setCode] = useState("");
  const [whatsappUpdates, setWhatsappUpdates] = useState(false);
  const [smsUpdates, setSmsUpdates] = useState(false);
  const [stage, setStage] = useState<"details" | "code" | "success">("details");
  const [pending, setPending] = useState(false);
  const [status, setStatus] = useState<FormStatusModel>({message: "", tone: ""});
  const copy = eventDetailCopy.hero.webRegistration;
  const inviteToken = inviteTokenOverride ?? eventInviteTokenFromLocation();

  useEffect(() => () => verificationRef.current?.clear(), []);
  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (pending || stage === "success") return;
    const name = displayName.trim();
    const phone = phoneNumber.replace(/[\s()-]/gu, "");
    if (name.length < 1) {
      setStatus({message: copy.missingName, tone: "is-error"});
      return;
    }
    if (!/^\+[1-9][0-9]{7,14}$/u.test(phone)) {
      setStatus({message: copy.invalidPhone, tone: "is-error"});
      return;
    }
    if (stage === "code" && !/^[0-9]{6}$/u.test(code.trim())) {
      setStatus({message: copy.invalidCode, tone: "is-error"});
      return;
    }

    setPending(true);
    setStatus({message: "", tone: ""});
    try {
      if (stage === "details") {
        verificationRef.current?.clear();
        verificationRef.current = await beginPublicEventPhoneVerification(
          phone,
          recaptchaContainerId
        );
        setStage("code");
        setStatus({message: copy.codeSent, tone: "is-success"});
        return;
      }
      const verification = verificationRef.current;
      if (!verification) {
        setStage("details");
        throw new Error(copy.verificationExpired);
      }
      await verification.confirm(code.trim());
      const response = await registerPublicEvent({
        eventId,
        displayName: name,
        organizerUpdates: {
          whatsapp: whatsappUpdates,
          sms: smsUpdates,
          termsVersion: "organizer-updates-v1",
        },
        inviteToken,
      });
      verificationRef.current?.clear();
      verificationRef.current = null;
      setStage("success");
      setStatus({
        message: response.status === "alreadyRegistered" ?
          copy.alreadyRegistered : response.status === "waitlisted" ?
            copy.waitlisted : copy.success,
        tone: "is-success",
      });
    } catch (error) {
      if (["auth/code-expired", "auth/session-expired"].includes(errorCode(error))) {
        verificationRef.current?.clear();
        verificationRef.current = null;
        setStage("details");
      }
      setStatus({message: registrationError(error), tone: "is-error"});
    } finally {
      setPending(false);
    }
  }

  return (
    <EventRegistrationForm onSubmit={handleSubmit}>
      <TextField
        autoComplete="name"
        disabled={pending || stage !== "details"}
        id={`${reactId}-event-registration-name`}
        label={copy.nameLabel}
        maxLength={120}
        onChange={(event) => setDisplayName(event.target.value)}
        placeholder={copy.namePlaceholder}
        value={displayName}
      />
      <TextField
        autoComplete="tel"
        disabled={pending || stage !== "details"}
        id={`${reactId}-event-registration-phone`}
        inputMode="tel"
        label={copy.phoneLabel}
        onChange={(event) => setPhoneNumber(event.target.value)}
        placeholder={copy.phonePlaceholder}
        value={phoneNumber}
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
        <TextField
          autoComplete="one-time-code"
          disabled={pending}
          id={`${reactId}-event-registration-code`}
          inputMode="numeric"
          label={copy.codeLabel}
          maxLength={6}
          onChange={(event) => setCode(event.target.value.replace(/\D/gu, ""))}
          placeholder={copy.codePlaceholder}
          value={code}
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
          {stage === "details" ? copy.sendCodeAction : copy.confirmAction}
        </Button>
      ) : null}
      <FormStatus status={status} />
      <EventRegistrationPrivacy>{copy.privacy}</EventRegistrationPrivacy>
    </EventRegistrationForm>
  );
}

function registrationError(error: unknown): string {
  const copy = eventDetailCopy.hero.webRegistration;
  switch (errorCode(error)) {
    case "auth/invalid-verification-code":
      return copy.invalidCode;
    case "auth/code-expired":
    case "auth/session-expired":
      return copy.verificationExpired;
    case "auth/too-many-requests":
    case "auth/quota-exceeded":
    case "functions/resource-exhausted":
      return copy.tooManyRequests;
    case "functions/failed-precondition":
    case "functions/not-found":
      return copy.eventUnavailable;
    default:
      return copy.genericError;
  }
}

function errorCode(error: unknown): string {
  if (typeof error !== "object" || error === null || !("code" in error)) return "";
  return typeof error.code === "string" ? error.code : "";
}
