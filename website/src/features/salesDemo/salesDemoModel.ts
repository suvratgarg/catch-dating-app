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
}

export function salesDemoApiFromCallable(
  invoke: <Request, Response>(name: "getSalesDemoPreview" | "startSalesDemo" |
    "getSalesDemoSession" | "advanceSalesDemo", input: Request) => Promise<Response>
): SalesDemoApi {
  return {
    preview: (input) => invoke("getSalesDemoPreview", input),
    start: (input) => invoke("startSalesDemo", input),
    getSession: (input) => invoke("getSalesDemoSession", input),
    advance: (input) => invoke("advanceSalesDemo", input),
  };
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
