import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Eventless Chats blast preview retained separately from the event-aware Host
/// broadcast workflow.
class ChatBlastComposerSheet extends StatelessWidget {
  const ChatBlastComposerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: CatchSurface(
          backgroundColor: t.surface,
          borderColor: t.line,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s4,
            bottom: CatchSpacing.s5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CatchSurface(
                  width: CatchSpacing.s10,
                  height: CatchStroke.hairline * 3,
                  radius: CatchRadius.pill,
                  backgroundColor: t.line,
                  borderWidth: 0,
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: CatchSpacing.s4),
              Text(
                context.l10n.chatsChatInboxScreenTextNewBlast,
                style: CatchTextStyles.titleL(context),
              ),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                context.l10n.chatsChatInboxScreenTextBroadcastSendingIsNot,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              const SizedBox(height: CatchSpacing.s4),
              CatchSurface(
                tone: CatchSurfaceTone.raised,
                borderColor: t.line,
                radius: CatchRadius.md,
                padding: const EdgeInsets.all(CatchSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.chatsChatInboxScreenTextReminder,
                      style: CatchTextStyles.fieldRowTitle(context),
                    ),
                    const SizedBox(height: CatchSpacing.micro2),
                    Text(
                      context.l10n.chatsChatInboxScreenTextSeeYouTonightAt,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CatchSpacing.s2),
              CatchSurface(
                tone: CatchSurfaceTone.raised,
                borderColor: t.line,
                radius: CatchRadius.md,
                padding: const EdgeInsets.all(CatchSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.chatsChatInboxScreenTextMeetingPoint,
                      style: CatchTextStyles.fieldRowTitle(context),
                    ),
                    const SizedBox(height: CatchSpacing.micro2),
                    Text(
                      context
                          .l10n
                          .chatsChatInboxScreenTextShareArrivalNotesParking,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CatchSpacing.s4),
              CatchButton(
                label: context.l10n.chatsChatInboxScreenLabelSendBroadcast,
                onPressed: null,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
