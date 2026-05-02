import 'dart:typed_data';

import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CreateRunClubCoverPicker extends StatelessWidget {
  const CreateRunClubCoverPicker({
    super.key,
    required this.coverImageBytes,
    this.existingImageUrl,
    required this.onTap,
  });

  final Uint8List? coverImageBytes;
  final String? existingImageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasCover = coverImageBytes != null || existingImageUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.md),
          child: hasCover
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    if (coverImageBytes != null)
                      Image.memory(coverImageBytes!, fit: BoxFit.cover)
                    else
                      Image.network(
                        existingImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(color: t.raised),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: t.surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: t.ink,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: t.raised,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: t.ink2,
                      ),
                      gapH8,
                      Text(
                        'Add cover photo',
                        style: CatchTextStyles.bodyM(context, color: t.ink2),
                      ),
                      Text(
                        'Optional',
                        style: CatchTextStyles.bodyS(context, color: t.ink3),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
