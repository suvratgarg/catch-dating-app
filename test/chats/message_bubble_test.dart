import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders message text and formatted time', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MessageBubble(
            text: 'Morning run?',
            isMe: true,
            sentAt: DateTime(2026, 4, 23, 9, 5),
          ),
        ),
      ),
    );

    expect(find.text('Morning run?'), findsOneWidget);
    expect(find.text('09:05'), findsOneWidget);
  });
}
