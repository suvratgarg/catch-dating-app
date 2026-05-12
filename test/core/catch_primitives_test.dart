import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/async_value_widget.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/settings_row.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
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
                  label: 'Join run',
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
        tester.getSize(find.widgetWithText(CatchButton, 'Join run')).height,
        56,
      );
      expect(
        tester.getSize(find.widgetWithText(CatchButton, 'Join run')).width,
        240,
      );

      await tester.tap(find.text('Join run'));
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

  testWidgets('CatchButton renders all catalog variants', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Wrap(
          children: [
            CatchButton(
              label: 'Primary',
              onPressed: null,
              variant: CatchButtonVariant.primary,
            ),
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

    expect(label.style?.color, CatchTokens.sunsetLight.ink);
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
    expect(label.style?.color, Colors.white);
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
    expect(label.style?.color, CatchTokens.sunsetLight.primary);
  });

  testWidgets('SettingsRow value occupies a right-aligned value lane', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 360,
          child: SettingsRow(
            label: 'Help & support',
            value: 'Contact us',
            icon: Icons.help_outline,
            onTap: null,
          ),
        ),
      ),
    );

    final valueText = tester.widget<Text>(find.text('Contact us'));
    final valueBox = tester.getSize(find.text('Contact us'));
    final labelRight = tester.getTopRight(find.text('Help & support')).dx;
    final valueLeft = tester.getTopLeft(find.text('Contact us')).dx;

    expect(valueText.textAlign, TextAlign.right);
    expect(valueBox.width, greaterThanOrEqualTo(110));
    expect(valueLeft, greaterThan(labelRight));
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
              length: 6,
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
      expect(find.text('1'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsNothing);
    },
  );

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
      find.widgetWithIcon(IconButton, Icons.add_rounded),
    );
    expect(disabledIncrease.onPressed, isNull);

    await tester.tap(find.byTooltip('Decrease height'));
    await tester.pump();
    expect(find.text('170 cm'), findsOneWidget);
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

    await tester.tap(find.text('Easy'));
    await tester.pump();
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(removed, isTrue);
  });

  testWidgets('ChipField single select keeps a selected chip selected', (
    tester,
  ) async {
    Set<CityOption> selected = {cityOptionByName('indore')!};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => ChipField<CityOption>(
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
    'ChipField optional single select clears a selected chip when enabled',
    (tester) async {
      Set<CityOption> selected = {cityOptionByName('indore')!};

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => ChipField<CityOption>(
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
    'ChipField single select keeps chips inactive when selected is empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChipField<CityOption>(
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

  testWidgets('ChipField multi select marks selected chips with a check', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ChipField<CityOption>(
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
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('ChipField required multi select keeps the last chip selected', (
    tester,
  ) async {
    Set<CityOption> selected = {cityOptionByName('mumbai')!};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => ChipField<CityOption>(
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
  });

  testWidgets('CatchBadge renders status tones and uppercase option', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Wrap(
          children: [
            CatchBadge(label: 'pending'),
            CatchBadge(label: 'paid', tone: CatchBadgeTone.success),
            CatchBadge(
              label: 'live - 6h left',
              tone: CatchBadgeTone.live,
              uppercase: true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('pending'), findsOneWidget);
    expect(find.text('paid'), findsOneWidget);
    expect(find.text('LIVE - 6H LEFT'), findsOneWidget);
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
    await tester.tap(find.text('Developer details'));
    await pumpFeatureUi(tester);
    expect(find.textContaining('Bad state: boom'), findsOneWidget);
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
    expect(find.text('Could not load profile'), findsOneWidget);
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
    expect(find.text('Please enter a valid phone number.'), findsOneWidget);
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
  });

  testWidgets('AsyncValueWidget uses branded default error state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsyncValueWidget<int>(
          value: AsyncError<int>(StateError('load failed'), StackTrace.empty),
          data: (value) => Text('$value'),
        ),
      ),
    );

    expect(find.byType(CatchErrorState), findsOneWidget);
    expect(find.text('load failed'), findsOneWidget);
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

    expect(find.text('snack failed'), findsOneWidget);
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
      await tester.pumpAndSettle();

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(retryCount, 1);
    },
  );

  testWidgets(
    'CatchTextField renders label, helper text, changes, and errors',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      var latestValue = '';

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: CatchTextField(
              label: 'Run title',
              hintText: 'Short and memorable',
              helperText: 'Shows on run cards',
              validator: (value) => value == null || value.isEmpty
                  ? "Title can't be empty"
                  : null,
              onChanged: (value) => latestValue = value,
            ),
          ),
        ),
      );

      expect(find.text('Run title'), findsOneWidget);
      expect(find.text('Short and memorable'), findsOneWidget);
      expect(find.text('Shows on run cards'), findsOneWidget);

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text("Title can't be empty"), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Sunrise Seawall 7K');
      await tester.pump();
      expect(latestValue, 'Sunrise Seawall 7K');
      expect(formKey.currentState!.validate(), isTrue);
    },
  );

  testWidgets(
    'CatchTextField syncs external controller edits into validation',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: CatchTextField(
              label: 'Date of birth',
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

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(controller.text, '15/04/1997');
      expect(formKey.currentState!.validate(), isTrue);
    },
  );

  testWidgets(
    'CatchTextField keeps non-actionable read-only fields out of focus',
    (tester) async {
      final controller = TextEditingController(text: '+91 9876543210');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          CatchTextField(
            label: 'Mobile number',
            controller: controller,
            readOnly: true,
            helperText: 'Verified via OTP',
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );

      expect(editableText.readOnly, isTrue);
      expect(editableText.focusNode.hasFocus, isFalse);
    },
  );

  testWidgets('CatchTextField renders optional field marker', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const CatchTextField(
          label: 'Bio',
          isOptional: true,
          hintText: 'Share a little about yourself',
        ),
      ),
    );

    expect(find.text('Bio'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Bio, optional',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CatchDropdownField validates and reports selection changes', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    CityOption? selected;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchDropdownField<CityOption>(
            label: 'City',
            values: defaultCityOptions,
            value: selected,
            validator: (value) => value == null ? 'Please select a city' : null,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please select a city'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_more_rounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Mumbai').hitTestable());
    await pumpFeatureUi(tester);

    expect(selected, cityOptionByName('mumbai')!);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('CatchSelectMenu uses normal menu corners for pill triggers', (
    tester,
  ) async {
    CityOption? selected = cityOptionByName('ahmedabad');

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 240,
          child: CatchSelectMenu<CityOption>(
            values: defaultCityOptions,
            value: selected,
            itemLabel: (city) => city.label,
            prefixIcon: const Icon(Icons.location_on_outlined),
            shape: CatchSelectMenuShape.pill,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.expand_more_rounded));
    await pumpFeatureUi(tester);

    expect(find.byType(MenuItemButton), findsWidgets);
    expect(
      tester.widgetList<Material>(find.byType(Material)).any((material) {
        final shape = material.shape;
        return shape is RoundedRectangleBorder &&
            shape.borderRadius == BorderRadius.circular(CatchRadius.sm);
      }),
      isTrue,
    );
  });
}

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}
