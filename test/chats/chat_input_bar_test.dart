import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatInputBar floats as a full-width composer pill', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(bottom: 34),
            viewPadding: EdgeInsets.only(bottom: 34),
          ),
          child: Scaffold(
            body: Column(
              children: [
                const Spacer(),
                ChatInputBar(
                  controller: controller,
                  sending: false,
                  onSend: () {},
                  onSendImage: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final pillRect = tester.getRect(find.byKey(ChatInputBar.pillKey));

    expect(find.byType(CatchBottomDock), findsNothing);
    expect(pillRect.left, CatchSpacing.screenPx);
    expect(pillRect.right, 390 - CatchSpacing.screenPx);
    expect(find.byTooltip('Send an image'), findsOneWidget);
    expect(find.byTooltip('Send message'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
      'Message...',
    );
  });
}
