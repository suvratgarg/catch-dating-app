import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchErrorBanner extends StatelessWidget {
  const CatchErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      color: t.surface,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          8,
          CatchSpacing.s4,
          0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(CatchRadius.md),
          border: Border.all(color: const Color(0xFFFFCCCC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: Color(0xFFCC3333),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: CatchTextStyles.bodyS(
                  context,
                  color: const Color(0xFFCC3333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
