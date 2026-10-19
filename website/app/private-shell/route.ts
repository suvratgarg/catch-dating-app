import {readFile} from "node:fs/promises";
import path from "node:path";
import {privateShellHead} from "../../src/server/privateShellMetadata";
export const dynamic = "force-dynamic";
export async function GET(request: Request) {
  const headers = {"Content-Type": "text/html; charset=utf-8", "Cache-Control": "private, no-store",
    "X-Robots-Tag": "noindex, nofollow", "Referrer-Policy": "no-referrer"};
  try {
    const html = await readFile(path.join(process.cwd(), "public/_legacy/index.html"), "utf8");
    return new Response(html.replace("<title>Catch</title>", privateShellHead(new URL(request.url).searchParams.get("surface"))), {headers});
  } catch {return new Response(null, {status: 503, headers});}
}
