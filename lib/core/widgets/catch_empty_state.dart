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
        final child = switch (layout) {
          CatchEmptyStateLayout.stacked => _StackedEmptyStateContent(
            icon: icon,
            iconStyle: iconStyle,
            iconSize: iconSize,
            iconContainerSize: iconContainerSize,
            title: title,
            message: message,
            action: action,
            titleStyle: titleStyle ?? CatchTextStyles.sectionTitle(context),
            messageStyle:
                messageStyle ?? CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          CatchEmptyStateLayout.inline => _InlineEmptyStateContent(
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
                CatchTextStyles.supporting(context, color: t.ink2),
          ),
        };

        final constrainedChild = constraints.hasBoundedWidth
            ? SizedBox(width: constraints.maxWidth, child: child)
            : child;
        if (!constraints.hasBoundedHeight) return constrainedChild;
        return SingleChildScrollView(primary: false, child: constrainedChild);
      },
    );

    if (!surface) {
      return Padding(padding: padding, child: content);
    }

    return CatchSurface(padding: padding, borderColor: t.line, child: content);
  }
}

class _StackedEmptyStateContent extends StatelessWidget {
  const _StackedEmptyStateContent({
    required this.icon,
    required this.iconStyle,
    required this.iconSize,
    required this.iconContainerSize,
    required this.title,
    required this.message,
    required this.action,
    required this.titleStyle,
    required this.messageStyle,
  });

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          _EmptyStateIcon(
            icon: icon!,
            style: iconStyle,
            size: iconSize,
            containerSize: iconContainerSize,
          ),
        if (_hasText(title)) ...[
          if (icon != null) gapH12,
          Text(title!, style: titleStyle, textAlign: TextAlign.center),
        ],
        if (_hasText(message)) ...[
          if (_hasText(title)) gapH6 else if (icon != null) gapH12,
          Text(message!, style: messageStyle, textAlign: TextAlign.center),
        ],
        if (action != null) ...[gapH16, action!],
      ],
    );
  }
}

class _InlineEmptyStateContent extends StatelessWidget {
  const _InlineEmptyStateContent({
    required this.icon,
    required this.iconStyle,
    required this.iconSize,
    required this.iconContainerSize,
    required this.title,
    required this.message,
    required this.action,
    required this.titleStyle,
    required this.messageStyle,
  });

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
    return Row(
      children: [
        if (icon != null) ...[
          _EmptyStateIcon(
            icon: icon!,
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
              if (_hasText(title)) Text(title!, style: titleStyle),
              if (_hasText(message)) ...[
                if (_hasText(title)) gapH4,
                Text(message!, style: messageStyle),
              ],
              if (action != null) ...[gapH12, action!],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon({
    required this.icon,
    required this.style,
    required this.size,
    required this.containerSize,
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
