import 'package:flutter/widgets.dart';

abstract final class ReviewKeys {
  static const writeReviewButton = ValueKey('reviews.write.button');
  static const submitReviewButton = ValueKey('reviews.sheet.submit');
  static const deleteReviewButton = ValueKey('reviews.sheet.delete');
  static const commentField = ValueKey('reviews.sheet.comment');
  static const seeAllReviewsButton = ValueKey('reviews.seeAll.button');

  static Key editReviewButton(String reviewId) =>
      ValueKey('reviews.edit.$reviewId');

  static Key ratingStar(int rating) => ValueKey('reviews.rating.$rating');
}
