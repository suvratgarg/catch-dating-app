export type SalesDemoAction = "reviewApplication" | "prepareReply" |
  "admitGuest" | "requestAssistance";

export interface SalesDemoPreview {
  schemaVersion: 1;
  invitationId: string;
  synthetic: true;
  preview: {
    brandName: string;
    headline: string;
    scenario: string;
    steps: string[];
    retainedTools: string[];
    limitations: string[];
    cta: string;
  };
  interactiveAvailable: boolean;
  expiresAt: string;
  notice: string;
}

export interface SalesDemoSession {
  schemaVersion: 1;
  synthetic: true;
  sessionId: string;
  invitationId: string;
  blueprintId: string;
  blueprintRevision: number;
  createdAt: string;
  expiresAt: string;
  status: "active" | "completed";
  allowedActions: SalesDemoAction[];
  revision: number;
  actionCount: number;
  step: "application" | "reply" | "admission" | "complete";
  application: {applicantName: string; request: string;
    review: "pending" | "approved" | "needs_info"};
  reply: {status: "none" | "prepared";
    template: "none" | "welcome" | "clarify"};
  guest: {status: "not_admitted" | "admitted"; displayName: string};
  assistanceRequested: boolean;
}

export type SalesDemoSetupPlan = {mode: "manual"; requirements: string[]} |
  {mode: "template"; requirements: string[]; templateId: string;
    templateVersion: number; templateHash: string;
    materializerVersion: 1; title: string};
export interface SalesDemoSetup {
  schemaVersion: 1;
  setupHash: string;
  plan: SalesDemoSetupPlan;
  organizerId: string | null;
  formId: string | null;
  editorPath: string | null;
  publicationAuthority: false;
  status: "manual_setup" | "claim_required" | "ready" | "prepared";
}

export interface SalesDemoApi {
  preview(input: {invitationId: string}): Promise<SalesDemoPreview>;
  start(input: {invitationId: string; grantToken: string;
    requestId: string}): Promise<SalesDemoSession>;
  getSession(input: {sessionId: string; grantToken: string}):
    Promise<SalesDemoSession>;
  advance(input: {sessionId: string; grantToken: string;
    requestId: string; expectedRevision: number; action: SalesDemoAction;
    choice?: "approve" | "needs_info" | "welcome" | "clarify"}):
    Promise<SalesDemoSession>;
  getSetup(input: {sessionId: string; grantToken: string}):
    Promise<SalesDemoSetup>;
  prepareSetup(input: {sessionId: string; grantToken: string;
    setupHash: string}): Promise<SalesDemoSetup>;
}

export function salesDemoApiFromCallable(
  invoke: <Request, Response>(name: "getSalesDemoPreview" | "startSalesDemo" |
    "getSalesDemoSession" | "advanceSalesDemo", input: Request) => Promise<Response>
): SalesDemoApi {
  // The website Firebase adapter is widened by the route owner at integration.
  const setupInvoke = invoke as unknown as <Request, Response>(name: "getSalesDemoSetup" |
    "prepareSalesDemoFormDraft", input: Request) => Promise<Response>;
  return {
    preview: (input) => invoke("getSalesDemoPreview", input),
    start: (input) => invoke("startSalesDemo", input),
    getSession: (input) => invoke("getSalesDemoSession", input),
    advance: (input) => invoke("advanceSalesDemo", input),
    getSetup: (input) => setupInvoke("getSalesDemoSetup", input),
    prepareSetup: (input) => setupInvoke("prepareSalesDemoFormDraft", input),
  };
}

/** The Forms editor is a Flutter route on the consumer/Host origin. */
export function salesDemoFormEditorUrl(editorPath: string | null): string | null {
  if (!editorPath || !/^\/host\/audience\/forms\/[A-Za-z0-9_-]+$/u
    .test(editorPath)) return null;
  const configured = import.meta.env.VITE_CONSUMER_APP_URL;
  const origin = configured || (import.meta.env.VITE_FIREBASE_PROJECT_ID ===
    "catch-dating-app-64e51" ? "https://app.catchdates.com" : null);
  if (!origin) return null;
  try {
    const url = new URL(origin);
    const local = url.protocol === "http:" &&
      ["localhost", "127.0.0.1", "[::1]"].includes(url.hostname);
    if ((url.protocol !== "https:" && !local) || url.username || url.password ||
        url.pathname !== "/" || url.search || url.hash) return null;
    url.hash = editorPath;
    return url.toString();
  } catch {return null;}
}

export function grantFromSalesDemoFragment(hash: string): string | null {
  if (!hash.startsWith("#")) return null;
  const parameters = new URLSearchParams(hash.slice(1));
  const grant = parameters.get("grant");
  return grant && /^[A-Za-z0-9_-]{43}$/u.test(grant) ? grant : null;
}

export function salesDemoActionTitle(action: SalesDemoAction,
  choice?: string): string {
  if (action === "reviewApplication") return choice === "approve" ?
    "Approve sample application" : "Ask sample applicant for more information";
  if (action === "prepareReply") return choice === "welcome" ?
    "Prepare welcome example" : "Prepare clarification example";
  if (action === "admitGuest") return "Admit sample guest";
  return "Request help with this demo";
}
