import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen_state.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live, consumer-facing Club Detail composition for an owner-facing read-only
/// preview. The selected [initialClub] renders immediately while live detail
/// data hydrates, matching the consumer route's initial-club fallback policy.
class ClubDetailReadOnlyPreviewSliver extends ConsumerWidget {
  const ClubDetailReadOnlyPreviewSliver({
    super.key,
    required this.initialClub,
    required this.currentUid,
  });

  final Club initialClub;
  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(
      clubDetailViewModelProvider(initialClub.id),
    );

    return viewModelAsync.when(
      loading: () => SliverIgnorePointer(
        sliver: ClubDetailSliverBody(
          state: ClubDetailBodyState.publicPreview(
            club: initialClub,
            uid: currentUid,
            isAuthenticated: currentUid != null,
          ),
          presentationMode: ClubDetailPresentationMode.embeddedReadOnlyPreview,
        ),
      ),
      error: (error, _) => CatchSliverErrorState.fromError(
        error,
        context: AppErrorContext.club,
        fillRemaining: false,
        onRetry: () =>
            ref.invalidate(clubDetailViewModelProvider(initialClub.id)),
      ),
      data: (viewModel) {
        if (viewModel == null) {
          return CatchSliverErrorState(
            title: context.l10n.clubsClubDetailScreenTitleClubNotFound,
            message: context.l10n.clubsClubDetailScreenMessageThisClubIsNo,
            icon: CatchIcons.groupsOutlined,
            fillRemaining: false,
            onRetry: () =>
                ref.invalidate(clubDetailViewModelProvider(initialClub.id)),
          );
        }

        return SliverIgnorePointer(
          sliver: ClubDetailSliverBody(
            state: ClubDetailBodyState.publicPreview(
              club: viewModel.club,
              upcomingEvents: viewModel.upcomingEvents,
              reviews: viewModel.reviews,
              userProfile: viewModel.userProfile,
              uid: viewModel.uid,
              isAuthenticated: viewModel.isAuthenticated,
            ),
            presentationMode:
                ClubDetailPresentationMode.embeddedReadOnlyPreview,
          ),
        );
      },
    );
  }
}
