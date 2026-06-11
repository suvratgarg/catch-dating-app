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

const _rawButtonControlConstructors = <String>{
  'CupertinoButton',
  'DropdownButton',
  'ElevatedButton',
  'FilledButton',
  'FloatingActionButton',
  'OutlinedButton',
  'PopupMenuButton',
  'Radio',
  'RangeSlider',
  'SegmentedButton',
  'Slider',
  'Switch',
  'TextButton',
  'TextField',
  'TextFormField',
};

const _surfaceShellConstructors = <String>{
  'AnimatedContainer',
  'Container',
  'DecoratedBox',
};

final _allowDebtPattern = RegExp(
  r'(?:alpha|breakpoint|color-sweep|control|icon-size|motion|radius|shadow|sizing|spacing|surface|token|typography|ui-system):allow:|ignore(?:_for_file)?:[^\n]*\bcatch_[a-z0-9_]+',
);

const _localDesignConstantWords = <String>{
  'alpha',
  'color',
  'duration',
  'elevation',
  'extent',
  'gap',
  'height',
  'inset',
  'margin',
  'offset',
  'opacity',
  'padding',
  'radius',
  'shadow',
  'size',
  'width',
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

const _tokenSourceNames = <String>{
  ..._tokenPrefixes,
  'ActivityPalette',
  'CatchFonts',
  'CatchTextStyles',
  'CatchTokens',
  'Sizes',
};

const _rawStrokeConstructors = <String>{
  'Border',
  'BorderSide',
  'CircularProgressIndicator',
  'Divider',
  'LinearProgressIndicator',
  'VerticalDivider',
};

const _assetPathConstructors = <String>{'AssetImage', 'ExactAssetImage'};

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

  static const noRawButtonControl = LintCode(
    'catch_no_raw_button_control',
    'Use a Catch control primitive or add the missing primitive instead of this raw Material/Cupertino input control.',
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

  static const noRawContentDimension = LintCode(
    'catch_no_raw_content_dimension',
    'Use flexible constraints, aspect ratios, CatchLayout, or a named dimension contract instead of a raw fixed content dimension.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noLocalDesignConstant = LintCode(
    'catch_no_local_design_constant',
    'Route private feature UI constants through Catch tokens or a shared primitive instead of owning raw design values locally.',
    severity: DiagnosticSeverity.WARNING,
  );

  static const noRawIconSource = LintCode(
    'catch_no_raw_icon_source',
    'Use CatchIcons or a semantic icon contract instead of referencing Icons directly in app UI.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawIconSize = LintCode(
    'catch_no_raw_icon_size',
    'Use CatchIcon size tokens or a primitive-owned semantic icon size instead of a raw icon size.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawAlpha = LintCode(
    'catch_no_raw_alpha',
    'Use CatchOpacity or a named opacity contract instead of a raw alpha/opacity value.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawShadow = LintCode(
    'catch_no_raw_shadow',
    'Use CatchElevation/CatchSurface elevation roles or a named component shadow contract instead of raw shadow/elevation values.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawMotion = LintCode(
    'catch_no_raw_motion',
    'Use CatchMotion or a named motion helper instead of raw Duration/Curves values in app UI.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawBreakpoint = LintCode(
    'catch_no_raw_breakpoint',
    'Use CatchLayout breakpoints or a named responsive contract instead of hardcoded width checks.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawSurfaceShell = LintCode(
    'catch_no_raw_surface_shell',
    'Use CatchSurface or a shared surface primitive instead of hand-rolling a local decorated surface.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawStrokeWidth = LintCode(
    'catch_no_raw_stroke_width',
    'Use CatchStroke or a primitive-owned stroke contract instead of a raw stroke width.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noRawAssetPath = LintCode(
    'catch_no_raw_asset_path',
    'Route asset paths through a named asset contract instead of passing raw assets/... strings to image loaders.',
    severity: DiagnosticSeverity.INFO,
  );

  static const iconButtonRequiresTooltip = LintCode(
    'catch_icon_button_requires_tooltip',
    'Icon-only buttons need a tooltip or an enclosing semantic label.',
    severity: DiagnosticSeverity.INFO,
  );

  static const noAllowDebt = LintCode(
    'catch_no_allow_debt',
    'Remove temporary Catch UI allow debt or replace it with a narrow source-of-truth exception.',
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
    noRawButtonControl,
    noRawColor,
    noRawTextStyle,
    noRawFontDrift,
    noRawRadius,
    noRawContentDimension,
    noLocalDesignConstant,
    noRawIconSource,
    noRawIconSize,
    noRawAlpha,
    noRawShadow,
    noRawMotion,
    noRawBreakpoint,
    noRawSurfaceShell,
    noRawStrokeWidth,
    noRawAssetPath,
    iconButtonRequiresTooltip,
    noAllowDebt,
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
      isSizingScannerPath: _isSizingScannerPath(path),
      isUiSystemScannerPath: _isUiSystemScannerPath(path),
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
    registry.addCompilationUnit(this, visitor);
    registry.addVariableDeclaration(this, visitor);
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

  bool _isSizingScannerPath(String path) {
    return !path.contains('/lib/labs/') && !path.contains('explore_concept');
  }

  bool _isUiSystemScannerPath(String path) {
    if (!_isSizingScannerPath(path)) return false;
    return path.contains('/lib/core/widgets/') ||
        path.contains('/lib/core/presentation/') ||
        path.contains('/presentation/');
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
    required this.isSizingScannerPath,
    required this.isUiSystemScannerPath,
    required this.allowRawControlConstructors,
  }) : _lineStarts = _computeLineStarts(source);

  final CatchUiLayoutRules rule;
  final String source;
  final String path;
  final bool isEventDetailPath;
  final bool isColorExemptPath;
  final bool isFeaturePresentationPath;
  final bool isSizingScannerPath;
  final bool isUiSystemScannerPath;
  final bool allowRawControlConstructors;
  final List<int> _lineStarts;
  Set<String> _locallyShadowedTokenNames = const <String>{};

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _locallyShadowedTokenNames = _declaredTokenShadows(node);

    for (final match in _allowDebtPattern.allMatches(source)) {
      if (_isThemeIndependentArtAllow(match.start)) continue;
      rule.reportAtOffset(
        match.start,
        match.end - match.start,
        diagnosticCode: CatchUiLayoutRules.noAllowDebt,
      );
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (!isFeaturePresentationPath) return;
    if (!isSizingScannerPath) return;
    if (_isInsideCustomPainter(node)) return;
    if (!_isPrivateDesignConstant(node)) return;

    final initializer = node.initializer;
    if (initializer == null) return;
    if (_expressionUsesToken(initializer)) return;
    if (!_expressionContainsRawDesignValue(initializer)) return;

    _reportAtNode(node, CatchUiLayoutRules.noLocalDesignConstant);
  }

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

    if (isUiSystemScannerPath &&
        _rawButtonControlConstructors.contains(typeName)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawButtonControl);
    }

    if (_isRawContentDimensionConstructor(node, typeName, constructorName)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawContentDimension);
    }

    if (isUiSystemScannerPath && _isRawShadowConstructor(node, typeName)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawShadow);
    }

    if (isUiSystemScannerPath && _isRawMotionConstructor(node, typeName)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawMotion);
    }

    if (_isLocalDecoratedSurfaceShell(node, typeName)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawSurfaceShell);
    }

    if (isUiSystemScannerPath && _iconButtonMissingTooltip(node)) {
      _reportAtNode(node, CatchUiLayoutRules.iconButtonRequiresTooltip);
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

    if (_isRawContentDimensionNamedArgument(node)) {
      _reportAtNode(node.expression, CatchUiLayoutRules.noRawContentDimension);
    }

    if (isUiSystemScannerPath && _isRawIconSizeNamedArgument(node)) {
      _reportAtNode(node.expression, CatchUiLayoutRules.noRawIconSize);
    }

    if (isUiSystemScannerPath && _isRawAlphaNamedArgument(node)) {
      _reportAtNode(node.expression, CatchUiLayoutRules.noRawAlpha);
    }

    if (isUiSystemScannerPath && _isRawShadowNamedArgument(node)) {
      _reportAtNode(node.expression, CatchUiLayoutRules.noRawShadow);
    }

    if (isUiSystemScannerPath && _isRawStrokeNamedArgument(node)) {
      _reportAtNode(node.expression, CatchUiLayoutRules.noRawStrokeWidth);
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator == TokenType.PLUS ||
        operator == TokenType.MINUS ||
        operator == TokenType.STAR ||
        operator == TokenType.SLASH) {
      final leftIsToken = _isTokenReference(
        node.leftOperand,
        _locallyShadowedTokenNames,
      );
      final rightIsToken = _isTokenReference(
        node.rightOperand,
        _locallyShadowedTokenNames,
      );
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

    if (isUiSystemScannerPath && _isRawBreakpointComparison(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawBreakpoint);
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
    if (isUiSystemScannerPath && node.prefix.name == 'Icons') {
      _reportAtNode(node, CatchUiLayoutRules.noRawIconSource);
    }

    if (isUiSystemScannerPath && node.prefix.name == 'Curves') {
      _reportAtNode(node, CatchUiLayoutRules.noRawMotion);
    }

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
    if (catchUiLintFontFamilies.contains(node.value) &&
        _isFontFamilyNamedArgument(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawFontDrift);
    }

    if (isFeaturePresentationPath && _isRawAssetPathLiteral(node)) {
      _reportAtNode(node, CatchUiLayoutRules.noRawAssetPath);
    }
  }

  bool _isThemeIndependentArtAllow(int offset) {
    final isKnownArtPath =
        path.endsWith('/lib/core/widgets/graded_image.dart') ||
        path.endsWith('/lib/events/presentation/event_activity_visuals.dart');
    return isKnownArtPath &&
        _lineForOffsetText(offset).contains('theme-independent art');
  }

  bool _isPrivateDesignConstant(VariableDeclaration node) {
    final name = node.name.lexeme;
    if (!name.startsWith('_')) return false;

    final parent = node.parent;
    if (parent is! VariableDeclarationList) return false;

    final keyword = parent.keyword?.lexeme;
    if (keyword != 'const' && keyword != 'final') return false;

    final lowerName = name.toLowerCase();
    return _localDesignConstantWords.any(lowerName.contains);
  }

  bool _isInsideCustomPainter(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        final extendsClause = current.extendsClause;
        return extendsClause?.superclass.name.lexeme == 'CustomPainter';
      }
      current = current.parent;
    }
    return false;
  }

  bool _expressionUsesToken(Expression expression) {
    final text = expression.toSource();
    if (_isTokenReference(expression, _locallyShadowedTokenNames)) return true;
    return _tokenPrefixes.any(
          (prefix) =>
              !_locallyShadowedTokenNames.contains(prefix) &&
              text.contains('$prefix.'),
        ) ||
        text.contains('ActivityPalette.') ||
        text.contains('CatchFonts.') ||
        text.contains('CatchTextStyles.') ||
        text.contains('Sizes.');
  }

  bool _expressionContainsRawDesignValue(Expression expression) {
    final text = expression.toSource();
    if (RegExp(
      r'\b(?:Color|Duration|Size|Offset|EdgeInsets(?:Directional|Geometry)?|BorderRadius|Radius)\b',
    ).hasMatch(text)) {
      return true;
    }
    if (RegExp(r'\b(?:Colors|CupertinoColors|Curves|Icons)\.').hasMatch(text)) {
      return true;
    }

    for (final match in RegExp(
      r'(?<![A-Za-z0-9_])-?\d+(?:\.\d+)?(?![A-Za-z0-9_])',
    ).allMatches(text)) {
      final value = double.tryParse(match.group(0)!);
      if (value != null && value.abs() > _hairlineLiteralLimit) return true;
    }

    return false;
  }

  bool _isRawContentDimensionConstructor(
    InstanceCreationExpression node,
    String typeName,
    String? constructorName,
  ) {
    if (!isSizingScannerPath) return false;

    if (typeName == 'Size') {
      if (constructorName != null && constructorName != 'square') {
        return false;
      }
      return node.argumentList.arguments.any(
        (argument) => _isNumberAtLeast(argument, 4),
      );
    }

    if (typeName == 'BoxConstraints') {
      return constructorName == 'tight' ||
          constructorName == 'tightFor' ||
          constructorName == 'expand';
    }

    return false;
  }

  bool _isRawContentDimensionNamedArgument(NamedExpression node) {
    if (!isSizingScannerPath) return false;

    final name = node.name.label.name;
    if (name != 'height' && name != 'width' && name != 'dimension') {
      return false;
    }
    if (!_isNumberAtLeast(node.expression, 4)) return false;
    return !_isIconConstructorContext(node);
  }

  bool _isRawIconSizeNamedArgument(NamedExpression node) {
    final name = node.name.label.name;
    if (name == 'iconSize') return _isNumberAtLeast(node.expression, 4);
    if (name != 'size') return false;
    if (!_isNumberAtLeast(node.expression, 4)) return false;

    final constructorType = _ancestorConstructorType(node);
    return constructorType == 'Icon' || constructorType == 'IconThemeData';
  }

  bool _isRawAlphaNamedArgument(NamedExpression node) {
    final name = node.name.label.name;
    if (name != 'alpha' && name != 'opacity') return false;
    return _isNumberBetween(node.expression, min: 0, max: 1);
  }

  bool _isRawShadowConstructor(
    InstanceCreationExpression node,
    String typeName,
  ) {
    return typeName == 'BoxShadow';
  }

  bool _isRawShadowNamedArgument(NamedExpression node) {
    final name = node.name.label.name;
    if (name == 'elevation') return _isNumberAtLeast(node.expression, 1);
    if (name == 'shadowColor') return _isRawColorExpression(node.expression);
    return false;
  }

  bool _isRawStrokeNamedArgument(NamedExpression node) {
    if (_isInsideCustomPainter(node)) return false;

    final name = node.name.label.name;
    final constructorType = _ancestorConstructorType(node);
    if (constructorType == null) return false;
    if (!_rawStrokeConstructors.contains(constructorType)) return false;

    if (name == 'width') {
      if (constructorType != 'BorderSide' && constructorType != 'Border') {
        return false;
      }
      return _isNumberAtLeast(node.expression, _hairlineLiteralLimit + 0.1);
    }

    if (name == 'strokeWidth') {
      return constructorType == 'CircularProgressIndicator' ||
              constructorType == 'LinearProgressIndicator'
          ? _isNumberAtLeast(node.expression, _hairlineLiteralLimit + 0.1)
          : false;
    }

    if (name == 'thickness') {
      return constructorType == 'Divider' ||
              constructorType == 'VerticalDivider'
          ? _isNumberAtLeast(node.expression, _hairlineLiteralLimit + 0.1)
          : false;
    }

    return false;
  }

  bool _isRawMotionConstructor(
    InstanceCreationExpression node,
    String typeName,
  ) {
    if (typeName == 'Duration') return true;
    if (typeName != 'CurveTween') return false;
    return node.toSource().contains('Curves.');
  }

  bool _isLocalDecoratedSurfaceShell(
    InstanceCreationExpression node,
    String typeName,
  ) {
    if (!isUiSystemScannerPath) return false;
    if (!isFeaturePresentationPath) return false;
    if (!_surfaceShellConstructors.contains(typeName)) return false;

    final decoration = _namedArgument(node, 'decoration');
    if (decoration == null) return false;
    if (decoration is! InstanceCreationExpression) return false;
    if (_constructorTypeName(decoration) != 'BoxDecoration') return false;

    final text = decoration.toSource();
    return text.contains('gradient:') ||
        text.contains('borderRadius:') ||
        text.contains('Border.all') ||
        text.contains('boxShadow:') ||
        text.contains('shape:');
  }

  bool _isRawBreakpointComparison(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator != TokenType.LT &&
        operator != TokenType.LT_EQ &&
        operator != TokenType.GT &&
        operator != TokenType.GT_EQ) {
      return false;
    }

    return (_looksLikeWidthExpression(node.leftOperand) &&
            _isNumberAtLeast(node.rightOperand, 100)) ||
        (_looksLikeWidthExpression(node.rightOperand) &&
            _isNumberAtLeast(node.leftOperand, 100));
  }

  bool _looksLikeWidthExpression(Expression expression) {
    final text = expression.toSource();
    return RegExp(
      r'\b(?:constraints\.(?:maxWidth|minWidth)|MediaQuery\.of\(context\)\.size\.width|size\.width|width)\b',
    ).hasMatch(text);
  }

  bool _isRawColorExpression(Expression expression) {
    if (expression is InstanceCreationExpression) {
      return _isRawColorConstructor(expression);
    }
    if (expression is PrefixedIdentifier) {
      return _isRawColorIdentifier(expression);
    }
    if (expression is PropertyAccess) {
      return _isRawColorPropertyAccess(expression);
    }
    return false;
  }

  bool _isIconConstructorContext(AstNode node) {
    final constructorType = _ancestorConstructorType(node);
    return constructorType == 'Icon' || constructorType == 'IconThemeData';
  }

  Expression? _namedArgument(InstanceCreationExpression node, String name) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression && argument.name.label.name == name) {
        return argument.expression;
      }
    }
    return null;
  }

  String? _ancestorConstructorType(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        return _constructorTypeName(current);
      }
      if (current is Statement || current is CollectionElement) return null;
      current = current.parent;
    }
    return null;
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

  bool _isRawAssetPathLiteral(SimpleStringLiteral node) {
    if (!node.value.startsWith('assets/')) return false;

    final argumentList = node.parent;
    if (argumentList is! ArgumentList) return false;

    final invocation = argumentList.parent;
    if (invocation is InstanceCreationExpression) {
      final typeName = _constructorTypeName(invocation);
      final constructorName = _constructorMemberName(invocation);
      return _assetPathConstructors.contains(typeName) ||
          ((typeName == 'Image' || typeName == 'SvgPicture') &&
              constructorName == 'asset');
    }
    if (invocation is MethodInvocation) {
      final methodName = invocation.methodName.name;
      final target = invocation.target;
      final targetName = target?.toSource();
      if (methodName == 'asset') {
        return targetName == 'Image' || targetName == 'SvgPicture';
      }
      if (methodName == 'load' || methodName == 'loadString') {
        return targetName == 'rootBundle';
      }
    }
    return false;
  }

  bool _iconButtonMissingTooltip(InstanceCreationExpression node) {
    if (_constructorTypeName(node) != 'IconButton') return false;
    if (_namedArgument(node, 'tooltip') != null) return false;
    return !_hasSemanticAncestor(node);
  }

  bool _hasSemanticAncestor(AstNode node) {
    var current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = _constructorTypeName(current);
        if (typeName == 'Semantics' || typeName == 'Tooltip') return true;
      }
      if (current is Statement || current is CollectionElement) return false;
      current = current.parent;
    }
    return false;
  }

  void _reportAtNode(
    AstNode node,
    LintCode diagnosticCode, {
    List<Object> arguments = const [],
  }) {
    if (diagnosticCode != CatchUiLayoutRules.noAllowDebt &&
        _hasUiAllowComment(node)) {
      return;
    }

    rule.reportAtNode(
      node,
      diagnosticCode: diagnosticCode,
      arguments: arguments,
    );
  }

  bool _hasUiAllowComment(AstNode node) {
    final line = _lineForOffset(node.offset);
    return _lineContainsUiAllow(line) || _lineContainsUiAllow(line - 1);
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

  bool _lineContainsUiAllow(int line) {
    if (line < 0 || line >= _lineStarts.length) return false;
    return _allowDebtPattern.hasMatch(_textForLine(line));
  }

  String _lineForOffsetText(int offset) {
    return _textForLine(_lineForOffset(offset));
  }

  String _textForLine(int line) {
    final start = _lineStarts[line];
    final end = line + 1 < _lineStarts.length
        ? _lineStarts[line + 1]
        : source.length;
    return source.substring(start, end);
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

bool _isNumberAtLeast(Expression expression, double minimum) {
  final value = _numberLiteralValue(expression);
  return value != null && value >= minimum;
}

bool _isNumberBetween(
  Expression expression, {
  required double min,
  required double max,
}) {
  final value = _numberLiteralValue(expression);
  return value != null && value >= min && value <= max;
}

double? _numberLiteralValue(Expression expression) {
  if (expression is IntegerLiteral) return expression.value?.toDouble();
  if (expression is DoubleLiteral) return expression.value;
  if (expression is PrefixExpression &&
      expression.operator.type == TokenType.MINUS) {
    final operandValue = _numberLiteralValue(expression.operand);
    return operandValue == null ? null : -operandValue;
  }
  if (expression is ParenthesizedExpression) {
    return _numberLiteralValue(expression.expression);
  }
  return null;
}

bool _isTokenReference(
  Expression expression, [
  Set<String> shadowedTokenNames = const <String>{},
]) {
  bool isSanctionedTokenName(String name) =>
      _tokenSourceNames.contains(name) && !shadowedTokenNames.contains(name);

  if (expression is SimpleIdentifier) {
    return isSanctionedTokenName(expression.name);
  }
  if (expression is PrefixedIdentifier) {
    return isSanctionedTokenName(expression.prefix.name) ||
        isSanctionedTokenName(expression.identifier.name);
  }
  if (expression is PropertyAccess) {
    final target = expression.target;
    return isSanctionedTokenName(expression.propertyName.name) ||
        (target != null && _isTokenReference(target, shadowedTokenNames));
  }
  if (expression is MethodInvocation) {
    final target = expression.target;
    return target is SimpleIdentifier &&
        !shadowedTokenNames.contains('CatchTokens') &&
        target.name == 'CatchTokens' &&
        expression.methodName.name == 'of';
  }
  if (expression is ParenthesizedExpression) {
    return _isTokenReference(expression.expression, shadowedTokenNames);
  }
  return false;
}

Set<String> _declaredTokenShadows(CompilationUnit node) {
  final shadows = <String>{};

  void addIfShadowed(String? name) {
    if (name != null && _tokenSourceNames.contains(name)) {
      shadows.add(name);
    }
  }

  for (final declaration in node.declarations) {
    if (declaration is ClassDeclaration) {
      addIfShadowed(declaration.name.lexeme);
    } else if (declaration is EnumDeclaration) {
      addIfShadowed(declaration.name.lexeme);
    } else if (declaration is ExtensionDeclaration) {
      addIfShadowed(declaration.name?.lexeme);
    } else if (declaration is FunctionDeclaration) {
      addIfShadowed(declaration.name.lexeme);
    } else if (declaration is MixinDeclaration) {
      addIfShadowed(declaration.name.lexeme);
    } else if (declaration is TopLevelVariableDeclaration) {
      for (final variable in declaration.variables.variables) {
        addIfShadowed(variable.name.lexeme);
      }
    }
  }

  return shadows;
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
