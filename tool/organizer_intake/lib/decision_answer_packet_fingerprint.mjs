import crypto from "node:crypto";

export function fingerprintDecisionAnswerPacket(packet) {
  return crypto
    .createHash("sha256")
    .update(stableStringify(sourceShape(packet)))
    .digest("hex");
}

function sourceShape(packet) {
  if (!packet || typeof packet !== "object") return packet;
  const {
    reviewDraft: _reviewDraft,
    ...rest
  } = packet;
  return rest;
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value));
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}
