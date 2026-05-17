import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Read-only club review aggregate.
///
/// Reviews are event-scoped, so club pages must never expose review creation.
class ClubReviewsSection extends StatelessWidget {
  const ClubReviewsSection({
    super.key,
    required this.reviews,
    required this.currentUid,
    this.maxVisibleReviews = 3,
  });

  final List<Review> reviews;
  final String? currentUid;
  final int maxVisibleReviews;

  @override
  Widget build(BuildContext context) {
    return ReviewsPreviewSection(
      reviews: reviews,
      currentUid: currentUid,
      maxVisibleReviews: maxVisibleReviews,
      showAllAction: false,
    );
  }
}

/// Event-scoped reviews with write/edit CTA for attended attendees.
class EventReviewsSection extends StatelessWidget {
  const EventReviewsSection({
    super.key,
    required this.clubId,
    required this.eventId,
    required this.reviews,
    required this.currentUid,
    required this.userProfile,
    this.isHost = false,
    this.hasAttended = false,
  });

  final String clubId;
  final String eventId;
  final List<Review> reviews;
  final String? currentUid;
  final UserProfile? userProfile;

  /// True when the current user is the host — hides the write-review CTA.
  final bool isHost;

  /// True when the current user attended the event — gates event-level reviews.
  final bool hasAttended;

  @override
  Widget build(BuildContext context) {
    final canWriteEventReview = userProfile != null && !isHost && hasAttended;
    final existingReview = canWriteEventReview && currentUid != null
        ? reviews.where((r) => r.reviewerUserId == currentUid).firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewsPreviewSection(
          reviews: reviews,
          currentUid: currentUid,
          maxVisibleReviews: 3,
          showAllAction: reviews.length > 3,
          onEditReview: canWriteEventReview
              ? (review) => showWriteReviewSheet(
                  context: context,
                  clubId: clubId,
                  eventId: eventId,
                  reviewer: userProfile!,
                  existingReview: review,
                )
              : null,
        ),

        // Review writes are event-scoped so one user can review each event once.
        if (canWriteEventReview) ...[
          gapH12,
          CatchButton(
            key: ReviewKeys.writeReviewButton,
            label: existingReview != null
                ? 'Edit your review'
                : 'Write a review',
            onPressed: () => showWriteReviewSheet(
              context: context,
              clubId: clubId,
              eventId: eventId,
              reviewer: userProfile!,
              existingReview: existingReview,
            ),
            variant: CatchButtonVariant.secondary,
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

class ReviewsPreviewSection extends StatelessWidget {
  const ReviewsPreviewSection({
    super.key,
    required this.reviews,
    required this.currentUid,
    this.maxVisibleReviews = 3,
    this.showAllAction = false,
    this.onEditReview,
  });

  final List<Review> reviews;
  final String? currentUid;
  final int maxVisibleReviews;
  final bool showAllAction;
  final ValueChanged<Review>? onEditReview;

  void _showAllReviews(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => CatchBottomSheetScaffold(
        title: 'All reviews (${reviews.length})',
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.68,
          child: ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (_, _) => gapH12,
            itemBuilder: (_, index) {
              final review = reviews[index];
              final isOwn = review.reviewerUserId == currentUid;
              return ReviewCard(
                review: review,
                isOwn: isOwn,
                onEdit: isOwn && onEditReview != null
                    ? () => onEditReview!(review)
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final avgRating = reviews.isEmpty
        ? null
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final previewReviews = reviews
        .take(maxVisibleReviews)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text('Reviews', style: CatchTextStyles.titleL(context)),
            ),
            if (avgRating != null) ...[
              StarRating(rating: avgRating.round(), size: 14),
              const SizedBox(width: 4),
              Text(
                '${avgRating.toStringAsFixed(1)} · ${reviews.length}',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // ── Review list ──────────────────────────────────────────────────────
        if (reviews.isEmpty)
          CatchEmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            message: 'Reviews from attendees will appear here after an event.',
            surface: false,
            iconSize: 28,
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
            titleStyle: CatchTextStyles.titleM(context),
            messageStyle: CatchTextStyles.bodyS(context, color: t.ink2),
          )
        else ...[
          for (var i = 0; i < previewReviews.length; i++) ...[
            ReviewCard(
              review: previewReviews[i],
              isOwn: previewReviews[i].reviewerUserId == currentUid,
              onEdit:
                  onEditReview != null &&
                      previewReviews[i].reviewerUserId == currentUid
                  ? () => onEditReview!(previewReviews[i])
                  : null,
            ),
            if (i < previewReviews.length - 1) gapH12,
          ],
          if (showAllAction && reviews.length > maxVisibleReviews) ...[
            gapH4,
            CatchTextButton(
              key: ReviewKeys.seeAllReviewsButton,
              label: 'See all ${reviews.length} reviews',
              onPressed: () => _showAllReviews(context),
            ),
          ],
        ],
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.isOwn,
    this.onEdit,
  });

  final Review review;
  final bool isOwn;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(Sizes.p14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PersonAvatar(name: review.reviewerName, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwn ? 'You' : review.reviewerName,
                      style: CatchTextStyles.labelL(context),
                    ),
                    StarRating(rating: review.rating, size: 12),
                  ],
                ),
              ),
              if (isOwn && onEdit != null)
                Tooltip(
                  message: 'Edit review',
                  child: IconBtn(
                    key: ReviewKeys.editReviewButton(review.id),
                    onTap: onEdit!,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: t.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: CatchTextStyles.bodyM(context, color: t.ink2),
            ),
          ],
        ],
      ),
    );
  }
}
