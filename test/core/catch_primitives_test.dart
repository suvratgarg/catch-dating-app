import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
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
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
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
    'CatchBottomDock.cta forwards activity accent to the primary button',
    (tester) async {
      const accent = Color(0xFF116466);

      await tester.pumpWidget(
        _wrap(
          CatchBottomDock.cta(
            label: 'Join event',
            onPressed: () {},
            buttonAccentColor: accent,
          ),
        ),
      );

      expect(find.byType(CatchBottomDockCta), findsOneWidget);
      final button = tester.widget<CatchButton>(
        find.widgetWithText(CatchButton, 'Join event'),
      );
      expect(button.accentColor, accent);
    },
  );

  testWidgets('CatchBottomDockCta renders catch line and footnote', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchBottomDockCta(
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

  testWidgets('CatchField valueText occupies a right-aligned value lane', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchField.read(
            title: 'Help & support',
            valueText: 'Contact us',
            icon: CatchIcons.helpOutline,
          ),
        ),
      ),
    );

    final valueText = tester.widget<Text>(find.text('Contact us'));
    final valueBox = tester.getSize(find.text('Contact us'));
    final labelRight = tester.getTopRight(find.text('Help & support')).dx;
    final valueLeft = tester.getTopLeft(find.text('Contact us')).dx;

    expect(valueText.textAlign, TextAlign.right);
    expect(
      valueBox.width,
      lessThanOrEqualTo(CatchLayout.fieldTrailingValueMaxWidth),
    );
    expect(valueLeft, greaterThan(labelRight));
  });

  testWidgets('CatchField valueText stays inside narrow row constraints', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 180,
          child: CatchField.read(
            title: 'Availability window',
            valueText: 'Weeknights after work',
            icon: CatchIcons.schedule,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final fieldRight = tester.getTopRight(find.byType(CatchField)).dx;
    final valueRight = tester
        .getTopRight(find.text('Weeknights after work'))
        .dx;

    expect(valueRight, lessThanOrEqualTo(fieldRight));
  });

  testWidgets('CatchField row keeps its own horizontal gutter by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchField.read(
            title: 'Notifications',
            valueText: 'On',
            icon: CatchIcons.helpOutline,
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final iconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
    final labelLeft = tester.getTopLeft(find.text('Notifications')).dx;
    final valueRight = tester.getTopRight(find.text('On')).dx;

    expect(iconRect.left - fieldRect.left, CatchSpacing.s4);
    expect(
      labelLeft - fieldRect.left,
      CatchSpacing.s4 + CatchFieldRow.textLaneInset,
    );
    expect(fieldRect.right - valueRight, CatchSpacing.s4);
  });

  testWidgets('CatchFieldInsetScope flush hands the gutter to the container', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchFieldInsetScope(
            flush: true,
            child: CatchField.read(
              title: 'Notifications',
              valueText: 'On',
              icon: CatchIcons.helpOutline,
            ),
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final iconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
    final labelLeft = tester.getTopLeft(find.text('Notifications')).dx;
    final valueRight = tester.getTopRight(find.text('On')).dx;

    expect(iconRect.left, fieldRect.left);
    expect(labelLeft - fieldRect.left, CatchFieldRow.textLaneInset);
    expect(valueRight, fieldRect.right);
  });

  testWidgets(
    'CatchSection.fieldRows renders rows flush with lane-aligned dividers',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              title: 'Details',
              children: [
                CatchField.read(
                  title: 'First',
                  valueText: 'A',
                  icon: CatchIcons.helpOutline,
                ),
                CatchField.read(
                  title: 'Second',
                  valueText: 'B',
                  icon: CatchIcons.schedule,
                ),
              ],
            ),
          ),
        ),
      );

      final sectionRect = tester.getRect(find.byType(CatchSection));
      final firstIconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
      expect(firstIconRect.left, sectionRect.left);

      final dividerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).height == CatchStroke.hairline,
      );
      final dividerRect = tester.getRect(dividerFinder.last);
      expect(dividerRect.left - sectionRect.left, CatchFieldRow.textLaneInset);
      expect(dividerRect.right, sectionRect.right);

      final dividerBox = tester.widget<ColoredBox>(dividerFinder.last);
      expect(dividerBox.color, CatchTokens.editorialLight.line);
    },
  );

  testWidgets(
    'CatchSection.fieldRows paints dividers from the preceding row layer',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              first: true,
              children: [
                CatchField.read(title: 'First', body: 'A'),
                CatchField.control(
                  title: 'Second',
                  body: 'B',
                  initiallyOpen: true,
                  control: Text('Second control'),
                ),
                CatchField.read(title: 'Third', body: 'C'),
              ],
            ),
          ),
        ),
      );

      final dividerPositions = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .where((positioned) => positioned.child is CatchDivider)
          .toList(growable: false);

      expect(dividerPositions, hasLength(2));
      for (final positioned in dividerPositions) {
        expect(positioned.top, isNull);
        expect(positioned.bottom, -CatchStroke.hairline);
      }
    },
  );

  testWidgets(
    'CatchSection field dividers do not change the global row divider tone',
    (tester) async {
      final tokens = CatchTokens.editorialLight;

      expect(
        CatchDivider.colorFor(tokens, CatchDividerRole.fieldSection),
        tokens.line,
      );
      expect(
        CatchDivider.colorFor(tokens, CatchDividerRole.fieldRow),
        tokens.line.withValues(alpha: CatchOpacity.fieldRowDivider),
      );
    },
  );

  testWidgets('CatchSection headerless field rows still own their top rule', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            first: true,
            children: [CatchField.read(title: 'Log out')],
          ),
        ),
      ),
    );

    final sectionRect = tester.getRect(find.byType(CatchSection));
    final ruleRect = tester.getRect(find.byType(CatchDivider));

    expect(ruleRect.top, sectionRect.top);
    expect(ruleRect.left, sectionRect.left);
    expect(ruleRect.right, sectionRect.right);
  });

  testWidgets(
    'CatchSection field rows preserve text-lane dividers for adapter children',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.fieldRows(
              first: true,
              children: [
                SizedBox(child: CatchField.read(title: 'First')),
                SizedBox(child: CatchField.read(title: 'Second')),
              ],
            ),
          ),
        ),
      );

      final sectionRect = tester.getRect(find.byType(CatchSection));
      final dividerRect = tester.getRect(
        find
            .byWidgetPredicate(
              (widget) => widget is Positioned && widget.child is CatchDivider,
            )
            .first,
      );

      expect(
        dividerRect.left - sectionRect.left,
        CatchFieldTokens.textLaneInset,
      );
    },
  );

  testWidgets('CatchSection divided footer uses handoff spacing and caption', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            first: true,
            footer: Text('We never show your birth year.'),
            children: [CatchField.read(title: 'Date of birth', body: '12 Aug')],
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final footerFinder = find.text('We never show your birth year.');
    final footerRect = tester.getRect(footerFinder);
    final footerStyle = DefaultTextStyle.of(tester.element(footerFinder)).style;

    expect(
      footerRect.top - fieldRect.bottom,
      closeTo(CatchFieldTokens.sectionFooterTopPadding, 0.001),
    );
    expect(footerStyle.color, CatchTokens.editorialLight.ink3);
    expect(footerStyle.height, 1.5);
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

  testWidgets('CatchChip supports active, tap, and removable states', (
    tester,
  ) async {
    var tapped = false;
    var removed = false;

    await tester.pumpWidget(
      _wrap(
        CatchChip(
          label: 'Easy',
          active: true,
          onTap: () => tapped = true,
          onRemove: () => removed = true,
        ),
      ),
    );

    final chipFinder = find.byType(CatchChip);
    final tokens = CatchTokens.of(tester.element(chipFinder));
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: chipFinder,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;

    expect(decoration.color, Colors.transparent);
    expect(decoration.border?.top.color, tokens.ink);
    expect(decoration.border?.top.width, 1.5);
    expect(find.byType(CatchChipRemoveButton), findsOneWidget);

    await tester.tap(find.text('Easy'));
    await tester.pump();
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(CatchIcons.closeRounded));
    await tester.pump();
    expect(removed, isTrue);
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

  testWidgets('CatchSegmentedControl supports expanded icon and label tabs', (
    tester,
  ) async {
    var selected = 'setup';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: CatchSegmentedControl<String>(
              selected: selected,
              expanded: true,
              style: CatchSegmentedControlStyle.surface,
              onChanged: (value) => setState(() => selected = value),
              segments: [
                CatchSegment(
                  value: 'setup',
                  label: 'Setup',
                  icon: CatchIcons.tuneRounded,
                ),
                CatchSegment(
                  value: 'live',
                  label: 'Live',
                  icon: CatchIcons.playCircleOutlineRounded,
                ),
                CatchSegment(
                  value: 'report',
                  label: 'Report',
                  icon: CatchIcons.insightsOutlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CatchSegmentedControl<String>)).width,
      360,
    );
    expect(find.byType(CatchSegmentButton<String>), findsNWidgets(3));
    expect(find.byIcon(CatchIcons.tuneRounded), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);

    await tester.tap(find.text('Live'));
    await tester.pump();
    expect(selected, 'live');
  });

  testWidgets('CatchSegmentButton renders selected label and tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        CatchSegmentButton<String>(
          segment: const CatchSegment(value: 'agenda', label: 'Agenda'),
          selected: true,
          expanded: false,
          style: CatchSegmentedControlStyle.filled,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Agenda'), findsOneWidget);
    await tester.tap(find.text('Agenda'));
    expect(tapped, isTrue);
  });

  testWidgets('CatchSegmentedControl exposes compact mono SegPill density', (
    tester,
  ) async {
    var selected = 'booked';

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 350,
            child: CatchSegmentedControl<String>(
              selected: selected,
              expanded: true,
              style: CatchSegmentedControlStyle.surface,
              size: CatchSegmentedControlSize.compact,
              labelStyle: CatchSegmentedControlLabelStyle.mono,
              onChanged: (value) => setState(() => selected = value),
              segments: const [
                CatchSegment(value: 'booked', label: 'BOOKED · 2'),
                CatchSegment(value: 'prospective', label: 'PROSPECTIVE · 2'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CatchSegmentedControl<String>)).height,
      lessThan(40),
    );
    await tester.tap(find.text('PROSPECTIVE · 2'));
    await tester.pump();
    expect(selected, 'prospective');
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

      final firstChip = tester.widget<CatchChip>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchChip &&
              widget.label == defaultCityOptions.first.label,
        ),
      );
      expect(firstChip.active, isFalse);
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

    final selectedChip = tester.widget<CatchChip>(
      find.byWidgetPredicate(
        (widget) => widget is CatchChip && widget.label == cityLabel('mumbai'),
      ),
    );
    final unselectedChip = tester.widget<CatchChip>(
      find.byWidgetPredicate(
        (widget) => widget is CatchChip && widget.label == cityLabel('delhi'),
      ),
    );

    expect(selectedChip.active, isTrue);
    expect(selectedChip.icon, isA<Icon>());
    expect(unselectedChip.active, isFalse);
    expect(unselectedChip.icon, isNull);
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

  testWidgets('CatchBadge renders status tones and uppercase option', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Wrap(
          children: [
            const CatchBadge(label: 'pending'),
            const CatchBadge(label: 'paid', tone: CatchBadgeTone.success),
            const CatchBadge(
              label: 'live - 6h left',
              tone: CatchBadgeTone.live,
              uppercase: true,
            ),
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

  testWidgets('CatchActivityChip renders soft and primary activity registers', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        Wrap(
          children: [
            const CatchActivityChip(activityKind: ActivityKind.socialRun),
            CatchActivityChip(
              activityKind: ActivityKind.pickleball,
              primary: true,
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

  testWidgets('CatchSection section variant renders row variants', (
    tester,
  ) async {
    var toggleValue = false;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchSection.divided(
            title: 'Account',
            first: true,
            children: [
              CatchField.nav(
                icon: CatchIcons.personOutlineRounded,
                title: 'Aanya',
                body: 'Name',
                onTap: () {},
              ),
              const CatchField.add(title: '+ Add bio'),
              CatchField.toggle(
                title: 'Visible',
                value: toggleValue,
                onChanged: (value) => setState(() => toggleValue = value),
              ),
              CatchField.read(
                icon: CatchIcons.deleteOutline,
                title: 'Delete account',
                tone: CatchFieldTone.danger,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Aanya'), findsOneWidget);
    expect(find.text('+ Add bio'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.byType(CatchKicker), findsOneWidget);
    expect(find.bySemanticsLabel('Visible'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catch-field-toggle')));
    await tester.pump();

    expect(toggleValue, isTrue);
  });

  testWidgets('CatchSection composes the shared kicker leaf', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.divided(
          title: 'Why you might click',
          first: true,
          child: Text('Body copy'),
        ),
      ),
    );

    expect(find.byType(CatchKicker), findsOneWidget);
    expect(find.text('WHY YOU MIGHT CLICK'), findsOneWidget);
    expect(find.text('Body copy'), findsOneWidget);
  });

  testWidgets('CatchSectionStack lets Section own the handoff rhythm', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSectionStack(
          children: [
            CatchSection.divided(
              title: 'First',
              first: true,
              child: Text('First body'),
            ),
            CatchSection.divided(title: 'Second', child: Text('Second body')),
          ],
        ),
      ),
    );

    final stack = tester.widget<CatchSectionStack>(
      find.byType(CatchSectionStack),
    );

    expect(stack.gap, 0);
    expect(stack.padding, CatchInsets.pageBody);
    expect(find.byType(Divider), findsNothing);
    expect(find.text('SECOND'), findsOneWidget);
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

  testWidgets('CatchSection accents only a lead activity section', (
    tester,
  ) async {
    late Color activityAccent;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            activityAccent = ActivityPalette.resolve(
              context,
              ActivityKind.socialRun,
            ).accent;
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSection.divided(
                  title: 'The plan',
                  activityKind: ActivityKind.socialRun,
                  lead: true,
                  first: true,
                  child: Text('Lead body'),
                ),
                CatchSection.divided(
                  title: 'Details',
                  activityKind: ActivityKind.socialRun,
                  child: Text('Neutral body'),
                ),
              ],
            );
          },
        ),
      ),
    );

    final lead = tester.widget<Text>(find.text('THE PLAN'));
    final neutral = tester.widget<Text>(find.text('DETAILS'));
    expect(lead.style?.color, activityAccent);
    expect(neutral.style?.color, CatchTokens.editorialLight.ink);
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
              CatchCornerSash(
                label: 'Saved',
                icon: CatchIcons.saved,
                tone: CatchSashTone.success,
              ),
              gapH12,
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

    expect(find.text('Saved'), findsOneWidget);
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

  testWidgets('CatchSection contained renders title and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.contained(
          title: 'Profile strength',
          subtitle: '3 of 7 profile basics complete',
          trailing: Text('28%'),
          child: Text('Section body'),
        ),
      ),
    );

    expect(find.text('Profile strength'), findsOneWidget);
    expect(find.text('3 of 7 profile basics complete'), findsOneWidget);
    expect(find.text('28%'), findsOneWidget);
    expect(find.text('Section body'), findsOneWidget);
    expect(find.text('PROFILE STRENGTH'), findsNothing);
    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.role, CatchSurfaceRole.card);
    expect(surface.elevation, CatchSurfaceElevation.card);
  });

  testWidgets(
    'CatchSection contained field rows keep header and footer inside the card',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.containedFieldRows(
              title: 'Where',
              count: '2 OF 4',
              trailing: Text('Ready'),
              footer: Text('Attendees see this on event cards.'),
              children: [CatchField.read(title: 'Location', body: 'Bandra')],
            ),
          ),
        ),
      );

      final surfaceFinder = find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final surfaceRect = tester.getRect(surfaceFinder);
      final titleRect = tester.getRect(find.text('WHERE'));
      final countRect = tester.getRect(find.text('2 OF 4'));
      final trailingRect = tester.getRect(find.text('Ready'));
      final footerRect = tester.getRect(
        find.text('Attendees see this on event cards.'),
      );

      expect(find.text('Where · 2 OF 4'), findsNothing);
      expect(
        titleRect.left - surfaceRect.left,
        CatchStroke.hairline + CatchFieldTokens.rowHorizontalPadding,
      );
      expect(
        titleRect.top - surfaceRect.top,
        CatchStroke.hairline + CatchFieldTokens.sectionHeaderTopPadding,
      );
      expect(countRect.right, lessThan(trailingRect.left));
      expect(
        surfaceRect.right - trailingRect.right,
        CatchStroke.hairline + CatchFieldTokens.rowHorizontalPadding,
      );
      expect(
        surfaceRect.bottom - footerRect.bottom,
        CatchStroke.hairline + CatchFieldTokens.rowVerticalPadding,
      );
      expect(
        find.ancestor(
          of: find.text('Attendees see this on event cards.'),
          matching: find.byType(AnimatedContainer),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CatchSection headerless contained field rows start at the card edge',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            width: 360,
            child: CatchSection.containedFieldRows(
              children: [CatchField.read(title: 'Prompt 1', body: 'Answer')],
            ),
          ),
        ),
      );

      final surfaceRect = tester.getRect(
        find
            .descendant(
              of: find.byType(CatchSectionFocusSurface),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final fieldRect = tester.getRect(find.byType(CatchField));

      expect(fieldRect.top, surfaceRect.top + CatchStroke.hairline);
    },
  );

  testWidgets('CatchSection contained reflects descendant focus', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(CatchSection.contained(child: TextField(focusNode: focusNode))),
    );

    focusNode.requestFocus();
    await tester.pump();

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.borderColor, CatchTokens.editorialLight.primary);
    expect(
      surface.boxShadow,
      CatchElevation.focusRing(CatchTokens.editorialLight),
    );
  });

  testWidgets(
    'CatchSection contained field rows leave descendant focus to the field',
    (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _wrap(
          CatchSection.containedFieldRows(
            child: TextField(focusNode: focusNode),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      final surface = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(CatchSectionFocusSurface),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = surface.foregroundDecoration! as BoxDecoration;
      expect(
        decoration.border,
        Border.all(color: CatchTokens.editorialLight.line2),
      );
    },
  );

  testWidgets('CatchSection contained field rows honor explicit focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.containedFieldRows(
          focused: true,
          child: Text('Section body'),
        ),
      ),
    );

    final surface = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final decoration = surface.foregroundDecoration! as BoxDecoration;
    expect(
      decoration.border,
      Border.all(color: CatchTokens.editorialLight.ink),
    );

    await tester.pumpWidget(
      _wrap(
        const CatchSection.containedFieldRows(
          focused: true,
          hasError: true,
          child: Text('Section body'),
        ),
      ),
    );
    final errorSurface = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(CatchSectionFocusSurface),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final errorDecoration = errorSurface.foregroundDecoration! as BoxDecoration;
    expect(
      errorDecoration.border,
      Border.all(color: CatchTokens.editorialLight.danger),
    );
  });

  testWidgets(
    'CatchSection contained perimeter paints above active edge fields',
    (tester) async {
      Future<void> pump({required bool firstOpen}) {
        return tester.pumpWidget(
          _wrap(
            SizedBox(
              width: 360,
              child: CatchSection.containedFieldRows(
                children: [
                  CatchField.control(
                    title: 'Prompt',
                    body: 'Question',
                    open: firstOpen,
                    onOpenChanged: (_) {},
                    control: const Text('Question choices'),
                  ),
                  CatchField.control(
                    title: 'Answer',
                    body: 'Response',
                    open: !firstOpen,
                    onOpenChanged: (_) {},
                    control: const Text('Answer editor'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      for (final firstOpen in [true, false]) {
        await pump(firstOpen: firstOpen);
        final surface = tester.widget<AnimatedContainer>(
          find
              .descendant(
                of: find.byType(CatchSectionFocusSurface),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final background = surface.decoration! as BoxDecoration;
        final perimeter = surface.foregroundDecoration! as BoxDecoration;

        expect(background.border, isNull);
        expect(
          perimeter.border,
          Border.all(color: CatchTokens.editorialLight.line2),
        );
      }
    },
  );

  testWidgets(
    'CatchSection contained renders field rows flush to card padding',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: CatchSection.contained(
              child: CatchField.read(
                title: 'Notifications',
                valueText: 'On',
                icon: CatchIcons.helpOutline,
              ),
            ),
          ),
        ),
      );

      final surfaceRect = tester.getRect(find.byType(CatchSurface));
      final iconRect = tester.getRect(find.byIcon(CatchIcons.helpOutline));
      final labelLeft = tester.getTopLeft(find.text('Notifications')).dx;
      final valueRight = tester.getTopRight(find.text('On')).dx;

      expect(iconRect.left, closeTo(surfaceRect.left + CatchSpacing.s4, 0.1));
      expect(
        labelLeft,
        closeTo(
          surfaceRect.left + CatchSpacing.s4 + CatchFieldRow.textLaneInset,
          0.1,
        ),
      );
      expect(valueRight, closeTo(surfaceRect.right - CatchSpacing.s4, 0.1));
    },
  );

  testWidgets('CatchSection contained error owns the danger state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchSection.contained(
          focused: true,
          hasError: true,
          child: Text('Section body'),
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.borderColor, CatchTokens.editorialLight.danger);
    expect(surface.boxShadow, isNull);
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

  testWidgets('CatchErrorState hides retry UI for non-retryable errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchErrorState.fromError(
          const ValidationException('Please enter a valid phone number.'),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Check your details'), findsOneWidget);
    expect(
      find.text('Check the highlighted details and try again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
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

  testWidgets('CatchAsyncValueView uses branded default error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchAsyncValueView<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          data: (value) => Text('$value'),
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
          data: (value) => Text('$value'),
          loadingBuilder: (context) => const Text('Loading custom state'),
        ),
      ),
    );

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

  testWidgets('CatchField can render control content expanded on first build', (
    tester,
  ) async {
    final controlKey = GlobalKey();
    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Capacity',
          body: '24 seats',
          initiallyOpen: true,
          control: SizedBox(
            key: controlKey,
            child: const Text('Capacity choices'),
          ),
        ),
      ),
    );

    expect(find.text('Capacity choices'), findsOneWidget);
    final controlElement = tester.element(find.byKey(controlKey));

    await tester.tap(find.byType(CatchField));
    await _pumpCatchFieldMotion(tester);

    expect(find.text('Capacity choices'), findsNothing);
    expect(
      tester.element(find.byKey(controlKey, skipOffstage: false)),
      same(controlElement),
    );

    await tester.tap(find.byType(CatchField));
    await _pumpCatchFieldMotion(tester);

    expect(find.text('Capacity choices').hitTestable(), findsOneWidget);
    expect(tester.element(find.byKey(controlKey)), same(controlElement));
  });

  testWidgets('CatchField preserves the last state when control is released', (
    tester,
  ) async {
    var controlled = true;
    late VoidCallback releaseControl;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            releaseControl = () => setState(() => controlled = false);
            return CatchField.control(
              title: 'Capacity',
              open: controlled ? true : null,
              onOpenChanged: (_) {},
              control: const Text('Capacity choices'),
            );
          },
        ),
      ),
    );

    expect(find.text('Capacity choices').hitTestable(), findsOneWidget);

    releaseControl();
    await tester.pump();

    expect(find.text('Capacity choices').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Capacity'));
    await _pumpCatchFieldMotion(tester);

    expect(find.text('Capacity choices'), findsNothing);
    expect(find.text('Capacity choices', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField closed control subtree cannot retain focus', (
    tester,
  ) async {
    final controlFocus = FocusNode();
    addTearDown(controlFocus.dispose);
    var open = true;
    late void Function(bool value) setOpen;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            setOpen = (value) => setState(() => open = value);
            return CatchField.control(
              title: 'Age range',
              open: open,
              onOpenChanged: setOpen,
              control: TextField(focusNode: controlFocus),
            );
          },
        ),
      ),
    );

    controlFocus.requestFocus();
    await tester.pump();
    expect(controlFocus.hasFocus, isTrue);

    setOpen(false);
    await tester.pump();
    expect(controlFocus.hasFocus, isFalse);

    await _pumpCatchFieldMotion(tester);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextField, skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField keeps open active chrome while saving', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.control(
          title: 'Height',
          body: '168 cm',
          open: true,
          isLoading: true,
          control: Text('Height control'),
        ),
      ),
    );

    final activeOverlay = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('catch-field-active-overlay')),
    );
    final decoration = activeOverlay.decoration! as BoxDecoration;

    expect(decoration.color, isNot(Colors.transparent));
    expect(decoration.boxShadow, isNotEmpty);
    expect(
      tester
          .widget<FocusableActionDetector>(find.byType(FocusableActionDetector))
          .enabled,
      isFalse,
    );
  });

  testWidgets('CatchField choices wrap and report caller-owned selection', (
    tester,
  ) async {
    Set<String>? nextSelection;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 280,
          child: CatchField.choices<String>(
            title: 'Languages',
            body: 'English',
            values: const ['English', 'Hindi', 'Marathi', 'Gujarati'],
            itemLabel: (value) => value,
            selected: const {'English'},
            multi: true,
            initiallyOpen: true,
            onSelectionChanged: (selection) => nextSelection = selection,
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    final chipTops = [
      for (final label in const ['English', 'Hindi', 'Marathi', 'Gujarati'])
        tester.getTopLeft(find.byKey(ValueKey('catch-field-choice-$label'))).dy,
    ];
    expect(chipTops.toSet().length, greaterThan(1));
    final englishRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-choice-English')),
    );
    expect(
      englishRect.height,
      closeTo(CatchFieldTokens.chipVisualMinHeight, 2.1),
    );
    final fieldRect = tester.getRect(find.byType(CatchField));
    final controlRect = tester.getRect(
      find.byWidgetPredicate((widget) => widget is CatchFieldChoiceControl),
    );
    expect(
      controlRect.right,
      closeTo(fieldRect.right - CatchFieldTokens.rowHorizontalPadding, 0.1),
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Hindi')));
    expect(nextSelection, const {'English', 'Hindi'});
  });

  testWidgets('CatchField choices derives its multi summary in option order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Languages',
          values: const ['English', 'Hindi', 'Marathi'],
          itemLabel: (value) => value,
          selected: const {'Marathi', 'English'},
          multi: true,
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.text('English · Marathi'), findsOneWidget);
    expect(find.text('Marathi · English'), findsNothing);
    expect(find.textContaining(','), findsNothing);
  });

  testWidgets('CatchField choices preserves an explicit body override', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Distances',
          body: '5K and beyond',
          values: const ['5K', '10K'],
          itemLabel: (value) => value,
          selected: const {'5K', '10K'},
          multi: true,
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.text('5K and beyond'), findsOneWidget);
    expect(find.text('5K · 10K'), findsNothing);
  });

  testWidgets('CatchField clearable choice does not imply Optional copy', (
    tester,
  ) async {
    var selected = <String>{'Indore'};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.choices<String>(
            title: 'City',
            values: const ['Indore', 'Mumbai'],
            itemLabel: (value) => value,
            selected: selected,
            allowEmptySelection: true,
            initiallyOpen: true,
            onSelectionChanged: (next) => setState(() => selected = next),
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Optional'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Indore')));
    await tester.pump();
    expect(selected, isEmpty);
    expect(find.textContaining('Optional'), findsNothing);
  });

  testWidgets('CatchField required multi choice preserves its final value', (
    tester,
  ) async {
    Set<String>? reported;

    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Languages',
          values: const ['English', 'Hindi'],
          itemLabel: (value) => value,
          selected: const {'English'},
          multi: true,
          initiallyOpen: true,
          onSelectionChanged: (next) => reported = next,
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-choice-English')));
    await tester.pump();
    expect(reported, isNull);
  });

  testWidgets('CatchField action bar shares the trailing edge and baseline', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchField.choices<String>(
            icon: CatchIcons.translateRounded,
            title: 'Languages',
            body: 'English · Hindi',
            values: const ['English', 'Hindi'],
            itemLabel: (value) => value,
            selected: const {'English', 'Hindi'},
            multi: true,
            initiallyOpen: true,
            onSelectionChanged: (_) {},
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final cancelRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-cancel')),
    );
    final doneRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-done')),
    );
    final caretRect = tester.getRect(find.byIcon(CatchIcons.expandMoreRounded));

    expect(
      doneRect.right,
      closeTo(fieldRect.right - CatchFieldTokens.rowHorizontalPadding, 0.1),
    );
    expect(doneRect.right, closeTo(caretRect.right, 0.1));
    expect(doneRect.left - cancelRect.right, CatchFieldTokens.actionButtonGap);
    expect(doneRect.top, cancelRect.top);
    expect(doneRect.bottom, cancelRect.bottom);
    expect(
      fieldRect.bottom - doneRect.bottom,
      closeTo(CatchFieldTokens.rowVerticalPadding, 0.1),
    );
  });

  testWidgets('CatchField divided action bar reaches the flush trailing edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            title: 'About you',
            children: [
              CatchField.choices<String>(
                icon: CatchIcons.translateRounded,
                title: 'Languages',
                values: const ['English', 'Hindi'],
                itemLabel: (value) => value,
                selected: const {'English'},
                multi: true,
                initiallyOpen: true,
                onSelectionChanged: (_) {},
                onCancel: () {},
                onSubmit: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final actionBarRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-action-bar')),
    );
    final doneRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-done')),
    );
    final caretRect = tester.getRect(find.byIcon(CatchIcons.expandMoreRounded));

    expect(actionBarRect.right, fieldRect.right);
    expect(doneRect.right, fieldRect.right);
    expect(doneRect.right, caretRect.right);
  });

  testWidgets('CatchField nav preserves explicit chevron visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            CatchField.nav(
              title: 'Hidden chevron',
              showChevron: false,
              onTap: () {},
            ),
            const CatchField.nav(title: 'Visible chevron', showChevron: true),
          ],
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.chevronRightRounded), findsOneWidget);
  });

  testWidgets('CatchField actions uses the canonical oriented commit bar', (
    tester,
  ) async {
    var cancelled = false;
    var submitted = false;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchField.actions(
            title: 'Club name',
            body: 'Catch Run Club',
            initiallyExpanded: true,
            control: const Text('Editor control'),
            actionLeading: const Text('12 / 80'),
            onCancel: () => cancelled = true,
            onSubmit: () => submitted = true,
          ),
        ),
      ),
    );

    final leadingRect = tester.getRect(find.text('12 / 80'));
    final cancelRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-cancel')),
    );
    final doneRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-done')),
    );

    expect(leadingRect.left, lessThan(cancelRect.left));
    expect(doneRect.left - cancelRect.right, CatchFieldTokens.actionButtonGap);
    expect(doneRect.top, cancelRect.top);
    expect(doneRect.bottom, cancelRect.bottom);

    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    expect(submitted, isTrue);
    await _pumpCatchFieldMotion(tester);
    expect(find.text('Editor control').hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-cancel')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catch-field-cancel')));
    expect(cancelled, isTrue);
    await _pumpCatchFieldMotion(tester);
    expect(find.text('Editor control'), findsNothing);
  });

  testWidgets('CatchField stepper reports bounded changes', (tester) async {
    num value = 168;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.stepper(
            title: 'Height',
            body: '$value cm',
            value: value,
            min: 167,
            max: 169,
            step: 2,
            unit: 'cm',
            initiallyOpen: true,
            decreaseSemanticLabel: 'Decrease height',
            increaseSemanticLabel: 'Increase height',
            onChanged: (next) => setState(() => value = next),
            onCancel: () {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Increase height'));
    await tester.pump();
    expect(value, 169);
    expect(find.text('169 cm'), findsNWidgets(2));
    final decreaseVisual = tester.getRect(
      find.byKey(const ValueKey('catch-field-stepper-Decrease height-visual')),
    );
    final stepperValue = tester.getRect(
      find.byKey(const ValueKey('catch-field-stepper-value')),
    );
    expect(
      stepperValue.left - decreaseVisual.right,
      closeTo(CatchFieldTokens.stepperGap, 0.1),
    );

    final increase = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.byIcon(CatchIcons.addRounded),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(increase.properties.enabled, isFalse);
  });

  testWidgets('CatchField exposes saving and saved trailing status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.control(
          title: 'Height',
          body: '168 cm',
          open: true,
          status: CatchFieldStatus.saved,
          control: Text('Height control'),
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        const CatchField.control(
          title: 'Height',
          body: '168 cm',
          open: true,
          status: CatchFieldStatus.saving,
          control: Text('Height control'),
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.text('Saving…'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('catch-field-done'))).height,
      34,
    );
  });

  testWidgets('CatchField single choice closes after the handoff delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'City',
          values: const ['Indore', 'Mumbai'],
          itemLabel: (value) => value,
          selected: const {'Indore'},
          onSelectionChanged: (_) {},
          initiallyOpen: true,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-choice-Mumbai')));
    await tester.pump(
      CatchFieldTokens.singleChoiceCloseDelay - CatchFieldTokens.fast,
    );
    expect(find.text('Mumbai').hitTestable(), findsOneWidget);

    await tester.pump(CatchFieldTokens.fast);
    await _pumpCatchFieldMotion(tester);
    expect(find.text('Mumbai'), findsNothing);
  });

  testWidgets('CatchField optional add choice is one primary line at rest', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.choices<String>(
          title: 'Religion',
          values: const ['Hindu', 'Muslim'],
          itemLabel: (value) => value,
          selected: const {},
          onSelectionChanged: (_) {},
          addable: true,
          isOptional: true,
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    expect(find.text('Add religion · Optional'), findsOneWidget);
    expect(find.text('Religion'), findsNothing);

    await tester.tap(find.text('Add religion · Optional'));
    await _pumpCatchFieldMotion(tester);
    expect(find.text('Religion · Optional'), findsOneWidget);
    expect(find.text('Hindu'), findsOneWidget);
  });

  testWidgets('CatchField toggle stays visible and disabled while saving', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      _wrap(
        CatchField.toggle(
          title: 'Show my pace',
          value: true,
          status: CatchFieldStatus.saving,
          onChanged: (_) => changes++,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('catch-field-toggle')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catch-field-toggle')));
    await tester.tap(find.text('Show my pace'));
    expect(changes, 0);
  });

  testWidgets('CatchField local control cancel closes before callback', (
    tester,
  ) async {
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          control: const Text('Height control'),
          onCancel: () => cancelCount++,
          onSubmit: () {},
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await _pumpCatchFieldMotion(tester);

    expect(cancelCount, 1);
    expect(find.text('Height control'), findsNothing);
    expect(find.text('Height control', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField local control Done submits and closes', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(find.text('Done'));
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 1);
    expect(find.text('Height control'), findsNothing);
    expect(find.text('Height control', skipOffstage: false), findsOneWidget);
  });

  testWidgets('CatchField controlled Done leaves disclosure parent-owned', (
    tester,
  ) async {
    var submitCount = 0;
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          open: true,
          onOpenChanged: openChanges.add,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(find.text('Done'));
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 1);
    expect(openChanges, isEmpty);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets('CatchField control blank space does not toggle its row', (
    tester,
  ) async {
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          onOpenChanged: openChanges.add,
          control: const SizedBox(height: 80, child: Text('Height control')),
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    final barrierRect = tester.getRect(
      find.byKey(const ValueKey('catch-field-control-tap-barrier')),
    );
    await tester.tapAt(Offset(barrierRect.left + 4, barrierRect.top + 60));
    await _pumpCatchFieldMotion(tester);

    expect(openChanges, isEmpty);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets('CatchField control keyboard events do not toggle its row', (
    tester,
  ) async {
    final controlFocus = FocusNode();
    addTearDown(controlFocus.dispose);
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          open: true,
          onOpenChanged: openChanges.add,
          control: Focus(
            focusNode: controlFocus,
            child: const SizedBox(height: 44, child: Text('Height control')),
          ),
        ),
      ),
    );

    controlFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await _pumpCatchFieldMotion(tester);

    expect(openChanges, isEmpty);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets('CatchField saving Done cannot submit or close local control', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          isLoading: true,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('catch-field-done')),
      warnIfMissed: false,
    );
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 0);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets('CatchField local control reports open and cancel changes', (
    tester,
  ) async {
    final openChanges = <bool>[];

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          control: const Text('Height control'),
          onOpenChanged: openChanges.add,
          onCancel: () {},
          onSubmit: () {},
        ),
      ),
    );

    await tester.tap(find.text('Height'));
    await _pumpCatchFieldMotion(tester);
    expect(openChanges, <bool>[true]);

    await tester.tap(find.text('Cancel'));
    await _pumpCatchFieldMotion(tester);
    expect(openChanges, <bool>[true, false]);
  });

  testWidgets('CatchField control cancels after an outside pointer is lifted', (
    tester,
  ) async {
    var open = true;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              CatchField.control(
                title: 'Height',
                open: open,
                onOpenChanged: (value) => setState(() => open = value),
                control: const Text('Height control'),
                onCancel: () {
                  cancelCount++;
                  setState(() => open = false);
                },
                onSubmit: () {},
              ),
              const SizedBox(height: 80),
              const Text('Outside target'),
            ],
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Outside target')),
    );
    await tester.pump();

    expect(open, isTrue);
    expect(cancelCount, 0);

    await gesture.up();
    await tester.pump();

    expect(open, isFalse);
    expect(cancelCount, 1);
  });

  testWidgets('CatchField control stays open after an outside drag', (
    tester,
  ) async {
    var open = true;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              CatchField.control(
                title: 'Height',
                open: open,
                onOpenChanged: (value) => setState(() => open = value),
                control: const Text('Height control'),
                onCancel: () {
                  cancelCount++;
                  setState(() => open = false);
                },
                onSubmit: () {},
              ),
              const SizedBox(height: 120),
              const Text('Outside drag target'),
            ],
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Outside drag target')),
    );
    await gesture.moveBy(const Offset(48, 0));
    await gesture.up();
    await tester.pump();

    expect(open, isTrue);
    expect(cancelCount, 0);
  });

  testWidgets('CatchField ignores Escape while an explicit save is loading', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Saving value');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var open = true;
    var openChanges = 0;
    var cancelCount = 0;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => CatchField.inputActions(
            title: 'Prompt',
            controller: controller,
            focusNode: focusNode,
            open: open,
            onOpenChanged: (value) {
              openChanges++;
              setState(() => open = value);
            },
            onCancel: () {
              cancelCount++;
              setState(() => open = false);
            },
            onSubmit: () {},
            isLoading: true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(open, isTrue);
    expect(openChanges, 0);
    expect(cancelCount, 0);
  });

  testWidgets('CatchField toggle centers its leading, text, and switch', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CatchField.toggle(
          icon: CatchIcons.visibilityOutlined,
          title: 'Show my pace on my profile',
          value: true,
          onChanged: (_) {},
        ),
      ),
    );

    final iconCenter = tester.getCenter(
      find.byIcon(CatchIcons.visibilityOutlined),
    );
    final labelCenter = tester.getCenter(
      find.text('Show my pace on my profile'),
    );
    final toggleCenter = tester.getCenter(
      find.byKey(const ValueKey('catch-field-toggle')),
    );

    expect(iconCenter.dy, closeTo(labelCenter.dy, 0.5));
    expect(toggleCenter.dy, closeTo(labelCenter.dy, 0.5));
  });

  testWidgets('CatchField derives trailing affordances from field capability', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatchField.read(title: 'Date of birth', body: '16/07/1994'),
            CatchField.nav(title: 'City', body: 'Indore', onTap: () {}),
            CatchField.input(
              icon: CatchIcons.personOutlined,
              title: 'Display name',
              initialValue: 'Suvrat',
            ),
            CatchField.input(
              icon: CatchIcons.cakeOutlined,
              title: 'Locked value',
              initialValue: 'Fixed',
              readOnly: true,
            ),
            CatchField.action(
              title: 'Notification',
              body: 'Starts tomorrow',
              action: const Text('2H'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.chevronRightRounded), findsOneWidget);
    expect(find.byIcon(CatchIcons.expandMoreRounded), findsNothing);
  });

  testWidgets('CatchField explicit-save expansion animates through height', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Catch me if you can');
    addTearDown(controller.dispose);
    var expanded = false;
    late void Function(bool value) setExpanded;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            setExpanded = (value) => setState(() => expanded = value);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 360,
                child: CatchField.inputActions(
                  icon: CatchIcons.formatQuoteRounded,
                  title: 'A perfect event with me looks like...',
                  controller: controller,
                  open: expanded,
                  onOpenChanged: setExpanded,
                  supporting: const Text('19 / 300'),
                  secondaryAction: const Text('Change prompt'),
                  onCancel: () => setExpanded(false),
                  onSubmit: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    final field = find.byType(CatchField);
    final collapsedHeight = tester.getSize(field).height;
    final anchoredTop = tester.getTopLeft(field).dy;

    setExpanded(true);
    await tester.pump();
    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final midpointHeight = tester.getSize(field).height;
    expect(midpointHeight, greaterThan(collapsedHeight));

    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final expandedHeight = tester.getSize(field).height;
    expect(midpointHeight, lessThan(expandedHeight));
    expect(tester.getTopLeft(field).dy, anchoredTop);

    setExpanded(false);
    await tester.pump();
    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    final collapsingHeight = tester.getSize(field).height;
    expect(collapsingHeight, greaterThan(collapsedHeight));
    expect(collapsingHeight, lessThan(expandedHeight));

    await tester.pump(
      Duration(milliseconds: CatchFieldTokens.reveal.inMilliseconds ~/ 2),
    );
    await tester.pump();
    expect(tester.getSize(field).height, collapsedHeight);
    expect(tester.getTopLeft(field).dy, anchoredTop);
  });

  testWidgets('CatchField explicit-save preserves label metrics and order', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Catch me if you can');
    addTearDown(controller.dispose);
    var expanded = false;
    late void Function(bool value) setExpanded;

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            setExpanded = (value) => setState(() => expanded = value);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 360,
                child: CatchField.inputActions(
                  title: 'A perfect event with me looks like...',
                  controller: controller,
                  open: expanded,
                  onOpenChanged: setExpanded,
                  supporting: const Text('19 / 300'),
                  secondaryAction: const Text('Change prompt'),
                  onCancel: () => setExpanded(false),
                  onSubmit: () {},
                ),
              ),
            );
          },
        ),
      ),
    );

    final labelFinder = find.text('A perfect event with me looks like...');
    final collapsedLabel = tester.widget<Text>(labelFinder);
    final collapsedRect = tester.getRect(labelFinder);

    setExpanded(true);
    await tester.pump();
    await tester.pump(CatchMotion.base);
    await tester.pump();

    final focusedLabel = tester.widget<Text>(labelFinder);
    final focusedRect = tester.getRect(labelFinder);
    expect(focusedLabel.style?.fontSize, collapsedLabel.style?.fontSize);
    expect(focusedLabel.style?.fontWeight, collapsedLabel.style?.fontWeight);
    expect(focusedLabel.style?.height, collapsedLabel.style?.height);
    expect(
      focusedLabel.style?.letterSpacing,
      collapsedLabel.style?.letterSpacing,
    );
    expect(focusedRect.topLeft, collapsedRect.topLeft);

    final answerBottom = tester.getBottomLeft(find.byType(EditableText)).dy;
    final counterTop = tester.getTopLeft(find.text('19 / 300')).dy;
    final secondaryTop = tester.getTopLeft(find.text('Change prompt')).dy;
    final cancelTop = tester.getTopLeft(find.text('Cancel')).dy;
    final doneTop = tester.getTopLeft(find.text('Done')).dy;
    expect(answerBottom, lessThan(counterTop));
    expect(counterTop, lessThan(secondaryTop));
    expect(secondaryTop, lessThan(cancelTop));
    expect(secondaryTop, lessThan(doneTop));
  });

  testWidgets('CatchField renders canonical row content and action slot', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        CatchField.nav(
          icon: CatchIcons.personOutlined,
          title: 'Display name',
          body: 'Shown on your profile and event rosters',
          action: const Text('Edit'),
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.personOutlined), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(
      find.text('Shown on your profile and event rosters'),
      findsOneWidget,
    );
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byIcon(CatchIcons.chevronRightRounded), findsOneWidget);

    await tester.tap(find.byType(CatchField));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CatchField row fills loose bounded parent width', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: Align(
            alignment: Alignment.topLeft,
            child: CatchField.nav(
              icon: CatchIcons.personOutlined,
              title: 'Display name',
              body: 'Shown on your profile and event rosters',
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    expect(fieldRect.width, 360);

    await tester.tapAt(Offset(fieldRect.right - 4, fieldRect.center.dy));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CatchField tappable rows own full-width tokenized ink', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchSection.fieldRows(
            first: true,
            title: 'Today',
            children: [
              CatchField.action(
                icon: CatchIcons.notificationsNoneRounded,
                title: 'Event starts tomorrow',
                body: 'Sundowner 5K meets at Carter Road Jetty.',
                action: const Text('2H'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final overlayFinder = find.descendant(
      of: find.byType(CatchField),
      matching: find.byKey(
        const ValueKey<String>('catch-field-active-overlay'),
      ),
    );
    final overlayRect = tester.getRect(overlayFinder);

    expect(overlayRect.left, fieldRect.left - CatchFieldTokens.dividedRowBleed);
    expect(
      overlayRect.right,
      fieldRect.right + CatchFieldTokens.dividedRowBleed,
    );

    final iconRect = tester.getRect(
      find.byIcon(CatchIcons.notificationsNoneRounded),
    );
    final titleLeft = tester.getTopLeft(find.text('Event starts tomorrow')).dx;
    expect(iconRect.left, fieldRect.left);
    expect(titleLeft - fieldRect.left, CatchFieldRow.textLaneInset);

    final gesture = await tester.startGesture(
      Offset(fieldRect.right - 4, fieldRect.center.dy),
    );
    await tester.pump();

    final overlay = tester.widget<AnimatedContainer>(overlayFinder);
    final pressedDecoration = overlay.decoration! as BoxDecoration;
    expect(
      pressedDecoration.color,
      CatchFieldTokens.pressedSurface(CatchTokens.editorialLight),
    );
    expect(pressedDecoration.border, isNotNull);

    await gesture.up();
    await tester.pump();
    await tester.pump(CatchFieldTokens.pressOut);

    final releasedOverlay = tester.widget<AnimatedContainer>(overlayFinder);
    final releasedDecoration = releasedOverlay.decoration! as BoxDecoration;
    expect(releasedDecoration.color, Colors.transparent);
    expect(releasedDecoration.border, isNull);
  });

  testWidgets('CatchField press chrome ignores secondary taps and drag exits', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 360,
          child: CatchField.action(
            title: 'Interactive row',
            onTap: () => taps++,
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(CatchField));
    final overlayFinder = find.byKey(
      const ValueKey<String>('catch-field-active-overlay'),
    );

    await tester.sendEventToBinding(
      PointerDownEvent(
        pointer: 41,
        position: fieldRect.center,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      ),
    );
    await tester.pump();
    var decoration =
        tester.widget<AnimatedContainer>(overlayFinder).decoration!
            as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect(decoration.border, isNull);
    await tester.sendEventToBinding(
      PointerUpEvent(
        pointer: 41,
        position: fieldRect.center,
        kind: PointerDeviceKind.mouse,
      ),
    );

    final gesture = await tester.startGesture(fieldRect.center);
    await tester.pump();
    await gesture.moveBy(const Offset(kTouchSlop + 8, 0));
    await tester.pump();
    decoration =
        tester.widget<AnimatedContainer>(overlayFinder).decoration!
            as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect(decoration.border, isNull);
    await gesture.up();
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('CatchField renders label, helper text, changes, and errors', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    var latestValue = '';

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.input(
            title: 'Event title',
            placeholder: 'Short and memorable',
            helperText: 'Shows on event cards',
            validator: (value) =>
                value == null || value.isEmpty ? "Title can't be empty" : null,
            onChanged: (value) => latestValue = value,
          ),
        ),
      ),
    );

    expect(find.text('Event title'), findsOneWidget);
    expect(find.text('Short and memorable'), findsNothing);
    expect(find.text('Shows on event cards'), findsOneWidget);

    await tester.tap(find.text('Event title'));
    await tester.pump();
    await tester.pump(CatchMotion.fast);
    expect(find.text('Short and memorable'), findsOneWidget);
    expect(find.text('Shows on event cards'), findsOneWidget);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text("Title can't be empty"), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sunrise Seawall 7K');
    await tester.pump();
    expect(latestValue, 'Sunrise Seawall 7K');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('CatchField exposes a keyboard done action by default', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Asha');
    addTearDown(controller.dispose);
    var submitted = '';

    await tester.pumpWidget(
      _wrap(
        CatchField.input(
          title: 'Name',
          controller: controller,
          onSubmitted: (value) => submitted = value,
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.textInputAction, TextInputAction.done);
    expect(editableText.focusNode.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 'Asha');
    expect(editableText.focusNode.hasFocus, isFalse);
  });

  testWidgets('CatchField syncs external controller edits into validation', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.input(
            title: 'Date of birth',
            controller: controller,
            readOnly: true,
            onTap: () => controller.text = '15/04/1997',
            validator: (value) =>
                value == null || value.isEmpty ? 'Pick a date' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);

    await tester.tap(find.text('Date of birth'));
    await tester.pump();

    expect(controller.text, '15/04/1997');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('CatchField keeps non-actionable read-only fields out of focus', (
    tester,
  ) async {
    final controller = TextEditingController(text: '+91 9876543210');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        CatchField.input(
          title: 'Mobile number',
          controller: controller,
          readOnly: true,
          helperText: 'Verified via OTP',
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));

    expect(editableText.readOnly, isTrue);
    expect(editableText.focusNode.hasFocus, isFalse);
  });

  testWidgets('CatchField error renders once with danger label styling', (
    tester,
  ) async {
    const error = 'Use a six character invite code.';

    await tester.pumpWidget(
      _wrap(
        const CatchField.input(
          title: 'Invite code',
          initialValue: 'ABC',
          error: error,
        ),
      ),
    );

    expect(find.text(error), findsOneWidget);
    expect(find.byType(CatchControlShell), findsNothing);

    final label = tester.widget<Text>(find.text('Invite code'));
    expect(label.style?.color, CatchTokens.editorialLight.danger);
  });

  testWidgets('CatchField row counter appears on focus or error', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'ABC');
    addTearDown(controller.dispose);

    Widget field({String? error}) => _wrap(
      CatchField.input(
        title: 'Invite code',
        controller: controller,
        maxLength: 10,
        error: error,
      ),
    );

    await tester.pumpWidget(field());
    expect(find.text('3 / 10'), findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('3 / 10'), findsOneWidget);

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('3 / 10'), findsNothing);

    await tester.pumpWidget(field(error: 'Use a valid code.'));
    await tester.pump();
    expect(find.text('3 / 10'), findsOneWidget);
  });

  testWidgets('CatchField underline counter remains focus-only', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Hello');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        CatchField.input(
          title: 'Bio',
          controller: controller,
          variant: CatchFieldVariant.underline,
          maxLength: 20,
          error: 'Review this value.',
        ),
      ),
    );

    expect(find.text('5 / 20'), findsNothing);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('5 / 20'), findsOneWidget);

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('5 / 20'), findsNothing);
  });

  testWidgets('CatchField renders optional field marker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.input(
          title: 'Bio',
          isOptional: true,
          placeholder: 'Share a little about yourself',
        ),
      ),
    );

    expect(find.text('Bio · Optional'), findsOneWidget);
    expect(find.text('Bio'), findsNothing);
    expect(find.text('Optional'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Bio, optional',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'CatchField keeps empty native text entry mounted through focus',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Public name',
              controller: controller,
              inputHint: 'e.g. Aanya',
            ),
          ),
        ),
      );

      expect(find.text('Public name'), findsOneWidget);
      expect(find.text('Add public name'), findsOneWidget);
      expect(find.text('e.g. Aanya'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      final inputElement = tester.element(find.byType(TextField));

      await tester.tap(find.text('Add public name'));
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('e.g. Aanya'), findsOneWidget);

      var editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.focusNode.hasFocus, isTrue);

      await tester.enterText(find.byType(TextField), 'Aanya');
      await tester.pump();

      expect(controller.text, 'Aanya');
      editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.style.fontSize, 14);
      expect(editableText.style.fontWeight, FontWeight.w700);

      await tester.enterText(find.byType(TextField), '');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(controller.text, isEmpty);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('Public name'), findsOneWidget);
      expect(find.text('Add public name'), findsOneWidget);
    },
  );

  testWidgets('CatchField keeps labels out of focused input hints', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 320,
          child: CatchField.input(title: 'Instagram', inputHint: 'Instagram'),
        ),
      ),
    );

    expect(find.text('Add instagram'), findsOneWidget);
    await tester.tap(find.text('Add instagram'));
    await tester.pump();
    await tester.pump(CatchMotion.fast);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, isNull);
    expect(find.text('Instagram'), findsOneWidget);
  });

  testWidgets('CatchField collapsed text entry reports focus changes', (
    tester,
  ) async {
    final changes = <bool>[];

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Public name',
            inputHint: 'e.g. Aanya',
            onFocusChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Public name'));
    await tester.pump();
    await tester.pump(CatchMotion.fast);

    expect(changes, <bool>[true]);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(changes, <bool>[true, false]);
  });

  testWidgets(
    'CatchField expands collapsed text entry when validation fails before focus',
    (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: const SizedBox(
              width: 320,
              child: CatchField.input(
                title: 'Public name',
                inputHint: 'e.g. Aanya',
                validator: _requiredPublicName,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Public name'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      final inputElement = tester.element(find.byType(TextField));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.element(find.byType(TextField)), same(inputElement));
      expect(find.text('e.g. Aanya'), findsOneWidget);
      expect(find.text('Public name is required'), findsOneWidget);
    },
  );

  testWidgets(
    'CatchField expands initial text and collapses after external clear',
    (tester) async {
      final controller = TextEditingController(text: 'Aanya');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Public name',
              controller: controller,
              inputHint: 'e.g. Aanya',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      controller.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump(CatchMotion.fast);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Public name'), findsOneWidget);
      expect(find.text('Add public name'), findsOneWidget);
    },
  );

  testWidgets('CatchField clearable input uses the row trailing slot', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Run');
    addTearDown(controller.dispose);
    var latest = 'Run';

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Search hosts',
            controller: controller,
            showClearButton: true,
            suffixIcon: Icon(CatchIcons.search),
            onChanged: (value) => latest = value,
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(TextField));
    final clearRect = tester.getRect(find.byTooltip('Clear Search hosts'));

    expect(clearRect.left, greaterThan(fieldRect.right));

    await tester.tap(find.byTooltip('Clear Search hosts'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(latest, isEmpty);
    expect(find.byIcon(CatchIcons.search), findsOneWidget);
  });

  testWidgets('CatchField valid row renders success trailing state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.read(
          title: 'Invite code',
          body: 'RUNCLUB',
          valid: true,
        ),
      ),
    );

    final validIcon = tester.widget<Icon>(find.byIcon(CatchIcons.checkCircle));
    expect(validIcon.color, CatchTokens.editorialLight.success);
  });

  testWidgets('CatchField success helper uses success support color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.input(
          title: 'Invite code',
          initialValue: 'RUNCLUB',
          helperText: 'Invite code is available.',
          helperTone: CatchFieldSupportTone.success,
        ),
      ),
    );

    final helper = tester.widget<Text>(find.text('Invite code is available.'));
    expect(helper.style?.color, CatchTokens.editorialLight.success);
  });

  testWidgets('CatchField supports underline, action suffix, and mono data', (
    tester,
  ) async {
    final controller = TextEditingController(text: '42');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.input(
            title: 'Distance',
            controller: controller,
            variant: CatchFieldVariant.underline,
            textAlign: TextAlign.center,
            mono: true,
            focused: true,
            action: const Text('KM'),
          ),
        ),
      ),
    );

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    final shell = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(CatchField),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final decoration = shell.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(find.text('KM'), findsOneWidget);
    expect(editableText.textAlign, TextAlign.center);
    expect(
      editableText.style.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(border.bottom.width, CatchStroke.underline);
  });

  testWidgets(
    'CatchField disables field chrome animation when reduced motion is on',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SizedBox(
              width: 320,
              child: CatchField.input(
                title: 'Distance',
                initialValue: '42',
                variant: CatchFieldVariant.underline,
                focused: true,
              ),
            ),
          ),
        ),
      );

      final chrome = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(CatchField),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );

      expect(chrome.duration, Duration.zero);
    },
  );

  testWidgets(
    'CatchField disables expansion motion when reduced motion is on',
    (tester) async {
      final controller = TextEditingController(text: 'Answer');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: CatchField.inputActions(
              title: 'Prompt',
              controller: controller,
              open: true,
              onOpenChanged: (_) {},
              supporting: const Text('6 / 300'),
              onCancel: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      final expansion = tester.widget<TweenAnimationBuilder<double>>(
        find.byKey(const ValueKey('catch-field-expansion')),
      );
      expect(expansion.duration, Duration.zero);
    },
  );

  testWidgets('CatchField compact input centers hint and icon vertically', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Center(
          child: SizedBox(
            width: 320,
            child: CatchField.input(
              title: 'Search',
              showLabel: false,
              placeholder: 'Search by name',
              size: CatchFieldSize.compact,
              prefixIcon: Icon(CatchIcons.searchRounded, size: 18),
            ),
          ),
        ),
      ),
    );

    final fieldRect = tester.getRect(find.byType(TextField));
    final hintRect = tester.getRect(find.text('Search by name'));
    final iconRect = tester.getRect(find.byIcon(CatchIcons.searchRounded));

    expect(
      (hintRect.center.dy - fieldRect.center.dy).abs(),
      lessThanOrEqualTo(2),
    );
    expect(
      (iconRect.center.dy - fieldRect.center.dy).abs(),
      lessThanOrEqualTo(2),
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

  testWidgets('CatchField.select validates and reports selection changes', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    CityOption? selected;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            itemLabel: (city) => city.label,
            value: selected,
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
            validator: (value) => value == null ? 'Please select a city' : null,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    final iconRect = tester.getRect(find.byIcon(CatchIcons.locationOnOutlined));
    final titleRect = tester.getRect(find.text('City'));
    final valueRect = tester.getRect(find.text('Select city'));

    expect(iconRect.right, lessThan(titleRect.left));
    expect((titleRect.left - valueRect.left).abs(), lessThanOrEqualTo(1));

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please select a city'), findsOneWidget);

    final label = tester.widget<Text>(find.text('City'));
    final value = tester.widget<Text>(find.text('Select city'));
    final chevron = tester.widget<Icon>(
      find.byIcon(CatchIcons.expandMoreRounded),
    );
    final iconTheme = IconTheme.of(
      tester.element(find.byIcon(CatchIcons.locationOnOutlined)),
    );

    expect(label.style?.color, CatchTokens.editorialLight.danger);
    expect(value.style?.color, CatchTokens.editorialLight.ink3);
    expect(chevron.color, CatchTokens.editorialLight.ink3);
    expect(iconTheme.color, CatchTokens.editorialLight.ink2);

    await tester.tap(find.byIcon(CatchIcons.expandMoreRounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Mumbai').hitTestable());
    await pumpFeatureUi(tester);

    expect(selected, cityOptionByName('mumbai')!);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets(
    'CatchField.select exposes button semantics with label and value',
    (tester) async {
      final selected = cityOptionByName('mumbai')!;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: CatchField.select<CityOption>(
              title: 'City',
              values: defaultCityOptions,
              itemLabel: (city) => city.label,
              value: selected,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'City' &&
              widget.properties.value == 'Mumbai',
        ),
      );

      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);
    },
  );

  testWidgets('CatchField.select disabled state does not open menu', (
    tester,
  ) async {
    final selected = cityOptionByName('mumbai')!;

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            itemLabel: (city) => city.label,
            value: selected,
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'City' &&
            widget.properties.value == 'Mumbai',
      ),
    );

    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.enabled, isFalse);

    await tester.tap(find.byIcon(CatchIcons.expandMoreRounded));
    await pumpFeatureUi(tester);

    expect(find.text('Delhi'), findsNothing);
  });

  testWidgets('CatchField.select clears form state when options remove value', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final mumbai = cityOptionByName('mumbai')!;
    var selected = mumbai;
    var values = [mumbai, cityOptionByName('delhi')!];
    late StateSetter updateState;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 320,
                child: CatchField.select<CityOption>(
                  title: 'City',
                  values: values,
                  itemLabel: (city) => city.label,
                  value: selected,
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                  onChanged: (value) {
                    if (value != null) selected = value;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Mumbai'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);

    updateState(() {
      values = [cityOptionByName('delhi')!];
    });
    await tester.pump();
    await tester.pump();

    expect(find.text('Select city'), findsOneWidget);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Please select a city'), findsOneWidget);
  });

  test('CatchField guards ambiguous form configuration', () {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    expect(
      () => CatchField.input(
        title: 'Name',
        controller: controller,
        initialValue: 'Aanya',
      ),
      throwsAssertionError,
    );

    expect(
      () => CatchField.select<String>(
        title: 'Activity',
        values: const ['Run', 'Run'],
        itemLabel: (value) => value,
      ),
      throwsAssertionError,
    );
  });

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

  testWidgets('CatchField.select opens the shared CatchMenu panel', (
    tester,
  ) async {
    CityOption? selected = cityOptionByName('ahmedabad');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 240,
          child: CatchField.select<CityOption>(
            title: 'City',
            values: defaultCityOptions,
            value: selected,
            itemLabel: (city) => city.label,
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
            showLabel: false,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(CatchIcons.expandMoreRounded));
    await pumpFeatureUi(tester);

    // Select renders through the shared CatchMenu panel, not raw Material
    // menu items; the selected option carries the shared check affordance.
    expect(find.byType(CatchMenu<Object?>), findsOneWidget);
    expect(find.byType(MenuItemButton), findsNothing);
    expect(find.byIcon(CatchIcons.check), findsOneWidget);

    final other = defaultCityOptions.firstWhere(
      (city) => city != cityOptionByName('ahmedabad'),
    );
    await tester.tap(find.text(other.label));
    await pumpFeatureUi(tester);

    expect(selected, other);
    expect(find.byType(CatchMenu<Object?>), findsNothing);
  });
}

Finder get _startupLogoFinder {
  return find.byWidgetPredicate(
    (widget) => widget is Image && widget.semanticLabel == 'Catch',
  );
}

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

Future<void> _pumpCatchFieldMotion(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(CatchFieldTokens.reveal);
  await tester.pump();
}

void _noop() {}

String? _requiredPublicName(String? value) {
  return value == null || value.isEmpty ? 'Public name is required' : null;
}
