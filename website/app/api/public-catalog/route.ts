import {readPublicCatalog} from "../../../src/server/publicCatalog";
export const dynamic = "force-dynamic";
export async function GET() {
  const headers = {"Cache-Control": "private, no-store", "X-Robots-Tag": "noindex"};
  try { return Response.json(await readPublicCatalog(), {headers}); }
  catch { return Response.json({listings: [], unavailable: true}, {status: 503, headers}); }
}
