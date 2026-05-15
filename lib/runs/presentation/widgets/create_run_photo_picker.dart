import 'dart:typed_data';

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';

class CreateRunPhotoPicker extends StatelessWidget {
  const CreateRunPhotoPicker({
    super.key,
    required this.photoImageBytes,
    required this.onTap,
  });

  final Uint8List? photoImageBytes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasPhoto = photoImageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Run photo', isOptional: true),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: hasPhoto ? 'Change run photo' : 'Add run photo',
          child: GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.md),
                child: hasPhoto
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(photoImageBytes!, fit: BoxFit.cover),
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
                    : DecoratedBox(
                        decoration: BoxDecoration(color: t.raised),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: t.ink2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add run photo',
                                style: TextStyle(
                                  color: t.ink2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
