import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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

  static const Key pillKey = ValueKey('chat_input_bar.floating_pill');

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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.screenPx,
          0,
          CatchSpacing.screenPx,
          CatchSpacing.s3,
        ),
        child: AnimatedSize(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            key: pillKey,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              border: Border.all(color: t.line),
              boxShadow: CatchElevation.raised,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s2,
                CatchSpacing.s1,
                CatchSpacing.s1,
                CatchSpacing.s1,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showImageButton)
                    Semantics(
                      label: context.l10n.chatsChatInputBarLabelSendAnImage,
                      button: true,
                      enabled: imageActionEnabled,
                      child: Tooltip(
                        message:
                            context.l10n.chatsChatInputBarMessageSendAnImage,
                        child: CatchIconButton(
                          size: 42,
                          background: t.surface,
                          borderColor: t.line2,
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
                  if (showImageButton) gapW8,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchSpacing.s1,
                        vertical: CatchSpacing.micro10,
                      ),
                      child: CatchField.input(
                        title: context.l10n.chatsChatInputBarTitleMessage,
                        showLabel: false,
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        placeholder:
                            disabledReason ??
                            context.l10n.chatsChatInputBarPlaceholderMessage,
                        size: CatchFieldSize.floating,
                        variant: CatchFieldVariant.bare,
                        enabled: onSend != null && !disabled,
                        onSubmitted: (_) => onSend?.call(),
                      ),
                    ),
                  ),
                  gapW8,
                  Semantics(
                    label: context.l10n.chatsChatInputBarLabelSendMessage,
                    button: true,
                    enabled: sendActionEnabled,
                    child: Tooltip(
                      message: context.l10n.chatsChatInputBarMessageSendMessage,
                      child: CatchIconButton(
                        size: 46,
                        variant: CatchIconButtonVariant.plain,
                        background: t.ink,
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
            ),
          ),
        ),
      ),
    );
  }
}
