import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_input_bar.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarContractStates(BuildContext context) {
  return const WidgetbookContractFrame(
    title: 'ChatInputBar',
    contractId: 'catch.chat_composer',
    states: [
      'empty-unfocused',
      'empty-focused',
      'draft-unfocused',
      'draft-focused',
      'multiline',
      'sending-text',
      'uploading-image',
      'disabled',
      'text-only',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'empty-unfocused',
        child: _ChatComposerContractPreview(),
      ),
      WidgetbookContractStateCard(
        label: 'draft-unfocused',
        child: _ChatComposerContractPreview(
          initialText: 'That last loop was fun.',
        ),
      ),
      WidgetbookContractStateCard(
        label: 'multiline',
        child: _ChatComposerContractPreview(
          initialText: 'A message that can wrap onto more than one line.',
        ),
      ),
      WidgetbookContractStateCard(
        label: 'sending-text',
        child: _ChatComposerContractPreview(
          initialText: 'Sending this now...',
          sending: true,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'uploading-image',
        child: _ChatComposerContractPreview(sendingImage: true),
      ),
      WidgetbookContractStateCard(
        label: 'disabled',
        child: _ChatComposerContractPreview(
          disabledReason: 'This chat is closed.',
        ),
      ),
      WidgetbookContractStateCard(
        label: 'text-only',
        child: _ChatComposerContractPreview(showImageButton: false),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Focused empty',
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarFocusedEmpty(BuildContext context) {
  return const Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: _ChatComposerContractPreview(autofocus: true),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Focused draft',
  type: ChatInputBar,
  path: '[Core primitives]/Product composites',
)
Widget chatInputBarFocusedDraft(BuildContext context) {
  return const Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: _ChatComposerContractPreview(
        initialText: 'That last loop was fun.',
        autofocus: true,
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPersonRow,
  path: '[Core primitives]/Product composites',
)
Widget catchPersonRowChatPreviewContractStates(BuildContext context) {
  final CatchPersonRowCopy copy = catchPersonRowCopy(context.l10n);
  return WidgetbookContractFrame(
    title: 'CatchPersonRow states',
    contractId: 'catch.person_row',
    states: const [
      'roster',
      'roster-trailing',
      'chat-preview',
      'chat-preview-new',
      'chat-preview-unread',
      'chat-preview-square-avatar',
      'divider',
      'long-copy',
      'directory',
      'directory-large-text',
      'chat-context',
      'chat-typing',
      'roster-long-copy',
      'contact-identity-only',
      'contact-navigable',
      'contact-message-enabled',
      'contact-verified',
      'contact-divider',
      'contact-long-copy',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'directory',
        child: CatchPersonRow.directory(
          data: const CatchPersonRowData(name: 'Ananya Rao'),
          meta: const Text('8 events · Last seen 18 June'),
          body: const Text('Returning customer'),
          trailing: const CatchBadge.status(
            label: 'Regular',
            tone: CatchBadgeTone.affinity,
          ),
          onTap: () {},
        ),
      ),
      WidgetbookContractStateCard(
        label: 'directory-large-text',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: CatchPersonRow.directory(
            data: const CatchPersonRowData(
              name: 'Ananya Rao with a longer family name',
            ),
            meta: const Text('8 events · Last seen 18 June'),
            body: const Text(
              'Returning customer with complete contextual information',
            ),
            trailing: const CatchBadge.status(
              label: 'Needs identity review',
              tone: CatchBadgeTone.warning,
            ),
            onTap: () {},
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'roster',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Aanya Rao',
              metaLine: '5:20 /km · 29',
              contextLine: 'Sundowner 5K',
            ),
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'roster-trailing',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Dev Malhotra',
              metaLine: 'Checked in',
              contextLine: 'Versova Padel',
            ),
            trailing: const CatchBadge(
              label: 'Host',
              tone: CatchBadgeTone.gold,
            ),
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-preview',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You: See you by the host stand.',
              timestamp: '9m',
            ),
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-preview-new',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You matched!',
              timestamp: '2m',
              isFresh: true,
              showFreshDot: true,
            ),
            showFreshBackground: false,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-preview-unread',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'I just joined the event.',
              timestamp: '1h',
              unreadCount: 2,
              isFresh: true,
            ),
            showFreshBackground: false,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-preview-square-avatar',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Catch Hosts',
              lastMessage: 'Can I bring a friend?',
              timestamp: '3h',
              unreadCount: 1,
              isFresh: true,
              avatarShape: CatchAvatarVariant.square,
            ),
            showFreshBackground: false,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'divider',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'You: See you there.',
              timestamp: '1d',
            ),
            divider: true,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'long-copy',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'A very long display name that should ellipsize',
              lastMessage:
                  'This is a very long latest message preview that should truncate cleanly inside the inbox row.',
              timestamp: '4d',
            ),
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'contact-identity-only',
        child: CatchPersonRow.contact(
          data: const CatchPersonRowData(
            name: 'Sunday sea-face crew',
            metaLine: 'HOSTING SINCE FEB 2026',
          ),
          colors: ActivityPalette.resolve(
            context,
            ActivityKind.socialRun,
          ).avatarColors,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'contact-navigable / message / verified / divider',
        child: CatchPersonRow.contact(
          data: const CatchPersonRowData(
            name: 'Catch supper club',
            metaLine: 'HOSTING SINCE MAR 2026 · REPLIES FAST',
          ),
          colors: ActivityPalette.resolve(
            context,
            ActivityKind.dinner,
          ).avatarColors,
          verified: true,
          divider: true,
          messageTooltip: 'Message host',
          onMessage: widgetbookNoop,
          onTap: widgetbookNoop,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'contact-long-copy',
        child: CatchPersonRow.contact(
          data: const CatchPersonRowData(
            name:
                'A deliberately long organizer identity for text-scale review',
            metaLine: 'LONG LOCATION AND RESPONSE METADATA',
          ),
          colors: ActivityPalette.resolve(
            context,
            ActivityKind.openActivity,
          ).avatarColors,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-context',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              contextLine: 'Sundowner 5K',
              lastMessage: 'See you by the host stand.',
            ),
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'chat-typing',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'Isha Mehta',
              lastMessage: 'Draft message',
              isTyping: true,
            ),
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'roster-long-copy',
        child: _MessageFrame(
          child: CatchPersonRow(
            copy: copy,
            data: const CatchPersonRowData(
              name: 'A very long roster name that should ellipsize',
              metaLine:
                  'A very long roster metadata line that should truncate inside the row.',
              contextLine:
                  'A very long event context that should stay inside the available width.',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: NotificationRow,
  path: '[Core primitives]/Product composites',
)
Widget notificationRowContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'NotificationRow',
    contractId: 'catch.notification_row',
    states: const [
      'unread',
      'read',
      'with-body',
      'divider',
      'non-navigable',
      'long-copy',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'unread',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventReminder,
            title: 'Event starts soon',
            time: '8m',
            body: 'Head to the south gate for check-in.',
            unread: true,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'read',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.clubUpdate,
            title: 'Run club posted an update',
            time: '2h',
            body: 'Sunday route changed to the waterfront.',
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'with-body',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.match,
            title: 'You matched',
            time: 'now',
            body: 'Start with a specific note about the event.',
            unread: true,
            onTap: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'waitlist promotion',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.waitlistPromotion,
            title: 'You are off the waitlist',
            time: '1d',
            onTap: widgetbookNoop,
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'non-navigable',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventCancelled,
            title: 'Event cancelled',
            time: '3d',
            body: 'No action is available for this update.',
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'long-copy',
        child: _MessageFrame(
          child: NotificationRow(
            type: ActivityNotificationType.eventUpdated,
            title:
                'A very long notification title that should wrap across lines',
            time: '11:42',
            body:
                'A long notification body should remain readable and avoid pushing the timestamp out of the row.',
            unread: true,
            onTap: widgetbookNoop,
          ),
        ),
      ),
    ],
  );
}

class _MessageFrame extends StatelessWidget {
  const _MessageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: WidgetbookPreviewLayout.wideContractWidth,
      tone: CatchSurfaceTone.surface,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: child,
    );
  }
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTimestampedMessageText,
  path: '[Core primitives]/Data display',
)
Widget catchTimestampedMessageContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'Timestamped message',
    contractId: 'catch.timestamped_message',
    states: const [
      'inline-timestamp',
      'stacked-timestamp',
      'empty-message',
      'large-text',
    ],
    children: [
      for (final example in const [
        ('inline-timestamp', 'Hi!', '19:30', 240.0),
        ('stacked-timestamp', 'See you', '19:30', 80.0),
        ('empty-message', '', '19:30', 240.0),
      ])
        WidgetbookContractStateCard(
          label: example.$1,
          child: SizedBox(
            width: example.$4,
            child: CatchTimestampedMessageText(
              text: example.$2,
              timestamp: example.$3,
              textStyle: CatchTextStyles.bodyM(context),
              timestampStyle: CatchTextStyles.numericMeta(context),
            ),
          ),
        ),
    ],
  );
}

class _ChatComposerContractPreview extends StatefulWidget {
  const _ChatComposerContractPreview({
    this.initialText = '',
    this.sending = false,
    this.sendingImage = false,
    this.disabledReason,
    this.showImageButton = true,
    this.autofocus = false,
  });

  final String initialText;
  final bool sending;
  final bool sendingImage;
  final String? disabledReason;
  final bool showImageButton;
  final bool autofocus;

  @override
  State<_ChatComposerContractPreview> createState() =>
      _ChatComposerContractPreviewState();
}

class _ChatComposerContractPreviewState
    extends State<_ChatComposerContractPreview> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatInputBar(
      controller: _controller,
      sending: widget.sending,
      sendingImage: widget.sendingImage,
      disabledReason: widget.disabledReason,
      showImageButton: widget.showImageButton,
      autofocus: widget.autofocus,
      onSend: widget.disabledReason == null ? widgetbookNoop : null,
      onSendImage: widget.disabledReason == null ? widgetbookNoop : null,
    );
  }
}
