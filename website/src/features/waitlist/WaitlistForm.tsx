import {websiteCopy} from "@content/generated";
import type {FormVariant} from "../../shared/forms/types";
import {activeWaitlistCityOptions} from "@content/markets";
import {
  Button,
  FormStatus,
  HoneypotField,
  SelectField,
  TextField,
  WaitlistFormShell,
} from "../../shared/ui/primitives";
import {useWaitlistFormController} from "./useWaitlistFormController";

export function WaitlistForm({variant}: {variant: FormVariant}) {
  const {
    handleCityChange,
    handleFormStart,
    handleRoleChange,
    handleSubmit,
    isSubmitting,
    roleOptions,
    showCustomCity,
    status,
  } = useWaitlistFormController(variant);

  return (
    <WaitlistFormShell onFocus={handleFormStart} onSubmit={handleSubmit}>
      <TextField id={`${variant}-waitlist-full-name`} label={websiteCopy["waitlistform_0515"]} name="fullName" autoComplete="name" required />
      <TextField id={`${variant}-waitlist-email`} label={websiteCopy["waitlistform_0514"]} name="email" type="email" autoComplete="email" required />
      <SelectField
        id={`${variant}-waitlist-city`}
        label={websiteCopy["waitlistform_0513"]}
        name="city"
        required
        onChange={(event) => {
          handleCityChange(event.currentTarget.value);
        }}
      >
        <option value="">{websiteCopy["waitlistform_0512"]}</option>
        {activeWaitlistCityOptions.map((city) => (
          <option key={city}>{city}</option>
        ))}
      </SelectField>
      <TextField
        id={`${variant}-waitlist-custom-city`}
        label={websiteCopy["waitlistform_0517"]}
        name="customCity"
        autoComplete="address-level2"
        hidden={!showCustomCity}
        required={showCustomCity}
      />
      <SelectField
        id={`${variant}-waitlist-role`}
        label={websiteCopy["waitlistform_0516"]}
        name="role"
        required
        defaultValue={variant === "host" ? "host" : ""}
        onChange={(event) => {
          handleRoleChange(event.currentTarget.value);
        }}
      >
        {roleOptions.map((option) => (
          <option value={option.value} key={option.value || option.label}>
            {option.label}
          </option>
        ))}
      </SelectField>
      <TextField
        id={`${variant}-waitlist-community-link`}
        label={variant === "host" ? "Community or venue link" : "Instagram or community link"}
        name="instagram"
        autoComplete="url"
      />
      <HoneypotField />
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? (variant === "host" ? "Applying..." : "Joining...") : variant === "host" ? "Apply as host" : "Join the list"}
      </Button>
      <FormStatus status={status} />
    </WaitlistFormShell>
  );
}
