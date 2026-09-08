import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'passive badge recipes retain geometry at scale $scale',
      (tester) async {
        await matchCatchGolden(
          tester,
          'badge_recipe_family@$scale',
          textScale: scale,
          size: const Size(440, 1700),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 24,
              children: [
                for (final (label, child) in <(String, Widget)>[
                  ('metadata', const CatchBadge(label: 'Live music')),
                  (
                    'functional',
                    const CatchBadge.functional(label: 'Confirmed'),
                  ),
                  ('solid', const CatchBadge.solid(label: 'Members')),
                  (
                    'solid status',
                    const CatchBadge.solidStatus(label: 'Sold out'),
                  ),
                  ('live', const CatchBadge.live(label: 'Live')),
                  ('on dark', const CatchBadge.onDark(label: 'Tonight')),
                  (
                    'dark status',
                    const CatchBadge.onDarkStatus(label: 'Booked'),
                  ),
                  (
                    'privacy',
                    const CatchBadge.privacy(
                      label: 'Private',
                      icon: Icons.lock_outline,
                    ),
                  ),
                  (
                    'status',
                    const CatchBadge.status(
                      label: 'Needs attention',
                      tone: CatchBadgeTone.warning,
                    ),
                  ),
                  (
                    'ticket soft',
                    CatchTicketStatusBadge(
                      label: 'Booked',
                      color: CatchTokens.of(context).primary,
                    ),
                  ),
                  (
                    'ticket dark',
                    CatchTicketStatusBadge(
                      label: 'Booked',
                      color: CatchTokens.of(context).primary,
                      tone: CatchTicketStatusBadgeTone.dark,
                    ),
                  ),
                  (
                    'ticket long',
                    CatchTicketStatusBadge(
                      label: 'A long ticket status for narrow spaces',
                      color: CatchTokens.of(context).danger,
                    ),
                  ),
                  (
                    'optional',
                    const CatchFormFieldOptionalBadge(label: 'Optional'),
                  ),
                  (
                    'optional error',
                    const CatchFormFieldOptionalBadge(
                      label: 'Optional',
                      hasError: true,
                    ),
                  ),
                  for (final count in [0, 1, 99, 100])
                    (
                      'unread $count',
                      CatchPersonUnreadCountPill(
                        count: count,
                        semanticsLabel: '$count unread messages',
                      ),
                    ),
                  (
                    'new match',
                    const CatchPersonNewMatchDot(semanticsLabel: 'New match'),
                  ),
                  ('count text', const CatchDaySectionHeaderCount(count: 8)),
                  (
                    'uncapped text',
                    const CatchDaySectionHeaderCount(count: 124),
                  ),
                  (
                    'quiet status',
                    const CatchInlineStatus(
                      label: 'Up to date',
                      tone: CatchInlineStatusTone.success,
                    ),
                  ),
                ])
                  SizedBox(
                    width: 192,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 8),
                        child,
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      tags: const ['golden'],
    );
  }
}
