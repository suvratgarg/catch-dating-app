import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/shared/review_keys.dart';
import 'package:catch_dating_app/reviews/shared/star_rating.dart';
import 'package:catch_dating_app/reviews/shared/write_review_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a bottom sheet for creating or editing a review.
///
/// Pass [existingReview] to pre-fill and switch to edit mode.
Future<void> showWriteReviewSheet({
  required BuildContext context,
  required String clubId,
  required String eventId,
  required UserProfile reviewer,
  Review? existingReview,
}) {
  return showCatchBottomSheet(
    context: context,
    builder: (_) => WriteReviewSheet(
      clubId: clubId,
      eventId: eventId,
      reviewer: reviewer,
      existingReview: existingReview,
    ),
  );
}

class WriteReviewSheet extends ConsumerStatefulWidget {
  const WriteReviewSheet({
    super.key,
    required this.clubId,
    required this.eventId,
    required this.reviewer,
    this.existingReview,
  });

  final String clubId;
  final String eventId;
  final UserProfile reviewer;
  final Review? existingReview;

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _didResetMutations = false;

  bool get _isEdit => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didResetMutations) return;
    _didResetMutations = true;
    WriteReviewController.submitMutation.reset(ref);
    WriteReviewController.deleteMutation.reset(ref);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    try {
      await WriteReviewController.submitMutation.run(ref, (tx) async {
        await tx
            .get(writeReviewControllerProvider.notifier)
            .submit(
              clubId: widget.clubId,
              eventId: widget.eventId,
              reviewerUserId: widget.reviewer.uid,
              reviewerName: widget.reviewer.name,
              rating: _rating,
              comment: _commentController.text.trim(),
              existingReview: widget.existingReview,
            );
      });
    } catch (_) {
      // Inline CatchErrorBanner owns user-facing error display.
    }
  }

  Future<void> _confirmDelete() async {
    final review = widget.existingReview;
    if (review == null) return;

    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: context.l10n.reviewsWriteReviewSheetTitleDeleteReview,
      message: context.l10n.reviewsWriteReviewSheetMessageThisRemovesYourReview,
      confirmLabel: context.l10n.sharedActionDelete,
    );
    if (confirmed != true || !mounted) return;

    try {
      await WriteReviewController.deleteMutation.run(ref, (tx) async {
        await tx.get(writeReviewControllerProvider.notifier).delete(review.id);
      });
    } catch (_) {
      // Inline CatchErrorBanner owns user-facing error display.
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(WriteReviewController.submitMutation);
    final deleteMutation = ref.watch(WriteReviewController.deleteMutation);
    final submitting = mutation.isPending || deleteMutation.isPending;

    ref.listen(WriteReviewController.submitMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        Navigator.of(context).pop();
      }
    });
    ref.listen(WriteReviewController.deleteMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return CatchBottomSheetScaffold(
      title: _isEdit
          ? context.l10n.reviewsWriteReviewSheetTitleEditReview
          : context.l10n.reviewsWriteReviewSheetTitleWriteAReview,
      keyboardSafe: true,
      padding: EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s4 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEdit) ...[
            CatchButton(
              key: ReviewKeys.deleteReviewButton,
              label: context.l10n.reviewsWriteReviewSheetLabelDeleteReview,
              onPressed: submitting ? null : _confirmDelete,
              isLoading: deleteMutation.isPending,
              variant: CatchButtonVariant.danger,
              fullWidth: true,
            ),
            gapH12,
          ],
          CatchButton(
            key: ReviewKeys.submitReviewButton,
            label: _isEdit
                ? context.l10n.reviewsWriteReviewSheetLabelSave
                : context.l10n.reviewsWriteReviewSheetLabelSubmit,
            onPressed: _rating == 0 || submitting ? null : _submit,
            isLoading: mutation.isPending,
            fullWidth: true,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StarRatingPicker(
            rating: _rating,
            onChanged: (r) => setState(() => _rating = r),
            keyBuilder: ReviewKeys.ratingStar,
          ),
          gapH16,
          CatchField.input(
            key: ReviewKeys.commentField,
            title: context.l10n.reviewsWriteReviewSheetTitleReview,
            isOptional: true,
            controller: _commentController,
            maxLines: 3,
            placeholder: context
                .l10n
                .reviewsWriteReviewSheetPlaceholderShareYourExperience,
            textCapitalization: TextCapitalization.sentences,
            // Mirror the backend review-comment maxLength so the user can't type
            // past the limit and hit a server rejection on submit.
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
          ),
          if (mutation.hasError) ...[
            gapH12,
            CatchErrorBanner(
              message: mutationErrorMessage(mutation, l10n: context.l10n),
            ),
          ],
          if (deleteMutation.hasError) ...[
            gapH12,
            CatchErrorBanner(
              message: mutationErrorMessage(deleteMutation, l10n: context.l10n),
            ),
          ],
        ],
      ),
    );
  }
}
