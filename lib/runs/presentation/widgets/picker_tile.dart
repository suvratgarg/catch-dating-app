import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class PickerTile extends StatelessWidget {
  const PickerTile({
    super.key,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: t.raised,
          borderRadius: BorderRadius.circular(CatchRadius.card),
          border: Border.all(color: t.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: t.ink2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? placeholder,
                style: value != null
                    ? CatchTextStyles.bodyMd(context)
                    : CatchTextStyles.bodyMd(context, color: t.ink3),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: t.ink3),
          ],
        ),
      ),
    );
  }
}
