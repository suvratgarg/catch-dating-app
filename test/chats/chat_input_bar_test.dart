import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses canonical symmetric one-line geometry', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pumpComposer(tester, controller: controller);

    final pillRect = tester.getRect(find.byKey(ChatInputBar.pillKey));
    final imageRect = tester.getRect(find.byKey(ChatInputBar.imageButtonKey));
    final sendRect = tester.getRect(find.byKey(ChatInputBar.sendButtonKey));

    expect(find.byType(CatchBottomDock), findsNothing);
    expect(pillRect.left, CatchSpacing.screenPx);
    expect(pillRect.right, 390 - CatchSpacing.screenPx);
    expect(pillRect.height, 60);
    expect(imageRect.size, const Size.square(CatchIconButton.defaultSize));
    expect(sendRect.size, const Size.square(CatchIconButton.defaultSize));
    expect(imageRect.left - pillRect.left, CatchSpacing.s2);
    expect(imageRect.top - pillRect.top, CatchSpacing.s2);
    expect(pillRect.bottom - imageRect.bottom, CatchSpacing.s2);
    expect(pillRect.right - sendRect.right, CatchSpacing.s2);
    expect(sendRect.top - pillRect.top, CatchSpacing.s2);
    expect(pillRect.bottom - sendRect.bottom, CatchSpacing.s2);
    expect(imageRect.center.dy, sendRect.center.dy);
    expect(find.byTooltip('Send an image'), findsOneWidget);
    expect(find.byTooltip('Send message'), findsOneWidget);
    expect(find.text('Message…'), findsOneWidget);
  });

  testWidgets('derives sendability from the trimmed draft', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sends = 0;

    await _pumpComposer(tester, controller: controller, onSend: () => sends++);

    CatchIconButton sendButton() =>
        tester.widget(find.byKey(ChatInputBar.sendButtonKey));

    expect(sendButton().disabled, isTrue);
    await tester.tap(find.byKey(ChatInputBar.sendButtonKey));
    expect(sends, 0);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(sendButton().disabled, isTrue);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();
    expect(sendButton().disabled, isFalse);
    await tester.tap(find.byKey(ChatInputBar.sendButtonKey));
    expect(sends, 1);

    controller.clear();
    await tester.pump();
    expect(sendButton().disabled, isTrue);
  });

  testWidgets('renders real focus chrome without changing geometry', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Draft');
    addTearDown(controller.dispose);

    await _pumpComposer(tester, controller: controller);
    final beforePill = tester.getRect(find.byKey(ChatInputBar.pillKey));
    final beforeImage = tester.getRect(find.byKey(ChatInputBar.imageButtonKey));
    final beforeSend = tester.getRect(find.byKey(ChatInputBar.sendButtonKey));
    expect(
      tester
          .widget<CatchControlShell>(find.byKey(ChatInputBar.pillKey))
          .focused,
      isFalse,
    );

    await tester.tap(find.byKey(ChatInputBar.fieldLaneKey));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CatchControlShell>(find.byKey(ChatInputBar.pillKey))
          .focused,
      isTrue,
    );
    expect(tester.getRect(find.byKey(ChatInputBar.pillKey)), beforePill);
    expect(
      tester.getRect(find.byKey(ChatInputBar.imageButtonKey)),
      beforeImage,
    );
    expect(tester.getRect(find.byKey(ChatInputBar.sendButtonKey)), beforeSend);
  });

  testWidgets('animates multiline growth and keeps actions bottom aligned', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'One line');
    addTearDown(controller.dispose);

    await _pumpComposer(tester, controller: controller);
    final initialPill = tester.getRect(find.byKey(ChatInputBar.pillKey));

    controller.text = 'Line one\nLine two\nLine three\nLine four';
    await tester.pump();
    final animationStart = tester.getRect(find.byKey(ChatInputBar.pillKey));
    await tester.pump(const Duration(milliseconds: 60));
    final animationMiddle = tester.getRect(find.byKey(ChatInputBar.pillKey));
    await tester.pumpAndSettle();
    final finalPill = tester.getRect(find.byKey(ChatInputBar.pillKey));
    final imageRect = tester.getRect(find.byKey(ChatInputBar.imageButtonKey));
    final sendRect = tester.getRect(find.byKey(ChatInputBar.sendButtonKey));

    expect(animationStart.height, initialPill.height);
    expect(animationMiddle.height, greaterThan(initialPill.height));
    expect(animationMiddle.height, lessThan(finalPill.height));
    expect(finalPill.height, greaterThan(initialPill.height));
    expect(finalPill.bottom - imageRect.bottom, CatchSpacing.s2);
    expect(finalPill.bottom - sendRect.bottom, CatchSpacing.s2);
    expect(imageRect.size, const Size.square(CatchIconButton.defaultSize));
    expect(sendRect.size, const Size.square(CatchIconButton.defaultSize));
  });

  testWidgets('keeps focus for keyboard and internal action taps', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Ready');
    addTearDown(controller.dispose);
    var sends = 0;
    var images = 0;

    await _pumpComposer(
      tester,
      controller: controller,
      onSend: () => sends++,
      onSendImage: () => images++,
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.focusNode?.hasFocus, isTrue);

    await tester.tap(find.byKey(ChatInputBar.imageButtonKey));
    await tester.pump();
    expect(images, 1);
    expect(textField.focusNode?.hasFocus, isTrue);

    await tester.tap(find.byKey(ChatInputBar.sendButtonKey));
    await tester.pump();
    expect(sends, 1);
    expect(textField.focusNode?.hasFocus, isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(sends, 2);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('pending actions leave the editor and peer action usable', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Draft');
    addTearDown(controller.dispose);

    await _pumpComposer(tester, controller: controller, sending: true);

    var field = tester.widget<TextField>(find.byType(TextField));
    var image = tester.widget<CatchIconButton>(
      find.byKey(ChatInputBar.imageButtonKey),
    );
    var send = tester.widget<CatchIconButton>(
      find.byKey(ChatInputBar.sendButtonKey),
    );
    final sendingRects = _actionRects(tester);
    expect(field.enabled, isTrue);
    expect(image.onTap, isNotNull);
    expect(image.disabled, isFalse);
    expect(send.onTap, isNull);
    expect(send.disabled, isFalse);
    expect(find.byTooltip('Sending message'), findsOneWidget);

    await _pumpComposer(tester, controller: controller, sendingImage: true);

    field = tester.widget<TextField>(find.byType(TextField));
    image = tester.widget<CatchIconButton>(
      find.byKey(ChatInputBar.imageButtonKey),
    );
    send = tester.widget<CatchIconButton>(
      find.byKey(ChatInputBar.sendButtonKey),
    );
    expect(field.enabled, isTrue);
    expect(image.onTap, isNull);
    expect(image.disabled, isFalse);
    expect(send.onTap, isNotNull);
    expect(send.disabled, isFalse);
    expect(find.byTooltip('Uploading image'), findsOneWidget);
    expect(_actionRects(tester), sendingRects);
  });

  testWidgets('exposes one editable node and one node per action', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final semantics = tester.ensureSemantics();

    await _pumpComposer(tester, controller: controller);

    final editableNode = tester.getSemantics(find.byType(TextField));
    expect(editableNode.flagsCollection.isTextField, isTrue);
    expect(editableNode.label, 'Message');
    expect(find.bySemanticsLabel('Message'), findsOne);
    expect(find.bySemanticsLabel('Send an image'), findsOne);
    expect(find.bySemanticsLabel('Send message'), findsOne);
    semantics.dispose();
  });
}

Future<void> _pumpComposer(
  WidgetTester tester, {
  required TextEditingController controller,
  bool sending = false,
  bool sendingImage = false,
  VoidCallback? onSend,
  VoidCallback? onSendImage,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

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
                sending: sending,
                sendingImage: sendingImage,
                onSend: onSend ?? () {},
                onSendImage: onSendImage ?? () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

(Rect, Rect) _actionRects(WidgetTester tester) => (
  tester.getRect(find.byKey(ChatInputBar.imageButtonKey)),
  tester.getRect(find.byKey(ChatInputBar.sendButtonKey)),
);
