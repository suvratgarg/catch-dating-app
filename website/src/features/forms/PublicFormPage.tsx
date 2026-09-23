import {useEffect, useRef} from "react";
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
  PublicFormFileInput,
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
  PublicFormSignatureInput,
  SelectField,
  TextAreaField,
  TextField,
} from "../../shared/ui/primitives";
import {publicFormsCopy, publicFormPaymentStatuses, formFeeLabel,
  formFeePayLabel} from "../../content/forms";
import {
  answerSummary,
  type PublicFormAnswer,
  type PublicFormQuestion as Question,
} from "./publicFormModel";
import {formProfileReviewUrl} from "./formProfileReviewLink";
import {embedParentOrigin, resizePayload} from "./publicFormEmbed";
import {usePublicFormController} from "./usePublicFormController";

export function PublicFormPage() {
  const {publicFormId = ""} = useParams<{publicFormId: string}>();
  const controller = usePublicFormController(publicFormId);
  const frameRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!controller.embed || window.parent === window || !frameRef.current) return;
    const embedId = new URLSearchParams(window.location.search).get("embedId") ?? "";
    const parentOrigin = embedParentOrigin(document.referrer);
    if (!parentOrigin) return;
    const frame = frameRef.current;
    const sendHeight = () => {
      const payload = resizePayload(embedId, frame.getBoundingClientRect().height);
      if (payload) window.parent.postMessage(payload, parentOrigin);
    };
    const observer = new ResizeObserver(sendHeight);
    observer.observe(frame);
    sendHeight();
    return () => observer.disconnect();
  }, [controller.embed]);
  const organizerName = controller.form?.organizer.name;
  const hasProfileFields = controller.form?.definition.sections?.some((section) =>
    section.questions.some((question) => question.answerDestination === "catchProfile" ||
      question.answerDestination === "organizerCard")) ?? false;

  return (
    <div ref={frameRef}><PublicFormFrame
      embed={controller.embed}
      appearance={controller.form?.definition.appearance.preset}
      activityKind={controller.form?.definition.appearance.activityKind}
      logoUrl={controller.form?.organizer.logoUrl}
      organizerName={organizerName}
    >
      <PublicFormStage controller={controller} />
      <PublicFormPrivacy
        brandLabel={publicFormsCopy.brand}
        brandWord={publicFormsCopy.brandWord}
        poweredByLabel={publicFormsCopy.poweredBy}
      >
        {hasProfileFields ? publicFormsCopy.profilePrivacyNote : publicFormsCopy.privacyNote}
      </PublicFormPrivacy>
    </PublicFormFrame></div>
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
        {controller.form ? (
          <PublicFormActions>
            <Button type="button" variant="ghost" onClick={controller.recoverPayment}>
              {publicFormsCopy.paymentRecoveryAction}
            </Button>
          </PublicFormActions>
        ) : null}
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
  if (controller.stage === "payment") {
    return <PaymentStage controller={controller} />;
  }
  if (controller.stage === "complete" && controller.receipt) {
    const completion = controller.receipt.completion;
    const reviewUrl = controller.receipt.profileReviewAvailable === true ?
      formProfileReviewUrl(controller.receipt.responseId) : null;
    return (
      <PublicFormPanel
        kicker={publicFormsCopy.completionKicker}
        title={completion.title}
        body={completion.message}
      >
        {controller.payments?.payment ? (
          <>
            {controller.payments.payment.status === "refunded" ? (
              <FormStatus status={{message: publicFormsCopy.paymentReceiptRefunded, tone: ""}} />
            ) : controller.payments.payment.status === "reviewRequired" ? (
              <FormStatus status={{message: publicFormPaymentStatuses.reviewRequired, tone: ""}} />
            ) : null}
            <FormStatus status={{message: publicFormsCopy.paymentWithdrawNote, tone: ""}} />
          </>
        ) : null}
        {reviewUrl ? (
          <FormStatus status={{message: publicFormsCopy.profileReviewHelp, tone: ""}} />
        ) : null}
        <PublicFormActions>
          {controller.pendingConsentResponseId ===
          controller.receipt.responseId ? (
            <Button
              loading={controller.pending}
              onClick={() => void controller.startConsentPromotion()}
              type="button"
            >
              {publicFormsCopy.messagingVerifyAction}
            </Button>
          ) : null}
          {reviewUrl ? (
            <ButtonLink href={reviewUrl}>
              {publicFormsCopy.profileReviewAction}
            </ButtonLink>
          ) : null}
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
  const permitsPhone = controller.verifyingConsent ||
    controller.recoveringPayment || policy === "phoneVerified" ||
    policy === "emailOrPhoneVerified" || policy === "catchAccount";
  const permitsEmail = !controller.verifyingConsent &&
    !controller.recoveringPayment && (policy === "emailVerified" ||
    policy === "emailOrPhoneVerified" || policy === "catchAccount");
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
      title={controller.recoveringPayment ? publicFormsCopy.paymentRecoveryTitle : publicFormsCopy.identityTitle}
      body={controller.recoveringPayment ? publicFormsCopy.paymentRecoveryBody : publicFormsCopy.identityBody}
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
            onUpload={(files) => controller.uploadAnswer(question, files)}
            question={question}
            upload={controller.uploads[question.questionId]}
          />
        ))}
      </PublicFormSection>
      <PublicFormActions>
        {controller.sectionIndex > 0 ? (
          <Button onClick={controller.previousSection} type="button" variant="ghost">
            {publicFormsCopy.previous}
          </Button>
        ) : null}
        <Button
          disabled={controller.uploadInProgress}
          onClick={() => void controller.nextSection()}
          type="button"
        >
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
  onUpload,
  question,
  upload,
}: {
  answer: PublicFormAnswer | undefined;
  error?: string;
  onChange: (answer: PublicFormAnswer) => void;
  onUpload: (files: Array<{blob: Blob; name: string}>) => Promise<void>;
  question: Question;
  upload?: {status: "uploading" | "ready" | "error"; label: string};
}) {
  const requiredLabel = question.required ? publicFormsCopy.requiredSuffix :
    publicFormsCopy.optionalSuffix;
  const disclosure = question.answerDestination === "catchProfile" ?
    publicFormsCopy.profileFieldDisclosure :
    question.answerDestination === "organizerCard" ?
      publicFormsCopy.organizerCardFieldDisclosure : undefined;
  const common = {
    error,
    help: question.helpText,
    disclosure,
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
  if (question.kind === "singleChoice" && question.options.length > 4) {
    return (
      <PublicFormQuestion {...common}>
        <SelectField
          id={`form-question-${question.questionId}`}
          invalid={Boolean(error)}
          label={question.label}
          onChange={(event) => onChange(event.target.value || null)}
          required={question.required}
          value={typeof answer === "string" ? answer : ""}
        >
          <option value="">{publicFormsCopy.chooseOne}</option>
          {question.options.map((option) => (
            <option key={option.optionId} value={option.value}>{option.label}</option>
          ))}
        </SelectField>
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
          {publicFormsCopy.confirmAcknowledgement}
        </CheckboxField>
      </PublicFormQuestion>
    );
  }
  if (question.kind === "file") {
    const current = Array.isArray(answer) ? answer : [];
    const accepted = question.validation.allowedMimeTypes.length > 0 ?
      question.validation.allowedMimeTypes.join(",") :
      "image/jpeg,image/png,image/webp,application/pdf";
    return (
      <PublicFormQuestion {...common}>
        <PublicFormFileInput
          accept={accepted}
          disabled={upload?.status === "uploading"}
          label={current.length > 0 ?
            publicFormsCopy.replaceFiles : publicFormsCopy.selectFiles}
          multiple={(question.validation.maxFileCount ?? 1) > 1}
          onFiles={(files) => void onUpload(files.map((file) => ({
            blob: file,
            name: file.name,
          })))}
          status={upload?.label ?? (current.length > 0 ?
            publicFormsCopy.uploadedFile : undefined)}
        />
        {current.length > 0 ? (
          <Button onClick={() => onChange([])} type="button" variant="ghost">
            {publicFormsCopy.removeUpload}
          </Button>
        ) : null}
      </PublicFormQuestion>
    );
  }
  return (
    <PublicFormQuestion {...common}>
      <PublicFormSignatureInput
        clearLabel={publicFormsCopy.clearSignature}
        disabled={upload?.status === "uploading"}
        instruction={publicFormsCopy.signatureInstruction}
        onSave={(blob) => onUpload([{blob, name: "signature.png"}])}
        saveLabel={answer ?
          publicFormsCopy.replaceFiles : publicFormsCopy.saveSignature}
        status={upload?.label ?? (answer ?
          publicFormsCopy.signatureReady : undefined)}
        typedNameLabel={publicFormsCopy.typedSignatureLabel}
      />
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
            answer={question.kind === "file" || question.kind === "signature" ?
              (controller.answers[question.questionId] ?
                publicFormsCopy.uploadedAnswer : publicFormsCopy.unanswered) :
              answerSummary(controller.answers[question.questionId]) ||
                publicFormsCopy.unanswered}
            key={question.questionId}
            label={question.label}
          />
        ))}
      </PublicFormReview>
      {definition.payment ? (
        <>
          <PublicFormReview>
            <PublicFormReviewAnswer
              label={definition.payment.description || publicFormsCopy.paymentTitle}
              answer={formFeeLabel(definition.payment.amountPaise)} />
            <PublicFormReviewAnswer label={publicFormsCopy.paymentRefundPolicy}
              answer={definition.payment.refundPolicy} />
          </PublicFormReview>
          <FormStatus status={{message: publicFormsCopy.paymentBody, tone: ""}} />
        </>
      ) : null}
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
      {controller.form?.messagingOffer && (
        controller.form.messagingOffer.organizerWhatsapp ||
        controller.form.messagingOffer.catchWhatsapp ||
        controller.form.messagingOffer.organizerOperationsWhatsapp ||
        controller.form.messagingOffer.organizerMarketingWhatsapp ||
        controller.form.messagingOffer.catchMarketingWhatsapp) ? (
        <PublicFormConsent>
          <h2>{publicFormsCopy.messagingHeading}</h2>
          <p>{controller.form.messagingOffer.termsVersion === "form-whatsapp-v2" ?
            publicFormsCopy.messagingPurposeHelp : publicFormsCopy.messagingHelp}</p>
          {(["organizerWhatsapp", "catchWhatsapp",
            "organizerOperationsWhatsapp", "organizerMarketingWhatsapp",
            "catchMarketingWhatsapp"] as const).map((scope) => {
            const label = controller.form?.messagingOffer?.[scope];
            return label ? <CheckboxField key={scope}
              checked={controller.messagingChoices[scope]}
              onChange={(event) => controller.updateMessagingChoice(scope, event.target.checked)}
            >{label}</CheckboxField> : null;
          })}
        </PublicFormConsent>
      ) : null}
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
          {definition.payment ? publicFormsCopy.paymentContinue : publicFormsCopy.submit}
        </Button>
      </PublicFormActions>
      <FormStatus status={controller.status} />
    </PublicFormPanel>
  );
}

