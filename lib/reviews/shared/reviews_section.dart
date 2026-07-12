import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/shared/review_keys.dart';
import 'package:catch_dating_app/reviews/shared/star_rating.dart';
import 'package:catch_dating_app/reviews/shared/write_review_controller.dart';
import 'package:catch_dating_app/reviews/shared/write_review_sheet.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      compactEmptyState: true,
      showHeader: false,
      emptyMessage: 'Reviews appear after members attend an event.',
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
          showAllAction: reviews.length > 3,
          compactEmptyState: true,
          showHeader: false,
          emptyMessage: 'Reviews appear after attendees complete the event.',
          onEditReview: canWriteEventReview
              ? (review) => showWriteReviewSheet(
                  context: context,
                  clubId: clubId,
                  eventId: eventId,
                  reviewer: userProfile!,
                  existingReview: review,
                )
              : null,
          onRespondToReview: isHost
              ? (review) =>
                    showReviewResponseSheet(context: context, review: review)
              : null,
        ),

        // Review writes are event-scoped so one user can review each event once.
        if (canWriteEventReview) ...[
          gapH12,
          CatchButton(
            key: ReviewKeys.writeReviewButton,
            label: existingReview != null
                ? context.l10n.reviewsReviewsSectionLabelEditYourReview
                : context.l10n.reviewsReviewsSectionLabelWriteAReview,
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
    this.compactEmptyState = false,
    this.showHeader = true,
    this.emptyMessage,
    this.onEditReview,
    this.onRespondToReview,
  });

  final List<Review> reviews;
  final String? currentUid;
  final int maxVisibleReviews;
  final bool showAllAction;
  final bool compactEmptyState;
  final bool showHeader;
  final String? emptyMessage;
  final ValueChanged<Review>? onEditReview;
  final ValueChanged<Review>? onRespondToReview;

  void _showAllReviews(BuildContext context) {
    showCatchBottomSheet<void>(
      context: context,
      builder: (sheetContext) => CatchBottomSheetScaffold(
        title: context.l10n.reviewsReviewsSectionTitleAllReviewsLength(
          length: reviews.length,
        ),
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
                onRespond: onRespondToReview == null
                    ? null
                    : () => onRespondToReview!(review),
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
        if (showHeader) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.reviewsReviewsSectionTextReviews,
                  style: CatchTextStyles.titleL(context),
                ),
              ),
              if (avgRating != null) ...[
                StarRating(rating: avgRating.round(), size: CatchIcon.rating),
                gapW4,
                Text(
                  context.l10n.reviewsReviewsSectionTextTostringasfixedLength(
                    toStringAsFixed: avgRating.toStringAsFixed(1),
                    length: reviews.length,
                  ),
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ],
          ),
          gapH12,
        ],

        if (reviews.isEmpty)
          CatchEmptyState(
            icon: CatchIcons.rateReviewOutlined,
            title: context.l10n.reviewsReviewsSectionTitleNoReviewsYet,
            message:
                emptyMessage ??
                (compactEmptyState
                    ? context
                          .l10n
                          .reviewsReviewsSectionMessageReviewsAppearAfterMembers
                    : context
                          .l10n
                          .reviewsReviewsSectionMessageReviewsFromAttendeesWill),
            surface: compactEmptyState,
            layout: compactEmptyState
                ? CatchEmptyStateLayout.inline
                : CatchEmptyStateLayout.stacked,
            iconSize: compactEmptyState ? CatchIcon.row : CatchIcon.tile,
            iconContainerSize: compactEmptyState ? 44 : null,
            padding: compactEmptyState
                ? CatchInsets.content
                : CatchInsets.contentVertical,
            titleStyle: compactEmptyState
                ? CatchTextStyles.sectionTitle(context)
                : CatchTextStyles.sectionTitle(context),
            messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
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
              onRespond: onRespondToReview == null
                  ? null
                  : () => onRespondToReview!(previewReviews[i]),
            ),
            if (i < previewReviews.length - 1) gapH12,
          ],
          if (showAllAction && reviews.length > maxVisibleReviews) ...[
            gapH4,
            CatchTextButton(
              key: ReviewKeys.seeAllReviewsButton,
              label: context.l10n.reviewsReviewsSectionLabelSeeAllLengthReviews(
                length: reviews.length,
              ),
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
    this.onRespond,
  });

  final Review review;
  final bool isOwn;
  final VoidCallback? onEdit;
  final VoidCallback? onRespond;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CatchPersonAvatar(name: review.reviewerName, size: 32),
              gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwn
                          ? context.l10n.reviewsReviewsSectionTextYou
                          : review.reviewerName,
                      style: CatchTextStyles.labelL(context),
                    ),
                    StarRating(rating: review.rating, size: CatchIcon.rating),
                  ],
                ),
              ),
              if (isOwn && onEdit != null)
                Tooltip(
                  message: context.l10n.reviewsReviewsSectionMessageEditReview,
                  child: CatchIconButton(
                    key: ReviewKeys.editReviewButton(review.id),
                    onTap: onEdit!,
                    child: Icon(
                      CatchIcons.editOutlined,
                      size: CatchIcon.xs,
                      color: t.primary,
                    ),
                  ),
                ),
              if (onRespond != null)
                Tooltip(
                  message: review.ownerResponse == null
                      ? context.l10n.reviewsReviewsSectionMessageRespondAsHost
                      : context
                            .l10n
                            .reviewsReviewsSectionMessageEditHostResponse,
                  child: CatchIconButton(
                    key: ReviewKeys.respondToReviewButton(review.id),
                    onTap: onRespond!,
                    child: Icon(
                      CatchIcons.rateReviewOutlined,
                      size: CatchIcon.xs,
                      color: t.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            gapH6,
            Text(
              review.comment,
              style: CatchTextStyles.bodyLead(context, color: t.ink2),
            ),
          ],
          if (review.ownerResponse case final response?) ...[
            gapH12,
            ReviewOwnerResponseBlock(response: response),
          ],
        ],
      ),
    );
  }
}

