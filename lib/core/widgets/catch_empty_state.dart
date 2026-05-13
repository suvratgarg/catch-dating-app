import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchEmptyStateIconStyle { plain, bubble }

class CatchEmptyState extends StatelessWidget {
  const CatchEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.surface = true,
    this.iconStyle = CatchEmptyStateIconStyle.bubble,
    this.iconSize,
    this.padding = const EdgeInsets.all(CatchSpacing.s5),
    this.titleStyle,
    this.messageStyle,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool surface;
  final CatchEmptyStateIconStyle iconStyle;
  final double? iconSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final column = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _EmptyStateIcon(icon: icon, style: iconStyle, size: iconSize),
            gapH18,
            Text(
              title,
              style: titleStyle ?? CatchTextStyles.displayM(context),
              textAlign: TextAlign.center,
            ),
            gapH8,
            Text(
              message,
              style:
                  messageStyle ?? CatchTextStyles.bodyM(context, color: t.ink2),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[gapH18, action!],
          ],
        );

        if (!constraints.hasBoundedWidth) return column;
        return SizedBox(width: constraints.maxWidth, child: column);
      },
    );

    if (!surface) {
      return Padding(padding: padding, child: content);
    }

    return CatchSurface(padding: padding, borderColor: t.line, child: content);
  }
}

class _EmptyStateIcon extends StatelessWidget {
  const _EmptyStateIcon({
    required this.icon,
    required this.style,
    required this.size,
  });

  final IconData icon;
  final CatchEmptyStateIconStyle style;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return switch (style) {
      CatchEmptyStateIconStyle.plain => Icon(
        icon,
        size: size ?? 72,
        color: t.line2,
      ),
      CatchEmptyStateIconStyle.bubble => Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(color: t.primarySoft, shape: BoxShape.circle),
        child: Icon(icon, size: size ?? 34, color: t.primary),
      ),
    };
  }
}
