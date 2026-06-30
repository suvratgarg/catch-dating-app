import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
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
    final imageActionEnabled = !disabled && onSendImage != null;
    final sendActionEnabled = !disabled && onSend != null;

    return CatchBottomDock(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showImageButton)
            Semantics(
              label: 'Send an image',
              button: true,
              enabled: imageActionEnabled,
              child: Tooltip(
                message: 'Send an image',
                child: CatchIconButton(
                  size: 42,
                  background: Colors.transparent,
                  disabled: !imageActionEnabled,
                  onTap: imageActionEnabled ? onSendImage : null,
                  child: sendingImage
                      ? SizedBox.square(
                          dimension: CatchIcon.control,
                          child: CatchLoadingIndicator(
                            strokeWidth: 2,
                            color: t.ink2,
                          ),
                        )
                      : Icon(
                          CatchIcons.imageOutlined,
                          size: CatchIcon.md,
                          color: t.ink2,
                        ),
                ),
              ),
            ),
          Expanded(
            child: CatchSection.contained(
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
              child: CatchField.input(
                title: 'Message',
                showLabel: false,
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                placeholder: disabledReason ?? 'Message...',
                size: CatchFieldSize.compact,
                enabled: onSend != null && !disabled,
                onSubmitted: (_) => onSend?.call(),
              ),
            ),
          ),
          gapW8,
          Semantics(
            label: 'Send message',
            button: true,
            enabled: sendActionEnabled,
            child: Tooltip(
              message: 'Send message',
              child: CatchIconButton(
                size: 42,
                background: t.primary,
                disabled: !sendActionEnabled,
                onTap: sendActionEnabled ? onSend : null,
                child: sending
                    ? SizedBox.square(
                        dimension: CatchIcon.control,
                        child: CatchLoadingIndicator(
                          strokeWidth: 2,
                          color: t.primaryInk,
                        ),
                      )
                    : Icon(
                        CatchIcons.sendRounded,
                        size: CatchIcon.md,
                        color: t.primaryInk,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
