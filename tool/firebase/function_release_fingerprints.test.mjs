import test from "node:test";
import assert from "node:assert/strict";
import {createRequire} from "node:module";
import {fingerprintRuntimeExports, compareFunctionFingerprints} from "./function_release_fingerprints.mjs";

const ts = createRequire(import.meta.url)("typescript");

const exports = ["functions:alpha", "functions:beta"];
function map(alpha = "function alpha() { return helper(); }", helper = "function helper() { return 1; }", extra = "") {
  return new Map([
    ["index.js", 'const api = require("./api"); Object.defineProperty(exports, "alpha", {get: function() { return api.alpha; }}); Object.defineProperty(exports, "beta", {get: function() { return api.beta; }});'],
    ["api.js", 'exports.alpha = alpha; exports.beta = beta; ' + alpha + ' function beta() { return 2; } ' + helper + extra],
  ]);
}
const snapshot = (modules) => fingerprintRuntimeExports({modules, targets: exports});
const delta = (before, after) => compareFunctionFingerprints(snapshot(before), snapshot(after), {authorizedTargets: exports});

test("shared file changes only the reachable exported behavior", () => {
  assert.deepEqual(delta(map(), map("function alpha() { return helper() + 1; }")).targets, ["functions:alpha"]);
});
test("noncanonical interop markers cannot hide a changed default import", () => {
  const modules = new Map([
    ["index.js", 'const api = require("./api"); exports.alpha = api.alpha; exports.beta = api.beta;'],
    ["api.js", 'var __importDefault = (this && this.__importDefault) || function (mod) {\n    return (mod && mod.__esModule) ? mod : { "default": mod };\n}; const m_1 = __importDefault(require("./m")); exports.alpha = () => m_1.default(); exports.beta = () => 2;'],
    ["m.js", 'Object.defineProperty(exports,"__esModule",{value:true}); exports.default = () => 1;'],
  ]);
  const before = new Map(modules);
  snapshot(modules);
  modules.set("m.js", 'Object.defineProperty(exports,"__esModule",{value:false}); exports.default = () => 1;');
  assert.throws(() => snapshot(modules), /Unsupported __esModule descriptor/);
  modules.set("m.js", 'exports.default = () => 1;');
  assert.ok(delta(before, modules).targets.includes("functions:alpha"));
  modules.set("m.js", 'Object.defineProperty(exports,"__esModule",{value:true}, sideEffect()); exports.default = () => 1;');
  assert.throws(() => snapshot(modules), /Unsupported __esModule descriptor/);
});
test("re-export descriptors cannot hide eager expression changes", () => {
  const modules = map();
  modules.set("index.js", 'const api=require("./api"); Object.defineProperty(exports,"alpha",{get:function(){return api.alpha},enumerable:(global.value=1)}); Object.defineProperty(exports,"beta",{get:function(){return api.beta}});');
  assert.throws(() => snapshot(modules), /Unsupported export descriptor/);
  modules.set("index.js", 'const api=require("./api"); Object.defineProperty(exports,"alpha",{get:function(){return api.alpha},get:function(){return api.beta}}); Object.defineProperty(exports,"beta",{get:function(){return api.beta}});');
  assert.throws(() => snapshot(modules), /Unsupported export descriptor/);
});
test("canonical TypeScript void export chains preserve namespace trust", () => {
  const compiled = ts.transpileModule('import * as api from "./api"; export const alpha = () => api.value(); export const beta = () => 2;',
    {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true}}).outputText;
  const chain = 'exports.beta = exports.alpha = void 0;';
  assert.ok(compiled.includes(chain));
  const modules = new Map([["index.js", compiled], ["api.js", 'exports.value = () => 1;']]);
  assert.deepEqual(snapshot(modules).functions["functions:alpha"].unknown, []);
  modules.set("index.js", compiled.replace(chain, 'exports.beta = exports.alpha = global.sideEffect();'));
  assert.throws(() => snapshot(modules), /Duplicate or computed export/);
  modules.set("index.js", compiled.replace(chain, 'exports.beta = exports[(global.value = 1, "alpha")] = void 0;'));
  assert.throws(() => snapshot(modules), /Unsupported compiler wrapper namespace|Duplicate or computed export/);
});
test("class receivers do not impersonate a CommonJS wrapper namespace", () => {
  const compiled = ts.transpileModule('import * as dep from "./dep"; class Provider { base() { return this.value; } value = 1; read() { return this.base() + dep.value(); } } const provider = new Provider(); export const alpha = () => provider.read(); export const beta = () => 2;',
    {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true}}).outputText;
  const modules = new Map([["index.js", compiled], ["dep.js", "exports.value = () => 1;"]]);
  assert.deepEqual(snapshot(modules).functions["functions:alpha"].unknown, []);
  modules.set("index.js", compiled + "\nthis.escaped = 1;");
  assert.throws(() => snapshot(modules), /Unsupported compiler wrapper namespace/);
  modules.set("index.js", compiled + "\nfunction escaped() { this.escaped = 1; }");
  assert.throws(() => snapshot(modules), /Unsupported compiler wrapper namespace/);
});
for (const [kind, members] of [
  ["method", "[Object.defineProperty(this,'fn',{get(){global.value=1}})](){}[Object.defineProperty(this,'other',{get(){global.value=2}})](){}"],
  ["field", "[Object.defineProperty(this,'fn',{get(){global.value=1}})];[Object.defineProperty(this,'other',{get(){global.value=2}})];"],
]) {
  test(`computed class ${kind} names retain enclosing CommonJS namespace effects`, () => {
    const before = map(), after = map();
    for (const [modules, name] of [[before, "fn"], [after, "other"]]) {
      modules.set("m.js", 'exports.fn=fn;exports.other=other;function fn(){}function other(){}class Patch{' + members + '}');
      modules.set("api.js", 'const m=require("./m");const unused={fn:m.' + name + '};exports.alpha=alpha;exports.beta=beta;function alpha(){return global.value}function beta(){return 2}');
    }
    assert.deepEqual(delta(before, after).targets, exports);
  });
  test(`computed class ${kind} names cannot preserve compiler wrapper namespace trust`, () => {
    const compiled = ts.transpileModule('import * as dep from "./dep"; export const alpha = () => dep.value(); export const beta = () => 2;',
      {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true}}).outputText;
    const modules = new Map([["index.js", compiled + '\nclass Patch{' + members + '}'], ["dep.js", 'exports.value = () => 1;']]);
    assert.throws(() => snapshot(modules), /Unsupported compiler wrapper namespace/);
  });
}
test("ordinary class bodies and initializers keep their receivers across nested computed names", () => {
  const compiled = ts.transpileModule('import * as dep from "./dep"; class Provider { value = (() => { this.ready = 1; return 1; })(); static label = this.name; static { this.ready = true; } constructor() { this.value = 1; } child = class { [this.value]() {} }; read() { class Nested { [this.value]() {} } return (() => this.value + dep.value())(); } get current() { return this.value; } set current(value) { this.value = value; } } const provider = new Provider(); export const alpha = () => provider.read(); export const beta = () => 2;',
    {compilerOptions: {module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true}}).outputText;
  const modules = new Map([["index.js", compiled], ["dep.js", 'exports.value = () => 1;']]);
  const result = snapshot(modules);
  for (const target of exports) assert.deepEqual(result.functions[target].unknown, []);
});
test("transitive private helper changes select its consumer only", () => {
  assert.deepEqual(delta(map(), map(undefined, "function helper() { return 3; }")).targets, ["functions:alpha"]);
});
test("comments and source-map metadata do not change behavior fingerprints", () => {
  assert.deepEqual(delta(map(), map(undefined, undefined, "\n// comment\n//# sourceMappingURL=api.js.map")).targets, []);
});
test("shorthand object properties retain their value dependencies", () => {
  assert.deepEqual(delta(map("function alpha() { return {helper}; }"), map("function alpha() { return {helper}; }", "function helper() { return 3; }")).targets, ["functions:alpha"]);
});
test("alias exports preserve a common implementation dependency", () => {
  const before = map(); const after = map("function alpha() { return 3; }");
  for (const modules of [before, after]) modules.set("api.js", modules.get("api.js").replace("exports.beta = beta", "exports.beta = alpha"));
  assert.deepEqual(delta(before, after).targets, exports);
});
test("cycles terminate and remain observable", () => {
  assert.deepEqual(delta(map("function alpha() { return helper(); }", "function helper() { return alpha(); }"), map("function alpha() { return helper() + 1; }", "function helper() { return alpha(); }")).targets, ["functions:alpha"]);
});
test("fixed package-local dynamic assets do not broaden unrelated exports", () => {
  const dynamic = 'async function beta() { const root = path.resolve(__dirname); const adapter = path.join(root, "ops", "adapter.mjs"); return import(url.pathToFileURL(adapter).href); }';
  const before = map(); const after = map("function alpha() { return 3; }");
  for (const modules of [before, after]) {
    modules.set("api.js", 'const path = require("node:path"); const url = require("node:url"); ' + modules.get("api.js").replace("function beta() { return 2; }", dynamic));
    modules.set("ops/adapter.mjs", "export const value = 1;");
  }
  assert.deepEqual(delta(before, after).targets, ["functions:alpha"]);
});
test("changed dynamic-load consumer fails closed rather than deploying all", () => {
  const before = map("function alpha() { return require(process.env.MODULE); }");
  const after = map("function alpha() { return require(process.env.MODULE).updated; }");
  assert.throws(() => delta(before, after), /Unknown runtime impact/);
});
test("side-effect initialization affects every observing export", () => {
  assert.deepEqual(delta(map(undefined, undefined, "global.configure(1);"), map(undefined, undefined, "global.configure(2);")).targets, exports);
});
test("unused external imports remain observable initialization", () => {
  assert.deepEqual(delta(map(undefined, undefined, 'const external = require("first");'), map(undefined, undefined, 'const external = require("second");')).targets, exports);
});
test("missing local runtime modules and unsupported bindings stop analysis", () => {
  const modules = map(); modules.set("api.js", 'const {value} = require("./missing"); exports.alpha = value;');
  assert.throws(() => snapshot(modules), /Unsupported runtime binding/);
});
test("an incomplete baseline cannot silently classify exports unchanged", () => {
  const before = snapshot(map()); delete before.functions["functions:beta"];
  assert.throws(() => compareFunctionFingerprints(before, snapshot(map()), {authorizedTargets: exports}), /Baseline export inventory/);
});

