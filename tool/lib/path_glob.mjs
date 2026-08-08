import picomatch from "picomatch";

const matcherCache = new Map();

export function normalizeGlobPath(value) {
  if (typeof value !== "string") return null;
  const normalized = value
    .replaceAll("\\", "/")
    .replace(/^\.\//u, "")
    .replace(/\/+$/gu, "");
  return normalized === "" ? null : normalized;
}

export function matchesGlobPath(value, pattern) {
  const normalizedValue = normalizeGlobPath(value);
  const normalizedPattern = normalizeGlobPath(pattern);
  if (!normalizedValue || !normalizedPattern) return false;

  let matcher = matcherCache.get(normalizedPattern);
  if (!matcher) {
    matcher = picomatch(normalizedPattern, {
      dot: true,
      nonegate: true,
    });
    matcherCache.set(normalizedPattern, matcher);
  }
  return matcher(normalizedValue);
}

export function matchesScopePath(candidate, pattern) {
  const normalizedCandidate = normalizeGlobPath(candidate);
  const normalizedPattern = normalizeGlobPath(pattern);
  if (!normalizedCandidate || !normalizedPattern) return false;
  if (normalizedCandidate === normalizedPattern) return true;
  if (!/[?*\[]/u.test(normalizedPattern)) {
    return normalizedCandidate.startsWith(`${normalizedPattern}/`);
  }
  return matchesGlobPath(normalizedCandidate, normalizedPattern);
}
