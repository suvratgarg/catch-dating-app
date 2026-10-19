export function isCatchWebsiteHost(hostname: string): boolean {
  const firebaseSite = hostname.match(
    /^([a-z0-9-]+)\.(?:web\.app|firebaseapp\.com)$/u)?.[1];
  const knownSite = firebaseSite === "catchdates-dev" ||
    firebaseSite === "catchdates-staging" ||
    firebaseSite === "catch-dating-app-64e51" ||
    /^(?:catchdates-dev|catchdates-staging|catch-dating-app-64e51)--[a-z0-9-]+$/u
      .test(firebaseSite ?? "");
  return hostname === "catchdates.com" || hostname === "www.catchdates.com" ||
    hostname === "localhost" || hostname === "127.0.0.1" ||
    hostname === "[::1]" || knownSite;
}

/** Parse only a Host authority. Never trust Next's listen-host URL or forwarded input. */
export function requestHostname(authority: string | null): string | null {
  if (!authority || /[\s/@?#\\]/.test(authority)) return null;
  try {
    const url = new URL(`http://${authority}`);
    return url.hostname.toLowerCase();
  } catch {return null;}
}
