import {httpsCallable} from "firebase/functions";
import {functions} from "../../../shared/api/firebaseFunctions";
export interface PartnerLead {
  assignment: {organizerId: string; revision: number; status: "offered" | "accepted";
    nextAction: string; reviewAt: string; expiresAt: string;
    relationshipContext: string | null; channel: string | null};
  organizer: {organizerId: string; name: string; city: string | null; claimState: string};
}
export interface PartnerWorkspace {
  membership: {uid: string; displayName: string; expiresAt: string};
  leads: PartnerLead[];
  submissions: Array<{intentId: string; status: string; name: string; organizerId: string | null}>;
  nextCursor: string | null; sendAuthority: false;
}
export async function readPartnerWorkspace(cursor: string | null): Promise<PartnerWorkspace> {
  return (await httpsCallable<{cursor: string | null}, PartnerWorkspace>(functions,
    "getSalesPartnerWorkspace")({cursor})).data;
}
export async function writePartner(action: "register" | "nominate" | "decide",
  payload: Record<string, unknown>) {
  const name = {register: "registerSalesPartner", nominate: "nominateSalesOrganizer",
    decide: "decideSalesPartnerAssignment"}[action];
  return (await httpsCallable(functions, name)(payload)).data;
}
