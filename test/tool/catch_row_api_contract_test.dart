import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'Dart rejects interactive layouts, arbitrary row children and retired row APIs',
    () async {
      final parent = Directory('tool/catch_ui_lints_probe')
        ..createSync(recursive: true);
      final folder = parent.createTempSync('row-api.');
      addTearDown(() => folder.deleteSync(recursive: true));
      final cases = <String, ({String source, String? error})>{
        'valid': (
          source:
              "final field = ui.CatchField.read(content: const ui.CatchPersonLayout(name: 'Person')); final section = ui.CatchSection.rows(children:[field]);",
          error: null,
        ),
        'layout_callback': (
          source:
              "final layout = ui.CatchRecordLayout(title:'Event',icon:Icons.event,onTap:() {});",
          error: 'UNDEFINED_NAMED_PARAMETER',
        ),
        'widget_child': (
          source:
              "final field = ui.CatchField.navigate(content:const Text('Person'),onActivate:() {});",
          error: 'ARGUMENT_TYPE_NOT_ASSIGNABLE',
        ),
        'row_recognizer': (
          source:
              'final section = ui.CatchSection.rows(children:[GestureDetector(onTap:() {})]);',
          error: 'LIST_ELEMENT_TYPE_NOT_ASSIGNABLE',
        ),
        'aliased_row_recognizer': (
          source:
              'typedef Rows=ui.CatchSection; final section = Rows.rows(children:[GestureDetector(onTap:() {})]);',
          error: 'LIST_ELEMENT_TYPE_NOT_ASSIGNABLE',
        ),
        'retired_person': (
          source: 'final row = ui.CatchPersonRow;',
          error: 'UNDEFINED_PREFIXED_NAME',
        ),
        'retired_record': (
          source: 'final row = ui.CatchRecordRow;',
          error: 'UNDEFINED_PREFIXED_NAME',
        ),
        'external_layout': (
          source: 'abstract class ForeignLayout extends ui.CatchFieldLayout {}',
          error: 'INVALID_USE_OF_TYPE_OUTSIDE_LIBRARY',
        ),
      };
      final files = <String>[];
      for (final entry in cases.entries) {
        final file = File('${folder.path}/${entry.key}.dart');
        file.writeAsStringSync(
          "import 'package:catch_ui/catch_ui.dart' as ui;\nimport 'package:flutter/material.dart';\n${entry.value.source}\n",
        );
        files.add(file.absolute.path);
      }
      final executable = Platform.resolvedExecutable;
      final dart = executable.contains('flutter_tester')
          ? File.fromUri(
              Uri.file(executable).resolve('../../../dart-sdk/bin/dart'),
            ).path
          : executable;
      final result = await Process.run(dart, [
        'analyze',
        '--format',
        'machine',
        ...files,
      ]);
      final output = '${result.stdout}\n${result.stderr}';
      expect(
        output,
        isNot(contains('An error occurred while executing an analyzer plugin')),
      );
      for (final entry in cases.entries) {
        final errors = output
            .split('\n')
            .where(
              (line) =>
                  line.startsWith('ERROR|') &&
                  line.contains('/${entry.key}.dart|'),
            )
            .toList();
        if (entry.value.error == null) {
          expect(errors, isEmpty, reason: output);
        } else {
          expect(
            errors.any((line) => line.contains('|${entry.value.error}|')),
            isTrue,
            reason: '${entry.key}: $output',
          );
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
