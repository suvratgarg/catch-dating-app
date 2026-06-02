import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

const _eventDetailPathFragments = <String>[
  '/lib/events/presentation/widgets/event_detail_',
  '/lib/events/presentation/widgets/event_photo_header.dart',
];

const _excludedPathFragments = <String>[
  '/lib/core/theme/',
  '/lib/core/schema_contracts/generated/',
  '/generated/',
];

const _spacingNamedArguments = <String>{
  'height',
  'width',
  'top',
  'right',
  'bottom',
  'left',
  'horizontal',
  'vertical',
  'all',
  'mainAxisSpacing',
  'crossAxisSpacing',
  'runSpacing',
  'spacing',
  'contentPadding',
};

const _rawControlConstructors = <String>{
  'ActionChip',
  'Badge',
  'Card',
  'Chip',
  'ChoiceChip',
  'FilterChip',
  'InputChip',
  'RawChip',
};

const _rawControlReplacements = <String, String>{
  'ActionChip': 'CatchChip',
  'Badge': 'CatchBadge',
  'Card': 'CatchSurface or CatchSectionCard',
  'Chip': 'CatchChip',
  'ChoiceChip': 'CatchChip',
  'FilterChip': 'CatchChip',
  'InputChip': 'CatchChip',
  'RawChip': 'CatchChip',
};

const _tokenPrefixes = <String>{
  'CatchIcon',
  'CatchLayout',
  'CatchGaps',
  'CatchInsets',
  'CatchElevation',
  'CatchOpacity',
  'CatchMotion',
  'CatchAspectRatio',
  'CatchRadius',
  'CatchSpacing',
  'CatchStroke',
};

const catchUiLintFontFamilies = <String>{
  'Newsreader',
  'Inter',
  'IBM Plex Mono',
};

const _hairlineLiteralLimit = 1.0;

class CatchUiLayoutRules extends MultiAnalysisRule {
  CatchUiLayoutRules()
    : super(
        name: 'catch_ui_layout_rules',
        description: 'Enforces Catch semantic UI layout invariants.',
      );

  static const rawUiSpacing = LintCode(
    'catch_no_raw_ui_spacing',
    'Use a named CatchSpacing/CatchLayout token or CatchSectionList gap instead of a raw UI spacing number.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const useSectionList = LintCode(
    'catch_use_section_list',
    'Use CatchSectionList/CatchDetailSliverSectionList for adjacent semantic sections instead of manually interleaving spacers.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noTokenArithmetic = LintCode(
    'catch_no_token_arithmetic',
    'Move token arithmetic into a named CatchLayout/CatchSpacing helper so layout intent is reusable and reviewable.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const preferSemanticInsets = LintCode(
    'catch_prefer_semantic_insets',
    'Use CatchInsets, a named inset contract, or a layout primitive instead of composing feature padding inline from CatchSpacing.',
    severity: DiagnosticSeverity.INFO,
  );

  static const eventDetailPrefersPhotoThumbnail = LintCode(
    'catch_event_detail_prefers_photo_thumbnail',
    'Event detail visuals must use CatchEventThumbnail so photos lead when available and activity artwork is only the fallback.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noRawMaterialControl = LintCode(
    'catch_no_raw_material_control',
    'Use {0} instead of this raw Material/Cupertino control in audited feature UI.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawColor = LintCode(
    'catch_no_raw_color',
    'Use CatchTokens, ActivityPalette, or a named color role instead of a raw Color/Colors/CupertinoColors value.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noRawTextStyle = LintCode(
    'catch_no_raw_text_style',
    'Use CatchTextStyles or CatchFonts instead of constructing a raw TextStyle in app UI.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noRawFontDrift = LintCode(
    'catch_no_raw_font_drift',
    'Use the CatchFonts family constants and style builders instead of raw GoogleFonts or fontFamily strings.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noRawRadius = LintCode(
    'catch_no_raw_radius',
    'Use CatchRadius tokens instead of raw Radius/BorderRadius numeric values.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noWidgetReturningMethod = LintCode(
    'catch_no_widget_returning_method',
    'Extract private Widget-returning helpers in feature presentation code to named Widget classes.',
    severity: DiagnosticSeverity.INFO,
  );

  @override
  bool get canUseParsedResult => true;

