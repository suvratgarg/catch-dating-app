part of 'catch_section.dart';

/// Closed, renderer-facing records for [CatchSection].
///
/// Dart record literals can be composed from parameters in a const constructor;
/// nested config objects cannot. Keeping one nullable slot per private variant
/// therefore preserves const construction and stable `CatchSection` identity
/// while ensuring public constructors can only populate supported properties.
typedef _SectionCommonConfig = ({
  String? title,
  String? subtitle,
  Object? count,
  Color? titleColor,
  double bodyGap,
});

typedef _DividedSectionConfig = ({
  _SectionCommonConfig common,
  Color? leadAccent,
  bool lead,
  bool first,
  Color? dividerColor,
  double dividerIndent,
  CatchDividerVariant dividerVariant,
  CatchDividerVariant internalDividerVariant,
  bool showInternalDividers,
});

typedef _DividedFieldRowsSectionConfig = ({
  _SectionCommonConfig common,
  Color? leadAccent,
  bool lead,
  bool first,
  CatchDividedFieldInteraction? interaction,
});

typedef _ContainedFieldRowsSectionConfig = ({
  _SectionCommonConfig common,
  List<CatchSectionFieldGroup>? groups,
  bool focused,
  bool hasError,
  CatchSectionHeaderPlacement headerPlacement,
});

typedef _ContainedSectionConfig = ({
  _SectionCommonConfig common,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  Color? borderColor,
  CatchSurfaceTone tone,
  CatchSurfaceEmphasis emphasis,
  List<BoxShadow>? boxShadow,
  bool showInternalDividers,
  bool focused,
  bool hasError,
});

typedef _PlainSectionConfig = ({
  _SectionCommonConfig common,
  EdgeInsetsGeometry? padding,
  bool showInternalDividers,
});

typedef _HorizontalSectionConfig = ({
  _SectionCommonConfig common,
  int itemCount,
  IndexedWidgetBuilder itemBuilder,
  double? height,
  double spacing,
  CatchRailItemWidth? itemWidth,
  bool showDivider,
  EdgeInsets headerPadding,
  EdgeInsetsGeometry listPadding,
});
