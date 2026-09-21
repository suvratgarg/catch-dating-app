import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_search_field.dart';
import 'package:catch_ui/src/components/catch_search_field_status.dart';
import 'package:catch_ui/src/components/catch_top_bar_action_row.dart';
import 'package:catch_ui/src/components/catch_top_bar_emphasis.dart';
import 'package:catch_ui/src/components/catch_top_bar_navigation.dart';
import 'package:catch_ui/src/components/catch_top_bar_primary_button.dart';
import 'package:catch_ui/src/components/catch_top_bar_search.dart';
import 'package:catch_ui/src/components/catch_top_bar_tone.dart';
import 'package:catch_ui/src/components/catch_toolbar_metrics.dart';
import 'package:catch_ui/src/components/catch_toolbar_control.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Canonical app chrome. Recipes own typography, hierarchy and geometry.
///
/// Route titles identify the current task; subtitles identify its context.
/// Root titles use the same platform family at headline scale. Search, navigation,
/// actions and identity are functional inputs, never typography overrides.
class CatchTopBar extends StatefulWidget implements CatchScaledPreferredSize {
  const CatchTopBar.route({
    super.key,
    required String this.title,
    this.subtitle,
    this.leading,
    this.navigation = const CatchTopBarNavigation(),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.footer,
    this.search,
  }) : identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null,
       _kind = _TopBarKind.route;

  const CatchTopBar.screen({
    super.key,
    required String this.title,
    this.subtitle,
    this.leading,
    this.navigation = const CatchTopBarNavigation(
      mode: CatchTopBarNavigationMode.none,
    ),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.footer,
    this.search,
  }) : identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null,
       _kind = _TopBarKind.screen;

  const CatchTopBar.primaryRail({
    super.key,
    required String this.title,
    this.subtitle,
    this.leading,
    this.navigation = const CatchTopBarNavigation(
      mode: CatchTopBarNavigationMode.none,
    ),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.footer,
    this.search,
  }) : identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null,
       _kind = _TopBarKind.primaryRail;

  const CatchTopBar.identity({
    super.key,
    required String this.identityName,
    required String this.identitySemanticLabel,
    this.identityPhotoUrl,
    this.onIdentityTap,
    this.leading,
    this.navigation = const CatchTopBarNavigation(),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.footer,
  }) : title = null,
       subtitle = null,
       search = null,
       _kind = _TopBarKind.identity;

  final _TopBarKind _kind;
  final String? title;
  final String? subtitle;
  final String? identityName;
  final String? identitySemanticLabel;
  final String? identityPhotoUrl;
  final VoidCallback? onIdentityTap;
  final Widget? leading;
  final CatchTopBarNavigation navigation;
  final List<Widget> actions;
  final Color? backgroundColor;
  final CatchTopBarTone tone;
  final CatchTopBarEmphasis emphasis;
  final PreferredSizeWidget? footer;
  final CatchTopBarSearch? search;

  bool get _root =>
      _kind == _TopBarKind.screen || _kind == _TopBarKind.primaryRail;
  bool get _safeArea => _kind != _TopBarKind.primaryRail;
  EdgeInsets get _padding => _kind == _TopBarKind.primaryRail
      ? CatchInsets.primaryRailTitleBlock
      : _root
      ? CatchInsets.screenTitleBlock
      : const EdgeInsets.symmetric(
          horizontal: CatchSpacing.screenPx,
          vertical: CatchSpacing.s1,
        );

  static int _lines(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1) >= 1.5 ? 2 : 1;

  @override
  Size get preferredSize => Size.fromHeight(
    CatchLayout.topBarHeight + (footer?.preferredSize.height ?? 0),
  );

