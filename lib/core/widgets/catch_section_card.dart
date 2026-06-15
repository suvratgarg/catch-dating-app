import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_panel.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Shared content-section card with the same hierarchy used by polished
/// profile guidance: sentence-case title, optional context, and one body.
class CatchSectionCard extends StatelessWidget {
  const CatchSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(CatchSpacing.s4),
    this.headerBodyGap = CatchSpacing.s3,
    this.borderColor,
    this.tone = CatchSurfaceTone.surface,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double headerBodyGap;
  final Color? borderColor;
  final CatchSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasHeader = title != null || subtitle != null || trailing != null;

    return CatchPanel(
      tone: tone,
      borderColor: borderColor ?? t.line,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || subtitle != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: CatchTextStyles.sectionTitle(
                              context,
                              color: t.ink,
                            ),
                          ),
                        if (subtitle != null) ...[
                          if (title != null) gapH4,
                          Text(
                            subtitle!,
                            style: CatchTextStyles.supporting(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (trailing != null) ...[
                  gapW12,
                  DefaultTextStyle.merge(
                    style: CatchTextStyles.sectionTitle(context, color: t.ink),
                    child: trailing!,
                  ),
                ],
              ],
            ),
            SizedBox(height: headerBodyGap),
          ],
          child,
        ],
      ),
    );
  }
}
