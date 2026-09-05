import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:flutter/material.dart';

/// A destination with its explanation attached, rather than a field value
/// squeezed into a trailing lane. All copy wraps at its natural height.
class EventRehearsalChoice extends StatelessWidget {
  const EventRehearsalChoice({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.expanded,
    this.icon,
  });

  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool? expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
    expanded: expanded,
    child: CatchRowPressSurface(
      onTap: onTap,
      child: Padding(
        padding: CatchInsets.tileVertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              CatchIconTile(
                icon: icon!,
                iconColor: CatchTokens.of(context).ink,
                size: CatchSpacing.s10,
                iconSize: CatchIcon.sm,
              ),
              gapW16,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CatchTextStyles.sectionTitle(context)),
                  gapH8,
                  Text(description, style: CatchTextStyles.supporting(context)),
                ],
              ),
            ),
            gapW16,
            ExcludeSemantics(
              child: Icon(
                expanded == null
                    ? CatchIcons.arrowForwardRounded
                    : expanded!
                    ? CatchIcons.expandLessRounded
                    : CatchIcons.expandMoreRounded,
                size: CatchIcon.md,
                color: CatchTokens.of(context).ink2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
