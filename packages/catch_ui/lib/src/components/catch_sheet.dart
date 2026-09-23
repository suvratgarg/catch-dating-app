import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_badge.dart';
import 'package:catch_ui/src/components/catch_sheet_header.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_sheet_drag_indicator.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

Future<T?> showCatchBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  Color? backgroundColor = Colors.transparent,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  Color? barrierColor,
  BoxConstraints? constraints,
  ShapeBorder? shape,
  Clip? clipBehavior,
  bool? showDragHandle,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    backgroundColor: backgroundColor,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    barrierColor: barrierColor,
    constraints: constraints,
    shape: shape,
    clipBehavior: clipBehavior,
    showDragHandle: showDragHandle,
  );
}

/// Whether the sheet delegates scrolling to its body or owns it for all content.
enum CatchSheetMode { content, scrollable }

/// Canonical sheet surface, header and terminal safe region.
class CatchSheet extends StatelessWidget {
  const CatchSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.footer,
    this.glyph,
    this.badge,
    this.badgeTone = CatchBadgeTone.neutral,
    this.trailing,
    this.grabber = true,
    this.keyboardSafe = false,
    this.mode = CatchSheetMode.content,
    this.padding,
  }) : _standard = false;

  /// Bounded, keyboard-safe sheet with one scroll owner and fixed geometry.
  /// Supply natural-height content; the sheet owns vertical scrolling.
  const CatchSheet.standard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.footer,
    this.glyph,
    this.badge,
    this.badgeTone = CatchBadgeTone.neutral,
    this.trailing,
  }) : _standard = true,
       grabber = true,
       keyboardSafe = true,
       mode = CatchSheetMode.scrollable,
       padding = null;

  final bool _standard;

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final IconData? glyph;
  final String? badge;
  final CatchBadgeTone badgeTone;
  final Widget? trailing;
  final bool grabber;

  /// Lets a larger keyboard inset replace the device bottom obstruction.
  final bool keyboardSafe;

  /// Scrolls the whole sheet when its natural content exceeds the viewport.
  final CatchSheetMode mode;

  /// Requested content insets.
  ///
  /// Top and horizontal values are applied as supplied. Bottom may request more
  /// space, but cannot remove the sheet-owned terminal safe region.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final viewPaddingBottom = mediaQuery?.viewPadding.bottom ?? 0.0;
    final keyboardInsetBottom = keyboardSafe && !_standard
        ? mediaQuery?.viewInsets.bottom ?? 0.0
        : 0.0;
    final obstructionBottom = math.max(viewPaddingBottom, keyboardInsetBottom);
    final minimumBottomPadding = math.max(
      CatchLayout.sheetBottomPadding,
      obstructionBottom + CatchLayout.sheetBottomSafeAreaGap,
    );
    final requestedPadding =
        padding?.resolve(Directionality.of(context)) ??
        const EdgeInsets.fromLTRB(
          CatchLayout.sheetHorizontalPadding,
          CatchLayout.sheetTopPadding,
          CatchLayout.sheetHorizontalPadding,
          CatchLayout.sheetBottomPadding,
        );
    final effectivePadding = requestedPadding.copyWith(
      bottom: math.max(requestedPadding.bottom, minimumBottomPadding),
    );
    final right = (badge?.isNotEmpty ?? false)
        ? CatchBadge.functional(label: badge!, tone: badgeTone)
        : trailing;
    final hasHeader =
        (title?.isNotEmpty ?? false) || glyph != null || right != null;

    final content = CatchSurface(
      emphasis: CatchSurfaceEmphasis.floating,
      duration: Duration.zero,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(CatchLayout.sheetTopRadius),
        topRight: Radius.circular(CatchLayout.sheetTopRadius),
        bottomLeft: Radius.circular(CatchLayout.sheetBottomRadius),
        bottomRight: Radius.circular(CatchLayout.sheetBottomRadius),
      ),
      child: Padding(
        key: const ValueKey<String>('catch-bottom-sheet-content-padding'),
        padding: effectivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _standard
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            if (grabber) ...[
              const CatchSheetDragIndicator(),
              const SizedBox(height: CatchLayout.sheetGrabberBottomMargin),
            ],
            if (hasHeader)
              glyph == null
                  ? CatchSheetHeader(
                      title: title,
                      subtitle: subtitle,
                      trailing: right,
                    )
                  : CatchSheetHeader.branded(
                      glyph: glyph!,
                      title: title,
                      subtitle: subtitle,
                      trailing: right,
                    ),
            if (hasHeader)
              const SizedBox(height: CatchLayout.sheetHeaderBodyGap),
            child,
            if (footer != null) ...[gapH16, footer!],
          ],
        ),
      ),
    );
    if (_standard) {
      // Keyboard obstruction belongs outside the scrollable surface so content
      // remains visible rather than requiring a scroll through keyboard padding.
      final keyboard = mediaQuery?.viewInsets.bottom ?? 0.0;
      return LayoutBuilder(
        builder: (context, constraints) {
          final mediaHeight = mediaQuery?.size.height ?? 0.0;
          final viewportHeight = mediaHeight > 0
              ? mediaHeight
              : constraints.maxHeight;
          final availableHeight = math.min(
            constraints.hasBoundedHeight
                ? constraints.maxHeight
                : viewportHeight,
            viewportHeight - (mediaQuery?.padding.top ?? 0.0),
          );
          final height =
              math.max(0.0, availableHeight - keyboard) *
              CatchLayout.sheetViewportMaxHeightFraction;
          return Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: height,
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(CatchLayout.sheetTopRadius),
                ),
                child: SingleChildScrollView(
                  key: const ValueKey('catch-sheet-scroll'),
                  child: content,
                ),
              ),
            ),
          );
        },
      );
    }
    return mode == CatchSheetMode.scrollable
        ? SingleChildScrollView(child: content)
        : content;
  }
}
