import 'package:catch_dating_app/chats/domain/chat_message.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_message_list.dart';
import 'package:catch_dating_app/chats/presentation/widgets/message_bubble.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  testWidgets('message list gives multi-line bubbles enough height', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 500,
            child: ChatMessageList(
              messagesAsync: AsyncData([
                ChatMessage(
                  id: 'msg-1',
                  senderId: 'runner-2',
                  text: 'That Indore route was fun.\nSame pace next time?',
                  sentAt: DateTime(2026, 5, 8, 14, 48),
                ),
                ChatMessage(
                  id: 'msg-2',
                  senderId: 'runner-1',
                  text: 'Definitely. I liked the last 2 km push.',
                  sentAt: DateTime(2026, 5, 8, 14, 55),
                ),
                ChatMessage(
                  id: 'msg-3',
                  senderId: 'runner-2',
                  text: 'Coffee after the weekend run?',
                  sentAt: DateTime(2026, 5, 8, 15, 2),
                ),
              ]),
              currentUid: 'runner-1',
              otherName: 'Yash',
              scrollController: scrollController,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final firstTimestampBottom = tester.getBottomLeft(find.text('14:48')).dy;
    final secondMessageTop = tester
        .getTopLeft(find.text('Definitely. I liked the last 2 km push.'))
        .dy;
    final secondTimestampBottom = tester.getBottomRight(find.text('14:55')).dy;
    final thirdMessageTop = tester
        .getTopLeft(find.text('Coffee after the weekend run?'))
        .dy;

    expect(firstTimestampBottom, lessThan(secondMessageTop));
    expect(secondTimestampBottom, lessThan(thirdMessageTop));
    expect(tester.takeException(), isNull);
  });
}
