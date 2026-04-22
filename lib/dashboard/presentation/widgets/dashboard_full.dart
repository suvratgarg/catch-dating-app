import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/catches_callout.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/next_run_hero.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardFull extends StatelessWidget {
  const DashboardFull({super.key, required this.user});

  final UserProfile? user;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  static String dayCity(String? cityLabel) {
    final day = DateFormat('EEEE').format(DateTime.now());
    return '$day · ${cityLabel ?? 'Mumbai'}';
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final firstName = user?.name.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.screenH,
                Sizes.p8,
                CatchSpacing.screenH,
                Sizes.p10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayCity(user?.city?.label).toUpperCase(),
                          style: CatchTextStyles.labelSm(context, color: t.ink3)
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                        ),
                        gapH2,
                        Text(
                          '${greeting()}, $firstName',
                          style: CatchTextStyles.displayLg(context),
                        ),
                      ],
                    ),
                  ),
                  PersonAvatar(
                    size: 42,
                    name: user?.name ?? '',
                    imageUrl: user?.photoUrls.firstOrNull,
                    borderWidth: 2,
                    borderColor: t.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.screenH,
                  Sizes.p4,
                  CatchSpacing.screenH,
                  Sizes.p24,
                ),
                children: [
                  NextRunHero(tokens: t, uid: user?.uid ?? ''),
                  gapH18,
                  CatchesCallout(tokens: t, uid: user?.uid ?? ''),
                  gapH14,
                  QuickActions(tokens: t),
                  gapH18,
                  StrideCard(tokens: t, uid: user?.uid ?? ''),
                  gapH20,
                  Recommendations(tokens: t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
