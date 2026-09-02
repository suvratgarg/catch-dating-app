const widgetBaseTypes = new Set([
  "Widget",
  "StatelessWidget",
  "StatefulWidget",
  "InheritedWidget",
  "InheritedNotifier",
  "InheritedModel",
  "ProxyWidget",
  "ParentDataWidget",
  "RenderObjectWidget",
  "LeafRenderObjectWidget",
  "SingleChildRenderObjectWidget",
  "MultiChildRenderObjectWidget",
  "SlottedMultiChildRenderObjectWidget",
  "PreferredSizeWidget",
  "ConsumerWidget",
  "ConsumerStatefulWidget",
  "HookWidget",
  "StatefulHookWidget",
  "HookConsumerWidget",
  "StatefulHookConsumerWidget",
]);

// These final, non-Widget descriptor types are the closed input protocols for
// the canonical route/tab scaffolds. Their private renderers are callable only
// from the owning scaffold library; keep this exact owner+method allowlist so
// unrelated Widget-returning helpers on the same types still fail inventory.
const canonicalClosedDescriptorRendererMethods = new Map([
  [
    "CatchRouteBody",
    new Set(["_build", "_buildStandard", "_buildStandardSlivers"]),
  ],
  ["CatchTabbedPageSpec", new Set(["_build"])],
  ["CatchTabbedScreenBody", new Set(["_build"])],
]);

export function unresolvedInventoryItems({
  addedWidgets = [],
  addedWidgetHelpers = [],
  movedWidgets = [],
  movedWidgetHelpers = [],
}) {
  return [
    ...addedWidgets,
    ...addedWidgetHelpers,
    ...movedWidgets,
    ...movedWidgetHelpers,
  ].filter((entry) => entry.status !== "covered");
}

export function requireResolvedMergeBase(result) {
  const mergeBase = result?.status === 0 ? String(result.stdout ?? "").trim() : "";
  if (mergeBase) return mergeBase;
  throw new Error(
    "Unable to resolve the merge base between HEAD and origin/main; refusing " +
      "to fall back to HEAD^. Fetch origin/main or pass --base <commit>.",
  );
}

export function collectCatalogWidgetSymbols(source) {
  const lines = source.split(/\r?\n/u);
  const symbols = new Set();

  for (let index = 0; index < lines.length - 1; index += 1) {
    const header = markdownTableCells(lines[index]);
    const separator = markdownTableCells(lines[index + 1]);
    if (
      header?.[0]?.trim() !== "Widget" ||
      separator == null ||
      !separator.every((cell) => /^:?-{3,}:?$/u.test(cell.trim()))
    ) {
      continue;
    }

    for (let rowIndex = index + 2; rowIndex < lines.length; rowIndex += 1) {
      const row = markdownTableCells(lines[rowIndex]);
      if (row == null) break;
      const firstCell = row[0].trim();
      const codeSpans = [...firstCell.matchAll(/`([^`]+)`/gu)];
      const remainder = firstCell
        .replaceAll(/`[^`]+`/gu, "")
        .replaceAll("/", "")
        .trim();
      if (codeSpans.length === 0 || remainder !== "") continue;

      for (const span of codeSpans) {
        const declaration = span[1].trim();
        const name = declaration.match(
          /^([A-Za-z_][A-Za-z0-9_]*)(?:<.*>)?$/u,
        )?.[1];
        if (name) symbols.add(name);
      }
    }
  }

  return symbols;
}

export function collectClassDeclarations(source, lineStarts = buildLineStarts(source)) {
  const code = maskNonCode(source);
  const rows = [];
  const regex =
    /\bclass\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^>{};=]+>)?\s+(?:extends|=)\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^>{};=]+>)?/gu;

  for (const match of code.matchAll(regex)) {
    rows.push({
      name: match[1],
      baseClass: match[2],
      visibility: match[1].startsWith("_") ? "private" : "public",
      line: lineForOffset(lineStarts, match.index ?? 0),
    });
  }
  return rows;
}

