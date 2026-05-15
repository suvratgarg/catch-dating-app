import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_controller.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({
    super.key,
    required this.uid,
    this.initialProfile,
  });

  final String uid;
  final PublicProfile? initialProfile;

  Future<void> _confirmBlock({
    required BuildContext context,
    required WidgetRef ref,
    required PublicProfile profile,
  }) async {
    final confirmed = await showBlockUserDialog(
      context: context,
      name: profile.name,
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await PublicProfileController.blockUserMutation.run(ref, (tx) async {
      await tx
          .get(publicProfileControllerProvider.notifier)
          .blockUser(targetUserId: profile.uid);
    });
  }

  Future<void> _report({
    required BuildContext context,
    required WidgetRef ref,
    required PublicProfile profile,
  }) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: CatchBottomSheetScaffold(
          title: 'Report ${profile.name}',
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s4,
            CatchSpacing.s3,
            CatchSpacing.s4,
            CatchSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReportReasonTile(
                label: 'Harassment or abuse',
                value: 'harassment_or_abuse',
              ),
              _ReportReasonTile(
                label: 'Fake or misleading profile',
                value: 'fake_or_misleading_profile',
              ),
              _ReportReasonTile(
                label: 'Inappropriate content',
                value: 'inappropriate_content',
              ),
              _ReportReasonTile(label: 'Other safety concern', value: 'other'),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;
    if (!context.mounted) return;

    await PublicProfileController.reportUserMutation.run(ref, (tx) async {
      await tx
          .get(publicProfileControllerProvider.notifier)
          .reportUser(targetUserId: profile.uid, reasonCode: reason);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(watchPublicProfileProvider(uid));
    final profile = profileAsync.asData?.value ?? initialProfile;
    final blockMutation = ref.watch(PublicProfileController.blockUserMutation);
    final reportMutation = ref.watch(
      PublicProfileController.reportUserMutation,
    );
    final currentUser = ref.watch(watchUserProfileProvider).asData?.value;
    final submitting = blockMutation.isPending || reportMutation.isPending;
    final t = CatchTokens.of(context);

    ref.listen(PublicProfileController.blockUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        if (profile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${profile.name} has been blocked.')),
          );
        }
        Navigator.of(context).maybePop();
      }
    });

    ref.listen(PublicProfileController.reportUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
      }
    });

    return MutationErrorSnackbarListener(
      mutation: PublicProfileController.blockUserMutation,
      child: MutationErrorSnackbarListener(
        mutation: PublicProfileController.reportUserMutation,
        child: Scaffold(
          appBar: CatchTopBar(
            title: profile?.name ?? 'Profile',
            actions: [
              if (profile != null)
                CatchTopBarMenuAction<String>(
                  tooltip: 'Profile actions',
                  enabled: !submitting,
                  onSelected: (value) {
                    if (value == 'report') {
                      _report(context: context, ref: ref, profile: profile);
                    } else if (value == 'block') {
                      _confirmBlock(
                        context: context,
                        ref: ref,
                        profile: profile,
                      );
                    }
                  },
                  items: const [
                    CatchActionMenuItem(
                      value: 'report',
                      label: 'Report',
                      icon: Icons.flag_outlined,
                    ),
                    CatchActionMenuItem(
                      value: 'block',
                      label: 'Block',
                      icon: Icons.block_rounded,
                      isDestructive: true,
                    ),
                  ],
                ),
            ],
          ),
          body: profileAsync.when(
            loading: () => profile == null
                ? const CatchLoadingIndicator()
                : _ProfileBody(
                    profile: profile,
                    submitting: submitting,
                    viewerProfile: currentUser,
                  ),
            error: (_, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(CatchSpacing.s6),
                child: Text(
                  'Unable to load this profile.',
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (loadedProfile) {
              if (loadedProfile == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(CatchSpacing.s6),
                    child: Text(
                      'This profile is unavailable.',
                      style: CatchTextStyles.bodyM(context, color: t.ink2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return _ProfileBody(
                profile: loadedProfile,
                submitting: submitting,
                viewerProfile: currentUser,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.submitting,
    this.viewerProfile,
  });

  final PublicProfile profile;
  final bool submitting;
  final UserProfile? viewerProfile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ProfileSurface(
            profile: profile,
            mode: ProfileSurfaceMode.publicProfile,
            bottomPadding: CatchSpacing.s8,
            viewerProfile: viewerProfile?.uid == profile.uid
                ? null
                : viewerProfile,
          ),
        ),
        if (submitting)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: CatchLoadingIndicator(),
            ),
          ),
      ],
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  const _ReportReasonTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}
