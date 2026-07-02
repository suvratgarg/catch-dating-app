import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/block_user_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_controller.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen_state.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen_view_model.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({
    super.key,
    required this.uid,
    this.initialProfile,
    this.sharedRunTitle,
  });

  final String uid;
  final PublicProfile? initialProfile;
  final String? sharedRunTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(
      publicProfileScreenStateProvider(
        PublicProfileScreenStateArgs(
          uid: uid,
          initialProfile: initialProfile,
          sharedRunTitle: sharedRunTitle,
        ),
      ),
    );
    final profile = screenState.profile;

    Future<void> confirmBlock(PublicProfile profile) async {
      final confirmed = await showBlockUserDialog(
        context: context,
        name: profile.name,
      );
      if (confirmed != true) return;
      if (!context.mounted) return;

      try {
        await PublicProfileController.blockUserMutation.run(ref, (tx) async {
          await tx
              .get(publicProfileControllerProvider.notifier)
              .blockUser(targetUserId: profile.uid);
        });
      } catch (_) {
        return;
      }
    }

    Future<void> report(PublicProfile profile) async {
      final reason = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        builder: (context) => SafeArea(
          child: PublicProfileReportSheet(
            profileName: profile.name,
            onReasonSelected: (reason) => Navigator.of(context).pop(reason),
          ),
        ),
      );
      if (reason == null) return;
      if (!context.mounted) return;

      try {
        await PublicProfileController.reportUserMutation.run(ref, (tx) async {
          await tx
              .get(publicProfileControllerProvider.notifier)
              .reportUser(targetUserId: profile.uid, reasonCode: reason);
        });
      } catch (_) {
        return;
      }
    }

    ref.listen(PublicProfileController.blockUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        if (profile != null) {
          showCatchSnackBar(context, '${profile.name} has been blocked.');
        }
        Navigator.of(context).maybePop();
      }
    });

    ref.listen(PublicProfileController.reportUserMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        showCatchSnackBar(context, 'Report submitted.');
      }
    });

    return CatchMutationErrorListener(
      mutation: PublicProfileController.blockUserMutation,
      child: CatchMutationErrorListener(
        mutation: PublicProfileController.reportUserMutation,
        child: Scaffold(
          appBar: CatchTopBar(
            title: screenState.title,
            actions: [
              if (screenState.showSafetyActions)
                CatchTopBarMenuAction<String>(
                  tooltip: 'Profile actions',
                  enabled: screenState.enableSafetyActions,
                  onSelected: (value) {
                    if (value == 'report') {
                      report(profile!);
                    } else if (value == 'block') {
                      confirmBlock(profile!);
                    }
                  },
                  items: [
                    CatchActionMenuItem(
                      value: 'report',
                      label: 'Report',
                      icon: CatchIcons.flagOutlined,
                    ),
                    CatchActionMenuItem(
                      value: 'block',
                      label: 'Block',
                      icon: CatchIcons.blockRounded,
                      isDestructive: true,
                    ),
                  ],
                ),
            ],
          ),
          body: PublicProfileScreenBody(
            state: screenState,
            onRetry:
                screenState.retryIntent ==
                    PublicProfileRetryIntent.reloadProfile
                ? () => ref.invalidate(
                    watchPublicProfileProvider(screenState.uid),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class PublicProfileScreenBody extends StatelessWidget {
  const PublicProfileScreenBody({super.key, required this.state, this.onRetry});

  final PublicProfileScreenState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case PublicProfileRouteStatus.loading:
        return const ProfileSurfaceSkeleton(bottomPadding: CatchSpacing.s8);
      case PublicProfileRouteStatus.error:
        return CatchErrorState.fromError(
          state.error!,
          context: AppErrorContext.profile,
          onRetry: onRetry,
        );
      case PublicProfileRouteStatus.unavailable:
        return Center(
          child: CatchEmptyState(
            icon: CatchIcons.personOffOutlined,
            title: 'Profile unavailable',
            message: 'This profile is no longer available on Catch.',
          ),
        );
      case PublicProfileRouteStatus.ready:
        return PublicProfileBody(
          profile: state.profile!,
          submitting: state.isSubmitting,
          viewerProfile: state.viewerProfileForSurface,
          sharedRunTitle: state.sharedRunTitle,
        );
    }
  }
}

class PublicProfileBody extends StatelessWidget {
  const PublicProfileBody({
    super.key,
    required this.profile,
    required this.submitting,
    this.viewerProfile,
    this.sharedRunTitle,
  });

  final PublicProfile profile;
  final bool submitting;
  final UserProfile? viewerProfile;
  final String? sharedRunTitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
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
            sharedRunTitle: sharedRunTitle,
          ),
        ),
        if (submitting)
          Positioned.fill(
            child: ColoredBox(
              color: t.overlay,
              child: const CatchLoadingIndicator(),
            ),
          ),
      ],
    );
  }
}

class PublicProfileReportSheet extends StatelessWidget {
  const PublicProfileReportSheet({
    super.key,
    required this.profileName,
    required this.onReasonSelected,
  });

  final String profileName;
  final ValueChanged<String> onReasonSelected;

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: 'Report $profileName',
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PublicProfileReportReasonTile(
            label: 'Harassment or abuse',
            value: 'harassment_or_abuse',
            onSelected: onReasonSelected,
          ),
          PublicProfileReportReasonTile(
            label: 'Fake or misleading profile',
            value: 'fake_or_misleading_profile',
            onSelected: onReasonSelected,
          ),
          PublicProfileReportReasonTile(
            label: 'Inappropriate content',
            value: 'inappropriate_content',
            onSelected: onReasonSelected,
          ),
          PublicProfileReportReasonTile(
            label: 'Other safety concern',
            value: 'other',
            onSelected: onReasonSelected,
          ),
        ],
      ),
    );
  }
}

class PublicProfileReportReasonTile extends StatelessWidget {
  const PublicProfileReportReasonTile({
    super.key,
    required this.label,
    required this.value,
    required this.onSelected,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return CatchField.nav(
      title: label,
      icon: CatchIcons.flagOutlined,
      onTap: () => onSelected(value),
    );
  }
}
