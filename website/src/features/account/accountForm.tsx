import {optionalAccountFields} from "../../shared/contracts/generated/profileRequirements";
import {accountCopy} from "../../content/account";
import {Button, EventRegistrationForm, EventRegistrationPrivacy, FormStatus, TextField} from "../../shared/ui/primitives";
import type {WebsiteAccountController} from "./useWebsiteAccountController";

/** Inline account step shared by follow and event actions. */
export function renderAccountForm(account: WebsiteAccountController) {
  if (account.loading) return <p role="status">{accountCopy.loading}</p>;
  if (account.ageIneligible) return <p role="status">{accountCopy.ageIneligible}</p>;
  return <EventRegistrationForm onSubmit={account.handleSubmit}>
    <TextField id={`${account.id}-name`} autoComplete="name" label={accountCopy.name} maxLength={80}
      value={account.displayName} onChange={(e) => account.setDisplayName(e.target.value)} disabled={account.pending || account.stage === "code"} />
    <TextField id={`${account.id}-phone`} autoComplete="tel" inputMode="tel" label={accountCopy.phone}
      value={account.phoneNumber} onChange={(e) => account.setPhoneNumber(e.target.value)} disabled={account.verified || account.pending || account.stage === "code"} />
    {!account.account?.dateOfBirth && (account.ageRequired || optionalAccountFields.includes("dateOfBirth")) ? <TextField id={`${account.id}-birth`} type="date"
      label={account.ageRequired ? accountCopy.requiredBirth : accountCopy.optionalBirth}
      value={account.dateOfBirth} onChange={(e) => account.setDateOfBirth(e.target.value)} disabled={account.pending || account.stage === "code"} /> : null}
    {account.stage === "code" ? <TextField id={`${account.id}-code`} autoComplete="one-time-code" inputMode="numeric"
      label={accountCopy.code} maxLength={6} value={account.code} onChange={(e) => account.setCode(e.target.value.replace(/\D/gu, ""))} disabled={account.pending} /> : null}
    <div id={account.recaptchaId} />
    <Button type="submit" disabled={account.pending} loading={account.pending} loadingLabel={accountCopy.continuing}>
      {account.stage === "code" ? accountCopy.verify : account.verified ? accountCopy.continue : accountCopy.sendCode}
    </Button>
    {account.stage === "code" ? <Button type="button" variant="ghost" disabled={account.pending} onClick={account.restartVerification}>{accountCopy.restartVerification}</Button> : null}
    <FormStatus status={account.status} />
    <EventRegistrationPrivacy>{accountCopy.privacy}</EventRegistrationPrivacy>
  </EventRegistrationForm>;
}
