import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

const _hostRoots = [
  'lib/hosts/',
  'lib/event_success/',
  'lib/event_rehearsal/',
  'lib/programs/',
];
const _rawPresenters = {
  'showModalBottomSheet',
  'showBottomSheet',
  'showCupertinoModalPopup',
  'BottomSheet',
};

List<String> _violations(String path, String source) {
  final visitor = _SheetPolicy(path);
  parseString(content: source).unit.accept(visitor);
  return visitor.failures;
}

class _SheetPolicy extends RecursiveAstVisitor<void> {
  _SheetPolicy(this.path);
  final String path;
  final failures = <String>[];

  void _check(String name, String? target, String? constructor) {
    final sharedPresenter =
        path == 'packages/catch_ui/lib/src/components/catch_sheet.dart';
    final nativePicker =
        path ==
        'packages/catch_ui/lib/src/components/catch_adaptive_picker.dart';
    if (_rawPresenters.contains(name) &&
        !(sharedPresenter && name == 'showModalBottomSheet') &&
        !(nativePicker && name == 'showCupertinoModalPopup')) {
      failures.add('$path: raw $name');
    }
    if (_hostRoots.any(path.startsWith) &&
        (name == 'CatchSheet' || target == 'CatchSheet') &&
        constructor != 'standard' &&
        name != 'standard') {
      failures.add(
        '$path: use CatchSheet.standard for shared geometry and scrolling',
      );
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _check(node.methodName.name, node.target?.toSource(), null);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _check(
      node.constructorName.type.name.lexeme,
      null,
      node.constructorName.name?.name,
    );
    super.visitInstanceCreationExpression(node);
  }
}

void main() {
  test('production sheets use shared presenters and Host composition', () {
    final failures = <String>[];
    var hostSheets = 0;
    for (final root in ['lib', 'packages/catch_ui/lib']) {
      for (final entity in Directory(root).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        failures.addAll(_violations(path, source));
        if (_hostRoots.any(path.startsWith)) {
          hostSheets += 'CatchSheet.standard('.allMatches(source).length;
        }
      }
    }
    expect(
      hostSheets,
      greaterThan(0),
      reason: 'The Host scan must not pass vacuously.',
    );
    expect(failures, isEmpty);
  });

  test('policy rejects raw presenter variants and legacy Host shells', () {
    for (final source in [
      'void f() { showModalBottomSheet(context: c, builder: b); }',
      'void f() { material.showModalBottomSheet(context: c, builder: b); }',
      'void f() { Scaffold.of(c).showBottomSheet(b); }',
      'void f() { showCupertinoModalPopup(context: c, builder: b); }',
      'void f() { BottomSheet(onClosing: f, builder: b); }',
      'void f() { const BottomSheet(onClosing: f, builder: b); }',
      'void f() { CatchSheet(child: child); }',
      'void f() { const CatchSheet(child: child); }',
    ]) {
      expect(
        _violations('lib/hosts/example.dart', source),
        isNotEmpty,
        reason: source,
      );
    }
    expect(
      _violations('lib/hosts/example.dart', '''
      // showModalBottomSheet is forbidden; mentioning it is not a call.
      void f() { showCatchBottomSheet(context: c, builder: b); }
      final a = CatchSheet.standard(child: child);
      final b = const CatchSheet.standard(child: child);
    '''),
      isEmpty,
    );
  });
}