  @override
  List<DiagnosticCode> get diagnosticCodes => const [
    rawUiSpacing,
    useSectionList,
    noTokenArithmetic,
    preferSemanticInsets,
    eventDetailPrefersPhotoThumbnail,
    noRawMaterialControl,
    noRawColor,
    noRawTextStyle,
    noRawFontDrift,
    noRawRadius,
    noWidgetReturningMethod,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = _normalizedPath(context);
    if (!_isAppPath(path)) return;

    final visitor = _CatchUiLayoutVisitor(
      this,
      source: context.definingUnit.content,
      path: path,
      isEventDetailPath: _isEventDetailPath(path),
      isColorExemptPath: false,
      isFeaturePresentationPath: _isFeaturePresentationPath(path),
      allowRawControlConstructors: _isCoreWidgetPrimitivePath(path),
    );
    registry.addInstanceCreationExpression(this, visitor);
    registry.addNamedExpression(this, visitor);
    registry.addBinaryExpression(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
    registry.addPrefixedIdentifier(this, visitor);
    registry.addPropertyAccess(this, visitor);
    registry.addSimpleStringLiteral(this, visitor);
  }

  String _normalizedPath(RuleContext context) {
    return context.definingUnit.file.path.replaceAll(r'\', '/');
  }

  bool _isAppPath(String path) {
    return path.contains('/lib/') &&
        !_excludedPathFragments.any(path.contains) &&
        !path.endsWith('.g.dart') &&
        !path.endsWith('.freezed.dart');
  }

  bool _isEventDetailPath(String path) {
    return _eventDetailPathFragments.any(path.contains);
  }

  bool _isFeaturePresentationPath(String path) {
    return path.contains('/lib/') &&
        path.contains('/presentation/') &&
        !path.contains('/lib/core/');
  }

  bool _isCoreWidgetPrimitivePath(String path) {
    return path.contains('/lib/core/widgets/');
  }
}

class _CatchUiLayoutVisitor extends SimpleAstVisitor<void> {
  _CatchUiLayoutVisitor(
    this.rule, {
    required this.source,
    required this.path,
    required this.isEventDetailPath,
    required this.isColorExemptPath,
    required this.isFeaturePresentationPath,
    required this.allowRawControlConstructors,
  }) : _lineStarts = _computeLineStarts(source);

  final CatchUiLayoutRules rule;
  final String source;
  final String path;
  final bool isEventDetailPath;
  final bool isColorExemptPath;
  final bool isFeaturePresentationPath;
  final bool allowRawControlConstructors;
  final List<int> _lineStarts;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = _constructorTypeName(node);
    final constructorName = _constructorMemberName(node);

    if (typeName == 'SizedBox') {
      _checkSizedBoxSpacing(node);
    } else if (_isEdgeInsetsConstructor(typeName)) {
      _checkEdgeInsetsSpacing(node);
    }

    if (isEventDetailPath && typeName == 'EventActivityBackdrop') {
      rule.reportAtNode(
        node,
        diagnosticCode: CatchUiLayoutRules.eventDetailPrefersPhotoThumbnail,
      );
    }

    if (!allowRawControlConstructors &&
        _rawControlConstructors.contains(typeName)) {
      _reportAtNode(
        node,
        CatchUiLayoutRules.noRawMaterialControl,
        arguments: [_rawControlReplacements[typeName] ?? 'a Catch primitive'],
      );
    }

    if (!isColorExemptPath && _isRawColorConstructor(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawColor);
    }

    if (typeName == 'TextStyle') {
      _reportAtNode(node, CatchUiLayoutRules.noRawTextStyle);
    }

    final rawRadiusOffender = _rawRadiusOffender(
      typeName,
      constructorName,
      node,
    );
    if (rawRadiusOffender != null) {
      _reportAtNode(rawRadiusOffender, CatchUiLayoutRules.noRawRadius);
    }

    if (typeName == 'Column') {
      _checkSectionColumn(node);
    }
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    final name = node.name.label.name;
    if (_spacingNamedArguments.contains(name) &&
        _isPositiveNumberLiteral(node.expression) &&
        _isSpacingContext(node)) {
      rule.reportAtNode(
        node.expression,
        diagnosticCode: CatchUiLayoutRules.rawUiSpacing,
      );
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator == TokenType.PLUS ||
        operator == TokenType.MINUS ||
        operator == TokenType.STAR ||
        operator == TokenType.SLASH) {
      final leftIsToken = _isTokenReference(node.leftOperand);
      final rightIsToken = _isTokenReference(node.rightOperand);
      final leftIsNumber = _isPositiveNumberLiteral(node.leftOperand);
      final rightIsNumber = _isPositiveNumberLiteral(node.rightOperand);
      if ((leftIsToken && (rightIsToken || rightIsNumber)) ||
          (rightIsToken && leftIsNumber)) {
        rule.reportAtNode(
          node,
          diagnosticCode: CatchUiLayoutRules.noTokenArithmetic,
        );
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!isFeaturePresentationPath) return;

    final name = node.name.lexeme;
    if (!name.startsWith('_') || name == 'build') return;

    final returnType = node.returnType?.toSource().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    if (returnType == 'Widget' ||
        returnType == 'Widget?' ||
        returnType == 'List<Widget>') {
      _reportAtNode(node, CatchUiLayoutRules.noWidgetReturningMethod);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isGoogleFontInvocation(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawFontDrift);
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (node.function.toSource().startsWith('GoogleFonts.')) {
      _reportAtNode(node, CatchUiLayoutRules.noRawFontDrift);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!isColorExemptPath && _isRawColorIdentifier(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawColor);
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (!isColorExemptPath && _isRawColorPropertyAccess(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawColor);
    }
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!catchUiLintFontFamilies.contains(node.value)) return;
    if (!_isFontFamilyNamedArgument(node)) return;

    _reportAtNode(node, CatchUiLayoutRules.noRawFontDrift);
  }

  void _checkSizedBoxSpacing(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) continue;
      final name = argument.name.label.name;
      if ((name == 'height' || name == 'width') &&
          _isPositiveNumberLiteral(argument.expression)) {
        rule.reportAtNode(
          argument.expression,
          diagnosticCode: CatchUiLayoutRules.rawUiSpacing,
        );
      }
    }
  }

  void _checkEdgeInsetsSpacing(InstanceCreationExpression node) {
    if (isFeaturePresentationPath &&
        !_isNamedInsetContract(node) &&
        _edgeInsetsUsesLowLevelSpacing(node)) {
      _reportAtNode(node, CatchUiLayoutRules.preferSemanticInsets);
    }

    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression) {
        if (_isPositiveNumberLiteral(argument.expression)) {
          rule.reportAtNode(
            argument.expression,
            diagnosticCode: CatchUiLayoutRules.rawUiSpacing,
          );
        }
      } else if (_isPositiveNumberLiteral(argument)) {
        rule.reportAtNode(
          argument,
          diagnosticCode: CatchUiLayoutRules.rawUiSpacing,
        );
      }
    }
  }

  bool _edgeInsetsUsesLowLevelSpacing(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      final expression = argument is NamedExpression
          ? argument.expression
          : argument;
      if (_usesCatchSpacing(expression)) return true;
    }
    return false;
  }

  bool _isNamedInsetContract(InstanceCreationExpression node) {
    var current = node.parent;
    while (current != null) {
      if (current is VariableDeclaration || current is DefaultFormalParameter) {
        return true;
      }
      if (current is Statement ||
          current is InstanceCreationExpression ||
          current is MethodInvocation) {
        return false;
      }
      current = current.parent;
    }
    return false;
  }

  void _checkSectionColumn(InstanceCreationExpression node) {
    final children = _childrenArgument(node);
    if (children == null || children.elements.length < 3) return;

    var sectionLikeChildren = 0;
    var hasManualGap = false;

    for (final element in children.elements) {
      final expression = element is Expression ? element : null;
      if (expression == null) continue;
      final childName = _expressionTypeName(expression);
      if (childName.endsWith('Section') || childName.contains('Section')) {
        sectionLikeChildren += 1;
      }
      if (childName == 'SizedBox') {
        hasManualGap = true;
      }
    }

    if (sectionLikeChildren >= 2 && hasManualGap) {
      rule.reportAtNode(
        node,
        diagnosticCode: CatchUiLayoutRules.useSectionList,
      );
    }
  }

  bool _isRawColorConstructor(InstanceCreationExpression node) {
    if (_constructorTypeName(node) != 'Color') return false;

    final constructorName = _constructorMemberName(node);
    if (constructorName == null) {
      final arguments = node.argumentList.arguments;
      if (arguments.isEmpty) return false;

      final firstArgument = arguments.first;
      if (firstArgument is IntegerLiteral &&
          _isTransparentColorLiteral(firstArgument)) {
        return false;
      }
      return true;
    }

    return constructorName == 'fromARGB' || constructorName == 'fromRGBO';
  }

  Expression? _rawRadiusOffender(
    String typeName,
    String? constructorName,
    InstanceCreationExpression node,
  ) {
    if (typeName == 'Radius') {
      if (_isBorderRadiusRadiusArgument(node)) return null;
      if (constructorName != 'circular' && constructorName != 'elliptical') {
        return null;
      }
      return _firstPositiveNumberArgument(node.argumentList.arguments);
    }

    if (typeName == 'BorderRadius') {
      if (constructorName == 'circular') {
        return _firstPositiveNumberArgument(node.argumentList.arguments);
      }
      if (constructorName == 'all' ||
          constructorName == 'only' ||
          constructorName == 'vertical' ||
          constructorName == 'horizontal') {
        return _firstRawRadiusConstructorArgument(node.argumentList.arguments);
      }
    }

    return null;
  }

  Expression? _firstPositiveNumberArgument(NodeList<Expression> nodes) {
    for (final node in nodes) {
      if (node is NamedExpression &&
          _isPositiveNumberLiteral(node.expression)) {
        return node.expression;
      }
      if (_isPositiveNumberLiteral(node)) return node;
    }
    return null;
  }

  Expression? _firstRawRadiusConstructorArgument(NodeList<Expression> nodes) {
    for (final node in nodes) {
      final expression = node is NamedExpression ? node.expression : node;
      if (expression is! InstanceCreationExpression) continue;
      if (_constructorTypeName(expression) != 'Radius') continue;
      final constructorName = _constructorMemberName(expression);
      if (constructorName != 'circular' && constructorName != 'elliptical') {
        continue;
      }
      if (_firstPositiveNumberArgument(expression.argumentList.arguments) !=
          null) {
        return expression;
      }
    }
    return null;
  }

  bool _isBorderRadiusRadiusArgument(InstanceCreationExpression node) {
    final parent = node.parent;
    final borderRadius = parent is NamedExpression
        ? parent.parent?.parent
        : parent?.parent;
    if (borderRadius is! InstanceCreationExpression) return false;
    if (_constructorTypeName(borderRadius) != 'BorderRadius') return false;
    final constructorName = _constructorMemberName(borderRadius);
    return constructorName == 'all' ||
        constructorName == 'only' ||
        constructorName == 'vertical' ||
        constructorName == 'horizontal';
  }

  bool _isGoogleFontInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;
    if (methodName == 'getFont') return true;

    final target = node.target;
    return (target is SimpleIdentifier && target.name == 'GoogleFonts') ||
        node.toSource().startsWith('GoogleFonts.');
  }

  bool _isRawColorIdentifier(PrefixedIdentifier node) {
    final prefix = node.prefix.name;
    if (prefix != 'Colors' && prefix != 'CupertinoColors') return false;

    return node.identifier.name != 'transparent';
  }

  bool _isRawColorPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is! SimpleIdentifier) return false;
    if (target.name != 'Colors' && target.name != 'CupertinoColors') {
      return false;
    }

    return node.propertyName.name != 'transparent';
  }

  bool _isFontFamilyNamedArgument(SimpleStringLiteral node) {
    final parent = node.parent;
    return parent is NamedExpression && parent.name.label.name == 'fontFamily';
  }

  void _reportAtNode(
    AstNode node,
    LintCode diagnosticCode, {
    List<Object> arguments = const [],
  }) {
    if (_hasTokenAllowComment(node)) return;

    rule.reportAtNode(
      node,
      diagnosticCode: diagnosticCode,
      arguments: arguments,
    );
  }

  bool _hasTokenAllowComment(AstNode node) {
    final line = _lineForOffset(node.offset);
    return _lineContainsTokenAllow(line) || _lineContainsTokenAllow(line - 1);
  }

  int _lineForOffset(int offset) {
    var low = 0;
    var high = _lineStarts.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final lineStart = _lineStarts[mid];
      if (lineStart > offset) {
        high = mid - 1;
      } else {
        if (mid == _lineStarts.length - 1 || _lineStarts[mid + 1] > offset) {
          return mid;
        }
        low = mid + 1;
      }
    }
    return 0;
  }

  bool _lineContainsTokenAllow(int line) {
    if (line < 0 || line >= _lineStarts.length) return false;

    final start = _lineStarts[line];
    final end = line + 1 < _lineStarts.length
        ? _lineStarts[line + 1]
        : source.length;
    return source.substring(start, end).contains('token:allow:');
  }

  ListLiteral? _childrenArgument(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == 'children' &&
          argument.expression is ListLiteral) {
        return argument.expression as ListLiteral;
      }
    }
    return null;
  }

  bool _isSpacingContext(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = _constructorTypeName(current);
        return typeName == 'SizedBox' ||
            typeName.startsWith('EdgeInsets') ||
            typeName == 'SliverGridDelegateWithFixedCrossAxisCount' ||
            typeName == 'SliverGridDelegateWithMaxCrossAxisExtent' ||
            typeName == 'Wrap';
      }
      if (current is MethodInvocation) {
        final methodName = current.methodName.name;
        return methodName == 'all' ||
            methodName == 'only' ||
            methodName == 'symmetric' ||
            methodName == 'fromLTRB';
      }
      current = current.parent;
    }
    return false;
  }
}

