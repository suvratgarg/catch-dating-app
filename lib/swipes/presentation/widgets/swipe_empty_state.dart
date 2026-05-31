import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:flutter/material.dart';

class SwipeEmptyState extends StatelessWidget {
  SwipeEmptyState({super.key, SwipeEmptyContent? content})
    : content = content ?? defaultSwipeEmptyContent;

  final SwipeEmptyContent content;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: content.icon,
        title: content.title,
        message: content.message,
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
        padding: const EdgeInsets.all(CatchSpacing.s8),
        titleStyle: CatchTextStyles.headline(context),
      ),
    );
  }
}
