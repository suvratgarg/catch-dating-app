import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_state.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewsHistoryScreen extends ConsumerWidget {
  const ReviewsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: const CatchTopBar(title: 'Review history', border: true),
      body: CatchAsyncValueView<String?>(
        value: uidAsync,
        loadingBuilder: (_) => const ReviewsHistorySkeleton(),
        errorBuilder: (_, _, _) => const ReviewsHistoryEmptyState(
          title: 'Sign in to see reviews',
          message: 'Your past event reviews will appear here.',
        ),
        builder: (context, uid) {
          if (uid == null) {
            return const ReviewsHistoryEmptyState(
              title: 'Sign in to see reviews',
              message: 'Your past event reviews will appear here.',
            );
          }
          return ReviewsHistoryProfileGate(uid: uid);
        },
      ),
    );
  }
}

class ReviewsHistoryProfileGate extends ConsumerWidget {
  const ReviewsHistoryProfileGate({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(watchUserProfileProvider);

    return CatchAsyncValueView(
      value: userAsync,
      loadingBuilder: (_) => const ReviewsHistorySkeleton(),
      errorBuilder: (_, _, _) => CatchErrorState(
        title: 'Reviews unavailable',
        message: 'Could not load your profile.',
        onRetry: () => ref.invalidate(watchUserProfileProvider),
      ),
      builder: (context, user) {
        if (user == null) return const ReviewsHistorySkeleton();
        return ReviewsHistoryReviewsGate(uid: uid, user: user);
      },
    );
  }
}

class ReviewsHistoryReviewsGate extends ConsumerWidget {
  const ReviewsHistoryReviewsGate({
    super.key,
    required this.uid,
    required this.user,
  });

  final String uid;
  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(watchReviewsByUserProvider(uid));
    final reviews = reviewsAsync.asData?.value;
    AsyncValue<List<Event>> eventsAsync = const AsyncData<List<Event>>([]);
    if (reviews != null && reviews.isNotEmpty) {
      final eventIds = ReviewsHistoryState.eventIdsFor(reviews);
      if (eventIds.isNotEmpty) {
        eventsAsync = ref.watch(
          watchEventsByIdsProvider(EventsByIdQuery(eventIds)),
        );
      }
    }
    void onRetryReviews() => ref.invalidate(watchReviewsByUserProvider(uid));

    return CatchAsyncValueView<List<Review>>(
      value: reviewsAsync,
      loadingBuilder: (_) => const ReviewsHistorySkeleton(),
      errorBuilder: (_, _, _) => CatchErrorState(
        title: 'Reviews unavailable',
        message: 'Could not load your reviews.',
        onRetry: onRetryReviews,
      ),
      builder: (context, reviews) {
        final state = ReviewsHistoryState.fromAsync(
          uid: uid,
          user: AsyncData(user),
          reviews: AsyncData(reviews),
          events: eventsAsync,
        );
        return ReviewsHistoryBody(
          state: state,
          onRetryProfile: () => ref.invalidate(watchUserProfileProvider),
          onRetryReviews: onRetryReviews,
          onEditReview: state is ReviewsHistoryContent
              ? (row) => _showEditReviewSheet(context, state, row)
              : null,
        );
      },
    );
  }
}

class ReviewsHistoryBody extends StatelessWidget {
  const ReviewsHistoryBody({
    super.key,
    required this.state,
    required this.onRetryProfile,
    required this.onRetryReviews,
    required this.onEditReview,
  });

  final ReviewsHistoryState state;
  final VoidCallback onRetryProfile;
  final VoidCallback? onRetryReviews;
  final ValueChanged<ReviewsHistoryRow>? onEditReview;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ReviewsHistoryLoading() => const ReviewsHistorySkeleton(),
      ReviewsHistoryEmpty(:final title, :final message) =>
        ReviewsHistoryEmptyState(title: title, message: message),
      ReviewsHistoryError(:final title, :final message, :final retryTarget) =>
        CatchErrorState(
          title: title,
          message: message,
          onRetry: switch (retryTarget) {
            ReviewsHistoryRetryTarget.profile => onRetryProfile,
            ReviewsHistoryRetryTarget.reviews => onRetryReviews,
          },
        ),
      ReviewsHistoryContent(:final rows) => ReviewsHistoryList(
        rows: rows,
        onEditReview: onEditReview,
      ),
    };
  }
}

class ReviewsHistoryList extends StatelessWidget {
  const ReviewsHistoryList({
    super.key,
    required this.rows,
    required this.onEditReview,
  });

  final List<ReviewsHistoryRow> rows;
  final ValueChanged<ReviewsHistoryRow>? onEditReview;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: CatchInsets.pageBodyRelaxed,
      itemCount: rows.length,
      separatorBuilder: (_, _) => gapH14,
      itemBuilder: (context, index) =>
          ReviewHistoryItem(row: rows[index], onEditReview: onEditReview),
    );
  }
}

class ReviewHistoryItem extends StatelessWidget {
  const ReviewHistoryItem({
    super.key,
    required this.row,
    required this.onEditReview,
  });

  final ReviewsHistoryRow row;
  final ValueChanged<ReviewsHistoryRow>? onEditReview;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.contextLabel,
          style: CatchTextStyles.labelS(context, color: t.ink2),
        ),
        gapH8,
        ReviewCard(
          review: row.review,
          isOwn: true,
          onEdit: row.canEdit && onEditReview != null
              ? () => onEditReview!(row)
              : null,
        ),
      ],
    );
  }
}

class ReviewsHistoryEmptyState extends StatelessWidget {
  const ReviewsHistoryEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CatchScreenBody(
      scrollable: false,
      child: Center(
        child: CatchEmptyState(
          icon: CatchIcons.rateReviewOutlined,
          title: title,
          message: message,
        ),
      ),
    );
  }
}

class ReviewsHistorySkeleton extends StatelessWidget {
  const ReviewsHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: CatchInsets.pageBodyRelaxed,
      itemCount: 4,
      separatorBuilder: (_, _) => gapH14,
      itemBuilder: (context, _) => const ReviewHistoryItemSkeleton(),
    );
  }
}

class ReviewHistoryItemSkeleton extends StatelessWidget {
  const ReviewHistoryItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
        gapH8,
        CatchSurface(
          borderColor: t.line,
          padding: CatchInsets.tileContentCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CatchSkeleton.circle(size: CatchLayout.rosterRowAvatarExtent),
                  gapW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CatchSkeleton.text(
                          width: CatchLayout.skeletonTextLabelWidth,
                        ),
                        gapH6,
                        Row(
                          children: [
                            for (var i = 0; i < 5; i++) ...[
                              CatchSkeleton.box(
                                width: CatchIcon.badge,
                                height: CatchIcon.badge,
                              ),
                              if (i < 4) gapW3,
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              gapH10,
              CatchSkeleton.textBlock(lines: 2),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _showEditReviewSheet(
  BuildContext context,
  ReviewsHistoryContent state,
  ReviewsHistoryRow row,
) {
  final eventId = row.editEventId;
  if (eventId == null) return Future<void>.value();
  return showWriteReviewSheet(
    context: context,
    clubId: row.review.clubId,
    eventId: eventId,
    reviewer: state.user,
    existingReview: row.review,
  );
}
