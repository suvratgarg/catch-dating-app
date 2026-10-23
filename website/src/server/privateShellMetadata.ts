import {pageMeta} from "../app/pageMeta";

const families = {
  join: "event_runtime", booking: "event_booking", offer: "event_offer",
  "event-update": "event_assistance", rehearse: "event_rehearsal", invite: "event_invite",
  rsvp: "household_rsvp", f: "public_form", demo: "sales_demo",
} as const;

/** Only a public route-family enum enters the rewrite; never the credential URL. */
export function privateShellFamily(pathname: string): keyof typeof families | null {
  const first = pathname.split("/")[1];
  if (!Object.hasOwn(families, first) || (first === "offer" && !/^\/offer\/?$/.test(pathname))) return null;
  return first as keyof typeof families;
}

/** The shell is the terminal rewrite target and holds no credential. */
export function isPrivateShellPath(pathname: string): boolean {
  return pathname.replace(/\/+$/, "") === "/private-shell";
}

export function privateShellHead(family: string | null): string {
  if (!family || !Object.hasOwn(families, family)) return "<title>Catch</title>";
  const meta = pageMeta[families[family as keyof typeof families]];
  const escape = (value: string) => value.replace(/[&<>"']/g, character => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  })[character]!);
  return `<title>${escape(meta.title)}</title><meta name="description" content="${escape(meta.description)}"><link rel="canonical" href="https://catchdates.com${escape(meta.canonicalPath)}">`;
}
