import "server-only";
/** Existing HTTP Functions only. Callables continue through the Firebase client. */
export async function forwardWebsiteFunction(request: Request, name: "joinWaitlist" | "resolvePublicFormDomain") {
  const headers = {"Cache-Control": "private, no-store", "X-Robots-Tag": "noindex, nofollow"};
  const project = process.env.CATCH_PUBLIC_FIRESTORE_PROJECT;
  if (!project || !/^[a-z][a-z0-9-]{4,62}$/.test(project)) return new Response(null, {status: 503, headers});
  const source = new URL(request.url);
  const target = new URL(`https://asia-south1-${project}.cloudfunctions.net/${name}`);
  if (name === "resolvePublicFormDomain") target.searchParams.set("hostname", source.searchParams.get("hostname") ?? "");
  try {
    const body = request.method === "POST" ? await request.text() : undefined;
    if (body && Buffer.byteLength(body) > 32_768) return new Response(null, {status: 413, headers});
    const forwarded = new Headers();
    for (const key of ["content-type", "x-firebase-appcheck", "origin"]) {
      const value = request.headers.get(key); if (value) forwarded.set(key, value);
    }
    const response = await fetch(target, {method: request.method, headers: forwarded, body,
      cache: "no-store", redirect: "error", signal: AbortSignal.timeout(15_000)});
    return new Response(response.body, {status: response.status, headers: {
      ...headers, "Content-Type": response.headers.get("content-type") ?? "application/json",
    }});
  } catch {return new Response(null, {status: 503, headers});}
}
