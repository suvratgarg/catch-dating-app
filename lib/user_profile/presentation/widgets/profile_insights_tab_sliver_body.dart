import 'package:catch_dating_app/user_analytics/shared/user_analytics_section.dart';
import 'package:flutter/material.dart';

class ProfileInsightsTabSliverBody extends StatelessWidget {
  const ProfileInsightsTabSliverBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(
        width: double.infinity,
        child: UserAnalyticsSection(showSectionTitle: false),
      ),
    );
  }
}
