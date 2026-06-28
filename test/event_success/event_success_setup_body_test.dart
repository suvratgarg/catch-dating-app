import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('setup body uses CatchSelectChip for live guide choices', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var attendeePrompt = '';
    var draft =
        EventSuccessHostDraft.fromActivity(
              ActivityKind.pickleball,
              targetAttendeeCount: 16,
            )
            .withModuleSelection(
              EventSuccessModuleCatalog.guidedRotations.id,
              true,
            )
            .withModuleSelection(EventSuccessModuleCatalog.liveReveal.id, true)
            .withModuleSelection(
              EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
              true,
            )
            .copyWith(
              structureConfig: const EventSuccessStructureConfig(
                unitKind: EventSuccessUnitKind.pairs,
                unitSize: 2,
                rotationIntervalMinutes: 15,
              ),
            );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return EventSuccessSetupBody(
                  draft: draft,
                  eventFormat: EventFormatSnapshot.fromActivityKind(
                    ActivityKind.pickleball,
                  ),
                  targetAttendeeCount: 16,
                  attendeePrompt: attendeePrompt,
                  onDraftChanged: (next) => setState(() => draft = next),
                  onAttendeePromptChanged: (next) =>
                      setState(() => attendeePrompt = next),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(_selectChip('15 min', active: true), findsOneWidget);
    expect(_selectChip('10s', active: true), findsOneWidget);
    expect(
      _fieldToggle(EventSuccessModuleCatalog.liveReveal.title),
      findsOneWidget,
    );
    expect(find.byType(ExpansionTile), findsNothing);

    await _tapToggle(tester, EventSuccessModuleCatalog.liveReveal.title);
    await tester.pump();
    expect(
      draft.isModuleSelected(EventSuccessModuleCatalog.liveReveal.id),
      isFalse,
    );

    await _tapToggle(tester, EventSuccessModuleCatalog.liveReveal.title);
    await tester.pump();
    expect(
      draft.isModuleSelected(EventSuccessModuleCatalog.liveReveal.id),
      isTrue,
    );

    await _tapSelectChip(tester, '20 min');
    await tester.pump();
    expect(draft.structureConfig.rotationIntervalMinutes, 20);
    expect(_selectChip('20 min', active: true), findsOneWidget);

    await _tapSelectChip(tester, '15s');
    await tester.pump();
    expect(draft.structureConfig.revealCountdownSeconds, 15);
    expect(_selectChip('15s', active: true), findsOneWidget);

    await tester.tap(find.text('Advanced'));
    await tester.pump(kThemeAnimationDuration);
    await tester.pump();

    expect(_selectChip('Clues only', active: true), findsOneWidget);

    _invokeSelectChip(tester, 'Clues + soft pairing');
    await tester.pump();
    expect(
      draft.isModuleSelected(
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ),
      isTrue,
    );
    expect(draft.compatibilityAffectsRanking, isTrue);
    expect(_selectChip('Clues + soft pairing', active: true), findsOneWidget);

    _invokeSelectChip(tester, 'Off');
    await tester.pump();
    expect(
      draft.isModuleSelected(
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ),
      isFalse,
    );
    expect(draft.compatibilityAffectsRanking, isFalse);
    expect(_selectChip('Off', active: true), findsOneWidget);
  });
}

Future<void> _tapSelectChip(WidgetTester tester, String label) async {
  final finder = _selectChip(label);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(find.descendant(of: finder, matching: find.text(label)));
}

void _invokeSelectChip(WidgetTester tester, String label) {
  tester.widgetList<CatchSelectChip>(_selectChip(label)).last.onTap!();
}

Future<void> _tapToggle(WidgetTester tester, String label) async {
  final finder = _fieldToggle(label);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Finder _fieldToggle(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
}

Finder _selectChip(String label, {bool? active}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchSelectChip &&
        widget.label == label &&
        (active == null || widget.active == active),
  );
}
