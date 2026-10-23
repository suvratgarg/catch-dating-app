import {CatchField} from "@catch/web-ui";
import {websiteCopy} from "@content/generated";
import type {FormVariant} from "../../shared/forms/types";
import {activeWaitlistCityOptions} from "@content/markets";
import {
  Button,
  FormStatus,
  HoneypotField,
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
    <WaitlistFormShell
      onFocus={handleFormStart}
      onSubmit={handleSubmit}
      pending={isSubmitting}
    >
      <CatchField
        recipe="input"
        id={`${variant}-waitlist-full-name`}
        title={websiteCopy["waitlistform_0515"]}
        name="fullName"
        autoComplete="name"
        required
      />
      <CatchField
        recipe="input"
        id={`${variant}-waitlist-email`}
        title={websiteCopy["waitlistform_0514"]}
        name="email"
        autoComplete="email"
        required
        keyboardType="emailAddress"
      />
      <CatchField
        recipe="select"
        id={`${variant}-waitlist-city`}
        title={websiteCopy["waitlistform_0513"]}
        name="city"
        required
        hintText={websiteCopy["waitlistform_0512"]}
        values={activeWaitlistCityOptions}
        itemLabelBuilder={(city) => city}
        onChanged={(city) => handleCityChange(city ?? "")}
      />
      {showCustomCity ? (
        <CatchField
          recipe="input"
          id={`${variant}-waitlist-custom-city`}
          title={websiteCopy["waitlistform_0517"]}
          name="customCity"
          autoComplete="address-level2"
          required
        />
      ) : null}
      <CatchField
        recipe="select"
        id={`${variant}-waitlist-role`}
        title={websiteCopy["waitlistform_0516"]}
        name="role"
        required
        values={roleOptions}
        itemLabelBuilder={(option) => option.label}
        itemValueBuilder={(option) => option.value}
        initialValue={roleOptions.find((option) => option.value === (variant === "host" ? "host" : ""))}
        onChanged={(option) => handleRoleChange(option?.value ?? "")}
      />
      <CatchField
        recipe="input"
        id={`${variant}-waitlist-community-link`}
        title={variant === "host" ? "Community or venue link" : "Instagram or community link"}
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
