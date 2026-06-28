import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSliverHeader {
  const ProfileSliverHeader({required this.controller});

  final TabController controller;

  List<Widget> buildSlivers(BuildContext context) {
    final header = CatchSliverHeader(
      title: _profileTitle(context),
      bottomHeight: 48,
      bottom: _profileTabBar(context, controller: controller),
    );

    return header.buildSlivers(context);
  }
}

Widget _profileTitle(BuildContext context) {
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
          _settingsButton(context),
        ],
      ),
    ),
  );
}

Widget _profileTabBar(
  BuildContext context, {
  required TabController controller,
}) {
  final t = CatchTokens.of(context);

  return Material(
    color: t.bg,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Padding(
        padding: CatchInsets.screenControlRow,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return CatchOptionGroup<int>(
              selected: controller.index,
              onChanged: controller.animateTo,
              options: const [
                CatchOption(value: 0, label: 'Edit'),
                CatchOption(value: 1, label: 'Preview'),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Widget _settingsButton(BuildContext context) {
  return CatchTopBarIconAction(
    icon: CatchIcons.settingsOutlined,
    tooltip: 'Settings',
    onPressed: () => context.pushNamed(Routes.settingsScreen.name),
  );
}