test("arbitrary dynamic loading cannot hide changes elsewhere in the package", () => {
  const before = map("function alpha() { return require(process.env.MODULE); }");
  const after = new Map(before); before.set("data.js", "exports.value = 1;"); after.set("data.js", "exports.value = 2;");
  assert.throws(() => delta(before, after), /Unknown runtime impact/);
});
test("aliased loaders stop when any potentially loaded runtime bytes change", () => {
  const before = map("function alpha() { const load = require; return load('./data'); }");
  const after = new Map(before); before.set("data.js", "exports.value = 1;"); after.set("data.js", "exports.value = 2;");
  assert.throws(() => delta(before, after), /Unknown runtime impact/);
});
test("shadowed require cannot be mistaken for the Node loader", () => {
  assert.throws(() => snapshot(map(undefined, undefined, 'function require(name) { return {}; }')), /Shadowed require/);
});
test("class static effects and getter initialization remain observable", () => {
  assert.deepEqual(delta(map(undefined, undefined, 'class Unused { static { global.value = 1; } }'), map(undefined, undefined, 'class Unused { static { global.value = 2; } }')).targets, exports);
  assert.deepEqual(delta(map(undefined, undefined, 'const discarded = state.first;'), map(undefined, undefined, 'const discarded = state.second;')).targets, exports);
});
test("side effects in void exports are not compiler initialization", () => {
  assert.deepEqual(delta(map(undefined, undefined, 'exports.placeholder = void(global.value = 1);'), map(undefined, undefined, 'exports.placeholder = void(global.value = 2);')).targets, exports);
});
test("import evaluation order and lexical initialization order cannot disappear", () => {
  const before = map(); const after = map();
  before.set("api.js", 'const a = require("./a"); const b = require("./b"); ' + before.get("api.js"));
  after.set("api.js", 'const b = require("./b"); const a = require("./a"); ' + after.get("api.js"));
  for (const modules of [before, after]) { modules.set("a.js", "global.value = 1;"); modules.set("b.js", "global.value = 2;"); }
  assert.deepEqual(delta(before, after).targets, exports);
  assert.throws(() => snapshot(map(undefined, undefined, "const a = b; const b = 1;")), /Unsafe initialization order/);
});


