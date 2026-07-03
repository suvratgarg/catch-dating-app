import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:catch_ui_lints/src/catch_ui_rules.dart';
import 'package:test/test.dart';

void main() {
  group('catch mutation pending lint helpers', () {
    test('flags watched mutation pending without error handling', () {
      final findings = _mutationPendingFindings('''
class SaveButton extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> save = ref.watch(EventController.saveMutation);
    return Text(save.isPending ? 'Saving' : 'Save');
  }
}
''');

      expect(findings.map((finding) => finding.variableName), ['save']);
    });

    test('allows pending mutation with same-variable hasError handling', () {
      final findings = _mutationPendingFindings('''
class SaveButton extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> save = ref.watch(EventController.saveMutation);
    if (save.hasError) return const Text('Failed');
    return Text(save.isPending ? 'Saving' : 'Save');
  }
}
''');

      expect(findings, isEmpty);
    });

    test('allows pending mutation with a Catch mutation error surface', () {
      final findings = _mutationPendingFindings('''
class SaveButton extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final Mutation<void> save = ref.watch(EventController.saveMutation);
    return Column(
      children: [
        CatchMutationErrorListener(mutation: save),
        Text(save.isPending ? 'Saving' : 'Save'),
      ],
    );
  }
}
''');

      expect(findings, isEmpty);
    });

    test('flags direct ref watch pending reads', () {
      final findings = _mutationPendingFindings('''
class SaveButton extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(EventController.saveMutation).isPending ? 'Saving' : 'Save',
    );
  }
}
''');

      expect(findings.map((finding) => finding.variableName), [isNull]);
      expect(findings.single.label, contains('ref.watch'));
    });
  });
}

List<CatchUiMutationPendingFinding> _mutationPendingFindings(String source) {
  final unit = parseString(content: source).unit;
  final visitor = _BuildMethodVisitor();
  unit.accept(visitor);
  final method = visitor.method;
  if (method == null) {
    fail('Expected source to contain a build method.');
  }
  return catchUiMutationPendingWithoutErrorFindings(method);
}

class _BuildMethodVisitor extends RecursiveAstVisitor<void> {
  MethodDeclaration? method;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (method == null && node.name.lexeme == 'build') {
      method = node;
      return;
    }
    super.visitMethodDeclaration(node);
  }
}
