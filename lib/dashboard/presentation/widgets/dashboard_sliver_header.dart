import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

class DashboardSliverHeader extends CatchSliverHeader {
  DashboardSliverHeader({
    required String eyebrow,
    required String title,
    required Widget avatar,
    TabController? controller,
  }) : super(
         title: _DashboardHeaderContent(
           eyebrow: eyebrow,
           title: title,
           avatar: avatar,
         ),
         bottomHeight: 48,
         bottom: controller == null ? null : _DashboardTabBar(controller),
       );
}

class _DashboardTabBar extends StatelessWidget {
  const _DashboardTabBar(this.controller);

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.bg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: CatchTopBarTabBar(
          controller: controller,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeaderContent extends StatelessWidget {
  const _DashboardHeaderContent({
    required this.eyebrow,
    required this.title,
    required this.avatar,
  });

  final String eyebrow;
  final String title;
  final Widget avatar;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Material(
      color: t.bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s2,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelM(
                      context,
                      color: t.ink3,
                    ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.0),
                  ),
                  gapH2,
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.displayL(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CatchSpacing.s3),
            avatar,
          ],
        ),
      ),
    );
  }
}
