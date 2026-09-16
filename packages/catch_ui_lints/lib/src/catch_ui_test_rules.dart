part of 'catch_ui_rules.dart';

class _CatchUiTestVisitor extends SimpleAstVisitor<void> {
  _CatchUiTestVisitor(this.rule, {required this.source});
  final CatchUiLayoutRules rule;
  final String source;
  @override
  void visitCompilationUnit(CompilationUnit node) {
    _reportMatches(
      RegExp(
        r'pumpAndSettle\s*\(|pump\s*\(\s*const\s+Duration|warnIfMissed\s*:\s*false',
      ),
      CatchUiLayoutRules.noBrittlePumpTiming,
    );
    _reportMatches(
      RegExp(
        r'find\.[A-Za-z_][A-Za-z0-9_]*\s*\([^)]*\)\s*\.(?:at|first|last)\b|(?:Scrollable|ListView)\.first\b',
      ),
      CatchUiLayoutRules.noPositionalWidgetFinder,
    );
    _reportMatches(
      RegExp(r'Future\s*<\s*void\s*>\s*\.delayed\s*\(\s*Duration\.zero\s*\)'),
      CatchUiLayoutRules.noAsyncFlushHack,
    );
  }

  void _reportMatches(RegExp pattern, LintCode diagnosticCode) {
    for (final match in pattern.allMatches(source)) {
      rule.reportAtOffset(
        match.start,
        match.end - match.start,
        diagnosticCode: diagnosticCode,
      );
    }
  }
}
