import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:catch_ui_lints/src/catch_ui_rules.dart';
import 'package:test/test.dart';

void main() {
  group('catch raw motion lint helpers', () {
    test('treats DateTime add/subtract Duration as date arithmetic', () {
      final addDuration = _durationCreation('''
DateTime endOfWindow(DateTime startOfToday) {
  return startOfToday.add(const Duration(days: 7));
}
''');
      final subtractDuration = _durationCreation('''
DateTime previousWindow(DateTime startOfToday) {
  return startOfToday.subtract(const Duration(days: 7));
}
''');

      expect(isCatchUiDateArithmeticDuration(addDuration), isTrue);
      expect(isCatchUiDateArithmeticDuration(subtractDuration), isTrue);
    });

    test('does not exempt widget animation Duration values', () {
      final duration = _durationCreation('''
Widget buildCard() {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    child: const SizedBox.shrink(),
  );
}
''');

      expect(isCatchUiDateArithmeticDuration(duration), isFalse);
    });
  });
}

InstanceCreationExpression _durationCreation(String source) {
  final unit = parseString(content: source).unit;
  final visitor = _DurationCreationVisitor();
  unit.accept(visitor);
  final creation = visitor.creation;
  if (creation == null) {
    fail('Expected source to contain a Duration creation.');
  }
  return creation;
}

class _DurationCreationVisitor extends RecursiveAstVisitor<void> {
  InstanceCreationExpression? creation;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (creation == null &&
        node.constructorName.type.toSource() == 'Duration') {
      creation = node;
      return;
    }
    super.visitInstanceCreationExpression(node);
  }
}
