import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileSliverHeader {
  const ProfileSliverHeader({required this.controller});

  final TabController controller;

  List<Widget> buildSlivers(BuildContext context) {
    final header = CatchSliverHeader(
      title: const _ProfileTitle(),
      bottomHeight: 48,
      bottom: _ProfileTabBar(controller: controller),
    );

    return header.buildSlivers(context);
  }
}

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.bg,
      child: Padding(
        padding: CatchInsets.pageHeaderBody,
        child: Row(
          children: [
            Expanded(
              child: Text('Profile', style: CatchTextStyles.headline(context)),
            ),
            const SizedBox(width: CatchSpacing.s2),
            const _SettingsButton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.bg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: CatchTopBarTabBar(
          controller: controller,
          tabs: const [
            Tab(text: 'Edit'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return CatchTopBarIconAction(
      icon: CatchIcons.settingsOutlined,
      tooltip: 'Settings',
      onPressed: () => context.pushNamed(Routes.settingsScreen.name),
    );
  }
}
