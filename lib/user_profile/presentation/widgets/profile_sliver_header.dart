import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.bg,
      child: Padding(
        padding: CatchInsets.screenTitleBlock,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Your profile',
                style: CatchTextStyles.headline(context),
              ),
            ),
            const SizedBox(width: CatchSpacing.s2),
            const ProfileSettingsButton(),
          ],
        ),
      ),
    );
  }
}

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
          options: const [
            CatchOption(value: 0, label: 'Edit'),
            CatchOption(value: 1, label: 'Preview'),
            CatchOption(value: 2, label: 'Insights'),
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
      tooltip: 'Settings',
      onPressed: () => context.pushNamed(Routes.settingsScreen.name),
    );
  }
}