  @override
  Size preferredSizeFor(BuildContext context, {double? width}) {
    final bottom = switch (footer) {
      final CatchScaledPreferredSize scaled =>
        scaled.preferredSizeFor(context, width: width).height,
      final bar? => bar.preferredSize.height,
      null => 0.0,
    };
    return Size.fromHeight(
      _contentHeightFor(context, width ?? MediaQuery.sizeOf(context).width) +
          bottom,
    );
  }

  double contentHeightFor(BuildContext context) =>
      _contentHeightFor(context, MediaQuery.sizeOf(context).width);

  double _contentHeightFor(BuildContext context, double width) {
    final target = CatchIconAction.targetExtentFor(CatchIconAction.navSize);
    final largeText = _lines(context) > 1;
    final selectorReflow = largeText && _root && leading is CatchToolbarLeading;
    final hasLeading =
        leading != null ||
        switch (navigation.mode) {
          CatchTopBarNavigationMode.none => false,
          CatchTopBarNavigationMode.auto =>
            Navigator.maybeOf(context)?.canPop() ?? false,
          CatchTopBarNavigationMode.back ||
          CatchTopBarNavigationMode.close => true,
        };
    final leadingSize = leading is CatchToolbarLeading
        ? (leading! as CatchToolbarLeading).toolbarSizeFor(context)
        : Size.square(target);
    final contentWidth = math.max(1.0, width - _padding.horizontal);
    var laneWidth =
        contentWidth -
        (hasLeading && !selectorReflow
            ? leadingSize.width + CatchSpacing.s3
            : 0);
    if (!selectorReflow && (search?.enabled ?? false)) {
      laneWidth -= CatchToolbarMetrics.targetExtent;
      if (!largeText && actions.isNotEmpty)
        laneWidth -= CatchToolbarMetrics.gap;
    }
    if (!largeText && actions.isNotEmpty) {
      laneWidth -= math.max(
        contentWidth * CatchLayout.topBarTrailingMaxRatio,
        CatchTopBarActionRow(actions: actions).minimumWidth,
      );
    }
    if (identityName != null) {
      laneWidth -= 36 + CatchSpacing.s2 + CatchSpacing.micro2;
    }
    laneWidth = math.max(1, laneWidth);
    final titleHeight = _textHeight(
      context,
      identityName ?? title ?? '',
      _root
          ? CatchTextStyles.headline(context)
          : CatchTextStyles.titleL(context),
      laneWidth,
      maxLines: _lines(context),
    );
    var textHeight = titleHeight;
    if (subtitle?.isNotEmpty ?? false) {
      textHeight +=
          CatchGaps.headerTitleToSubtitle +
          _textHeight(
            context,
            subtitle!,
            CatchTextStyles.appBarSubtitle(context),
            laneWidth,
            maxLines: _lines(context),
          );
    }
    if (identityName != null) {
      textHeight += CatchInsets.controlVerticalTight.vertical;
    }
    if (selectorReflow) {
      final searchHeight = (search?.enabled ?? false)
          ? CatchSearchField.heightFor(
              context,
              visualExtent: CatchToolbarMetrics.visualExtent,
            )
          : target;
      final controlsHeight = math.max(
        leadingSize.height,
        math.max(searchHeight, _actionsHeight(context, contentWidth)),
      );
      return math.max(
        CatchLayout.topBarHeight,
        (textHeight +
                CatchToolbarMetrics.gap +
                controlsHeight +
                _padding.vertical)
            .ceilToDouble(),
      );
    }
    var rowHeight = math.max(
      hasLeading ? leadingSize.height : target,
      textHeight,
    );
    if (search?.enabled ?? false) {
      rowHeight = math.max(
        rowHeight,
        CatchSearchField.heightFor(
          context,
          visualExtent: CatchToolbarMetrics.visualExtent,
        ),
      );
    }
    if (!largeText && actions.isNotEmpty) {
      rowHeight = math.max(
        rowHeight,
        _actionsHeight(
          context,
          contentWidth * CatchLayout.topBarTrailingMaxRatio,
        ),
      );
    }
    var height = rowHeight + _padding.vertical;
    if (largeText && actions.isNotEmpty) {
      height += CatchSpacing.s2 + _actionsHeight(context, contentWidth);
    }
    return math.max(CatchLayout.topBarHeight, height.ceilToDouble());
  }

