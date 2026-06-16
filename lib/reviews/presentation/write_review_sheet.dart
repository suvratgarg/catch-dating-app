import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/confirm_danger_dialog.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
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
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WriteReviewSheet(
      clubId: clubId,
      eventId: eventId,
      reviewer: reviewer,
      existingReview: existingReview,
    ),
  );
}

class _WriteReviewSheet extends ConsumerStatefulWidget {
  const _WriteReviewSheet({
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
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
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
      // Inline ErrorBanner owns user-facing error display.
    }
  }

  Future<void> _confirmDelete() async {
    final review = widget.existingReview;
    if (review == null) return;

    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: 'Delete review?',
      message: 'This removes your review from this event.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !mounted) return;

    try {
      await WriteReviewController.deleteMutation.run(ref, (tx) async {
        await tx.get(writeReviewControllerProvider.notifier).delete(review.id);
      });
    } catch (_) {
      // Inline ErrorBanner owns user-facing error display.
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(WriteReviewController.submitMutation);
    final deleteMutation = ref.watch(WriteReviewController.deleteMutation);
    final submitting = mutation.isPending || deleteMutation.isPending;

    ref.listen(WriteReviewController.submitMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess && context.mounted) {
        Navigator.of(context).pop();
      }
    });
    ref.listen(WriteReviewController.deleteMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess && context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return CatchBottomSheetScaffold(
      title: _isEdit ? 'Edit review' : 'Write a review',
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
              label: 'Delete review',
              onPressed: submitting ? null : _confirmDelete,
              isLoading: deleteMutation.isPending,
              variant: CatchButtonVariant.danger,
              fullWidth: true,
            ),
            gapH12,
          ],
          CatchButton(
            key: ReviewKeys.submitReviewButton,
            label: _isEdit ? 'Save' : 'Submit',
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
          CatchTextField(
            key: ReviewKeys.commentField,
            label: 'Review',
            isOptional: true,
            controller: _commentController,
            maxLines: 3,
            hintText: 'Share your experience',
            textCapitalization: TextCapitalization.sentences,
          ),
          if (mutation.hasError) ...[
            gapH12,
            ErrorBanner(message: mutationErrorMessage(mutation)),
          ],
          if (deleteMutation.hasError) ...[
            gapH12,
            ErrorBanner(message: mutationErrorMessage(deleteMutation)),
          ],
        ],
      ),
    );
  }
}