function PaymentStage({controller}: {
  controller: ReturnType<typeof usePublicFormController>;
}) {
  const {payment, pending, pay, refresh, status} = controller.payments;
  const fee = controller.form?.definition.payment;
  return (
    <PublicFormPanel kicker={publicFormsCopy.paymentKicker}
      title={payment ? formFeeLabel(payment.amountPaise) : publicFormsCopy.paymentTitle}
      body={publicFormsCopy.paymentBody}>
      <FormStatus status={{message: payment?.status === "failed" && !payment.checkout ?
        publicFormsCopy.paymentUnavailable : payment ?
        publicFormPaymentStatuses[payment.status] : publicFormsCopy.paymentPreparing,
      tone: ""}} />
      {payment?.mode === "test" ? (
        <FormStatus status={{message: publicFormsCopy.paymentTestMode, tone: ""}} />
      ) : null}
      <PublicFormReview>
        <PublicFormReviewAnswer label={publicFormsCopy.paymentRefundPolicy}
          answer={payment?.refundPolicy ?? fee?.refundPolicy ?? ""} />
      </PublicFormReview>
      <PublicFormActions>
        <Button loading={pending || controller.pending}
          loadingLabel={publicFormsCopy.paymentChecking} type="button" variant="ghost"
          onClick={() => void refresh()}>{publicFormsCopy.paymentCheck}</Button>
        {payment && ["expired", "refunded"].includes(payment.status) ? (
          <Button disabled={pending || controller.pending} type="button" variant="ghost"
            onClick={() => void controller.restartAfterPayment()}>
            {publicFormsCopy.paymentRestart}
          </Button>
        ) : null}
        {payment?.checkout ? (
          <Button loading={pending || controller.pending}
            loadingLabel={publicFormsCopy.paymentChecking} type="button"
            onClick={() => void pay(controller.form?.organizer.name ?? publicFormsCopy.brand)}>
            {formFeePayLabel(payment.amountPaise)}
          </Button>
        ) : null}
      </PublicFormActions>
      <FormStatus status={status} />
      <FormStatus status={controller.status} />
    </PublicFormPanel>
  );
}

function toggleValue(values: string[], value: string) {
  return values.includes(value) ? values.filter((item) => item !== value) :
    [...values, value];
}
