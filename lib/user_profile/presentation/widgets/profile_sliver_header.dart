import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSliverHeader {
  const ProfileSliverHeader({required this.controller});

  final TabController controller;

  List<Widget> buildSlivers(BuildContext context) {
    final header = CatchSliverHeader(
      title: const _ProfileTitle(),
      titleHeight: 104,
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
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s4,
          CatchSpacing.s5,
          CatchSpacing.s3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('Profile', style: CatchTextStyles.displayL(context)),
            ),
            const SizedBox(width: CatchSpacing.s2),
            const _SettingsButton(),
            const SizedBox(width: CatchSpacing.s2),
            const _OverflowMenu(),
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
      icon: Icons.settings_outlined,
      tooltip: 'Settings',
      onPressed: () => context.pushNamed(Routes.settingsScreen.name),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutMutation = ref.watch(AuthSessionController.signOutMutation);

    return CatchTopBarMenuAction<String>(
      tooltip: 'More profile actions',
      onSelected: (value) {
        if (value == 'payments') {
          context.pushNamed(Routes.paymentHistoryScreen.name);
        } else if (value == 'signOut') {
          if (signOutMutation.isPending) return;
          AuthSessionController.signOutMutation.run(
            ref,
            (tx) async =>
                tx.get(authSessionControllerProvider.notifier).signOut(),
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'payments', child: Text('Payment history')),
        PopupMenuItem(value: 'signOut', child: Text('Sign out')),
      ],
    );
  }
}
