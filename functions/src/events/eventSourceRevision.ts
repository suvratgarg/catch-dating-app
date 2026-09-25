/**
 * A stable event source revision for offer review and admission.
 * Progressive events own an explicit revision. Older published events use the
 * actual Firestore document update time, not an optional field in their data.
 */
export function eventSourceRevision(
  event: {setupRevision?: unknown},
  snapshot: Pick<FirebaseFirestore.DocumentSnapshot, "updateTime">,
): number | null {
  if (Object.prototype.hasOwnProperty.call(event, "setupRevision")) {
    const revision = event.setupRevision;
    return Number.isSafeInteger(revision) && (revision as number) > 0 ?
      revision as number : null;
  }
  const stamp = snapshot.updateTime;
  const seconds = stamp?.seconds;
  const nanoseconds = stamp?.nanoseconds;
  if (!Number.isSafeInteger(seconds) || !Number.isSafeInteger(nanoseconds) ||
      seconds! < 0 || nanoseconds! < 0 || nanoseconds! >= 1_000_000_000 ||
      nanoseconds! % 1_000 !== 0) return null;
  const micros = BigInt(seconds!) * 1_000_000n +
    BigInt(nanoseconds! / 1_000);
  return micros > 0n && micros <= BigInt(Number.MAX_SAFE_INTEGER) ?
    Number(micros) : null;
}
