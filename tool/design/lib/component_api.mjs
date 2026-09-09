import {componentAxes, widgetSlotNames} from "./component_naming.mjs";

const widgetBases = new Set([
  "Widget", "PreferredSizeWidget", "StatelessWidget", "StatefulWidget", "InheritedWidget",
  "InheritedNotifier", "InheritedModel", "ProxyWidget", "ParentDataWidget",
  "RenderObjectWidget", "SingleChildRenderObjectWidget", "MultiChildRenderObjectWidget",
  "LeafRenderObjectWidget", "ConsumerWidget", "ConsumerStatefulWidget",
]);
const baseName = (type) => type?.replace(/<.*>/su, "").replace(/[?\s]/gu, "").split(".").at(-1);
const builderName = (name) => name === "builder" || /Builder$/u.test(name);
const callbackName = (name) => /^on[A-Z]/u.test(name);

function unwrapType(type) {
  while (type.startsWith("(") && type.endsWith(")?")) type = `${type.slice(1, -2)}?`;
  return type;
}

function substitute(type, parameters) {
  return type?.replace(/[A-Za-z_$][\w$]*/gu, (name) => parameters[name] ?? name);
}

function typeArguments(type) {
  const match = type?.match(/^[\w$.]+\s*<([\s\S]*)>\??$/u);
  if (!match) return [];
  const source = match[1];
  const result = [];
  let depth = 0;
  let start = 0;
  for (let i = 0; i < source.length; i += 1) {
    if ("<([{".includes(source[i])) depth += 1;
    if (">)]}".includes(source[i])) depth -= 1;
    if (source[i] === "," && depth === 0) {
      result.push(source.slice(start, i).trim());
      start = i + 1;
    }
  }
  result.push(source.slice(start).trim());
  return result;
}