test("stored local data-export functions do not execute during dependency-object creation", () => {
  const before = map(); const after = map("function alpha() { return 3; }");
  for (const modules of [before, after]) {
    modules.set("api.js", 'const service = require("./service"); const deps = {handler: service.work}; ' + modules.get("api.js"));
    modules.set("service.js", 'exports.work = work; function work() { return 1; }');
  }
  after.set("service.js", 'exports.work = work; function work() { return 2; }');
  assert.deepEqual(delta(before, after).targets, ["functions:alpha"]);
});
test("adding an already initialized local import is a cached no-op", () => {
  const before = map(), after = map();
  for (const modules of [before, after]) {
    modules.set("index.js", 'const shared = require("./shared"); ' + modules.get("index.js"));
    modules.set("shared.js", 'global.value = 1; exports.work = work; function work() {}');
  }
  after.set("api.js", 'const cached = require("./shared"); ' + after.get("api.js"));
  assert.deepEqual(delta(before, after).targets, []);
});
test("SDK callback factories remain eager and their side effects affect every export", () => {
  const before = map(), after = map();
  for (const [modules, value] of [[before, 1], [after, 2]]) modules.set("api.js",
    'const sdk = require("firebase-functions/v2/https"); const ext = require("unknown"); ' +
    'function makeHandler() { global.effect = ' + value + '; return () => 1; } ' +
    'exports.alpha = sdk.onCall({memory:ext.memory}, makeHandler()); exports.beta = beta; function beta() { return 2; }');
  assert.deepEqual(delta(before, after).targets, exports);
});
test("unknown callback consumers and mutable exported getters stay conservative", () => {
  const before = map(), after = map(undefined, "function helper() { return 3; }");
  for (const modules of [before, after]) modules.set("api.js", modules.get("api.js") + ' unknown.consume({callback:helper});');
  assert.deepEqual(delta(before, after).targets, exports);
  const modules = map(); modules.set("getter.js", 'Object.defineProperty(exports,"work",{get:function(){ global.value=1; return ()=>1; }});');
  modules.set("api.js", 'const service = require("./getter"); const deps = {handler:service.work}; ' + modules.get("api.js"));
  assert.throws(() => snapshot(modules), /Unsupported export getter/);
});

