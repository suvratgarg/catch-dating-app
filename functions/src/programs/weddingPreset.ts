const MINUTE_MILLIS = 60 * 1000;
const DAY_MILLIS = 24 * 60 * MINUTE_MILLIS;

/**
 * One suggested function in the wedding preset. Times are expressed as a
 * program-local day offset plus minutes after the program-local day start so
 * the preset stays timezone-agnostic; the caller resolves the day anchor.
 */
export interface WeddingPresetFunction {
  key: string;
  name: string;
  dayOffset: number;
  startMinutes: number;
  durationMinutes: number;
  dressCode: string;
  instructions: string | null;
  invitationMode: "allGuests" | "selectedGuests";
  checkInEnabled: boolean;
}

/** Typical multi-day wedding run of events used to seed a new program. */
export const weddingFunctionPresets: ReadonlyArray<WeddingPresetFunction> = [
  {
    key: "mehndi",
    name: "Mehndi",
    dayOffset: 0,
    startMinutes: 11 * 60,
    durationMinutes: 3 * 60,
    dressCode: "Festive ethnic",
    instructions:
      "Henna stations open through the afternoon; lunch is served alongside.",
    invitationMode: "allGuests",
    checkInEnabled: true,
  },
  {
    key: "haldi",
    name: "Haldi",
    dayOffset: 1,
    startMinutes: 10 * 60,
    durationMinutes: 2 * 60,
    dressCode: "Yellow; easy-wash fabrics",
    instructions:
      "Turmeric ceremony is outdoors — avoid dry-clean-only outfits.",
    invitationMode: "allGuests",
    checkInEnabled: true,
  },
  {
    key: "sangeet",
    name: "Sangeet",
    dayOffset: 1,
    startMinutes: 19 * 60,
    durationMinutes: 4 * 60,
    dressCode: "Pastel formal",
    instructions:
      "Shuttles leave the hotel porch at 18:30. " +
      "Dance floor opens after the family performances.",
    invitationMode: "allGuests",
    checkInEnabled: true,
  },
  {
    key: "ceremony",
    name: "Ceremony",
    dayOffset: 2,
    startMinutes: 18 * 60,
    durationMinutes: 4 * 60,
    dressCode: "Traditional formal",
    instructions:
      "Baraat assembles at the gate at 18:00; pheras begin at 19:30.",
    invitationMode: "allGuests",
    checkInEnabled: true,
  },
  {
    key: "reception",
    name: "Reception",
    dayOffset: 3,
    startMinutes: 19 * 60,
    durationMinutes: 4 * 60,
    dressCode: "Evening formal",
    instructions: null,
    invitationMode: "allGuests",
    checkInEnabled: true,
  },
];

/** Capabilities a wedding program should request at creation time. */
export const weddingPresetCapabilities: ReadonlyArray<string> = [
  "arrivalsTransport",
  "accommodation",
  "forms",
  "messaging",
];

export interface MaterializedPresetFunction {
  name: string;
  startsAtMillis: number;
  endsAtMillis: number;
  dressCode: string;
  instructions: string | null;
  invitationMode: "allGuests" | "selectedGuests";
  checkInEnabled: boolean;
}

/**
 * Turns preset specs into concrete function windows anchored at the
 * program-local start of day zero. The caller supplies the anchor (already
 * resolved for the program timezone); the result is deterministic.
 */
export function materializeWeddingPreset(
  dayZeroStartMillis: number,
): MaterializedPresetFunction[] {
  requireMillis(dayZeroStartMillis);
  return weddingFunctionPresets.map((fn) => {
    const startsAtMillis = dayZeroStartMillis +
      fn.dayOffset * DAY_MILLIS + fn.startMinutes * MINUTE_MILLIS;
    return {
      name: fn.name,
      startsAtMillis,
      endsAtMillis: startsAtMillis + fn.durationMinutes * MINUTE_MILLIS,
      dressCode: fn.dressCode,
      instructions: fn.instructions,
      invitationMode: fn.invitationMode,
      checkInEnabled: fn.checkInEnabled,
    };
  });
}

function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Preset anchor must be non-negative safe milliseconds.");
  }
}