/** Check every public Widget constructor, not only the default constructor. */
export function componentApiProblems(inventory) {
  const failures = (inventory.failures ?? []).map((message) => ({rule: "parse", message}));
  const classes = inventory.classes ?? [];
  const byName = new Map();
  for (const row of [...classes, ...(inventory.externalClasses ?? [])]) {
    if (!byName.has(row.name)) byName.set(row.name, []);
    byName.get(row.name).push(row);
  }
  const classFor = (name, file) => {
    const matches = byName.get(name) ?? [];
    return matches.find((row) => row.file === file) ?? (matches.length === 1 ? matches[0] : null);
  };
  function isWidget(row, visited = new Set()) {
    if (!row || visited.has(row)) return false;
    visited.add(row);
    return [row.base, ...(row.interfaces ?? [])].some((type) => {
      const parent = baseName(type);
      return widgetBases.has(parent) || isWidget(classFor(parent, row.file), visited);
    });
  }
  const widgets = classes.filter((row) => !row.name.startsWith("_") && isWidget(row));
  const widgetNames = new Set([...widgetBases,
    ...[...classes, ...(inventory.externalClasses ?? [])].filter((row) => isWidget(row)).map((row) => row.name),
  ]);

  function expandAlias(type, file, visited = new Set()) {
    if (!type) return type;
    let result = "";
    const names = /[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*/gu;
    let cursor = 0;
    let match;
    while ((match = names.exec(type))) {
      result += type.slice(cursor, match.index);
      const name = match[0].split(".").at(-1);
      const matches = [...(inventory.aliases ?? []), ...(inventory.externalAliases ?? [])]
        .filter((row) => row.name === name);
      const alias = matches.find((row) => row.file === file) ?? (matches.length === 1 ? matches[0] : null);
      if (!alias) {
        if (matches.length > 1) return null;
        result += match[0];
        cursor = names.lastIndex;
        continue;
      }
      const identity = `${alias.file}:${alias.name}`;
      if (visited.has(identity)) return null;
      let end = names.lastIndex;
      while (/\s/u.test(type[end] ?? "")) end += 1;
      if (type[end] === "<") {
        let depth = 1;
        for (end += 1; end < type.length && depth; end += 1) {
          if (type[end] === "<") depth += 1;
          if (type[end] === ">") depth -= 1;
        }
      }
      const arguments_ = typeArguments(type.slice(match.index, end)).map((type) => expandAlias(type, file, visited));
      const parameters = alias.parameters ?? [];
      if (arguments_.length !== parameters.length || arguments_.some((type) => !type)) return null;
      const expanded = expandAlias(substitute(alias.type,
        Object.fromEntries(parameters.map((parameter, i) => [parameter, arguments_[i]]))),
      alias.file, new Set([...visited, identity]));
      if (!expanded) return null;
      result += expanded;
      cursor = end;
      names.lastIndex = end;
    }
    return result + type.slice(cursor);
  }
  function parameterType(row, constructor, parameter, visited = new Set(), arguments_ = {}) {
    function resolve(type) {
      return expandAlias(substitute(type, {...row.typeParameters, ...arguments_}), row.file);
    }
    if (parameter.type) return resolve(parameter.type);
    if (parameter.kind === "field") return resolve(row.fields?.[parameter.field]);
    if (parameter.kind !== "super" || visited.has(row)) return null;
    if (parameter.name === "key") return "Key?";
    visited.add(row);
    const parent = classFor(baseName(row.base), row.file);
    const parentConstructor = parent?.constructors.find((entry) => entry.name === constructor.superConstructor);
    if (!parentConstructor) return null;
    const position = constructor.parameters.filter((entry) => !entry.named).indexOf(parameter);
    const inherited = parameter.named
      ? parentConstructor.parameters.find((entry) => entry.named && entry.name === parameter.name)
      : parentConstructor.parameters.filter((entry) => !entry.named)[position];
    const parentArguments = typeArguments(row.base).map(resolve);
    const substitutions = Object.fromEntries(Object.keys(parent.typeParameters ?? {}).map((name, i) => [name, parentArguments[i]]).filter(([, value]) => value));
    return inherited ? parameterType(parent, parentConstructor, inherited, visited, substitutions) : null;
  }
  function typeKind(raw) {
    const type = unwrapType(raw?.replace(/\s+/gu, "").replace(/\?+/gu, "?") ?? "");
    if (!type || type === "dynamic") return "unknown";
    if (/^bool\??$/u.test(type)) return "bool";
    // Inspect the return type, not Widget arguments inside a void callback.
    const functionAt = type.indexOf("Function");
    if (functionAt >= 0) {
      const result = type.slice(0, functionAt);
      if (hasWidget(result)) return "builder";
      return /^(?:void|Future<void>|FutureOr<void>)$/u.test(result) ? "callback" : "function";
    }
    return hasWidget(type) ? "slot" : "value";
  }
  function hasWidget(type) {
    return (type.match(/[A-Za-z_$][\w$]*/gu) ?? []).some((word) => widgetNames.has(word));
  }
  for (const row of widgets) {
    for (const constructor of row.constructors) {
      const parameters = constructor.parameters.map((parameter) => ({
        ...parameter, resolvedType: parameterType(row, constructor, parameter),
      }));
      const bools = parameters.filter((parameter) => typeKind(parameter.resolvedType) === "bool");
      if (bools.length > 2) report("boolean-count", row, constructor,
        `exposes ${bools.length} booleans (${bools.map((p) => p.name).join(", ")}); use a typed axis`);
      for (const parameter of parameters) {
        const kind = typeKind(parameter.resolvedType);
        const {name} = parameter;
        if (kind === "unknown") report("parameter-type", row, constructor,
          `${name}: cannot determine the public parameter type`, parameter);
        if (kind === "slot" && !widgetSlotNames.includes(name)) report("slot", row, constructor,
          `${name}: Widget slots use the closed vocabulary`, parameter);
        if (kind === "builder" && !builderName(name)) report("builder", row, constructor,
          `${name}: a builder must be named builder or end in Builder`, parameter);
        if (kind === "callback" && !callbackName(name)) report("callback", row, constructor,
          `${name}: an action callback must start with on`, parameter);
        if (kind === "function" && !builderName(name) && !callbackName(name)) report("function", row, constructor,
          `${name}: name the computation with Builder or the callback with on`, parameter);
      }
    }
  }

  // Foundation/configuration classes may own axes too; ownership still requires
  // a real public declaration, never an invented prefix or registry ID.
  const owners = classes.filter((row) => !row.name.startsWith("_"))
    .map((row) => row.name).sort((a, b) => b.length - a.length || a.localeCompare(b));
  for (const entry of inventory.enums ?? []) {
    if (entry.name.startsWith("_")) continue;
    const owner = owners.find((name) => entry.name.startsWith(name));
    if (!owner || !componentAxes.includes(entry.name.slice(owner.length))) {
      failures.push({rule: "enum-axis", file: entry.file, line: entry.line, column: entry.column, symbol: entry.name,
        message: owner ? `${entry.name}: axis after ${owner} must be ${componentAxes.join("|")}`
          : `${entry.name}: enum must name its owning component followed by a closed axis`});
    }
  }
  return failures.sort((a, b) => (a.file ?? "").localeCompare(b.file ?? "") ||
    (a.line ?? 0) - (b.line ?? 0) || (a.column ?? 0) - (b.column ?? 0) || a.message.localeCompare(b.message));

  function report(rule, row, constructor, message, parameter) {
    failures.push({rule, file: row.file, line: parameter?.line ?? constructor.line,
      column: parameter?.column ?? constructor.column,
      symbol: row.name, constructor: constructor.name, parameter: parameter?.name,
      message: `${row.name}${constructor.name ? `.${constructor.name}` : ""}: ${message}`});
  }
}
