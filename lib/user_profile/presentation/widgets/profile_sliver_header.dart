import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum SelfProfileTab { edit, preview, insights }

class ProfileTabBar extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  const ProfileTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Size get preferredSize => Size.fromHeight(CatchTabRail.minimumHeight);

  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchTabRail.heightFor(context));

  @override
  Widget build(BuildContext context) {
    return CatchTabControllerRail<SelfProfileTab>(
      controller: controller,
      options: [
        CatchOption(
          value: SelfProfileTab.edit,
          label: context.l10n.userProfileProfileSliverHeaderLabelEdit,
        ),
        CatchOption(
          value: SelfProfileTab.preview,
          label: context.l10n.userProfileProfileSliverHeaderLabelPreview,
        ),
        CatchOption(
          value: SelfProfileTab.insights,
          label: context.l10n.userProfileProfileSliverHeaderLabelInsights,
        ),
      ],
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