String _constructorTypeName(InstanceCreationExpression node) {
  final raw = node.constructorName.type.toSource();
  return raw.split('<').first;
}

bool _isEdgeInsetsConstructor(String typeName) {
  return typeName == 'EdgeInsets' || typeName == 'EdgeInsetsDirectional';
}

bool _isPositiveNumberLiteral(Expression expression) {
  if (expression is IntegerLiteral) {
    return (expression.value ?? 0) > _hairlineLiteralLimit;
  }
  if (expression is DoubleLiteral) {
    return expression.value > _hairlineLiteralLimit;
  }
  return false;
}

bool _isTokenReference(Expression expression) {
  if (expression is PrefixedIdentifier) {
    return _tokenPrefixes.contains(expression.prefix.name);
  }
  if (expression is PropertyAccess) {
    final target = expression.target;
    return target != null && _isTokenReference(target);
  }
  if (expression is MethodInvocation) {
    final target = expression.target;
    return target is SimpleIdentifier &&
        target.name == 'CatchTokens' &&
        expression.methodName.name == 'of';
  }
  if (expression is ParenthesizedExpression) {
    return _isTokenReference(expression.expression);
  }
  return false;
}

bool _usesCatchSpacing(Expression expression) {
  if (expression is PrefixedIdentifier) {
    return expression.prefix.name == 'CatchSpacing';
  }
  if (expression is PropertyAccess) {
    final target = expression.target;
    if (target is SimpleIdentifier && target.name == 'CatchSpacing') {
      return true;
    }
    return target != null && _usesCatchSpacing(target);
  }
  if (expression is BinaryExpression) {
    return _usesCatchSpacing(expression.leftOperand) ||
        _usesCatchSpacing(expression.rightOperand);
  }
  if (expression is ConditionalExpression) {
    return _usesCatchSpacing(expression.condition) ||
        _usesCatchSpacing(expression.thenExpression) ||
        _usesCatchSpacing(expression.elseExpression);
  }
  if (expression is ParenthesizedExpression) {
    return _usesCatchSpacing(expression.expression);
  }
  return false;
}

String _expressionTypeName(Expression expression) {
  if (expression is InstanceCreationExpression) {
    return _constructorTypeName(expression);
  }
  if (expression is Identifier) {
    return expression.name;
  }
  if (expression is PrefixedIdentifier) {
    return expression.identifier.name;
  }
  if (expression is ParenthesizedExpression) {
    return _expressionTypeName(expression.expression);
  }
  return '';
}

String? _constructorMemberName(InstanceCreationExpression node) {
  return node.constructorName.name?.name;
}

bool _isTransparentColorLiteral(IntegerLiteral literal) {
  final lexeme = literal.literal.lexeme.toLowerCase();
  if (!lexeme.startsWith('0x')) return false;

  final hex = lexeme.substring(2).replaceAll('_', '');
  return hex.length == 8 && hex.startsWith('00');
}

List<int> _computeLineStarts(String source) {
  final starts = <int>[0];
  for (var index = 0; index < source.length; index += 1) {
    if (source.codeUnitAt(index) == 0x0A) {
      starts.add(index + 1);
    }
  }
  return starts;
}
