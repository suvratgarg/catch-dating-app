import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {classifyPaths, validateComponentGraph} from "./component_graph.mjs";

// Runtime assets can bypass Dart imports. Treat any manifest mention of a
// candidate or containing directory as a possible asset, including comments.
// Escaped YAML or an asset declaration for a whole ancestor directory remains
// opaque. False positives retain tests; this is not an alternative YAML parser.
function possiblyBundled(document, manifests) {
  return Object.entries(manifests).some(([name, source]) => {
    if (source.includes("\\") || /(?:^|[\s,[\]])["']?(?:\.\.?\/)+["']?(?=\s*(?:[,\]#]|$))/mu.test(source)) return true;
    const local = path.posix.relative(path.posix.dirname(name), document)
      .replace(/^(?:\.\.\/)+/u, "");
    const parts = local.split("/");
    const prefixes = parts.slice(0, -1).map((_, index) =>
      parts.slice(0, index + 1).join("/") + "/",
    );
    return [local, ...prefixes].some((value) => source.includes(value));
  });
}

export function selectOrdinaryDocuments({beforeGraph, afterGraph, changed, manifests}) {
  for (const graph of [beforeGraph, afterGraph]) {
    const errors = validateComponentGraph(graph);
    if (errors.length > 0) throw new Error(errors.join("\n"));
  }
  const snapshots = [beforeGraph, afterGraph].map((graph) =>
    classifyPaths({changedPaths: changed, graph}).pathMatches,
  );
  return changed.filter((name) =>
    name.endsWith(".md") &&
    !/(?:^|\/)(?:assets|test|integration_test)\//u.test(name) &&
    snapshots.every((matches) =>
      matches[name]?.components.length === 1 &&
      matches[name].components[0] === "docs.ordinary",
    ) &&
    !manifests.some((snapshot) => possiblyBundled(name, snapshot)),
  ).sort();
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  console.log(JSON.stringify(selectOrdinaryDocuments(JSON.parse(fs.readFileSync(0, "utf8")))));
}
