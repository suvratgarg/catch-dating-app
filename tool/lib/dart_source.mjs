// Shared lexical walk for dependency-free Dart source checks.
// This is not a Dart parser; syntax validation remains the analyzer owner.
export function tokenizeDartSyntax(source) {
  const tokens = [];

  function addToken(start, end) {
    tokens.push({
      kind: "identifier",
      identifier: source.slice(start, end),
      offset: start,
    });
  }

  function addMemberAccess(offset, operator) {
    tokens.push({kind: "member-access", operator, offset});
  }

  function scanCode(start, stopAtInterpolationBrace = false) {
    let index = start;
    let nestedBraceDepth = 0;
    while (index < source.length) {
      const character = source[index];
      const next = source[index + 1];

      if (stopAtInterpolationBrace && character === "}") {
        if (nestedBraceDepth === 0) return index + 1;
        tokens.push({kind: "syntax", offset: index});
        nestedBraceDepth -= 1;
        index += 1;
        continue;
      }
      if (stopAtInterpolationBrace && character === "{") {
        tokens.push({kind: "syntax", offset: index});
        nestedBraceDepth += 1;
        index += 1;
        continue;
      }

      if (character === "/" && next === "/") {
        index = skipLineComment(source, index + 2);
        continue;
      }
      if (character === "/" && next === "*") {
        index = skipBlockComment(source, index + 2);
        continue;
      }

      if (
        (character === "r" || character === "R") &&
        isQuote(source[index + 1])
      ) {
        index = scanString(index + 1, true);
        continue;
      }
      if (isQuote(character)) {
        index = scanString(index, false);
        continue;
      }

      if (isIdentifierStart(character)) {
        const tokenStart = index;
        index += 1;
        while (isIdentifierPart(source[index])) index += 1;
        addToken(tokenStart, index);
        continue;
      }
      if (character === ".") {
        addMemberAccess(index, ".");
        index += 1;
        continue;
      }
      if (character === "?" && next === ".") {
        addMemberAccess(index, "?.");
        index += 2;
        continue;
      }

      if (!/\s/u.test(character)) {
        tokens.push({kind: "syntax", offset: index});
      }
      index += 1;
    }
    return index;
  }

  function scanString(quoteIndex, raw) {
    const quote = source[quoteIndex];
    const triple =
      source[quoteIndex + 1] === quote && source[quoteIndex + 2] === quote;
    const delimiterLength = triple ? 3 : 1;
    let index = quoteIndex + delimiterLength;

    while (index < source.length) {
      if (source[index] === quote) {
        if (!triple || source.slice(index, index + 3) === quote.repeat(3)) {
          return index + delimiterLength;
        }
      }
      if (!raw && source[index] === "\\") {
        index += Math.min(2, source.length - index);
        continue;
      }
      if (!raw && source[index] === "$") {
        if (source[index + 1] === "{") {
          index = scanCode(index + 2, true);
          continue;
        }
        if (isInterpolationIdentifierStart(source[index + 1])) {
          const tokenStart = index + 1;
          index = tokenStart + 1;
          while (isIdentifierPart(source[index])) index += 1;
          addToken(tokenStart, index);
          continue;
        }
      }
      index += 1;
    }
    return index;
  }

  scanCode(0);
  return tokens;
}

function skipLineComment(source, start) {
  const newline = source.indexOf("\n", start);
  return newline === -1 ? source.length : newline + 1;
}

function skipBlockComment(source, start) {
  let index = start;
  let depth = 1;
  while (index < source.length && depth > 0) {
    if (source[index] === "/" && source[index + 1] === "*") {
      depth += 1;
      index += 2;
    } else if (source[index] === "*" && source[index + 1] === "/") {
      depth -= 1;
      index += 2;
    } else {
      index += 1;
    }
  }
  return index;
}

function isQuote(character) {
  return character === "'" || character === '"';
}

function isIdentifierStart(character) {
  return character != null && /[A-Za-z_$]/u.test(character);
}

function isInterpolationIdentifierStart(character) {
  return character != null && /[A-Za-z_]/u.test(character);
}

function isIdentifierPart(character) {
  return character != null && /[A-Za-z0-9_$]/u.test(character);
}

