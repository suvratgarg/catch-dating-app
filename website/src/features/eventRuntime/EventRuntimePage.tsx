import {useParams} from "react-router";
import {
  eventRuntimeCopy,
  eventRuntimeGenderOptions,
} from "../../content/eventRuntime";
import {
  Button,
  ButtonLink,
  ChoiceChip,
  ChoiceChipGrid,
  EventRuntimeAssignments,
  EventRuntimeConsent,
  EventRuntimeFieldset,
  EventRuntimeForm,
  EventRuntimeFrame,
  EventRuntimeKicker,
  EventRuntimeLive,
  EventRuntimeLiveHeader,
  EventRuntimeLoading,
  EventRuntimeMission,
  EventRuntimeModule,
  EventRuntimePanel,
  EventRuntimePrivacy,
  EventRuntimeProfileQuestions,
  EventRuntimeQuestionnaire,
  FormStatus,
  SelectField,
  TextAreaField,
  TextField,
} from "../../shared/ui/primitives";
import {useEventRuntimeController} from "./useEventRuntimeController";

export function EventRuntimePage() {
  const {publicRuntimeId = ""} = useParams<{publicRuntimeId: string}>();
  const controller = useEventRuntimeController(publicRuntimeId);
  const event = controller.bootstrap?.event ?? null;

  if (controller.stage === "loading") {
    return (
      <EventRuntimeFrame
        brandLabel={eventRuntimeCopy.brand}
        brandWord={eventRuntimeCopy.brandWord}
        eventTitle={event?.title}
      >
        <EventRuntimeLoading label={eventRuntimeCopy.brand} />
      </EventRuntimeFrame>
    );
  }

  if (controller.stage === "unavailable") {
    return (
      <EventRuntimeFrame
        brandLabel={eventRuntimeCopy.brand}
        brandWord={eventRuntimeCopy.brandWord}
        eventTitle={event?.title}
      >
        <EventRuntimePanel
          kicker={eventRuntimeCopy.brand}
          title={eventRuntimeCopy.unavailableTitle}
          body={eventRuntimeCopy.unavailableBody}
        >
          <FormStatus status={controller.status} />
          <ButtonLink href="/help" variant="ghost">
            {eventRuntimeCopy.helpAction}
          </ButtonLink>
        </EventRuntimePanel>
      </EventRuntimeFrame>
    );
  }

  return (
    <EventRuntimeFrame
      brandLabel={eventRuntimeCopy.brand}
      brandWord={eventRuntimeCopy.brandWord}
      eventTitle={event?.title}
    >
      {controller.stage === "phone" ? (
        <EventRuntimePanel
          kicker={eventRuntimeCopy.phoneKicker}
          title={eventRuntimeCopy.phoneTitle}
          body={eventRuntimeCopy.phoneBody}
        >
          <EventRuntimeForm onSubmit={controller.handlePhoneSubmit} pending={controller.pending}>
            <TextField
              autoComplete="tel"
              id="event-runtime-phone"
              inputMode="tel"
              label={eventRuntimeCopy.phoneLabel}
              onChange={(event) => controller.setPhoneNumber(event.target.value)}
              placeholder={eventRuntimeCopy.phonePlaceholder}
              value={controller.phoneNumber}
            />
            <div id={controller.recaptchaContainerId} />
            <Button loading={controller.pending} loadingLabel={eventRuntimeCopy.sendingCode} type="submit">
              {eventRuntimeCopy.sendCode}
            </Button>
            <FormStatus status={controller.status} />
          </EventRuntimeForm>
        </EventRuntimePanel>
      ) : null}

      {controller.stage === "otp" ? (
        <EventRuntimePanel
          kicker={eventRuntimeCopy.otpKicker}
          title={eventRuntimeCopy.otpTitle}
          body={eventRuntimeCopy.otpBody}
        >
          <EventRuntimeForm onSubmit={controller.handleCodeSubmit} pending={controller.pending}>
            <TextField
              autoComplete="one-time-code"
              id="event-runtime-code"
              inputMode="numeric"
              label={eventRuntimeCopy.otpLabel}
              maxLength={6}
              onChange={(event) => controller.setCode(event.target.value.replace(/\D/gu, ""))}
              value={controller.code}
            />
            <Button loading={controller.pending} loadingLabel={eventRuntimeCopy.confirmingCode} type="submit">
              {eventRuntimeCopy.confirmCode}
            </Button>
            <FormStatus status={controller.status} />
          </EventRuntimeForm>
        </EventRuntimePanel>
      ) : null}

      {controller.stage === "profile" ? (
        <EventRuntimePanel
          kicker={eventRuntimeCopy.profileKicker}
          title={eventRuntimeCopy.profileTitle}
          body={eventRuntimeCopy.profileBody}
        >
          <EventRuntimeForm onSubmit={controller.handleProfileSubmit} pending={controller.pending}>
            <TextField
              autoComplete="name"
              id="event-runtime-name"
              label={eventRuntimeCopy.displayNameLabel}
              maxLength={120}
              onChange={(event) => controller.setDisplayName(event.target.value)}
              value={controller.displayName}
            />
            {controller.requiresCompatibilityProfile ? (
              <CompatibilityProfileFields controller={controller} />
            ) : null}
            <EventRuntimeConsent
              checked={controller.saveAsCatchPrefill}
              onChange={(event) => controller.setSaveAsCatchPrefill(event.target.checked)}
            >
              {eventRuntimeCopy.prefillConsent}
            </EventRuntimeConsent>
            <Button loading={controller.pending} loadingLabel={eventRuntimeCopy.savingProfile} type="submit">
              {eventRuntimeCopy.continueAction}
            </Button>
            <FormStatus status={controller.status} />
          </EventRuntimeForm>
        </EventRuntimePanel>
      ) : null}

      {controller.stage === "approval" ? (
        <EventRuntimePanel
          kicker={eventRuntimeCopy.approvalKicker}
          title={eventRuntimeCopy.approvalTitle}
          body={eventRuntimeCopy.approvalBody}
        >
          <Button
            loading={controller.pending}
            onClick={() => void controller.handleRefresh()}
            type="button"
          >
            {eventRuntimeCopy.refreshAction}
          </Button>
          <FormStatus status={controller.status} />
        </EventRuntimePanel>
      ) : null}

      {controller.stage === "runtime" && event ? (
        <LiveEventRuntime controller={controller} />
      ) : null}
    </EventRuntimeFrame>
  );
}

