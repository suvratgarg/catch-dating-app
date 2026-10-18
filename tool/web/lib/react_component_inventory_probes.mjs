import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {buildReactComponentGraph} from "./react_component_graph.mjs";
import {buildReactComponentInventory} from "./react_component_inventory.mjs";

const graphFixture = {
  "tsconfig.json": JSON.stringify({
    compilerOptions: {jsx: "preserve", module: "esnext", moduleResolution: "bundler", target: "es2022", noEmit: true},
    include: ["src"],
  }),
  "src/shared/Button.tsx": "export function Button() { return <button />; }\nexport function formatLabel() { return 'x'; }\n",
  "src/shared/Panel.tsx": "import {Button} from './Button';\nfunction Inner() { return <Button />; }\nexport function Panel() { return <Inner />; }\n",
  "src/shared/index.ts": "export * from './Panel';\n",
  "src/features/a/Page.tsx": "import {Panel} from '../../shared';\nexport function Page() { return <Panel />; }\n",
  "src/features/b/LazyRoute.tsx": "export default function LazyRoute() { return <div />; }\n",
  "src/app.tsx": "import {Page} from './features/a/Page';\nexport const routes = [() => import('./features/b/LazyRoute')];\nexport function App() { return <Page />; }\n",
  "src/shared/Dead.tsx": "export function Dead() { return <span />; }\n",
  "src/shared/Dead.stories.tsx": "import {Dead} from './Dead';\nexport const Story = () => <Dead />;\n",
};

/** The graph follows barrels, private helpers and dynamic imports, and ignores stories. */
export function graphProbeProblems() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "react-component-graph-probe-"));
  try {
    for (const [file, source] of Object.entries(graphFixture)) {
      fs.mkdirSync(path.dirname(path.join(root, file)), {recursive: true});
      fs.writeFileSync(path.join(root, file), source);
    }
    const graph = buildReactComponentGraph({
      repoRoot: root,
      surfaces: [{id: "website", root: "src", tsconfig: "tsconfig.json"}],
    });
    const failures = [];
    const names = graph.components.map((component) => component.name).sort();
    if (JSON.stringify(names) !== JSON.stringify(["App", "Button", "Dead", "LazyRoute", "Page", "Panel"])) {
      failures.push(`components should be the JSX-rendering exports, found ${names.join(", ")}`);
    }
    const has = (from, to) => graph.references.some((reference) => reference.from === from && reference.to === to);
    if (!has("src/shared/Panel.tsx::Inner", "src/shared/Button.tsx::Button")) failures.push("a private helper's use was dropped");
    if (!has("src/shared/Panel.tsx::Panel", "src/shared/Panel.tsx::Inner")) failures.push("a use of a private helper was dropped");
    if (!has("src/features/a/Page.tsx::Page", "src/shared/Panel.tsx::Panel")) failures.push("a barrel re-export was not resolved");
    if (!has("src/app.tsx::routes", "src/features/b/LazyRoute.tsx::LazyRoute")) failures.push("a dynamic import of a default export was missed");
    const deadUses = graph.references.filter((reference) => reference.to === "src/shared/Dead.tsx::Dead");
    if (deadUses.length !== 1 || deadUses[0].file !== "src/shared/Dead.stories.tsx") {
      failures.push("story uses must stay visible as the only, non-production use of an export");
    }
    return failures;
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
}

// Seeded known-bad inventory: each rule of the Phase 7d gate must fire once,
// and the decided and derived cases must stay quiet.
const W = "website/src/shared/ui/primitives";
const A = "admin/src/shared/ui/AdminPrimitives";
const component = (surface, file, name) => ({id: `${file}::${name}`, surface, file, name, line: 1});
const use = (from, to) => ({from, to, file: from.split("::")[0]});

export const probeRegistry = {
  roleNounRedirects: {},
  components: [
    {id: "catch.banner", tier: "T1", level: "L3", roleNoun: "Banner", dart: {symbol: "CatchBanner"}, aliases: ["StatusBanner"]},
    {id: "catch.button", tier: "T1", level: "L3", roleNoun: "Button", dart: {symbol: "CatchButton"},
      react: {symbol: "ButtonControl", file: "packages/web-ui/src/primitives.tsx", api: "headless-control"}},
    {id: "catch.sheet", tier: "T3", level: "L3", roleNoun: "Sheet", dart: {symbol: "CatchSheet"}},
  ],
};

