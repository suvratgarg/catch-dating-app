import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {
  assertReactDependencyGraphHealthy,
  buildReactDependencyGraph,
  parseReactDependencyGraphArgs,
  parseModuleReferences,
  reactDependencyGraphSummaryPayload,
  renderReactDependencyGraphJson,
} from "./react_dependency_graph.mjs";

const scriptPath = fileURLToPath(new URL("./react_dependency_graph.mjs", import.meta.url));

test("parses imports, dynamic imports, re-exports, aliases, and workspace modules", (t) => {
  const repoRoot = createFixture(t);
  write(
    repoRoot,
    "website/src/app/App.tsx",
    `import type {HomeModel} from "../features/home/model";
import {homeCopy} from "@content/home";
import {ButtonControl} from "@catch/web-ui";
import {sharedValue} from "../shared";
export {HomePage} from "../features/home/HomePage";
export async function loadAdminSafeChunk() {
  return import("../features/home/lazy");
}
export const App = () => ButtonControl({children: (homeCopy + sharedValue) satisfies HomeModel});
`
  );

  const graph = buildReactDependencyGraph({repoRoot});
  assert.deepEqual(buildReactDependencyGraph({repoRoot}), graph);
  assertReactDependencyGraphHealthy(graph);
  assert.equal(graph.summary.scannedSourceModules, 10);
  assert.equal(graph.health.unresolvedImports.length, 0);
  assert.ok(
    graph.moduleEdges.some(
      (edge) =>
        edge.source === "website/src/app/App.tsx" &&
        edge.target === "website/src/content/home.ts" &&
        edge.kind === "import"
    )
  );
  assert.ok(
    graph.moduleEdges.some(
      (edge) =>
        edge.source === "website/src/app/App.tsx" &&
        edge.target === "packages/web-ui/src/index.ts" &&
        edge.kind === "import"
    )
  );
  assert.ok(
    graph.moduleEdges.some(
      (edge) => edge.kind === "dynamic-import" && edge.target.endsWith("/lazy.ts")
    )
  );
  assert.ok(
    graph.moduleEdges.some(
      (edge) => edge.kind === "export" && edge.target.endsWith("/HomePage.tsx")
    )
  );
  assert.ok(
    graph.moduleEdges.some(
      (edge) => edge.specifier === "../shared" && edge.target.endsWith("/shared/index.ts")
    )
  );
  assert.deepEqual(
    graph.modules.find((module) => module.id.endsWith("/HomePage.tsx")),
    {
      id: "website/src/features/home/HomePage.tsx",
      surface: "website",
      layer: "feature",
      scope: "feature",
      feature: "home",
      group: "website:feature:home",
      extension: ".tsx",
      scanned: true,
      test: false,
      story: false,
    }
  );
});

test("known-bad unresolved repo-local import makes graph health fail", (t) => {
  const repoRoot = createFixture(t);
  write(
    repoRoot,
    "website/src/features/home/Broken.ts",
    'import {missing} from "./does-not-exist";\nexport const broken = missing;\n'
  );

  const graph = buildReactDependencyGraph({repoRoot});
  assert.equal(graph.summary.unresolvedImports, 1);
  assert.match(graph.health.unresolvedImports[0].reason, /did not match/u);
  assert.throws(
    () => assertReactDependencyGraphHealthy(graph),
    /cannot resolve repo-local import '.\/does-not-exist'/u
  );
});

test("full and summary JSON evidence is deterministic and newline terminated", (t) => {
  const repoRoot = createFixture(t);
  const graph = buildReactDependencyGraph({repoRoot});
  assertReactDependencyGraphHealthy(graph);
  const full = renderReactDependencyGraphJson(graph);
  const summary = renderReactDependencyGraphJson(
    reactDependencyGraphSummaryPayload(graph)
  );
  assert.equal(full, renderReactDependencyGraphJson(buildReactDependencyGraph({repoRoot})));
  assert.equal(summary, renderReactDependencyGraphJson(
    reactDependencyGraphSummaryPayload(buildReactDependencyGraph({repoRoot}))
  ));
  assert.ok(full.endsWith("\n"));
  assert.ok(summary.endsWith("\n"));
  assert.deepEqual(JSON.parse(full), graph);
  assert.deepEqual(JSON.parse(summary), {
    schemaVersion: graph.schemaVersion,
    generator: graph.generator,
    policy: graph.policy,
    summary: graph.summary,
    health: graph.health,
  });
});

