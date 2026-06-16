import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
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
    final userAsync = ref.watch(watchUserProfileProvider);
    final uid = uidAsync.asData?.value;

    return Scaffold(
      appBar: const CatchTopBar(title: 'Review history', border: true),
      body: switch ((uid, userAsync)) {
        (null, _) => const _ReviewsHistoryEmpty(
          title: 'Sign in to see reviews',
          message: 'Your past event reviews will appear here.',
        ),
        (final String uid, AsyncData(value: final user?)) =>
          _ReviewsHistoryList(uid: uid, user: user),
        (_, AsyncError()) => CatchErrorState(
          title: 'Reviews unavailable',
          message: 'Could not load your profile.',
          onRetry: () => ref.invalidate(watchUserProfileProvider),
        ),
        _ => const Center(child: CatchLoadingIndicator()),
      },
    );
  }
}

class _ReviewsHistoryList extends ConsumerWidget {
  const _ReviewsHistoryList({required this.uid, required this.user});

  final String uid;
  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(watchReviewsByUserProvider(uid));

    return reviewsAsync.when(
      loading: () => const Center(child: CatchLoadingIndicator()),
      error: (error, stackTrace) => CatchErrorState(
        title: 'Reviews unavailable',
        message: 'Could not load your reviews.',
        onRetry: () => ref.invalidate(watchReviewsByUserProvider(uid)),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return const _ReviewsHistoryEmpty(
            title: 'No reviews yet',
            message: 'After you review a completed event, it will appear here.',
          );
        }

        // Batch-resolve the events for the date labels in one query instead of
        // opening a live event-doc stream per review row.
        final eventIds = <String>{
          for (final review in reviews)
            if (review.eventId != null) review.eventId!,
        };
        final eventsAsync = eventIds.isEmpty
            ? const AsyncData<List<Event>>([])
            : ref.watch(watchEventsByIdsProvider(EventsByIdQuery(eventIds)));
        final eventsById = <String, Event>{
          for (final event in eventsAsync.asData?.value ?? const <Event>[])
            event.id: event,
        };

        return ListView.separated(
          padding: CatchInsets.pageBodyRelaxed,
          itemCount: reviews.length,
          separatorBuilder: (_, _) => gapH14,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _ReviewHistoryItem(
              review: review,
              user: user,
              event: review.eventId == null
                  ? null
                  : eventsById[review.eventId],
            );
          },
        );
      },
    );
  }
}

class _ReviewHistoryItem extends StatelessWidget {
  const _ReviewHistoryItem({
    required this.review,
    required this.user,
    required this.event,
  });

  final Review review;
  final UserProfile user;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final eventId = review.eventId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _reviewContextLabel(event, eventId),
          style: CatchTextStyles.labelS(context, color: t.ink2),
        ),
        gapH8,
        ReviewCard(
          review: review,
          isOwn: true,
          onEdit: eventId == null
              ? null
              : () => showWriteReviewSheet(
                  context: context,
                  clubId: review.clubId,
                  eventId: eventId,
                  reviewer: user,
                  existingReview: review,
                ),
        ),
      ],
    );
  }

  String _reviewContextLabel(Event? event, String? eventId) {
    if (event != null) {
      return '${event.longDateLabel} · ${event.timeRangeLabel}';
    }
    if (eventId != null) return 'Event review';
    return 'Legacy club review';
  }
}

class _ReviewsHistoryEmpty extends StatelessWidget {
  const _ReviewsHistoryEmpty({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: CatchInsets.contentRelaxed,
        child: CatchEmptyState(
          icon: CatchIcons.rateReviewOutlined,
          title: title,
          message: message,
        ),
      ),
    );
  }
}
