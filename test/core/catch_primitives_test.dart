import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/async_value_widget.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_dropdown_field.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
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
          ],
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Ghost'), findsOneWidget);
    expect(find.text('Danger'), findsOneWidget);
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
    Set<IndianCity> selected = {IndianCity.indore};

    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => ChipField<IndianCity>(
            label: 'City',
            values: IndianCity.values,
            selected: selected,
            multiSelect: false,
            onChanged: (next) => setState(() => selected = next),
          ),
        ),
      ),
    );

    await tester.tap(find.text(IndianCity.indore.label));
    await tester.pump();

    expect(selected, {IndianCity.indore});
  });

  testWidgets(
    'ChipField single select keeps chips inactive when selected is empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChipField<IndianCity>(
            label: 'City',
            values: IndianCity.values,
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
              widget.label == IndianCity.values.first.label,
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
        ChipField<IndianCity>(
          label: 'Cities',
          values: IndianCity.values.take(2).toList(),
          selected: {IndianCity.mumbai},
          multiSelect: true,
          onChanged: (_) {},
        ),
      ),
    );

    final selectedChip = tester.widget<CatchChip>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchChip && widget.label == IndianCity.mumbai.label,
      ),
    );
    final unselectedChip = tester.widget<CatchChip>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchChip && widget.label == IndianCity.delhi.label,
      ),
    );

    expect(selectedChip.active, isTrue);
    expect(selectedChip.icon, isA<Icon>());
    expect(unselectedChip.active, isFalse);
    expect(unselectedChip.icon, isNull);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
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
    IndianCity? selected;

    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: CatchDropdownField<IndianCity>(
            label: 'City',
            values: IndianCity.values,
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

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Mumbai').hitTestable());
    await pumpFeatureUi(tester);

    expect(selected, IndianCity.mumbai);
    expect(formKey.currentState!.validate(), isTrue);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}
