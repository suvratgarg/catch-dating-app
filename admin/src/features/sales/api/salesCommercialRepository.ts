import {httpsCallable} from "firebase/functions";
import {functions} from "../../../shared/api/firebaseFunctions";
import {dataMode} from "../../../shared/api/dataMode";
import type {CommercialDecisionInput, CommercialDetail, CommercialPilotInput,
  CommercialQuoteInput, CommercialReport} from "./salesCommercialTypes";

function call<Request, Response>(name: string, payload: Request): Promise<Response> {
  return httpsCallable<Request, Response>(functions, name)(payload).then(
    (result) => result.data
  );
}
function liveOnly(): void {
  if (dataMode() === "sample") {
    throw new Error("Commercial approvals are available only with live Sales records.");
  }
}
export async function getCommercialDetail(organizerId: string,
  opportunityId: string): Promise<CommercialDetail> {
  liveOnly();
  return call("adminGetSalesCommercialDetail", {organizerId, opportunityId});
}
export async function listCommercialReport(organizerId: string,
  cursor?: string): Promise<CommercialReport> {
  liveOnly();
  return call("adminListSalesCommercialReport", {organizerId, cursor, limit: 25});
}
export async function upsertCommercialPilot(input: CommercialPilotInput):
Promise<{pilotPlan: CommercialDetail["pilotPlan"]}> {
  liveOnly();
  return call("adminUpsertSalesPilotPlan", input);
}
export async function reviseCommercialQuote(input: CommercialQuoteInput):
Promise<{quote: CommercialDetail["quote"]}> {
  liveOnly();
  return call("adminReviseSalesQuote", input);
}
export async function approveCommercialQuote(input: CommercialDecisionInput):
Promise<{quote: CommercialDetail["quote"]}> {
  liveOnly();
  return call("adminApproveSalesQuote", input);
}
export async function acceptCommercialQuote(input: CommercialDecisionInput):
Promise<{quote: CommercialDetail["quote"]}> {
  liveOnly();
  return call("adminAcceptSalesQuote", input);
}
