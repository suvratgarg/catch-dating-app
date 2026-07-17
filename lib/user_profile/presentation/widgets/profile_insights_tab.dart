import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/user_analytics/shared/user_analytics_panel.dart';
import 'package:flutter/material.dart';

class ProfileInsightsTabSliverBody extends StatelessWidget {
  const ProfileInsightsTabSliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: CatchInsets.formEditBodyRelaxed.copyWith(bottom: 0),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchLayout.maxContentWidth,
            ),
            child: const SizedBox(
              width: double.infinity,
              child: UserAnalyticsPanel(showSectionTitle: false),
            ),
          ),
        ),
      ),
    );
  }
}
