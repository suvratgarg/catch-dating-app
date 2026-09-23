// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import '../lib/src/fingerprint_extractor.dart';

void main(List<String> rawArgs) {
  final parser = ArgParser()
    ..addOption(
      'files',
      help:
          'Comma-separated Dart files to scan. When omitted, --classification supplies the target inventory.',
    )
    ..addOption(
      'classification',
      help:
          'Repo-relative or absolute classification JSON used for target discovery and widget metadata.',
    )
    ..addOption(
      'out',
      defaultsTo: 'artifacts/widget_dedupe/fingerprints.json',
      help: 'Output JSON path.',
    )
    ..addFlag(
      'retirement',
      negatable: false,
      help:
          'Scan repository Dart references; emit an advisory retirement report to stdout.',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print usage.');

  late ArgResults args;
  try {
    args = parser.parse(rawArgs);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }

  if (args.flag('help')) {
    stdout.writeln(
      'Usage: dart run --packages=tool/widget_dedupe/.dart_tool/package_config.json '
      'tool/widget_dedupe/bin/extract_fingerprints.dart '
      '[--files a.dart,b.dart] [--classification path] [--out path]',
    );
    stdout.writeln(parser.usage);
    return;
  }

  final repoRoot = _findRepoRoot(Directory.current);
  if (args.flag('retirement')) {
    if (args.wasParsed('files') ||
        args.wasParsed('classification') ||
        args.wasParsed('out')) {
      stderr.writeln(
        '--retirement scans the full repository and writes only stdout.',
      );
      exitCode = 64;
      return;
    }
    final listing = Process.runSync('git', [
      'ls-files',
      '-z',
      '--cached',
      '--others',
      '--exclude-standard',
      '--',
      '*.dart',
    ], workingDirectory: repoRoot.path);
    if (listing.exitCode != 0) {
      stderr.write(listing.stderr);
      exitCode = 1;
      return;
    }
    final deletedResult = Process.runSync('git', [
      'ls-files',
      '-z',
      '--deleted',
    ], workingDirectory: repoRoot.path);
    if (deletedResult.exitCode != 0) {
      stderr.write(deletedResult.stderr);
      exitCode = 1;
      return;
    }
    final deleted = (deletedResult.stdout as String).split('\u0000').toSet();
    final sources = <String, String>{};
    for (final relative in (listing.stdout as String).split('\u0000').toSet()) {
      if (relative.isEmpty ||
          relative.startsWith('vendor/') ||
          relative.startsWith('third_party/'))
        continue;
      if (deleted.contains(relative)) continue;
      final file = File(p.join(repoRoot.path, relative));
      if (file.existsSync()) {
        sources[relative] = file.readAsStringSync();
      } else {
        // Sparse checkout: indexed source still participates in the scan.
        final indexed = Process.runSync('git', [
          'show',
          ':$relative',
        ], workingDirectory: repoRoot.path);
        if (indexed.exitCode != 0) {
          stderr.writeln('Cannot read $relative; retirement scan aborted.');
          exitCode = 1;
          return;
        }
        sources[relative] = indexed.stdout as String;
      }
    }
    if (sources.isEmpty) {
      stderr.writeln('No Dart sources discovered; retirement scan aborted.');
      exitCode = 1;
      return;
    }
    final report = analyzeRetirementSources(sources);
    final revision = Process.runSync('git', [
      'rev-parse',
      'HEAD',
    ], workingDirectory: repoRoot.path);
    report['revision'] = revision.exitCode == 0
        ? (revision.stdout as String).trim()
        : null;
    report['snapshot'] = 'working-tree; sourceDigest includes dirty source';
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    if ((report['failures'] as List).isNotEmpty) exitCode = 1;
    return;
  }
  final files = (args.option('files') ?? '')
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
  final classificationPath = args.option('classification')?.trim();
  if (files.isEmpty &&
      (classificationPath == null || classificationPath.isEmpty)) {
    stderr.writeln(
      '--classification is required when --files is not supplied.',
    );
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }
  final outPath = p.normalize(p.join(repoRoot.path, args.option('out')!));

  final result = extractFingerprints(
    repoRoot: repoRoot.path,
    files: files.isEmpty ? null : files,
    classificationPath: classificationPath == null || classificationPath.isEmpty
        ? null
        : classificationPath,
  );

  final output = File(outPath);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(result)}\n',
  );
  stdout.writeln(
    'Wrote ${p.relative(outPath, from: repoRoot.path)} '
    '(${(result['widgets'] as List<Object?>).length} widgets, '
    '${(result['failures'] as List<Object?>).length} failures).',
  );
}

Directory _findRepoRoot(Directory start) {
  var current = start.absolute;
  while (true) {
    if (File(p.join(current.path, 'pubspec.yaml')).existsSync() &&
        Directory(p.join(current.path, 'lib')).existsSync() &&
        Directory(p.join(current.path, 'tool')).existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      stderr.writeln('Could not find Catch repo root from ${start.path}.');
      exit(65);
    }
    current = parent;
  }
}
