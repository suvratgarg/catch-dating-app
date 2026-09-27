'use strict';
/* eslint-disable @typescript-eslint/no-require-imports, max-len */

const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const {pathToFileURL} = require('node:url');

const root = path.resolve(__dirname, '../../../..');
const out = path.join(root, 'functions', 'lib');
const files = [
  'operations/src/platform/budget.mjs',
  'operations/src/platform/canonical-json.mjs',
  'operations/src/platform/contracts.mjs',
  'operations/src/platform/engine.mjs',
  'operations/src/platform/errors.mjs',
  'operations/src/platform/json-schema.mjs',
  'operations/src/platform/model/guarded-model-runner.mjs',
  'operations/src/platform/storage/file-store.mjs',
  'operations/src/workflows/outreach-drafting/manifest.json',
  'operations/src/workflows/outreach-drafting/workflow.mjs',
  'operations/src/workflows/outreach-drafting/sales-adapter.mjs',
  'contracts/operations/outreach_drafting_input.schema.json',
  'contracts/operations/outreach_drafting_selection.schema.json',
  'contracts/operations/outreach_drafting_draft.schema.json',
  'contracts/operations/outreach_drafting_approval.schema.json',
];
const check = process.argv.includes('--check');
const digest = (bytes) => crypto.createHash('sha256').update(bytes).digest('hex');

async function main() {
  if (!fs.existsSync(path.join(out, 'admin', 'salesIntelligence', 'runtime.js'))) {
    throw new Error('Compile Functions before copying the Operations runtime.');
  }
  for (const file of files) {
    const source = path.join(root, file);
    const target = path.join(out, file);
    if (!fs.statSync(source).isFile()) {
      throw new Error(`Missing allowlisted Operations dependency: ${file}`);
    }
    if (!check) {
      fs.mkdirSync(path.dirname(target), {recursive: true});
      fs.copyFileSync(source, target);
    }
    if (!fs.existsSync(target) ||
        digest(fs.readFileSync(source)) !== digest(fs.readFileSync(target))) {
      throw new Error(`Stale Operations runtime dependency: ${file}`);
    }
  }
  const module = await import(pathToFileURL(path.join(out,
      'operations/src/workflows/outreach-drafting/workflow.mjs')).href);
  const workflow = new module.OutreachDraftingWorkflow({repoRoot: out});
  workflow.contracts();
  if (workflow.workflowId !== 'outreach-drafting') {
    throw new Error('Unexpected bundled Operations workflow.');
  }
  process.stdout.write(`Sales outreach runtime ${check ? 'fresh' : 'copied'}: ${files.length} allowlisted files.\n`);
}
main().catch((error) => {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
});
