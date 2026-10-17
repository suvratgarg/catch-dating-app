import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {materializeInventories} from "./generated_inventories.mjs";
import {buildInventory} from "../ui_capture/check_route_inventory.mjs";
import {catalogStart, catalogEnd, runCatalog} from "../design/generate_widget_catalog.mjs";

const routePath = "tool/ui_capture/route_inventory.json";
const catalogPath = "docs/widget_catalog.md";
function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "ci-inventories-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const write = (file, text) => {
    fs.mkdirSync(path.dirname(path.join(root, file)), {recursive: true});
    fs.writeFileSync(path.join(root, file), text);
  };
  const git = (...args) => {
    const result = spawnSync("git", args, {cwd: root, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  write("lib/routing/route_contract.dart", "enum Routes {\n  home('/'),\n  ;\n}\n");
  write("lib/routing/go_router.dart", "GoRouter router() { return GoRouter(routes: [GoRoute(path: Routes.home.path, name: Routes.home.name, builder: (_) => const HomeScreen())]); }\n");
  write("apps/host/lib/feature.dart", "/// Host-only feature.\nclass HostScreen extends StatelessWidget {}\nvoid open() { MaterialPageRoute(builder: (_) => const HostScreen()); }\n");
  write("lib/home.dart", "/// Home contract.\nclass HomeScreen extends StatelessWidget {}\n");
  write("apps/consumer/lib/entry.dart", "// Consumer root.\n");
  write("packages/catch_ui/lib/entry.dart", "// Shared root.\n");
  write("design/components/catch.components.json", JSON.stringify({components: []}));
  write("authored-coverage.json", JSON.stringify({home: "explicitly planned"}));
  write("test/goldens/home.png", "real regression baseline bytes are outside this operation");
  write(routePath, "stale route inventory\n");
  write(catalogPath, `# Authored decisions\nKeep café and CRLF here.\r\n${catalogStart}\nStale rows\n${catalogEnd}\n## Authored footer\nKeep exactly.\n`);
  git("init", "-q");
  const commit = () => {
    git("add", ".");
    git("-c", "user.name=Inventory Test", "-c", "user.email=inventory@example.invalid", "commit", "-qm", "fixture");
    return git("rev-parse", "HEAD");
  };
  return {root, write, git, commit, sourceSha: commit(), read: file => fs.readFileSync(path.join(root, file), "utf8")};
}

test("actual generators replace stale outputs while preserving authored guidance, decisions and goldens", t => {
  const f = fixture(t);
  const catalog = f.read(catalogPath);
  const coverage = f.read("authored-coverage.json");
  const golden = f.read("test/goldens/home.png");
  assert.throws(() => runCatalog({repoRoot: f.root}), /stale or hand-edited/u);
  const result = materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha});
  assert.equal(result.routes, 1);
  assert.equal(result.widgets, 2);
  assert.deepEqual(result.files.map(file => file.changed), [true, true]);
  assert.deepEqual(JSON.parse(f.read(routePath)), buildInventory({repoRoot: f.root}));
  assert.equal(JSON.parse(f.read(routePath)).imperativePageRoutes[0].sourcePath, "apps/host/lib/feature.dart");
  assert.deepEqual(runCatalog({repoRoot: f.root}), {count: 2, changed: false});
  assert.equal(f.read(catalogPath).split(catalogStart)[0], catalog.split(catalogStart)[0]);
  assert.equal(f.read(catalogPath).split(catalogEnd)[1], catalog.split(catalogEnd)[1]);
  assert.equal(f.read("authored-coverage.json"), coverage);
  assert.equal(f.read("test/goldens/home.png"), golden);
  assert.deepEqual(materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}).files.map(file => file.changed), [false, false]);
});

test("wrong or mutable source identity and dirty authored inputs fail before either output changes", t => {
  const f = fixture(t);
  const originals = [f.read(routePath), f.read(catalogPath)];
  for (const sourceSha of ["main", "a".repeat(40), `${f.sourceSha}\n`]) {
    assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}));
  }
  f.write("lib/home.dart", "class ChangedScreen extends StatelessWidget {}\n");
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}), /Authored inventory inputs/);
  assert.deepEqual([f.read(routePath), f.read(catalogPath)], originals);
});

test("untracked production source cannot silently enter an exact-source inventory", t => {
  const f = fixture(t);
  f.write("lib/untracked.dart", "class UntrackedScreen extends StatelessWidget {}\n");
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}), /Untracked source/);
  assert.equal(f.read(routePath), "stale route inventory\n");
});

test("ignored untracked Dart and index flags cannot hide inputs from the exact source binding", t => {
  const f = fixture(t);
  f.write(".gitignore", "lib/ignored.dart\n");
  const sourceSha = f.commit();
  f.write("lib/ignored.dart", "class IgnoredScreen extends StatelessWidget {}\n");
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /Ignored untracked Dart/);
  fs.unlinkSync(path.join(f.root, "lib/ignored.dart"));
  f.git("update-index", "--assume-unchanged", "lib/home.dart");
  f.write("lib/home.dart", "class HiddenScreen extends StatelessWidget {}\n");
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /assume-unchanged/);
  assert.equal(f.read(routePath), "stale route inventory\n");
});

