import {useEffect, useLayoutEffect, useState} from "react";
import {useParams} from "react-router";
import {Button, EventRuntimeActionGrid, EventRuntimeFrame,
  EventRuntimeLoading, EventRuntimeModule, EventRuntimePanel,
  EventRuntimePracticeBanner, EventRuntimeSectionStack, FormStatus,
  TextField} from "../../shared/ui/primitives";
import {websiteSalesDemoAuth, type SalesDemoAuth,
  type SalesDemoPhoneChallenge} from "./salesDemoAuth";
import {grantFromSalesDemoFragment, salesDemoActionTitle,
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

  return <EventRuntimeFrame brandLabel="Catch" brandWord="Catch"
    eventTitle={preview?.preview.brandName}>
    {invalidId || controller.preview.isError ? <EventRuntimePanel
      kicker="Private example" title="This preview is unavailable"
      body="The invitation may have expired or changed. Ask the inviter for a current link.">
      <Button type="button" onClick={() => void controller.preview.refetch()}>
        Try again
      </Button>
    </EventRuntimePanel> : controller.preview.isPending || !preview ?
      <EventRuntimeLoading label="Loading private preview…" /> :
      <EventRuntimePanel kicker="Private workflow preview"
        title={preview.preview.headline} body={preview.preview.scenario}>
        <EventRuntimeSectionStack>
          <EventRuntimePracticeBanner>{preview.notice}</EventRuntimePracticeBanner>
          <EventRuntimeModule title="What you can explore">
            <ol>{preview.preview.steps.map((step, index) =>
              <li key={`${index}-${step}`}>{step}</li>)}</ol>
          </EventRuntimeModule>
          {preview.preview.retainedTools.length ? <EventRuntimeModule
            title="What stays with your current tools">
            <ul>{preview.preview.retainedTools.map((tool) =>
              <li key={tool}>{tool}</li>)}</ul>
          </EventRuntimeModule> : null}
          {preview.preview.limitations.length ? <EventRuntimeModule
            title="Known limits of this example">
            <ul>{preview.preview.limitations.map((limit) =>
              <li key={limit}>{limit}</li>)}</ul>
          </EventRuntimeModule> : null}
          <p>Available until {new Date(preview.expiresAt).toLocaleString()}.</p>
          <p>No real messages, charges, guest admission, organizer ownership,
            or publication occur here.</p>
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
      setAuthError("Google sign-in did not complete. You can try again.");
    } finally {setAuthPending(false);}
  };
  const sendCode = async () => {
    if (authPending || !/^\+[1-9][0-9]{7,14}$/u.test(phone.trim())) return;
    setAuthPending(true); setAuthError("");
    try {setChallenge(await auth.beginPhone(phone.trim(), "sales-demo-recaptcha"));}
    catch {setAuthError("Phone verification could not start. Check the number and try again.");}
    finally {setAuthPending(false);}
  };
  const verifyCode = async () => {
    if (authPending || !challenge || !code.trim()) return;
    setAuthPending(true); setAuthError("");
    try {await challenge.confirm(code.trim()); setCode(""); setPhone("");
      setChallenge(null);} catch {
      setAuthError("That verification code could not be confirmed. Try again.");
    } finally {setAuthPending(false);}
  };
  if (!interactiveAvailable) return <EventRuntimeModule title="Preview only">
    <p>Interactive access has not been enabled for this invitation. Ask the inviter
      to review the intended contact if you want to try the sample workflow.</p>
  </EventRuntimeModule>;
  if (!hasGrant) return <EventRuntimeModule title="Interactive link needed">
    <p>This preview is safe to view, but its interactive grant is missing.
      Open the original invitation link or ask the inviter for a new one.</p>
  </EventRuntimeModule>;
  return <EventRuntimeModule title="Try the sample workflow">
    <p>{cta}</p>
    {!controller.authReady ? <EventRuntimeLoading label="Checking sign-in…" /> :
      <>
      {controller.canTry ? <>
        <p>Signed in as {controller.viewer?.email ||
          controller.viewer?.phoneNumber || "verified account"}.
          The server will check this identity against the invitation.</p>
        <Button type="button" onClick={() => void controller.start()}
          disabled={controller.pending || authPending} loading={controller.pending}
          loadingLabel="Opening sample…">Open interactive example</Button>
      </> : null}
        <p>Use the invited email or verify the invited phone. If you are signed
          in with another account, you can change it below.</p>
        <EventRuntimeActionGrid><Button type="button" onClick={() => void google()}
          disabled={authPending || controller.pending} loading={authPending}>
          {controller.viewer ? "Use another Google account" : "Continue with Google"}
        </Button>
        </EventRuntimeActionGrid>
        <TextField id="sales-demo-phone" label="Or verify phone (international format)"
          type="tel" autoComplete="tel" value={phone}
          disabled={authPending || controller.pending || Boolean(challenge)}
          onChange={(event) => setPhone(event.target.value)}
          placeholder="+91…" />
        <div id="sales-demo-recaptcha" />
        {!challenge ? <Button type="button" variant="ghost"
          disabled={authPending || controller.pending || !/^\+[1-9][0-9]{7,14}$/u.test(phone.trim())}
          onClick={() => void sendCode()}>Send verification code</Button> : <>
          <TextField id="sales-demo-code" label="Verification code" value={code}
            onChange={(event) => setCode(event.target.value)}
            inputMode="numeric" autoComplete="one-time-code" />
          <Button type="button" variant="ghost" disabled={authPending || controller.pending || !code.trim()}
            onClick={() => void verifyCode()}>Verify phone</Button>
          <Button type="button" variant="ghost"
            disabled={authPending || controller.pending}
            onClick={() => {setChallenge(null); setCode(""); setAuthError("");}}>
            Change number or resend code
          </Button>
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
    <EventRuntimeModule title="Your isolated sample">
      <p>Step: {session.step.replaceAll("_", " ")} ·
        {session.status === "completed" ? " Completed" : " In progress"}</p>
      <p>Sample applicant: {session.application.applicantName} ·
        {session.application.request}</p>
      <p>Review: {session.application.review.replaceAll("_", " ")} ·
        Reply: {session.reply.template.replaceAll("_", " ")} ·
        Guest: {session.guest.status.replaceAll("_", " ")}</p>
      <p>Only synthetic records are changed.</p>
    </EventRuntimeModule>
    <EventRuntimeModule title="Next sample step">
      {!controller.fresh ? <p>Check the latest session before continuing.</p> : null}
      <EventRuntimeActionGrid>
        {retry ? <Button type="button" disabled={controller.pending || !controller.fresh}
          onClick={() => act(retry.action, retry.choice)}>
          Retry: {salesDemoActionTitle(retry.action, retry.choice)}
        </Button> : <DemoStepActions session={session} disabled={controller.pending ||
          !controller.fresh} onAction={act} />}
        {available("requestAssistance") && !session.assistanceRequested && !retry ?
          <Button type="button" variant="ghost" disabled={controller.pending ||
            !controller.fresh} onClick={() => act("requestAssistance")}>
            Request help with this demo
          </Button> : null}
        <Button type="button" variant="ghost" disabled={controller.pending}
          onClick={() => void controller.refresh()}>Refresh sample status</Button>
      </EventRuntimeActionGrid>
      {session.assistanceRequested ? <p role="status">Assistance requested.
        This records an in-product request; no message is sent here.</p> : null}
      {session.status === "completed" ? <p role="status">You completed this
        synthetic workflow. A real product setup requires a separate reviewed
        host handoff.</p> : null}
    </EventRuntimeModule>
  </>;
}

function DemoStepActions({session, disabled, onAction}: {
  session: SalesDemoSession; disabled: boolean;
  onAction: (action: SalesDemoAction, choice?: "approve" | "needs_info" |
    "welcome" | "clarify") => void;
}) {
  if (session.step === "application" &&
      session.allowedActions.includes("reviewApplication")) return <>
    <Button type="button" disabled={disabled}
      onClick={() => onAction("reviewApplication", "approve")}>
      Approve sample application
    </Button>
    <Button type="button" variant="ghost" disabled={disabled}
      onClick={() => onAction("reviewApplication", "needs_info")}>
      Ask sample applicant for more information
    </Button>
  </>;
  if (session.step === "reply" && session.allowedActions.includes("prepareReply")) {
    return session.application.review === "needs_info" ? <Button type="button"
      disabled={disabled} onClick={() => onAction("prepareReply", "clarify")}>
      Prepare clarification example
    </Button> : <>
      <Button type="button" disabled={disabled}
        onClick={() => onAction("prepareReply", "welcome")}>
        Prepare welcome example
      </Button>
      <Button type="button" variant="ghost" disabled={disabled}
        onClick={() => onAction("prepareReply", "clarify")}>
        Prepare clarification example
      </Button>
    </>;
  }
  if (session.step === "admission" && session.allowedActions.includes("admitGuest")) {
    return <Button type="button" disabled={disabled}
      onClick={() => onAction("admitGuest")}>Admit sample guest</Button>;
  }
  return <p>No further sample step is available.</p>;
}
