import {httpsCallable} from "firebase/functions";
import {functions} from "../../../shared/api/firebaseFunctions";
import {parsePartnerWorkspace} from "./partnerWorkspaceResponse";
export interface PartnerLead {
  assignment: {organizerId: string; revision: number; status: "offered" | "accepted";
    nextAction: string; reviewAt: string; expiresAt: string;
    relationshipContext: string | null; channel: string | null};
  organizer: {organizerId: string; name: string; city: string | null; claimState: string};
}
export interface PartnerWorkspace {
  membership: {uid: string; displayName: string; termsVersion: "referral-preview-v1"; expiresAt: string};
  leads: PartnerLead[];
  submissions: Array<{intentId: string; status: string; name: string; organizerId: string | null}>;
  nextCursor: string | null; sendAuthority: false;
}
export async function readPartnerWorkspace(cursor: string | null, actorUid: string): Promise<PartnerWorkspace> {
  const response = await httpsCallable<{cursor: string | null}, unknown>(functions,
    "getSalesPartnerWorkspace")({cursor});
  const workspace = parsePartnerWorkspace(response.data);
  if (workspace.membership.uid !== actorUid) throw new Error("Partner identity changed. Sign in again.");
  return workspace;
}
export async function writePartner(action: "register" | "nominate" | "decide" | "update",
  payload: Record<string, unknown>) {
  const name = {register: "registerSalesPartner", nominate: "nominateSalesOrganizer",
    decide: "decideSalesPartnerAssignment", update: "updateSalesPartnerAssignment"}[action];
  return (await httpsCallable(functions, name)(payload)).data;
}
