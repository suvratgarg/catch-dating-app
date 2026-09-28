import {salesDemoCopy} from "../../content/salesDemo";
import {useEffect, useLayoutEffect, useState} from "react";
import {useParams} from "react-router";
import {Button, ButtonLink, EventRuntimeActionGrid, EventRuntimeFrame,
  EventRuntimeLoading, EventRuntimeModule, EventRuntimePanel,
  EventRuntimePracticeBanner, EventRuntimeSectionStack, FormStatus,
  TextField} from "../../shared/ui/primitives";
import {websiteSalesDemoAuth, type SalesDemoAuth,
  type SalesDemoPhoneChallenge} from "./salesDemoAuth";
import {grantFromSalesDemoFragment, salesDemoActionTitle,
  salesDemoFormEditorUrl,
  type SalesDemoAction, type SalesDemoApi, type SalesDemoSession} from
  "./salesDemoModel";
import {useSalesDemoController} from "./useSalesDemoController";

export function SalesDemoPage({api, auth = websiteSalesDemoAuth}: {
  api: SalesDemoApi; auth?: SalesDemoAuth;
}) {
  const {invitationId = ""} = useParams<{invitationId: string}>();
  return <SalesDemoInvitation key={invitationId} invitationId={invitationId}
    api={api} auth={auth} />;
}

function SalesDemoInvitation({invitationId, api, auth}: {
  invitationId: string; api: SalesDemoApi; auth: SalesDemoAuth;
}) {
  const [grantToken] = useState(() => grantFromSalesDemoFragment(
    window.location.hash));
  useLayoutEffect(() => {
    const search = new URLSearchParams(window.location.search);
    const unsafeQuery = ["grant", "grantToken", "token"].some((key) =>
      search.has(key));
    search.delete("grant"); search.delete("grantToken"); search.delete("token");
    if (window.location.hash || unsafeQuery) window.history.replaceState(null, "",
      `${window.location.pathname}${search.size ? `?${search.toString()}` : ""}`);
  }, []);
  const controller = useSalesDemoController({invitationId, grantToken, api, auth});
  const preview = controller.preview.data;
  const invalidId = !/^[A-Za-z0-9_-]{3,128}$/u.test(invitationId);

  return <EventRuntimeFrame brandLabel={salesDemoCopy.catch} brandWord={salesDemoCopy.catch}
    eventTitle={preview?.preview.brandName}>
    {invalidId || controller.preview.isError ? <EventRuntimePanel
      kicker={salesDemoCopy.privateExample} title={salesDemoCopy.thisPreviewIsUnavailable}
      body={salesDemoCopy.theInvitationMayHaveExpiredOr}>
      <Button type="button" onClick={() => void controller.preview.refetch()}>{salesDemoCopy.tryAgain}</Button>
    </EventRuntimePanel> : controller.preview.isPending || !preview ?
      <EventRuntimeLoading label={salesDemoCopy.loadingPrivatePreview} /> :
      <EventRuntimePanel kicker={salesDemoCopy.privateWorkflowPreview}
        title={preview.preview.headline} body={preview.preview.scenario}>
        <EventRuntimeSectionStack>
          <EventRuntimePracticeBanner>{preview.notice}</EventRuntimePracticeBanner>
          <EventRuntimeModule title={salesDemoCopy.whatYouCanExplore}>
            <ol>{preview.preview.steps.map((step, index) =>
              <li key={`${index}-${step}`}>{step}</li>)}</ol>
          </EventRuntimeModule>
          {preview.preview.retainedTools.length ? <EventRuntimeModule
            title={salesDemoCopy.whatStaysWithYourCurrentTools}>
            <ul>{preview.preview.retainedTools.map((tool) =>
              <li key={tool}>{tool}</li>)}</ul>
          </EventRuntimeModule> : null}
          {preview.preview.limitations.length ? <EventRuntimeModule
            title={salesDemoCopy.knownLimitsOfThisExample}>
            <ul>{preview.preview.limitations.map((limit) =>
              <li key={limit}>{limit}</li>)}</ul>
          </EventRuntimeModule> : null}
          <p>{salesDemoCopy.availableUntil}{" "}{new Date(preview.expiresAt).toLocaleString()}.</p>
          <p>{salesDemoCopy.noRealMessagesChargesGuestAdmission}</p>
          {controller.notice ? <FormStatus status={{message: controller.notice,
            tone: "is-error"}} /> : null}
          {controller.session ? <DemoSessionView controller={controller} /> :
            <DemoAccessView controller={controller} auth={auth}
              hasGrant={Boolean(grantToken)} cta={preview.preview.cta}
              interactiveAvailable={preview.interactiveAvailable} />}
        </EventRuntimeSectionStack>
      </EventRuntimePanel>}
  </EventRuntimeFrame>;
}

