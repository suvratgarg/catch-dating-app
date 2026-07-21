import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_icon.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_horizontal_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_journey_steps.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_mono_label.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_scrim.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_status_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('Catch map reveal opens a veil and respects reduced motion', (
    tester,
  ) async {
    final animation = AnimationController(
      vsync: tester,
      duration: CatchMotion.slow,
      value: 0.5,
    );
    addTearDown(animation.dispose);

    Widget transition({required bool reduceMotion}) {
      return _wrap(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Builder(
            builder: (context) => CatchMapRevealTransition(
              animation: animation,
              child: const Text('Map surface'),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(transition(reduceMotion: false));
    expect(find.byKey(const ValueKey('catch_map_reveal.veil')), findsOneWidget);
    final mapRect = tester.getRect(find.text('Map surface'));
    animation.value = 0.8;
    await tester.pump();
    expect(tester.getRect(find.text('Map surface')), mapRect);

    await tester.pumpWidget(transition(reduceMotion: true));
    expect(
      find.byKey(const ValueKey('catch_map_reveal.reduced')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('catch_map_reveal.veil')), findsNothing);
  });

  testWidgets('Catch typography does not inherit underline decoration', (
    tester,
  ) async {
    late final List<TextStyle> styles;
    late final TextStyle kicker;
    late final TextStyle kickerLarge;
    late final TextStyle monoCapsLabel;
    late final TextStyle badgeCaps;

    await tester.pumpWidget(
      _wrap(
        DefaultTextStyle.merge(
          style: const TextStyle(decoration: TextDecoration.underline),
          child: Builder(
            builder: (context) {
              styles = [
                CatchTextStyles.display(context),
                CatchTextStyles.headline(context),
                CatchTextStyles.headlineS(context),
                CatchTextStyles.eventTitle(context),
                CatchTextStyles.consoleTitle(context),
                CatchTextStyles.hint(context),
                CatchTextStyles.titleL(context),
                CatchTextStyles.name(context),
                CatchTextStyles.bodyL(context),
                CatchTextStyles.bodyS(context),
                CatchTextStyles.labelL(context),
                CatchTextStyles.monoLabel(context),
                CatchTextStyles.monoLabelS(context),
                CatchTextStyles.mono(context),
                CatchTextStyles.badge(context),
              ];
              kicker = CatchTextStyles.kicker(context);
              kickerLarge = CatchTextStyles.kickerLg(context);
              monoCapsLabel = CatchTextStyles.monoCapsLabel(context);
              badgeCaps = CatchTextStyles.badgeCaps(context);
              return const Text('Typography sample');
            },
          ),
        ),
      ),
    );

    expect(styles.map((style) => style.decoration).toSet(), {
      TextDecoration.none,
    });
    expect(styles.map((style) => style.letterSpacing).toSet(), {0});
    expect(kicker.letterSpacing, 1.76);
    expect(kickerLarge.letterSpacing, 2.16);
    expect(monoCapsLabel.letterSpacing, 1.43);
    expect(badgeCaps.letterSpacing, 0.72);
  });

  testWidgets('CatchKicker renders uppercase mono eyebrow sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchKicker(
          label: 'Was at · Sundowner 5K',
          color: Colors.red,
          size: CatchKickerSize.lg,
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('WAS AT · SUNDOWNER 5K'));
    final context = tester.element(find.text('WAS AT · SUNDOWNER 5K'));
    expect(text.style?.color, Colors.red);
    expect(
      text.style?.fontSize,
      CatchTextStyles.kickerLg(context, color: Colors.red).fontSize,
    );
  });

  testWidgets(
    'CatchButton supports size, full width, tap, and loading states',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchButton(
                  label: 'Join event',
                  onPressed: () => taps++,
                  size: CatchButtonSize.lg,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                CatchButton(
                  label: 'Loading',
                  onPressed: () => taps++,
                  isLoading: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.widgetWithText(CatchButton, 'Join event')).height,
        56,
      );
      expect(
        tester.getSize(find.widgetWithText(CatchButton, 'Join event')).width,
        240,
      );
      expect(find.byType(CatchButtonLabel), findsOneWidget);
      expect(find.byType(CatchButtonLoadingDots), findsOneWidget);

      await tester.tap(find.text('Join event'));
      await tester.pump();
      expect(taps, 1);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CatchButton && widget.label == 'Loading',
        ),
      );
      await tester.pump();
      expect(taps, 1);
      expect(find.text('Loading'), findsNothing);
    },
  );

  testWidgets('CatchButton pairs primary activity accent with white ink', (
    tester,
  ) async {
    const accent = Color(0xFF116466);

    await tester.pumpWidget(
      _wrap(
        CatchButton(
          key: const ValueKey('accent-button'),
          label: 'Run crew',
          onPressed: () {},
          accentColor: accent,
        ),
      ),
    );

    final buttonFinder = find.byKey(const ValueKey('accent-button'));
    final buttonBox = tester.widget<DecoratedBox>(
      find.descendant(of: buttonFinder, matching: find.byType(DecoratedBox)),
    );
    final buttonLabel = tester.widget<Text>(
      find.descendant(of: buttonFinder, matching: find.text('Run crew')),
    );
    final decoration = buttonBox.decoration as BoxDecoration;

    expect(decoration.color, accent);
    expect(buttonLabel.style?.color, CatchTokens.editorialWhite);
  });

  testWidgets(
    'CatchBottomAction forwards activity accent to the primary button',
    (tester) async {
      const accent = Color(0xFF116466);

      await tester.pumpWidget(
        _wrap(
          CatchBottomAction(
            label: 'Join event',
            onPressed: () {},
            buttonAccentColor: accent,
          ),
        ),
      );

      expect(find.byType(CatchBottomAction), findsOneWidget);
      final button = tester.widget<CatchButton>(
        find.widgetWithText(CatchButton, 'Join event'),
      );
      expect(button.accentColor, accent);
    },
  );

  testWidgets('CatchBottomAction renders catch line and footnote', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomAction(
          label: 'Confirm',
          onPressed: () {},
          catchLine: 'free to join',
          footnote: 'No charge until approval.',
        ),
      ),
    );

    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('FREE TO JOIN'), findsOneWidget);
    expect(find.text('No charge until approval.'), findsOneWidget);
  });

  testWidgets('CatchIconButton renders handoff icon button variants', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchIconButton.icon(
              key: const ValueKey('bordered-icon-button'),
              icon: CatchIcons.search,
              tooltip: 'Search events',
              onTap: () => taps++,
            ),
            CatchIconButton.icon(
              key: const ValueKey('active-icon-button'),
              icon: CatchIcons.favoriteRounded,
              active: true,
              accent: CatchTokens.editorialLight.danger,
              onTap: () {},
            ),
            CatchIconButton.icon(
              key: const ValueKey('float-icon-button'),
              icon: CatchIcons.close,
              variant: CatchIconButtonVariant.float,
              onTap: () {},
            ),
            CatchIconButton.icon(
              key: const ValueKey('plain-icon-button'),
              icon: CatchIcons.more,
              variant: CatchIconButtonVariant.plain,
              borderColor: CatchTokens.editorialLight.line2,
              disabled: true,
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );

    final borderedFinder = find.byKey(const ValueKey('bordered-icon-button'));
    final floatFinder = find.byKey(const ValueKey('float-icon-button'));
    final plainFinder = find.byKey(const ValueKey('plain-icon-button'));
    final tokens = CatchTokens.of(tester.element(borderedFinder));
    final borderedBox = tester.widget<DecoratedBox>(
      find.descendant(of: borderedFinder, matching: find.byType(DecoratedBox)),
    );
    final activeIconTheme = tester.widget<IconTheme>(
      find
          .ancestor(
            of: find.byIcon(CatchIcons.favoriteRounded),
            matching: find.byType(IconTheme),
          )
          .first,
    );
    final floatBox = tester.widget<DecoratedBox>(
      find.descendant(of: floatFinder, matching: find.byType(DecoratedBox)),
    );
    final plainBox = tester.widget<DecoratedBox>(
      find.descendant(of: plainFinder, matching: find.byType(DecoratedBox)),
    );

    final borderedDecoration = borderedBox.decoration as BoxDecoration;
    final floatDecoration = floatBox.decoration as BoxDecoration;
    final plainDecoration = plainBox.decoration as BoxDecoration;

    expect(
      tester.getSize(borderedFinder),
      const Size.square(CatchLayout.iconButtonSize),
    );
    expect(borderedDecoration.color, tokens.surface);
    expect((borderedDecoration.border! as Border).top.color, tokens.line2);
    expect(activeIconTheme.data.color, CatchTokens.editorialLight.danger);
    expect(floatDecoration.color, isNot(tokens.surface));
    expect(floatDecoration.boxShadow, CatchElevation.iconButtonFloat);
    expect(plainDecoration.color, Colors.transparent);
    expect((plainDecoration.border! as Border).top.color, tokens.line2);
    expect(find.byTooltip('Search events'), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.search));
    await tester.pump();
    await tester.tap(find.byIcon(CatchIcons.more));
    await tester.pump();

    expect(taps, 1);
  });

  test(
    'compact-control constructors reject invalid count and label states',
    () {
      expect(
        () => CatchIconButton.counted(
          icon: CatchIcons.notificationsRounded,
          count: -1,
        ),
        throwsAssertionError,
      );
      expect(
        () => CatchCountPill.label(label: '   ', onPressed: () {}),
        throwsAssertionError,
      );
      expect(
        () =>
            CatchCountPill.label(label: 'Filters', count: -1, onPressed: () {}),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'CatchIconButton.counted owns typed counts, target size, and semantics',
    (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchIconButton.counted(
                key: const ValueKey('zero-count-icon-button'),
                icon: CatchIcons.notificationsNoneRounded,
                count: 0,
                tooltip: 'Notifications',
                onTap: () => taps++,
              ),
              CatchIconButton.counted(
                key: const ValueKey('counted-icon-button'),
                icon: CatchIcons.tuneRounded,
                count: 3,
                tooltip: 'Filters, 3 active',
                onTap: () => taps++,
              ),
              CatchIconButton.counted(
                icon: CatchIcons.notificationsRounded,
                count: 124,
                tooltip: 'Notifications, 124 unread',
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      final counted = find.byKey(const ValueKey('counted-icon-button'));
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Filters, 3 active',
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(
        tester.getSize(counted),
        const Size.square(CatchIconButton.defaultSize),
      );
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);

      await tester.tap(counted);
      await tester.pump();
      expect(taps, 1);
    },
  );

  testWidgets('CatchCountPill.label stays interactive and at least 44px', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchCountPill.label(
          key: const ValueKey('labelled-count-pill'),
          icon: CatchIcons.tuneRounded,
          label: 'Filters',
          count: 3,
          semanticLabel: 'Filters, 3 active',
          onPressed: () => taps++,
        ),
        textScale: 2,
      ),
    );

    final pill = find.byKey(const ValueKey('labelled-count-pill'));
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Filters, 3 active',
      ),
    );

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.getSize(pill).height, greaterThanOrEqualTo(44));
    expect(
      tester
          .getRect(find.text('Filters'))
          .overlaps(tester.getRect(find.text('3'))),
      isFalse,
    );
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.enabled, isTrue);

    await tester.tap(pill);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('CatchButton renders all catalog variants', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Wrap(
          children: [
            CatchButton(label: 'Primary', onPressed: null),
            CatchButton(
              label: 'Secondary',
              onPressed: null,
              variant: CatchButtonVariant.secondary,
            ),
            CatchButton(
              label: 'Ghost',
              onPressed: null,
              variant: CatchButtonVariant.ghost,
            ),
            CatchButton(
              label: 'Danger',
              onPressed: null,
              variant: CatchButtonVariant.danger,
            ),
            CatchButton(
              label: 'Light',
              onPressed: null,
              variant: CatchButtonVariant.light,
              isInteractive: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Ghost'), findsOneWidget);
    expect(find.text('Danger'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('CatchStepProgress renders count and full-width segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchStepProgress(
            label: 'Profile setup',
            currentStep: 1,
            totalSteps: 5,
          ),
        ),
      ),
    );

    expect(find.text('Profile setup'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
  });

  testWidgets('CatchStepHeader renders AppBar anatomy and progress hairline', (
    tester,
  ) async {
    var backTaps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchStepHeader(
          title: 'Basics',
          subtitle: 'South Bombay Runners',
          kicker: 'Create event',
          step: 2,
          total: 5,
          onBack: () => backTaps++,
        ),
      ),
    );

    final progress = tester.widget<FractionallySizedBox>(
      find.descendant(
        of: find.byType(CatchStepHeader),
        matching: find.byType(FractionallySizedBox),
      ),
    );

    expect(find.text('CREATE EVENT'), findsOneWidget);
    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('South Bombay Runners'), findsOneWidget);
    expect(find.text('STEP 2 OF 5'), findsOneWidget);
    expect(find.byIcon(CatchIcons.arrowBackIosNewRounded), findsOneWidget);
    expect(
      tester
          .getSize(
            find.descendant(
              of: find.byType(CatchStepHeader),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is SizedBox &&
                    widget.height == CatchLayout.stepHeaderProgressHeight,
              ),
            ),
          )
          .height,
      CatchLayout.stepHeaderProgressHeight,
    );
    expect(progress.widthFactor, 0.4);

    await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
    await tester.pump();

    expect(backTaps, 1);
  });

  testWidgets('CatchStepHeader displays one-based progress copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStepHeader(title: 'Schedule', step: 1, total: 3)),
    );

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
  });

  testWidgets('CatchButton light variant stays legible in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchButton(
          label: 'Light action',
          onPressed: null,
          variant: CatchButtonVariant.light,
          isInteractive: false,
        ),
        theme: AppTheme.dark,
      ),
    );

    final label = tester.widget<Text>(find.text('Light action'));

    expect(label.style?.color, CatchTokens.editorialLight.ink);
  });

  testWidgets('CatchButton primary variant uses white text in dark mode', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        CatchButton(label: 'Primary action', onPressed: () => taps++),
        theme: AppTheme.dark,
      ),
    );

    await tester.tap(find.text('Primary action'));
    await tester.pump();

    final label = tester.widget<Text>(find.text('Primary action'));

    expect(taps, 1);
    expect(label.style?.color, CatchTokens.editorialDark.primaryInk);
  });

  testWidgets('CatchTextButton applies token color and tap semantics', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(CatchTextButton(label: 'Retry', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    final label = tester.widget<Text>(find.text('Retry'));
    expect(taps, 1);
    expect(label.style?.color, CatchTokens.editorialLight.primary);
  });

  testWidgets('CatchTextButton keeps long localized labels constrained', (
    tester,
  ) async {
    const plainLabel = 'Cancel this unexpectedly long localized action';
    const leadingLabel = 'Saving this unexpectedly long localized action';

    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            SizedBox(
              width: 132,
              child: CatchTextButton(label: plainLabel, onPressed: null),
            ),
            SizedBox(
              width: 132,
              child: CatchTextButton(
                label: leadingLabel,
                onPressed: null,
                leading: SizedBox.square(dimension: 12),
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text(plainLabel)).width, lessThanOrEqualTo(116));
    expect(
      tester.getSize(find.text(leadingLabel)).width,
      lessThanOrEqualTo(98),
    );
    expect(
      tester.widget<Text>(find.text(plainLabel)).overflow,
      TextOverflow.ellipsis,
    );
    expect(
      tester.widget<Text>(find.text(leadingLabel)).overflow,
      TextOverflow.ellipsis,
    );
  });

  testWidgets('CatchToggle emits the next value on tap', (tester) async {
    bool? nextValue;

    await tester.pumpWidget(
      _wrap(
        CatchToggle(
          value: false,
          semanticLabel: 'Push notifications',
          onChanged: (value) => nextValue = value,
        ),
      ),
    );

    await tester.tap(find.byType(CatchToggle));
    await tester.pump();

    expect(nextValue, isTrue);
  });

  testWidgets(
    'CatchOtpCodeField renders visible digits over one hidden input',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => CatchOtpCodeField(
              inputKey: const ValueKey('otp-input'),
              controller: controller,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('otp-input')),
        '1234567',
      );
      await tester.pump();

      expect(controller.text, '123456');
      expect(find.byType(CatchCodeInputRow), findsOneWidget);
      expect(find.byType(CatchCodeInputCell), findsNWidgets(6));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsNothing);
    },
  );

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

  testWidgets('CatchDetailHeroBackdrop composes fallback and scrim renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchDetailHeroBackdrop(),
        ),
      ),
    );

    expect(find.byType(CatchDetailHeroFallback), findsOneWidget);
    expect(find.byType(CatchScrim), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchDetailHeroBackdrop(showScrim: false),
        ),
      ),
    );

    expect(find.byType(CatchDetailHeroFallback), findsOneWidget);
    expect(find.byType(CatchScrim), findsNothing);
  });

  testWidgets('CatchEventThumbnail composes fallback and scrim renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchEventThumbnail(
            photoUrl: null,
            pace: PaceLevel.easy,
            activityKind: ActivityKind.socialRun,
          ),
        ),
      ),
    );

    expect(find.byType(CatchEventThumbnailActivityFallback), findsOneWidget);
    expect(find.byType(CatchEventThumbnailScrimOverlay), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 220,
          height: 140,
          child: CatchEventThumbnail(
            photoUrl: null,
            pace: PaceLevel.easy,
            activityKind: ActivityKind.dinner,
            scrim: CatchEventThumbnailScrim.none,
          ),
        ),
      ),
    );

    expect(find.byType(CatchEventThumbnailActivityFallback), findsOneWidget);
    expect(find.byType(CatchEventThumbnailScrimOverlay), findsNothing);
  });

  testWidgets('CatchMetricStrip renders compact labeled data pairs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchMetricStrip(
            items: [
              CatchMetricStripItem(value: '124', label: 'members'),
              CatchMetricStripItem(value: '3', label: 'upcoming'),
              CatchMetricStripItem(value: '4.7', label: 'rating'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('124'), findsOneWidget);
    expect(find.text('members'), findsOneWidget);
    expect(find.text('upcoming'), findsOneWidget);
    expect(find.text('rating'), findsOneWidget);
    expect(find.byType(CatchMetricStripCell), findsNWidgets(3));
    expect(find.byType(CatchMetricStripDivider), findsNWidgets(2));
  });

  testWidgets('CatchDaySectionHeader composes count renderer', (tester) async {
    await tester.pumpWidget(
      _wrap(const CatchDaySectionHeader(label: 'Today', count: 3)),
    );

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.byType(CatchDaySectionHeaderCount), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(const CatchDaySectionHeader(label: 'Tomorrow')),
    );

    expect(find.byType(CatchDaySectionHeaderCount), findsNothing);
  });

  testWidgets('CatchJourneySteps composes public step nodes', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchJourneySteps(
          steps: [
            CatchJourneyStep(title: 'Arrive', body: 'Check in with the host.'),
            CatchJourneyStep(title: 'Meet', body: 'Start the first round.'),
          ],
        ),
      ),
    );

    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.byType(CatchJourneyStepNode), findsNWidgets(2));
  });

  testWidgets('CatchTabBar reveals only the selected label and badges icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchTabBar<String>(
          active: 'chats',
          items: const [
            CatchTabBarItem(
              id: 'home',
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            CatchTabBarItem(
              id: 'chats',
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chats',
              badgeCount: 104,
            ),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(CatchTabBarButton<String>), findsNWidgets(2));
    expect(find.byType(CatchTabBarIcon), findsNWidgets(2));
    expect(find.text('Home'), findsNothing);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('CatchTabBar keeps four animated destinations within 390px', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var active = 'home';
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchTabBar<String>(
            active: active,
            items: const [
              CatchTabBarItem(id: 'home', icon: Icons.home, label: 'Home'),
              CatchTabBarItem(
                id: 'explore',
                icon: Icons.explore,
                label: 'Explore',
              ),
              CatchTabBarItem(id: 'chats', icon: Icons.chat, label: 'Chats'),
              CatchTabBarItem(id: 'profile', icon: Icons.person, label: 'You'),
            ],
            onChanged: (next) => setState(() => active = next),
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Explore'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('Explore'), findsOneWidget);
  });

  testWidgets('CatchHorizontalRail is embedded and chromeless by default', (
    tester,
  ) async {
    const railKey = ValueKey('embedded-rail');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          key: railKey,
          width: 360,
          child: CatchHorizontalRail(
            title: 'Recommended',
            itemCount: 1,
            itemBuilder: (context, index) =>
                const SizedBox(width: 48, height: 48, child: Text('Item 1')),
          ),
        ),
      ),
    );

    final railLeft = tester.getTopLeft(find.byKey(railKey)).dx;

    expect(tester.getTopLeft(find.text('Recommended')).dx, railLeft);
    expect(tester.getTopLeft(find.text('Item 1')).dx, railLeft);
    expect(find.byType(CatchDivider), findsNothing);
  });

  testWidgets('CatchHorizontalRail fullBleed owns rail gutters and divider', (
    tester,
  ) async {
    const railKey = ValueKey('full-bleed-rail');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          key: railKey,
          width: 360,
          child: CatchHorizontalRail(
            title: 'Recommended',
            itemCount: 1,
            fullBleed: true,
            itemBuilder: (context, index) =>
                const SizedBox(width: 48, height: 48, child: Text('Item 1')),
          ),
        ),
      ),
    );

    final railLeft = tester.getTopLeft(find.byKey(railKey)).dx;

    expect(
      tester.getTopLeft(find.text('Recommended')).dx - railLeft,
      CatchSpacing.screenPx,
    );
    expect(
      tester.getTopLeft(find.text('Item 1')).dx - railLeft,
      CatchSpacing.screenPx,
    );
    expect(find.byType(CatchDivider), findsOneWidget);
  });

  testWidgets('CatchScreenBody owns the scrolling page gutter', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            height: 480,
            child: CatchScreenBody(
              pt: CatchSpacing.s2,
              pb: CatchSpacing.s8,
              child: SizedBox(height: 900, child: Text('Body')),
            ),
          ),
        ),
      ),
    );

    final bodyFinder = find.byType(CatchScreenBody);
    final padding = tester.widget<Padding>(
      find.descendant(of: bodyFinder, matching: find.byType(Padding)).first,
    );
    final minHeight = tester.widget<ConstrainedBox>(
      find
          .descendant(of: bodyFinder, matching: find.byType(ConstrainedBox))
          .first,
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      padding.padding,
      const EdgeInsets.fromLTRB(
        CatchSpacing.screenPx,
        CatchSpacing.s2,
        CatchSpacing.screenPx,
        CatchSpacing.s8,
      ),
    );
    expect(minHeight.constraints.minHeight, 480);
  });

  testWidgets('CatchScreenBody can drop the gutter without owning scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchScreenBody(
          gutter: false,
          scrollable: false,
          child: Text('Full bleed body'),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(CatchScreenBody),
            matching: find.byType(Padding),
          )
          .first,
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      padding.padding,
      const EdgeInsets.fromLTRB(
        CatchSpacing.s0,
        CatchSpacing.screenPt,
        CatchSpacing.s0,
        CatchSpacing.screenPb,
      ),
    );
  });

  testWidgets('compact core atoms render with shared primitives', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchMetaDotRow(
                entries: [
                  CatchMetaEntry(
                    label: 'Tonight',
                    icon: CatchIcons.calendarTodayOutlined,
                  ),
                  const CatchMetaEntry(label: 'Bandra'),
                ],
                trailing: const CatchMetaEntry(label: '2.3 km'),
              ),
              gapH12,
              const CatchField.read(title: 'Payment ID', body: 'pay_123'),
              gapH12,
              const CatchStatColumn(
                value: '24',
                label: 'members',
                center: true,
              ),
              gapH12,
              const CatchGradedImage(
                enabled: false,
                child: SizedBox.square(
                  dimension: 12,
                  child: ColoredBox(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Bandra'), findsOneWidget);
    expect(find.text('2.3 km'), findsOneWidget);
    expect(find.byType(CatchMetaEntryFlow), findsOneWidget);
    expect(find.byType(CatchMetaEntryView), findsNWidgets(3));
    expect(find.text('Payment ID'), findsOneWidget);
    expect(find.text('pay_123'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('members'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('CatchStartupLoadingScreen delays slow-boot spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const CatchStartupLoadingScreen(),
      ),
    );

    expect(find.bySemanticsLabel('Catch'), findsOneWidget);
    final logo = tester.widget<Image>(_startupLogoFinder);
    expect(
      (logo.image as AssetImage).assetName,
      CatchStartupLoadingScreen.lightIconAsset,
    );
    expect(find.byType(CatchLoadingIndicator), findsNothing);

    await tester.pump(CatchMotion.startupIndicatorDelay);
    await tester.pump(CatchMotion.fast);

    expect(find.byType(CatchLoadingIndicator), findsOneWidget);
  });

  testWidgets('CatchStartupLoadingScreen uses dark splash mark in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const CatchStartupLoadingScreen(),
      ),
    );

    final logo = tester.widget<Image>(_startupLogoFinder);
    expect(
      (logo.image as AssetImage).assetName,
      CatchStartupLoadingScreen.darkIconAsset,
    );
  });

  testWidgets('CatchStatusBar renders handoff light and surface states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStatusBar(time: '10:24', surface: true)),
    );

    final time = tester.widget<Text>(find.text('10:24'));
    final surface = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(ColoredBox),
      ),
    );
    final iconTheme = tester.widget<IconTheme>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(IconTheme),
      ),
    );

    expect(surface.color, CatchTokens.editorialLight.surface);
    expect(time.style?.fontSize, CatchLayout.statusBarTimeFontSize);
    expect(time.style?.fontWeight, FontWeight.w700);
    expect(time.style?.color, CatchTokens.editorialLight.ink);
    expect(iconTheme.data.color, CatchTokens.editorialLight.ink);
    expect(find.byIcon(CatchIcons.statusCellSignal), findsOneWidget);
    expect(find.byIcon(CatchIcons.statusWifi), findsOneWidget);
    expect(find.byIcon(CatchIcons.statusBattery), findsOneWidget);
  });

  testWidgets('CatchStatusBar renders paper ink on dark wow surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchStatusBar(tone: CatchStatusBarTone.dark)),
    );

    final time = tester.widget<Text>(find.text('9:41'));
    final iconTheme = tester.widget<IconTheme>(
      find.descendant(
        of: find.byType(CatchStatusBar),
        matching: find.byType(IconTheme),
      ),
    );

    expect(time.style?.color, CatchTokens.editorialDark.ink);
    expect(iconTheme.data.color, CatchTokens.editorialDark.ink);
  });

  testWidgets('CatchSurface supports padding, fixed size, and tap handling', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        CatchSurface(
          width: 180,
          padding: const EdgeInsets.all(16),
          tone: CatchSurfaceTone.raised,
          borderColor: Colors.black,
          onTap: () => tapped = true,
          child: const Text('Surface content'),
        ),
      ),
    );

    expect(find.text('Surface content'), findsOneWidget);
    expect(tester.getSize(find.byType(CatchSurface)).width, 180);

    await tester.tap(find.text('Surface content'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('CatchSurface.card renders the handoff card surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchSurface.card(width: 240, child: Text('Panel content'))),
    );

    final panelSurface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(find.text('Panel content'), findsOneWidget);
    expect(panelSurface.role, CatchSurfaceRole.card);
    expect(panelSurface.width, 240);
    expect(panelSurface.padding, CatchInsets.contentRelaxed);
    expect(panelSurface.radius, CatchRadius.md);
    expect(panelSurface.elevation, CatchSurfaceElevation.card);
  });

  testWidgets('CatchSurface.message renders inline title and tone content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSurface.message(
          title: 'Host tip',
          message: 'Keep the first message short and specific.',
          messageTone: CatchSurfaceMessageTone.warning,
        ),
      ),
    );

    final messageSurfaceFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CatchSurface && widget.role == CatchSurfaceRole.message,
    );
    final renderedSurfaceFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CatchSurface && widget.role == CatchSurfaceRole.base,
    );
    final messageSurface = tester.widget<CatchSurface>(messageSurfaceFinder);
    final renderedSurface = tester.widget<CatchSurface>(renderedSurfaceFinder);
    expect(find.text('Host tip'), findsOneWidget);
    expect(
      find.text('Keep the first message short and specific.'),
      findsOneWidget,
    );
    expect(messageSurfaceFinder, findsOneWidget);
    expect(renderedSurfaceFinder, findsOneWidget);
    expect(messageSurface.role, CatchSurfaceRole.message);
    expect(renderedSurface.role, CatchSurfaceRole.base);
    expect(renderedSurface.radius, CatchRadius.md);
  });

  testWidgets('CatchEmptyState defaults to the handoff quiet placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchEmptyState(
          icon: CatchIcons.search,
          title: 'Nothing here yet',
          message: 'Try another filter or check back soon.',
          action: CatchButton(label: 'Browse events', onPressed: () {}),
        ),
      ),
    );

    expect(find.byType(CatchSurface), findsNothing);
    expect(find.byType(CatchEmptyStateContent), findsOneWidget);
    expect(find.byType(CatchEmptyStateIcon), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(CatchIcons.search));
    final title = tester.widget<Text>(find.text('Nothing here yet'));
    final message = tester.widget<Text>(
      find.text('Try another filter or check back soon.'),
    );
    final titleContext = tester.element(find.text('Nothing here yet'));
    final messageContext = tester.element(
      find.text('Try another filter or check back soon.'),
    );

    expect(icon.size, 34);
    expect(icon.color, CatchTokens.editorialLight.ink3);
    expect(
      title.style?.fontSize,
      CatchTextStyles.sectionTitle(titleContext).fontSize,
    );
    expect(
      message.style?.fontSize,
      CatchTextStyles.bodyS(messageContext).fontSize,
    );
    expect(message.style?.color, CatchTokens.editorialLight.ink2);
    expect(find.text('Browse events'), findsOneWidget);
  });

  testWidgets('CatchBottomSheetScaffold renders the handoff plain sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomSheetScaffold(
          title: 'Filters',
          subtitle: 'Tune what shows up first.',
          badge: '2',
          badgeTone: CatchBadgeTone.gold,
          action: CatchButton(label: 'Apply', onPressed: () {}),
          child: const Text('Sheet body'),
        ),
      ),
    );

    expect(find.byType(CatchBottomSheetGrabber), findsOneWidget);
    expect(find.byType(CatchPlainSheetHeader), findsOneWidget);
    expect(find.byType(CatchBrandedSheetHeader), findsNothing);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Tune what shows up first.'), findsOneWidget);
    expect(find.widgetWithText(CatchBadge, '2'), findsOneWidget);
    expect(find.text('Sheet body'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('CatchBottomSheetScaffold renders the branded sheet header', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomSheetScaffold(
          title: 'Set up payouts',
          subtitle: 'Powered by Stripe',
          glyph: CatchIcons.hostBadge,
          trailing: const Text('Soon'),
          grabber: false,
          child: const Text('Stripe body'),
        ),
      ),
    );

    expect(find.byType(CatchBottomSheetGrabber), findsNothing);
    expect(find.byType(CatchPlainSheetHeader), findsNothing);
    expect(find.byType(CatchBrandedSheetHeader), findsOneWidget);
    final glyph = tester.widget<Icon>(find.byIcon(CatchIcons.hostBadge));
    expect(glyph.size, CatchLayout.sheetGlyphIconSize);
    expect(glyph.color, CatchTokens.editorialLight.primaryInk);
    expect(find.text('Set up payouts'), findsOneWidget);
    expect(find.text('Powered by Stripe'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);
    expect(find.text('Stripe body'), findsOneWidget);
  });

  testWidgets(
    'CatchSurface disables chrome animation when reduced motion is on',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: CatchSurface.card(child: Text('Panel')),
          ),
        ),
      );

      final surface = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(CatchSurface),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(surface.duration, Duration.zero);
    },
  );

  testWidgets('CatchFrameworkErrorView renders branded recovery UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchFrameworkErrorView(
          details: FlutterErrorDetails(exception: StateError('boom')),
          showDebugDetails: false,
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.textContaining('This screen hit a temporary app error'),
      findsOneWidget,
    );
    expect(find.text('Developer details'), findsNothing);
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('CatchErrorIcon renders the shared branded medallion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchErrorIcon()));

    expect(find.byType(CatchErrorIcon), findsOneWidget);
    expect(find.byIcon(CatchIcons.errorOutlineRounded), findsOneWidget);
  });

  testWidgets('CatchMonoLabel renders compact metadata with overflow guard', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CatchMonoLabel('TODAY AT 7 PM', color: Colors.black)),
    );

    final text = tester.widget<Text>(find.text('TODAY AT 7 PM'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('CatchFrameworkErrorView can expose debug details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchFrameworkErrorView(
          details: FlutterErrorDetails(exception: StateError('boom')),
        ),
      ),
    );

    expect(find.text('Developer details'), findsOneWidget);
    expect(find.byType(CatchFrameworkErrorDebugDetails), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    await tester.tap(find.text('Developer details'));
    await pumpFeatureUi(tester);
    expect(find.textContaining('Bad state: boom'), findsOneWidget);
  });

  testWidgets('CatchFrameworkErrorDebugDetails renders expanded details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchFrameworkErrorDebugDetails(
          details: 'debug exception details',
          initiallyExpanded: true,
        ),
      ),
    );

    expect(find.text('Developer details'), findsOneWidget);
    expect(find.text('debug exception details'), findsOneWidget);
  });

  testWidgets('CatchErrorState renders retry UI without debug details', (
    tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchErrorState.fromError(
          StateError('Could not load profile'),
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(CatchErrorBody), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('StackTrace'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('CatchErrorState honors an explicit recovery callback', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _wrap(
        CatchErrorState.fromError(
          const ValidationException('Please enter a valid phone number.'),
          onRetry: () => retryCount += 1,
        ),
      ),
    );

    expect(find.text('Check your details'), findsOneWidget);
    expect(
      find.text('Check the highlighted details and try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryCount, 1);
  });

  testWidgets('Catch error variants keep a caller-provided alternate action', (
    tester,
  ) async {
    var alternateCount = 0;
    Widget alternateAction() => CatchButton(
      label: 'Go back',
      onPressed: () => alternateCount += 1,
      variant: CatchButtonVariant.secondary,
    );

    await tester.pumpWidget(
      _wrap(
        CatchInlineErrorState.fromError(
          const PermissionException('Unavailable.'),
          secondaryAction: alternateAction(),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 1);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: CatchErrorScaffold.fromError(
          const PermissionException('Unavailable.'),
          secondaryAction: alternateAction(),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 2);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              CatchSliverErrorState.fromError(
                const PermissionException('Unavailable.'),
                secondaryAction: alternateAction(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go back'));
    expect(alternateCount, 3);
  });

  testWidgets('CatchSliverErrorState fills a sliver viewport', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CustomScrollView(
            slivers: [
              CatchSliverErrorState(
                title: 'Messages unavailable',
                message: 'Unable to load messages.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Messages unavailable'), findsOneWidget);
    expect(find.text('Unable to load messages.'), findsOneWidget);
    expect(find.byType(CatchErrorBody), findsOneWidget);
  });

  testWidgets(
    'box state viewport centers in the visible floating-shell region',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AppShellActiveTab(
            index: 1,
            bottomBarPlacement: AppShellBottomBarPlacement.floating,
            bottomOverlayInset: 100,
            child: Scaffold(
              key: ValueKey('box-state-scaffold'),
              body: CatchStateViewport(
                child: CatchEmptyState(title: 'Nothing here'),
              ),
            ),
          ),
        ),
      );

      final scaffold = find.byKey(const ValueKey('box-state-scaffold'));
      final offset =
          tester.getCenter(find.byType(CatchEmptyStateContent)).dy -
          tester.getCenter(scaffold).dy;
      expect(offset, closeTo(-50, 1));
    },
  );

  testWidgets(
    'sliver empty and error states center in the visible floating-shell region',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      Future<double> pumpState(Widget sliver, Finder content) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: AppShellActiveTab(
              index: 1,
              bottomBarPlacement: AppShellBottomBarPlacement.floating,
              bottomOverlayInset: 100,
              child: Scaffold(
                key: const ValueKey('state-scaffold'),
                body: CustomScrollView(slivers: [sliver]),
              ),
            ),
          ),
        );
        final viewport = find.descendant(
          of: find.byKey(const ValueKey('state-scaffold')),
          matching: find.byType(CustomScrollView),
        );
        return tester.getCenter(content).dy - tester.getCenter(viewport).dy;
      }

      final emptyOffset = await pumpState(
        const CatchSliverEmptyState(title: 'Nothing here'),
        find.byType(CatchEmptyStateContent),
      );
      expect(emptyOffset, closeTo(-50, 1));

      final errorOffset = await pumpState(
        const CatchSliverErrorState(
          title: 'Unavailable',
          message: 'Try again later.',
        ),
        find.byType(CatchErrorBody),
      );
      expect(errorOffset, closeTo(-50, 1));
    },
  );

  testWidgets('CatchAsyncValueView uses branded default error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          builder: (context, value) => Text('$value'),
        ),
      ),
    );

    expect(find.bySubtype<CatchErrorState>(), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('CatchAsyncValueView supports context-aware state builders', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          builder: (context, value) => Text('$value'),
          loadingBuilder: (context) => const Text('Loading custom state'),
          errorBuilder: (context, error, stackTrace) =>
              Text('Custom error: $error'),
        ),
      ),
    );

    expect(find.textContaining('Custom error:'), findsOneWidget);
    expect(find.byType(CatchErrorState), findsNothing);

    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: const AsyncLoading<int>(),
          builder: (context, value) => Text('$value'),
          loadingBuilder: (context) => const Text('Loading custom state'),
        ),
      ),
    );

    expect(find.text('Loading custom state'), findsOneWidget);
  });

  testWidgets('CatchAsyncValueView replaces an expired skeleton with retry', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: const AsyncLoading<int>(),
          initialLoadTimeout: const Duration(milliseconds: 10),
          onRetry: () => retryCount += 1,
          builder: (context, value) => Text('$value'),
          loadingBuilder: (_) => const Text('Loading custom state'),
        ),
      ),
    );

    expect(find.text('Loading custom state'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 11));
    expect(
      find.text('The request timed out. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryCount, 1);
    expect(find.text('Loading custom state'), findsOneWidget);
  });

  testWidgets('CatchAsyncScreenLoading uses shared screen body and skeletons', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CatchAsyncScreenLoading(count: 2)));

    expect(find.byType(CatchScreenBody), findsOneWidget);
    expect(find.byType(CatchSkeletonList), findsOneWidget);
  });

  testWidgets('CatchSkeleton.box renders a fixed-size skeleton piece', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(CatchSkeleton.box(width: 42, height: 24)));

    expect(find.byType(CatchSkeleton), findsOneWidget);
    expect(tester.getSize(find.byType(CatchSkeleton)), const Size(42, 24));
  });

  testWidgets('CatchSkeleton uses the theme raised fill in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(CatchSkeleton.box(width: 42, height: 24), theme: AppTheme.dark),
    );

    final themedShape = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(CatchSkeleton),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((container) => container.decoration is BoxDecoration);
    final decoration = themedShape.decoration! as BoxDecoration;
    expect(decoration.color, CatchTokens.dark.raised);
    expect(decoration.color, isNot(CatchTokens.editorialWhite));
  });

  testWidgets('showCatchErrorSnackBar maps errors to user copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showCatchErrorSnackBar(context, StateError('snack failed')),
              child: const Text('Show error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show error'));
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('showCatchSnackBar pins token contrast in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCatchSnackBar(context, 'Saved.'),
              child: const Text('Show snackbar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final message = tester.widget<Text>(find.text('Saved.'));
    expect(snackBar.backgroundColor, CatchTokens.dark.ink);
    expect(message.style?.color, CatchTokens.dark.bg);
  });

  testWidgets(
    'showCatchErrorSnackBar exposes retry action for retryable errors',
    (tester) async {
      var retryCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCatchErrorSnackBar(
                  context,
                  const NetworkException(
                    'timeout',
                    'The request timed out. Please try again.',
                  ),
                  onRetry: () => retryCount++,
                ),
                child: const Text('Show error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show error'));
      await pumpFeatureUi(tester);

      await tester.tap(find.text('Try again'));
      await pumpFeatureUi(tester);

      expect(retryCount, 1);
    },
  );

  testWidgets('CatchMutationErrorBanner renders mutation errors inline', (
    tester,
  ) async {
    final mutation = Mutation<void>();
    var retryCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(mutation);
                return Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await mutation.run(ref, (_) async {
                            throw const NetworkException(
                              'timeout',
                              'The request timed out. Please try again.',
                            );
                          });
                        } catch (_) {}
                      },
                      child: const Text('Save'),
                    ),
                    CatchMutationErrorBanner(
                      mutation: state,
                      onRetry: () => retryCount++,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CatchErrorBanner), findsNothing);

    await tester.tap(find.text('Save'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchErrorBanner), findsOneWidget);
    expect(
      find.text('The request timed out. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await pumpFeatureUi(tester);

    expect(retryCount, 1);
  });

  testWidgets('CatchMutationErrorListeners handles multiple mutations', (
    tester,
  ) async {
    final saveMutation = Mutation<void>();
    final deleteMutation = Mutation<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => CatchMutationErrorListeners(
                mutations: [saveMutation, deleteMutation],
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await saveMutation.run(ref, (_) async {
                            throw StateError('save failed');
                          });
                        } catch (_) {}
                      },
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await deleteMutation.run(ref, (_) async {
                            throw StateError('delete failed');
                          });
                        } catch (_) {}
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Delete'));
    await pumpFeatureUi(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('CatchSearchField renders pill search and clear behavior', (
    tester,
  ) async {
    var query = 'tempo';
    var submitted = '';
    var focused = false;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchSearchField(
            value: query,
            placeholder: 'Search clubs',
            semanticLabel: 'Search clubs',
            onChanged: (value) => setState(() => query = value),
            onSubmitted: (value) => submitted = value,
            onFocusChanged: (value) => focused = value,
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.search), findsOneWidget);
    expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'tempo',
    );
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration?.filled, isFalse);
    expect(textField.decoration?.fillColor, Colors.transparent);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focused, isTrue);

    await tester.enterText(find.byType(TextField), 'asha');
    await tester.pump();
    expect(query, 'asha');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 'asha');

    await tester.tap(find.byIcon(CatchIcons.clearCircle));
    await tester.pump();
    expect(query, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets(
    'CatchSearchField expanding mode opens, clears, and closes from the app bar slot',
    (tester) async {
      const searchFieldKey = ValueKey('expanding-search-field');
      var query = 'tempo';
      var opened = false;
      var closed = false;

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField(
                key: searchFieldKey,
                mode: CatchSearchFieldMode.expanding,
                progress: 0,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);
      expect(tester.getSize(find.byKey(searchFieldKey)).width, 280);
      expect(find.byIcon(CatchIcons.search), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.search));
      await tester.pump();
      expect(opened, isTrue);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField(
                key: searchFieldKey,
                mode: CatchSearchFieldMode.expanding,
                progress: 0.5,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(CatchMotion.base);

      expect(find.byType(TextField), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: CatchSearchField(
                key: searchFieldKey,
                mode: CatchSearchFieldMode.expanding,
                progress: 1,
                maxWidth: 280,
                value: query,
                placeholder: 'Search clubs',
                onChanged: (value) => setState(() => query = value),
                onOpenSearch: () => opened = true,
                onCloseSearch: () => closed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(CatchMotion.base);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(CatchIcons.clearCircle), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.clearCircle));
      await tester.pump();
      expect(query, isEmpty);
      expect(closed, isFalse);
      expect(find.byIcon(CatchIcons.close), findsOneWidget);

      await tester.tap(find.byIcon(CatchIcons.close));
      await tester.pump();
      expect(closed, isTrue);
    },
  );

  testWidgets('CatchMenu renders handoff rows and selection state', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _wrap(
        CatchMenu<String>(
          width: 220,
          items: [
            CatchMenuItem(
              value: 'owner',
              label: 'Owner club',
              sublabel: 'OWNER',
              icon: CatchIcons.hostBadge,
              selected: true,
            ),
            CatchMenuItem(
              value: 'delete',
              label: 'Delete club',
              icon: CatchIcons.deleteOutline,
              danger: true,
            ),
          ],
          onSelected: (value, _) => selected = value,
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.width, 220);
    expect(surface.radius, CatchRadius.md);
    expect(surface.elevation, CatchSurfaceElevation.overlay);
    expect(find.text('Owner club'), findsOneWidget);
    expect(find.text('OWNER'), findsOneWidget);
    expect(find.byIcon(CatchIcons.check), findsOneWidget);
    expect(find.byType(CatchDivider), findsOneWidget);
    expect(find.byType(CatchMenuRow<String>), findsNWidgets(2));

    await tester.tap(find.text('Delete club'));
    await tester.pump();

    expect(selected, 'delete');
  });

  testWidgets('CatchMenuRow disables selection when item is disabled', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      _wrap(
        CatchMenuRow<String>(
          item: const CatchMenuItem(
            value: 'locked',
            label: 'Locked',
            enabled: false,
          ),
          onSelected: (_, _) => selected = true,
        ),
      ),
    );

    await tester.tap(find.text('Locked'));
    expect(selected, isFalse);
  });

  testWidgets('CatchActionMenu opens the shared handoff menu panel', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      _wrap(
        CatchActionMenu<String>(
          tooltip: 'More actions',
          items: [
            CatchActionMenuItem(
              value: 'active',
              label: 'Active club',
              sublabel: 'HOST',
              icon: CatchIcons.hostBadge,
              selected: true,
            ),
            CatchActionMenuItem(
              value: 'remove',
              label: 'Remove host',
              icon: CatchIcons.deleteOutline,
              isDestructive: true,
            ),
          ],
          onSelected: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.byTooltip('More actions'));
    await pumpFeatureUi(tester);

    expect(find.byType(CatchMenu<String>), findsOneWidget);
    expect(find.text('Active club'), findsOneWidget);
    expect(find.text('HOST'), findsOneWidget);
    expect(find.byIcon(CatchIcons.check), findsOneWidget);

    await tester.tap(find.text('Remove host'));
    await pumpFeatureUi(tester);

    expect(selected, 'remove');
    expect(find.byType(CatchMenu<String>), findsNothing);
  });
}

Finder get _startupLogoFinder {
  return find.byWidgetPredicate(
    (widget) => widget is Image && widget.semanticLabel == 'Catch',
  );
}

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

bool _chipSelected(WidgetTester tester, Finder chip) {
  final semantics = tester.widget<Semantics>(
    find
        .descendant(
          of: chip,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.selected != null,
          ),
        )
        .first,
  );
  return semantics.properties.selected!;
}
