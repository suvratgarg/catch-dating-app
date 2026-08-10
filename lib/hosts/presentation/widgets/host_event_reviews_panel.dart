import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/shared/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Host-owned review workspace for one event.
///
/// Responses are written through the existing callable and are rendered by the
/// same review document on the public organizer listing. Keeping this panel in
/// the Host report makes the review workflow available without the Consumer
/// app or a Consumer profile.
class HostEventReviewsPanel extends ConsumerWidget {
  const HostEventReviewsPanel({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(watchReviewsForEventProvider(eventId));
    return CatchSection.contained(
      title: context.l10n.hostsHostEventReviewsTitlePublicReviews,
      subtitle: context.l10n.hostsHostEventReviewsSubtitlePublicResponse,
      child: CatchAsyncValueView<List<Review>>(
        value: reviewsAsync,
        errorContext: AppErrorContext.event,
        onRetry: () => ref.invalidate(watchReviewsForEventProvider(eventId)),
        builder: (context, reviews) => ReviewsPreviewSection(
          reviews: reviews,
          currentUid: null,
          maxVisibleReviews: 5,
          showAllAction: reviews.length > 5,
          showHeader: false,
          emptyPresentation: ReviewsEmptyPresentation.inline,
          emptyMessage: context.l10n.hostsHostEventReviewsMessageEmpty,
          onRespondToReview: (review) =>
              showReviewResponseSheet(context: context, review: review),
        ),
      ),
    );
  }
}
