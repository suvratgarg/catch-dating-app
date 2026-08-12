const inviteSessionKey = "catch:event-invite-session:v1";

/** Reads the opaque invitation token without turning URL fields into identity. */
export function eventInviteTokenFromLocation(): string | null {
  if (typeof window === "undefined") return null;
  const token = new URLSearchParams(window.location.search).get("il")?.trim();
  return token && token.length <= 180 ? token : null;
}

/** Returns a browser-session signal used only to deduplicate likely-human opens. */
export function eventInviteSessionId(): string | null {
  if (typeof window === "undefined") return null;
  try {
    const stored = window.sessionStorage.getItem(inviteSessionKey);
    if (stored) return stored;
    const created = typeof crypto.randomUUID === "function" ?
      crypto.randomUUID() : `${Date.now()}-${Math.random()}`;
    window.sessionStorage.setItem(inviteSessionKey, created);
    return created;
  } catch {
    return null;
  }
}
