import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Canonical chat composer.
///
/// The component owns draft-derived sendability, focus chrome, action geometry,
/// multiline motion, and independent text/image pending states. Call sites
/// provide capabilities and mutations; they cannot accidentally enable an
/// empty send or disable the editor while an attachment is uploading.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
    this.onSendImage,
    this.sendingImage = false,
    this.disabledReason,
    this.showImageButton = true,
    this.autofocus = false,
  });

  static const Key pillKey = ValueKey('chat_input_bar.floating_pill');
  static const Key fieldLaneKey = ValueKey('chat_input_bar.field_lane');
  static const Key imageButtonKey = ValueKey('chat_input_bar.image_button');
  static const Key sendButtonKey = ValueKey('chat_input_bar.send_button');

  final TextEditingController controller;
  final bool sending;
  final VoidCallback? onSend;
  final VoidCallback? onSendImage;
  final bool sendingImage;
  final String? disabledReason;
  final bool showImageButton;
  final bool autofocus;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'ChatInputBar.message')
      ..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) => _ChatComposer(
        value: value,
        controller: widget.controller,
        focusNode: _focusNode,
        sending: widget.sending,
        sendingImage: widget.sendingImage,
        disabledReason: widget.disabledReason,
        showImageButton: widget.showImageButton,
        autofocus: widget.autofocus,
        onSend: widget.onSend,
        onSendImage: widget.onSendImage,
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.value,
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.sendingImage,
    required this.disabledReason,
    required this.showImageButton,
    required this.autofocus,
    required this.onSend,
    required this.onSendImage,
  });

  final TextEditingValue value;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final bool sendingImage;
  final String? disabledReason;
  final bool showImageButton;
  final bool autofocus;
  final VoidCallback? onSend;
  final VoidCallback? onSendImage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hardDisabled = disabledReason != null || onSend == null;
    final hasMessage = value.text.trim().isNotEmpty;
    final imageActionEnabled =
        !hardDisabled && !sendingImage && onSendImage != null;
    final sendActionEnabled = !hardDisabled && !sending && hasMessage;

    return TextFieldTapRegion(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: CatchInsets.chatComposerDock,
          child: AnimatedSize(
            duration: CatchMotion.fast,
            curve: CatchMotion.standardCurve,
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CatchRadius.pill),
                boxShadow: CatchElevation.raised,
              ),
              child: CatchControlShell(
                key: ChatInputBar.pillKey,
                size: CatchControlSize.floating,
                shape: CatchControlShape.pill,
                enabled: !hardDisabled,
                focused: !hardDisabled && focusNode.hasFocus,
                // BoxDecoration includes its border dimensions in Container
                // padding. Subtract the stroke so the visible outer inset is
                // exactly s2 on every edge.
                padding: const EdgeInsets.all(
                  CatchLayout.chatInputInnerPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showImageButton)
                      CatchIconButton(
                        key: ChatInputBar.imageButtonKey,
                        background: t.surface,
                        borderColor: t.line2,
                        disabled: !sendingImage && !imageActionEnabled,
                        onTap: imageActionEnabled ? onSendImage : null,
                        tooltip: sendingImage
                            ? context.l10n.chatsChatInputBarLabelUploadingImage
                            : context.l10n.chatsChatInputBarMessageSendAnImage,
                        liveRegion: sendingImage,
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
                    if (showImageButton) gapW8,
                    Expanded(
                      child: GestureDetector(
                        key: ChatInputBar.fieldLaneKey,
                        behavior: HitTestBehavior.opaque,
                        onTap: hardDisabled ? null : focusNode.requestFocus,
                        child: CatchFieldLanes.single(
                          child: CatchField.input(
                            title: context.l10n.chatsChatInputBarTitleMessage,
                            contract: CatchContractConstraints
                                .createChatMessageClientWriteDataText,
                            showLabel: false,
                            controller: controller,
                            focusNode: focusNode,
                            retainFocusOnSubmitted: true,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            inputHint:
                                disabledReason ??
                                context
                                    .l10n
                                    .chatsChatInputBarPlaceholderMessage,
                            size: CatchFieldSize.floating,
                            variant: CatchFieldVariant.bare,
                            enabled: !hardDisabled,
                            autofocus: autofocus,
                            onSubmitted: (_) {
                              if (sendActionEnabled) onSend?.call();
                            },
                          ),
                        ),
                      ),
                    ),
                    gapW8,
                    CatchIconButton(
                      key: ChatInputBar.sendButtonKey,
                      variant: CatchIconButtonVariant.plain,
                      background: t.ink,
                      disabled: !sending && !sendActionEnabled,
                      onTap: sendActionEnabled ? onSend : null,
                      tooltip: sending
                          ? context.l10n.chatsChatInputBarLabelSendingMessage
                          : context.l10n.chatsChatInputBarMessageSendMessage,
                      liveRegion: sending,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
