import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashed_avatar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/empty_hero_card.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty({super.key, required this.user});

  final UserProfile? user;

  static const _steps = [
    (
      '01',
      'Book a group run',
      "Pick a club near you. Pay the fee (or don't — some are free).",
    ),
    (
      '02',
      'Actually show up',
      'Run with the club. No swiping happens here. Just run.',
    ),
    (
      '03',
      'Swipe within 24 hours',
      'You get the roster of who ran. Catch anyone who caught your eye.',
    ),
    (
      '04',
      'They catch you back?',
      'Match. Message. Plan the next run together.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final firstName = user?.name.split(' ').first ?? '';
    final photoUrl = user?.photoUrls.firstOrNull;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                Sizes.p8,
                CatchSpacing.s5,
                Sizes.p10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME TO CATCH',
                          style: CatchTextStyles.labelM(context, color: t.ink3)
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                        ),
                        gapH2,
                        Text(
                          "Let's find your first run",
                          style: CatchTextStyles.displayL(context),
                        ),
                      ],
                    ),
                  ),
                  DashedAvatar(
                    size: 42,
                    imageUrl: photoUrl,
                    name: firstName,
                    tokens: t,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  Sizes.p4,
                  CatchSpacing.s5,
                  Sizes.p24,
                ),
                children: [
                  EmptyHeroCard(tokens: t),
                  gapH20,
                  Text(
                    'How Catch works',
                    style: CatchTextStyles.titleL(context),
                  ),
                  gapH10,
                  ...List.generate(_steps.length, (i) {
                    final s = _steps[i];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.p14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.$1,
                                style: CatchTextStyles.mono(
                                  context,
                                  color: t.primary,
                                ),
                              ),
                              gapW14,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.$2,
                                      style: CatchTextStyles.titleM(context),
                                    ),
                                    gapH3,
                                    Text(
                                      s.$3,
                                      style: CatchTextStyles.bodyS(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i < _steps.length - 1)
                          Divider(color: t.line, height: 1),
                      ],
                    );
                  }),
                  if (user != null) ...[gapH20, ActivitySection(uid: user!.uid, showEmptyState: false)],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