type Controller = ReturnType<typeof useSalesDemoController>;

function DemoAccessView({controller, auth, hasGrant, cta, interactiveAvailable}: {
  controller: Controller; auth: SalesDemoAuth; hasGrant: boolean;
  cta: string; interactiveAvailable: boolean;
}) {
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [challenge, setChallenge] = useState<SalesDemoPhoneChallenge | null>(null);
  const [authError, setAuthError] = useState("");
  const [authPending, setAuthPending] = useState(false);
  useEffect(() => () => challenge?.clear(), [challenge]);
  const google = async () => {
    if (authPending) return;
    setAuthPending(true); setAuthError("");
    try {await auth.signInGoogle();} catch {
      setAuthError(salesDemoCopy.googleSigninDidNotCompleteYou);
    } finally {setAuthPending(false);}
  };
  const sendCode = async () => {
    if (authPending || !/^\+[1-9][0-9]{7,14}$/u.test(phone.trim())) return;
    setAuthPending(true); setAuthError("");
    try {setChallenge(await auth.beginPhone(phone.trim(), "sales-demo-recaptcha"));}
    catch {setAuthError(salesDemoCopy.phoneVerificationCouldNotStartCheck);}
    finally {setAuthPending(false);}
  };
  const verifyCode = async () => {
    if (authPending || !challenge || !code.trim()) return;
    setAuthPending(true); setAuthError("");
    try {await challenge.confirm(code.trim()); setCode(""); setPhone("");
      setChallenge(null);} catch {
      setAuthError(salesDemoCopy.thatVerificationCodeCouldNotBe);
    } finally {setAuthPending(false);}
  };
  if (!interactiveAvailable) return <EventRuntimeModule title={salesDemoCopy.previewOnly}>
    <p>{salesDemoCopy.interactiveAccessHasNotBeenEnabled}</p>
  </EventRuntimeModule>;
  if (!hasGrant) return <EventRuntimeModule title={salesDemoCopy.interactiveLinkNeeded}>
    <p>{salesDemoCopy.thisPreviewIsSafeToView}</p>
  </EventRuntimeModule>;
  return <EventRuntimeModule title={salesDemoCopy.tryTheSampleWorkflow}>
    <p>{cta}</p>
    {!controller.authReady ? <EventRuntimeLoading label={salesDemoCopy.checkingSignin} /> :
      <>
      {controller.canTry ? <>
        <p>{salesDemoCopy.signedInAs}{" "}{controller.viewer?.email ||
          controller.viewer?.phoneNumber || "verified account"}{salesDemoCopy.theServerWillCheckThisIdentity}</p>
        <Button type="button" onClick={() => void controller.start()}
          disabled={controller.pending || authPending} loading={controller.pending}
          loadingLabel={salesDemoCopy.openingSample}>{salesDemoCopy.openInteractiveExample}</Button>
      </> : null}
        <p>{salesDemoCopy.useTheInvitedEmailOrVerify}</p>
        <EventRuntimeActionGrid><Button type="button" onClick={() => void google()}
          disabled={authPending || controller.pending} loading={authPending}>
          {controller.viewer ? "Use another Google account" : "Continue with Google"}
        </Button>
        </EventRuntimeActionGrid>
        <TextField id="sales-demo-phone" label={salesDemoCopy.orVerifyPhoneInternationalFormat}
          type="tel" autoComplete="tel" value={phone}
          disabled={authPending || controller.pending || Boolean(challenge)}
          onChange={(event) => setPhone(event.target.value)}
          placeholder={salesDemoCopy.phonePlaceholder} />
        <div id="sales-demo-recaptcha" />
        {!challenge ? <Button type="button" variant="ghost"
          disabled={authPending || controller.pending || !/^\+[1-9][0-9]{7,14}$/u.test(phone.trim())}
          onClick={() => void sendCode()}>{salesDemoCopy.sendVerificationCode}</Button> : <>
          <TextField id="sales-demo-code" label={salesDemoCopy.verificationCode} value={code}
            onChange={(event) => setCode(event.target.value)}
            inputMode="numeric" autoComplete="one-time-code" />
          <Button type="button" variant="ghost" disabled={authPending || controller.pending || !code.trim()}
            onClick={() => void verifyCode()}>{salesDemoCopy.verifyPhone}</Button>
          <Button type="button" variant="ghost"
            disabled={authPending || controller.pending}
            onClick={() => {setChallenge(null); setCode(""); setAuthError("");}}>{salesDemoCopy.changeNumberOrResendCode}</Button>
        </>}
      </>}
    {authError ? <FormStatus status={{message: authError, tone: "is-error"}} /> : null}
  </EventRuntimeModule>;
}

