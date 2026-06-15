import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
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
            _ComposerIconAction(
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
          _ComposerIconAction(
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

class _ComposerIconAction extends StatelessWidget {
  const _ComposerIconAction({
    required this.tooltip,
    required this.icon,
    this.onPressed,
    this.disabled = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool disabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveForeground = foregroundColor ?? t.ink2;
    final enabled = !disabled && onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: IconTheme(
          data: IconThemeData(color: effectiveForeground, size: CatchIcon.md),
          child: IconBtn(
            size: 42,
            background: backgroundColor ?? Colors.transparent,
            onTap: enabled ? onPressed : null,
            child: icon,
          ),
        ),
      ),
    );
  }
}
