import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_photo_header.dart';
import 'package:flutter/material.dart';

class RunDetailHeroAppBar extends StatelessWidget {
  const RunDetailHeroAppBar({
    super.key,
    required this.run,
    required this.isSaved,
    required this.savePending,
    required this.onBack,
    required this.onShare,
    required this.onToggleSaved,
  });

  final Run run;
  final bool isSaved;
  final bool savePending;
  final VoidCallback onBack;
  final ValueChanged<BuildContext> onShare;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: t.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CatchTopBarIconAction(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          background: t.surface,
          onPressed: onBack,
          foregroundColor: t.ink,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (buttonContext) => CatchTopBarIconAction(
              icon: Icons.ios_share_rounded,
              tooltip: 'Share run',
              background: t.surface,
              onPressed: () => onShare(buttonContext),
              foregroundColor: t.ink,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
          child: CatchTopBarIconAction(
            icon: isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            tooltip: isSaved ? 'Unsave run' : 'Save run',
            background: t.surface,
            onPressed: savePending ? null : onToggleSaved,
            foregroundColor: t.ink,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: RunPhotoHeader(run: run),
      ),
    );
  }
}
