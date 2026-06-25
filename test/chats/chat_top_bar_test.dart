import 'package:catch_dating_app/chats/presentation/widgets/chat_top_bar.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('runs profile callback from the chat identity title', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: ChatTopBar(
            name: 'Taylor',
            photoUrl: null,
            onProfileTap: () => opened = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Taylor'));
    await pumpFeatureUi(tester);

    expect(opened, isTrue);
  });

  testWidgets('keeps profile out of the overflow menu', (tester) async {
    final selected = <ChatTopBarAction>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: ChatTopBar(
            name: 'Taylor',
            photoUrl: null,
            onProfileTap: () {},
            actions: const [ChatTopBarAction.report, ChatTopBarAction.block],
            onActionSelected: selected.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);

    expect(find.text('View profile'), findsNothing);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Block'), findsOneWidget);
  });

  testWidgets('runs share-card action from the overflow menu', (tester) async {
    final selected = <ChatTopBarAction>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: ChatTopBar(
            name: 'Taylor',
            photoUrl: null,
            actions: const [
              ChatTopBarAction.shareCard,
              ChatTopBarAction.report,
              ChatTopBarAction.block,
            ],
            onActionSelected: selected.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Share card'));
    await pumpFeatureUi(tester);

    expect(selected, [ChatTopBarAction.shareCard]);
  });

  testWidgets('does not select disabled overflow actions', (tester) async {
    final selected = <ChatTopBarAction>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: ChatTopBar(
            name: 'Taylor',
            photoUrl: null,
            actions: const [ChatTopBarAction.report, ChatTopBarAction.block],
            disabledActions: const {ChatTopBarAction.report},
            onActionSelected: selected.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Chat actions'));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Report'));
    await pumpFeatureUi(tester);

    expect(selected, isEmpty);

    await tester.tap(find.text('Block'));
    await pumpFeatureUi(tester);

    expect(selected, [ChatTopBarAction.block]);
  });
}
