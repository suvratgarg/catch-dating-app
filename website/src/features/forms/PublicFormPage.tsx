import {useParams} from "react-router";
import {
  Button,
  ButtonLink,
  CheckboxField,
  ChoiceChip,
  FormStatus,
  PublicFormActions,
  PublicFormChoiceList,
  PublicFormConsent,
  PublicFormForm,
  PublicFormFrame,
  PublicFormLoading,
  PublicFormPanel,
  PublicFormPrivacy,
  PublicFormProgress,
  PublicFormQuestion,
  PublicFormReview,
  PublicFormReviewAnswer,
  PublicFormSection,
  TextAreaField,
  TextField,
} from "../../shared/ui/primitives";
import {publicFormsCopy} from "../../content/forms";
import {
  answerSummary,
  type PublicFormAnswer,
  type PublicFormQuestion as Question,
} from "./publicFormModel";
import {usePublicFormController} from "./usePublicFormController";

export function PublicFormPage() {
  const {publicFormId = ""} = useParams<{publicFormId: string}>();
  const controller = usePublicFormController(publicFormId);
  const organizerName = controller.form?.organizer.name;

  return (
    <PublicFormFrame
      brandLabel={publicFormsCopy.brand}
      brandWord={publicFormsCopy.brandWord}
      embed={controller.embed}
      organizerName={organizerName}
    >
      <PublicFormStage controller={controller} />
      <PublicFormPrivacy>{publicFormsCopy.privacyNote}</PublicFormPrivacy>
    </PublicFormFrame>
  );
}

function PublicFormStage({
  controller,
}: {
  controller: ReturnType<typeof usePublicFormController>;
}) {
  const definition = controller.form?.definition;

  if (controller.stage === "loading") {
    return <PublicFormLoading label={publicFormsCopy.loading} />;
  }
  if (controller.stage === "unavailable") {
    return (
      <PublicFormPanel
        kicker={controller.form?.organizer.name ?? publicFormsCopy.brand}
        title={publicFormsCopy.unavailableTitle}
        body={controller.form?.availabilityMessage ?? publicFormsCopy.unavailableBody}
      >
        <FormStatus status={controller.status} />
      </PublicFormPanel>
    );
  }
  if (controller.stage === "identity" ||
      controller.stage === "phoneCode" ||
      controller.stage === "emailSent") {
    return <IdentityStage controller={controller} />;
  }
  if (controller.stage === "form" && definition && controller.activeSection) {
    return <QuestionStage controller={controller} />;
  }
  if (controller.stage === "review" && definition) {
    return <ReviewStage controller={controller} />;
  }
  if (controller.stage === "complete" && controller.receipt) {
    const completion = controller.receipt.completion;
    return (
      <PublicFormPanel
        kicker={publicFormsCopy.completionKicker}
        title={completion.title}
        body={completion.message}
      >
        <PublicFormActions>
          {completion.actionUrl && completion.actionLabel ? (
            <ButtonLink href={completion.actionUrl}>{completion.actionLabel}</ButtonLink>
          ) : null}
          <Button
            loading={controller.pending}
            loadingLabel={publicFormsCopy.withdrawing}
            onClick={() => void controller.withdraw()}
            type="button"
            variant="ghost"
          >
            {publicFormsCopy.withdraw}
          </Button>
        </PublicFormActions>
        <FormStatus status={controller.status} />
      </PublicFormPanel>
    );
  }
  if (controller.stage === "withdrawn") {
    return (
      <PublicFormPanel
        kicker={publicFormsCopy.completionKicker}
        title={publicFormsCopy.withdrawnTitle}
        body={publicFormsCopy.withdrawnBody}
      >
        <span />
      </PublicFormPanel>
    );
  }
  return <PublicFormLoading label={publicFormsCopy.loading} />;
}

