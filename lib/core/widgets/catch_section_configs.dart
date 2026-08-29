part of 'catch_section_layout.dart';

/// Closed, renderer-facing records for [CatchSection].
///
/// Dart record literals can be composed from parameters in a const constructor;
/// nested config objects cannot. Keeping one nullable slot per private variant
/// therefore preserves const construction and stable `CatchSection` identity
/// while ensuring public constructors can only populate supported properties.
typedef _SectionCommonConfig = ({
  String? title,
  String? subtitle,
  Widget? trailing,
  Object? count,
  Color? titleColor,
  double bodyGap,
  List<Widget>? children,
  Widget? child,
});

typedef _DividedSectionConfig = ({
  _SectionCommonConfig common,
  ActivityKind? activityKind,
  bool lead,
  bool first,
  Color? dividerColor,
  double dividerIndent,
  CatchDividerRole dividerRole,
  CatchDividerRole internalDividerRole,
  bool showInternalDividers,
});

typedef _DividedFieldRowsSectionConfig = ({
  _SectionCommonConfig common,
  ActivityKind? activityKind,
  bool lead,
  bool first,
  Widget? footer,
  CatchDividedFieldInteraction? interaction,
});

typedef _ContainedFieldRowsSectionConfig = ({
  _SectionCommonConfig common,
  List<CatchSectionFieldGroup>? groups,
  Widget? footer,
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
  CatchSurfaceElevation elevation,
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
