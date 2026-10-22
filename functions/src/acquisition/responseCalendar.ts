const HOUR = 60 * 60 * 1000;
const DAY = 24 * HOUR;
const IST_OFFSET = 5.5 * HOUR;
const OPEN = 9 * HOUR;
const CLOSE = 18 * HOUR;

/** Approved 21 Oct 2026: nine working hours, Mon-Sat 09:00-18:00 IST.
 * Sundays alone are excluded; holidays are ordinary working days.
 * Input is the authoritative accepted receipt time, never an email time.
 * This pure deadline helper neither records a response nor authorizes sends.
 */
export function hostResponseDueAt(acceptedAt: number): number | null {
  // Modern application timestamps; reserve headroom for date arithmetic.
  if (!Number.isSafeInteger(acceptedAt) || acceptedAt < 0 ||
      acceptedAt > 8.64e15 - 8 * DAY) return null;
  let local = acceptedAt + IST_OFFSET;
  let remaining = CLOSE - OPEN;
  // At most two working days plus Sunday are needed for this fixed target.
  for (let days = 0; days < 4; days++) {
    const midnight = Math.floor(local / DAY) * DAY;
    const sunday = new Date(midnight).getUTCDay() === 0;
    const start = Math.max(local, midnight + OPEN);
    const end = midnight + CLOSE;
    if (!sunday && start < end) {
      const available = end - start;
      if (remaining <= available) return start + remaining - IST_OFFSET;
      remaining -= available;
    }
    local = midnight + DAY;
  }
  return null;
}
