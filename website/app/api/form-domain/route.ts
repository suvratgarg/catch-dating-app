import {forwardWebsiteFunction} from "../../../src/server/functionGateway";
export const dynamic = "force-dynamic";
export async function GET(request: Request) {return forwardWebsiteFunction(request, "resolvePublicFormDomain");}
