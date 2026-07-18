import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchEmptyStateIconStyle { plain, bubble }

enum CatchEmptyStateLayout { stacked, inline }

class CatchEmptyState extends StatelessWidget {
  const CatchEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
    this.surface = false,
    this.iconStyle = CatchEmptyStateIconStyle.plain,
    this.layout = CatchEmptyStateLayout.stacked,
    this.iconSize,
    this.iconContainerSize,
    this.padding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s6),
    this.titleStyle,
    this.messageStyle,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? action;
  final bool surface;
  final CatchEmptyStateIconStyle iconStyle;
  final CatchEmptyStateLayout layout;
  final double? iconSize;
  final double? iconContainerSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final child = CatchEmptyStateContent(
          layout: layout,
          icon: icon,
          iconStyle: iconStyle,
          iconSize: iconSize,
          iconContainerSize: iconContainerSize,
          title: title,
          message: message,
          action: action,
          titleStyle: titleStyle ?? CatchTextStyles.sectionTitle(context),
          messageStyle:
              messageStyle ??
              (layout == CatchEmptyStateLayout.stacked
                  ? CatchTextStyles.bodyS(context, color: t.ink2)
                  : CatchTextStyles.supporting(context, color: t.ink2)),
        );

        final constrainedChild = constraints.hasBoundedWidth
            ? SizedBox(width: constraints.maxWidth, child: child)
            : child;
        if (!constraints.hasBoundedHeight) return constrainedChild;
        return SingleChildScrollView(
          primary: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(child: constrainedChild),
          ),
        );
      },
    );

    if (!surface) {
      return Padding(padding: padding, child: content);
    }

    return CatchSurface(padding: padding, borderColor: t.line, child: content);
  }
}

/// Sliver-native viewport for terminal empty and error states.
///
/// A floating app-shell tab bar overlays the scaffold body instead of reducing
/// its constraints. Centering directly in [SliverFillRemaining] therefore
/// lands below the optical center of the visible region. This primitive owns
/// that shell geometry once for both empty and error content.
class CatchSliverStateViewport extends StatelessWidget {
  const CatchSliverStateViewport({
    super.key,
    required this.child,
    this.accountForBottomOverlay = true,
  });

  final Widget child;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    final bottomOverlayInset = accountForBottomOverlay
        ? AppShellActiveTab.bottomOverlayInsetOf(context)
        : 0.0;
    return SliverFillRemaining(
      // This must stay true: CatchEmptyState uses LayoutBuilder and cannot
      // participate in SliverFillRemaining's intrinsic-height pass.
      // ignore: avoid_redundant_argument_values
      hasScrollBody: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomOverlayInset),
        child: child,
      ),
    );
  }
}

/// Canonical sliver placement for a full-region empty success state.
class CatchSliverEmptyState extends StatelessWidget {
  const CatchSliverEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.action,
    this.iconStyle = CatchEmptyStateIconStyle.plain,
    this.layout = CatchEmptyStateLayout.stacked,
    this.iconSize,
    this.iconContainerSize,
    this.padding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s6),
    this.titleStyle,
    this.messageStyle,
    this.accountForBottomOverlay = true,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final Widget? action;
  final CatchEmptyStateIconStyle iconStyle;
  final CatchEmptyStateLayout layout;
  final double? iconSize;
  final double? iconContainerSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final bool accountForBottomOverlay;

  @override
  Widget build(BuildContext context) {
    return CatchSliverStateViewport(
      accountForBottomOverlay: accountForBottomOverlay,
      child: CatchEmptyState(
        icon: icon,
        title: title,
        message: message,
        action: action,
        iconStyle: iconStyle,
        layout: layout,
        iconSize: iconSize,
        iconContainerSize: iconContainerSize,
        padding: padding,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
      ),
    );
  }
}

class CatchEmptyStateContent extends StatelessWidget {
  const CatchEmptyStateContent({
    super.key,
    required this.layout,
    required this.titleStyle,
    required this.messageStyle,
    this.icon,
    this.iconStyle = CatchEmptyStateIconStyle.plain,
    this.iconSize,
    this.iconContainerSize,
    this.title,
    this.message,
    this.action,
  });

  final CatchEmptyStateLayout layout;
  final IconData? icon;
  final CatchEmptyStateIconStyle iconStyle;
  final double? iconSize;
  final double? iconContainerSize;
  final String? title;
  final String? message;
  final Widget? action;
  final TextStyle titleStyle;
  final TextStyle messageStyle;

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    final titleText = title;
    final messageText = message;
    final actionWidget = action;

    return switch (layout) {
      CatchEmptyStateLayout.stacked => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null)
            CatchEmptyStateIcon(
              icon: iconData,
              style: iconStyle,
              size: iconSize,
              containerSize: iconContainerSize,
            ),
          if (_hasText(titleText)) ...[
            if (iconData != null) gapH12,
            Text(titleText!, style: titleStyle, textAlign: TextAlign.center),
          ],
          if (_hasText(messageText)) ...[
            if (_hasText(titleText)) gapH6 else if (iconData != null) gapH12,
            Text(
              messageText!,
              style: messageStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (actionWidget != null) ...[gapH16, actionWidget],
        ],
      ),
      CatchEmptyStateLayout.inline => Row(
        children: [
          if (iconData != null) ...[
            CatchEmptyStateIcon(
              icon: iconData,
              style: iconStyle,
              size: iconSize,
              containerSize: iconContainerSize ?? 44,
            ),
            gapW12,
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasText(titleText)) Text(titleText!, style: titleStyle),
                if (_hasText(messageText)) ...[
                  if (_hasText(titleText)) gapH4,
                  Text(messageText!, style: messageStyle),
                ],
                if (actionWidget != null) ...[gapH12, actionWidget],
              ],
            ),
          ),
        ],
      ),
    };
  }
}

class CatchEmptyStateIcon extends StatelessWidget {
  const CatchEmptyStateIcon({
    super.key,
    required this.icon,
    required this.style,
    this.size,
    this.containerSize,
  });

  final IconData icon;
  final CatchEmptyStateIconStyle style;
  final double? size;
  final double? containerSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bubbleSize = containerSize ?? 76;

    return switch (style) {
      CatchEmptyStateIconStyle.plain => Icon(
        icon,
        size: size ?? 34,
        color: t.ink3,
      ),
      CatchEmptyStateIconStyle.bubble => SizedBox.square(
        dimension: bubbleSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: size ?? 34, color: t.primary),
        ),
      ),
    };
  }
}

bool _hasText(String? value) => value != null && value.isNotEmpty;
