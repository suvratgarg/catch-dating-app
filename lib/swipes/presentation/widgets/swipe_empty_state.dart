import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:flutter/material.dart';

class SwipeEmptyState extends StatelessWidget {
  const SwipeEmptyState({super.key, this.content});

  final SwipeEmptyContent? content;

  @override
  Widget build(BuildContext context) {
    final resolvedContent = content ?? defaultSwipeEmptyContent(context.l10n);
    return Center(
      child: CatchEmptyState(
        icon: resolvedContent.icon,
        title: resolvedContent.title,
        message: resolvedContent.message,
        padding: CatchInsets.emptyStateContent,
        titleStyle: CatchTextStyles.headline(context),
      ),
    );
  }
}
