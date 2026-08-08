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
    matcher = new RegExp(`^${globToRegexSource(normalizedPattern)}$`, "u");
    matcherCache.set(normalizedPattern, matcher);
  }
  return matcher.test(normalizedValue);
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

function globToRegexSource(pattern) {
  let source = "";
  for (let index = 0; index < pattern.length; index += 1) {
    const character = pattern[index];

    if (character === "/" && pattern.slice(index + 1, index + 3) === "**") {
      const afterGlobstar = pattern[index + 3];
      if (afterGlobstar === "/") {
        source += "/(?:[^/]+/)*";
        index += 3;
      } else if (afterGlobstar == null) {
        source += "(?:/.*)?";
        index += 2;
      } else {
        source += "/.*";
        index += 2;
      }
      continue;
    }

    if (character === "*" && pattern[index + 1] === "*") {
      if (pattern[index + 2] === "/") {
        source += "(?:[^/]+/)*";
        index += 2;
      } else {
        source += ".*";
        index += 1;
      }
      continue;
    }

    if (character === "*") {
      source += "[^/]*";
    } else if (character === "?") {
      source += "[^/]";
    } else {
      source += escapeRegexCharacter(character);
    }
  }
  return source;
}

function escapeRegexCharacter(character) {
  return /[\\^$.*+?()[\]{}|]/u.test(character)
    ? `\\${character}`
    : character;
}