export function resolveWidgetTypeNames(declarations) {
  const widgetTypes = new Set(widgetBaseTypes);
  let changed = true;
  while (changed) {
    changed = false;
    for (const declaration of declarations) {
      if (
        widgetTypes.has(declaration.name) ||
        !widgetTypes.has(declaration.baseClass)
      ) {
        continue;
      }
      widgetTypes.add(declaration.name);
      changed = true;
    }
  }
  return widgetTypes;
}

export function collectWidgetClasses(
  source,
  lineStarts,
  widgetTypeNames,
) {
  return collectClassDeclarations(source, lineStarts).filter((declaration) =>
    widgetTypeNames.has(declaration.baseClass),
  );
}

export function collectWidgetStateClasses(
  source,
  lineStarts = buildLineStarts(source),
) {
  const code = maskNonCode(source);
  const rows = [];
  const regex =
    /\bclass\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^>{};=]+>)?\s+extends\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?((?:State|ConsumerState)<(?:[^<>{}]|<[^<>{}]*>)+>)/gu;

  for (const match of code.matchAll(regex)) {
    rows.push({
      name: match[1],
      baseClass: match[2].replaceAll(/\s+/gu, " "),
      visibility: match[1].startsWith("_") ? "private" : "public",
      line: lineForOffset(lineStarts, match.index ?? 0),
    });
  }
  return rows;
}

export function collectWidgetHelpers(
  source,
  lineStarts,
  classRanges,
  widgetTypeNames,
) {
  const code = maskNonCode(source);
  const rows = [];
  const seen = new Set();
  const type =
    String.raw`(?:[A-Za-z_][A-Za-z0-9_]*\.)?[A-Za-z_][A-Za-z0-9_]*(?:\s*<[^<>{};=()]*>)?\??`;
  const functionRegex = new RegExp(
    String.raw`(?:^|\n)([ \t]*(?:(?:static|external)\s+)*(${type})\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^<>{};=()]+>)?\s*\()`,
    "gu",
  );
  const getterRegex = new RegExp(
    String.raw`(?:^|\n)([ \t]*(?:(?:static|external)\s+)*(${type})\s+get\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?==>|\{))`,
    "gu",
  );

  for (const regex of [functionRegex, getterRegex]) {
    for (const match of code.matchAll(regex)) {
      const offset = (match.index ?? 0) + (match[0].startsWith("\n") ? 1 : 0);
      // An old-style function-typed parameter can look exactly like a helper
      // declaration on its own line (`Widget builder()`). It is not a widget
      // factory, so exclude matches nested inside another parameter list.
      if (delimiterDepthAt(code, offset, "(", ")") > 0) continue;
      const returnType = simpleTypeName(match[2]);
      const name = match[3];
      if (name === "build" || !widgetTypeNames.has(returnType)) continue;
      const key = `${offset}:${name}`;
      if (seen.has(key)) continue;
      seen.add(key);
      const owner = innermostClassRange(classRanges, offset);
      // Descriptor renderers are the typed mapper protocol, not free-standing
      // composition helpers that can drift outside a cataloged widget owner.
      if (
        owner?.name === "CatchFormRowDescriptor" ||
        owner?.baseClass === "CatchFormRowDescriptor" ||
        isCanonicalClosedDescriptorRenderer(owner?.name, name)
      ) {
        continue;
      }
      rows.push({
        name,
        owner: owner?.name ?? null,
        ownerBaseClass: owner?.baseClass ?? null,
        returnType: match[2].replaceAll(/\s+/gu, ""),
        visibility: name.startsWith("_") ? "private" : "public",
        line: lineForOffset(lineStarts, offset),
        scope: owner ? "class-method" : "top-level",
        declarationKind: regex === getterRegex ? "getter" : "function",
      });
    }
  }

  return rows.sort((a, b) => a.line - b.line || a.name.localeCompare(b.name));
}

function isCanonicalClosedDescriptorRenderer(ownerName, methodName) {
  return canonicalClosedDescriptorRendererMethods
    .get(ownerName)
    ?.has(methodName) === true;
}

