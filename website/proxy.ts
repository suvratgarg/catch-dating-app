import {productionIndexing} from "./src/server/publicEnvironment";
import {isCatchWebsiteHost, requestHostname} from "./src/app/surfaceHostPolicy";
import {readPublicCatalog} from "./src/server/publicCatalog";
import {availabilityCopy} from "./src/content/availability";
import {NextRequest, NextResponse} from "next/server";
import {retiredMarketingDestination} from "./src/app/retiredMarketingRoutes";

async function handleRequest(request: NextRequest) {
  const url = request.nextUrl;
  const privatePath = /^\/(join|booking|event-update|rehearse|invite|rsvp|f|demo)(\/|$)/.test(url.pathname) ||
    /^\/offer\/?$/.test(url.pathname);
  const asset = /^\/(_next\/|_legacy\/|assets\/|fonts\/|\.well-known\/)/.test(url.pathname) ||
    ["/favicon.png", "/organizer-tracking-runtime.html"].includes(url.pathname);
  const api = url.pathname.startsWith("/api/");
  const hostname = requestHostname(request.headers.get("host"));
  const allowedHost = hostname && (isCatchWebsiteHost(hostname) || hostname === process.env.CATCH_PREVIEW_HOST);
  if ((!allowedHost && !asset && !api) || privatePath) {
    const shell = url.clone(); shell.pathname = "/private-shell"; shell.search = "";
    const response = NextResponse.rewrite(shell);
    response.headers.set("Cache-Control", "private, no-store");
    response.headers.set("X-Robots-Tag", "noindex, nofollow");
    response.headers.set("Referrer-Policy", "no-referrer");
    return response;
  }
  if (!allowedHost && api && url.pathname !== "/api/form-domain") {
    return new NextResponse(null, {status: 404, headers: {"Cache-Control": "no-store"}});
  }
  const destination = retiredMarketingDestination({pathname: url.pathname, search: url.search, hash: ""});
  if (destination) return NextResponse.redirect(new URL(destination, url.origin), 301);
  if (url.pathname === "/" || /^\/(explore|organizers|events|claim)(\/|$)/.test(url.pathname)) {
    try {
      const catalog = await readPublicCatalog();
      const pathname = url.pathname.replace(/\/+$/, "") + "/";
      const aliases = catalog.listings.filter(listing => listing.legacyPaths?.includes(pathname));
      if (!catalog.listings.some(listing => listing.path === pathname) && aliases.length === 1) {
        const canonical = url.clone(); canonical.pathname = aliases[0].path;
        return NextResponse.redirect(canonical, 301);
      }
    } catch {
      return new NextResponse(`<!doctype html><html lang="en"><head><meta name="robots" content="noindex"><title>${availabilityCopy.title}</title></head><body><h1>${availabilityCopy.title}</h1><p>${availabilityCopy.body}</p></body></html>`,
        {status: 503, headers: {"Content-Type": "text/html; charset=utf-8", "Cache-Control": "private, no-store", "Retry-After": "30", "X-Robots-Tag": "noindex"}});
    }
  }
  const response = NextResponse.next();
  if (url.pathname.startsWith("/_legacy/")) {
    response.headers.set("X-Robots-Tag", "noindex, nofollow");
    response.headers.set("Referrer-Policy", "no-referrer");
    if (url.pathname.endsWith(".html")) response.headers.set("Cache-Control", "private, no-store");
  }
  return response;
}
export async function proxy(request: NextRequest) {
  const response = await handleRequest(request);
  if (!productionIndexing()) response.headers.set("X-Robots-Tag", "noindex, nofollow");
  return response;
}
export const config = {matcher: "/:path*"};
