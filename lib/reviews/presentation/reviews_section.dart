import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Renders a reviews list with a header summary and a write/edit button.
///
/// Club pages use this as a read-only aggregate. Run pages pass both
/// [runClubId] and [runId], and attended users can write or edit their
/// run-scoped review.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.runClubId,
    this.runId,
    required this.reviews,
    required this.currentUid,
    required this.userProfile,
    this.isHost = false,
    this.isMember = false,
    this.hasAttended = false,
  });

  final String runClubId;
  final String? runId;
  final List<Review> reviews;
  final String? currentUid;
  final UserProfile? userProfile;

  /// True when the current user is the host — hides the write-review CTA.
  final bool isHost;

  /// True when the current user is a club member. Club pages currently show
  /// review aggregates only; writes remain run-scoped.
  final bool isMember;

  /// True when the current user attended the run — gates run-level reviews.
  final bool hasAttended;

  static const _previewCount = 5;

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
            itemBuilder: (_, index) => ReviewCard(
              review: reviews[index],
              isOwn: reviews[index].reviewerUserId == currentUid,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final canWriteRunReview =
        userProfile != null && !isHost && runId != null && hasAttended;
    final existingReview = canWriteRunReview && currentUid != null
        ? reviews.where((r) => r.reviewerUserId == currentUid).firstOrNull
        : null;

    final avgRating = reviews.isEmpty
        ? null
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final previewReviews = reviews.take(_previewCount).toList(growable: false);

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
            message: 'Reviews from runners will appear here after a run.',
            surface: false,
            iconSize: 28,
            padding: const EdgeInsets.symmetric(vertical: Sizes.p12),
            titleStyle: CatchTextStyles.titleM(context),
            messageStyle: CatchTextStyles.bodyS(context, color: t.ink2),
          )
        else ...[
          for (var i = 0; i < previewReviews.length; i++) ...[
            ReviewCard(
              review: previewReviews[i],
              isOwn: previewReviews[i].reviewerUserId == currentUid,
              onEdit:
                  canWriteRunReview &&
                      previewReviews[i].reviewerUserId == currentUid
                  ? () => showWriteReviewSheet(
                      context: context,
                      runClubId: runClubId,
                      runId: runId,
                      reviewer: userProfile!,
                      existingReview: previewReviews[i],
                    )
                  : null,
            ),
            if (i < previewReviews.length - 1) gapH12,
          ],
          if (reviews.length > _previewCount) ...[
            gapH4,
            TextButton(
              key: ReviewKeys.seeAllReviewsButton,
              onPressed: () => _showAllReviews(context),
              child: Text('See all ${reviews.length} reviews'),
            ),
          ],
        ],

        // ── CTA ─────────────────────────────────────────────────────────────
        // Review writes are run-scoped so one user can review each run once.
        if (canWriteRunReview) ...[
          const SizedBox(height: 12),
          CatchButton(
            key: ReviewKeys.writeReviewButton,
            label: existingReview != null
                ? 'Edit your review'
                : 'Write a review',
            onPressed: () => showWriteReviewSheet(
              context: context,
              runClubId: runClubId,
              runId: runId,
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