export function collectClassRanges(source, lineStarts = buildLineStarts(source)) {
  const code = maskNonCode(source);
  const rows = [];
  const regex =
    /\bclass\s+([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^>{};=]+>)?(?:\s+extends\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?([A-Za-z_][A-Za-z0-9_]*)(?:\s*<[^>{};=]+>)?)?/gu;

  for (const match of code.matchAll(regex)) {
    const open = code.indexOf("{", match.index);
    const semicolon = code.indexOf(";", match.index);
    if (open === -1 || (semicolon !== -1 && semicolon < open)) continue;
    const close = findMatchingBrace(code, open);
    if (close === -1) continue;
    rows.push({
      name: match[1],
      baseClass: match[2] ?? "",
      open,
      close,
      line: lineForOffset(lineStarts, match.index ?? 0),
    });
  }

  return rows.sort((a, b) => a.open - b.open);
}

export function buildLineStarts(source) {
  const starts = [0];
  for (let index = 0; index < source.length; index += 1) {
    if (source[index] === "\n") starts.push(index + 1);
  }
  return starts;
}

function simpleTypeName(type) {
  return type
    .replaceAll(/\s+/gu, "")
    .replace(/\?$/u, "")
    .replace(/<.*>$/u, "")
    .split(".")
    .at(-1);
}

function innermostClassRange(ranges, offset) {
  return ranges
    .filter((range) => offset > range.open && offset < range.close)
    .sort((a, b) => (a.close - a.open) - (b.close - b.open))[0];
}

function lineForOffset(lineStarts, offset) {
  let low = 0;
  let high = lineStarts.length - 1;
  while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    if (lineStarts[mid] <= offset) low = mid + 1;
    else high = mid - 1;
  }
  return high + 1;
}

function findMatchingBrace(code, open) {
  let depth = 0;
  for (let index = open; index < code.length; index += 1) {
    if (code[index] === "{") depth += 1;
    else if (code[index] === "}") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  return -1;
}

function delimiterDepthAt(code, offset, open, close) {
  let depth = 0;
  for (let index = 0; index < offset; index += 1) {
    if (code[index] === open) depth += 1;
    else if (code[index] === close) depth = Math.max(0, depth - 1);
  }
  return depth;
}

function markdownTableCells(line) {
  const trimmed = line.trim();
  if (!trimmed.startsWith("|") || !trimmed.endsWith("|")) return null;
  return trimmed.slice(1, -1).split("|");
}

function maskNonCode(source) {
  const output = [...source];
  let index = 0;
  let blockDepth = 0;
  let lineComment = false;
  let string = null;

  const blank = (position) => {
    if (output[position] !== "\n" && output[position] !== "\r") {
      output[position] = " ";
    }
  };

  while (index < source.length) {
    if (lineComment) {
      if (source[index] === "\n") lineComment = false;
      else blank(index);
      index += 1;
      continue;
    }
    if (blockDepth > 0) {
      if (source.startsWith("/*", index)) {
        blank(index);
        blank(index + 1);
        blockDepth += 1;
        index += 2;
      } else if (source.startsWith("*/", index)) {
        blank(index);
        blank(index + 1);
        blockDepth -= 1;
        index += 2;
      } else {
        blank(index);
        index += 1;
      }
      continue;
    }
    if (string != null) {
      const {quote, triple, raw} = string;
      const terminator = triple ? quote.repeat(3) : quote;
      if (source.startsWith(terminator, index)) {
        for (let cursor = 0; cursor < terminator.length; cursor += 1) {
          blank(index + cursor);
        }
        index += terminator.length;
        string = null;
      } else if (!raw && source[index] === "\\") {
        blank(index);
        blank(index + 1);
        index += 2;
      } else {
        blank(index);
        index += 1;
      }
      continue;
    }
    if (source.startsWith("//", index)) {
      blank(index);
      blank(index + 1);
      lineComment = true;
      index += 2;
      continue;
    }
    if (source.startsWith("/*", index)) {
      blank(index);
      blank(index + 1);
      blockDepth = 1;
      index += 2;
      continue;
    }
    if (source[index] === "'" || source[index] === '"') {
      const quote = source[index];
      const triple = source.startsWith(quote.repeat(3), index);
      const raw = index > 0 && /[rR]/u.test(source[index - 1]);
      const length = triple ? 3 : 1;
      for (let cursor = 0; cursor < length; cursor += 1) blank(index + cursor);
      string = {quote, triple, raw};
      index += length;
      continue;
    }
    index += 1;
  }

  return output.join("");
}
