import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  assertReactDependencyGraphHealthy,
  buildReactDependencyGraph,
  checkReactDependencyGraphArtifacts,
  parseModuleReferences,
  writeReactDependencyGraphArtifacts,
} from "./react_dependency_graph.mjs";

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

test("known-bad stale artifact is reported deterministically", (t) => {
  const repoRoot = createFixture(t);
  const outputDir = path.join(repoRoot, "tmp-output");
  const graph = buildReactDependencyGraph({repoRoot});
  assertReactDependencyGraphHealthy(graph);
  writeReactDependencyGraphArtifacts({graph, outputDir});
  assert.deepEqual(checkReactDependencyGraphArtifacts({graph, outputDir}), []);

  fs.appendFileSync(path.join(outputDir, "README.md"), "stale\n");
  assert.deepEqual(checkReactDependencyGraphArtifacts({graph, outputDir}), [
    {name: "README.md", reason: "stale"},
  ]);
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