function CompatibilityProfileFields({
  controller,
}: {
  controller: ReturnType<typeof useEventRuntimeController>;
}) {
  return (
    <EventRuntimeProfileQuestions>
      <EventRuntimeFieldset>
        <legend>{eventRuntimeCopy.genderLabel}</legend>
        <ChoiceChipGrid aria-label={eventRuntimeCopy.genderLabel}>
          {eventRuntimeGenderOptions.map((option) => (
            <ChoiceChip
              key={option.id}
              onClick={() => controller.setGender(option.id)}
              selected={controller.gender === option.id}
            >
              {option.label}
            </ChoiceChip>
          ))}
        </ChoiceChipGrid>
      </EventRuntimeFieldset>
      <EventRuntimeFieldset>
        <legend>{eventRuntimeCopy.interestedLabel}</legend>
        <ChoiceChipGrid aria-label={eventRuntimeCopy.interestedLabel}>
          {eventRuntimeGenderOptions.map((option) => (
            <ChoiceChip
              key={option.id}
              onClick={() => controller.toggleInterest(option.id)}
              selected={controller.interestedInGenders.includes(option.id)}
            >
              {option.label}
            </ChoiceChip>
          ))}
        </ChoiceChipGrid>
      </EventRuntimeFieldset>
      <EventRuntimeConsent
        checked={controller.sensitiveConsent}
        onChange={(event) => controller.setSensitiveConsent(event.target.checked)}
        required
      >
        {eventRuntimeCopy.sensitiveConsent}
      </EventRuntimeConsent>
    </EventRuntimeProfileQuestions>
  );
}