function IdentityStage({
  controller,
}: {
  controller: ReturnType<typeof usePublicFormController>;
}) {
  const policy = controller.form?.definition.identityPolicy;
  const permitsPhone = policy === "phoneVerified" ||
    policy === "emailOrPhoneVerified" || policy === "catchAccount";
  const permitsEmail = policy === "emailVerified" ||
    policy === "emailOrPhoneVerified" || policy === "catchAccount";
  if (controller.stage === "emailSent") {
    return (
      <PublicFormPanel
        kicker={publicFormsCopy.identityKicker}
        title={publicFormsCopy.emailSentTitle}
        body={publicFormsCopy.emailSentBody}
      >
        <FormStatus status={controller.status} />
      </PublicFormPanel>
    );
  }
  return (
    <PublicFormPanel
      kicker={publicFormsCopy.identityKicker}
      title={publicFormsCopy.identityTitle}
      body={publicFormsCopy.identityBody}
    >
      {controller.stage === "phoneCode" ? (
        <PublicFormForm
          onSubmit={controller.handleCodeSubmit}
          pending={controller.pending}
        >
          <TextField
            autoComplete="one-time-code"
            id="public-form-code"
            inputMode="numeric"
            label={publicFormsCopy.codeLabel}
            maxLength={6}
            onChange={(event) => controller.setCode(
              event.target.value.replace(/\D/gu, "")
            )}
            value={controller.code}
          />
          <Button
            loading={controller.pending}
            loadingLabel={publicFormsCopy.confirmingCode}
            type="submit"
          >
            {publicFormsCopy.confirmCode}
          </Button>
        </PublicFormForm>
      ) : (
        <>
          {permitsPhone ? (
            <PublicFormForm
              onSubmit={controller.handlePhoneSubmit}
              pending={controller.pending}
            >
              <TextField
                autoComplete="tel"
                id="public-form-phone"
                inputMode="tel"
                label={publicFormsCopy.phoneLabel}
                onChange={(event) => controller.setPhoneNumber(event.target.value)}
                placeholder={publicFormsCopy.phonePlaceholder}
                value={controller.phoneNumber}
              />
              <Button
                loading={controller.pending}
                loadingLabel={publicFormsCopy.sendingCode}
                type="submit"
              >
                {publicFormsCopy.sendCode}
              </Button>
            </PublicFormForm>
          ) : null}
          {permitsEmail ? (
            <PublicFormForm
              onSubmit={controller.handleEmailSubmit}
              pending={controller.pending}
            >
              <TextField
                autoComplete="email"
                id="public-form-email"
                inputMode="email"
                label={publicFormsCopy.emailLabel}
                onChange={(event) => controller.setEmail(event.target.value)}
                type="email"
                value={controller.email}
              />
              <Button
                loading={controller.pending}
                loadingLabel={publicFormsCopy.sendingEmailLink}
                type="submit"
                variant={permitsPhone ? "ghost" : "primary"}
              >
                {window.location.href.includes("mode=signIn") ?
                  publicFormsCopy.completeEmailSignIn :
                  publicFormsCopy.sendEmailLink}
              </Button>
            </PublicFormForm>
          ) : null}
        </>
      )}
      <div id={controller.recaptchaContainerId} />
      <FormStatus status={controller.status} />
    </PublicFormPanel>
  );
}

function QuestionStage({
  controller,
}: {
  controller: ReturnType<typeof usePublicFormController>;
}) {
  const definition = controller.form!.definition;
  const section = controller.activeSection!;
  const finalSection = controller.sectionIndex ===
    controller.visibleSections.length - 1;
  return (
    <PublicFormPanel
      kicker={controller.form!.organizer.name}
      title={definition.title}
      body={definition.description}
    >
      <PublicFormProgress
        current={controller.sectionIndex + 1}
        label={publicFormsCopy.stepLabel}
        total={controller.visibleSections.length + 1}
      />
      <PublicFormSection title={section.title} description={section.description}>
        {section.questions.map((question) => (
          <QuestionField
            answer={controller.answers[question.questionId]}
            error={controller.errors[question.questionId]}
            key={question.questionId}
            onChange={(answer) => controller.updateAnswer(
              question.questionId,
              answer
            )}
            question={question}
          />
        ))}
      </PublicFormSection>
      <PublicFormActions>
        {controller.sectionIndex > 0 ? (
          <Button onClick={controller.previousSection} type="button" variant="ghost">
            {publicFormsCopy.previous}
          </Button>
        ) : null}
        <Button onClick={() => void controller.nextSection()} type="button">
          {finalSection ? publicFormsCopy.review : publicFormsCopy.next}
        </Button>
      </PublicFormActions>
      <FormStatus status={controller.status} />
      <FormStatus status={{
        message: controller.saveState === "saving" ? publicFormsCopy.saveStatus :
          controller.saveState === "saved" ? publicFormsCopy.savedStatus : "",
        tone: "",
      }} />
    </PublicFormPanel>
  );
}

