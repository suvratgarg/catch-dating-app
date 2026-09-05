#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {parseArgs} from "node:util";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const projects = ["ios", "apps/consumer/ios", "apps/host/ios"];

// Keep each Podfile self-contained: Flutter's CocoaPods freshness check and
// CocoaPods' checksum watch that file, not Ruby helpers it might require.
export const iosPodPolicyOutputs = Object.freeze([
  {template: "ios/Podfile.template", outputs: projects.map((project) => `${project}/Podfile`)},
  {template: "ios/Flutter/CatchBuildSettings.xcconfig.template",
    outputs: projects.map((project) => `${project}/Flutter/CatchBuildSettings.xcconfig`)},
]);

export function syncIosPodPolicy({repoRoot = root, write = false} = {}) {
  // Read every authored input before changing any output. Preserve bytes, so
  // adopting generation does not invalidate the existing Podfile.lock hashes.
  const expected = iosPodPolicyOutputs.flatMap(({template, outputs}) => {
    const contents = fs.readFileSync(path.join(repoRoot, template));
    if (contents.length === 0) throw new Error(`Empty iOS policy template: ${template}`);
    return outputs.map((output) => ({output, contents}));
  });
  const stale = expected.filter(({output, contents}) => {
    const filename = path.join(repoRoot, output);
    return !fs.existsSync(filename) || !fs.readFileSync(filename).equals(contents);
  });
  if (write) {
    for (const {output, contents} of stale) {
      const filename = path.join(repoRoot, output);
      fs.mkdirSync(path.dirname(filename), {recursive: true});
      const temporary = `${filename}.${process.pid}.tmp`;
      try {
        fs.writeFileSync(temporary, contents, {flag: "wx"});
        fs.renameSync(temporary, filename);
      } finally {
        fs.rmSync(temporary, {force: true});
      }
    }
  }
  return stale.map(({output}) => output);
}

function main() {
  const {values} = parseArgs({options: {
    check: {type: "boolean"}, write: {type: "boolean"}, help: {type: "boolean"},
  }});
  if (values.help) {
    console.log("Usage: node tool/platform/sync_ios_pod_policy.mjs [--check | --write]");
    return;
  }
  if (values.check && values.write) throw new Error("Choose --check or --write, not both.");
  const stale = syncIosPodPolicy({write: values.write === true});
  if (stale.length && !values.write) {
    console.error(`Stale generated iOS policy:\n${stale.join("\n")}\nRun node tool/platform/sync_ios_pod_policy.mjs --write`);
    process.exitCode = 1;
  } else {
    console.log(values.write ? `Updated ${stale.length} iOS policy file(s).` : "Generated iOS policy is current.");
  }
}

if (process.argv[1] && fs.realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { main(); } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
