import {ProfileStrength} from "../../../components/site";
import {cities} from "../../../shared/lib/cities";
import {
  Button,
  ButtonLink,
  ChoiceChip,
  ChoiceChipGrid,
  Field,
  FormStatus,
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
    <form
      className="host-application"
      onFocus={handleFormStart}
      onSubmit={handleSubmit}
    >
      <StepRail
        currentIndex={currentStepIndex}
        items={hostApplicationSteps}
        label="Host application steps"
        onSelect={goToStep}
      />

      <div className="host-application__panel">
        {submitted ? (
          <div className="host-application__submitted">
            <span className="submitted-panel__mark">✓</span>
            <div>
              <span className="ui-label">Host application received</span>
              <h3>Catch has the operating packet for {draft.organizationName || "your host profile"}.</h3>
              <p>
                Approval still has to happen before the website can create clubs,
                events, payouts, or owner dashboards on your behalf.
              </p>
            </div>
          </div>
        ) : null}

        {!submitted && step === "profile" ? (
          <div className="host-application__stage">
            <div className="flow-field-grid">
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
                {cities.map((city) => (
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
            </div>
          </div>
        ) : null}

        {!submitted && step === "event" ? (
          <div className="host-application__stage">
            <Field span label={<span>Formats you want to run</span>}>
              <ChoiceChipGrid>
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
            <div className="flow-field-grid">
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
            </div>
          </div>
        ) : null}

        {!submitted && step === "policy" ? (
          <div className="host-application__stage">
            <div className="flow-field-grid">
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
            </div>
          </div>
        ) : null}

        {!submitted && step === "success" ? (
          <div className="host-application__stage">
            <Field span label={<span>Event Success modules to start with</span>}>
              <ChoiceChipGrid>
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
            <div className="flow-field-grid">
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
            </div>
          </div>
        ) : null}

        {!submitted && step === "review" ? (
          <div className="host-application__stage">
            <div className="host-application__review">
              <HostApplicationSummary title="Profile" rows={[
                ["Host", draft.fullName],
                ["Organization", draft.organizationName],
                ["City", resolvedCity],
                ["Link", draft.communityLink],
              ]} />
              <HostApplicationSummary title="First event" rows={[
                ["Formats", draft.formats.join(", ")],
                ["Event", draft.nextEventName],
                ["Location", draft.eventLocation],
                ["Cadence", draft.eventCadence],
              ]} />
              <HostApplicationSummary title="Operations" rows={[
                ["Capacity", draft.expectedCapacity],
                ["Admission", draft.admissionModel],
                ["Waitlist", draft.waitlistPlan],
                ["Payment", draft.paymentReadiness],
              ]} />
              <HostApplicationSummary title="Event Success" rows={[
                ["Modules", draft.eventSuccessModules.join(", ")],
                ["Goal", draft.hostGoals],
              ]} />
            </div>
            <div className="operational-note">
              <strong>What this does now</strong>
              <p>
                This submits a real host lead packet for review. Creating clubs,
                events, payout accounts, and owner dashboards still requires
                approval because those backend callables are host-authenticated.
              </p>
            </div>
          </div>
        ) : null}

        <div className="host-application__summary">
          <div>
            <span className="ui-label">Application completeness</span>
            <ProfileStrength value={hostApplicationCompleteness(draft)} />
          </div>
          <ul>
            {hostApplicationChecklist(draft).map((item) => (
              <li className={item.done ? "is-done" : ""} key={item.label}>
                <span>{item.done ? "✓" : "·"}</span>{item.label}
              </li>
            ))}
          </ul>
        </div>

        {!submitted ? (
          <div className="flow-actions">
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
          </div>
        ) : (
          <div className="flow-actions">
            <ButtonLink href="/organizers/" variant="ghost">
              Browse organizer pages
            </ButtonLink>
            <ButtonLink href="/claim/">
              Claim an existing listing
            </ButtonLink>
          </div>
        )}

        <FormStatus status={status} />
      </div>
    </form>
  );
}

function HostApplicationSummary({
  title,
  rows,
}: {
  title: string;
  rows: Array<[string, string]>;
}) {
  return (
    <article>
      <span className="ui-label">{title}</span>
      <dl>
        {rows.map(([label, value]) => (
          <div key={label}>
            <dt>{label}</dt>
            <dd>{value || "Not provided"}</dd>
          </div>
        ))}
      </dl>
    </article>
  );
}