function QuestionField({
  answer,
  error,
  onChange,
  question,
}: {
  answer: PublicFormAnswer | undefined;
  error?: string;
  onChange: (answer: PublicFormAnswer) => void;
  question: Question;
}) {
  const requiredLabel = question.required ? publicFormsCopy.requiredSuffix : undefined;
  const common = {
    error,
    help: question.helpText,
    label: question.label,
    requiredLabel,
  };
  if (question.kind === "longText") {
    return (
      <PublicFormQuestion {...common}>
        <TextAreaField
          id={`form-question-${question.questionId}`}
          invalid={Boolean(error)}
          label={question.label}
          maxLength={question.validation.maxLength ?? undefined}
          onChange={(event) => onChange(event.target.value)}
          required={question.required}
          rows={5}
          value={typeof answer === "string" ? answer : ""}
        />
      </PublicFormQuestion>
    );
  }
  if (["shortText", "date", "phone", "email", "url", "number"].includes(
    question.kind
  )) {
    const type = question.kind === "number" ? "number" :
      question.kind === "date" ? "date" :
      question.kind === "email" ? "email" :
      question.kind === "url" ? "url" : "text";
    return (
      <PublicFormQuestion {...common}>
        <TextField
          id={`form-question-${question.questionId}`}
          invalid={Boolean(error)}
          label={question.label}
          max={question.kind === "number" ?
            question.validation.maxNumber ?? undefined :
            question.validation.latestDate ?? undefined}
          maxLength={question.validation.maxLength ?? undefined}
          min={question.kind === "number" ?
            question.validation.minNumber ?? undefined :
            question.validation.earliestDate ?? undefined}
          onChange={(event) => onChange(question.kind === "number" ?
            (event.target.value === "" ? null : event.target.valueAsNumber) :
            event.target.value)}
          required={question.required}
          type={type}
          value={typeof answer === "string" || typeof answer === "number" ?
            answer : ""}
        />
      </PublicFormQuestion>
    );
  }
  if (question.kind === "singleChoice" || question.kind === "multiChoice") {
    const selected = Array.isArray(answer) ? answer :
      typeof answer === "string" ? [answer] : [];
    return (
      <PublicFormQuestion {...common}>
        <PublicFormChoiceList>
          {question.options.map((option) => (
            <ChoiceChip
              key={option.optionId}
              onClick={() => onChange(question.kind === "singleChoice" ?
                option.value : toggleValue(selected, option.value))}
              selected={selected.includes(option.value)}
            >
              {option.label}
            </ChoiceChip>
          ))}
        </PublicFormChoiceList>
      </PublicFormQuestion>
    );
  }
  if (question.kind === "boolean") {
    return (
      <PublicFormQuestion {...common}>
        <PublicFormChoiceList>
          <ChoiceChip onClick={() => onChange(true)} selected={answer === true}>
            {publicFormsCopy.yes}
          </ChoiceChip>
          <ChoiceChip onClick={() => onChange(false)} selected={answer === false}>
            {publicFormsCopy.no}
          </ChoiceChip>
        </PublicFormChoiceList>
      </PublicFormQuestion>
    );
  }
  if (question.kind === "acknowledgement") {
    return (
      <PublicFormQuestion {...common}>
        <CheckboxField
          checked={answer === true}
          onChange={(event) => onChange(event.target.checked)}
        >
          {question.label}
        </CheckboxField>
      </PublicFormQuestion>
    );
  }
  return (
    <PublicFormQuestion {...common}>
      <p>{question.kind === "file" ? publicFormsCopy.fileComingSoon :
        publicFormsCopy.signatureComingSoon}</p>
    </PublicFormQuestion>
  );
}

function ReviewStage({
  controller,
}: {
  controller: ReturnType<typeof usePublicFormController>;
}) {
  const definition = controller.form!.definition;
  const questions = controller.visibleSections.flatMap((section) => section.questions);
  return (
    <PublicFormPanel
      kicker={publicFormsCopy.reviewKicker}
      title={publicFormsCopy.reviewTitle}
      body={publicFormsCopy.reviewBody}
    >
      <PublicFormProgress
        current={controller.visibleSections.length + 1}
        label={publicFormsCopy.stepLabel}
        total={controller.visibleSections.length + 1}
      />
      <PublicFormReview>
        {questions.map((question) => (
          <PublicFormReviewAnswer
            answer={answerSummary(controller.answers[question.questionId]) ||
              publicFormsCopy.unanswered}
            key={question.questionId}
            label={question.label}
          />
        ))}
      </PublicFormReview>
      <PublicFormConsent>
        <h2>{publicFormsCopy.consentHeading}</h2>
        <p>{definition.consent.retentionCopy}</p>
        <CheckboxField
          checked={controller.consentAccepted}
          onChange={(event) => controller.updateConsent(event.target.checked)}
        >
          {definition.consent.consentCopy}
        </CheckboxField>
      </PublicFormConsent>
      <PublicFormActions>
        <Button
          onClick={() => {
            controller.setSectionIndex(controller.visibleSections.length - 1);
            controller.setStage("form");
          }}
          type="button"
          variant="ghost"
        >
          {publicFormsCopy.previous}
        </Button>
        <Button
          loading={controller.pending}
          loadingLabel={publicFormsCopy.submitting}
          onClick={() => void controller.submit()}
          type="button"
        >
          {publicFormsCopy.submit}
        </Button>
      </PublicFormActions>
      <FormStatus status={controller.status} />
    </PublicFormPanel>
  );
}

function toggleValue(values: string[], value: string) {
  return values.includes(value) ? values.filter((item) => item !== value) :
    [...values, value];
}
