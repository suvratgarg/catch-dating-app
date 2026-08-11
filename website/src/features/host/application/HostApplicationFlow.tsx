import {websiteCopy} from "@content/generated";
import {hostApplicationCopy} from "@content/host";
import {websiteTemplates} from "@content/templates";
import {activeHostApplicationCityOptions} from "@content/markets";
import {
  Button,
  ActionGroup,
  ButtonLink,
  ChoiceChip,
  ChoiceChipGrid,
  Field,
  FieldGrid,
  FormStatus,
  HostApplicationCompletenessSummary,
  HostApplicationPanel,
  HostApplicationReviewCard,
  HostApplicationReviewGrid,
  HostApplicationShell,
  HostApplicationStage,
  HostApplicationSubmitted,
  OperationalNote,
  ProfileStrength,
  SelectField,
  StepRail,
  TextAreaField,
  TextField,
} from "../../../shared/ui/primitives";
import {
  hostApplicationChecklist,
  hostApplicationCompleteness,
  hostApplicationSteps,
  hostFormatOptions,
  hostSuccessModuleOptions,
} from "./applicationModel";
import {useHostApplicationController} from "./useHostApplicationController";

export function HostApplicationFlow() {
  const {
    currentStepIndex,
    draft,
    goBack,
    goNext,
    goToStep,
    handleFormStart,
    handleSubmit,
    isSubmitting,
    resolvedCity,
    status,
    step,
    submitted,
    toggleDraftList,
    updateDraft,
  } = useHostApplicationController();

  return (
    <HostApplicationShell
      onFocus={handleFormStart}
      onSubmit={handleSubmit}
      pending={isSubmitting}
    >
      <StepRail
        currentIndex={currentStepIndex}
        items={hostApplicationSteps}
        label={websiteCopy["hostapplicationflow_0232"]}
        onSelect={goToStep}
      />

      <HostApplicationPanel>
        {submitted ? (
          <HostApplicationSubmitted
            label={websiteCopy["hostapplicationflow_0231"]}
            title={websiteTemplates.hostPacketReceived(draft.organizationName)}
            body={websiteCopy["hostapplicationflow_0208"]}
          />
        ) : null}

        {!submitted && step === "profile" ? (
          <HostApplicationStage>
            <FieldGrid>
              <TextField
                id="host-full-name"
                label={websiteCopy["hostapplicationflow_0230"]}
                value={draft.fullName}
                autoComplete="name"
                onChange={(event) => updateDraft("fullName", event.currentTarget.value)}
                required
              />
              <TextField
                id="host-email"
                label={websiteCopy["hostapplicationflow_0221"]}
                value={draft.email}
                type="email"
                autoComplete="email"
                onChange={(event) => updateDraft("email", event.currentTarget.value)}
                required
              />
              <SelectField
                id="host-city"
                label={websiteCopy["hostapplicationflow_0245"]}
                value={draft.city}
                onChange={(event) => updateDraft("city", event.currentTarget.value)}
                required
              >
                {activeHostApplicationCityOptions.map((city) => (
                  <option key={city}>{city}</option>
                ))}
              </SelectField>
              {draft.city === "Other" ? (
                <TextField
                  id="host-custom-city"
                  label={websiteCopy["hostapplicationflow_0265"]}
                  value={draft.customCity}
                  autoComplete="address-level2"
                  onChange={(event) => updateDraft("customCity", event.currentTarget.value)}
                  required
                />
              ) : null}
              <TextField
                id="host-org-name"
                label={websiteCopy["hostapplicationflow_0248"]}
                value={draft.organizationName}
                onChange={(event) => updateDraft("organizationName", event.currentTarget.value)}
                required
              />
              <SelectField
                id="host-org-type"
                label={websiteCopy["hostapplicationflow_0233"]}
                value={draft.organizationType}
                onChange={(event) => updateDraft("organizationType", event.currentTarget.value)}
              >
                <option>{websiteCopy["hostapplicationflow_0234"]}</option>
                <option>{websiteCopy["hostapplicationflow_0255"]}</option>
                <option>{websiteCopy["hostapplicationflow_0259"]}</option>
                <option>{websiteCopy["hostapplicationflow_0217"]}</option>
                <option>{websiteCopy["hostapplicationflow_0222"]}</option>
              </SelectField>
              <TextField
                id="host-community-link"
                label={websiteCopy["hostapplicationflow_0218"]}
                value={draft.communityLink}
                autoComplete="url"
                placeholder={websiteCopy["hostapplicationflow_0235"]}
                onChange={(event) => updateDraft("communityLink", event.currentTarget.value)}
                span
                required
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "event" ? (
          <HostApplicationStage>
            <Field span label={<span>{websiteCopy["hostapplicationflow_0228"]}</span>}>
              <ChoiceChipGrid aria-label={websiteCopy["hostapplicationflow_0228"]}>
                {hostFormatOptions.map((format) => (
                  <ChoiceChip
                    selected={draft.formats.includes(format)}
                    key={format}
                    onClick={() => toggleDraftList("formats", format)}
                  >
                    {format}
                  </ChoiceChip>
                ))}
              </ChoiceChipGrid>
            </Field>
            <FieldGrid>
              <SelectField
                id="host-event-cadence"
                label={websiteCopy["hostapplicationflow_0215"]}
                value={draft.eventCadence}
                onChange={(event) => updateDraft("eventCadence", event.currentTarget.value)}
              >
                <option>{websiteCopy["hostapplicationflow_0262"]}</option>
                <option>{websiteCopy["hostapplicationflow_0212"]}</option>
                <option>{websiteCopy["hostapplicationflow_0240"]}</option>
                <option>{websiteCopy["hostapplicationflow_0252"]}</option>
                <option>{websiteCopy["hostapplicationflow_0243"]}</option>
              </SelectField>
              <TextField
                id="host-event-name"
                label={websiteCopy["hostapplicationflow_0226"]}
                value={draft.nextEventName}
                placeholder={websiteCopy["hostapplicationflow_0237"]}
                onChange={(event) => updateDraft("nextEventName", event.currentTarget.value)}
                required
              />
              <TextField
                id="host-event-date"
                label={websiteCopy["hostapplicationflow_0257"]}
                value={draft.nextEventDate}
                type="date"
                onChange={(event) => updateDraft("nextEventDate", event.currentTarget.value)}
              />
              <TextField
                id="host-event-location"
                label={websiteCopy["hostapplicationflow_0260"]}
                value={draft.eventLocation}
                onChange={(event) => updateDraft("eventLocation", event.currentTarget.value)}
                required
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "setup" ? (
          <HostApplicationStage>
            <FieldGrid>
              <TextField
                id="host-capacity"
                label={hostApplicationCopy.setup.guestCountLabel}
                value={draft.expectedCapacity}
                inputMode="numeric"
                onChange={(event) => updateDraft("expectedCapacity", event.currentTarget.value)}
                required
              />
              <SelectField
                id="host-booking-platform"
                label={hostApplicationCopy.setup.bookingPlatformLabel}
                value={draft.bookingPlatform}
                onChange={(event) => updateDraft("bookingPlatform", event.currentTarget.value)}
                span
              >
                {hostApplicationCopy.setup.bookingPlatforms.map((platform) => (
                  <option key={platform}>{platform}</option>
                ))}
              </SelectField>
              <SelectField
                id="host-guest-list-format"
                label={hostApplicationCopy.setup.guestListFormatLabel}
                value={draft.guestListFormat}
                onChange={(event) => updateDraft("guestListFormat", event.currentTarget.value)}
              >
                {hostApplicationCopy.setup.guestListFormats.map((format) => (
                  <option key={format}>{format}</option>
                ))}
              </SelectField>
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "success" ? (
          <HostApplicationStage>
            <Field span label={<span>{websiteCopy["hostapplicationflow_0224"]}</span>}>
              <ChoiceChipGrid aria-label={websiteCopy["hostapplicationflow_0224"]}>
                {hostSuccessModuleOptions.map((module) => (
                  <ChoiceChip
                    selected={draft.eventSuccessModules.includes(module)}
                    key={module}
                    onClick={() => toggleDraftList("eventSuccessModules", module)}
                  >
                    {module}
                  </ChoiceChip>
                ))}
              </ChoiceChipGrid>
            </Field>
            <FieldGrid>
              <TextAreaField
                id="host-goals"
                label={websiteCopy["hostapplicationflow_0263"]}
                value={draft.hostGoals}
                rows={3}
                placeholder={websiteCopy["hostapplicationflow_0211"]}
                onChange={(event) => updateDraft("hostGoals", event.currentTarget.value)}
                span
                required
              />
              <TextAreaField
                id="host-operating-notes"
                label={websiteCopy["hostapplicationflow_0246"]}
                value={draft.operatingNotes}
                rows={3}
                placeholder={websiteCopy["hostapplicationflow_0219"]}
                onChange={(event) => updateDraft("operatingNotes", event.currentTarget.value)}
                span
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "review" ? (
          <HostApplicationStage>
            <HostApplicationReviewGrid>
              <HostApplicationReviewCard title={websiteCopy["hostapplicationflow_0251"]} rows={[
                ["Host", draft.fullName],
                ["Organization", draft.organizationName],
                ["City", resolvedCity],
                ["Link", draft.communityLink],
              ]} />
              <HostApplicationReviewCard title={websiteCopy["hostapplicationflow_0227"]} rows={[
                ["Formats", draft.formats.join(", ")],
                ["Event", draft.nextEventName],
                ["Location", draft.eventLocation],
                ["Cadence", draft.eventCadence],
              ]} />
              <HostApplicationReviewCard title={hostApplicationCopy.review.setupTitle} rows={[
                [hostApplicationCopy.review.platformLabel, draft.bookingPlatform],
                [hostApplicationCopy.review.formatLabel, draft.guestListFormat],
                [hostApplicationCopy.review.guestsLabel, draft.expectedCapacity],
              ]} />
              <HostApplicationReviewCard title={websiteCopy["hostapplicationflow_0223"]} rows={[
                ["Modules", draft.eventSuccessModules.join(", ")],
                ["Goal", draft.hostGoals],
              ]} />
            </HostApplicationReviewGrid>
            <OperationalNote
              title={hostApplicationCopy.review.noteTitle}
              body={hostApplicationCopy.review.noteBody}
            />
          </HostApplicationStage>
        ) : null}

        <HostApplicationCompletenessSummary
          label={websiteCopy["hostapplicationflow_0207"]}
          meter={<ProfileStrength value={hostApplicationCompleteness(draft)} />}
          items={hostApplicationChecklist(draft)}
        />

        {!submitted ? (
          <ActionGroup>
            <Button
              disabled={currentStepIndex === 0}
              onClick={goBack}
              type="button"
              variant="ghost"
            >{websiteCopy["hostapplicationflow_0209"]}</Button>
            {step === "review" ? (
              <Button disabled={isSubmitting} type="submit">
                {isSubmitting ? "Submitting..." : "Submit host packet"}
              </Button>
            ) : (
              <Button onClick={goNext} type="button">{websiteCopy["hostapplicationflow_0220"]}</Button>
            )}
          </ActionGroup>
        ) : (
          <ActionGroup>
            <ButtonLink href="/organizers/" variant="ghost">{websiteCopy["hostapplicationflow_0214"]}</ButtonLink>
            <ButtonLink href="/claim/">{websiteCopy["hostapplicationflow_0216"]}</ButtonLink>
          </ActionGroup>
        )}

        <FormStatus status={status} />
      </HostApplicationPanel>
    </HostApplicationShell>
  );
}
