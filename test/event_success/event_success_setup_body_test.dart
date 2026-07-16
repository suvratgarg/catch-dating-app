import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('setup body uses CatchField choices for live guide choices', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var attendeePrompt = '';
    var immediateDraftChanges = 0;
    var stagedDraftChanges = 0;
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
                  onDraftChanged: (next) {
                    stagedDraftChanges += 1;
                    setState(() => draft = next);
                  },
                  onImmediateDraftChanged: (update) {
                    immediateDraftChanges += 1;
                    setState(() => draft = update(draft));
                  },
                  onAttendeePromptChanged: (next) =>
                      setState(() => attendeePrompt = next),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<CatchField>(_field('Switch partners every')).initiallyOpen,
      isFalse,
    );
    await _openField(tester, 'Switch partners every');
    expect(_choice('15 min', selected: true), findsOneWidget);
    await _openField(tester, 'Reveal countdown');
    expect(_choice('10s', selected: true), findsOneWidget);
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
    expect(immediateDraftChanges, 2);
    expect(stagedDraftChanges, 0);

    await _openField(tester, 'Switch partners every');
    await _tapChoice(tester, '20 min');
    await tester.pump();
    expect(draft.structureConfig.rotationIntervalMinutes, 20);
    expect(_choice('20 min', selected: true), findsOneWidget);

    await _openField(tester, 'Reveal countdown');
    await _tapChoice(tester, '15s');
    await tester.pump();
    expect(draft.structureConfig.revealCountdownSeconds, 15);
    expect(_choice('15s', selected: true), findsOneWidget);

    expect(_field('How the room is grouped'), findsNothing);
    expect(_field('Group people into'), findsOneWidget);
    expect(_field('Match clue questions'), findsOneWidget);
    expect(
      find.ancestor(
        of: _field('Match clue questions'),
        matching: find.byType(CatchSection),
      ),
      findsOneWidget,
    );
    final flowFieldBounds = tester.getRect(_field('Group people into'));
    final matchClueBounds = tester.getRect(_field('Match clue questions'));
    expect(matchClueBounds.left, flowFieldBounds.left);
    expect(matchClueBounds.right, flowFieldBounds.right);
    await _openField(tester, 'Match clue questions');
    expect(_choice('Clues only', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Clues + soft pairing');
    await tester.pump();
    expect(
      draft.isModuleSelected(
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ),
      isTrue,
    );
    expect(draft.compatibilityAffectsRanking, isTrue);
    expect(_choice('Clues + soft pairing', selected: true), findsOneWidget);

    _invokeChoice(tester, 'Off');
    await tester.pump();
    expect(
      draft.isModuleSelected(
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      ),
      isFalse,
    );
    expect(draft.compatibilityAffectsRanking, isFalse);
    expect(_choice('Off', selected: true), findsOneWidget);
  });
}

Future<void> _tapChoice(WidgetTester tester, String label) async {
  final finder = _choice(label);
  await tester.ensureVisible(finder);
  await tester.pump();
  tester.widgetList<CatchFieldChoiceChip>(finder).last.onPressed();
}

void _invokeChoice(WidgetTester tester, String label) {
  tester.widgetList<CatchFieldChoiceChip>(_choice(label)).last.onPressed();
}

Future<void> _openField(WidgetTester tester, String title) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == title,
  );
  await tester.ensureVisible(field.last);
  await tester.tap(field.last);
  await tester.pump(kThemeAnimationDuration);
  await tester.pump();
}

Future<void> _tapToggle(WidgetTester tester, String label) async {
  final finder = _fieldToggle(label);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Finder _fieldToggle(String label) {
  return _field(label);
}

Finder _field(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
}

Finder _choice(String label, {bool? selected}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchFieldChoiceChip &&
        widget.label == label &&
        (selected == null || widget.selected == selected),
    skipOffstage: false,
  );
}
