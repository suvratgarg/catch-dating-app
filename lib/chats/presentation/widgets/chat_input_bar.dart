import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
    this.onSendImage,
    this.sendingImage = false,
    this.disabledReason,
    this.showImageButton = true,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback? onSend;
  final VoidCallback? onSendImage;
  final bool sendingImage;
  final String? disabledReason;
  final bool showImageButton;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final disabled = sending || sendingImage;

    return CatchBottomDock(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Row(
        children: [
          if (showImageButton)
            IconButton(
              onPressed: disabled ? null : onSendImage,
              icon: sendingImage
                  ? const SizedBox.square(
                      dimension: CatchIcon.control,
                      child: CatchLoadingIndicator(strokeWidth: 2),
                    )
                  : Icon(CatchIcons.imageOutlined, color: t.ink2),
              tooltip: 'Send an image',
            ),
          Expanded(
            child: CatchTextField(
              label: 'Message',
              showLabel: false,
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              hintText: disabledReason ?? 'Message...',
              size: CatchTextFieldSize.compact,
              shape: CatchTextFieldShape.pill,
              tone: CatchTextFieldTone.raised,
              enabled: onSend != null && !disabled,
              onSubmitted: (_) => onSend?.call(),
            ),
          ),
          gapW8,
          IconButton.filled(
            onPressed: disabled ? null : onSend,
            tooltip: 'Send message',
            icon: sending
                ? const SizedBox.square(
                    dimension: CatchIcon.control,
                    child: CatchLoadingIndicator(strokeWidth: 2),
                  )
                : Icon(CatchIcons.sendRounded),
          ),
        ],
      ),
    );
  }
}
