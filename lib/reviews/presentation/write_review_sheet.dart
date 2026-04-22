import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a bottom sheet for creating or editing a review.
///
/// Pass [existingReview] to pre-fill and switch to edit mode.
Future<void> showWriteReviewSheet({
  required BuildContext context,
  required String runClubId,
  String? runId,
  required UserProfile reviewer,
  Review? existingReview,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WriteReviewSheet(
      runClubId: runClubId,
      runId: runId,
      reviewer: reviewer,
      existingReview: existingReview,
    ),
  );
}

class _WriteReviewSheet extends ConsumerStatefulWidget {
  const _WriteReviewSheet({
    required this.runClubId,
    this.runId,
    required this.reviewer,
    this.existingReview,
  });

  final String runClubId;
  final String? runId;
  final UserProfile reviewer;
  final Review? existingReview;

  @override
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;

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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) return;
    WriteReviewController.submitMutation.run(ref, (tx) async {
      await tx
          .get(writeReviewControllerProvider.notifier)
          .submit(
            runClubId: widget.runClubId,
            runId: widget.runId,
            reviewerUserId: widget.reviewer.uid,
            reviewerName: widget.reviewer.name,
            rating: _rating,
            comment: _commentController.text.trim(),
            existingReview: widget.existingReview,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(WriteReviewController.submitMutation);

    ref.listen(WriteReviewController.submitMutation, (prev, next) {
      if (prev?.isPending == true && next.isSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Sizes.p24,
        Sizes.p24,
        Sizes.p24,
        Sizes.p24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEdit ? 'Edit review' : 'Write a review',
            style: CatchTextStyles.displaySm(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          gapH16,
          StarRatingPicker(
            rating: _rating,
            onChanged: (r) => setState(() => _rating = r),
          ),
          gapH16,
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (mutation.hasError) ...[
            gapH12,
            ErrorBanner(message: (mutation as MutationError).error.toString()),
          ],
          gapH20,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _rating == 0 || mutation.isPending ? null : _submit,
              child: mutation.isPending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Save' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