function DemoSessionView({controller}: {controller: Controller}) {
  const session = controller.session!;
  const retry = controller.retryAction;
  const available = (action: SalesDemoAction) => session.allowedActions.includes(action);
  const act = (action: SalesDemoAction, choice?: "approve" | "needs_info" |
    "welcome" | "clarify") => void controller.advance({action, choice});
  return <>
    <EventRuntimeModule title={salesDemoCopy.yourIsolatedSample}>
      <p>{salesDemoCopy.step}{" "}{session.step.replaceAll("_", " ")} ·
        {session.status === "completed" ? " Completed" : " In progress"}</p>
      <p>{salesDemoCopy.sampleApplicant}{" "}{session.application.applicantName} ·
        {session.application.request}</p>
      <p>{salesDemoCopy.review}{" "}{session.application.review.replaceAll("_", " ")}{salesDemoCopy.reply}{" "}{session.reply.template.replaceAll("_", " ")}{salesDemoCopy.guest}{" "}{session.guest.status.replaceAll("_", " ")}</p>
      <p>{salesDemoCopy.onlySyntheticRecordsAreChanged}</p>
    </EventRuntimeModule>
    <EventRuntimeModule title={salesDemoCopy.nextSampleStep}>
      {!controller.fresh ? <p>{salesDemoCopy.checkTheLatestSessionBeforeContinuing}</p> : null}
      <EventRuntimeActionGrid>
        {retry ? <Button type="button" disabled={controller.pending || !controller.fresh}
          onClick={() => act(retry.action, retry.choice)}>{salesDemoCopy.retry}{" "}{salesDemoActionTitle(retry.action, retry.choice)}
        </Button> : <DemoStepActions session={session} disabled={controller.pending ||
          !controller.fresh} onAction={act} />}
        {available("requestAssistance") && !session.assistanceRequested && !retry ?
          <Button type="button" variant="ghost" disabled={controller.pending ||
            !controller.fresh} onClick={() => act("requestAssistance")}>{salesDemoCopy.requestHelpWithThisDemo}</Button> : null}
        <Button type="button" variant="ghost" disabled={controller.pending}
          onClick={() => void controller.refresh()}>{salesDemoCopy.refreshSampleStatus}</Button>
      </EventRuntimeActionGrid>
      {session.assistanceRequested ? <p role="status">{salesDemoCopy.assistanceRequestedThisRecordsAnInproduct}</p> : null}
      {session.status === "completed" ? <p role="status">{salesDemoCopy.youCompletedThisSyntheticWorkflowA}</p> : null}
    </EventRuntimeModule>
    {session.status === "completed" ? <DemoSetupView controller={controller} /> : null}
  </>;
}