test("direct website-to-admin dependency is rejected", (t) => {
  const repoRoot = createFixture(t);
  write(
    repoRoot,
    "website/src/app/App.tsx",
    'import {AdminApp} from "../../../admin/src/app/App";\nexport const App = AdminApp;\n'
  );

  const graph = buildReactDependencyGraph({repoRoot});
  assert.equal(graph.summary.crossSurfaceViolations, 1);
  assert.throws(
    () => assertReactDependencyGraphHealthy(graph),
    /website and admin must remain separate deployable apps/u
  );
});

test("runtime and type-only cycles are detected without baselining existing debt", (t) => {
  const repoRoot = createFixture(t);
  write(repoRoot, "admin/src/features/cycle/A.ts", 'import {b} from "./B"; export const a = b;\n');
  write(repoRoot, "admin/src/features/cycle/B.ts", 'import {a} from "./A"; export const b = a;\n');
  write(repoRoot, "website/src/features/types/A.ts", 'import type {B} from "./B"; export type A = B;\n');
  write(repoRoot, "website/src/features/types/B.ts", 'import type {A} from "./A"; export type B = A;\n');

  const graph = buildReactDependencyGraph({repoRoot});
  assert.equal(graph.summary.runtimeCycles, 1);
  assert.equal(graph.summary.allModuleCycles, 2);
  assertReactDependencyGraphHealthy(graph);
  assert.equal(graph.policy.runtimeModuleCycles, "report");
});

test("AST parser ignores comments and records non-literal dynamic imports", () => {
  const references = parseModuleReferences({
    source: `// import "./commented";
import {type Input} from "./input";
export {type Model} from "./model";
const name = "./runtime";
void import(name);
`,
  });
  assert.deepEqual(references, [
    {
      specifier: "./input",
      kind: "import",
      typeOnly: true,
      line: 2,
      column: 1,
    },
    {
      specifier: "./model",
      kind: "export",
      typeOnly: true,
      line: 3,
      column: 1,
    },
    {
      specifier: null,
      kind: "dynamic-import",
      typeOnly: false,
      line: 5,
      column: 6,
    },
  ]);
});

test("CLI accepts live evidence combinations and rejects retired artifact modes", () => {
  const fixtureRoot = path.resolve("fixture-root");
  assert.deepEqual(
    parseReactDependencyGraphArgs(
      ["--check", "--json", "--repo-root", fixtureRoot],
      {repoRoot: "/unused"}
    ),
    {
      repoRoot: fixtureRoot,
      check: true,
      json: true,
      summary: false,
      help: false,
    }
  );
  assert.throws(
    () => parseReactDependencyGraphArgs(["--json", "--summary"]),
    /Choose either --json or --summary/u
  );
  assert.throws(
    () => parseReactDependencyGraphArgs(["--write"]),
    /Unknown argument: --write/u
  );
  assert.throws(
    () => parseReactDependencyGraphArgs(["--output-dir", "tmp"]),
    /Unknown argument: --output-dir/u
  );
  assert.throws(
    () => parseReactDependencyGraphArgs([]),
    /Choose --check, --json, --summary/u
  );

  const retiredMode = spawnSync(process.execPath, [scriptPath, "--write"], {
    encoding: "utf8",
  });
  assert.equal(retiredMode.status, 64);
  assert.match(retiredMode.stderr, /Unknown argument: --write/u);
  assert.match(retiredMode.stderr, /Usage: node tool\/web\/react_dependency_graph/u);
});