test("partial sparse checkout fails even when every production root still exists", t => {
  const f = fixture(t);
  f.git("sparse-checkout", "init", "--no-cone");
  f.git("sparse-checkout", "set", "--no-cone", "/*", "!/lib/home.dart");
  assert.ok(fs.existsSync(path.join(f.root, "lib/routing/go_router.dart")));
  assert.ok(!fs.existsSync(path.join(f.root, "lib/home.dart")));
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}), /skip-worktree/);
  assert.equal(f.read(routePath), "stale route inventory\n");
});

test("edited catalog prose and sparse source roots cannot be mistaken for derived drift", t => {
  const f = fixture(t);
  f.write(catalogPath, f.read(catalogPath).replace("Authored decisions", "Changed policy"));
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}), /Authored catalog guidance/);
  fs.rmSync(path.join(f.root, "apps/consumer/lib"), {recursive: true});
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha: f.sourceSha}), /full source checkout/);
  assert.equal(f.read(routePath), "stale route inventory\n");
});

test("a newly generated route still fails the actual authored capture coverage gate", t => {
  const f = fixture(t);
  for (const file of ["tool/ui_capture/check_capture_coverage.mjs", "tool/lib/repo_paths.mjs"]) {
    f.write(file, fs.readFileSync(new URL(`../../${file}`, import.meta.url), "utf8"));
  }
  const decisions = JSON.stringify({routes: [{routeId: "home", status: "planned", priority: "P1", reason: "Explicit authored decision"}]});
  f.write("tool/ui_capture/capture_coverage.json", decisions);
  f.write("test/ui_captures/catalog/screen_capture_catalog.dart", "// No captured routes yet.\n");
  f.write("tool/marketing/capture_manifest.json", JSON.stringify({captures: []}));
  let sourceSha = f.commit();
  materializeInventories({repoRoot: f.root, sourceSha});
  const check = () => spawnSync(process.execPath, ["tool/ui_capture/check_capture_coverage.mjs", "--check"], {cwd: f.root, encoding: "utf8"});
  const before = check();
  assert.equal(before.status, 0, before.stderr);
  f.write("lib/routing/route_contract.dart", "enum Routes {\n  home('/'),\n  detail('/detail'),\n  ;\n}\n");
  f.write("lib/routing/go_router.dart", "GoRouter router() { return GoRouter(routes: [GoRoute(path: Routes.home.path, name: Routes.home.name, builder: (_) => const HomeScreen()), GoRoute(path: Routes.detail.path, name: Routes.detail.name, builder: (_) => const DetailScreen())]); }\n");
  sourceSha = f.commit();
  materializeInventories({repoRoot: f.root, sourceSha});
  assert.deepEqual(JSON.parse(f.read(routePath)).routes.map(route => route.id), ["home", "detail"]);
  assert.equal(f.read("tool/ui_capture/capture_coverage.json"), decisions);
  const after = check();
  assert.equal(after.status, 1);
  assert.match(after.stderr, /detail: missing capture coverage entry/u);
});

test("invalid authored widget identity prevents both writes even after route derivation succeeds", t => {
  const f = fixture(t);
  f.write("packages/catch_ui/lib/src/components/catch_menu.dart", "class CatchMenu extends StatelessWidget {}\n");
  const sourceSha = f.commit();
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /no component-registry identity/);
  assert.equal(f.read(routePath), "stale route inventory\n");
  assert.match(f.read(catalogPath), /Stale rows/u);
});

test("invalid route ownership and malformed catalog boundaries cannot partially materialize", t => {
  const f = fixture(t);
  f.write("lib/routing/go_router.dart", "GoRouter router() { return GoRouter(routes: []); }\n");
  let sourceSha = f.commit();
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /not wired/);
  assert.equal(f.read(routePath), "stale route inventory\n");
  f.write("lib/routing/go_router.dart", "GoRouter router() { return GoRouter(routes: [GoRoute(path: '/', name: Routes.home.name, builder: (_) => const HomeScreen())]); }\n");
  f.write(catalogPath, `${catalogStart}\n${catalogEnd}\n${catalogStart}`);
  sourceSha = f.commit();
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /exactly one/);
  assert.equal(f.read(routePath), "stale route inventory\n");
});

test("symlink destinations are rejected without modifying their targets", t => {
  const f = fixture(t);
  const target = path.join(f.root, "authored-coverage.json");
  const before = fs.readFileSync(target);
  fs.unlinkSync(path.join(f.root, routePath));
  fs.symlinkSync(target, path.join(f.root, routePath));
  const sourceSha = f.commit();
  assert.throws(() => materializeInventories({repoRoot: f.root, sourceSha}), /symlink/);
  assert.deepEqual(fs.readFileSync(target), before);
});
