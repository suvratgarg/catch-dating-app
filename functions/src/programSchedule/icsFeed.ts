import {
  orderFunctions,
  requireMillis,
  type ProgramFunctionLike,
} from "./programTimeline";

export interface IcsFeedFunction extends ProgramFunctionLike {
  venueNotes?: string | null;
}

export interface IcsFeedOptions {
  // Program title published as X-WR-CALNAME.
  programTitle: string;
  functions: ReadonlyArray<IcsFeedFunction>;
  // Epoch milliseconds used for every VEVENT's DTSTAMP.
  generatedAtMillis: number;
}

const PRODID = "-//Catch//Program Schedule//EN";
const MAX_LINE_OCTETS = 75;

export function buildIcsFeed(options: IcsFeedOptions): string {
  const lines: string[] = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    `PRODID:${PRODID}`,
    "CALSCALE:GREGORIAN",
    "METHOD:PUBLISH",
    `X-WR-CALNAME:${escapeText(options.programTitle)}`,
  ];
  const dtstamp = formatUtcDateTime(options.generatedAtMillis);
  for (const fn of orderFunctions(options.functions)) {
    lines.push("BEGIN:VEVENT");
    lines.push(`UID:${fn.functionId}@catch`);
    lines.push(`DTSTAMP:${dtstamp}`);
    lines.push(`DTSTART:${formatUtcDateTime(fn.startsAt)}`);
    lines.push(`DTEND:${formatUtcDateTime(fn.endsAt)}`);
    lines.push(`SUMMARY:${escapeText(fn.name)}`);
    const location = [fn.venueName, fn.venueNotes]
      .filter((value): value is string =>
        value !== undefined && value !== null && value !== "")
      .join(", ");
    if (location !== "") {
      lines.push(`LOCATION:${escapeText(location)}`);
    }
    const description = fn.venueNotes ?
      `${fn.name}\n\n${fn.venueNotes}` : fn.name;
    lines.push(`DESCRIPTION:${escapeText(description)}`);
    lines.push(`SEQUENCE:${fn.revision}`);
    if (fn.status === "cancelled") {
      lines.push("STATUS:CANCELLED");
    }
    lines.push("END:VEVENT");
  }
  lines.push("END:VCALENDAR");
  return `${lines.map(foldLine).join("\r\n")}\r\n`;
}

export function formatUtcDateTime(millis: number): string {
  requireMillis(millis, "millis");
  // toISOString gives 2026-05-01T14:30:00.000Z; the RFC 5545 UTC
  // format drops the separators and the fractional seconds.
  const iso = new Date(millis).toISOString();
  return `${iso.slice(0, 19).replace(/[-:]/g, "")}Z`;
}

export function escapeText(value: string): string {
  // RFC 5545 TEXT escaping: backslash first, then semicolons,
  // commas, and newlines.
  return value
    .replace(/\\/g, "\\\\")
    .replace(/;/g, "\\;")
    .replace(/,/g, "\\,")
    .replace(/\r\n/g, "\\n")
    .replace(/[\r\n]/g, "\\n");
}

export function foldLine(line: string): string {
  // RFC 5545 folds content lines longer than 75 octets with a
  // CRLF followed by a single space.
  const segments: string[] = [];
  let current = "";
  let currentOctets = 0;
  for (const char of line) {
    const octets = utf8OctetLength(char);
    // Continuation segments carry a leading space, leaving 74.
    const limit = segments.length === 0 ?
      MAX_LINE_OCTETS : MAX_LINE_OCTETS - 1;
    if (currentOctets + octets > limit) {
      segments.push(current);
      current = char;
      currentOctets = octets;
    } else {
      current += char;
      currentOctets += octets;
    }
  }
  segments.push(current);
  return segments.join("\r\n ");
}

function utf8OctetLength(char: string): number {
  const codePoint = char.codePointAt(0) ?? 0;
  if (codePoint < 0x80) return 1;
  if (codePoint < 0x800) return 2;
  if (codePoint < 0x10000) return 3;
  return 4;
}