test("unknown SDK factories cannot silently defer their callbacks", () => {
  const before = map(), after = map();
  for (const [modules, value] of [[before, 1], [after, 2]]) modules.set("api.js",
    'const sdk = require("firebase-functions"); const initialize = sdk.onUnknown(() => { global.effect=' + value + '; }); ' +
    'exports.alpha = alpha; exports.beta = beta; function alpha() { return 1; } function beta() { return 2; }');
  assert.deepEqual(delta(before, after).targets, exports);
});

test("consumer namespace mutation invalidates imported function purity", () => {
  const before=map(),after=map();
  for (const [modules, name] of [[before,"fn"],[after,"other"]]) {
    modules.set("m.js", 'exports.fn=fn; exports.other=other; function fn(){} function other(){}');
    modules.set("api.js", 'const m=require("./m"); Object.defineProperty(m,"fn",{get(){global.value=1}}); Object.defineProperty(m,"other",{get(){global.value=2}}); const unused={fn:m.'+name+'}; exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});
test("mutated SDK factories cannot suppress eagerly invoked callbacks", () => {
  const before=map(),after=map();
  for (const [modules,value] of [[before,1],[after,2]]) modules.set("api.js", 'const sdk=require("firebase-functions/v2/https"); sdk.onCall=callback=>callback(); const unused=sdk.onCall(()=>{global.value='+value+'}); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.deepEqual(delta(before,after).targets,exports);
});
test("helper parameter shadowing cannot be mistaken for the SDK namespace", () => {
  const before=map(),after=map();
  for (const [modules,value] of [[before,1],[after,2]]) modules.set("api.js", 'const sdk=require("firebase-functions/v2/https"); function make(sdk){return sdk.onCall(()=>{global.value='+value+'})} const other={onCall:cb=>cb()}; const unused=make(other); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.deepEqual(delta(before,after).targets,exports);
});
test("cyclic imports preserve observable export assignment order", () => {
  const before=map(),after=map();
  for (const modules of [before,after]) {
    modules.set("api.js", 'const a=require("./a"); exports.alpha=alpha; exports.beta=beta; function alpha(){return a.value} function beta(){return 2}');
    modules.set("b.js", 'const a=require("./a"); exports.value=typeof a.fn;');
  }
  before.set("a.js", 'const b=require("./b"); exports.fn=()=>1; exports.value=b.value;');
  after.set("a.js", 'exports.fn=()=>1; const b=require("./b"); exports.value=b.value;');
  assert.deepEqual(delta(before,after).targets,exports);
});
test("dynamic loader parameters never resolve to unrelated outer constants", () => {
  const before=map(),after=map();
  for (const modules of [before,after]) {
    modules.set("api.js", 'const target="/package/asset.mjs"; function load(target){return import(target)}; exports.alpha=()=>load("./data.mjs"); exports.beta=beta; function beta(){return 2}');
    modules.set("asset.mjs", 'export const value=1;');
  }
  before.set("data.mjs", 'export const value=1;');after.set("data.mjs", 'export const value=2;');
  assert.throws(()=>delta(before,after),/Unknown runtime impact/);
});

test("shadowed helper callees cannot borrow unrelated pure module implementations", () => {
  const before=map(),after=map();
  for (const [modules,value] of [[before,1],[after,2]]) modules.set("api.js", 'function f(){return 1} function make(f){return f()} function effect(){global.value='+value+';return 1} const unused=make(effect); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.deepEqual(delta(before,after).targets,exports);
});
test("shadowed collection constructors cannot be mistaken for native builtins", () => {
  const before=map(),after=map();
  for (const [modules,value] of [[before,1],[after,2]]) modules.set("api.js", 'function make(Map){return new Map()} class Custom {constructor(){global.value='+value+'}} const unused=make(Custom); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.deepEqual(delta(before,after).targets,exports);
});

test("reassigned helper declarations never prove eager calls pure", () => {
  const before=map(),after=map();
  for (const [modules,callee] of [[before,"a"],[after,"b"]]) modules.set("api.js", 'function a(){return null} function b(){return null} a=()=>{global.value=1}; b=()=>{global.value=2}; const discarded='+callee+'(); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.deepEqual(delta(before,after).targets,exports);
});
test("constructor failure and overwritten globals remain observable module evaluation", () => {
  const before=map(undefined,undefined,'const discarded=new Map([1]);'),after=map(undefined,undefined,'const discarded=new Set([1]);');
  assert.deepEqual(delta(before,after).targets,exports);
  assert.deepEqual(delta(map(undefined,undefined,'global.Map=class {constructor(x){global.value=x}}; const discarded=new Map(1);'),map(undefined,undefined,'global.Map=class {constructor(x){global.value=x}}; const discarded=new Map(2);')).targets,exports);
});
test("coercion and BigInt exceptions never disappear behind operator purity", () => {
  assert.deepEqual(delta(map(undefined,undefined,'const value={valueOf(){global.result=1;return 1}}; const unused=+value;'),map(undefined,undefined,'const value={valueOf(){global.result=1;return 1}}; const unused=!value;')).targets,exports);
  assert.deepEqual(delta(map(undefined,undefined,'const unused=1n/0n;'),map(undefined,undefined,'const unused=1n/1n;')).targets,exports);
});

test("shared namespaces inherit mutation distrust from another module", () => {
  const before=map(),after=map();
  for (const [modules,name] of [[before,"fn"],[after,"other"]]) {
    modules.set("m.js", 'exports.fn=fn; exports.other=other; function fn(){} function other(){}');
    modules.set("patch.js", 'const m=require("./m"); Object.defineProperty(m,"fn",{get(){global.value=1}}); Object.defineProperty(m,"other",{get(){global.value=2}});');
    modules.set("api.js", 'require("./patch"); const m=require("./m"); const unused={fn:m.'+name+'}; exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});
test("shared SDK factory mutation invalidates every importing consumer", () => {
  const before=map(),after=map();
  for (const [modules,value] of [[before,1],[after,2]]) {
    modules.set("patch.js", 'const sdk=require("firebase-functions/v2/https"); sdk.onCall=callback=>callback();');
    modules.set("api.js", 'require("./patch"); const sdk=require("firebase-functions/v2/https"); const unused=sdk.onCall(()=>{global.value='+value+'}); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});

test("namespace distrust survives nested identifiers reusing another import name", () => {
  const before=map(),after=map();
  for (const [modules,name] of [[before,"fn"],[after,"other"]]) {
    modules.set("m.js", 'exports.fn=fn; exports.other=other; function fn(){} function other(){}');
    modules.set("other.js", 'exports.fn=()=>1;');
    modules.set("patch.js", 'const shared=require("./m"); Object.defineProperty(shared,"fn",{get(){global.value=1}}); Object.defineProperty(shared,"other",{get(){global.value=2}}); function untouched(){const shared=require("./other");return shared.fn}');
    modules.set("api.js", 'require("./patch"); const m=require("./m"); const unused={fn:m.'+name+'}; exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});
test("escaping direct require results invalidate the same cached namespace", () => {
  const before=map(),after=map();
  for (const [modules,name] of [[before,"fn"],[after,"other"]]) {
    modules.set("m.js", 'exports.fn=fn; exports.other=other; function fn(){} function other(){}');
    modules.set("patch.js", 'Object.defineProperty(require("./m"),"fn",{get(){global.value=1}}); Object.defineProperty(require("./m"),"other",{get(){global.value=2}});');
    modules.set("api.js", 'require("./patch"); const m=require("./m"); const unused={fn:m.'+name+'}; exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});

test("custom compiler-wrapper names require investigation rather than purity", () => {
  const modules=map();
  modules.set("m.js", 'exports.fn=()=>1;');
  modules.set("api.js", 'function __importStar(x){global.value=1;return x} const m=__importStar(require("./m")); exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  assert.throws(()=>snapshot(modules),/Unsupported compiler wrapper/);
});
test("escaping wrapped require results never preserve namespace trust", () => {
  const before=map(),after=map();
  for (const [modules,name] of [[before,"fn"],[after,"other"]]) {
    modules.set("m.js", 'exports.fn=fn; exports.other=other; function fn(){} function other(){}');
    modules.set("patch.js", 'function __importDefault(m){return {default:m}} Object.defineProperty(__importDefault(require("./m")).default,"fn",{get(){global.value=1}}); Object.defineProperty(__importDefault(require("./m")).default,"other",{get(){global.value=2}});');
    modules.set("api.js", 'require("./patch"); const m=require("./m"); const unused={fn:m.'+name+'}; exports.alpha=alpha; exports.beta=beta; function alpha(){return global.value} function beta(){return 2}');
  }
  assert.deepEqual(delta(before,after).targets,exports);
});
