import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

/// Renders a reviews list with a header summary and a write/edit button.
///
/// Works for both club and run contexts:
/// - Club: pass [runClubId] only; set [isMember] and [isHost] appropriately.
/// - Run: pass both [runClubId] and [runId]; set [hasAttended] appropriately.
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

  /// True when the current user is a club member — gates club-level reviews.
  final bool isMember;

  /// True when the current user attended the run — gates run-level reviews.
  final bool hasAttended;

  static const _previewCount = 5;

  void _showAllReviews(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text(
              'All reviews (${reviews.length})',
              style: CatchTextStyles.displaySm(context),
            ),
            const SizedBox(height: 16),
            ...reviews.map(
              (r) =>
                  ReviewCard(review: r, isOwn: r.reviewerUserId == currentUid),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final existingReview = currentUid != null
        ? reviews.where((r) => r.reviewerUserId == currentUid).firstOrNull
        : null;

    final avgRating = reviews.isEmpty
        ? null
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text('Reviews', style: CatchTextStyles.displaySm(context)),
            ),
            if (avgRating != null) ...[
              StarRating(rating: avgRating.round(), size: 14),
              const SizedBox(width: 4),
              Text(
                '${avgRating.toStringAsFixed(1)} · ${reviews.length}',
                style: CatchTextStyles.bodySm(context, color: t.ink2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // ── Review list ──────────────────────────────────────────────────────
        if (reviews.isEmpty)
          Text(
            'No reviews yet — be the first!',
            style: CatchTextStyles.bodySm(context, color: t.ink2),
          )
        else ...[
          ...reviews
              .take(_previewCount)
              .map(
                (r) => ReviewCard(
                  review: r,
                  isOwn: r.reviewerUserId == currentUid,
                  onEdit: userProfile != null
                      ? () => showWriteReviewSheet(
                          context: context,
                          runClubId: runClubId,
                          runId: runId,
                          reviewer: userProfile!,
                          existingReview: r,
                        )
                      : null,
                ),
              ),
          if (reviews.length > _previewCount) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showAllReviews(context),
              child: Text(
                'See all ${reviews.length} reviews',
                style: CatchTextStyles.labelMd(context, color: t.primary),
              ),
            ),
          ],
        ],

        // ── CTA ─────────────────────────────────────────────────────────────
        // Show the write-review button only when the user is allowed to review:
        // - For run reviews: the user must have attended the run.
        // - For club reviews: the user must be a member (not the host).
        if (userProfile != null &&
            !isHost &&
            (runId != null ? hasAttended : isMember)) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => showWriteReviewSheet(
                context: context,
                runClubId: runClubId,
                runId: runId,
                reviewer: userProfile!,
                existingReview: existingReview,
              ),
              child: Text(
                existingReview != null ? 'Edit your review' : 'Write a review',
              ),
            ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                      style: CatchTextStyles.labelMd(context),
                    ),
                    StarRating(rating: review.rating, size: 12),
                  ],
                ),
              ),
              if (isOwn && onEdit != null)
                IconBtn(
                  onTap: onEdit!,
                  child: Icon(Icons.edit_outlined, size: 16, color: t.primary),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
            ),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: t.line),
        ],
      ),
    );
  }
}
