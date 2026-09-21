import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {fromRepo} from '../lib/repo_paths.mjs';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'catch-capture-'));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  const write = (name, content) => {
    const file = path.join(root, name);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, content);
    return file;
  };
  for (const name of ['tool/lib/repo_paths.mjs', 'tool/marketing/sync_website_media.mjs',
    'tool/marketing/export_app_screenshots.mjs', 'tool/ui_capture/run_captures.mjs']) {
    write(name, fs.readFileSync(fromRepo(name)));
  }
  const capture = {
    id: 'sample', status: 'active', audience: 'host', surface: 'Today',
    device: 'iphone-17-pro', fixtureKey: 'salesDemo.sample',
    sourcePath: 'artifacts/sample.png',
    websitePath: 'website/public/assets/app-screenshots/sample.png',
    placeholderPath: 'website/public/assets/app-screenshots/placeholders/sample.svg',
    alt: 'Synthetic Today screen', caption: 'Today', walkthroughStep: '1',
  };
  write('tool/marketing/capture_manifest.json', JSON.stringify({version: 1, updated: '2026-09-21', captures: [capture]}));
  write(capture.sourcePath, 'first image bytes');
  write('test/ui_captures/catalog/screen_capture_catalog.dart', `
    ScreenCaptureEntry(id: 'sample_screen', routeIds: const <String>['today'],
      marketingFixtureKeys: const <String>['salesDemo.sample'], device: CaptureDevice.iphone17Pro)
  `);
  const calls = path.join(root, 'calls.jsonl');
  // Stub only external render/frame executables. The actual Node wrappers run.
  const fakeCommand = name => {
    const file = write(`bin/${name}`, `#!${process.execPath}\n` +
      `require('node:fs').appendFileSync(process.env.CAPTURE_TEST_CALLS, JSON.stringify({name: ${JSON.stringify(name)}, args: process.argv.slice(2)})+'\\n');\n`);
    fs.chmodSync(file, 0o755);
  };
  fakeCommand('flutter');
  fakeCommand('dart');
  const run = (script, ...args) => spawnSync(process.execPath, [path.join(root, script), ...args], {
    encoding: 'utf8', cwd: root,
    env: {...process.env, PATH: `${path.join(root, 'bin')}${path.delimiter}${process.env.PATH}`, CAPTURE_TEST_CALLS: calls},
  });
  const readCalls = () => fs.readFileSync(calls, 'utf8').trim().split('\n').map(JSON.parse);
  return {root, write, capture, run, readCalls};
}

const sync = 'tool/marketing/sync_website_media.mjs';
test('sync checks image bytes, catches replacement and missing files, and repairs copies', t => {
  const f = fixture(t);
  assert.equal(f.run(sync, '--update').status, 0);
  assert.equal(f.run(sync, '--check').status, 0);
  f.write(f.capture.websitePath, 'unreviewed destination bytes');
  let result = f.run(sync, '--check');
  assert.equal(result.status, 1);
  assert.match(result.stderr, /differs from the app capture source/);
  fs.unlinkSync(path.join(f.root, f.capture.websitePath));
  result = f.run(sync, '--check');
  assert.equal(result.status, 1);
  assert.match(result.stderr, /website image is missing/);
  assert.equal(f.run(sync, '--update').status, 0);
  f.write(f.capture.sourcePath, 'new reviewed source image');
  assert.equal(f.run(sync, '--check').status, 1);
  assert.equal(f.run(sync, '--update').status, 0);
  assert.equal(f.run(sync, '--check').status, 0);
});

test('product exporter forwards native iOS and final raster scale through the actual capture CLI', t => {
  const f = fixture(t);
  const font = f.write('fonts/Native Font.ttf', 'font fixture');
  const result = f.run('tool/marketing/export_app_screenshots.mjs', '--update', '--ids', 'sample', '--sf-font', font);
  assert.equal(result.status, 0, result.stderr);
  const calls = f.readCalls();
  assert.deepEqual(calls.map(c => c.name), ['flutter', 'dart']);
  const args = calls[0].args;
  for (const expected of ['--dart-define=CAPTURE_PLATFORM=ios', '--dart-define=CAPTURE_DPR=2',
    '--dart-define=CAPTURE_DEVICE_ID=iphone-17-pro', `--dart-define=CAPTURE_SF_FONT=${font}`]) {
    assert.ok(args.includes(expected), expected);
  }
  assert.ok(!args.includes('--update-goldens'));
});

test('review CLI preserves default renderer and rejects invalid platform or font requests', t => {
  const f = fixture(t);
  const cli = 'tool/ui_capture/run_captures.mjs';
  assert.equal(f.run(cli, '--ids', 'sample_screen').status, 0);
  assert.ok(!f.readCalls()[0].args.some(arg => arg.startsWith('--dart-define=CAPTURE_PLATFORM=')));
  assert.equal(f.run(cli, '--platform', 'unknown').status, 64);
  assert.equal(f.run(cli, '--platform', 'ios', '--sf-font', path.join(f.root, 'absent.ttf')).status, 64);
  const font = f.write('fonts/local.ttf', 'font fixture');
  assert.equal(f.run(cli, '--platform', 'android', '--sf-font', font).status, 64);
  assert.equal(f.run('tool/marketing/export_app_screenshots.mjs', '--update', '--sf-font', path.join(f.root, 'absent.ttf')).status, 1);
  assert.equal(f.readCalls().length, 1, 'invalid requests must not run a renderer');
});
