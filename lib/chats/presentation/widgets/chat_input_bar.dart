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

    return CatchBottomDock(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showImageButton)
            _buildComposerIconAction(
              context,
              tooltip: 'Send an image',
              onPressed: disabled ? null : onSendImage,
              disabled: disabled || onSendImage == null,
              foregroundColor: t.ink2,
              icon: sendingImage
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
          Expanded(
            child: CatchSection(
              variant: CatchSectionVariant.contained,
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
              child: CatchField(
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
          _buildComposerIconAction(
            context,
            tooltip: 'Send message',
            onPressed: disabled ? null : onSend,
            disabled: disabled || onSend == null,
            backgroundColor: t.primary,
            foregroundColor: t.primaryInk,
            icon: sending
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
        ],
      ),
    );
  }
}

Widget _buildComposerIconAction(
  BuildContext context, {
  required String tooltip,
  required Widget icon,
  VoidCallback? onPressed,
  bool disabled = false,
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final t = CatchTokens.of(context);
  final effectiveForeground = foregroundColor ?? t.ink2;
  final enabled = !disabled && onPressed != null;

  return Tooltip(
    message: tooltip,
    child: Opacity(
      opacity: enabled ? 1 : 0.4,
      child: IconTheme(
        data: IconThemeData(color: effectiveForeground, size: CatchIcon.md),
        child: CatchIconButton(
          size: 42,
          background: backgroundColor ?? Colors.transparent,
          onTap: enabled ? onPressed : null,
          child: icon,
        ),
      ),
    ),
  );
}
