import {forwardWebsiteFunction} from "../../../src/server/functionGateway";
export const dynamic = "force-dynamic";
export async function POST(request: Request) {return forwardWebsiteFunction(request, "joinWaitlist");}
