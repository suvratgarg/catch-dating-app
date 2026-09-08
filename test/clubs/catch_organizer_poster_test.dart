import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clubs_test_helpers.dart';

void main() {
  testWidgets('uses editorial title and arrow defaults', (tester) async {
    await pumpTestApp(
      tester,
      CatchOrganizerPoster(
        media: const ColoredBox(color: Colors.black),
        kicker: 'CLUB TO KNOW',
        title: 'Neighbourhood Club',
        onTap: () {},
      ),
    );

    final title = tester.widget<Text>(find.text('Neighbourhood Club'));
    expect(title.style?.fontSize, CatchDisplayStep.m.size);
    expect(title.style?.fontStyle, isNot(FontStyle.italic));
    expect(find.byIcon(CatchIcons.forwardArrow), findsOneWidget);

    await pumpTestApp(
      tester,
      const CatchOrganizerPoster(
        media: ColoredBox(color: Colors.black),
        kicker: 'CLUB TO KNOW',
        title: 'Neighbourhood Club',
        showArrow: false,
      ),
    );

    expect(find.byIcon(CatchIcons.forwardArrow), findsNothing);
  });

  testWidgets('renders every approved recipe', (tester) async {
    for (final layout in OrganizerPosterLayout.values) {
      await pumpTestApp(
        tester,
        SizedBox(
          width: 360,
          height: 480,
          child: CatchOrganizerPoster(
            media: const ColoredBox(color: Colors.black),
            kicker: 'Run club · Mumbai',
            title: 'A deliberately long organizer identity',
            tagline: 'A recurring scene with enough copy to test the layout.',
            meta: 'Every Saturday · 6:30 AM',
            layout: layout,
            treatment: OrganizerPosterTreatment
                .values[layout.index % OrganizerPosterTreatment.values.length],
            titleMaxLines: 2,
            showArrow: false,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('organizer-poster-canvas')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull, reason: layout.name);
    }
  });
}
