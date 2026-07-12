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
      <TextField id={`${variant}-waitlist-full-name`} label="Full name" name="fullName" autoComplete="name" required />
      <TextField id={`${variant}-waitlist-email`} label="Email" name="email" type="email" autoComplete="email" required />
      <SelectField
        id={`${variant}-waitlist-city`}
        label="City"
        name="city"
        required
        onChange={(event) => {
          handleCityChange(event.currentTarget.value);
        }}
      >
        <option value="">Choose city</option>
        {activeWaitlistCityOptions.map((city) => (
          <option key={city}>{city}</option>
        ))}
      </SelectField>
      <TextField
        id={`${variant}-waitlist-custom-city`}
        label="Your city"
        name="customCity"
        autoComplete="address-level2"
        hidden={!showCustomCity}
        required={showCustomCity}
      />
      <SelectField
        id={`${variant}-waitlist-role`}
        label="Joining as"
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
