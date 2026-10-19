import {publicCatalogResponse} from "../../../src/server/publicCatalogResponse";
export const dynamic = "force-dynamic";
export async function GET(request: Request) {return publicCatalogResponse(request);}
