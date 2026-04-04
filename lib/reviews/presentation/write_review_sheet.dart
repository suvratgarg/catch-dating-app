import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a bottom sheet for creating or editing a review.
///
/// Pass [existingReview] to pre-fill and switch to edit mode.
Future<void> showWriteReviewSheet({
  required BuildContext context,
  required String runClubId,
  String? runId,
  required AppUser reviewer,
  Review? existingReview,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
  final AppUser reviewer;
  final Review? existingReview;

  @override
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _submitting = false;

  bool get _isEdit => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController =
        TextEditingController(text: widget.existingReview?.comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _submitting = true);
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      if (_isEdit) {
        await repo.updateReview(
          widget.existingReview!.copyWith(
            rating: _rating,
            comment: _commentController.text.trim(),
          ),
        );
      } else {
        await repo.addReview(Review(
          id: '',
          runClubId: widget.runClubId,
          runId: widget.runId,
          reviewerUserId: widget.reviewer.uid,
          reviewerName: widget.reviewer.name,
          rating: _rating,
          comment: _commentController.text.trim(),
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEdit ? 'Edit Review' : 'Write a Review',
            style:
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StarRatingPicker(
            rating: _rating,
            onChanged: (r) => setState(() => _rating = r),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _rating == 0 || _submitting ? null : _submit,
              child: _submitting
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
