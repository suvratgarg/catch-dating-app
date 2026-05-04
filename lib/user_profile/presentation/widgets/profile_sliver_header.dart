import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSliverHeader extends CatchSliverTopBar {
  const ProfileSliverHeader({super.key}) : super(
         titleWidget: const _ProfileTitle(),
         leading: const SizedBox.shrink(),
         actions: const [_SettingsButton(), _OverflowMenu()],
         bottom: const CatchTopBarTabBar(
           tabs: [Tab(text: 'Profile'), Tab(text: 'Preview')],
         ),
         expandedHeight: 112,
       );
}

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        kToolbarHeight + 8,
        CatchSpacing.s4,
        CatchSpacing.s3,
      ),
      child: Text('You', style: CatchTextStyles.displayL(context)),
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
    return CatchTopBarMenuAction<String>(
      tooltip: 'More profile actions',
      onSelected: (value) {
        if (value == 'payments') {
          context.pushNamed(Routes.paymentHistoryScreen.name);
        } else if (value == 'signOut') {
          ref.read(authRepositoryProvider).signOut();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'payments', child: Text('Payment history')),
        PopupMenuItem(value: 'signOut', child: Text('Sign out')),
      ],
    );
  }
}
