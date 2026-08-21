part of 'catch_primitives_test.dart';

void _registerCatchPrimitivesCompositionTests() {
  testWidgets('CatchCodeInput renders handoff cells and active caret', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchCodeInput(length: 4, value: '12', active: 3, height: 72),
      ),
    );

    final tokens = CatchTokens.of(tester.element(find.byType(CatchCodeInput)));
    final activeCellFinder = find.byKey(const ValueKey('code_digit_3'));
    final activeContainerFinder = find.descendant(
      of: activeCellFinder,
      matching: find.byType(AnimatedContainer),
    );
    final activeCell = tester.widget<AnimatedContainer>(activeContainerFinder);
    final decoration = activeCell.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(find.byType(CatchCodeInputRow), findsOneWidget);
    expect(find.byType(CatchCodeInputCell), findsNWidgets(4));
    expect(find.byType(CatchCodeInputCaret), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('code_digit_3'))).height,
      72,
    );
    expect(decoration.color, tokens.surface);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(CatchRadius.interactiveTile),
    );
    expect(border.top.color, tokens.ink);
    expect(border.top.width, 1.5);
    expect(
      find.descendant(
        of: find.byType(CatchCodeInput),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == CatchLayout.otpDigitGap,
        ),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('code_digit_3')),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == CatchLayout.otpCaretWidth &&
              widget.height == CatchLayout.otpCaretHeight,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('CatchRangeSlider hides tick marks while preserving divisions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchRangeSlider(
          values: const RangeValues(18, 60),
          min: 18,
          max: 60,
          divisions: 42,
          minLabel: '18',
          maxLabel: '60+',
          onChanged: (_) {},
        ),
      ),
    );

    final theme = tester.widget<SliderTheme>(
      find.ancestor(
        of: find.byType(RangeSlider),
        matching: find.byType(SliderTheme),
      ),
    );
    final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));

    expect(theme.data.inactiveTickMarkColor, Colors.transparent);
    expect(slider.divisions, 42);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('60+'), findsOneWidget);
  });

  testWidgets('CatchNumberStepper formats and clamps numeric changes', (
    tester,
  ) async {
    num value = 170;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchNumberStepper(
            value: value,
            min: 169,
            max: 171,
            decreaseTooltip: 'Decrease height',
            increaseTooltip: 'Increase height',
            formatValue: (next) => '${next.round()} cm',
            onChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    expect(find.text('170 cm'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase height'));
    await tester.pump();
    expect(find.text('171 cm'), findsOneWidget);

    final disabledIncrease = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, CatchIcons.addRounded),
    );
    expect(disabledIncrease.onPressed, isNull);

    await tester.tap(find.byTooltip('Decrease height'));
    await tester.pump();
    expect(find.text('170 cm'), findsOneWidget);
  });

  testWidgets('standalone controls share the md minimum height contract', (
    tester,
  ) async {
    CityOption? selected;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchField.select<CityOption>(
                key: const Key('control-select-menu'),
                title: 'City',
                values: defaultCityOptions,
                value: selected,
                itemLabel: (city) => city.label,
                hintText: 'Select city',
                showLabel: false,
                onChanged: (value) => selected = value,
              ),
              const SizedBox(height: 12),
              CatchNumberStepper(
                key: const Key('control-number-stepper'),
                value: 60,
                min: 30,
                max: 120,
                formatValue: (value) => '${value.round()} min',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    const expectedHeight = CatchControlMetrics.mdMinHeight;
    expect(
      tester.getSize(find.byKey(const Key('control-select-menu'))).height,
      expectedHeight,
    );
    expect(
      tester.getSize(find.byKey(const Key('control-number-stepper'))).height,
      expectedHeight,
    );
  });

  testWidgets('CatchChip.removable uses one whole-chip removal action', (
    tester,
  ) async {
    var removals = 0;

    await tester.pumpWidget(
      _wrap(CatchChip.removable(label: 'Easy', onRemove: () => removals += 1)),
    );

    final chipFinder = find.byType(CatchChip);
    final tokens = CatchTokens.of(tester.element(chipFinder));
    final decoration =
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: chipFinder,
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration
            as BoxDecoration;

    expect(decoration.color, tokens.surface);
    expect(decoration.border?.top.color, tokens.line2);
    expect(decoration.border?.top.width, CatchStroke.hairline);
    expect(find.byIcon(CatchIcons.closeRounded), findsOneWidget);

    await tester.tap(find.text('Easy'));
    await tester.pump();
    expect(removals, 1);

    await tester.tap(find.byIcon(CatchIcons.closeRounded));
    await tester.pump();
    expect(removals, 2);
  });

  testWidgets('CatchFormFieldLabel renders optional badge leaf', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchFormFieldLabel(label: 'Instagram', isOptional: true)),
    );

    expect(find.text('Instagram'), findsOneWidget);
    expect(find.byType(CatchFormFieldOptionalBadge), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
  });

  testWidgets('CatchOptionGroup composes public option items', (tester) async {
    var selected = 'all';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchOptionGroup<String>(
            selected: selected,
            onChanged: (value) => setState(() => selected = value),
            options: const [
              CatchOption(value: 'all', label: 'All'),
              CatchOption(value: 'saved', label: 'Saved'),
              CatchOption(value: 'nearby', label: 'Nearby'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CatchOptionGroupItem<String>), findsNWidgets(3));
    await tester.tap(find.text('Saved'));
    await tester.pump();
    expect(selected, 'saved');
  });

  testWidgets('CatchOptionGroup keeps option labels on a stable axis', (
    tester,
  ) async {
    var selected = 'first';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchOptionGroup<String>(
            selected: selected,
            onChanged: (value) => setState(() => selected = value),
            options: const [
              CatchOption(value: 'first', label: 'First'),
              CatchOption(value: 'second', label: 'Second'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('First')).dy,
      closeTo(tester.getTopLeft(find.text('Second')).dy, 0.1),
    );

    await tester.tap(find.text('Second'));
    await tester.pump(CatchMotion.fast);

    expect(
      tester.getTopLeft(find.text('First')).dy,
      closeTo(tester.getTopLeft(find.text('Second')).dy, 0.1),
    );
  });

  testWidgets('CatchTabRail aligns trailing actions with option labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchTabRail<String>(
          selected: 'all',
          options: const [
            CatchOption(value: 'all', label: 'All'),
            CatchOption(value: 'saved', label: 'Saved'),
          ],
          trailing: SizedBox.square(
            dimension: CatchLayout.iconButtonNavSize,
            child: Icon(CatchIcons.tuneRounded),
          ),
        ),
      ),
    );
    await tester.pump();

    final labelCenter = tester.getCenter(find.text('All'));
    final iconCenter = tester.getCenter(find.byIcon(CatchIcons.tuneRounded));

    expect((labelCenter.dy - iconCenter.dy).abs(), lessThan(8));
  });

  testWidgets('operational CatchTabRail keeps labels and actions at 2x text', (
    tester,
  ) async {
    var selected = 'now';
    final options = [
      CatchOption(value: 'now', label: 'Now', icon: CatchIcons.scheduleRounded),
      CatchOption(
        value: 'guests',
        label: 'Guests',
        icon: CatchIcons.groupsOutlined,
      ),
      CatchOption(
        value: 'room',
        label: 'Room',
        icon: CatchIcons.gridViewRounded,
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        CatchTabRail<String>(
          selected: selected,
          options: options,
          variant: CatchOptionGroupVariant.operational,
          onChanged: (value) => selected = value,
        ),
      ),
    );
    expect(find.byIcon(CatchIcons.gridViewRounded), findsOneWidget);
    await tester.tap(find.text('Room'));
    expect(selected, 'room');

    await tester.pumpWidget(
      _wrap(
        CatchTabRail<String>(
          selected: selected,
          options: options,
          variant: CatchOptionGroupVariant.operational,
          onChanged: (value) => selected = value,
        ),
        textScale: 2,
      ),
    );
    await tester.pump();
    expect(find.text('Now'), findsOneWidget);
    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('Room'), findsOneWidget);
    expect(find.byIcon(CatchIcons.gridViewRounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CatchOptionGroupItem renders mono uppercase label and tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        CatchOptionGroupItem<String>(
          option: const CatchOption(value: 'mine', label: 'Mine'),
          selected: true,
          selectedRule: Colors.black,
          variant: CatchOptionGroupVariant.mono,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('MINE'), findsOneWidget);
    await tester.tap(find.text('MINE'));
    expect(tapped, isTrue);
  });

  testWidgets('CatchChipField single select keeps a selected chip selected', (
    tester,
  ) async {
    Set<CityOption> selected = {cityOptionByName('indore')!};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchChipField<CityOption>(
            label: 'City',
            values: defaultCityOptions,
            selected: selected,
            multiSelect: false,
            onChanged: (next) => setState(() => selected = next),
          ),
        ),
      ),
    );

    await tester.tap(find.text(cityLabel('indore')));
    await tester.pump();

    expect(selected, {cityOptionByName('indore')!});
  });

  testWidgets(
    'CatchChipField optional single select clears a selected chip when enabled',
    (tester) async {
      Set<CityOption> selected = {cityOptionByName('indore')!};

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchChipField<CityOption>(
              label: 'City',
              values: defaultCityOptions,
              selected: selected,
              multiSelect: false,
              isOptional: true,
              allowEmptySingleSelection: true,
              onChanged: (next) => setState(() => selected = next),
            ),
          ),
        ),
      );

      await tester.tap(find.text(cityLabel('indore')));
      await tester.pump();

      expect(selected, isEmpty);
    },
  );

  testWidgets(
    'CatchChipField single select keeps chips inactive when selected is empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          CatchChipField<CityOption>(
            label: 'City',
            values: defaultCityOptions,
            selected: const {},
            multiSelect: false,
            onChanged: (_) {},
          ),
        ),
      );

      final firstChip = find.widgetWithText(
        CatchChip,
        defaultCityOptions.first.label,
      );
      expect(_chipSelected(tester, firstChip), isFalse);
    },
  );

  testWidgets('CatchChipField multi select marks selected chips with a check', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchChipField<CityOption>(
          label: 'Cities',
          values: defaultCityOptions.take(2).toList(),
          selected: {cityOptionByName('mumbai')!},
          multiSelect: true,
          onChanged: (_) {},
        ),
      ),
    );

    final selectedChip = find.widgetWithText(CatchChip, cityLabel('mumbai'));
    final unselectedChip = find.widgetWithText(CatchChip, cityLabel('delhi'));

    expect(_chipSelected(tester, selectedChip), isTrue);
    expect(
      find.descendant(
        of: selectedChip,
        matching: find.byIcon(CatchIcons.checkRounded),
      ),
      findsOneWidget,
    );
    expect(_chipSelected(tester, unselectedChip), isFalse);
    expect(
      find.descendant(
        of: unselectedChip,
        matching: find.byIcon(CatchIcons.checkRounded),
      ),
      findsNothing,
    );
    expect(find.byIcon(CatchIcons.checkRounded), findsOneWidget);
  });

  testWidgets(
    'CatchChipField required multi select keeps the last chip selected',
    (tester) async {
      Set<CityOption> selected = {cityOptionByName('mumbai')!};

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchChipField<CityOption>(
              label: 'Cities',
              values: defaultCityOptions.take(2).toList(),
              selected: selected,
              multiSelect: true,
              onChanged: (next) => setState(() => selected = next),
            ),
          ),
        ),
      );

      await tester.tap(find.text(cityLabel('mumbai')));
      await tester.pump();

      expect(selected, {cityOptionByName('mumbai')!});
    },
  );

  testWidgets('CatchBadge renders status tones and typed typography', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Wrap(
          children: [
            const CatchBadge(label: 'pending'),
            const CatchBadge(label: 'paid', tone: CatchBadgeTone.success),
            const CatchBadge.live(label: 'live - 6h left'),
            CatchBadge(
              label: 'reward',
              tone: CatchBadgeTone.gold,
              icon: CatchIcons.rated,
            ),
            CatchBadge(
              label: 'checked in',
              size: CatchBadgeSize.action,
              accentColor: Colors.deepPurple,
              icon: CatchIcons.checkRounded,
            ),
          ],
        ),
      ),
    );

    expect(find.text('pending'), findsOneWidget);
    expect(find.text('paid'), findsOneWidget);
    expect(find.text('LIVE - 6H LEFT'), findsOneWidget);
    expect(find.text('reward'), findsOneWidget);
    expect(find.text('checked in'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(CatchBadge, 'checked in')).height,
      33,
    );
    expect(find.byIcon(CatchIcons.checkRounded), findsOneWidget);
  });

  testWidgets('CatchChip.activity renders soft and solid activity registers', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        Wrap(
          children: [
            const CatchChip.activity(activityKind: ActivityKind.socialRun),
            CatchChip.activity(
              activityKind: ActivityKind.pickleball,
              emphasis: CatchChipEmphasis.solid,
              label: 'Primary court',
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Social run'), findsOneWidget);
    expect(find.text('Primary court'), findsOneWidget);

    await tester.tap(find.text('Primary court'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets(
    'CatchPersonAvatar renders activity-context initials and dim states',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Wrap(
            children: [
              CatchPersonAvatar(
                size: 48,
                name: 'Social run',
                activityKind: ActivityKind.socialRun,
                initials: 'SR',
                borderWidth: 2,
              ),
              CatchPersonAvatar(
                size: 44,
                name: 'Pickleball',
                activityKind: ActivityKind.pickleball,
                initials: 'PB',
                activityDim: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('SR'), findsOneWidget);
      expect(find.text('PB'), findsOneWidget);
      expect(find.byType(CatchPersonAvatarShell), findsNWidgets(2));
      expect(find.byType(CatchActivityInitialsPlaceholder), findsNWidgets(2));
      expect(CatchPersonAvatar.initialsOf('Social run'), 'SR');
    },
  );

  testWidgets(
    'CatchPersonAvatar composes obscured initials fallback renderers',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CatchPersonAvatar(
            size: 48,
            name: 'Private guest',
            obscured: true,
          ),
        ),
      );

      expect(find.text('PG'), findsOneWidget);
      expect(find.byType(CatchPersonAvatarShell), findsOneWidget);
      expect(find.byType(CatchObscuredAvatarContent), findsOneWidget);
      expect(find.byType(CatchInitialsAvatarPlaceholder), findsOneWidget);
    },
  );

  testWidgets(
    'CatchPersonAvatar keeps activity fallback when a supplied logo fails',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CatchPersonAvatar(
            size: 48,
            name: 'Sea Face Social',
            imageUrl: 'assets/fixtures/does-not-exist.png',
            activityKind: ActivityKind.socialRun,
            initials: 'SF',
          ),
        ),
      );
      await pumpFeatureUi(tester);

      expect(find.byType(CatchActivityInitialsPlaceholder), findsOneWidget);
      expect(find.byType(CatchInitialsAvatarPlaceholder), findsNothing);
      expect(find.text('SF'), findsOneWidget);
    },
  );

  testWidgets('CatchPersonAvatarStack renders initials, veils, and overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchPersonAvatarStack(
          items: [CatchPersonAvatarItem(name: 'Asha Shah')],
          totalCount: 4,
          size: 42,
          limit: 3,
          veiledCount: 2,
          activityKind: ActivityKind.yoga,
        ),
      ),
    );

    expect(find.text('AS'), findsOneWidget);
    expect(find.byIcon(CatchIcons.personOutlined), findsNWidgets(2));
    expect(find.byType(CatchVeiledPersonAvatar), findsNWidgets(2));
    expect(find.byType(CatchInitialsAvatarPlaceholder), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets(
    'CatchActivityMapPin renders selected flag and activity pigment pin',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const CatchActivityMapPin(
            activityKind: ActivityKind.socialRun,
            selected: true,
            label: 'SOCIAL RUN · 6:30 AM',
          ),
        ),
      );

      expect(find.text('SOCIAL RUN · 6:30 AM'), findsOneWidget);
      expect(find.byIcon(CatchIcons.pin), findsOneWidget);
    },
  );

  testWidgets('CatchDistanceRing renders tappable map radius label', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(CatchDistanceRing(label: 'WITHIN 3 KM', onTap: () => taps++)),
    );

    expect(find.text('WITHIN 3 KM'), findsOneWidget);

    await tester.tap(find.text('WITHIN 3 KM'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('CatchDistanceRingLabel is reusable over native maps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        CatchDistanceRingLabel(
          label: 'Within 5 km · tap to change',
          onTap: () => taps += 1,
        ),
      ),
    );

    expect(find.text('WITHIN 5 KM · TAP TO CHANGE'), findsOneWidget);
    await tester.tap(find.text('WITHIN 5 KM · TAP TO CHANGE'));
    expect(taps, 1);
  });

  testWidgets(
    'CatchActivityArt renders generated activity backdrop with child',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 220,
            child: CatchActivityArt(
              activityKind: ActivityKind.yoga,
              dim: true,
              child: Center(child: Text('Ticket meta')),
            ),
          ),
        ),
      );

      expect(find.text('Ticket meta'), findsOneWidget);
    },
  );

  testWidgets('CatchNetworkImage composes branded fallback renderer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox.square(
          dimension: 48,
          child: CatchNetworkImage('assets/branding/not-found.png'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CatchNetworkImageFallback), findsOneWidget);
    expect(find.byIcon(CatchIcons.imageOutlined), findsOneWidget);
  });
}