test("CLI emits inspectable JSON before a combined check fails", (t) => {
  const repoRoot = createFixture(t);
  write(
    repoRoot,
    "website/src/features/home/Broken.ts",
    'import {missing} from "./does-not-exist";\nexport const broken = missing;\n'
  );

  const result = spawnSync(
    process.execPath,
    [scriptPath, "--repo-root", repoRoot, "--check", "--json"],
    {encoding: "utf8"}
  );
  assert.equal(result.status, 1);
  assert.equal(JSON.parse(result.stdout).summary.unresolvedImports, 1);
  assert.match(result.stderr, /React dependency graph validation failed/u);
  assert.match(result.stderr, /cannot resolve repo-local import/u);
});

test("missing source roots and TypeScript configs fail closed", (t) => {
  const missingSourceRoot = createFixture(t);
  fs.rmSync(path.join(missingSourceRoot, "admin/src"), {recursive: true});
  assert.throws(
    () => buildReactDependencyGraph({repoRoot: missingSourceRoot}),
    /source root is missing: admin\/src/u
  );

  const missingConfig = createFixture(t);
  fs.rmSync(path.join(missingConfig, "website/tsconfig.json"));
  assert.throws(
    () => buildReactDependencyGraph({repoRoot: missingConfig}),
    /tsconfig is missing: website\/tsconfig.json/u
  );
});

function createFixture(t) {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-react-graph-"));
  t.after(() => fs.rmSync(repoRoot, {recursive: true, force: true}));
  writeJson(repoRoot, "package.json", {
    name: "fixture",
    private: true,
    workspaces: ["website", "admin", "packages/web-ui"],
  });
  writeJson(repoRoot, "packages/web-config/tsconfig.react.json", {
    compilerOptions: {
      target: "ES2022",
      module: "ESNext",
      moduleResolution: "Bundler",
      jsx: "react-jsx",
      strict: true,
    },
  });
  writeJson(repoRoot, "website/package.json", {name: "catch-marketing", private: true});
  writeJson(repoRoot, "website/tsconfig.json", {
    extends: "../packages/web-config/tsconfig.react.json",
    compilerOptions: {paths: {"@content/*": ["./src/content/*"]}},
    include: ["src"],
  });
  writeJson(repoRoot, "admin/package.json", {name: "catch-admin", private: true});
  writeJson(repoRoot, "admin/tsconfig.json", {
    extends: "../packages/web-config/tsconfig.react.json",
    include: ["src"],
  });
  writeJson(repoRoot, "packages/web-ui/package.json", {
    name: "@catch/web-ui",
    private: true,
    exports: {".": {types: "./src/index.ts", import: "./src/index.ts"}},
  });
  writeJson(repoRoot, "packages/web-ui/tsconfig.json", {
    extends: "../web-config/tsconfig.react.json",
    include: ["src"],
  });
  write(repoRoot, "website/src/app/App.tsx", "export const App = () => null;\n");
  write(repoRoot, "website/src/content/home.ts", 'export const homeCopy = "Home";\n');
  write(repoRoot, "website/src/features/home/HomePage.tsx", "export const HomePage = () => null;\n");
  write(repoRoot, "website/src/features/home/model.ts", "export type HomeModel = string;\n");
  write(repoRoot, "website/src/features/home/lazy.ts", "export const lazy = true;\n");
  write(repoRoot, "website/src/shared/index.ts", 'export const sharedValue = " shared";\n');
  write(repoRoot, "admin/src/app/App.tsx", "export const AdminApp = () => null;\n");
  write(repoRoot, "admin/src/features/overview/Overview.tsx", "export const Overview = () => null;\n");
  write(repoRoot, "packages/web-ui/src/index.ts", 'export {ButtonControl} from "./primitives";\n');
  write(repoRoot, "packages/web-ui/src/primitives.tsx", "export const ButtonControl = (props: unknown) => props;\n");
  return repoRoot;
}

function writeJson(repoRoot, relativePath, value) {
  write(repoRoot, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}

function write(repoRoot, relativePath, contents) {
  const absolutePath = path.join(repoRoot, relativePath);
  fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
  fs.writeFileSync(absolutePath, contents);
}
