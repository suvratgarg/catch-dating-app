import 'package:catch_dating_app/swipes/presentation/widgets/profile_info_chip.dart';
import 'package:flutter/material.dart';

class ProfileLifestyleSection extends StatelessWidget {
  const ProfileLifestyleSection({super.key, required this.items});

  final List<({IconData icon, String text})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFESTYLE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in items) ProfileInfoChip(icon: i.icon, text: i.text),
            ],
          ),
        ],
      ),
    );
  }
}