function LiveEventRuntime({
  controller,
}: {
  controller: ReturnType<typeof useEventRuntimeController>;
}) {
  const event = controller.bootstrap!.event;
  const modules = new Set(event.moduleIds);
  const mission = controller.liveState.mission;
  const revealBlocked = modules.has("live_reveal") &&
    controller.liveState.plan?.revealStatus !== "revealed";
  return (
    <EventRuntimeLive>
      <EventRuntimeLiveHeader badge={eventRuntimeCopy.checkedIn}>
        <EventRuntimeKicker>{eventRuntimeCopy.runtimeEyebrow}</EventRuntimeKicker>
        <h1>{event.title}</h1>
        <p>{event.locationName} · {formatEventTime(event.startTimeMillis)}</p>
      </EventRuntimeLiveHeader>

      <EventRuntimeModule title={eventRuntimeCopy.assignmentTitle} accent="coral">
        {revealBlocked ? <p>{eventRuntimeCopy.revealWaiting}</p> :
          controller.liveState.assignments.length ? (
          <EventRuntimeAssignments>
            {controller.liveState.assignments.map((assignment) => (
              <article key={assignment.moduleId}>
                <span>{assignment.label}</span>
                <h3>{assignment.displayTitle}</h3>
                {assignment.displaySubtitle ? <p>{assignment.displaySubtitle}</p> : null}
                {assignment.whySummary ? <small>{assignment.whySummary}</small> : null}
              </article>
            ))}
          </EventRuntimeAssignments>
          ) : <p>{eventRuntimeCopy.assignmentEmpty}</p>}
      </EventRuntimeModule>

      {controller.liveState.plan?.attendeePrompt ? (
        <EventRuntimeModule title={eventRuntimeCopy.hostPromptTitle}>
          <p>{controller.liveState.plan.attendeePrompt}</p>
        </EventRuntimeModule>
      ) : null}

      {modules.has("first_hello_check_in") ? (
        <EventRuntimeModule title={eventRuntimeCopy.firstHelloTitle}>
          <p>{eventRuntimeCopy.firstHelloBody}</p>
          {!mission ? (
            <Button
              loading={controller.pending}
              loadingLabel={eventRuntimeCopy.firstHelloStarting}
              onClick={() => void controller.startFirstHello()}
              type="button"
            >
              {eventRuntimeCopy.firstHelloStart}
            </Button>
          ) : (
            <EventRuntimeMission>
              <span>{mission.targetContext}</span>
              <h3>{mission.targetDisplayName}</h3>
              <p>{mission.question}</p>
              <ChoiceChipGrid aria-label={mission.question}>
                {mission.answerOptions.map((answer) => (
                  <ChoiceChip
                    disabled={controller.pending || mission.status !== "active"}
                    key={answer.id}
                    onClick={() => void controller.completeFirstHello(answer.id)}
                    selected={mission.selectedAnswerId === answer.id}
                  >
                    {answer.label}
                  </ChoiceChip>
                ))}
              </ChoiceChipGrid>
              {mission.status === "active" ? <small>{eventRuntimeCopy.firstHelloComplete}</small> : null}
            </EventRuntimeMission>
          )}
        </EventRuntimeModule>
      ) : null}

      {modules.has("compatibility_questionnaire") ? (
        <EventRuntimeModule title={controller.questionnaire.title}>
          <p>{eventRuntimeCopy.compatibilityBody}</p>
          <EventRuntimeQuestionnaire>
            {controller.questionnaire.questions.map((question) => (
              <EventRuntimeFieldset key={question.id}>
                <legend>{question.prompt}</legend>
                <ChoiceChipGrid aria-label={question.prompt}>
                  {question.options.map((answer) => (
                    <ChoiceChip
                      key={answer.id}
                      onClick={() => controller.selectQuestionAnswer(question.id, answer.id)}
                      selected={controller.questionAnswers[question.id] === answer.id}
                    >
                      {answer.label}
                    </ChoiceChip>
                  ))}
                </ChoiceChipGrid>
              </EventRuntimeFieldset>
            ))}
          </EventRuntimeQuestionnaire>
          <Button onClick={() => void controller.saveCompatibilityAnswers()} type="button">
            {eventRuntimeCopy.compatibilitySave}
          </Button>
        </EventRuntimeModule>
      ) : null}

      {modules.has("wingman_requests") ? (
        <EventRuntimeModule title={eventRuntimeCopy.wingmanTitle}>
          <p>{eventRuntimeCopy.wingmanBody}</p>
          {controller.wingmanCandidates.length ? (
            <SelectField
              id="event-runtime-wingman"
              label={eventRuntimeCopy.wingmanSelect}
              onChange={(event) => controller.setWingmanTargetUid(event.target.value)}
              value={controller.wingmanTargetUid}
            >
              <option value="">{eventRuntimeCopy.wingmanSelect}</option>
              {controller.wingmanCandidates.map((candidate) => (
                <option key={candidate.uid} value={candidate.uid}>{candidate.displayName}</option>
              ))}
            </SelectField>
          ) : <p>{eventRuntimeCopy.wingmanEmpty}</p>}
          {controller.liveState.wingmanTargetUid ? (
            <Button onClick={() => void controller.withdrawWingmanRequest()} type="button" variant="ghost">
              {eventRuntimeCopy.wingmanWithdraw}
            </Button>
          ) : (
            <Button
              disabled={!controller.wingmanTargetUid}
              onClick={() => void controller.submitWingmanRequest()}
              type="button"
            >
              {eventRuntimeCopy.wingmanSubmit}
            </Button>
          )}
        </EventRuntimeModule>
      ) : null}

      {modules.has("decomposed_feedback") && Date.now() >= event.endTimeMillis ? (
        <EventRuntimeModule title={eventRuntimeCopy.feedbackTitle}>
          <p>{eventRuntimeCopy.feedbackBody}</p>
          <EventRuntimeForm onSubmit={(submitEvent) => {
            submitEvent.preventDefault();
            void controller.submitFeedback();
          }} pending={controller.pending}>
            <RuntimeRating
              label={eventRuntimeCopy.welcomeRating}
              onChange={controller.setWelcomeRating}
              value={controller.welcomeRating}
            />
            <RuntimeRating
              label={eventRuntimeCopy.structureRating}
              onChange={controller.setStructureRating}
              value={controller.structureRating}
            />
            <TextField
              id="event-runtime-people-met"
              label={eventRuntimeCopy.peopleMet}
              max={100}
              min={0}
              onChange={(changeEvent) => controller.setMetNewPeopleCount(
                Math.max(0, Math.min(100, Number(changeEvent.target.value) || 0))
              )}
              type="number"
              value={controller.metNewPeopleCount}
            />
            <EventRuntimeConsent
              checked={controller.safetyConcern}
              onChange={(changeEvent) => controller.setSafetyConcern(changeEvent.target.checked)}
              required={controller.safetyConcern}
            >
              {eventRuntimeCopy.safetyConcern}
            </EventRuntimeConsent>
            <TextAreaField
              id="event-runtime-private-note"
              label={eventRuntimeCopy.privateNote}
              maxLength={500}
              onChange={(changeEvent) => controller.setPrivateNote(changeEvent.target.value)}
              rows={3}
              value={controller.privateNote}
            />
            <Button type="submit">{eventRuntimeCopy.feedbackSave}</Button>
          </EventRuntimeForm>
        </EventRuntimeModule>
      ) : null}

      <FormStatus status={controller.status} />
      <EventRuntimePrivacy>{eventRuntimeCopy.privacyNote}</EventRuntimePrivacy>
    </EventRuntimeLive>
  );
}

function RuntimeRating({
  label,
  onChange,
  value,
}: {
  label: string;
  onChange: (value: number) => void;
  value: number;
}) {
  return (
    <EventRuntimeFieldset>
      <legend>{label}</legend>
      <ChoiceChipGrid aria-label={label}>
        {[1, 2, 3, 4, 5].map((score) => (
          <ChoiceChip
            key={score}
            onClick={() => onChange(score)}
            selected={value === score}
          >
            {score}
          </ChoiceChip>
        ))}
      </ChoiceChipGrid>
    </EventRuntimeFieldset>
  );
}

function formatEventTime(millis: number) {
  return new Intl.DateTimeFormat(undefined, {
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(millis));
}
