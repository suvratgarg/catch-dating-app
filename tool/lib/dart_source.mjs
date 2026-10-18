// Shared lexical walk for dependency-free Dart source checks.
// This is not a Dart parser; syntax validation remains the analyzer owner.
export function tokenizeDartSyntax(source) {
  return lexDartSource(source).tokens;
}

export function scanDartSource(source) {
  const {tokens, code, directiveTokens} = lexDartSource(source);
  const imports = collectImports(source, directiveTokens);
  const body = code.split("");
  for (const directive of imports) {
    for (let index = directive.start; index < directive.end; index += 1) {
      if (!/\s/u.test(body[index])) body[index] = " ";
    }
  }
  return {tokens, code: body.join(""), imports};
}

function lexDartSource(source) {
  const tokens = [];
  const directiveTokens = [];
  // split("") preserves UTF-16 offsets, including astral characters.
  const code = source.split("").map((character) =>
    /\s/u.test(character) ? character : " ");
  function keep(start, end = start + 1) {
    for (let index = start; index < end; index += 1) code[index] = source[index];
  }

  function addToken(start, end) {
    keep(start, end);
    tokens.push({
      kind: "identifier",
      identifier: source.slice(start, end),
      offset: start,
    });
  }

  function addMemberAccess(offset, operator) {
    keep(offset, offset + operator.length);
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
        keep(index);
        tokens.push({kind: "syntax", offset: index});
        nestedBraceDepth -= 1;
        index += 1;
        continue;
      }
      if (stopAtInterpolationBrace && character === "{") {
        keep(index);
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
        const literal = scanString(index + 1, true);
        if (!stopAtInterpolationBrace) directiveTokens.push(literal);
        index = literal.end;
        continue;
      }
      if (isQuote(character)) {
        const literal = scanString(index, false);
        if (!stopAtInterpolationBrace) directiveTokens.push(literal);
        index = literal.end;
        continue;
      }

      if (!stopAtInterpolationBrace && !/\s/u.test(character)) {
        directiveTokens.push({
          kind: "code", text: character, start: index, end: index + 1,
        });
      }
      if (isIdentifierStart(character)) {
        const tokenStart = index;
        index += 1;
        while (isIdentifierPart(source[index])) index += 1;
        addToken(tokenStart, index);
        if (!stopAtInterpolationBrace) {
          Object.assign(directiveTokens.at(-1), {
            text: source.slice(tokenStart, index), end: index,
          });
        }
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
        keep(index);
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
    const contentStart = quoteIndex + delimiterLength;
    let index = contentStart;
    let interpolated = false;
    function literal(end, closed) {
      return {
        kind: "string", start: raw ? quoteIndex - 1 : quoteIndex, end,
        raw, triple, interpolated, closed,
        content: source.slice(contentStart, closed ? end - delimiterLength : end),
      };
    }

    while (index < source.length) {
      if (source[index] === quote) {
        if (!triple || source.slice(index, index + 3) === quote.repeat(3)) {
          return literal(index + delimiterLength, true);
        }
      }
      if (!raw && source[index] === "\\") {
        index += Math.min(2, source.length - index);
        continue;
      }
      if (!raw && source[index] === "$") {
        if (source[index + 1] === "{") {
          interpolated = true;
          index = scanCode(index + 2, true);
          continue;
        }
        if (isInterpolationIdentifierStart(source[index + 1])) {
          interpolated = true;
          const tokenStart = index + 1;
          index = tokenStart + 1;
          while (isIdentifierPart(source[index])) index += 1;
          addToken(tokenStart, index);
          continue;
        }
      }
      index += 1;
    }
    return literal(index, false);
  }

  scanCode(0);
  return {tokens, directiveTokens, code: code.join("")};
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

// Only import directives are interpreted. The Dart analyzer still owns the
// surrounding language; malformed/unsupported import syntax fails closed here.
function collectImports(source, tokens) {
  const imports = [];
  let depth = 0;
  for (let index = 0; index < tokens.length; index += 1) {
    const token = tokens[index];
    if (["{", "(", "["].includes(token.text)) depth += 1;
    if (["}", ")", "]"].includes(token.text)) depth -= 1;
    if (depth !== 0 || token.text !== "import") continue;
    const start = token.start;
    const uris = [];
    function fail() {
      throw new Error(`Unsupported Dart import directive at offset ${start}`);
    }
    function takeUri() {
      const offset = tokens[index + 1]?.start;
      let uri = "";
      do {
        const literal = tokens[++index];
        if (literal?.kind !== "string" || !literal.closed || literal.interpolated) {
          fail();
        }
        uri += decodeString(literal);
      } while (tokens[index + 1]?.kind === "string");
      uris.push({uri, offset});
    }
    function takeIdentifier() {
      const identifier = tokens[++index];
      if (identifier?.kind !== "code" ||
          !/^[A-Za-z_$][A-Za-z0-9_$]*$/u.test(identifier.text)) fail();
    }
    takeUri();
    while (tokens[index + 1]?.text === "if") {
      index += 2;
      if (tokens[index]?.text !== "(") fail();
      let conditionDepth = 1;
      while (conditionDepth > 0) {
        const condition = tokens[++index];
        if (!condition || condition.text === ";") fail();
        if (condition.text === "(") conditionDepth += 1;
        if (condition.text === ")") conditionDepth -= 1;
      }
      takeUri();
    }
    if (tokens[index + 1]?.text === "deferred") {
      index += 1;
      if (tokens[index + 1]?.text !== "as") fail();
    }
    if (tokens[index + 1]?.text === "as") {
      index += 1;
      takeIdentifier();
    }
    while (["show", "hide"].includes(tokens[index + 1]?.text)) {
      index += 1;
      takeIdentifier();
      while (tokens[index + 1]?.text === ",") {
        index += 1;
        takeIdentifier();
      }
    }
    const end = tokens[++index];
    if (end?.text !== ";") fail();
    imports.push({start, end: end.end, text: source.slice(start, end.end), uris});
  }
  return imports;
}

function decodeString(literal) {
  // Dart drops an initial whitespace-only line in a multiline literal.
  const content = literal.triple
    ? literal.content.replace(/^(?:\\?[ \t])*\\?(?:\r\n|\r|\n)/u, "")
    : literal.content;
  if (literal.raw) return content;
  const escapes = {n: "\n", r: "\r", t: "\t", b: "\b", f: "\f", v: "\v"};
  return content.replace(/\\(u\{[0-9a-fA-F]{1,6}\}|u[0-9a-fA-F]{4}|x[0-9a-fA-F]{2}|[\s\S])/gu,
    (_, escape) => {
      if (/^[ux]/u.test(escape)) {
        const hex = escape.startsWith("u{") ? escape.slice(2, -1) : escape.slice(1);
        if (!/^[0-9a-fA-F]+$/u.test(hex)) {
          throw new Error(`Unsupported Dart string escape at offset ${literal.start}`);
        }
        return String.fromCodePoint(Number.parseInt(hex, 16));
      }
      return escapes[escape] ?? escape;
    });
}
