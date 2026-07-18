import 'package:catch_dating_app/chats/presentation/inbox/chat_blast_composer_sheet.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('eventless Chats blast remains an explicitly named preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ChatBlastComposerSheet()),
      ),
    );

    expect(find.byType(ChatBlastComposerSheet), findsOneWidget);
    expect(find.text('New blast'), findsOneWidget);
    expect(find.text('Send broadcast'), findsOneWidget);
    expect(
      tester.widget<CatchButton>(find.byType(CatchButton)).onPressed,
      isNull,
    );
  });
}