  double _actionsHeight(BuildContext context, double width) {
    var height = CatchPlatformTokens.minimumInteractiveExtent;
    final lane = math.max(
      1.0,
      (width - CatchSpacing.s2 * (actions.length - 1)) / actions.length,
    );
    for (final item in actions) {
      Widget? action = item;
      // Accessibility wrappers do not change a control's painted size.
      while (action is Semantics) {
        action = action.child;
      }
      if (action is Text) {
        height = math.max(
          height,
          _textHeight(
            context,
            action.data ?? action.textSpan?.toPlainText() ?? '',
            action.style ?? DefaultTextStyle.of(context).style,
            lane,
            maxLines: action.maxLines,
          ),
        );
      }
      if (action is CatchTopBarPrimaryButton &&
          !CatchWindowSize.fromWidth(
            MediaQuery.sizeOf(context).width,
          ).isCompact) {
        height = math.max(
          height,
          CatchToolbarControl.sizeFor(context, label: action.label).height,
        );
      }
      if (action is CatchButton && action.isTextAction) {
        final tapTargetSize =
            action.tapTargetSize ??
            TextButtonTheme.of(context).style?.tapTargetSize ??
            Theme.of(context).materialTapTargetSize;
        height = math.max(height, action.minimumSize.height);
        if (tapTargetSize == MaterialTapTargetSize.padded) {
          height = math.max(height, kMinInteractiveDimension);
        }
        final padding = action.padding.resolve(Directionality.of(context));
        final labelWidth =
            lane -
            padding.horizontal -
            (action.leading == null
                ? 0
                : CatchPlatformTokens.minimumInteractiveExtent +
                      action.leadingGap);
        height = math.max(
          height,
          _textHeight(
                context,
                action.label,
                action.textStyle ?? CatchTextStyles.labelL(context),
                math.max(1, labelWidth),
              ) +
              padding.vertical,
        );
      }
    }
    return height.ceilToDouble();
  }

  static double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width, {
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  @override
  State<CatchTopBar> createState() => _CatchTopBarState();
}

enum _TopBarKind { route, identity, screen, primaryRail }

class _CatchTopBarState extends State<CatchTopBar> {
  bool _searchOpen = false;

  bool get _searchEnabled => widget.search?.enabled ?? false;

  bool get _searchOpenEffective {
    if (!_searchEnabled) return false;
    return widget.search?.expanded ?? _searchOpen;
  }