export function probeGraph() {
  const components = [
    component("web-ui", "packages/web-ui/src/primitives.tsx", "ButtonControl"),
    component("web-ui", "packages/web-ui/src/motion.tsx", "OrphanControl"),
    component("website", `${W}/feedback.tsx`, "NoticeBanner"),
    component("website", `${W}/feedback.tsx`, "DecidedBanner"),
    component("website", `${W}/feedback.tsx`, "StaleCompare"),
    component("website", `${W}/forms.tsx`, "DupField"),
    component("website", `${W}/media.tsx`, "DeadThing"),
    component("website", `${W}/media.tsx`, "SingleThing"),
    component("admin", `${A}/actions.tsx`, "AdminActionButton"),
    component("admin", `${A}/cards.tsx`, "SoloCard"),
    component("admin", `${A}/cards.tsx`, "OwnedCard"),
    component("admin", `${A}/forms.tsx`, "DupField"),
  ];
  const websiteA = "website/src/features/a/Page.tsx::PageA";
  const websiteB = "website/src/features/b/Page.tsx::PageB";
  const adminX = "admin/src/features/x/Screen.tsx::XScreen";
  const adminY = "admin/src/features/y/Screen.tsx::YScreen";
  const references = [
    use(websiteA, "packages/web-ui/src/motion.tsx::OrphanControl"),
    use(adminX, "packages/web-ui/src/motion.tsx::OrphanControl"),
    ...[websiteA, websiteB].flatMap((page) => [
      use(page, `${W}/feedback.tsx::NoticeBanner`),
      use(page, `${W}/feedback.tsx::DecidedBanner`),
      use(page, `${W}/feedback.tsx::StaleCompare`),
      use(page, `${W}/forms.tsx::DupField`),
    ]),
    use(websiteA, `${W}/media.tsx::SingleThing`),
    use(`${A}/actions.tsx::AdminActionButton`, "packages/web-ui/src/primitives.tsx::ButtonControl"),
    use(adminX, `${A}/actions.tsx::AdminActionButton`),
    use(adminX, `${A}/cards.tsx::SoloCard`),
    use(adminX, `${A}/cards.tsx::OwnedCard`),
    use(adminX, `${A}/forms.tsx::DupField`),
    use(adminY, `${A}/forms.tsx::DupField`),
    use("website/src/stories/Media.stories.tsx", `${W}/media.tsx::DeadThing`),
  ];
  return {components, references};
}

export const probeSurfaceRegistries = {
  website: {components: [
    {id: "decided_banner", source: `${W}/feedback.tsx`, exportName: "DecidedBanner",
      comparedWith: ["catch.banner"], comparisonReason: "Page band with a call to action, not inline feedback."},
    {id: "stale_compare", source: `${W}/feedback.tsx`, exportName: "StaleCompare",
      comparedWith: ["catch.sheet"], comparisonReason: "Compared with a contract the inventory never matched."},
  ]},
  admin: {components: [
    {id: "admin_action_button", kind: "shared-primitive", owner: "shared/ui", source: `${A}/actions.tsx`,
      exportName: "AdminActionButton", comparedWith: ["catch.button"], comparisonReason: "Too short."},
    {id: "solo_card", kind: "shared-primitive", owner: "shared/ui", source: `${A}/cards.tsx`, exportName: "SoloCard"},
    {id: "owned_card", kind: "feature-component", owner: "features/y", source: `${A}/cards.tsx`, exportName: "OwnedCard"},
  ]},
};

export const expectedProbeProblems = [
  ["motion.tsx::OrphanControl", "implements no registered contract"],
  ["feedback.tsx::NoticeBanner", "matches catch.banner"],
  ["admin_action_button", "needs a comparisonReason"],
  ["solo_card", "record it as a feature-component"],
  ["owned_card", "feature-component owned by features/y is rendered by admin:features/x"],
  ["both export DupField", "point both at one contract"],
  ["stale_compare", "is not a measured candidate"],
];

/** Problems with the gate itself: an expected finding missing or a quiet case reported. */
export function inventoryProbeProblems() {
  const inventory = buildReactComponentInventory({
    graph: probeGraph(),
    registry: probeRegistry,
    surfaceRegistries: probeSurfaceRegistries,
  });
  const failures = [];
  for (const [subject, message] of expectedProbeProblems) {
    if (!inventory.problems.some((problem) => problem.includes(subject) && problem.includes(message))) {
      failures.push(`expected a finding for ${subject}: ${message}`);
    }
  }
  if (inventory.problems.some((problem) => problem.includes("DecidedBanner"))) {
    failures.push("a recorded comparison was reported as undecided");
  }
  const mapping = (name) => inventory.rows.find((row) => row.id.endsWith(`::${name}`))?.mapping;
  if (mapping("DeadThing")?.kind !== "delete") failures.push("a story-only export was not mapped to deletion");
  const single = mapping("SingleThing");
  if (single?.kind !== "t4" || !single.move || single.owner !== "website:features/a") {
    failures.push("a single-feature shared export was not mapped to its feature for a move");
  }
  if (mapping("ButtonControl")?.componentId !== "catch.button") failures.push("a react record was not mapped to its concept");
  return failures;
}
