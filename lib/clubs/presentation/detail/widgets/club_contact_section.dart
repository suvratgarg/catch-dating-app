import 'dart:async';

import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen_state.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef ClubContactActionHandler =
    Future<void> Function(ClubContactAction action);

class ClubContactSection extends StatelessWidget {
  const ClubContactSection({
    super.key,
    required this.actions,
    this.showTitle = true,
    this.onContactSelected,
  });

  final List<ClubContactAction> actions;
  final bool showTitle;
  final ClubContactActionHandler? onContactSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSection.contained(
      title: showTitle
          ? context.l10n.clubsClubContactSectionTitleContact
          : null,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.none,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final action in actions)
            Padding(
              padding: CatchInsets.detailInlineRowBottomGap,
              child: CatchField.action(
                icon: _contactActionIcon(action.kind),
                iconColor: t.ink,
                title: action.label,
                onTap: onContactSelected != null
                    ? () => unawaited(onContactSelected!(action))
                    : null,
                action: Icon(CatchIcons.arrowUpRight, size: CatchIcon.sm),
              ),
            ),
        ],
      ),
    );
  }
}

IconData _contactActionIcon(ClubContactActionKind kind) {
  return switch (kind) {
    ClubContactActionKind.instagram => CatchIcons.alternateEmailRounded,
    ClubContactActionKind.phone => CatchIcons.callOutlined,
    ClubContactActionKind.email => CatchIcons.emailOutlined,
  };
}