  @override
  void didUpdateWidget(covariant CatchTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_searchEnabled && _searchOpen) _searchOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final bar = LayoutBuilder(
      builder: (context, constraints) =>
          _buildBar(context, constraints.maxWidth),
    );
    if (widget.tone != CatchTopBarTone.overlay) return bar;
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(
            context,
          ).extensions.values.where((extension) => extension is! CatchTokens),
          CatchTokens.dark,
        ],
      ),
      child: bar,
    );
  }

  Widget _buildBar(BuildContext context, double width) {
    final t = CatchTokens.of(context);
    final showDivider = widget.emphasis == CatchTopBarEmphasis.divided;
    final background =
        widget.backgroundColor ??
        switch (widget.tone) {
          CatchTopBarTone.surface => t.surface,
          CatchTopBarTone.overlay => Colors.transparent,
          CatchTopBarTone.page => t.bg,
        };
    const crossAxisAlignment = CrossAxisAlignment.center;
    Widget? leading = widget.leading;
    if (leading == null) {
      final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
      final type = widget.navigation.mode;
      final wantsLeading = switch (type) {
        CatchTopBarNavigationMode.none => false,
        CatchTopBarNavigationMode.back ||
        CatchTopBarNavigationMode.close => true,
        CatchTopBarNavigationMode.auto => canPop,
      };
      if (wantsLeading) {
        final isClose = type == CatchTopBarNavigationMode.close;
        final localizations = MaterialLocalizations.of(context);
        leading = CatchIconAction.toolbar(
          tooltip: isClose
              ? localizations.closeButtonTooltip
              : localizations.backButtonTooltip,
          icon: isClose ? CatchIcons.close : CatchIcons.arrowBackIosNewRounded,
          onPressed:
              widget.navigation.onPressed ??
              () => Navigator.of(context).maybePop(),
        );
      }
    }
    final largeText = CatchTopBar._lines(context) > 1;
    final selectorReflow =
        largeText && widget._root && widget.leading is CatchToolbarLeading;
    final effectiveActions = largeText ? const <Widget>[] : widget.actions;
    final identityName = widget.identityName;
    final body = (identityName != null && identityName.isNotEmpty
        ? Semantics(
            button: widget.onIdentityTap != null,
            label: widget.onIdentityTap == null
                ? null
                : widget.identitySemanticLabel,
            child: InkWell(
              onTap: widget.onIdentityTap,
              borderRadius: BorderRadius.circular(CatchRadius.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: CatchPlatformTokens.minimumInteractiveExtent,
                  minWidth: CatchPlatformTokens.minimumInteractiveExtent,
                ),
                child: Padding(
                  padding: CatchInsets.controlVerticalTight,
                  child: Row(
                    children: [
                      CatchAvatar(
                        size: 36,
                        name: identityName,
                        imageUrl: widget.identityPhotoUrl,
                      ),
                      gapW10,
                      Expanded(
                        child: Text(
                          identityName,
                          maxLines: CatchTopBar._lines(context),
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.titleL(context, color: t.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : widget.title == null || widget.title!.isEmpty
        ? const SizedBox.shrink()
        : Text(
            widget.title!,
            maxLines: CatchTopBar._lines(context),
            overflow: TextOverflow.ellipsis,
            style: widget._root
                ? CatchTextStyles.headline(context, color: t.ink)
                : CatchTextStyles.titleL(context, color: t.ink),
          ));

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        body,
        if (widget.subtitle?.isNotEmpty ?? false) ...[
          const SizedBox(height: CatchGaps.headerTitleToSubtitle),
          Text(
            widget.subtitle!,
            maxLines: CatchTopBar._lines(context),
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.appBarSubtitle(context, color: t.ink2),
          ),
        ],
      ],
    );

    final trailing = effectiveActions.isNotEmpty
        ? CatchTopBarActionRow(actions: effectiveActions)
        : null;
    final title = titleBlock;
    final height = widget._contentHeightFor(context, width);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          padding: widget._padding,
          // The scroll divider paints inside the frame without reducing its title lane.
          foregroundDecoration: BoxDecoration(
            border: showDivider && widget.footer == null
                ? Border(bottom: BorderSide(color: t.line))
                : const Border(),
          ),
          child: LayoutBuilder(
            builder: (context, frameConstraints) => selectorReflow
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      title,
                      const SizedBox(height: CatchToolbarMetrics.gap),
                      _selectorControls(leading!, frameConstraints.maxWidth),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: crossAxisAlignment,
                        children: [
                          if (leading != null) ...[
                            CatchToolbarScope(child: leading),
                            gapW12,
                          ],
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, laneConstraints) {
                                final search = _searchEnabled
                                    ? widget.search
                                    : null;
                                final searchWidget = search == null
                                    ? null
                                    : _searchField(
                                        search,
                                        laneConstraints.maxWidth,
                                      );
                                final maxTrailingWidth =
                                    frameConstraints.maxWidth *
                                    CatchLayout.topBarTrailingMaxRatio;
                                final minimumTrailingWidth =
                                    trailing is CatchTopBarActionRow
                                    ? trailing.minimumWidth
                                    : CatchPlatformTokens
                                          .minimumInteractiveExtent;
                                final trailingEdge = trailing == null
                                    ? const SizedBox.shrink()
                                    : ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              maxTrailingWidth <
                                                  minimumTrailingWidth
                                              ? minimumTrailingWidth
                                              : maxTrailingWidth,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: CatchToolbarScope(
                                                child: trailing,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                if (searchWidget == null) {
                                  return Row(
                                    crossAxisAlignment: crossAxisAlignment,
                                    children: [
                                      Expanded(child: title),
                                      trailingEdge,
                                    ],
                                  );
                                }
                                return Stack(
                                  alignment: Alignment.centerRight,
                                  children: [
                                    ExcludeSemantics(
                                      excluding: _searchOpenEffective,
                                      child: IgnorePointer(
                                        ignoring: _searchOpenEffective,
                                        child: AnimatedOpacity(
                                          opacity: _searchOpenEffective ? 0 : 1,
                                          duration: CatchMotion.base,
                                          curve: CatchMotion.standardCurve,
                                          child: Row(
                                            crossAxisAlignment:
                                                crossAxisAlignment,
                                            children: [
                                              Expanded(child: title),
                                              trailingEdge,
                                              if (trailing != null)
                                                const SizedBox(
                                                  width:
                                                      CatchToolbarMetrics.gap,
                                                ),
                                              SizedBox(
                                                width: CatchToolbarMetrics
                                                    .targetExtent,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    searchWidget,
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      if (largeText && widget.actions.isNotEmpty) ...[
                        gapH8,
                        Visibility(
                          visible: !_searchOpenEffective,
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true,
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: CatchToolbarScope(
                              child: CatchTopBarActionRow(
                                actions: widget.actions,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        if (widget.footer != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: t.line))
                  : const Border(),
            ),
            child: widget.footer!,
          ),
      ],
    );
    return Material(
      color: background,
      surfaceTintColor: Colors.transparent,
      child: widget._safeArea
          ? SafeArea(bottom: false, child: content)
          : content,
    );
  }

  Widget _searchField(CatchTopBarSearch search, double maxWidth) =>
      CatchSearchField.expanding(
        copy: search.copy,
        key: search.fieldKey,
        status: _searchOpenEffective
            ? CatchSearchFieldStatus.expanded
            : CatchSearchFieldStatus.collapsed,
        maxWidth: maxWidth,
        value: search.value,
        contract: search.contract,
        contractExemption: search.contractExemption,
        onChanged: search.onChanged,
        placeholder: search.placeholder,
        autofocus: search.autofocus,
        textInputAction: search.textInputAction,
        onSubmitted: search.onSubmitted,
        onFocusChanged: search.onFocusChanged,
        semanticLabel: search.semanticLabel,
        onOpenSearch: () => _setSearchOpen(true),
        onCloseSearch: () => _setSearchOpen(false),
        tooltip: search.tooltip,
      );

  Widget _selectorControls(Widget leading, double width) {
    final search = _searchEnabled ? widget.search : null;
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Visibility(
          visible: !_searchOpenEffective,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: Padding(
            padding: EdgeInsets.only(
              right: search == null
                  ? 0
                  : CatchToolbarMetrics.targetExtent + CatchToolbarMetrics.gap,
            ),
            child: Row(
              children: [
                CatchToolbarScope(child: leading),
                const Spacer(),
                if (widget.actions.isNotEmpty)
                  CatchToolbarScope(
                    child: CatchTopBarActionRow(actions: widget.actions),
                  ),
              ],
            ),
          ),
        ),
        if (search != null) _searchField(search, width),
      ],
    );
  }

  void _setSearchOpen(bool value) {
    widget.search?.onExpandedChanged?.call(value);
    if (widget.search?.expanded == null) {
      setState(() => _searchOpen = value);
    }
  }
}