function DemoSetupView({controller}: {controller: Controller}) {
  const [confirm, setConfirm] = useState(false);
  const setup = controller.setup;
  const editorUrl = salesDemoFormEditorUrl(setup?.editorPath ?? null);
  return <EventRuntimeModule title={salesDemoCopy.realSetupHandoff}>
    <p>{salesDemoCopy.realSetupIsSeparate}</p>
    {!setup || !controller.setupFresh ? <Button type="button"
      disabled={controller.pending || !controller.fresh}
      onClick={() => {setConfirm(false); void controller.readSetup();}}>
      {salesDemoCopy.reviewSetupOptions}</Button> : null}
    {controller.setupNotice ? <FormStatus status={{message: controller.setupNotice,
      tone: "is-error"}} /> : null}
    {setup && controller.setupFresh ? <>
      <p>{setup.plan.mode === "template" ?
        `${salesDemoCopy.reviewedTemplate}: ${setup.plan.title}` :
        salesDemoCopy.manualHandoff}</p>
      <ul>{setup.plan.requirements.map((step, index) =>
        <li key={`${index}-${step}`}>{step}</li>)}</ul>
      {setup.status === "manual_setup" ? <p>{salesDemoCopy.manualSetupNeeded}</p> : null}
      {setup.status === "claim_required" ? <>
        <p>{salesDemoCopy.claimRequiredForDraft}</p>
        <ButtonLink href="/claim/">{salesDemoCopy.openClaimSetup}</ButtonLink>
      </> : null}
      {setup.status === "ready" ? <>
        <p>{salesDemoCopy.templateDraftNotPublished}</p>
        {!confirm ? <Button type="button" disabled={controller.pending}
          onClick={() => setConfirm(true)}>{salesDemoCopy.prepareTemplateDraft}</Button> :
          <EventRuntimeActionGrid>
            <Button type="button" disabled={controller.pending ||
              !controller.fresh || !controller.setupFresh}
              onClick={() => {setConfirm(false); void controller.prepareSetup();}}>
              {salesDemoCopy.confirmPrepareTemplateDraft}</Button>
            <Button type="button" variant="ghost" disabled={controller.pending}
              onClick={() => setConfirm(false)}>{salesDemoCopy.cancel}</Button>
          </EventRuntimeActionGrid>}
      </> : null}
      {setup.status === "prepared" ? <>
        <p role="status">{salesDemoCopy.draftPrepared}</p>
        {editorUrl ? <ButtonLink href={editorUrl}>{salesDemoCopy.finishInForms}</ButtonLink> :
          <p>{salesDemoCopy.hostAppLinkUnavailable}</p>}
      </> : null}
      <Button type="button" variant="ghost" disabled={controller.pending}
        onClick={() => {setConfirm(false); void controller.readSetup();}}>
        {salesDemoCopy.refreshSetup}</Button>
    </> : null}
  </EventRuntimeModule>;
}

function DemoStepActions({session, disabled, onAction}: {
  session: SalesDemoSession; disabled: boolean;
  onAction: (action: SalesDemoAction, choice?: "approve" | "needs_info" |
    "welcome" | "clarify") => void;
}) {
  if (session.step === "application" &&
      session.allowedActions.includes("reviewApplication")) return <>
    <Button type="button" disabled={disabled}
      onClick={() => onAction("reviewApplication", "approve")}>{salesDemoCopy.approveSampleApplication}</Button>
    <Button type="button" variant="ghost" disabled={disabled}
      onClick={() => onAction("reviewApplication", "needs_info")}>{salesDemoCopy.askSampleApplicantForMoreInformation}</Button>
  </>;
  if (session.step === "reply" && session.allowedActions.includes("prepareReply")) {
    return session.application.review === "needs_info" ? <Button type="button"
      disabled={disabled} onClick={() => onAction("prepareReply", "clarify")}>{salesDemoCopy.prepareClarificationExample}</Button> : <>
      <Button type="button" disabled={disabled}
        onClick={() => onAction("prepareReply", "welcome")}>{salesDemoCopy.prepareWelcomeExample}</Button>
      <Button type="button" variant="ghost" disabled={disabled}
        onClick={() => onAction("prepareReply", "clarify")}>{salesDemoCopy.prepareClarificationExample}</Button>
    </>;
  }
  if (session.step === "admission" && session.allowedActions.includes("admitGuest")) {
    return <Button type="button" disabled={disabled}
      onClick={() => onAction("admitGuest")}>{salesDemoCopy.admitSampleGuest}</Button>;
  }
  return <p>{salesDemoCopy.noFurtherSampleStepIsAvailable}</p>;
}
