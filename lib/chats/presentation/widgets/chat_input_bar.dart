import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p12,
          vertical: Sizes.p8,
        ),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(top: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: CatchTextField(
                label: 'Message',
                showLabel: false,
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                hintText: 'Message...',
                size: CatchTextFieldSize.compact,
                shape: CatchTextFieldShape.pill,
                tone: CatchTextFieldTone.raised,
                enabled: onSend != null,
                onSubmitted: (_) => onSend?.call(),
              ),
            ),
            gapW8,
            IconButton.filled(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CatchLoadingIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
