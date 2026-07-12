import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        return CatchTabRail<int>(
          selected: controller.index,
          selectionPosition: controller.animation!.value,
          onChanged: controller.animateTo,
          options: [
            CatchOption(
              value: 0,
              label: context.l10n.userProfileProfileSliverHeaderLabelEdit,
            ),
            CatchOption(
              value: 1,
              label: context.l10n.userProfileProfileSliverHeaderLabelPreview,
            ),
            CatchOption(
              value: 2,
              label: context.l10n.userProfileProfileSliverHeaderLabelInsights,
            ),
          ],
        );
      },
    );
  }
}

class ProfileSettingsButton extends StatelessWidget {
  const ProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchIconAction(
      icon: CatchIcons.settingsOutlined,
      tooltip: context.l10n.userProfileProfileSliverHeaderTooltipSettings,
      onPressed: () => context.pushNamed(Routes.settingsScreen.name),
    );
  }
}
