import {CatchField} from "@catch/web-ui";
import {optionalAccountFields} from "../../shared/contracts/generated/profileRequirements";
import {accountCopy} from "../../content/account";
import {Button, EventRegistrationForm, EventRegistrationPrivacy, FormStatus} from "../../shared/ui/primitives";
import type {WebsiteAccountController} from "./useWebsiteAccountController";

/** Inline account step shared by follow and event actions. */
export function renderAccountForm(account: WebsiteAccountController) {
  if (account.loading) return <p role="status">{accountCopy.loading}</p>;
  if (account.ageIneligible) return <p role="status">{accountCopy.ageIneligible}</p>;
  return <EventRegistrationForm onSubmit={account.handleSubmit}>
    <CatchField
      recipe="input"
      id={`${account.id}-name`}
      autoComplete="name"
      title={accountCopy.name}
      maxLength={80}
      value={account.displayName}
      onChanged={(value) => account.setDisplayName(value)}
      inputMode={account.pending || account.stage === "code" ? "inactive" : "editable"}
    />
    <CatchField
      recipe="input"
      id={`${account.id}-phone`}
      autoComplete="tel"
      title={accountCopy.phone}
      value={account.phoneNumber}
      onChanged={(value) => account.setPhoneNumber(value)}
      inputMode={account.verified || account.pending || account.stage === "code" ? "inactive" : "editable"}
      keyboardType="phone"
    />
    {!account.account?.dateOfBirth && (account.ageRequired || optionalAccountFields.includes("dateOfBirth")) ? <CatchField
      recipe="input"
      id={`${account.id}-birth`}
      title={account.ageRequired ? accountCopy.requiredBirth : accountCopy.optionalBirth}
      value={account.dateOfBirth}
      onChanged={(value) => account.setDateOfBirth(value)}
      inputMode={account.pending || account.stage === "code" ? "inactive" : "editable"}
      keyboardType="date"
    /> : null}
    {account.stage === "code" ? <CatchField
      recipe="input"
      id={`${account.id}-code`}
      autoComplete="one-time-code"
      title={accountCopy.code}
      maxLength={6}
      value={account.code}
      onChanged={(value) => account.setCode(value.replace(/\D/gu, ""))}
      inputMode={account.pending ? "inactive" : "editable"}
      keyboardType="number"
    /> : null}
    <div id={account.recaptchaId} />
    <Button type="submit" disabled={account.pending} loading={account.pending} loadingLabel={accountCopy.continuing}>
      {account.stage === "code" ? accountCopy.verify : account.verified ? accountCopy.continue : accountCopy.sendCode}
    </Button>
    {account.stage === "code" ? <Button type="button" variant="ghost" disabled={account.pending} onClick={account.restartVerification}>{accountCopy.restartVerification}</Button> : null}
    <FormStatus status={account.status} />
    <EventRegistrationPrivacy>{accountCopy.privacy}</EventRegistrationPrivacy>
  </EventRegistrationForm>;
}
