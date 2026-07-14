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
    >
      <StepRail
        currentIndex={currentStepIndex}
        items={hostApplicationSteps}
        label="Host application steps"
        onSelect={goToStep}
      />

      <HostApplicationPanel>
        {submitted ? (
          <HostApplicationSubmitted
            label="Host application received"
            title={`Catch has the operating packet for ${draft.organizationName || "your host profile"}.`}
            body="Approval still has to happen before the website can create clubs, events, payouts, or owner dashboards on your behalf."
          />
        ) : null}

        {!submitted && step === "profile" ? (
          <HostApplicationStage>
            <FieldGrid>
              <TextField
                id="host-full-name"
                label="Full name"
                value={draft.fullName}
                autoComplete="name"
                onChange={(event) => updateDraft("fullName", event.currentTarget.value)}
                required
              />
              <TextField
                id="host-email"
                label="Email"
                value={draft.email}
                type="email"
                autoComplete="email"
                onChange={(event) => updateDraft("email", event.currentTarget.value)}
                required
              />
              <SelectField
                id="host-city"
                label="Operating city"
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
                  label="Your city"
                  value={draft.customCity}
                  autoComplete="address-level2"
                  onChange={(event) => updateDraft("customCity", event.currentTarget.value)}
                  required
                />
              ) : null}
              <TextField
                id="host-org-name"
                label="Organizer, venue, or community name"
                value={draft.organizationName}
                onChange={(event) => updateDraft("organizationName", event.currentTarget.value)}
                required
              />
              <SelectField
                id="host-org-type"
                label="Host type"
                value={draft.organizationType}
                onChange={(event) => updateDraft("organizationType", event.currentTarget.value)}
              >
                <option>Independent host</option>
                <option>Run club</option>
                <option>Venue</option>
                <option>Community</option>
                <option>Event company</option>
              </SelectField>
              <TextField
                id="host-community-link"
                label="Community or venue link"
                value={draft.communityLink}
                autoComplete="url"
                placeholder="Instagram, website, Luma, Linktree, or venue page"
                onChange={(event) => updateDraft("communityLink", event.currentTarget.value)}
                span
                required
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "event" ? (
          <HostApplicationStage>
            <Field span label={<span id="host-format-options-label">Formats you want to run</span>}>
              <ChoiceChipGrid aria-labelledby="host-format-options-label">
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
                label="Cadence"
                value={draft.eventCadence}
                onChange={(event) => updateDraft("eventCadence", event.currentTarget.value)}
              >
                <option>Weekly</option>
                <option>Biweekly</option>
                <option>Monthly</option>
                <option>Quarterly</option>
                <option>One-off launch</option>
              </SelectField>
              <TextField
                id="host-event-name"
                label="First Catch event"
                value={draft.nextEventName}
                placeholder="Long table no. 1, Saturday run, singles mixer"
                onChange={(event) => updateDraft("nextEventName", event.currentTarget.value)}
                required
              />
              <TextField
                id="host-event-date"
                label="Target date"
                value={draft.nextEventDate}
                type="date"
                onChange={(event) => updateDraft("nextEventDate", event.currentTarget.value)}
              />
              <TextField
                id="host-event-location"
                label="Venue or meeting area"
                value={draft.eventLocation}
                onChange={(event) => updateDraft("eventLocation", event.currentTarget.value)}
                required
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "policy" ? (
          <HostApplicationStage>
            <FieldGrid>
              <TextField
                id="host-capacity"
                label="Expected capacity"
                value={draft.expectedCapacity}
                inputMode="numeric"
                onChange={(event) => updateDraft("expectedCapacity", event.currentTarget.value)}
                required
              />
              <TextField
                id="host-price-range"
                label="Price range"
                value={draft.priceRange}
                onChange={(event) => updateDraft("priceRange", event.currentTarget.value)}
              />
              <SelectField
                id="host-admission"
                label="Admission model"
                value={draft.admissionModel}
                onChange={(event) => updateDraft("admissionModel", event.currentTarget.value)}
              >
                <option>Open booking</option>
                <option>Request to join</option>
                <option>Invite-only</option>
                <option>Balanced ratio</option>
                <option>Members-only</option>
              </SelectField>
              <SelectField
                id="host-waitlist-plan"
                label="Waitlist plan"
                value={draft.waitlistPlan}
                onChange={(event) => updateDraft("waitlistPlan", event.currentTarget.value)}
              >
                <option>Ranked timed offers</option>
                <option>Manual review</option>
                <option>Broadcast first come first served</option>
                <option>No waitlist</option>
              </SelectField>
              <SelectField
                id="host-payment"
                label="Payment readiness"
                value={draft.paymentReadiness}
                onChange={(event) => updateDraft("paymentReadiness", event.currentTarget.value)}
                span
              >
                <option>Need Catch payment onboarding</option>
                <option>Already sell paid tickets</option>
                <option>Free events first</option>
                <option>Sponsor or venue-funded</option>
              </SelectField>
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "success" ? (
          <HostApplicationStage>
            <Field span label={<span id="host-success-modules-label">Event Success modules to start with</span>}>
              <ChoiceChipGrid aria-labelledby="host-success-modules-label">
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
                label="What should Catch help you improve?"
                value={draft.hostGoals}
                rows={3}
                placeholder="Better gender balance, less awkward arrivals, verified reviews, repeat attendance..."
                onChange={(event) => updateDraft("hostGoals", event.currentTarget.value)}
                span
                required
              />
              <TextAreaField
                id="host-operating-notes"
                label="Operating notes"
                value={draft.operatingNotes}
                rows={3}
                placeholder="Constraints, safety needs, venue rules, approval preferences, payout timing, or launch questions"
                onChange={(event) => updateDraft("operatingNotes", event.currentTarget.value)}
                span
              />
            </FieldGrid>
          </HostApplicationStage>
        ) : null}

        {!submitted && step === "review" ? (
          <HostApplicationStage>
            <HostApplicationReviewGrid>
              <HostApplicationReviewCard title="Profile" rows={[
                ["Host", draft.fullName],
                ["Organization", draft.organizationName],
                ["City", resolvedCity],
                ["Link", draft.communityLink],
              ]} />
              <HostApplicationReviewCard title="First event" rows={[
                ["Formats", draft.formats.join(", ")],
                ["Event", draft.nextEventName],
                ["Location", draft.eventLocation],
                ["Cadence", draft.eventCadence],
              ]} />
              <HostApplicationReviewCard title="Operations" rows={[
                ["Capacity", draft.expectedCapacity],
                ["Admission", draft.admissionModel],
                ["Waitlist", draft.waitlistPlan],
                ["Payment", draft.paymentReadiness],
              ]} />
              <HostApplicationReviewCard title="Event Success" rows={[
                ["Modules", draft.eventSuccessModules.join(", ")],
                ["Goal", draft.hostGoals],
              ]} />
            </HostApplicationReviewGrid>
            <OperationalNote
              title="What this does now"
              body="This submits a real host lead packet for review. Creating clubs, events, payout accounts, and owner dashboards still requires approval because those backend callables are host-authenticated."
            />
          </HostApplicationStage>
        ) : null}

        <HostApplicationCompletenessSummary
          label="Application completeness"
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
            >
              Back
            </Button>
            {step === "review" ? (
              <Button disabled={isSubmitting} type="submit">
                {isSubmitting ? "Submitting..." : "Submit host packet"}
              </Button>
            ) : (
              <Button onClick={goNext} type="button">
                Continue
              </Button>
            )}
          </ActionGroup>
        ) : (
          <ActionGroup>
            <ButtonLink href="/organizers/" variant="ghost">
              Browse organizer pages
            </ButtonLink>
            <ButtonLink href="/claim/">
              Claim an existing listing
            </ButtonLink>
          </ActionGroup>
        )}

        <FormStatus status={status} />
      </HostApplicationPanel>
    </HostApplicationShell>
  );
}