class ReviewOwnerResponseBlock extends StatelessWidget {
  const ReviewOwnerResponseBlock({super.key, required this.response});

  final ReviewOwnerResponse response;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: double.infinity,
      padding: CatchInsets.contentDense,
      radius: CatchRadius.sm,
      backgroundColor: t.accent.withValues(
        alpha: CatchOpacity.activityIconFill,
      ),
      borderColor: t.accent.withValues(alpha: CatchOpacity.activityIconBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CatchPersonAvatar(
                name: response.hostName,
                imageUrl: response.hostAvatarUrl,
                size: 24,
              ),
              gapW8,
              Expanded(
                child: Text(
                  context.l10n.reviewsReviewsSectionTextHostResponseHostname(
                    hostName: response.hostName,
                  ),
                  style: CatchTextStyles.labelS(context, color: t.ink),
                ),
              ),
            ],
          ),
          gapH6,
          Text(
            response.message,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

Future<void> showReviewResponseSheet({
  required BuildContext context,
  required Review review,
}) {
  return showCatchBottomSheet<void>(
    context: context,
    builder: (_) => ReviewResponseSheet(review: review),
  );
}

class ReviewResponseSheet extends ConsumerStatefulWidget {
  const ReviewResponseSheet({super.key, required this.review});

  final Review review;

  @override
  ConsumerState<ReviewResponseSheet> createState() =>
      _ReviewResponseSheetState();
}

class _ReviewResponseSheetState extends ConsumerState<ReviewResponseSheet> {
  late final TextEditingController _messageController;
  bool _didResetMutation = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: widget.review.ownerResponse?.message ?? '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResetMutation) return;
    _didResetMutation = true;
    WriteReviewController.responseMutation.reset(ref);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    try {
      await WriteReviewController.responseMutation.run(ref, (tx) async {
        await tx
            .get(writeReviewControllerProvider.notifier)
            .setOwnerResponse(reviewId: widget.review.id, message: message);
      });
    } catch (_) {
      // Inline CatchErrorBanner owns user-facing error display.
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(WriteReviewController.responseMutation);
    final canSubmit = _messageController.text.trim().isNotEmpty;

    ref.listen(WriteReviewController.responseMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return CatchBottomSheetScaffold(
      title: widget.review.ownerResponse == null
          ? context.l10n.reviewsReviewsSectionTitleRespondToReview
          : context.l10n.reviewsReviewsSectionTitleEditResponse,
      keyboardSafe: true,
      action: CatchButton(
        key: ReviewKeys.submitOwnerResponseButton,
        label: context.l10n.reviewsReviewsSectionLabelSaveResponse,
        onPressed: !canSubmit || mutation.isPending ? null : _submit,
        isLoading: mutation.isPending,
        fullWidth: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchField.input(
            key: ReviewKeys.ownerResponseField,
            title: context.l10n.reviewsReviewsSectionTitleResponse,
            controller: _messageController,
            maxLines: 4,
            placeholder:
                context.l10n.reviewsReviewsSectionPlaceholderThankTheAttendeeOr,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
            onChanged: (_) => setState(() {}),
          ),
          if (mutation.hasError) ...[
            gapH12,
            CatchErrorBanner(
              message: mutationErrorMessage(mutation, l10n: context.l10n),
            ),
          ],
        ],
      ),
    );
  }
}
