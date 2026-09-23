/** Public, dimension-only protocol. No form state or bearer values cross this boundary. */
export const FORM_RESIZE_TYPE = "catch:form:resize";
export const MIN_EMBED_HEIGHT = 320;
export const MAX_EMBED_HEIGHT = 4000;

export function embedParentOrigin(referrer: string): string | null {
  try {
    const url = new URL(referrer);
    if (url.protocol !== "https:" &&
        !(url.protocol === "http:" && ["localhost", "127.0.0.1"].includes(url.hostname))) {
      return null;
    }
    return url.origin;
  } catch {
    return null;
  }
}

export function resizePayload(embedId: string, height: number) {
  if (!/^[a-zA-Z0-9_-]{1,80}$/u.test(embedId) || !Number.isFinite(height)) return null;
  return {
    type: FORM_RESIZE_TYPE,
    version: 1,
    embedId,
    height: Math.max(MIN_EMBED_HEIGHT, Math.min(MAX_EMBED_HEIGHT, Math.ceil(height))),
  } as const;
}
