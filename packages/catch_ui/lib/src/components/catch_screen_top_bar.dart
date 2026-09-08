import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_icon_button.dart';
import 'package:catch_ui/src/components/catch_screen_header_title.dart';
import 'package:catch_ui/src/components/catch_top_bar.dart';
import 'package:catch_ui/src/components/catch_top_bar_leading.dart';
import 'package:catch_ui/src/components/catch_top_bar_search.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// App-bar wrapper for static/root screens that use the root-title voice.
///
/// The factory requires [BuildContext] because [preferredSize] must be resolved
/// synchronously from the caller's text scaler and direction before this
/// widget's own [build] method runs. Stateful search and identity headers use
/// [CatchTopBar] directly.
class CatchScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  factory CatchScreenTopBar({
    Key? key,
    required BuildContext context,
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    CatchTopBarLeading leadingType = CatchTopBarLeading.auto,
    List<Widget> actions = const <Widget>[],
    int titleMaxLines = 1,
    TextStyle? titleStyle,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
    Color? backgroundColor,
    bool surface = false,
    bool divider = false,
    bool gutter = false,
    bool applySafeArea = true,
    PreferredSizeWidget? bottom,
    Widget? trailing,
    CatchTopBarSearch? search,
  }) => CatchScreenTopBar._(
    heightFor(
      context: context,
      hasEyebrow: eyebrow?.isNotEmpty ?? false,
      hasSubtitle: subtitle?.isNotEmpty ?? false,
      titleMaxLines: titleMaxLines,
      hasActions: actions.isNotEmpty,
      titleStyle: titleStyle,
    ),
    key: key,
    title: title,
    eyebrow: eyebrow,
    subtitle: subtitle,
    leading: leading,
    leadingType: leadingType,
    actions: actions,
    titleMaxLines: titleMaxLines,
    titleStyle: titleStyle,
    rowCrossAxisAlignment: rowCrossAxisAlignment,
    backgroundColor: backgroundColor,
    surface: surface,
    divider: divider,
    gutter: gutter,
    applySafeArea: applySafeArea,
    contentPadding: CatchInsets.screenTitleBlock,
    bottom: bottom,
    trailing: trailing,
    search: search,
  );

  /// Root-title chrome embedded in the root screen scaffold.
  ///
  /// The root owner supplies the safe area and pinned rail, so this variant
  /// uses the same content-sized title band and 4 pt rail handoff as the
  /// non-search title path instead of inheriting the 56 pt app-bar minimum.
  factory CatchScreenTopBar.primaryRail({
    Key? key,
    required BuildContext context,
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    List<Widget> actions = const <Widget>[],
    int titleMaxLines = 1,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
    CatchTopBarSearch? search,
  }) => CatchScreenTopBar._(
    _heightFor(
      context: context,
      hasEyebrow: eyebrow?.isNotEmpty ?? false,
      hasSubtitle: subtitle?.isNotEmpty ?? false,
      titleMaxLines: titleMaxLines,
      hasActions: actions.isNotEmpty,
      contentPadding: CatchInsets.primaryRailTitleBlock,
      minimumHeight: 0,
    ),
    key: key,
    title: title,
    eyebrow: eyebrow,
    subtitle: subtitle,
    leading: leading,
    leadingType: CatchTopBarLeading.none,
    actions: actions,
    titleMaxLines: titleMaxLines,
    titleStyle: null,
    rowCrossAxisAlignment: rowCrossAxisAlignment,
    backgroundColor: null,
    surface: false,
    divider: false,
    gutter: false,
    applySafeArea: false,
    contentPadding: CatchInsets.primaryRailTitleBlock,
    bottom: null,
    trailing: null,
    search: search,
  );

  const CatchScreenTopBar._(
    this._resolvedHeight, {
    super.key,
    required this.title,
    required this.eyebrow,
    required this.subtitle,
    required this.leading,
    required this.leadingType,
    required this.actions,
    required this.titleMaxLines,
    required this.titleStyle,
    required this.rowCrossAxisAlignment,
    required this.backgroundColor,
    required this.surface,
    required this.divider,
    required this.gutter,
    required this.applySafeArea,
    required this.contentPadding,
    required this.bottom,
    required this.trailing,
    required this.search,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final CatchTopBarLeading leadingType;
  final List<Widget> actions;
  final int titleMaxLines;
  final TextStyle? titleStyle;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final Color? backgroundColor;
  final bool surface;
  final bool divider;
  final bool gutter;
  final bool applySafeArea;
  final EdgeInsetsGeometry? contentPadding;
  final PreferredSizeWidget? bottom;
  final Widget? trailing;
  final CatchTopBarSearch? search;
  final double _resolvedHeight;

  static double heightFor({
    required BuildContext context,
    bool hasEyebrow = false,
    bool hasSubtitle = false,
    int titleMaxLines = 1,
    bool hasActions = false,
    TextStyle? titleStyle,
  }) => _heightFor(
    context: context,
    hasEyebrow: hasEyebrow,
    hasSubtitle: hasSubtitle,
    titleMaxLines: titleMaxLines,
    hasActions: hasActions,
    titleStyle: titleStyle,
    contentPadding: CatchInsets.screenTitleBlock,
    minimumHeight: hasEyebrow || hasSubtitle || titleMaxLines > 1
        ? CatchLayout.browseHeaderHeight
        : CatchLayout.topBarHeight,
  );

  static double _heightFor({
    required BuildContext context,
    required bool hasEyebrow,
    required bool hasSubtitle,
    required int titleMaxLines,
    required bool hasActions,
    TextStyle? titleStyle,
    required EdgeInsetsGeometry contentPadding,
    required double minimumHeight,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final largeText = textScaler.scale(1) >= 1.5;
    final resolvedPadding = contentPadding.resolve(Directionality.of(context));
    double lineHeight(TextStyle style) =>
        textScaler.scale(style.fontSize!) * (style.height ?? 1);

    var textHeight =
        lineHeight(titleStyle ?? CatchTextStyles.headline(context)) *
        titleMaxLines;
    if (hasEyebrow) {
      textHeight +=
          lineHeight(CatchTextStyles.kicker(context)) + CatchSpacing.micro2;
    }
    if (hasSubtitle) {
      textHeight +=
          CatchGaps.headerTitleToSubtitle +
          lineHeight(CatchTextStyles.supporting(context)) * (largeText ? 2 : 1);
    }
    if (largeText && hasActions) {
      textHeight += CatchLayout.topBarLargeTextActionReserve;
    }

    final actionExtent = CatchIconButton.targetExtentFor(
      CatchIconButton.navSize,
    );
    final contentHeight = textHeight > actionExtent ? textHeight : actionExtent;
    // Text layout can round a scaled glyph run slightly above the nominal
    // style height, so reserve the next logical pixel in the preferred size.
    final requiredHeight = (contentHeight + resolvedPadding.vertical)
        .ceilToDouble();
    return requiredHeight > minimumHeight ? requiredHeight : minimumHeight;
  }

  double get height => _resolvedHeight;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    return CatchTopBar(
      titleWidget: CatchScreenHeaderTitle(
        title: title,
        eyebrow: eyebrow,
        subtitle: subtitle,
        actions: largeText ? actions : const <Widget>[],
        titleMaxLines: titleMaxLines,
        titleStyle: titleStyle,
        rowCrossAxisAlignment: rowCrossAxisAlignment,
      ),
      large: false,
      leading: leading,
      leadingType: leadingType,
      actions: largeText ? const <Widget>[] : actions,
      backgroundColor: backgroundColor,
      surface: surface,
      divider: divider,
      gutter: gutter,
      applySafeArea: applySafeArea,
      contentPadding: contentPadding,
      height: height,
      contentCrossAxisAlignment: CrossAxisAlignment.start,
      bottom: bottom,
      trailing: trailing,
      search: search,
    );
  }
}
