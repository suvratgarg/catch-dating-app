import {NextRequest, NextResponse} from "next/server";
import {retiredMarketingDestination} from "./src/app/retiredMarketingRoutes";

function catchHost(host: string) {
  return ["catchdates.com", "www.catchdates.com", "localhost", "127.0.0.1", "[::1]"].includes(host) ||
    /^(catchdates-dev|catchdates-staging|catch-dating-app-64e51)(--[a-z0-9-]+)?\.(web\.app|firebaseapp\.com)$/.test(host) ||
    (process.env.CATCH_PREVIEW_HOST && host === process.env.CATCH_PREVIEW_HOST);
}
export function proxy(request: NextRequest) {
  const url = request.nextUrl;
  const privatePath = /^\/(join|booking|event-update|rehearse|invite|rsvp|f|demo)(\/|$)/.test(url.pathname) ||
    /^\/offer\/?$/.test(url.pathname);
  const asset = /^\/(_next\/|_legacy\/|assets\/|fonts\/|\.well-known\/)/.test(url.pathname) ||
    ["/favicon.png", "/organizer-tracking-runtime.html"].includes(url.pathname);
  const api = url.pathname.startsWith("/api/");
  const allowedHost = catchHost(url.hostname.toLowerCase());
  if ((!allowedHost && !asset && !api) || privatePath) {
    const shell = url.clone(); shell.pathname = "/_legacy/index.html"; shell.search = "";
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
  const response = NextResponse.next();
  if (url.pathname.startsWith("/_legacy/")) {
    response.headers.set("X-Robots-Tag", "noindex, nofollow");
    response.headers.set("Referrer-Policy", "no-referrer");
    if (url.pathname.endsWith(".html")) response.headers.set("Cache-Control", "private, no-store");
  }
  return response;
}
export const config = {matcher: "/:path*"};
